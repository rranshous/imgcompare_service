require 'thread'

class ImageCollection
  attr_accessor :mutex

  def initialize data=[]
    @data = data.dup
    self.mutex = Mutex.new
  end

  def << image
    synchronize { @data << image }
  end

  def find criteria
    select do |image|
      criteria.any? do |message, reply|
        image.public_send(message) == reply
      end
    end.to_a.first
  end

  def each &blk
    to_a.each(&blk) and self
  end

  def map &blk
    self.class.new to_a.map(&blk)
  end

  def select &blk
    self.class.new to_a.select(&blk)
  end

  def size
    synchronize{ @data.dup }.length
  end

  def to_a
    synchronize{ @data.dup }
  end

  def synchronize
    mutex.synchronize { yield }
  end

  def to_s
    "#{super}:#{synchronize { @data.dup }}"
  end
end
