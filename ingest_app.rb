require 'sinatra'
require 'phashion'
require 'thread'
require_relative 'array'
require_relative 'tracked'

DATA_DIR = '/tmp'
data_snapshot_path = File.join DATA_DIR, "index.marshall"

all_data = []
last_snapshot_count = 0
data_mutex = Mutex.new

if File.exists? data_snapshot_path
  puts "LOADING SNAPSHOT"
  bin_rep = File.open(data_snapshot_path, 'rb') {|fh| fh.read }
  data_mutex.synchronize { all_data = Marshal.load(bin_rep) }
  puts "LOADED: #{all_data.length}"
  last_snapshot_count = all_data.length
end

Thread.new do
  loop do
    puts "background] sleeping"
    sleep 10
    puts "background] eval for dumping"
    data_mutex.synchronize do
      if all_data.length != last_snapshot_count
        puts "background] dumping"
        bin_rep = Marshal.dump all_data
        last_snapshot_count = all_data.length
        File.open(data_snapshot_path, 'wb') {|fh| fh.write bin_rep }
      end
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
  data_mutex.synchronize do
    all_data.map do |tracked|
      "<img style='width: 300px' src='/image/#{tracked.filename}'>"
    end.join("\n")
  end
end

get '/image/:filename' do |filename|
  puts "finding: #{filename}"
  img = data_mutex.synchronize do
    all_data.find {|t| puts t.filename; t.filename == filename }
  end
  if img.nil?
    halt 404
  else
    content_type 'image/jpg'
    File.read(img.file_path)
  end
end
