require 'thread'

Thread.abort_on_exception = true

class BackgroundRunner
  def every seconds
    puts "starting background thread"
    Thread.new do
      loop do
        puts "running"
        yield
        puts "sleeping for #{seconds} seconds"
        sleep seconds
      end
    end
  end
end
