class Catalog
  attr_writer :content

  def content
    @content ||= {}
  end

  def load
    self.content = JSON.load file_path if File.exist?(file_path)
    self
  end

  def save
    File.write(file_path, JSON.pretty_generate(content))
  end

  def export_data_table
    File.write(data_table_path, JSON.pretty_generate(planes.values))
  end

  def base_folder
    @base_folder ||= ensure_folder_exists! Pathname.new(File.dirname(__FILE__)).join('..', 'cache')
  end

  def base_folder=(value)
    @base_folder = ensure_folder_exists! value
  end

  def snapshots_folder
    @snapshots_folder ||= ensure_folder_exists! base_folder.join('snapshots')
  end

  def file_path
    @file_path ||= base_folder.join('catalog.json')
  end

  def data_table_path
    base_folder.join('data.json')
  end

  def image_folder
    @image_folder ||= ensure_folder_exists! base_folder.join('images')
  end

  def image_path(local_name)
    image_folder.join(local_name)
  end

  def planes
    content['planes'] ||= {}
  end

  def planes=(value)
    content['planes'] = value
  end

  protected

  def ensure_folder_exists!(path)
    FileUtils.mkdir_p(path) unless File.exist?(path)
    path
  end
end
