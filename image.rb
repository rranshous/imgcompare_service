class Image
  attr_accessor :path, :fingerprint

  def self.load path
    new path: path
  end

  def initialize opts
    self.path ||= opts[:path]
  end

  def data
    path.read
  end

end
