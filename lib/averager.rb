$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

class Averager
  VERSION = '0.0.1'
  
  def initialize(options = {})
    @started = Time.now
    @every = options[:every] || 1000
    if @expected_lines = options[:expected_lines]
      @digits = @expected_lines.to_i.to_s.length
    end
    if options[:digits]
      @digits = options[:digits]
    else
      @digits ||= 7
    end
    @stream = options[:stream] || STDOUT
  end

  def avg(i, status = nil)
    if i > 0 && i % @every == 0
      per_second = i / (Time.now - @started)
      out = nil
      if block_given?
        out = yield(:digits => @digits, :i => i, :per_second => per_second, :status => status)
      else
        out = "%0#{@digits}d: %.1f" % [i, per_second]
        out << ": #{status}" if status
      end
      @stream.puts out
      @stream.flush
      true
    else
      false
    end
  end
end