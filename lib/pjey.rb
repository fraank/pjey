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
            if page_data['page'] == 1
              jekyll_page.data['pjey_page'] = page_data
            else
              page_folder = File.dirname(jekyll_page.path)
              page_folder = "" if page_folder == "."
              site.pages << PjeyPage.new(site, page_folder, page_data)
            end
          end
        end
      end

    end
  end

  class PjeyPage < Page
    
    def initialize(site, dir, page_data)
      @site = site
      @dir = dir

      @page_data = page_data
      @name = page_data['permalink']

      self.ext = File.extname(@name)
      self.basename = File.basename(@name)

      self.read_yaml(@dir, page_data['root']) # <<- has to be the source file
      
      title = ""
      title = @page_data['title'] if(@page_data['title'] && @page_data['title'] != "")
      title = title + @page_data['title_suffix'].gsub(':page', @page_data['page'].to_s) if(@page_data['title_suffix'] && @page_data['title_suffix'] != "")
      self.data['title'] = title
      
      # temp data
      self.data['pjey_page'] = @page_data
      self.data['pjey_activated'] = false
    end

    def page_data
      @page_data
    end

    def destination(dest)
      File.join(dest, @dir, @page_data['permalink'])
    end

  end

  class Pjey
    
    DEFAULTS = {
      'data_type'    => 'posts',

      'categories'   => [],
      'tags'         => [],

      'order'        => 'title',

      'per_page'     => 10,                 # entries per page
      'total_pages'  => 0,                  # total pages count
      'total'        => 0,                  # total entries
      'page'         => 1,                  # current page
      'root'         => '',                 # root page where we started

      'title_suffix' => ' - Page :page',
      'permalink'    => ':filename_:page'
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

    def paginate elems = []
      selected = []
      pages = elems.each_slice(@config['per_page'])
      pages.each_with_index do |page_data, index|
        key = @config['data_type'].to_s

        page = index + 1
        
        next_page = {}
        next_page = {
          "page" => page + 1,
        } if page < pages.size
        
        previous_page = {}
        previous_page = {
          "page" => page - 1,
        } if page > 1

        permalink = @config['permalink'].gsub(":filename", File.basename(@page.path, ".*")).gsub(":page", page.to_s)+".html"

        

        page = {
          "root" => File.basename(@page.path),
          "permalink" => permalink,
          "page" => page,
          "total" => elems.size,
          "total_pages" => pages.size,
          "#{key}" => page_data,
          "next" => next_page,
          "previous" => previous_page
        }
        selected << DEFAULTS.merge(page)

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