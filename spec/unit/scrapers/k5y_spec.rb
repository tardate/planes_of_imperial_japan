require 'spec_helper'

describe Scrapers::K5y do
  let(:component) { described_class.new(given_catalog) }
  let(:given_catalog) { Catalog.new }

  vcr_base = 'scrapers/k5y/load'

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
        expect(plane['uuid']).to eql('738a2e1e58fcd7bcdf28d078b4ee53cc')
        expect(plane['name']).to eql('Yokosuka K5Y')
        expect(plane['title']).to eql('Yokosuka K5Y')
        expect(plane['title_ja']).to eql('九三式中間練習機')
        expect(plane['url']).to eql('https://en.wikipedia.org/wiki/Yokosuka_K5Y')
        expect(plane['categories']).to match_array(%w[Trainers])
        expect(plane['allied_code']).to eql('Willow')
        expect(plane['first_flown']).to eql(1933)
        expect(plane['number_built']).to eql(5770)
        expect(plane['services']).to match_array(%w[IJN])
      end
    end
  end
end
