require 'spec_helper'

describe Catalog do
  let(:component) { described_class.new }
  describe '#load' do
    subject { component.load }
    before do
      component.base_folder = given_base_folder
    end
    context 'when catalog already exists' do
      let(:given_base_folder) { fixtures_path.join('catalog', 'existing') }
      it 'loads the existing catalog' do
        expect { subject }.to change { component.content }.from({})
        expect(component.content.keys).to match_array(%w[planes])
        expect(component.planes.keys).to match_array(%w[c82a2d7f8a2cab40073b04bf25de0dc8])
      end
      it 'returns reference to compoennt' do
        expect(subject).to eql(component)
      end
    end
    context 'when catalog not already present' do
      let(:given_base_folder) { fixtures_path.join('catalog', 'non_existant') }
      before do
        FileUtils.remove_dir given_base_folder if File.exist?(given_base_folder)
      end
      it 'makes a new catalog' do
        expect { subject }.to_not change { component.content }.from({})
      end
      it 'returns reference to compoennt' do
        expect(subject).to eql(component)
      end
    end
  end
end
