require 'rubygems'
require 'open4'

module Outback
  class TaskHelper  
    def initialize( manager=nil )
      @manager = manager
    end
    
    def cache
      if @manager and cache = @manager.cache
        cache
      else
        {}
      end
    end
    
    def workdir
      if @manager and workdir = @manager.workdir
        workdir
      else
        Dir.getwd
      end
    end
    
    def sys( command )
      result = {}
      Dir.chdir(workdir) do
        status = Open4.popen4(*command) do |pid, i, o, e|
          result[:stdout] = o.read
          result[:stderr] = e.read
        end
        result[:exit_status] = status.exitstatus
      end
      return result
    end

  end
end
