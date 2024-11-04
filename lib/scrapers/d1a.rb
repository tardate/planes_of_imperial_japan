class Scrapers::D1a < Scrapers::Base
  def main_path
    '/wiki/Aichi_D1A'
  end

  def load!
    plane = {
      'path' => main_path,
      'url' => base_url + main_path,
      'category' => 'Bombers',
      'allied_code' => 'Susie',
      'first_flown' => 1934,
      'number_built' => 590,
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
