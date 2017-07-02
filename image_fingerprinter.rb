require 'phashion'

class ImageFingerprinter
  def fingerprint file
    file.fingerprint = Phashion::Image.new(file.path.to_s).fingerprint
  end
end
