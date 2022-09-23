#! /usr/bin/env ruby
require 'RubyAgentBase.rb'

class MyAgent < RubyAgentBase
  TriggerFilter = ["update", "calcSpeed"]

  def initialize(*arg)
    super(*arg)
    @seatWidth = ItkTerm.getArg(@fallback, "seat_width").getDouble()
    @myPlan = ItkTerm.toRuby(@config).to_hash["myPlan"]
    @planCursor = 0
    @myPlan.reverse.each { |plan|
      insertRoute(plan["target"])
    }
    
    @stopAt = -1.0
  end

  def calcSpeed(previousSpeed)
    speed = super(previousSpeed)
    
    if @planCursor < @myPlan.length then
      if getCurrentLink.hasTag(@myPlan[@planCursor]["target"]) then
        place = @javaAgent.getCurrentPlace()
        if @stopAt < 0.0 and place.getRemainingDistance() > (@seatWidth * (place.getIndexFromHeadingInLane(@javaAgent) +1)) then
          distance = place.getRemainingDistance() - (@seatWidth * (place.getIndexFromHeadingInLane(@javaAgent) +1))
          speed = (distance - speed <= 0.0) ? 0.2 : speed
        else
          time = getCurrentTime().getAbsoluteTime()
          if @stopAt < 0.0 then
            @stopAt = time
          end
          
          value = @myPlan[@planCursor]["value"]
          if @myPlan[@planCursor]["mode"] == "wait" then
            if value.is_a?(String) then
              if value == getCurrentTime().getAbsoluteTimeString()
                nextPlan()
              end
            else
              p ["wait", value, getCurrentTime().getRelativeTime()]
              if value < getCurrentTime().getRelativeTime()
                nextPlan()
              end
            end
          elsif @myPlan[@planCursor]["mode"] == "stop" then
            if @stopAt + value < time
              nextPlan()
            end
          else
            raise RunTimeError, "invalid mode in MyAgent"
          end
          
          speed = 0.0
        end
      end
    end
    
    return speed <= 0.0 ? 0.0 : speed
  end
  
  def nextPlan()
    @planCursor += 1
    @stopAt = -1.0
  end

end

