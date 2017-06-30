class Tracked
  THRESHOLD = 10

  attr_accessor :file_path, :fingerprint

  def initialize file_path, fingerprint
    self.file_path   = file_path
    self.fingerprint = fingerprint
  end

  def filename
    File.basename file_path
  end

  def < other
    dist = distance other
    if dist <= THRESHOLD
      false
    else
      fingerprint < other.fingerprint
    end
  end

  def > other
    dist = distance other
    if dist <= THRESHOLD
      false
    else
      fingerprint > other.fingerprint
    end
  end

  def == other
    dist = distance other
    dist <= THRESHOLD
  end

  def distance other
    Phashion.hamming_distance self.fingerprint, other.fingerprint
  end
end

