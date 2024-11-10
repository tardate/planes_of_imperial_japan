class Scrapers::H3k < Scrapers::Base
  def main_path
    '/wiki/Kawanishi_H3K'
  end

  def load!
    plane = {
      'path' => main_path,
      'url' => base_url + main_path,
      'categories' => ['Reconnaissance aircraft'],
      'allied_code' => 'Belle',
      'first_flown' => 1930,
      'number_built' => 5,
      'services' => %w[IJN]
    }
    plane['name'] = append_title(plane, main_doc)
    plane['uuid'] = Digest::MD5.hexdigest(plane['name'])

    append_title_ja(plane, main_doc, default: '九〇式二号飛行艇')
    append_plane_description(plane, main_doc)
    append_image(plane, main_doc)
    append_variants(plane, main_doc)

    catalog.planes[plane['uuid']] = plane
  end

end
