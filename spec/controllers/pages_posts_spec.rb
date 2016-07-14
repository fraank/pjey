# encoding: utf-8
require 'rexml/document'
require_relative '../spec_helper'

describe 'Pages Posts', :type => :controller do

  before do
    @test = JekyllUnitTest.new

    @site = Site.new(@test.site_configuration)
    @site.read
    @site.generate
    @site.render

    # which layout do we wanna use?
    @layouts = {
      "default" => Layout.new(@site, @test.source_dir("_layouts"), "default.html")
    }
  end

  describe 'default filters' do

    it 'use without filter' do
      @site.pages.each do |page|
        if page.path == "index.html"
          page.render(@layouts, @site.site_payload)
          doc = REXML::Document.new(page.content)
          
          count = 0
          doc.elements.each('posts/post') do |post|
            count = count + 1
          end
          expect(count).to eq 10
        end
      end
    end

    it 'check category filter' do
      @site.pages.each do |page|
        if page.path == "category1.html"
          page.render(@layouts, @site.site_payload)
          doc = REXML::Document.new(page.content)
          
          count = 0
          doc.elements.each('posts/post') do |post|
            count = count + 1
            post_categories = post.elements["categories"].text.split(",")
            expect(post_categories).to include "category1"
          end
          expect(count).to eq 7
        end
      end
    end

    it 'check tag filter' do
      @site.pages.each do |page|
        if page.path == "tag1.html"
          page.render(@layouts, @site.site_payload)
          doc = REXML::Document.new(page.content)
          
          count = 0
          doc.elements.each('posts/post') do |post|
            count = count + 1
            post_tags = post.elements["tags"].text.split(",")
            expect(post_tags).to include "tag1"
          end
          expect(count).to eq 2
        end
      end
    end

  end

  describe 'default filters with pagination' do

    it 'check category filter' do
      per_page = 2
      
      # render only one page
      @site.pages.each do |page|
        if page.path == "category1_p2.html"
          page.render(@layouts, @site.site_payload)
          doc = REXML::Document.new(page.content)

          count = 0
          doc.elements.each('result/posts/post') do |post|
            count = count + 1
            post_categories = post.elements["categories"].text.split(",")
            expect(post_categories).to include "category1"
          end
          expect(count).to eq per_page
          
          page_info = doc.elements['result/page']
          page = page_info.elements['num'].text.to_i
          total = page_info.elements['total'].text.to_i
          totalpages = page_info.elements['totalpages'].text.to_i

          expect(page).to eq 1
          expect(total).to eq 7
          expect(totalpages).to eq 4
        end
      end
      
      # check second page
      page2_exists = false
      
      @site.pages.each do |page|
        if page.path == "category1_p2_2.html"
          page2_exists = true

          page.render(@layouts, @site.site_payload)
          doc = REXML::Document.new(page.content)
          page_info = doc.elements['result/page']
          page = page_info.elements['num'].text.to_i
          expect(page).to eq 2
        end
      end

      expect(page2_exists).to eq true
    end

  end

  describe 'default filters with pagination in subfolder' do

    it 'check category filter' do
      per_page = 2
      
      # render only one page
      @site.pages.each do |page|
        if page.path == "subfolder/index.html"
          page.render(@layouts, @site.site_payload)
          doc = REXML::Document.new(page.content)

          count = 0
          doc.elements.each('result/posts/post') do |post|
            count = count + 1
            post_categories = post.elements["categories"].text.split(",")
            expect(post_categories).to include "category1"
          end
          expect(count).to eq per_page
          
          page_info = doc.elements['result/page']
          page = page_info.elements['num'].text.to_i
          total = page_info.elements['total'].text.to_i
          totalpages = page_info.elements['totalpages'].text.to_i

          expect(page).to eq 1
          expect(total).to eq 7
          expect(totalpages).to eq 4
        end
      end
      
      # check second page
      page2_exists = false
      @site.pages.each do |page|
        if page.path == "subfolder/index_2.html"
          page2_exists = true

          page.render(@layouts, @site.site_payload)
          doc = REXML::Document.new(page.content)
          page_info = doc.elements['result/page']
          page = page_info.elements['num'].text.to_i
          expect(page).to eq 2
        end
      end

      expect(page2_exists).to eq true
    end

  end

end