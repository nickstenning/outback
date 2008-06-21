module Outback
  
  class Command
    
    def initialize( script )
      @manager = Manager.new
      parse(script)
    end
    
    def parse( script )
      script.each_line do |l|
        out, back = l[/^([^\^]+)\s*\^\s*(.+)$/]
        p "o:", out, "b:", back
        if out and back
          p out, back
          t = Task.new("temp")
          t.rollout { |t| t.sys out }
          t.rollback { |t| t.sys back }
          @manager.tasks << t
        end
      end
    end
    
    def run( command )
      raise %{Command "#{command}" not understood.} unless [:rollout, :rollback].include? command
      
      #@manager.tasks.each 
      #@manager.send(command)
    end
    
  end
  
end