require 'fileutils'
require 'pathname'
require 'json'

module FixturesHelper
  def project_path
    Pathname.new(File.dirname(__FILE__)).join('..', '..')
  end

  def fixtures_path
    Pathname.new(File.dirname(__FILE__)).join('..', 'fixtures')
  end

  def get_json_fixture(filename, *collection_spec)
    JSON.load(fixtures_path.join(*collection_spec, filename))
  end

  def get_html_snapshot(filename)
    path = fixtures_path.join('snapshots', filename)
    Nokogiri::HTML(path)
  end
end

RSpec.configure do |conf|
  conf.include FixturesHelper
end
