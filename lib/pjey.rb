# encoding: utf-8
require "jekyll"
require "pjey/version"

require "pjey/page_generator"
require "pjey/page"

module Jekyll

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