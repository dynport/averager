module TimeTravel
  @@offset = 0
  @@frozen_time = nil
  
  def self.now
    if @@frozen_time
      @@frozen_time + offset
    else
      Time.now_without_time_travel + offset
    end
  end
  
  def self.freeze_to(time)
    @@frozen_time = time
  end
  
  def self.jump(seconds)
    @@offset = offset + seconds
  end
  
  def self.offset
    @@offset
  end
end


class << Time
  alias_method :now_without_time_travel, :now
  def now; TimeTravel.now; end
end