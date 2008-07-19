require File.dirname(__FILE__) + '/../spec_helper'
require 'yaml'

describe Outback::Manager do
  
  before do
    @obm = Outback::Manager.new
    @task1 = mock("task1", :workdir => "/tmp", :name => "task1", :null_object => true)
    @task2 = mock("task2", :workdir => nil, :name => nil, :null_object => true)
    @task3 = mock("task3", :workdir => nil, :name => "task3", :null_object => true)
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
  
  it "should add multiple tasks to its list, in order, with #add_tasks" do
    @obm.add_tasks(@task1, @task2, @task3)
    @obm.should have(3).tasks
    @obm.tasks[0].should == @task1
    @obm.tasks[1].should == @task2
    @obm.tasks[2].should == @task3
  end
  
  it "should not allow more than one task with the same name" do
    lambda { @obm.add_tasks(@task1, @task1) }.should raise_error(Outback::DuplicateNamedTaskError)
    lambda { @obm.add_tasks(@task1, @task2, @task1) }.should raise_error(Outback::DuplicateNamedTaskError)
    lambda { @obm.add_tasks(@task1, @task3, @task3) }.should raise_error(Outback::DuplicateNamedTaskError)
  end
  
  it "should allow the same task twice if unnamed" do
    lambda { @obm.add_tasks(@task1, @task2, @task2) }.should_not raise_error
  end
  
  it "should return the named task with #find_task(name)" do
    @obm.add_tasks(@task1, @task2, @task3)
    @obm.find_task('task1').should == @task1
    @obm.find_task('task3').should == @task3
  end
  
  describe "(with a few tasks)" do
    
    before do
      @obm.add_tasks(@task1, @task2)
    end
    
    it "should call each task's #rollout! method, in order, on #rollout!" do
      @task1.should_receive(:rollout!).and_return(true)
      @task2.should_receive(:rollout!).and_return(true)
      @obm.rollout!
    end
    
    it "should call each task's #rollback! method, in reverse order, on #rollback!" do
      @task1.should_receive(:rollout!).and_return(true)
      @task2.should_receive(:rollout!).and_return(true)
      @obm.rollout!
    end
    
    it "should raise an Outback::Error if a rollout fails" do
      @task1.stub!(:rollback!)
      @task1.should_receive(:rollout!).and_return(false)
      @task2.should_not_receive(:rollout!)
      @task2.should_not_receive(:rollback!)
      lambda { @obm.rollout! }.should raise_error(Outback::Error)
    end
    
    it "should raise an Outback::TransactionError if a rollback subsequently fails" do
      @task2.should_receive(:rollback!).and_return(false)
      @task1.should_not_receive(:rollback!)
      lambda { @obm.rollback! }.should raise_error(Outback::TransactionError)
    end
    
  end
  
  describe "(with #workdir set)" do
    
    before do
      @task1 = Outback::ShellTask.new("", "")
      @task1.workdir = "/tmp"
      @task2 = Outback::ShellTask.new("", "")
      @obm.workdir = "/nonexistent"
      @obm.add_tasks(@task1, @task2)
    end
    
    it "should set the workdir of each of its tasks if it is currently nil" do
      @task1.workdir.should == "/tmp"
      @task2.workdir.should == "/nonexistent"
    end
    
  end
  
  describe "(with #watcher set)" do
    
    before do
      @task1 = Outback::ShellTask.new("pwd", "")
      @task2 = Outback::ShellTask.new("echo 'hello'", "")
      require 'tempfile'
      @obm.workdir = Dir.tmpdir
      @obm.add_tasks(@task1, @task2)
      @watcher = mock("watcher")
      @obm.watcher = @watcher
    end
    
    it "should call the watcher's #notify method after every task rollout/rollback with the task as an argument" do
      @watcher.should_receive(:notify).ordered.with(@task1)
      @watcher.should_receive(:notify).ordered.with(@task2)
      @obm.rollout!
    end
    
  end
end