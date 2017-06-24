require 'sinatra'
require 'phashion'
require_relative 'array'

class Tracked
  THRESHOLD = 10

  attr_accessor :filename, :fingerprint

  def initialize filename, fingerprint
    self.filename    = filename
    self.fingerprint = fingerprint
  end

  def < other
    dist = distance other.fingerprint
    if dist <= THRESHOLD
      false
    else
      fingerprint < other.fingerprint
    end
  end

  def > other
    dist = distance other.fingerprint
    if dist <= THRESHOLD
      false
    else
      fingerprint > other.fingerprint
    end
  end

  def == other
    dist = distance other.fingerprint
    dist <= THRESHOLD
  end

  def distance fingerprint
    Phashion.hamming_distance self.fingerprint, fingerprint
  end
end

all_data = []

post '/image' do
  filename = params[:image][:filename]
  fh = params[:image][:tempfile]
  p_img = Phashion::Image.new fh.path
  fingerprint = p_img.fingerprint
  t = Tracked.new filename, fingerprint
  all_data.binary_insert t
  puts "fingerprint: #{fingerprint}"
  puts "DATA: #{all_data}"
end

