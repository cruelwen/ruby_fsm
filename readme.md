# Finite State Machine in Ruby

Example 1: Basic usage
```
require 'fsm'
light = Fsm.new states: [:red, :green, :yellow],
  current: :red,
  transitions: { :red => [:green],
                 :green => [:yellow],
                 :yellow => [:red] }

puts light.current # should be red
light.set :green
puts light.current # should be green
light.set :red # should raise a error
```

Example 2: Async
```
require 'fsm'
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
```

Example 3: Using callback and inherit
```
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
```
