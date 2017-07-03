class Image
  attr_accessor :path, :fingerprint, :palette

  def self.load path
    new path: path
  end

  def initialize opts
    self.path ||= opts[:path]
  end

  def data
    path.read
  end

  def to_s
    "#<#{self.class.name}:#{path}>"
  end

end
