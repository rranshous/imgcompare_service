require 'sinatra'
require_relative 'disk_scanner'
require_relative 'image'
require_relative 'image_collection'
require_relative 'image_fingerprinter'
require_relative 'color_scanner'
require_relative 'color_saver'

DATA_ROOT = 'data'
MAX_SCAN = 10_000_000

images = ImageCollection.new
fingerprinter = ImageFingerprinter.new
color_scanner = ColorScanner.new
color_saver = ColorSaver.new

disk_scanner = DiskScanner.new Image
disk_scanner.scan("#{DATA_ROOT}/**/*.jpg").first(MAX_SCAN).to_a.each do |image|
  images << image
end

images.each do |image|
  fingerprinter.fingerprint(image) if !image.fingerprint
  color_saver.load(image)   if !image.palette
  color_scanner.scan(image) if !image.palette
end

puts "images: #{images.size}"

get '/images.html' do
  """
  <style>img { width: 300px }</style>
  """ + \
  images.map do |image|
    image_thumbnail image
  end.to_a.join("\n")
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

get '/images/*/similar_color' do
  image_path = params['splat'].first
  image = images.find path: Pathname.new(image_path)
  halt 404 if image.nil?
  """
  <style>img { width: 300px }</style>
  """ + \
  images.to_a.sort_by do |other_image|
    case other_image.palette
    when nil then 1
    else image.palette.similarity other_image.palette
    end
  end.to_a.first(10)
  .map { |similar_image| image_thumbnail(similar_image) }.join("\n")
end

helpers do
  def image_thumbnail image
    """
    <a href='/images/#{image.path}/data'>
      <img src='/images/#{image.path}/data'>
    </a>
    """
  end
end
