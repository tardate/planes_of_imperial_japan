class Scrapers::Ki54 < Scrapers::Base
  def main_path
    '/wiki/Tachikawa_Ki-54'
  end

  def load!
    name = main_doc.css('.mw-page-title-main').text
    plane = {
      'name' => name,
      'title' => name,
      'path' => main_path,
      'url' => base_url + main_path,
      'category' => 'Trainers',
      'allied_code' => 'Hickory',
      'first_flown' => 1941,
      'number_built' => 1368,
      'services' => %w[IJA]
    }
    plane['uuid'] = Digest::MD5.hexdigest(plane['name'])

    append_plane_description(plane, main_doc)

    image_link = main_doc.css('.infobox img.mw-file-element').last
    if image_link
      image_url = image_link.attr('src')
      image_url = "https:#{image_url}" if image_url[0] = '/'
      plane['image_url'] = image_url
      plane['image_local_name'] = [plane['uuid'], image_url.split('.').last.downcase].join('.')
    end

    catalog.planes[plane['uuid']] = plane
  end
end
