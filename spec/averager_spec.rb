require File.expand_path("../spec/spec_helper", File.basename(__FILE__))

# Time to add your specs!
# http://rspec.info/
describe "Place your specs here" do
  let(:log_dir) { project_root.join("tmp/logs/averager") }
  let(:log_file) { log_dir.join("out.log") }
  let(:stream) { double("stream").as_null_object }
  
  before(:each) do
    FileUtils.rm_rf(log_dir)
    Timecop.freeze Time.local(2009, 9, 9, 11, 20, 0)
  end
  
  after(:each) do
    Timecop.return
  end
  
  describe "#initialize" do
    it "sets every to 1.0 when not set" do
      Averager.new.every.should == 1.0
    end
    
    it "sets every to a value when set" do
      Averager.new(:every => 10.0).every.should == 10.0
    end
    
    it "does not set expected when nothing provided" do
      Averager.new.expected.should be_nil
    end
    
    describe "setting expected" do
      it "sets expected" do
        Averager.new(:expected => 10).expected.should == 10
      end
      
      it "sets the correct amount of digits" do
        Averager.new(:expected => 10).digits.should == 2
      end
      
      it "overwrites digits from expected" do
        Averager.new(:expected => 10, :digits => 3).digits.should == 3
      end
    end
    
    it "sets the digits to default value when not given" do
      Averager.new.digits.should == 7
    end
    
    it "sets log_path to path when provided" do
      Averager.new(:log_path => "/tmp/out.log").log_path.should == "/tmp/out.log"
    end
    
    it "sets the stream when to $stdout when not set" do
      Averager.new.stream.should == $stdout
    end
    
    it "sets the stream to a stream when present" do
      stream = double("stream").as_null_object
      Averager.new(:stream => stream).stream.should == stream
    end
    
    it "sets progress_bar to true when provided" do
      Averager.new(:progress_bar => true).progress_bar.should == true
    end
    
    it "sets porgress_bar to false when nil" do
      Averager.new(:progress_bar => nil).progress_bar.should == false
    end
    
    it "sets porgress_bar to false when something wird" do
      Averager.new(:progress_bar => false).progress_bar.should == false
    end
    
    it "sets the counter to 0" do
      Averager.new.counter.should == 0
    end
    
    describe "with log_path given" do
      it "creates the path of log file when not exists" do
        Averager.new(:log_path => log_file)
        File.should be_exists(log_dir)
      end
      
      it "creates the logfile" do
        Averager.new(:log_path => log_file)
        File.should be_exists(log_file)
      end
      
      it "opens the file for appending" do
        stream = double("stream").as_null_object
        File.should_receive(:open).with(log_file, "a").and_return stream
        Averager.new(:log_path => log_file)
      end
    end
  
    describe "with a block" do
      it "yields the block with itself" do
        results = []
        Averager.new(:stream => double("stream").as_null_object) do |a|
          results << a
        end
        results.first.should be_an_instance_of(Averager)
      end
      
      it "calls finish on after yielding" do
        Averager.new do |a|
          a.should_receive(:finish)
        end
      end
    end
  end
  
  describe "#each_with_avg" do
    class OpenIterator
      def each
        10.times do |i|
          yield(i)
        end
      end
    end
    
    class ClosedIterator
      def each
        10.times do |i|
          yield(i)
        end
      end
      
      def count
        10
      end
    end
    
    it "raises a NoMethodError when calling on a object which does not define each" do
      lambda {
        Object.new.each_with_avg
      }.should raise_error(NoMethodError)
    end
    
    describe "with objects responding to each only" do
      it "should respond to each_with_avg" do
        OpenIterator.new.should respond_to(:each_with_avg)
      end
      
      it "initializes a new averager without expected" do
        Averager.should_receive(:new).with({:stream => stream})
        OpenIterator.new.each_with_avg(:stream => stream) do |a|
        end
      end
      
      it "hands options given to each_with_avg to averager" do
        Averager.should_receive(:new).with({:every => 10, :stream => stream})
        OpenIterator.new.each_with_avg(:every => 10, :stream => stream) do |a|
        end
      end
      
      it "calls avg 10 times" do
        stream.should_receive(:puts).exactly(11).times
        OpenIterator.new.each_with_avg(:stream => stream) do |a|
          Timecop.freeze Time.now + 1
        end
      end
      
      it "does not raise NoMethodError" do
        lambda {
          OpenIterator.new.each_with_avg(:stream => stream) do
          end
        }.should_not raise_error
      end
    end
    
    describe "with objects responding to each and count" do
      it "merges expected into options when initializing averager" do
        Averager.should_receive(:new).with({:every => 10, :stream => stream, :expected => 10})
        ClosedIterator.new.each_with_avg(:every => 10, :stream => stream) do |a|
        end
      end
    end
  end
  
  it "should print the first every time" do
    avg = Averager.new(:log_path => log_file, :every => 10, :digits => 3)
    Timecop.freeze Time.now + 1
    avg.avg(100, "test")
    File.read(log_file).should == %(100 (100.0/second): test\n)
  end
  
  it "should only print every x seconds" do
    avg = Averager.new(:log_path => log_file, :every => 10, :digits => 3)
    Timecop.freeze Time.now + 1
    avg.avg(100, "test")
    File.read(log_file).should == %(100 (100.0/second): test\n)
    Timecop.freeze Time.now + 1
    avg.avg(200, "test")
    File.read(log_file).should == %(100 (100.0/second): test\n)
    Timecop.freeze Time.now + 9
    avg.avg(1100, "test")
    File.read(log_file).should == %(100 (100.0/second): test\n1100 (100.0/second): test\n)
  end
  
  it "should include a percentage and estimated end time" do
    avg = Averager.new(:log_path => log_file, :expected => 1000, :every => 1.0)
    Timecop.freeze Time.now + 1
    avg.avg(500, "500")
    Timecop.freeze Time.now + 1
    avg.avg(750, "750")
    File.read(log_file).should == %( 500/1000 50.0% (500.0/second 00:00:01): 500\n 750/1000 75.0% (375.0/second 00:00:00): 750\n)
  end
  
  it "should not be mandatory to call with integer" do
    avg = Averager.new(:log_path => log_file, :expected => 2, :every => 1.0)
    Timecop.freeze Time.now + 1
    avg.avg
    Timecop.freeze Time.now + 1
    avg.avg
    File.read(log_file).should == %(1/2 50.0% (1.0/second 00:00:01)\n2/2 100.0% (1.0/second)\n)
  end
  
  it "should be able to be called with a block" do
    Averager.new(:log_path => log_file, :expected => 2, :every => 1) do |avg|
      Timecop.freeze Time.now + 1
      avg.avg
      Timecop.freeze Time.now + 1
      avg.avg
    end
    File.read(log_file).should == %(1/2 50.0% (1.0/second 00:00:01)\n2/2 100.0% (1.0/second)\nfinished in 2.0\n)
  end
  
  it "should not break on printing first and per_second is null" do
    Averager.new(:log_path => log_file, :expected => 2, :every => 1) do |a|
      a.avg
    end
    File.read(log_file).should == "1/2 50.0% (inf/second)\nfinished in 0.0\n"
  end
  
  it "should not break when per_second is 0.0" do
    Averager.new(:log_path => log_file, :expected => 2, :every => 1) do |a|
      a.avg(0.0)
    end
  end
  
  it "should print the last status when finished before" do
    Averager.new(:log_path => log_file, :expected => 3, :every => 4) do |avg|
      Timecop.freeze Time.now + 1
      avg.avg
      Timecop.freeze Time.now + 1
      avg.avg
      Timecop.freeze Time.now + 1
      avg.avg
    end
    File.read(log_file).should == %(1/3 33.3% (1.0/second 00:00:02)\n3/3 100.0% (1.0/second)\nfinished in 3.0\n)
  end
  
  it "should be able to average over an array" do
    [1, 2, 3, 4].each_with_avg(:log_path => log_file) do |i|
      Timecop.freeze Time.now + 1
    end
    File.read(log_file).should == %(1/4 25.0% (1.0/second 00:00:03)\n2/4 50.0% (1.0/second 00:00:02)\n3/4 75.0% (1.0/second 00:00:01)\n4/4 100.0% (1.0/second)\nfinished in 4.0\n)
  end
end
