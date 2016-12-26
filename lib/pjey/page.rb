module Jekyll

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
end