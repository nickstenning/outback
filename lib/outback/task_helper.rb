module Outback
  
  class TaskHelper
    
    def initialize( task )
      @task = task
    end
    
    def sys( *args )
      pid, i, o, e = Open4.popen4(*args)
      o.each_line { |l| @task.stdout.print "[#{pid}] #{l}" }
      e.each_line { |l| @task.stderr.print "E [#{pid}] #{l}" }
    end
    
    def puts( *args )
      @task.stdout.puts *args
    end
    
  end
  
end