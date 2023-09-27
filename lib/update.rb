#! /usr/bin/env ruby
require 'fileutils'
require 'pathname'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'digest'

class Catalog
  attr_accessor :content

  def load
    self.content = if File.exist?(file_path)
      JSON.load file_path
    else
      FileUtils.mkdir_p File.dirname(file_path)
      {}
    end
    self
  end

  def save
    File.write(file_path, JSON.pretty_generate(content))
  end

  def export_data_table
    File.write(data_table_path, JSON.pretty_generate(planes))
  end

  def base_folder
    @base_folder ||= Pathname.new(File.dirname(__FILE__)).join('..', 'cache')
  end

  def cache_folder
    @cache_folder ||= base_folder.join('snapshots')
  end

  def file_path
    @file_path ||= base_folder.join('catalog.json')
  end

  def data_table_path
    base_folder.join('data.json')
  end

  def image_folder
    @image_folder ||= begin
      path = base_folder.join('images')
      FileUtils.mkdir_p(path) unless File.exist?(path)
      path
    end
  end

  def image_path(local_name)
    image_folder.join(local_name)
  end

  def planes
    content['planes'] ||= []
  end
end

class Scraper
  BACKOFF_SECONDS = ENV.fetch('BACKOFF_SECONDS', 0.3).to_f
  BASE_URL = 'https://en.wikipedia.org'.freeze
  INDEX_PATH = '/wiki/List_of_aircraft_of_Japan_during_World_War_II'.freeze

  def ensure_cache_complete
    index_doc
    load_planes

    save
    cache_plane_images
  end

  def catalog
    @catalog ||= Catalog.new.load
  end

  def save
    catalog.save
    catalog.export_data_table
  end

  def load_planes(refresh: false)
    return unless refresh || catalog.planes.empty?

    index_doc.css('#bodyContent h2').each do |header|
      category = header.css('.mw-headline').text
      table = header.next_element
      table.css('tbody tr').each do |row|
        cells = row.css('td')
        next unless cells.count > 0

        plane = {
          'name' => cells[0].css('a').text,
          'category' => category,
          'path' => cells[0].css('a').last.attr('href'),
          'allied_code' => cells[1].text.chomp,
          'first_flown' => as_first_flown(cells[2].text),
          'number_built' => cells[3].text.chomp.to_i,
          'services' => as_service_list(cells[4]&.text)
        }
        # plane['uuid'] = Digest::SHA1.hexdigest(plane['name'])
        plane['uuid'] = Digest::MD5.hexdigest(plane['name'])
        plane['url'] = BASE_URL + plane['path']
        load_plane plane
        catalog.planes << plane
      end
    end
  end

  def load_plane(plane)
    puts "loading #{plane['name']} .."

    local_file = catalog.cache_folder.join("#{plane['uuid']}.html")
    plane_doc = get_page(plane['url'], message: "GET #{plane['name']}", local_file: local_file)

    page_title = plane_doc.css('.mw-page-title-main').first
    plane['title'] = page_title.text if page_title

    image_link = plane_doc.css('.infobox img.mw-file-element').last
    if image_link
      image_url = image_link.attr('src')
      image_url = "https:#{image_url}" if image_url[0] = '/'
      plane['image_url'] = image_url
      plane['image_local_name'] = [plane['uuid'], image_url.split('.').last.downcase].join('.')
    end

    variants = plane_doc.css('h2 span#Variants').first
    if variants
      plane['variants'] = []
      current_element = variants.parent.next_element
      while !%w[h2 h3].include?(current_element.name) do
        case current_element.name
        when 'dl'
          dt_nodes = current_element.children.collect { |node| node.name == 'dt' ? node : nil }.compact #css('dt')
          dd_nodes = current_element.children.collect { |node| node.name == 'dd' ? node : nil }.compact #css('dd')
          if dt_nodes.count > 0 && dt_nodes.count == dd_nodes.count
            puts "scanning variant element #{current_element.name}"
            dt_nodes.each_with_index do |dt, index|
              variant = {
                'name' => dt.text,
                'description' => dd_nodes[index].text
              }
              plane['variants'] << variant
            end
          else
            puts "ignoring variant element #{current_element.name} dt_nodes.count: #{dt_nodes.count}, dd_nodes.count: #{dd_nodes.count} current_element: #{current_element.inspect}"
          end
        when 'ul'
          puts "scanning variant element #{current_element.name}"
          current_element.css('li').each do |item|
            variant = {
              'name' => item.css('b').text,
              'description' => item.text
            }
            plane['variants'] << variant
          end
        else
          puts "ignoring variant element #{current_element.name}"
        end
        current_element = current_element.next_element
      end
    end
  end

  def cache_plane_images
    catalog.planes.each do |plane|
      next unless plane['image_url']

      get_image(plane['image_local_name'], plane['image_url'])
    end
  end

  def as_first_flown(value)
    result = value.chomp.to_i
    result if result > 0
  end

  def as_service_list(value)
    result = []
    %w[IJA IJN].each do |key|
      result << key if value && value.include?(key)
    end
    result
  end

  def index_doc
    @index_doc ||= begin
      local_file = catalog.cache_folder.join('index.html')
      get_page(BASE_URL + INDEX_PATH, message: 'GET main page (en)', local_file: local_file)
    end
  end

  def get_page(url, message: nil, local_file: nil)
    if local_file && File.exist?(local_file)
      html = local_file
    else
      log message, "loading #{url} with a #{BACKOFF_SECONDS} second grace period delay"
      html = URI.open(URI.parse(url))
      File.write(local_file, File.read(html)) if local_file
      sleep BACKOFF_SECONDS
    end
    result = Nokogiri::HTML(html)
    result
  end

  def get_image(local_name, image_url)
    filename = catalog.image_path(local_name)
    log 'Load Product Image', "loading #{filename} with a #{BACKOFF_SECONDS} second grace period delay"

    unless File.exist?(filename)
      open(filename, 'wb') do |file|
        file << URI.open(URI.parse(image_url)).read
      end
      sleep BACKOFF_SECONDS
    end
  end

  def log(category, message)
    warn "[#{category}][#{Time.now}] #{message}"
  end

  def show_categories
    categories = catalog.planes.each_with_object({}) do |plane, memo|
      category = plane['category'] || ''
      memo[category] ||= 0
      memo[category] += 1
    end
    categories.keys.sort.each do |category|
      puts "#{category}: #{categories[category]} planes"
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  operation = ARGV.shift
  scraper = Scraper.new
  case operation
  when 'show_categories'
    scraper.show_categories
  when 'all'
    scraper.ensure_cache_complete
  else
    warn <<-HELP
      Usage:
        ruby #{$PROGRAM_NAME} all                      # update product metadata, product items and ensures the image cache is complete
        ruby #{$PROGRAM_NAME} show_categories          # show all categories used by current records in the database
        ruby #{$PROGRAM_NAME} (help)                   # this help

      Environment settings:
        BACKOFF_SECONDS # override the default backoff delay 0.3 seconds
    HELP
  end
end
