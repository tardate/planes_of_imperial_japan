require 'spec_helper'

describe Catalog do
  let(:component) { described_class.new }
  describe '#base_folder' do
    subject { component.base_folder }
    it 'returns the correct local folder' do
      expect(subject.to_s).to eql(project_path.join('cache').to_s)
    end
  end
  describe '#snapshots_folder' do
    subject { component.snapshots_folder }
    it 'returns the correct local folder' do
      expect(subject.to_s).to eql(project_path.join('cache').join('snapshots').to_s)
    end
  end
  describe '#file_path' do
    subject { component.file_path }
    it 'returns the correct local file' do
      expect(subject.to_s).to eql(project_path.join('cache').join('catalog.json').to_s)
    end
  end
  describe '#data_table_path' do
    subject { component.data_table_path }
    it 'returns the correct local folder' do
      expect(subject.to_s).to eql(project_path.join('cache').join('data.json').to_s)
    end
  end
end

