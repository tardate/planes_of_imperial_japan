require 'spec_helper'

describe Scrapers::H3k do
  let(:component) { described_class.new(given_catalog) }
  let(:given_catalog) { Catalog.new }

  vcr_base = 'scrapers/H3k/load'

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
        expect(plane['uuid']).to eql('ddde4e5a488a776c3e285a0af739ff2e')
        expect(plane['name']).to eql('Kawanishi H3K')
        expect(plane['title']).to eql('Kawanishi H3K')
        expect(plane['title_ja']).to eql('九〇式二号飛行艇')
        expect(plane['url']).to eql('https://en.wikipedia.org/wiki/Kawanishi_H3K')
        expect(plane['categories']).to match_array(['Reconnaissance aircraft'])
        expect(plane['allied_code']).to eql('Belle')
        expect(plane['first_flown']).to eql(1930)
        expect(plane['number_built']).to eql(5)
        expect(plane['services']).to match_array(%w[IJN])
      end
    end
  end
end
