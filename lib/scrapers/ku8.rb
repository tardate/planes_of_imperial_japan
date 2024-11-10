class Scrapers::Ku8 < Scrapers::Base
  def main_path
    '/wiki/Kokusai_Ku-8'
  end

  def load!
    plane = {
      'path' => main_path,
      'url' => base_url + main_path,
      'categories' => %w[Transports],
      'allied_code' => 'Gander',
      'first_flown' => 1943,
      'number_built' => 700,
      'services' => %w[IJA]
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
