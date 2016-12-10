# encoding: utf-8
require "jekyll"
require "pjey/version"

module Jekyll

  class PjayPageGenerator < Generator
    safe true

    def generate(site)
      
      site.pages.each do |jekyll_page|
        if jekyll_page.data && jekyll_page.data['pjey'] && jekyll_page.data['pjey_activated'] != false
          if jekyll_page.data['pjey'].is_a?(Hash)
            pjey = Jekyll::Pjey.new(jekyll_page, site.posts, jekyll_page.data['pjey'])
          else
            pjey = Jekyll::Pjey.new(jekyll_page, site.posts)
          end

          pjey.paginate(pjey.data).each do |page_data|
            if page_data['page']['page'] == 1
              jekyll_page.data['pjey_page'] = page_data
            else
              site.pages << PjeyPage.new(site, page_data['page']['path'], page_data)
            end
          end
        end
      end

    end
  end

  class PjeyPage < Page
    
    def initialize(site, path, page_data)
      @site = site
      @dir = File.dirname(path)
      @dir = "" if @dir == "."

      @page_data = page_data
      @name = page_data['page']['filename']

      self.ext = File.extname(@name)
      self.basename = File.basename(@name)
      
      # this has to be the source file
      source_dir = File.dirname(File.join(site.source, page_data['page']['root']['path']))
      source_file = File.basename(page_data['page']['root']['path'])
      self.read_yaml(source_dir, source_file) 
      
      title = ""
      title = @page_data['title'] if(@page_data['title'] && @page_data['title'] != "")
      title = title + @page_data['title_suffix'].gsub(':page', @page_data['page']['page'].to_s) if(@page_data['title_suffix'] && @page_data['title_suffix'] != "")
      self.data['title'] = title
      
      # temp data
      self.data['pjey_page'] = @page_data
      self.data['pjey_activated'] = false
    end

    def page_data
      @page_data
    end

    def destination(dest)
      File.join(dest, @dir, @name)
    end

  end

  class Pjey
    
    # default config for pagination
    DEFAULTS = {
      'data_type'    => 'posts',            # what should be iterated?

      'categories'   => [],                 # filter by categories
      'tags'         => [],                 # filter by tags

      'order'        => 'title',            # do a sorting
      'per_page'     => 10,                 # entries per page

      'title_suffix' => ' - Page :page',    # how should the title of the pages should look like?
      'permalink'    => ':filename_:page'   # how does the filename should look like?
    }

    def initialize page, posts, config = {}
      @page = page
      @posts = posts
      @config = DEFAULTS.merge(config)
      # do some validations
      @config['per_page'] = @config['per_page'].to_i
      # make list if we don't have one
      @config['categories'] = make_list(@config['categories'])
      @config['tags'] = make_list(@config['tags'])
    end

    def make_list array_or_string
      unless array_or_string.kind_of?(Array)
        array_or_string = array_or_string.split(" ")
      end
      return array_or_string.collect{|x| x.strip || x }
    end

    # prepare data
    # do filtering
    # do sorting (todo)
    def data
      if(@config['data_type'] == "posts")
        return posts
      end
      return []
    end

    # return posts
    def posts
      selected = []
      @posts.docs.each do |post|
        if @config['categories'].size == 0 && @config['tags'].size == 0
          selected << post
        else
          use_post = false
          if post.data['categories'].size > 0
            if (@config['categories'] & post.data['categories']).size > 0
              use_post = true 
            end
          end
          if post.data['tags'].size > 0
            if (@config['tags'] & post.data['tags']).size > 0
              use_post = true 
            end
          end
          selected << post if use_post
        end
      end
      @data = selected
      return selected
    end

    # page permalink
    def page_permalink
      @config['permalink'].gsub(":filename", File.basename(@page.path, ".*"))+".html"
    end

    # page filename
    def page_filename page = 1
      File.basename(page_permalink.gsub(":page", page.to_s))
    end

    # return path for page
    def page_path page = 1
      page_folder = File.dirname(@page.path)
      subfolder_perma = File.dirname(page_permalink.gsub(":page", page.to_s))

      if page == 1
        if page_folder == "."
          path = File.basename(@page.path)
        else
          path = File.join(page_folder, File.basename(@page.path))
        end
      else
        page_folder = File.join(page_folder, subfolder_perma) if (subfolder_perma != ".")
        if page_folder == "."
          path = page_filename(page)
        else
          path = File.join(page_folder, page_filename(page))
        end
      end
      return path
    end

    def paginate elems = []
      selected = []
      pages = elems.each_slice(@config['per_page'])
      pages.each_with_index do |page_data, index|
        key = @config['data_type'].to_s

        page = index + 1
        
        next_page = false
        if page < pages.size
          page_num = page + 1
          next_page = {
            "page" => page_num,
            "path" => page_path(page_num)
          }
        end
        
        previous_page = false
        if page > 1
          page_num = page - 1
          previous_page = {
            "page" => page_num,
            "path" => page_path(page_num)
          }
        end

        root = {
          "path"     => page_path(1),
          "filename" => File.basename(@page.path)
        }

        page = {
          "page"            =>  page,                      # current page is int
          "total_pages"     =>  pages.size,                # total pages count
          'total'           =>  elems.size,                # total entries
          
          "root"            =>  root,                      # root page where we started

          "permalink"       =>  page_path(':page'),            # a path where you can replace :page for getting any page
          "path"            =>  page_path(page),           # will be "folder/index_1.html"
          "filename"        =>  page_filename(page),       # will be "index_1.html"
          
          "next"            => next_page,                  # minimal page data for next page
          "previous"        => previous_page               # minimal page data for previous page
        }

        selected << DEFAULTS.merge({
          "#{key}" => page_data,
          'page'   => page
        })

      end
      return selected
    end

  end

end

# make pjey accessable in templates
Jekyll::Hooks.register :pages, :pre_render do |jekyll_page, payload|
  if jekyll_page.data && jekyll_page.data['pjey']
    payload['pjey'] = jekyll_page.data['pjey_page']
  end
end