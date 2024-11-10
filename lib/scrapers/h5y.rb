class Scrapers::H5y < Scrapers::Base
  def main_path
    '/wiki/Yokosuka_H5Y'
  end

  def load!
    plane = {
      'path' => main_path,
      'url' => base_url + main_path,
      'categories' => ['Reconnaissance aircraft'],
      'allied_code' => 'Cherry',
      'first_flown' => 1936,
      'number_built' => 20,
      'services' => %w[IJN]
    }
    plane['name'] = append_title(plane, main_doc)
    plane['uuid'] = Digest::MD5.hexdigest(plane['name'])

    append_title_ja(plane, main_doc, default: '九九式飛行艇')
    append_plane_description(plane, main_doc)
    append_image(plane, main_doc)
    append_variants(plane, main_doc)

    catalog.planes[plane['uuid']] = plane
  end

end
