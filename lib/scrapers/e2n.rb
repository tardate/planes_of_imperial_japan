class Scrapers::E2n < Scrapers::Base
  def main_path
    '/wiki/Nakajima_E2N'
  end

  def load!
    name = main_doc.css('.mw-page-title-main').text
    plane = {
      'name' => name,
      'title' => name,
      'path' => main_path,
      'url' => base_url + main_path,
      'category' => 'Reconnaissance aircraft',
      'allied_code' => nil,
      'first_flown' => 1927,
      'number_built' => 80,
      'services' => %w[IJN]
    }
    plane['uuid'] = Digest::MD5.hexdigest(plane['name'])

    append_plane_description(plane, main_doc)
    append_image(plane, main_doc)

    catalog.planes[plane['uuid']] = plane
  end
end
