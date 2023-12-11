class Scrapers::Ku7 < Scrapers::Base
  def main_path
    '/wiki/Kokusai_Ku-7'
  end

  def load!
    name = main_doc.css('.mw-page-title-main').text
    plane = {
      'name' => name,
      'title' => name,
      'path' => main_path,
      'url' => base_url + main_path,
      'category' => 'Experimental aircraft',
      'allied_code' => 'Buzzard',
      'first_flown' => 1942,
      'number_built' => 2,
      'services' => %w[IJA]
    }
    plane['uuid'] = Digest::MD5.hexdigest(plane['name'])

    append_title_ja(plane, main_doc, default: '真鶴')
    append_plane_description(plane, main_doc)
    append_image(plane, main_doc)

    catalog.planes[plane['uuid']] = plane
  end

end
