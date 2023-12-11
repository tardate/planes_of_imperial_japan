class Scrapers::WikiList < Scrapers::Base
  def main_path
    '/wiki/List_of_aircraft_of_Japan_during_World_War_II'
  end

  def load!
    main_doc.css('#bodyContent h2').each do |header|
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
        plane['url'] = base_url + plane['path']
        load_plane plane
        catalog.planes[plane['uuid']] = plane
      end
    end
  end

  def load_plane(plane)
    log 'load_plane', "loading #{plane['name']} .."
    plane_doc = load_plane_doc plane

    plane['title'] = plane_doc.css('.mw-page-title-main').first&.text
    plane['title'] ||= plane_doc.css('.mw-first-heading').first&.text

    title_ja = plane_doc.css('.mw-body-content span[title="Japanese-language text"] span').first
    plane['title_ja'] = title_ja.text if title_ja

    image_link = plane_doc.css('.infobox img.mw-file-element').last
    if image_link
      image_url = image_link.attr('src')
      image_url = "https:#{image_url}" if image_url[0] = '/'
      plane['image_url'] = image_url
      plane['image_local_name'] = [plane['uuid'], image_url.split('.').last.downcase].join('.')
    end

    append_plane_description(plane, plane_doc)

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

  def load_plane_doc(plane)
    local_file = snapshots_folder.join("#{plane['uuid']}.html")
    get_page(plane['url'], message: "GET #{plane['name']}", local_file: local_file)
  end
end
