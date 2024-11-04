class Scrapers::Ki2 < Scrapers::Base
  def main_path
    '/wiki/Mitsubishi_Ki-2'
  end

  def load!
    plane = {
      'path' => main_path,
      'url' => base_url + main_path,
      'category' => 'Bombers',
      'allied_code' => 'Louise',
      'first_flown' => 1933,
      'number_built' => 187,
      'services' => %w[IJA]
    }
    plane['name'] = append_title(plane, main_doc)
    plane['uuid'] = Digest::MD5.hexdigest(plane['name'])

    append_title_ja(plane, main_doc, default: '九三式双軽爆撃機')
    append_plane_description(plane, main_doc)
    append_image(plane, main_doc)
    append_variants(plane, main_doc)

    catalog.planes[plane['uuid']] = plane
  end

end
