require 'spec_helper'

describe Scrapers::E2n do
  let(:component) { described_class.new(given_catalog) }
  let(:given_catalog) { Catalog.new }

  vcr_base = 'scrapers/e2n/load'

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

    context 'with cached snapshot' do
      before do
        allow(component).to receive(:main_doc).and_return(snapshot)
      end
      let(:snapshot) { get_html_snapshot('e2n.html') }

      it 'parses the imain page to catalog correctly' do
        expect { subject }.to change { component.catalog.planes.keys.count }.from(0).to(1)
      end
    end

    context 'with index.html load', vcr: { cassette_name: "#{vcr_base}/index", match_requests_on: [:path] } do
      before do
        component.snapshots_enabled = false
      end

      it 'parses the index.html to catalog correctly' do
        expect { subject }.to change { component.catalog.planes.keys.count }.from(0).to(1)
        plane = component.catalog.planes.values.first
        expect(plane['uuid']).to eql('df900f7276252bc52bd2c0c6bedfcda3')
        expect(plane['name']).to eql('Nakajima E2N')
        expect(plane['title']).to eql('Nakajima E2N')
        expect(plane['title_ja']).to eql('一五式水上偵察機')
        expect(plane['url']).to eql('https://en.wikipedia.org/wiki/Nakajima_E2N')
        expect(plane['categories']).to match_array(['Reconnaissance aircraft'])
        expect(plane['allied_code']).to eql('Bob')
        expect(plane['first_flown']).to eql(1927)
        expect(plane['number_built']).to eql(80)
        expect(plane['services']).to match_array(%w[IJN])
      end
    end
  end
end
