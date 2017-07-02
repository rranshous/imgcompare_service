class DiskReader
  def read path
    File.read(File.absolute_path(path))
  end
end
