$: << File.expand_path(File.dirname(__FILE__) + '/../../lib')
require 'outback'

include Outback

if $0 == __FILE__

  @man = Manager.new

  @man.add_task do |t|
    t.rollout do |m|
      m.cache[:result] = 1
    end
    t.rollback do |m|
      m.cache.delete(:result)
    end
  end

  @man.add_task do |t|
    t.rollout do |m|
      m.cache[:result] += 2
    end
    t.rollback do |m|
      m.cache[:result] -= 2
    end
  end

  @man.add_task do |t|
    t.rollout do |m|
      m.cache[:number_three] = m.cache[:result]
    end
    t.rollback do |m|
      m.cache.delete(:number_three)
    end
  end

  @man.add_task do |t|
    t.rollout do |m|
      m.cache[:b0rk] = "hello"
    end
    t.rollback do |m|
      m.cache.delete(:b0rk)
    end
  end
  
  @man.add_task do |t|
    t.rollout do |m|
      m.cache[:syscall] = m.sys("pwd")[:stdout].strip
    end
    t.rollback do |m|
      m.cache.delete(:syscall)
    end
  end
  
  @man.rollout!
  y @man.cache
  @man.rollback!
  y @man.cache
  

end