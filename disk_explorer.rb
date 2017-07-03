require 'sinatra'
require_relative 'disk_scanner'
require_relative 'image'
require_relative 'image_collection'
require_relative 'image_fingerprinter'
require_relative 'color_scanner'
require_relative 'color_saver'
require_relative 'fingerprint_loader'

DATA_ROOT = 'data'
MAX_SCAN = 10_000_000

images = ImageCollection.new
#fingerprinter = ImageFingerprinter.new
#color_scanner = ColorScanner.new
fingerprint_loader = FingerprintLoader.new
color_saver = ColorSaver.new

disk_scanner = DiskScanner.new Image
found_images = disk_scanner.scan("#{DATA_ROOT}/**{,/*/**}/*.jpg").first(MAX_SCAN)
found_images.to_a.each { |image| images << image }

images.to_a.each_with_index do |image, i|
  puts "[#{i+1} / #{images.size}] loading metadata: #{image}"
  fingerprint_loader.load(image)   if !image.fingerprint
  color_saver.load(image)          if !image.palette
  #fingerprinter.fingerprint(image) if !image.fingerprint
  #color_scanner.scan(image) if !image.palette
end

puts "images: #{images.size}"
puts "with palette: #{images.select{|i| i.palette}.size}"
puts "with fingerprint: #{images.select{|i| i.fingerprint}.size}"

get '/images.html' do
  max = (params[:max] || 100).to_i
  """
  <style>img { width: 300px }</style>
  """ + \
  images.to_a.first(max).map do |image|
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
  max = (params[:max] || 100).to_i
  image_path = params['splat'].first
  image = images.find path: Pathname.new(image_path)
  halt 400 if image.palette.nil?
  halt 404 if image.nil?
  """
  <style>img { width: 300px }</style>
  """ + \
  images.select{|o| o.palette }.to_a.sort_by do |other_image|
    r = image.palette.similarity other_image.palette
    r.nan? ? 1 : r
  end.to_a
  .select {|i| image.palette.similarity(i.palette) < 0.03 }
  .first(max)
  .map { |similar_image| image_thumbnail(similar_image) }.join("\n")
end

helpers do
  def image_thumbnail image
    """
    <a href='/images/#{image.path}/similar_color'>
    #{image.palette ? image.palette.colors.reverse.map{|c| "<div style='border: 5px solid ##{c.hex}'>"}.join("\n") : ''}
      <img src='/images/#{image.path}/data'>
    #{image.palette ? image.palette.colors.map{|c| '</div>'}.join("\n") : ''}
    </a>
    """
  end
end
