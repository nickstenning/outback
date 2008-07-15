require 'rubygems'
require 'open4'

module Outback
  
  class ShellTask
  
    attr_accessor :rollout, :rollback, :workdir
    attr_reader :result, :errors, :exit_code
    
    def initialize(out, back)
      @rollout, @rollback = out, back
      @rolled_out = false
    end
    
    def rollout!
      run @rollout
      @rolled_out = true
      return @exit_code == 0
    end
    
    def rollback!
      run @rollback
      @rolled_out = false
      return @exit_code == 0
    end
    
    def rolled_out?
      @rolled_out
    end
        
    def reset_strings
      @result, @errors = "", ""
    end
    
    def run( command )
      reset_strings
      Dir.chdir(@workdir || Dir.getwd) do
        @status = Open4.popen4(*command) do |pid, i, o, e|
          @result = o.read
          @errors = e.read
        end
        @exit_code = @status.exitstatus
      end
    # Catch nonexistent commands at this point and return a sensible error
    rescue Errno::ENOENT => e
      @exit_code = 127
      @errors = e.message
    end
    
  end
  
end