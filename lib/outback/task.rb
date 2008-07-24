module Outback
  class Task
    def initialize
      @rollback = proc {}
      @rollout  = proc {}
      if block_given?
        yield self
      end
    end
    
    def rollout( &block )
      if block_given?
        @rollout = block
      else
        @rollout
      end
    end
    
    def rollback( &block )
      if block_given?
        @rollback = block
      else
        @rollback
      end
    end
    
    def rollout!( task_helper = nil )
      @rollout.call(task_helper)
    end
    
    def rollback!( task_helper = nil )
      @rollback.call(task_helper)
    end
  end
end
