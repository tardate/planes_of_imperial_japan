require 'spec_helper'

describe Scraper do
  let(:component) { described_class.new }
  describe '#load_plane' do
    subject { component.load_plane(plane) }
    let(:plane) { { 'uuid' => uuid } }
    let(:given_catalog) { Catalog.new }
    before do
      component.catalog = given_catalog
      allow(component).to receive(:load_plane_doc).and_return(snapshot)
      allow(component).to receive(:log)
    end
    let(:snapshot) { get_html_snapshot(snapshot_file) }
    let(:snapshot_file) { [uuid, 'html'].join('.') }
    context 'for Kawanishi_N1K' do
      let(:uuid) { '2ad0cafbdae52374ba8ee9486f90b0d1' }
      it 'parses the page correctly' do
        expect { subject }.to change { plane.keys.sort }.to(%w[uuid title title_ja image_url image_local_name variants description].sort)
        expect(plane['title']).to eql('Kawanishi N1K')
        expect(plane['title_ja']).to eql('強風')
        expect(plane['description']).to include('The Kawanishi N1K was an Imperial Japanese Navy fighter aircraft')
        expect(plane['image_url']).to eql('https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Kawanishi_N1K2-J_050317-F-1234P-015.jpg/300px-Kawanishi_N1K2-J_050317-F-1234P-015.jpg')
        expect(plane['image_local_name']).to eql('2ad0cafbdae52374ba8ee9486f90b0d1.jpg')
      end
      it 'loads variants correctly' do
        expect { subject }.to change { plane['variants']&.count }.to(18)
      end
    end

    context 'for Tachikawa Ki-94-I' do
      let(:uuid) { '5afc98ea6e5a36f6fc83acd74baee3f2' }
      it 'parses the page correctly' do
        expect { subject }.to change { plane.keys.sort }.to(%w[uuid title description].sort)
        expect(plane['title']).to eql('Tachikawa Ki-94')
        expect(plane['description']).to include('The Tachikawa Ki-94 was a single-seat fighter-Interceptor')
      end
    end
  end
end
