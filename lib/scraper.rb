class Scraper
  BACKOFF_SECONDS = ENV.fetch('BACKOFF_SECONDS', 0.3).to_f
  BASE_URL = 'https://en.wikipedia.org'.freeze
  INDEX_PATH = '/wiki/List_of_aircraft_of_Japan_during_World_War_II'.freeze

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
    load_planes refresh: refresh
    save
    cache_plane_images
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

  def load_planes(refresh: false)
    return unless refresh || catalog.planes.empty?

    catalog.planes = {}
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
        plane['uuid'] = Digest::MD5.hexdigest(plane['name'])
        plane['url'] = BASE_URL + plane['path']
        load_plane plane
        catalog.planes[plane['uuid']] = plane
      end
    end
  end

  def append_plane_description(plane, plane_doc)
    paras =  plane_doc.css('.mw-body-content p').map do |para|
      content = para.text.chomp
      content unless content.empty?
    end
    paras.compact!

    plane['description'] = paras.first if paras.size > 0
  end

  def load_plane(plane)
    log 'load_plane', "loading #{plane['name']} .."
    plane_doc = load_plane_doc plane

    page_title = plane_doc.css('.mw-page-title-main').first
    plane['title'] = page_title.text if page_title

    image_link = plane_doc.css('.infobox img.mw-file-element').last
    if image_link
      image_url = image_link.attr('src')
      image_url = "https:#{image_url}" if image_url[0] = '/'
      plane['image_url'] = image_url
      plane['image_local_name'] = [plane['uuid'], image_url.split('.').last.downcase].join('.')
    end

    append_plane_description(plane, plane_doc)

    title_ja = plane_doc.css('.mw-body-content span[title="Japanese-language text"] span').first
    plane['title_ja'] = title_ja.text if title_ja

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
  end

  def cache_plane_images
    catalog.planes.values.each do |plane|
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
      local_file = catalog.snapshots_folder.join('index.html')
      get_page(BASE_URL + INDEX_PATH, message: 'GET main page (en)', local_file: local_file)
    end
  end

  def load_plane_doc(plane)
    local_file = catalog.snapshots_folder.join("#{plane['uuid']}.html")
    get_page(plane['url'], message: "GET #{plane['name']}", local_file: local_file)
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
