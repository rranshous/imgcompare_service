require 'sinatra'
require_relative 'disk_scanner'
require_relative 'image'
require_relative 'image_collection'
require_relative 'image_fingerprinter'
require_relative 'color_scanner'
require_relative 'color_saver'
require_relative 'color_comparer'
require_relative 'fingerprint_loader'
require_relative 'background_runner'

DATA_ROOT = 'data'
MAX_SCAN = 50_000

images = ImageCollection.new
#fingerprinter = ImageFingerprinter.new
#color_scanner = ColorScanner.new
color_comparer = ColorComparer.new
fingerprint_loader = FingerprintLoader.new
color_saver = ColorSaver.new
backgrounder = BackgroundRunner.new

disk_scanner = DiskScanner.new Image
found_images = disk_scanner.scan("#{DATA_ROOT}/**{,/*/**}/*.jpg").first(MAX_SCAN)
found_images = found_images.to_a
backgrounder.background do
  found_images.each_with_index do |image, i|
    puts "[#{i+1} / #{found_images.size}] loading: #{image}"
    fingerprint_loader.load(image)   if !image.fingerprint
    color_saver.load(image)          if !image.palette
    images << image
  end
  puts "images: #{images.size}"
  puts "with palette: #{images.select{|i| i.palette}.size}"
  puts "with colors: #{images.select{|i| i.colors? }.size}"
  puts "with fingerprint: #{images.select{|i| i.fingerprint}.size}"
end

get '/images.html' do
  max = (params[:max] || 20).to_i
  offset = (params[:offset] || 0).to_i
  """
  <style>img { width: 300px }</style>
  """ + \
  images.select{|i| i.colors? }
  .to_a.drop(offset).first(max).map do |image|
    image_thumbnail image
  end.to_a.join("\n")
end

get '/images/*/data' do
  image_path = params['splat'].first
  content_type 'image/jpeg'
  image = images.find path: Pathname.new(image_path)
  halt 404 if image.nil?
  image.data
end

get '/images/*/similar_color' do
  max = (params[:max] || 20).to_i
  image_path = params['splat'].first
  image = images.find path: Pathname.new(image_path)
  halt 400 if image.palette.nil?
  halt 404 if image.nil?
  begin
    timeout(25) do
      """
      <style>img { width: 300px }</style>
      """ + \
      image_thumbnail(image) + \
      color_comparer.sort_similar_parallel(image, images.select{|i| i != image}).first(max)
      .map { |similar_image| image_thumbnail(similar_image) }.join("\n")
    end
  rescue TimeoutError
    halt 503, "Timeout"
  end
end

helpers do
  def image_thumbnail image
    """
    <a href='/images/#{image.path}/similar_color'>
      <img src='/images/#{image.path}/data'>
    </a>
    """
  end
end
