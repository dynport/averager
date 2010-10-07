$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

class Averager
  VERSION = '0.0.4'
  
  module ArrayExtensions
    def each_with_avg(options = {})
      options[:expected] ||= self.length
      Averager.new(options) do |a|
        self.each do |element|
          yield(element)
          a.avg
        end
      end
    end
  end
  
  def initialize(options = {})
    @started = Time.now
    @every = options[:every] || 1.0
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
    @i = 0
    if block_given?
      yield(self)
      self.finish
    end
  end
  
  def flush_stream_for_progress
    if @log_path
      FileUtils.mkdir_p(File.dirname(@log_path))
      @stream = File.open(@log_path, "w")
    else
      @stream.print "\r"
    end
  end
  
  def print_current?
    if @last_printed.nil? || (Time.now - @last_printed) >= @every
      @last_printed = Time.now
      true
    else
      false
    end
  end
  
  def print_current(status = nil)
    per_second = @i / (Time.now - @started)
    out = nil
    if block_given?
      out = yield(:digits => @digits, :iteration => @i, :per_second => per_second, :status => status)
    else
      out = "%#{@digits}d" % @i
      if @expected
        out << "/#{@expected}" 
        out << " %3.1f%" % (100 * (@i / @expected.to_f)) if @i <= @expected
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
  end

  def avg(*args)
    status = nil
    i_or_status = args.shift
    if args.any?
      status = args.shift
    end
    if i_or_status.is_a?(Numeric)
      @i = i_or_status
    else
      if i_or_status.is_a?(String)
        status = i_or_status
      end
      @i += 1
    end
    if print_current?
      print_current(status)
      @printed_last = true
    else
      @printed_last = false
    end
    @printed_last
  end
  
  def finish
    if !@printed_last && !print_current?
      print_current
    end
    @stream.puts "\n" if @progress_bar
    @stream.puts "finished in #{Time.now - @started}"
    @stream.close if ![$stdout, $stderr].include?(@stream)
  end
end

Array.send(:include, Averager::ArrayExtensions)