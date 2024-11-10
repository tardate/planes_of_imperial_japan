require 'spec_helper'

describe Scrapers::Ki55 do
  let(:component) { described_class.new(given_catalog) }
  let(:given_catalog) { Catalog.new }

  vcr_base = 'scrapers/ki55/load'

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
        expect(plane['uuid']).to eql('df7ac11604c0afb10f707778555491eb')
        expect(plane['name']).to eql('Tachikawa Ki-55')
        expect(plane['title']).to eql('Tachikawa Ki-55')
        expect(plane['title_ja']).to be_nil
        expect(plane['url']).to eql('https://en.wikipedia.org/wiki/Tachikawa_Ki-55')
        expect(plane['categories']).to match_array(%w[Trainers])
        expect(plane['allied_code']).to eql('Ida')
        expect(plane['first_flown']).to eql(1939)
        expect(plane['number_built']).to eql(1389)
        expect(plane['services']).to match_array(%w[IJA])
      end
    end
  end
end
