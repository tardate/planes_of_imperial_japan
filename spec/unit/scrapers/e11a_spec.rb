require 'spec_helper'

describe Scrapers::E11a do
  let(:component) { described_class.new(given_catalog) }
  let(:given_catalog) { Catalog.new }

  vcr_base = 'scrapers/e11a/load'

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
        expect(plane['uuid']).to eql('316880560c7f8b18319f48c2447b3556')
        expect(plane['name']).to eql('Aichi E11A')
        expect(plane['title']).to eql('Aichi E11A')
        expect(plane['title_ja']).to eql('九八夜偵')
        expect(plane['url']).to eql('https://en.wikipedia.org/wiki/Aichi_E11A')
        expect(plane['category']).to eql('Reconnaissance aircraft')
        expect(plane['allied_code']).to eql('Laura')
        expect(plane['first_flown']).to eql(1937)
        expect(plane['number_built']).to eql(17)
        expect(plane['services']).to match_array(%w[IJA])
      end
    end
  end
end
