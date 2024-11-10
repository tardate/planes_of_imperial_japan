require 'spec_helper'

describe Scrapers::Ki2 do
  let(:component) { described_class.new(given_catalog) }
  let(:given_catalog) { Catalog.new }

  vcr_base = 'scrapers/ki2/load'

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
        expect(plane['uuid']).to eql('55f64f45bf00ef0b8ce665ca468ea94d')
        expect(plane['name']).to eql('Mitsubishi Ki-2')
        expect(plane['title']).to eql('Mitsubishi Ki-2')
        expect(plane['title_ja']).to eql('九三式双軽爆撃機')
        expect(plane['url']).to eql('https://en.wikipedia.org/wiki/Mitsubishi_Ki-2')
        expect(plane['categories']).to match_array(%w[Bombers])
        expect(plane['allied_code']).to eql('Louise')
        expect(plane['first_flown']).to eql(1933)
        expect(plane['number_built']).to eql(187)
        expect(plane['services']).to match_array(%w[IJA])
      end
    end
  end
end
