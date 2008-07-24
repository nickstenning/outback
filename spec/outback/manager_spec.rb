require File.dirname(__FILE__) + '/../spec_helper'
require 'yaml'

describe Outback::Manager do
  
  before do
    @obm = Outback::Manager.new
    @task1 = mock(:task1, :null_object => true)
    @task2 = mock(:task2, :null_object => true)
    @task3 = mock(:task3, :null_object => true)
  end

  it "should have a list of tasks" do
    @obm.tasks.should be_a_kind_of(Enumerable)
    @obm.should have(0).tasks
  end
  
  it "should add a task to its list with #add_task" do
    @obm.add_task(@task1)
    @obm.should have(1).tasks
    @obm.add_task(@task2)
    @obm.should have(2).tasks
  end
  
  it "should add a new Outback::Task and add it if #add_task is called with a block" do
    @obm.add_task do
    end
    @obm.should have(1).tasks
  end
  
  it "should add multiple tasks to its list, in order, with #add_tasks" do
    @obm.add_tasks(@task1, @task2, @task3)
    @obm.should have(3).tasks
    @obm.tasks[0].should == @task1
    @obm.tasks[1].should == @task2
    @obm.tasks[2].should == @task3
  end
  
  it "should give a hash representing its state on #state" do
    @obm.state[:position].should == 0
    @obm.state[:direction].should == 1
  end
  
  it "should restore its state when passed in a state hash on #restore_state" do
    @obm.restore_state({:position => 3, :direction => -1})
    @obm.position.should == 3
    @obm.direction.should == -1
  end
  
  it "should update its cache with #cache=" do
    @obm.cache = {:foo => "bar"}
    @obm.cache[:foo].should == "bar"
  end
  
  describe "(with a few tasks)" do
    
    before do
      @obm.add_tasks(@task1, @task2)
    end
    
    it "should, by default, be rolling out" do
      @obm.direction.should == Outback::Manager::ROLLOUT
    end
    
    it "should start at the first task" do
      @obm.position.should == 0
    end
    
    it "should report the tasks it will run in any given state with #tasks_to_run" do
      @obm.add_task(@task3)
      @obm.tasks_to_run.should == [@task1, @task2, @task3]
      @obm.direction = -1
      @obm.tasks_to_run.should be_empty
      @obm.position = 3
      @obm.tasks_to_run.should == [@task3, @task2, @task1]
      @obm.position = 2
      @obm.tasks_to_run.should == [@task2, @task1]
      @obm.direction = 1
      @obm.tasks_to_run.should == [@task3]
    end
        
    it "should call each task's #rollout! method, in order, on #rollout!" do
      @task1.should_receive(:rollout!)
      @task2.should_receive(:rollout!)
      @obm.rollout!.should == [@task1, @task2]
    end
    
    it "should not roll back any tasks if it isn't already rolled out" do
      @task1.should_not_receive(:rollback!)
      @task2.should_not_receive(:rollback!)
      @obm.rollback!.should be_empty
    end
    
    it "should halt the rollout if any task's #rollout! method throws an error, and put the error in the cache" do
      @error_task = mock(:error_task, :null_object => true)
      @error_task.should_receive(:rollout!).and_raise("Just some runtime error.")
      @obm.add_tasks(@error_task, @task2)
      @obm.rollout!.should_not be_true
      @obm.cache.should have(1).error
      @obm.tasks_to_run.should == [@error_task, @task2]
    end
    
    it "should clear the cache errors before every rollout or rollback" do
      @obm.cache[:errors] = "I'm an error."
      @obm.rollout!
      @obm.cache[:errors].should be_nil
      @obm.cache[:errors] = "I'm an error."
      @obm.rollback!
      @obm.cache[:errors].should be_nil
    end
      
    
    it "should run each task in a transactional manner, so changes to the cache that are followed by an error are reversed" do
      @error_task = Outback::Task.new do |t|
        t.rollout do |m|
          m.cache[:result] = "Foo"
          raise "Some cockup!"
        end
      end
      
      @obm.add_tasks(@error_task, @task2)
      @obm.rollout!.should_not be_true
      @obm.cache[:result].should be_nil
    end
         
    it "should call each task's #rollback! method, in reverse order, on #rollback!, provided it's already rolled out" do
      @obm.position = 2
      @task2.should_receive(:rollback!)
      @task1.should_receive(:rollback!)
      @obm.rollback!.should == [@task2, @task1]
    end
    
    it "should not roll out any tasks if it isn't already rolled back" do
      @obm.position = 2
      @task1.should_not_receive(:rollout!)
      @task2.should_not_receive(:rollout!)
      @obm.rollout!.should be_empty
    end
    
    it "should pass an instance of TaskHelper into tasks' #rollout! and #rollback! methods" do
      th = @obm.task_helper
      @task1.should_receive(:rollout!).with(th)
      @obm.rollout!
    end
    
  end
  
  describe "(with observers)" do
    
    before do
      @obm.add_tasks(@task1, @task2)

      @watcher = mock(:watcher)
      @watcher.stub!(:update)

      @obm.add_observer(@watcher)   
    end
    
    it "should call the watcher's #update method after each rollout or rollback with a state hash and the results cache as parameters." do
      @watcher.should_receive(:update).ordered.with({:position => 1, :direction => 1}, {})
      @watcher.should_receive(:update).ordered.with({:position => 2, :direction => 1}, {})
      @watcher.should_receive(:update).ordered.with({:position => 1, :direction => -1}, {})
      @watcher.should_receive(:update).ordered.with({:position => 0, :direction => -1}, {})
      @obm.rollout!
      @obm.rollback!
    end
    
  end
end