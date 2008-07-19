require 'yaml'

module Outback
  
  class Manager
    
    ROLLOUT = 1
    ROLLBACK = -1
    
    attr_reader :tasks, :position
    attr_accessor :workdir
    attr_writer :watcher
  
    def initialize
      @tasks = []
      @names = {}
      @position = 0
    end
    
    def add_tasks( *tasks )
      [*tasks].each do |task|
        task.workdir = @workdir unless task.workdir
        
        if task.name
          if @names.has_key?(task.name)
            raise DuplicateNamedTaskError, "Cannot add a named task more than once!"
          else
            @names[task.name] = @tasks.length
          end
        end
        
        @tasks << task
      end
    end
    
    alias_method :add_task, :add_tasks
    
    def find_task( name )
      @tasks[@names[name]]
    end
    
    def rollout!
      @direction = ROLLOUT
      run
    end
    
    def rollback!
      @direction = ROLLBACK
      run
    end
    
    def rollout_from( task )
      @position = @tasks.index(task)
      rollout!
    end
    
    def rollback_from( task )
      @position = @tasks.index(task) - 1
      rollback!
    end
    
    def attempt( task )
      method = {ROLLOUT => :rollout!, ROLLBACK => :rollback!}[@direction]
      ret = task.send(method)
      @watcher.notify(task) if @watcher
      return ret
    end
    
    def current_task
      @tasks[@position]
    end
    
    private
    
    def run
      if @direction == ROLLOUT
        task_list = @tasks[@position..-1]
      elsif @direction == ROLLBACK
        task_list = @tasks[0..@position + 1].reverse
      end
      task_list.each do |task|
        @position = @tasks.index(task)
        unless attempt current_task
          fail
          break
        end
      end
    end
    
    def fail
      case @direction
      when ROLLOUT
        #rollback_from current_task
        raise Error, "Could not rollout task #{current_task}, attempting rollback."
      when ROLLBACK
        raise TransactionError, "Could not rollback task #{current_task}, aborting."
      else
        raise Error, "Unknown direction!"
      end
    end
    
  end

end
