class Scrapers::Q1w < Scrapers::Base
  def main_path
    '/wiki/Kyushu_Q1W'
  end

  def load!
    plane = {
      'path' => main_path,
      'url' => base_url + main_path,
      'categories' => %w[Bombers],
      'allied_code' => 'Lorna',
      'first_flown' => 1943,
      'number_built' => 153,
      'services' => %w[IJN]
    }
    plane['name'] = append_title(plane, main_doc)
    plane['uuid'] = Digest::MD5.hexdigest(plane['name'])

    append_title_ja(plane, main_doc, default: '東海')
    append_plane_description(plane, main_doc)
    append_image(plane, main_doc)
    append_variants(plane, main_doc)

    catalog.planes[plane['uuid']] = plane
  end

end
