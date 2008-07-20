module Outback
  class Runner
    attr_reader :manager
    attr_writer :logger
    
    def initialize( yaml_file )
      @manager = YAML.load_file( yaml_file )
      @manager.watcher = self
    end
    
    def rollout!
      @manager.rollout!
    end
    
    def rollback!
      @manager.rollback!
    end
    
    def notify( task )
      puts details_for( task )
      @logger.info details_for( task ) if @logger 
    end
    
    def details_for( task )
      "#{@manager.position + 1}/#{@manager.tasks.length}: #{task.result.strip}"
    end
  end
end