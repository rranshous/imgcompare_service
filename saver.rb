
class Saver

  attr_accessor :save_root

  def initialize save_root
    self.save_root = save_root
  end

  def load name
    file_path = path_for name
    if File.exists? file_path
      bin_rep = File.open(file_path, 'rb') {|fh| fh.read }
      Marshal.load bin_rep
    else
      nil
    end
  end

  def save name, data
    bin_rep = Marshal.dump data
    file_path = path_for name
    File.open(file_path, 'wb') {|fh| fh.write bin_rep }
    true
  end

  def path_for name
    File.join DATA_DIR, "#{name}.rbmdata"
  end

end
