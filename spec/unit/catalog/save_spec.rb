require 'spec_helper'

describe Catalog do
  let(:component) { described_class.new }
  describe '#save' do
    subject { component.save }
    before do
      FileUtils.remove_dir given_base_folder if File.exist?(given_base_folder)
      component.base_folder = given_base_folder
      component.content = given_content
    end
    let(:given_base_folder) { fixtures_path.join('catalog', 'save') }
    let(:given_content) { { 'planes' => { 'a' => { 'b' => 'a' } } } }
    it 'saves the cataog correctly' do
      subject
      saved_content = get_json_fixture('catalog.json', 'catalog', 'save')
      expect(saved_content).to eql(given_content)
    end
  end
end
