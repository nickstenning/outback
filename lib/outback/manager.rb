require 'yaml'
require 'observer'

module Outback
  
  class Manager
    
    include Observable
    
    ROLLOUT = 1
    ROLLBACK = -1
    
    attr_reader :tasks
    attr_accessor :direction, :position, :workdir, :cache
  
    def initialize
      @tasks = []
      @cache = {}
      @position = 0
      @direction = 1
    end
    
    def add_tasks( *tasks )
      @tasks += tasks
    end
    
    def add_task( task=nil, &block )
      if block_given?
        task = Outback::Task.new(&block)
      end
      add_tasks( task ) if task
    end
    
    def rollout!
      @direction = ROLLOUT
      run_all
    end
    
    def rollback!
      @direction = ROLLBACK
      run_all
    end
    
    def run_all
      cache.delete(:errors)
      
      tasks_to_run.each do |task|
        temp = cache.dup
        begin
          run task, @direction
        rescue => e
          self.cache = temp
          cache[:errors] ||= []
          cache[:errors] << e
          break false
        end
        @position += @direction
        changed
        notify_observers(state, cache)
      end
    end
    
    def tasks_to_run
      if @direction == ROLLOUT
        @tasks[@position..-1]
      elsif @direction == ROLLBACK
        @tasks[0...@position].reverse
      end
    end
    
    def state
      { :position => @position,
        :direction => @direction
      }
    end
    
    def restore_state( state )
      @position = state[:position] || @position
      @direction = state[:direction] || @direction
      self
    end
        
    def run( task, direction=1 )
      method = { ROLLOUT => :rollout!, ROLLBACK => :rollback! }[direction]
    
      task.send(method, task_helper)
    end
    
    def task_helper
      @task_helper ||= TaskHelper.new(self)
    end
  end

end