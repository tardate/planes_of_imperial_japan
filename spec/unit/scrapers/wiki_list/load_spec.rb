require 'spec_helper'

describe Scrapers::WikiList do
  let(:component) { described_class.new(given_catalog) }
  let(:given_catalog) { Catalog.new }

  vcr_base = 'scrapers/wiki_list/load'

  let(:expected_entries) { 60 }

  describe '#load!' do
    subject { component.load! }
    before do
      allow(component).to receive(:load_plane)
      allow(component).to receive(:log)
    end

    let(:expected_keys) do
      %w[
        uuid name path url
        categories allied_code
        first_flown number_built services
      ]
    end

    context 'with cached snapshot' do
      before do
        allow(component).to receive(:main_doc).and_return(snapshot)
      end
      let(:snapshot) { get_html_snapshot('wiki_list.html') }

      it 'parses the index.html to catalog correctly' do
        expect { subject }.to change { component.catalog.planes.keys.count }.from(0).to(expected_entries)
      end
    end

    context 'with index.html load', vcr: { cassette_name: "#{vcr_base}/index", match_requests_on: [:path] } do
      before do
        component.snapshots_enabled = false
      end

      it 'parses the index.html to catalog correctly' do
        expect { subject }.to change { component.catalog.planes.keys.count }.from(0).to(expected_entries)
      end

      context 'for Kawasaki Ki-10' do
        let(:expected_uuid) { '09fbf7e8284a52ac2daef4c61f404048' }
        let(:planes) { component.catalog.planes.collect { |_, v| v['path'] == '/wiki/Kawasaki_Ki-10' ? v : nil }.compact }
        let(:plane) { planes.first }
        it 'loads one entry only' do
          subject
          expect(planes.count).to eql(1)
        end
        it 'loads details correctly' do
          subject
          expect(plane['uuid']).to eql expected_uuid
          expect(plane['name']).to eql('Kawasaki Ki-10 Army Type 95 Fighter')
          expect(plane['url']).to eql('https://en.wikipedia.org/wiki/Kawasaki_Ki-10')
          expect(plane['categories']).to match_array(['Fighters', 'Reconnaissance aircraft'])
          expect(plane['allied_code']).to eql('Perry')
          expect(plane['first_flown']).to eql(1935)
          expect(plane['number_built']).to eql(588)
          expect(plane['services']).to match_array(%w[IJA])
        end
      end

      context 'for Kawanishi_N1K' do
        let(:expected_uuid) { '2ad0cafbdae52374ba8ee9486f90b0d1' }
        it 'loads details correctly' do
          expect { subject }.to change { component.catalog.planes[expected_uuid]&.keys }.from(nil).to(expected_keys)
          plane = component.catalog.planes[expected_uuid]
          expect(plane['name']).to eql('Kawanishi N1K Kyofu Navy Fighter Seaplane')
          expect(plane['url']).to eql('https://en.wikipedia.org/wiki/Kawanishi_N1K')
          expect(plane['categories']).to match_array(%w[Fighters])
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
          expect(plane['categories']).to match_array(%w[Fighters])
          expect(plane['allied_code']).to eql('George')
          expect(plane['first_flown']).to eql(1943)
          expect(plane['number_built']).to eql(1435)
          expect(plane['services']).to match_array(%w[IJN])
        end
      end

      context 'for Mitsubishi Ki-46' do
        let(:expected_uuid) { '2e090e977e02b0b90915b7317b3c7d3f' }
        let(:planes) { component.catalog.planes.collect { |_, v| v['path'] == '/wiki/Mitsubishi_Ki-46' ? v : nil }.compact }
        let(:plane) { planes.first }
        it 'loads one entry only' do
          subject
          expect(planes.count).to eql(1)
        end
        it 'loads details correctly' do
          subject
          expect(plane['uuid']).to eql expected_uuid
          expect(plane['name']).to eql('Mitsubishi Ki-46-III-Kai Army Type 100 Air Defence Fighter')
          expect(plane['url']).to eql('https://en.wikipedia.org/wiki/Mitsubishi_Ki-46')
          expect(plane['categories']).to match_array(['Fighters', 'Reconnaissance aircraft'])
          expect(plane['allied_code']).to eql('Dinah')
          expect(plane['first_flown']).to eql(1941)
          expect(plane['number_built']).to eql(1742)
          expect(plane['services']).to match_array(%w[IJA IJN])
        end
      end

      context 'for Nakajima J1N' do
        let(:expected_uuid) { '439faabb9cbb57ad9a597ee4aea90f03' }
        let(:planes) { component.catalog.planes.collect { |_, v| v['path'] == '/wiki/Nakajima_J1N' ? v : nil }.compact }
        let(:plane) { planes.first }
        it 'loads one entry only' do
          subject
          expect(planes.count).to eql(1)
        end
        it 'loads details correctly' do
          subject
          expect(plane['uuid']).to eql expected_uuid
          expect(plane['name']).to eql('Nakajima J1N Gekkou Navy Type 2 Reconnaissance Plane')
          expect(plane['url']).to eql('https://en.wikipedia.org/wiki/Nakajima_J1N')
          expect(plane['categories']).to match_array(['Fighters', 'Reconnaissance aircraft'])
          expect(plane['allied_code']).to eql('Irving')
          expect(plane['first_flown']).to eql(1941)
          expect(plane['number_built']).to eql(479)
          expect(plane['services']).to match_array(%w[IJN])
        end
      end

      context 'for Tachikawa Ki-94' do
        let(:expected_uuid) { '5afc98ea6e5a36f6fc83acd74baee3f2' }
        let(:planes) { component.catalog.planes.collect { |_, v| v['path'] == '/wiki/Tachikawa_Ki-94' ? v : nil }.compact }
        let(:plane) { planes.first }
        it 'loads one entry only' do
          subject
          expect(planes.count).to eql(1)
        end
        it 'loads details correctly' do
          subject
          expect(plane['uuid']).to eql expected_uuid
          expect(plane['name']).to eql('Tachikawa Ki-94')
          expect(plane['url']).to eql('https://en.wikipedia.org/wiki/Tachikawa_Ki-94')
          expect(plane['categories']).to match_array(['Experimental aircraft'])
          expect(plane['allied_code']).to eql('n/a')
          expect(plane['first_flown']).to be_nil
          expect(plane['number_built']).to eql(2)
          expect(plane['services']).to match_array(%w[IJA])
        end
      end

      context 'for Yokosuka MXY-7 Ohka' do
        let(:expected_uuid) { '76889e3e340299ae29eec2edbe6245a3' }
        it 'loads details correctly' do
          expect { subject }.to change { component.catalog.planes[expected_uuid]&.keys }.from(nil).to(expected_keys)
          plane = component.catalog.planes[expected_uuid]
          expect(plane['name']).to eql('Yokosuka MXY-7 Ohka')
          expect(plane['url']).to eql('https://en.wikipedia.org/wiki/Ohka')
          expect(plane['categories']).to match_array(['Attack aircraft'])
          expect(plane['allied_code']).to eql("Baka ('Fool' in Japanese)[1]")
          expect(plane['first_flown']).to eql(1944)
          expect(plane['number_built']).to eql(852)
          expect(plane['services']).to match_array(%w[IJN])
        end
      end

      context 'for Mitsubishi Hinazuru-type Passenger Transport' do
        let(:expected_uuid) { '3d7668c49dd53fc000fae43fb96fc29c' }
        it 'skips loading' do
          expect { subject }.to_not change { component.catalog.planes[expected_uuid] }.from(nil)
        end
      end
    end
  end
end
