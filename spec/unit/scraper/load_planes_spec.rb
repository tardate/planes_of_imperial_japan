require 'spec_helper'

describe Scraper do
  let(:component) { described_class.new }
  describe '#load_planes' do
    subject { component.load_planes }
    let(:given_catalog) { Catalog.new }
    before do
      component.catalog = given_catalog
      allow(component).to receive(:index_doc).and_return(snapshot)
      allow(component).to receive(:load_plane)
      allow(component).to receive(:log)
    end
    let(:snapshot) { get_html_snapshot('index.html') }
    let(:expected_keys) do
      %w[
        name category path allied_code first_flown
        number_built services uuid url
      ]
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
  end
end
