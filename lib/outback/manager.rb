module Outback
  
  class Manager
    
    attr_reader :tasks, :status, :errors
    attr_writer :logger
    attr_accessor :workdir
  
    def initialize
      @tasks = []
      @statuses = []
      @errors = []
    end
    
    def rollout( task_list = @tasks )
      run :rollout, task_list
    end
    
    def rollback( task_list = @tasks.reverse )
      run :rollback, task_list
    end
    
    def rollout_from( task )
      from = @tasks.index(task)
      rollout @tasks[from..-1]
    end
    
    def rollback_from( task )
      from = @tasks.index(task)
      rollback @tasks[0..from].reverse
    end
    
    def attempt( task )
      Dir.chdir(@workdir || Dir.pwd) do
        @statuses << [task, *@current_task.send(task)]
      end
      @errors << status unless latest_okay?
      return latest_okay?
    end
    
    def latest_okay?
      status[1] == 0
    end
    
    def status
      @statuses.last
    end
    
    private
    
    def run( type, task_list )
      task_list.each do |t|
        @current_task = t
        unless attempt type
          fail
          break
        end
      end
    end
    
    def fail
      case status[0]
      when :rollout
        rollback_from @current_task
        raise TransactionError, "Could not rollout task #{@current_task.name}, attempting rollback."
      when :rollback
        raise TransactionError, "Could not rollback task #{@current_task.name}, aborting."
      end
    end
    
  end

end
