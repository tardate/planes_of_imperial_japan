require 'spec_helper'

describe Scrapers::WikiList do
  let(:component) { described_class.new(given_catalog) }
  let(:given_catalog) { Catalog.new }

  vcr_base = 'scrapers/wiki_list/load_plane'

  describe '#load_plane' do
    subject { component.load_plane(plane) }
    before do
      component.snapshots_enabled = false
      allow(component).to receive(:log)
    end
    let(:base_keys) { %w[uuid category name path url] }
    let(:expected_keys) { (base_keys + added_keys).sort }

    context 'for Aichi B7A', vcr: { cassette_name: "#{vcr_base}/Aichi_B7A", match_requests_on: [:path] } do
      let(:plane) do
        {
          'uuid' => '7c698e1440838dc1b20c18ad1b61d217',
          'category' => 'Attack aircraft',
          'name' => 'Aichi B7A Ryusei Navy carrier torpedo bomber',
          'path' => '/wiki/Aichi_B7A',
          'url' => 'https://en.wikipedia.org/wiki/Aichi_B7A'
        }
      end
      let(:added_keys) { %w[title title_ja image_url image_local_name variants description] }
      it 'parses the page correctly' do
        expect { subject }.to change { plane.keys.sort }.to(expected_keys)
        expect(plane['title']).to eql('Aichi B7A')
        expect(plane['title_ja']).to eql('流星')
        expect(plane['description']).to include('The Aichi B7A Ryusei')
        expect(plane['image_url']).to eql('https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Aichi_B7A_Ryusei.jpg/300px-Aichi_B7A_Ryusei.jpg')
        expect(plane['image_local_name']).to eql('7c698e1440838dc1b20c18ad1b61d217.jpg')
      end
      it 'loads variants correctly' do
        expect { subject }.to change { plane['variants']&.count }.to(4)
      end
    end

    context 'for Kawanishi_N1K', vcr: { cassette_name: "#{vcr_base}/Kawanishi_N1K", match_requests_on: [:path] } do
      let(:plane) do
        {
          'uuid' => '2ad0cafbdae52374ba8ee9486f90b0d1',
          'category' => 'Fighters',
          'name' => 'Kawanishi N1K Kyofu Navy Fighter Seaplane',
          'path' => '/wiki/Kawanishi_N1K',
          'url' => 'https://en.wikipedia.org/wiki/Kawanishi_N1K'
        }
      end
      let(:added_keys) { %w[title title_ja image_url image_local_name variants description] }
      it 'parses the page correctly' do
        expect { subject }.to change { plane.keys.sort }.to(expected_keys)
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

    context 'for Kawanishi_N1K-J', vcr: { cassette_name: "#{vcr_base}/Kawanishi_N1K-J", match_requests_on: [:path] } do
      let(:plane) do
        {
          'uuid' => '8db9bedd6990b3c01e31a80e6956a452',
          'category' => 'Fighters',
          'name' => 'Kawanishi N1K Kyofu Navy Fighter Seaplane',
          'path' => '/wiki/Kawanishi_N1K-J',
          'url' => 'https://en.wikipedia.org/wiki/Kawanishi_N1K-J'
        }
      end
      let(:added_keys) { %w[title title_ja image_url image_local_name variants description] }
      it 'parses the page correctly' do
        expect { subject }.to change { plane.keys.sort }.to(expected_keys)
        expect(plane['title']).to eql('Kawanishi N1K-J')
        expect(plane['title_ja']).to eql('強風')
        expect(plane['description']).to include('The Kawanishi N1K is an Imperial Japanese Navy fighter aircraft')
        expect(plane['image_url']).to eql('https://upload.wikimedia.org/wikipedia/commons/thumb/7/71/N1K1_in_biwalake.jpg/220px-N1K1_in_biwalake.jpg')
        expect(plane['image_local_name']).to eql('8db9bedd6990b3c01e31a80e6956a452.jpg')
      end
      it 'loads variants correctly' do
        expect { subject }.to change { plane['variants']&.count }.to(18)
      end
    end

    context 'for Tachikawa Ki-94-I', vcr: { cassette_name: "#{vcr_base}/Tachikawa_Ki-94", match_requests_on: [:path] } do
      let(:plane) do
        {
          'uuid' => '5afc98ea6e5a36f6fc83acd74baee3f2',
          'category' => 'Experimental aircraft',
          'name' => 'Tachikawa Ki-94-I',
          'path' => '/wiki/Tachikawa_Ki-94',
          'url' => 'https://en.wikipedia.org/wiki/Tachikawa_Ki-94'
        }
      end
      let(:added_keys) { %w[title description] }
      it 'parses the page correctly' do
        expect { subject }.to change { plane.keys.sort }.to(expected_keys)
        expect(plane['title']).to eql('Tachikawa Ki-94')
        expect(plane['description']).to include('The Tachikawa Ki-94 was a single-seat fighter-Interceptor')
      end
    end

    context 'for Yokosuka MXY-7 Ohka', vcr: { cassette_name: "#{vcr_base}/Ohka", match_requests_on: [:path] } do
      let(:plane) do
        {
          'uuid' => '76889e3e340299ae29eec2edbe6245a3',
          'category' => 'Attack aircraft',
          'name' => 'Yokosuka MXY-7 Ohka',
          'path' => '/wiki/Ohka',
          'url' => 'https://en.wikipedia.org/wiki/Ohka'
        }
      end
      let(:added_keys) { %w[title title_ja image_url image_local_name variants description] }
      it 'parses the page correctly' do
        expect { subject }.to change { plane.keys.sort }.to(expected_keys)
        expect(plane['title']).to eql('Yokosuka MXY-7 Ohka')
        expect(plane['title_ja']).to eql('櫻花')
        expect(plane['description']).to include('The Yokosuka MXY-7 Ohka')
        expect(plane['image_url']).to eql('https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Japanese_Ohka_rocket_plane.jpg/300px-Japanese_Ohka_rocket_plane.jpg')
        expect(plane['image_local_name']).to eql('76889e3e340299ae29eec2edbe6245a3.jpg')
      end
      it 'loads variants correctly' do
        expect { subject }.to change { plane['variants']&.count }.to(12)
      end
    end
  end
end
