class Builder
  def run!
    operation = ARGV.shift
    case operation
    when 'show_categories'
      show_categories
    when 'all'
      ensure_cache_complete refresh: true
    when 'cache'
      ensure_cache_complete
    else
      warn <<-HELP
        Usage:
          bin/update.rb all                      # reload plane data and ensures the image cache is complete
          bin/update.rb cache                    # ensures the data and image cache is complete
          bin/update.rb show_categories          # show all categories used by current records in the database
          bin/update.rb (help)                   # this help

        Environment settings:
          BACKOFF_SECONDS # override the default backoff delay 0.3 seconds

      HELP
    end
  end

  def ensure_cache_complete(refresh: false)
    if refresh || catalog.planes.empty?
      catalog.planes = {}
      all_scrapers.each do |scraper|
        scraper.new(catalog).load!
      end
    end
    save
    cache_plane_images
  end

  def all_scrapers
    [
      Scrapers::WikiList,
      Scrapers::E2n,
      Scrapers::E10a,
      Scrapers::E11a,
      Scrapers::G5n,
      Scrapers::H3k,
      Scrapers::H5y,
      Scrapers::K10w,
      Scrapers::K3m,
      Scrapers::Ki2,
      Scrapers::Ki54,
      Scrapers::Ki55,
      Scrapers::Ki70,
      Scrapers::Ki74,
      Scrapers::Ki76,
      Scrapers::Ki9,
      Scrapers::Ku7,
      Scrapers::Ku8,
      Scrapers::Q1w
    ]
  end

  def catalog
    @catalog ||= Catalog.new.load
  end

  def catalog=(value)
    @catalog = value
  end

  def save
    catalog.save
    catalog.export_data_table
  end

  def cache_plane_images
    catalog.planes.values.each do |plane|
      next unless plane['image_url']

      get_image(plane['image_local_name'], plane['image_url'])
    end
  end

  def get_image(local_name, image_url)
    filename = catalog.image_path(local_name)
    Scrapers::Base.log 'Load Product Image', "loading #{filename} with a #{Scrapers::Base::BACKOFF_SECONDS} second grace period delay"

    unless File.exist?(filename)
      open(filename, 'wb') do |file|
        file << URI.open(URI.parse(image_url)).read
      end
      sleep Scrapers::Base::BACKOFF_SECONDS
    end
  end

  def show_categories
    categories = catalog.planes.values.each_with_object({}) do |plane, memo|
      category = plane['category'] || ''
      memo[category] ||= 0
      memo[category] += 1
    end
    categories.keys.sort.each do |category|
      puts "#{category}: #{categories[category]} planes"
    end
  end
end
