require 'spec_helper'

describe Catalog do
  let(:component) { described_class.new }
  describe '#export_data_table' do
    subject { component.export_data_table }
    before do
      FileUtils.remove_dir given_base_folder if File.exist?(given_base_folder)
      component.base_folder = given_base_folder
      component.content = given_content
    end
    let(:given_base_folder) { fixtures_path.join('catalog', 'export_data_table') }
    let(:given_content) { { 'planes' => { 'a' => { 'b' => 'a' } } } }
    it 'saves the planes data as an array' do
      subject
      saved_content = get_json_fixture('data.json', 'catalog', 'export_data_table')
      expect(saved_content).to eql([{ 'b' => 'a' }])
    end
  end
end
