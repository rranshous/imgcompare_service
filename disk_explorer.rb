require 'sinatra'
require_relative 'scanner'
require_relative 'disk_reader'
require_relative 'image'
require_relative 'image_collection'

DATA_ROOT = 'data'

images = ImageCollection.new
reader = DiskReader.new

scanner = Scanner.new Image
scanner.scan DATA_ROOT, images


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
  data = image.data reader
  puts "data len: #{data.length}"
  data
end

