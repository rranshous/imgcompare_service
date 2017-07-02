class Scanner
  attr_accessor :image_loader

  def initialize image_loader
    self.image_loader = image_loader
  end

  def scan file_path, collection
    puts "scanning: #{file_path}"
    Dir["#{file_path}/**/*.jpg"].each do |image_path|
      puts "adding #{image_path}"
      collection << image_loader.load(Pathname.new(image_path))
    end
  end
end
