require 'spec_helper'

describe Scrapers::K3m do
  let(:component) { described_class.new(given_catalog) }
  let(:given_catalog) { Catalog.new }

  vcr_base = 'scrapers/k3m/load'

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
        expect(plane['uuid']).to eql('8afb0ea1f873c83ff9883716619646fa')
        expect(plane['name']).to eql('Mitsubishi K3M')
        expect(plane['title']).to eql('Mitsubishi K3M')
        expect(plane['title_ja']).to eql('九〇式機上作業練習機')
        expect(plane['url']).to eql('https://en.wikipedia.org/wiki/Mitsubishi_K3M')
        expect(plane['category']).to eql('Trainers')
        expect(plane['allied_code']).to eql('Pine')
        expect(plane['first_flown']).to eql(1930)
        expect(plane['number_built']).to eql(625)
        expect(plane['services']).to match_array(%w[IJN])
      end
    end
  end
end
