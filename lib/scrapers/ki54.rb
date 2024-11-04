class Scrapers::Ki54 < Scrapers::Base
  def main_path
    '/wiki/Tachikawa_Ki-54'
  end

  def load!
    plane = {
      'path' => main_path,
      'url' => base_url + main_path,
      'category' => 'Trainers',
      'allied_code' => 'Hickory',
      'first_flown' => 1941,
      'number_built' => 1368,
      'services' => %w[IJA]
    }
    plane['name'] = append_title(plane, main_doc)
    plane['uuid'] = Digest::MD5.hexdigest(plane['name'])

    append_plane_description(plane, main_doc)
    append_image(plane, main_doc)

    catalog.planes[plane['uuid']] = plane
  end
end
