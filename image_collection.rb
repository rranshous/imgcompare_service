require 'thread'

class ImageCollection
  attr_accessor :mutex

  def initialize
    @data = []
    self.mutex = Mutex.new
  end

  def each &blk
    synchronize{ @data.dup }.each(&blk)
  end

  def << image
    synchronize { @data << image }
  end

  def map &blk
    synchronize{ @data.dup }.map(&blk)
  end

  def select &blk
    synchronize{ @data.dup }.select(&blk)
  end

  def find criteria
    select do |image|
      criteria.any? do |message, reply|
        puts "#{image}: #{message} #{reply} | #{image.public_send(message)}"
        image.public_send(message) == reply
      end
    end.first
  end

  def synchronize
    mutex.synchronize { yield }
  end
end
