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

  def append_plane_description(plane, plane_doc)
    plane_doc.css('.mw-body-content p').detect do |item|
      text = item.text.chomp
      unless text.empty?
        plane['description'] = text
        return
      end
    end
    nil
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
