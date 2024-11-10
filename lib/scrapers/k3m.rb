class Scrapers::K3m < Scrapers::Base
  def main_path
    '/wiki/Mitsubishi_K3M'
  end

  def load!
    plane = {
      'path' => main_path,
      'url' => base_url + main_path,
      'categories' => %w[Trainers],
      'allied_code' => 'Pine',
      'first_flown' => 1930,
      'number_built' => 625,
      'services' => %w[IJN]
    }
    plane['name'] = append_title(plane, main_doc)
    plane['uuid'] = Digest::MD5.hexdigest(plane['name'])

    append_title_ja(plane, main_doc, default: '九〇式機上作業練習機')
    append_plane_description(plane, main_doc)
    append_image(plane, main_doc)
    append_variants(plane, main_doc)

    catalog.planes[plane['uuid']] = plane
  end

end
