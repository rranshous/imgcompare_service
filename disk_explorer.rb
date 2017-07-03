require 'sinatra'
require_relative 'disk_scanner'
require_relative 'image'
require_relative 'image_collection'
require_relative 'image_fingerprinter'
require_relative 'color_scanner'

DATA_ROOT = 'data'

images = ImageCollection.new
fingerprinter = ImageFingerprinter.new
color_scanner = ColorScanner.new

disk_scanner = DiskScanner.new Image
disk_scanner.scan("#{DATA_ROOT}/**/*.jpg", images)

images.each do |image|
  fingerprinter.fingerprint(image)
  color_scanner.scan(image)
end

puts "images: #{images.size}"

get '/images.html' do
  """
  <style>img { width: 300px }</style>
  """ + \
  images.map do |image|
    """
    <a href='/images/#{image.path}/data'>
      <img src='/images/#{image.path}/data'>
    </a>
    """
  end.join("\n")
end

get '/images/*/data' do
  image_path = params['splat'].first
  content_type 'image/jpeg'
  image = images.find path: Pathname.new(image_path)
  halt 404 if image.nil?
  data = image.data
  puts "data len: #{data.length}"
  data
end

