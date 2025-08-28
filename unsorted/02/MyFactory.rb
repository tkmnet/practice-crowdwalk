require "json"

class MyFactory < AgentFactoryBase
  
  def initialize(factory, config, fallback)
    super

    @gen = {}
    @taskSize = 0
    @taskCount = 0
    @stagedAgents = []

    text = File.read(ItkTerm.getArg(config, "generation_file").toString)
    text.gsub!(/#.*\n/, "")
    genList = JSON.load(text)
    genList.each {|orgTask|
      unless orgTask["startTime"].nil? then
        time = getSimTime(orgTask["startTime"]).getAbsoluteTime

        if !orgTask["rule"].nil? and !orgTask["total"].nil? and orgTask["rule"] == "EACH" then
          duration = orgTask["duration"].nil? ? 0 : orgTask["duration"]
          (0..orgTask["total"]).each { |i|
            addTask(time + (duration * i / 1000).to_i, orgTask)
          }
        else
          addTask(time, orgTask)
        end
      end
    }

    p "TASK SIZE: " + @taskSize.to_s
  end
  
  def initCycle()
    @beginTime = getCurrentTime() ;
    @fromTag = makeSymbolTerm("major") ;
    @fromList = getLinkTableByTag(@fromTag) ;
    @toTag = makeSymbolTerm("node_09_06") ;
    @toList = getNodeTableByTag(@toTag) ;
    @agentList = [] ;
  end
  
  def cycle()
    time = getCurrentTime().getAbsoluteTime()

    #agent = launchAgentWithRoute("RationalAgent", origin, @toTag, []) ;
    ##pp [:time0, @time0.to_s] ;
    
    gen = @gen[time]
    if gen.nil? then
      return
    end
    gen.each { |task|
      @taskCount += 1
    }
    
    if @taskCount >= @taskSize and @stagedAgents.length <= 0 then
      finalize
    end
  end

  def finalize()
    disable
  end

  def addTask(time, orgTask)
    unless orgTask["agentType"].nil? and orgTask["agentType"]["myPlan"].nil? then
      task = orgTask["agentType"]["myPlan"].clone
      task.unshift({"mode":"start", "start": orgTask["startPlace"]})
      task.push({"mode":"goal", "goal": orgTask["goal"]})
      p task
      if @gen[time].nil? then
        @gen[time] = []
      end
      @gen[time] << task
      @taskSize += 1
    end
  end

end

