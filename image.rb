class Image
  attr_accessor :path

  def self.load path
    new path: path
  end

  def initialize opts
    self.path ||= opts[:path]
  end

  def data data_reader
    data_reader.read self.path
  end

end
