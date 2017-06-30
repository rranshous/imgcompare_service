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
    if all_data.length != last_snapshot_count
      puts "background] dumping"
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
  File.open(file_path, 'w'){ |fh| fh.write tfh.read }
  p_img = Phashion::Image.new tfh.path
  fingerprint = p_img.fingerprint
  t = Tracked.new file_path, fingerprint
  data_mutex.synchronize { all_data.binary_insert t }
  puts "fingerprint: #{fingerprint}"
end

get '/images.html' do
  max = (params[:max] || 1_000).to_i
  data_mutex.synchronize do
    all_data.first(max).map {|tracked| thumbnail_for tracked }.join("\n")
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
  puts "threshold: #{threshold}"
  img = data_mutex.synchronize do
    all_data.find {|t| t.filename == filename }
  end
  closest = data_mutex.synchronize do
    all_data.select {|t| img.distance(t) < threshold }
  end
  closest.map { |tracked| thumbnail_for tracked }.join("\n")
end

helpers do
  def thumbnail_for tracked
    href = "/image/#{tracked.filename}"
    """
    <a href='#{href}/neighbors?threshold=20'>
    <img
      alt='#{tracked.fingerprint} #{tracked.filename}'
      style='width: 300px'
      src='#{href}'>
    </a>
    """
  end
end
