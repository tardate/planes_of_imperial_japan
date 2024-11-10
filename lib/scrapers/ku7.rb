class Scrapers::Ku7 < Scrapers::Base
  def main_path
    '/wiki/Kokusai_Ku-7'
  end

  def load!
    plane = {
      'path' => main_path,
      'url' => base_url + main_path,
      'categories' => ['Experimental aircraft'],
      'allied_code' => 'Buzzard',
      'first_flown' => 1942,
      'number_built' => 2,
      'services' => %w[IJA]
    }
    plane['name'] = append_title(plane, main_doc)
    plane['uuid'] = Digest::MD5.hexdigest(plane['name'])

    append_title_ja(plane, main_doc, default: '真鶴')
    append_plane_description(plane, main_doc)
    append_image(plane, main_doc)

    catalog.planes[plane['uuid']] = plane
  end

end
