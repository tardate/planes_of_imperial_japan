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
    append_title(plane, plane_doc)
    append_title_ja(plane, plane_doc)
    append_image(plane, plane_doc)
    append_plane_description(plane, plane_doc)
    append_variants(plane, plane_doc)
  end

  def load_plane_doc(plane)
    local_file = snapshots_folder.join("#{plane['uuid']}.html")
    get_page(plane['url'], message: "GET #{plane['name']}", local_file: local_file)
  end
end
