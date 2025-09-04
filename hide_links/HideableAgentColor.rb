require 'RubyColorBase.rb'
java_import java.awt.Color

class HideableAgentColor < RubyColorBase
  @@coefficientOfHue = 0.35
  @@exponent = 5.0
  @@saturation = 0.8588
  @@brightness = 0.698

  def getAgentColorRGB(agent)
    link = getAgentLink(agent)
    if link.hasTag('HIDDEN') then
      return [255, 255, 255] 
    else
      hue = (agent.getSpeed() ** @@exponent) * @@coefficientOfHue
      rgb_int = Color.HSBtoRGB(hue.to_f, @@saturation.to_f, @@brightness.to_f)
      return [(rgb_int >> 16) & 0xFF, (rgb_int >> 8) & 0xFF, rgb_int & 0xFF]
    end
  end
end

