require 'set'
require 'thread'

class Fsm
  attr :current_state, :state_set, :transitions, :async, :desired_state, :transition_thread

  def default_setting
    {
      :states => [:init],
      :current => :init,
      :async => false,
      :transitions => {:init => [:init]},
    }
  end

  def initialize setting = {}
    @state_set = Set.new setting[:states] || default_setting[:states]
    @current_state = setting[:current] || default_setting[:current]
    @async = setting[:async] || default_setting[:async] 
    @transitions = setting[:transitions] || default_setting[:transitions]
    @transition_thread = Thread.new {}
    @desired_state = @current_state
  end
  
  def can_reach? desired_state
    @transitions[@current_state].include? desired_state
  end

  def current 
    @current_state
  end

  def set desired_state
    raise "#{desired_state} is not in state set #{@state_set}" unless @state_set.include? desired_state
    raise "current state is aready desired_state, omited" if @current_state == desired_state
    if @async and @transition_thread.status
      if @desired_state == desired_state
        raise "desired transition is in processing, omited"
      elsif @current_state != @desired_state
        raise "another transition from #{@current_state} to #{@desired_state} is in processing." 
      end
    end
    raise "#{desired_state} is not reachable from #{@current_state}" unless can_reach? desired_state
    transition_event desired_state
  end

  def wait
    if async
      transition_thread.join
    end
  end

  :private

  def transition_event desired_state
    @desired_state = desired_state
    if async 
      @transition_thread = Thread.new {
        self.send "leave_#{@current_state}"
        self.send "from_#{@current_state}_to_#{desired_state}"
        self.send "enter_#{desired_state}"
        @current_state = desired_state
      }
    else
      self.send "leave_#{@current_state}"
      self.send "from_#{@current_state}_to_#{desired_state}"
      self.send "enter_#{desired_state}"
      @current_state = desired_state
    end
  end

  def method_missing method_name, *args, &block
    self.class.send :define_method, method_name do
    end
    self.send(method_name)
  end

end

