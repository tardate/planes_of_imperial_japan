class Scrapers::Ki76 < Scrapers::Base
  def main_path
    '/wiki/Kokusai_Ki-76'
  end

  def load!
    plane = {
      'path' => main_path,
      'url' => base_url + main_path,
      'category' => 'Reconnaissance aircraft',
      'allied_code' => 'Stella',
      'first_flown' => 1941,
      'number_built' => 937,
      'services' => %w[IJA]
    }
    plane['name'] = append_title(plane, main_doc)
    plane['uuid'] = Digest::MD5.hexdigest(plane['name'])

    append_title_ja(plane, main_doc, default: '三式指揮連絡機')
    append_plane_description(plane, main_doc)
    append_image(plane, main_doc)
    append_variants(plane, main_doc)

    catalog.planes[plane['uuid']] = plane
  end

end
