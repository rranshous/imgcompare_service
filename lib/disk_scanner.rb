class DiskScanner
  attr_accessor :item_loader

  def initialize item_loader
    self.item_loader = item_loader
  end

  def scan pattern
    puts "Scanning: #{pattern}"
    Dir[pattern].lazy.map { |path| item_loader.load(Pathname.new(path)) }
  end
end
