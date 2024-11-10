require 'spec_helper'

describe Scrapers::WikiList do
  let(:component) { described_class.new(given_catalog) }
  let(:given_catalog) { Catalog.new }

  vcr_base = 'scrapers/wiki_list/load'

  describe '#load!' do
    subject { component.load! }
    before do
      allow(component).to receive(:load_plane)
      allow(component).to receive(:log)
    end

    let(:expected_keys) do
      %w[
        name category path allied_code first_flown
        number_built services uuid url
      ]
    end

    context 'with cached snapshot' do
      before do
        allow(component).to receive(:main_doc).and_return(snapshot)
      end
      let(:snapshot) { get_html_snapshot('wiki_list.html') }

      it 'parses the index.html to catalog correctly' do
        expect { subject }.to change { component.catalog.planes.keys.count }.from(0).to(65)
      end
    end

    context 'with index.html load', vcr: { cassette_name: "#{vcr_base}/index", match_requests_on: [:path] } do
      before do
        component.snapshots_enabled = false
      end

      it 'parses the index.html to catalog correctly' do
        expect { subject }.to change { component.catalog.planes.keys.count }.from(0).to(65)
      end

      context 'for Kawanishi_N1K' do
        let(:expected_uuid) { '2ad0cafbdae52374ba8ee9486f90b0d1' }
        it 'loads details correctly' do
          expect { subject }.to change { component.catalog.planes[expected_uuid]&.keys }.from(nil).to(expected_keys)
          plane = component.catalog.planes[expected_uuid]
          expect(plane['name']).to eql('Kawanishi N1K Kyofu Navy Fighter Seaplane')
          expect(plane['url']).to eql('https://en.wikipedia.org/wiki/Kawanishi_N1K')
          expect(plane['category']).to eql('Fighters')
          expect(plane['allied_code']).to eql('Rex')
          expect(plane['first_flown']).to eql(1942)
          expect(plane['number_built']).to eql(1532)
          expect(plane['services']).to match_array(%w[IJN])
        end
      end

      context 'for Kawanishi_N1K-J' do
        let(:expected_uuid) { '8db9bedd6990b3c01e31a80e6956a452' }
        it 'loads details correctly' do
          expect { subject }.to change { component.catalog.planes[expected_uuid]&.keys }.from(nil).to(expected_keys)
          plane = component.catalog.planes[expected_uuid]
          expect(plane['name']).to eql('Kawanishi N1K1-J/N1K2-J Shiden Navy Land-Based Interceptor')
          expect(plane['url']).to eql('https://en.wikipedia.org/wiki/Kawanishi_N1K-J')
          expect(plane['category']).to eql('Fighters')
          expect(plane['allied_code']).to eql('George')
          expect(plane['first_flown']).to eql(1943)
          expect(plane['number_built']).to eql(1435)
          expect(plane['services']).to match_array(%w[IJN])
        end
      end

      context 'for Mitsubishi_Ki-46' do
        let(:expected_uuid) { '2e090e977e02b0b90915b7317b3c7d3f' }
        it 'loads details correctly' do
          expect { subject }.to change { component.catalog.planes[expected_uuid]&.keys }.from(nil).to(expected_keys)
          plane = component.catalog.planes[expected_uuid]
          expect(plane['name']).to eql('Mitsubishi Ki-46-III-Kai Army Type 100 Air Defence Fighter')
          expect(plane['url']).to eql('https://en.wikipedia.org/wiki/Mitsubishi_Ki-46')
          expect(plane['category']).to eql('Fighters')
          expect(plane['allied_code']).to eql('Dinah')
          expect(plane['first_flown']).to eql(1941)
          expect(plane['number_built']).to eql(1742)
          expect(plane['services']).to match_array(%w[IJA IJN])
        end
      end

      context 'for Yokosuka MXY-7 Ohka' do
        let(:expected_uuid) { '76889e3e340299ae29eec2edbe6245a3' }
        it 'loads details correctly' do
          expect { subject }.to change { component.catalog.planes[expected_uuid]&.keys }.from(nil).to(expected_keys)
          plane = component.catalog.planes[expected_uuid]
          expect(plane['name']).to eql('Yokosuka MXY-7 Ohka')
          expect(plane['url']).to eql('https://en.wikipedia.org/wiki/Ohka')
          expect(plane['category']).to eql('Attack aircraft')
          expect(plane['allied_code']).to eql("Baka ('Fool' in Japanese)[1]")
          expect(plane['first_flown']).to eql(1944)
          expect(plane['number_built']).to eql(852)
          expect(plane['services']).to match_array(%w[IJN])
        end
      end
    end
  end
end
