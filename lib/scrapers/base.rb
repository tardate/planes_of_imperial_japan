module Scrapers
end

class Scrapers::Base
  attr_accessor :snapshots_enabled
  attr_accessor :catalog

  BACKOFF_SECONDS = ENV.fetch('BACKOFF_SECONDS', 0.3).to_f

  def base_url
    'https://en.wikipedia.org'
  end

  def main_path
    # override
  end

  def initialize(catalog, snapshots_enabled: true)
    self.catalog = catalog
    self.snapshots_enabled = snapshots_enabled
  end

  def self.log(category, message)
    warn "[#{category}][#{Time.now}] #{message}"
  end

  def log(category, message)
    self.class.log(category, message)
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

  def append_title(plane, doc)
    plane['title'] = doc.css('.mw-page-title-main').first&.text
    plane['title'] ||= doc.css('.mw-first-heading').first&.text
  end

  def append_title_ja(plane, doc, default: nil)
    title_ja = doc.css('.mw-body-content span[title="Japanese-language text"] span').first
    plane['title_ja'] = title_ja.text if title_ja
    plane['title_ja'] ||= default if default
  end

  def append_plane_description(plane, doc)
    doc.css('.mw-body-content p').detect do |item|
      text = item.text.chomp
      unless text.empty?
        plane['description'] = text
        return
      end
    end
    nil
  end

  def append_image(plane, doc)
    image_link = doc.css('.infobox img.mw-file-element').last
    if image_link
      image_url = image_link.attr('src')
      image_url = "https:#{image_url}" if image_url[0] = '/'
      plane['image_url'] = image_url
      plane['image_local_name'] = [plane['uuid'], image_url.split('.').last.downcase].join('.')
    end
  end

  def append_variants(plane, doc, selector='h2 span#Variants')
    variants = doc.css(selector).first
    return unless variants

    plane['variants'] = []
    current_element = variants.parent.next_element
    while current_element && !%w[h2 h3].include?(current_element.name) do
      case current_element.name
      when 'dl'
        dt_nodes = current_element.children.collect { |node| node.name == 'dt' ? node : nil }.compact #css('dt')
        dd_nodes = current_element.children.collect { |node| node.name == 'dd' ? node : nil }.compact #css('dd')
        if dt_nodes.count > 0 && dt_nodes.count == dd_nodes.count
          log 'load_plane', "scanning variant element #{current_element.name}"
          dt_nodes.each_with_index do |dt, index|
            variant = {
              'name' => dt.text,
              'description' => dd_nodes[index].text
            }
            plane['variants'] << variant
          end
        else
          log 'load_plane', "ignoring variant element #{current_element.name} dt_nodes.count: #{dt_nodes.count}, dd_nodes.count: #{dd_nodes.count} current_element: #{current_element.inspect}"
        end
      when 'ul'
        log 'load_plane', "scanning variant element #{current_element.name}"
        current_element.css('li').each do |item|
          variant = {
            'name' => item.css('b').text,
            'description' => item.text
          }
          plane['variants'] << variant
        end
      else
        log 'load_plane', "ignoring variant element #{current_element.name}"
      end
      current_element = current_element.next_element
    end
  end

  def get_page(url, message: nil, local_file: nil)
    if snapshots_enabled && local_file && File.exist?(local_file)
      html = local_file
    else
      log message, "loading #{url} with a #{BACKOFF_SECONDS} second grace period delay"
      html = URI.open(URI.parse(url))
      File.write(local_file, File.read(html)) if snapshots_enabled && local_file
      sleep BACKOFF_SECONDS
    end
    result = Nokogiri::HTML(html)
    result
  end

  def snapshots_folder
    @snapshots_folder ||= begin
      result = catalog.snapshots_folder.join(self.class.name.split('::').last.downcase)
      FileUtils.mkdir_p result
      result
    end
  end

  def main_doc
    @main_doc ||= begin
      local_file = snapshots_folder.join('index.html')
      get_page(base_url + main_path, message: 'GET main page (en)', local_file: local_file)
    end
  end
end
