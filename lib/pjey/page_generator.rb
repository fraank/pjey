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
end