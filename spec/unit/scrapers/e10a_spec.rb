require 'spec_helper'

describe Scrapers::E10a do
  let(:component) { described_class.new(given_catalog) }
  let(:given_catalog) { Catalog.new }

  vcr_base = 'scrapers/e10a/load'

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
        expect(plane['uuid']).to eql('f3d004494d37558684d5d84a54bc5ece')
        expect(plane['name']).to eql('Aichi E10A')
        expect(plane['title']).to eql('Aichi E10A')
        expect(plane['title_ja']).to be_nil
        expect(plane['url']).to eql('https://en.wikipedia.org/wiki/Aichi_E10A')
        expect(plane['categories']).to match_array(['Reconnaissance aircraft'])
        expect(plane['allied_code']).to eql('Hank')
        expect(plane['first_flown']).to eql(1934)
        expect(plane['number_built']).to eql(15)
        expect(plane['services']).to match_array(%w[IJN])
      end
    end
  end
end
