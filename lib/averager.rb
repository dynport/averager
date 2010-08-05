$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

class Averager
  VERSION = '0.0.3'
  
  def initialize(options = {})
    @started = Time.now
    @every = options[:every] || 1000
    if @expected = options[:expected]
      @digits = @expected.to_i.to_s.length
    end
    if options[:digits]
      @digits = options[:digits]
    else
      @digits ||= 7
    end
    @log_path = options[:log_path]
    @stream = options[:stream] || STDOUT
    flush_stream_for_progress
    @progress_bar = options[:progress_bar] == true
  end
  
  def flush_stream_for_progress
    if @log_path
      FileUtils.mkdir_p(File.dirname(@log_path))
      @stream = File.open(@log_path, "w")
    else
      @stream.print "\r"
    end
  end

  def avg(i, status = nil)
    if i > 0 && i % @every == 0
      per_second = i / (Time.now - @started)
      out = nil
      if block_given?
        out = yield(:digits => @digits, :i => i, :per_second => per_second, :status => status)
      else
        out = "%#{@digits}d" % i
        if @expected
          out << "/#{@expected}" 
          out << " %3.1f%" % (100 * (i / @expected.to_f)) if i <= @expected
        end
        out << " (%.1f)" % per_second
        out << ": #{status}" if status
      end
      if @progress_bar
        flush_stream_for_progress
        @stream.print out
      else
        @stream.puts out
      end
      @stream.flush
      true
    else
      false
    end
  end
  
  def finish
    @stream.close
  end
end