require 'stringio'

require 'rubygems'
require 'open4'

module Outback
  
  class Task
  
    attr_reader :name
    attr_accessor :stdout, :stderr
    
    def initialize
      @rollout, @rollback = lambda {}
      @stdout = StringIO.new
      @stderr = StringIO.new
    end
    
    def rollout( &block )
      if block_given?
        @rollout = block
      else
        run @rollout
      end
    end

    def rollback( &block )
      if block_given?
        @rollback = block
      else
        run @rollback
      end
    end
    
  private
    
    def run( proc )
      proc.call(TaskHelper.new(self))
      [0, stdout.string, stderr.string]
    rescue SystemCallError => err
      [1, stdout.string, stderr.string]
    end

  end
  
    
  class ShellTask < Task
    
    attr_reader :rollout_command, :rollback_command
    
    def initialize(rollout, rollback)
      super()
      @rollout = lambda { |t| t.sys rollout }
      @rollout_command = rollout
      @rollback = lambda { |t| t.sys rollback }
      @rollback_command = rollback
    end
    
  end
  
end