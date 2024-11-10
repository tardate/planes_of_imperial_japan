require 'spec_helper'

describe Scrapers::Ku8 do
  let(:component) { described_class.new(given_catalog) }
  let(:given_catalog) { Catalog.new }

  vcr_base = 'scrapers/Ku8/load'

  describe '#load!' do
    subject { component.load! }
    before do
      allow(component).to receive(:load_plane)
      allow(component).to receive(:log)
    end

    let(:expected_keys) do
      %w[
        name title description category path allied_code first_flown
        number_built services uuid url
        image_url image_local_name
      ]
    end

    context 'with index.html load', vcr: { cassette_name: "#{vcr_base}/index", match_requests_on: [:path] } do
      before do
        component.snapshots_enabled = false
      end

      it 'parses the index.html to catalog correctly' do
        expect { subject }.to change { component.catalog.planes.keys.count }.from(0).to(1)
        plane = component.catalog.planes.values.first
        expect(plane['uuid']).to eql('09ca41f346c5f72e5533a84ca2306556')
        expect(plane['name']).to eql('Kokusai Ku-8')
        expect(plane['title']).to eql('Kokusai Ku-8')
        expect(plane['title_ja']).to eql('国際 ク8 四式特殊輸送機')
        expect(plane['url']).to eql('https://en.wikipedia.org/wiki/Kokusai_Ku-8')
        expect(plane['categories']).to match_array(%w[Transports])
        expect(plane['allied_code']).to eql('Gander')
        expect(plane['first_flown']).to eql(1943)
        expect(plane['number_built']).to eql(700)
        expect(plane['services']).to match_array(%w[IJA])
      end
    end
  end
end
