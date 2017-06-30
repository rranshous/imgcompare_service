require 'sinatra'
require 'phashion'
require 'thread'
require_relative 'array'
require_relative 'tracked'
require_relative 'background_runner'
require_relative 'saver'

DATA_DIR = ENV['DATA_DIR'] || '/tmp'

bg_runner = BackgroundRunner.new
saver = Saver.new DATA_DIR

all_data = saver.load(:all_data) || []
last_snapshot_count = all_data.length
puts "loaded: #{last_snapshot_count} images"
data_mutex = Mutex.new

bg_runner.every(10) do
  data_mutex.synchronize do
    if last_snapshot_count != all_data.length
      saver.save :all_data, all_data
      last_snapshot_count = all_data.length
      puts "saved: #{last_snapshot_count} images"
    end
  end
end

post '/image' do
  filename = params[:image][:filename]
  tfh = params[:image][:tempfile]
  file_path = File.join DATA_DIR, File.basename(filename)
  halt 409 if File.exists? file_path
  File.open(file_path, 'w'){ |fh| fh.write tfh.read }
  p_img = Phashion::Image.new tfh.path
  fingerprint = p_img.fingerprint
  t = Tracked.new file_path, fingerprint
  data_mutex.synchronize { all_data.binary_insert t }
  tfh.unlink
  puts "fingerprint: #{fingerprint}"
end

get '/images.html' do
  max = (params[:max] || 1_000).to_i
  offset = (params[:offset] || 0).to_i
  data_mutex.synchronize do
    all_data.drop(offset).first(max)
      .map {|tracked| thumbnail_for tracked }.join("\n")
  end
end

get '/image/:filename' do |filename|
  img = data_mutex.synchronize do
    all_data.find {|t| t.filename == filename }
  end
  if img.nil?
    halt 404
  else
    content_type 'image/jpg'
    File.read(img.file_path)
  end
end

get '/image/:filename/neighbors' do |filename|
  threshold = (params[:threshold] || Tracked::THRESHOLD).to_i
  img = data_mutex.synchronize do
    all_data.find {|t| t.filename == filename }
  end
  closest = data_mutex.synchronize do
    all_data.select {|t| img.distance(t) < threshold }
  end
  closest.map { |tracked| thumbnail_for tracked }.join("\n")
end

get '/image/:filename/desc' do |filename|
  max = (params[:max] || 1_000).to_i
  img = data_mutex.synchronize do
    all_data.find {|t| t.filename == filename }
  end
  from_img = data_mutex.synchronize do
    all_data.sort_by {|t| img.distance(t) }
  end
  from_img.first(max).map { |tracked| thumbnail_for tracked }.join("\n")
end

helpers do
  def thumbnail_for tracked
    href = "/image/#{tracked.filename}"
    #neighbors_href = "#{href}/neighbors?threshold=20"
    sort_from_img_href = "#{href}/desc?max=25"
    """
    <a href='#{sort_from_img_href}'>
    <img
      alt='#{tracked.fingerprint} #{tracked.filename}'
      style='width: 300px'
      src='#{href}'>
    </a>
    """
  end
end
