class Array
  def binary_insert val, &blk
    blk ||= lambda { |o| o }
    i = binary_search_closest val, &blk
    compare_i       = blk.call self[i] if self[i]
    compare_val     = blk.call val
    i = [i, 0].max
    i += 1 if self[i] && compare_i < compare_val
    self.insert i, val
  end

  def binary_search_closest val, low=0, high=(self.length - 1), &blk
    blk ||= lambda { |o| o }
    mid = (low + high) / 2
    if high < low
      return mid
    end
    compare_mid_val = blk.call self[mid]
    compare_val     = blk.call val
    case
    when compare_mid_val > compare_val
      binary_search_closest(val, low, mid-1, &blk)
    when compare_mid_val < compare_val
      binary_search_closest(val, mid+1, high, &blk)
    else
      mid
    end
  end
end

module Lockable
  attr_accessor :mutex

  def initialize *args
    super
    self.mutex = Mutex.new
  end

  def with_lock &blk
    raise 'Must provide block' if !blk
    mutex.synchronize do
      blk.call self
    end
  end
end
