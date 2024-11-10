class Scrapers::E10a < Scrapers::Base
  def main_path
    '/wiki/Aichi_E10A'
  end

  def load!
    plane = {
      'path' => main_path,
      'url' => base_url + main_path,
      'categories' => ['Reconnaissance aircraft'],
      'allied_code' => 'Hank',
      'first_flown' => 1934,
      'number_built' => 15,
      'services' => %w[IJN]
    }
    plane['name'] = append_title(plane, main_doc)
    plane['uuid'] = Digest::MD5.hexdigest(plane['name'])

    append_title_ja(plane, main_doc)
    append_plane_description(plane, main_doc)
    append_image(plane, main_doc)
    append_variants(plane, main_doc)

    catalog.planes[plane['uuid']] = plane
  end

end
