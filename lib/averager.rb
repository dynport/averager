$:.unshift(File.dirname(__FILE__)) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

class Averager
  attr_accessor :every, :expected, :digits, :log_path, :stream, :progress_bar, :counter
  DEFAULT_EVERY = 1.0
  DEFAULT_DIGITS = 7
  
  module ObjectExtensions
    def each_with_avg(options = {})
      raise NoMethodError if !self.respond_to?(:each)
      options[:expected] ||= self.count if self.respond_to?(:count)
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
    self.every = options[:every] || DEFAULT_EVERY
    self.expected = options[:expected]
    self.digits = options[:digits] if options[:digits]
    self.digits ||= DEFAULT_DIGITS
    self.stream = options[:stream] || $stdout
    self.log_path = options[:log_path]
    self.progress_bar = options[:progress_bar] == true
    self.counter = 0
    flush_stream_for_progress
    if block_given?
      yield(self)
      self.finish
    end
  end
  
  def expected=(new_value)
    if @expected = new_value
      self.digits = new_value.to_i.to_s.length
    end
  end
  
  def log_path=(new_path)
    if new_path
      @log_path = new_path
      FileUtils.mkdir_p(File.dirname(new_path))
      self.stream = File.open(new_path, "a")
    end
  end
  
  def flush_stream_for_progress
    self.stream.print("\r") if self.log_path.nil?
  end
  
  def print_current?
    if @last_printed.nil? || (Time.now - @last_printed) >= self.every
      @last_printed = Time.now
      true
    else
      false
    end
  end
  
  def print_current(status = nil)
    return if self.counter == 0
    per_second = self.counter / (Time.now - @started)
    out = nil
    if block_given?
      out = yield(:digits => self.digits, :iteration => self.counter, :per_second => per_second, :status => status)
    else
      out = "%#{self.digits}d" % self.counter
      if @expected
        out << "/#{@expected}"
        out << " %3.1f%" % (100 * (self.counter / @expected.to_f)) if self.counter <= @expected
      end
      out << " (%.1f/second" % [per_second]
      if !per_second.infinite? && @expected && self.counter < @expected
        missing = @expected - self.counter
        seconds = missing / per_second
        hours = (seconds / 3600.0).floor
        seconds -= (hours * 3600)
        minutes = (seconds / 60.0).floor
        seconds -= (minutes * 60)
        out << " %02d:%02d:%02d" % [hours, minutes, seconds]
      end
      out << ")"
      out << ": #{status}" if status
    end
    if self.progress_bar
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
      self.counter = i_or_status
    else
      if i_or_status.is_a?(String)
        status = i_or_status
      end
      self.counter += 1
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
    @stream.puts "\n" if self.progress_bar
    @stream.puts "finished in #{Time.now - @started}"
    @stream.close if ![$stdout, $stderr].include?(@stream)
  end
end

Object.send(:include, Averager::ObjectExtensions)