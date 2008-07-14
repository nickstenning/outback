require 'yaml'
require 'tempfile'

module Outback
  
  class Manager
    
    attr_reader :tasks, :status, :errors, :position
    attr_writer :logger
    attr_accessor :workdir
  
    def initialize
      @tasks = []
      @statuses = []
      @errors = []
      @position = 0
    end
    
    def rollout
      @direction = 1
      run
    end
    
    def rollback
      @direction = -1
      run
    end
    
    def rollout_from( task )
      @position = @tasks.index(task)
      rollout
    end
    
    def rollback_from( task )
      @position = @tasks.index(task) - 1
      rollback
    end
    
    def attempt
      method = {1 => :rollout, -1 => :rollback}[@direction]
      Dir.chdir(@workdir || Dir.pwd) do
        @statuses << [method, *current_task.send(method)]
      end
      return latest_okay?
    end
    
    def latest_okay?
      status[1] == 0
    end
    
    def errors
      @statuses.select { |status| status[1] != 0 }
    end
    
    def status
      @statuses.last
    end
    
    def current_task
      @tasks[@position]
    end
    
    def state
      { :position => @position, 
        :direction => @direction, 
        :statuses => @statuses }
    end
    
    private
    
    def run
      if @direction == 1
        task_list = @tasks[@position..-1]
      elsif @direction == -1
        task_list = @tasks[0..@position + 1].reverse
      end
      task_list.each do |task|
        @position = @tasks.index(task)
        unless attempt
          fail
          break
        end
      end
    end
    
    def fail
      case status[0]
      when :rollout
        rollback_from current_task
        raise TransactionError, "Could not rollout task #{current_task}, attempting rollback."
      when :rollback
        raise TransactionError, "Could not rollback task #{current_task}, aborting."
      else
        raise Error, "Unknown direction!"
      end
    end
    
  end

end
