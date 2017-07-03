require 'pathname'

class FingerprintLoader

  def load image
    image.fingerprint = fingerprint_from_file image
  end

  def fingerprint_from_file image
    path = fingerprint_path(image)
    if path.exist?
      fingerprint_path(image).read.strip
    else
      nil
    end
  end

  def fingerprint_path image
    Pathname.new "#{image.path}.fingerprint"
  end
end
