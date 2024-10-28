class Scrapers::E2n < Scrapers::Base
  def main_path
    '/wiki/Nakajima_E2N'
  end

  def load!
    name = main_doc.css('.mw-page-title-main').text
    plane = {
      'name' => name,
      'title' => name,
      'title_ja' => '一五式水上偵察機',
      'path' => main_path,
      'url' => base_url + main_path,
      'category' => 'Reconnaissance aircraft',
      'allied_code' => nil,
      'first_flown' => 1927,
      'number_built' => 80,
      'services' => %w[IJN]
    }
    plane['uuid'] = Digest::MD5.hexdigest(plane['name'])

    # append_plane_description(plane, main_doc)
    append_image(plane, main_doc)
    plane['description'] = "The Nakajima E2N was a Japanese reconnaissance seaplane of the 1920s. It was a two-seat, single-engine biplane with a central float and underwing stabilizing floats. The E2N served with the Navy as the Nakajima Navy Type 15 Reconnaissance Floatplane (一五式水上偵察機) from 1927 to 1936."
    plane['variants'] = [
      {
        "name": "E2N1 (Type 15-1 Reconnaissance Seaplane)",
        "description": "Short-range reconnaissance aircraft."
      },
      {
        "name": "E2N2 (Type 15-2 Reconnaissance Seaplane)",
        "description": "Trainer version with dual controls."
      }
    ]

    catalog.planes[plane['uuid']] = plane
  end
end
