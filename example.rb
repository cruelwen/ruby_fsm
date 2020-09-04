require './fsm'

puts "Example 1"
light = Fsm.new states: [:red, :green, :yellow],
  current: :red,
  async: false,
  transitions: { :red => [:green],
                 :green => [:yellow],
                 :yellow => [:red] }
puts light.current # should be red
light.set :green
puts light.current # should be green

puts "Example 2"
light = Fsm.new states: [:red, :green, :yellow],
  current: :red,
  async: true,
  transitions: { :red => [:green],
                 :green => [:yellow],
                 :yellow => [:red] }
puts light.current # should be red
light.set :green
puts light.current # may be red or green 
light.wait
puts light.current # should be green

puts "Example 3"
class FsmTrafficLight < Fsm
  def default_setting
    {
      :states => [:red, :green, :yellow],
      :current => :red,
      :async => false,
      :transitions => { :red => [:green],
                        :green => [:yellow],
                        :yellow => [:red] }
    }
  end

  def enter_green
    puts "entering green"
  end
end

light = FsmTrafficLight.new 
puts light.current # should be red
light.set :green
puts light.current # should call enter_green and then be green
