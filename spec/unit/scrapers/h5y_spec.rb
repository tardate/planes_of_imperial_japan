require 'spec_helper'

describe Scrapers::H5y do
  let(:component) { described_class.new(given_catalog) }
  let(:given_catalog) { Catalog.new }

  vcr_base = 'scrapers/h5y/load'

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
        expect(plane['uuid']).to eql('4d67529969bc1c632374afc790a06140')
        expect(plane['name']).to eql('Yokosuka H5Y')
        expect(plane['title']).to eql('Yokosuka H5Y')
        expect(plane['title_ja']).to eql('九九式飛行艇')
        expect(plane['url']).to eql('https://en.wikipedia.org/wiki/Yokosuka_H5Y')
        expect(plane['category']).to eql('Reconnaissance aircraft')
        expect(plane['allied_code']).to eql('Cherry')
        expect(plane['first_flown']).to eql(1936)
        expect(plane['number_built']).to eql(20)
        expect(plane['services']).to match_array(%w[IJN])
      end
    end
  end
end
