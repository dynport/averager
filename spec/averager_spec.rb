require File.dirname(__FILE__) + '/spec_helper.rb'

# Time to add your specs!
# http://rspec.info/
describe "Place your specs here" do
  before(:each) do
    @log_path = File.expand_path(File.dirname("#{__FILE__}") + "/../tmp/status.log")
    FileUtils.rm_f(@log_path)
    TimeTravel.freeze_to Time.local(2009, 9, 9, 11, 20, 0)
  end
  
  it "should print the first every time" do
    avg = Averager.new(:log_path => @log_path, :every => 10, :digits => 3)
    TimeTravel.jump(1)
    avg.avg(100, "test")
    File.read(@log_path).should == %(100 (100.0/second): test\n)
  end
  
  it "should only print every x seconds" do
    avg = Averager.new(:log_path => @log_path, :every => 10, :digits => 3)
    TimeTravel.jump(1)
    avg.avg(100, "test")
    File.read(@log_path).should == %(100 (100.0/second): test\n)
    TimeTravel.jump(1)
    avg.avg(200, "test")
    File.read(@log_path).should == %(100 (100.0/second): test\n)
    TimeTravel.jump(9)
    avg.avg(1100, "test")
    File.read(@log_path).should == %(100 (100.0/second): test\n1100 (100.0/second): test\n)
  end
  
  it "should include a percentage and estimated end time" do
    avg = Averager.new(:log_path => @log_path, :expected => 1000, :every => 1.0)
    TimeTravel.jump(1)
    avg.avg(500, "500")
    TimeTravel.jump(1)
    avg.avg(750, "750")
    File.read(@log_path).should == %( 500/1000 50.0% (500.0/second 00:00:01): 500\n 750/1000 75.0% (375.0/second 00:00:00): 750\n)
  end
  
  it "should print a progress when asked for" do
    avg = Averager.new(:log_path => @log_path, :expected => 1000, :every => 1.0, :progress_bar => true)
    TimeTravel.jump(1)
    avg.avg(500, "500")
    File.read(@log_path).should == %( 500/1000 50.0% (500.0/second 00:00:01): 500)
    TimeTravel.jump(1)
    avg.avg(750, "750")
    File.read(@log_path).should == %( 750/1000 75.0% (375.0/second 00:00:00): 750)
  end
  
  it "should not be mandatory to call with integer" do
    avg = Averager.new(:log_path => @log_path, :expected => 2, :every => 1.0)
    TimeTravel.jump(1)
    avg.avg
    TimeTravel.jump(1)
    avg.avg
    File.read(@log_path).should == %(1/2 50.0% (1.0/second 00:00:01)\n2/2 100.0% (1.0/second)\n)
  end
  
  it "should be able to be called with a block" do
    Averager.new(:log_path => @log_path, :expected => 2, :every => 1) do |avg|
      TimeTravel.jump(1)
      avg.avg
      TimeTravel.jump(1)
      avg.avg
    end
    File.read(@log_path).should == %(1/2 50.0% (1.0/second 00:00:01)\n2/2 100.0% (1.0/second)\nfinished in 2.0\n)
  end
  
  it "should not break on printing first and per_second is null" do
    Averager.new(:log_path => @log_path, :expected => 2, :every => 1) do |a|
      a.avg
    end
    File.read(@log_path).should == "1/2 50.0% (inf/second)\nfinished in 0.0\n"
  end
  
  it "should not break when per_second is 0.0" do
    Averager.new(:log_path => @log_path, :expected => 2, :every => 1) do |a|
      a.avg(0.0)
    end
  end
  
  it "should print the last status when finished before" do
    Averager.new(:log_path => @log_path, :expected => 3, :every => 4) do |avg|
      TimeTravel.jump(1)
      avg.avg
      TimeTravel.jump(1)
      avg.avg
      TimeTravel.jump(1)
      avg.avg
    end
    File.read(@log_path).should == %(1/3 33.3% (1.0/second 00:00:02)\n3/3 100.0% (1.0/second)\nfinished in 3.0\n)
  end
  
  it "should be able to average over an array" do
    [1, 2, 3, 4].each_with_avg(:log_path => @log_path) do |i|
      TimeTravel.jump(1)
    end
    File.read(@log_path).should == %(1/4 25.0% (1.0/second 00:00:03)\n2/4 50.0% (1.0/second 00:00:02)\n3/4 75.0% (1.0/second 00:00:01)\n4/4 100.0% (1.0/second)\nfinished in 4.0\n)
  end
end
