require File.dirname(__FILE__) + '/spec_helper.rb'

# Time to add your specs!
# http://rspec.info/
describe "Place your specs here" do
  before(:each) do
    @log_path = File.expand_path(File.dirname("#{__FILE__}") + "/../tmp/status.log")
    FileUtils.rm_f(@log_path)
  end
  
  it "should log to a specific logfile" do
    TimeTravel.freeze_to Time.local(2009, 9, 9, 11, 20, 0)
    avg = Averager.new(:log_path => @log_path, :every => 1, :digits => 3)
    TimeTravel.jump(1)
    avg.avg(100, "test")
    TimeTravel.jump(1)
    avg.avg(300, "test")
    File.read(@log_path).should == %(100 (100.0): test\n300 (150.0): test\n)
  end
  
  it "should only log every x time" do
    TimeTravel.freeze_to Time.local(2009, 9, 9, 11, 20, 0)
    avg = Averager.new(:log_path => @log_path, :every => 600)
    TimeTravel.jump(1)
    avg.avg(100, "100")
    TimeTravel.jump(1)
    avg.avg(300, "300")
    TimeTravel.jump(1)
    avg.avg(600, "600")
    avg.avg(601, "601")
    File.read(@log_path).should == %(    600 (200.0): 600\n)
  end
  
  it "should include a percentage and estimated end time" do
    TimeTravel.freeze_to Time.local(2009, 9, 9, 11, 20, 0)
    avg = Averager.new(:log_path => @log_path, :expected => 1000, :every => 250)
    TimeTravel.jump(1)
    avg.avg(500, "500")
    TimeTravel.jump(1)
    avg.avg(750, "750")
    File.read(@log_path).should == %( 500/1000 50.0% (500.0): 500\n 750/1000 75.0% (375.0): 750\n)
  end
  
  it "should print a progress when asked for" do
    TimeTravel.freeze_to Time.local(2009, 9, 9, 11, 20, 0)
    avg = Averager.new(:log_path => @log_path, :expected => 1000, :every => 250, :progress_bar => true)
    TimeTravel.jump(1)
    avg.avg(500, "500")
    File.read(@log_path).should == %( 500/1000 50.0% (500.0): 500)
    TimeTravel.jump(1)
    avg.avg(750, "750")
    File.read(@log_path).should == %( 750/1000 75.0% (375.0): 750)
  end
end
