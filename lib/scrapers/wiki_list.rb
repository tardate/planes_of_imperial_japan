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

        name = cells[0].css('a').text
        plane = {
          'uuid' => Digest::MD5.hexdigest(name),
          'name' => name
        }
        next if [
          '3d7668c49dd53fc000fae43fb96fc29c', # ignore Mitsubishi Hinazuru-type Passenger Transport entry
          '01b6d07320c3dd305e3f43c8cef9edd8', # duplicate Tachikawa Ki-94 entry
          '754bd2a4d1ec2c57c7f513c56c2ccd42', # duplicate Kawasaki Ki-10 entry
          '8c7fd7e579132b387970f64da6f8a742', # duplicate Mitsubishi Ki-46 entry
          'd946df437755f9151345f9f03efd9c49' # duplicate Nakajima J1N entry
        ].include? plane['uuid']

        path = cells[0].css('a').last.attr('href')
        plane.merge!(
          'path' => path,
          'url' => base_url + path,
          'categories' => Array(category),
          'allied_code' => cells[1].text.chomp,
          'first_flown' => as_first_flown(cells[2].text),
          'number_built' => cells[3].text.chomp.to_i,
          'services' => as_service_list(cells[4]&.text)
        )

        case plane['uuid']
        when '09fbf7e8284a52ac2daef4c61f404048' # customise Kawasaki Ki-10 entry
          plane['categories'] = [category, 'Reconnaissance aircraft'].sort
        when '2e090e977e02b0b90915b7317b3c7d3f' # customise Mitsubishi Ki-46 entry
          plane['categories'] = [category, 'Reconnaissance aircraft'].sort
        when '439faabb9cbb57ad9a597ee4aea90f03' # customise Nakajima J1N entry
          plane['first_flown'] = 1941
          plane['categories'] = [category, 'Fighters'].sort
        when '5afc98ea6e5a36f6fc83acd74baee3f2' # customise Tachikawa Ki-94 entry
          plane['name'] = 'Tachikawa Ki-94'
          plane['number_built'] = 2
          plane['services'] = %w[IJA]
        end

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
