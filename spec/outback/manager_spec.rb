require File.dirname(__FILE__) + '/../spec_helper'

describe Outback::Manager do
  
  before do
    @obm = Outback::Manager.new
    @task1 = mock("task1", :name => "Task 1") 
    @task2 = mock("task2", :name => "Task 2")
  end
  
  describe "(empty)" do
    
    it "should have a list of tasks" do
      @obm.tasks.should be_a_kind_of(Enumerable)
      @obm.should have(0).tasks
    end
    
    it "should have a rollout method" do
      @obm.should respond_to(:rollout)
    end
    
    it "should have a rollback method" do
      @obm.should respond_to(:rollback)
    end
    
    it "should add tasks to its list with standard array operations" do
      @obm.should have(0).tasks
      @obm.tasks << @task1
      @obm.should have(1).tasks
      @obm.tasks << @task2
      @obm.should have(2).tasks
    end
    
  end
  
  describe "(with a few tasks)" do
    
    before do
      @obm.tasks << @task1 << @task2
    end
    
    it "should call each task's rollout method on rollout (in order)" do
      @task1.should_receive(:rollout).and_return(0)
      @task2.should_receive(:rollout).and_return(0)
      @obm.rollout
    end
    
    it "should call each task's rollback method on rollback (in reverse order)" do
      @task2.should_receive(:rollback).and_return(0)
      @task1.should_receive(:rollback).and_return(0)
      @obm.rollback
    end
    
    it "should raise an Outback::Error if a rollout fails" do
      @task1.stub!(:rollback)
      @task1.should_receive(:rollout).and_return(1)
      @task2.should_not_receive(:rollout)
      lambda { @obm.rollout }.should raise_error(Outback::Error)
    end
    
    it "should raise an Outback::Error if a rollback fails" do
      @task2.should_receive(:rollback).and_return(1)
      @task1.should_not_receive(:rollback)
      lambda { @obm.rollback }.should raise_error(Outback::Error)
    end
    
    it "should store the latest task's run direction (rollout, rollback), return code, stdout and stderr in #status" do
      @task1.should_receive(:rollout).and_return([0, "A message", ""])
      @task2.should_receive(:rollout).and_return([0, "Another message", ""])
      @obm.rollout
      @obm.status.should == [:rollout, 0, "Another message", ""]
    end
    
    it "should store the latest task's status even if an earlier task raised an error." do
      @task1.stub!(:rollback).and_return([0, "Getting rolled back", ""])
      @task1.should_receive(:rollout).and_return([1, "", "Error message"])
      @task2.should_not_receive(:rollout)
      begin 
        @obm.rollout
      rescue Outback::Error
        @obm.status.should == [:rollback, 0, "Getting rolled back", ""]
      end
    end
    
    it "should store any status messages with non-zero return codes in #errors" do
      @task1.should_receive(:rollout).and_return([0, "All okay", ""])
      @task2.should_receive(:rollout).and_return([1, "", "Error message"])
      @task2.should_receive(:rollback).and_return([0, "Getting rolled back", ""])
      @task1.should_receive(:rollback).and_return([3, "", "Error while rolling back"])
      begin
        @obm.rollout
      rescue Outback::Error
        @obm.should have(2).errors
        @obm.errors.shift.should == [:rollout, 1, "", "Error message"]
        @obm.errors.shift.should == [:rollback, 3, "", "Error while rolling back"]    
      end
    end
    
    it "should rollback previously rolled-out tasks if a rollout fails" do
      @task1.should_receive(:rollout).ordered.and_return([1, "", "Error message"])
      @task2.should_not_receive(:rollout)
      @task1.should_receive(:rollback).ordered
      @task2.should_not_receive(:rollback)
      begin 
        @obm.rollout
      rescue Outback::Error
      end
    end
  end
  
  describe "(with #workdir set)" do
    
    it "should execute all tasks in the workdir" do
      @obm.tasks << Outback::ShellTask.new('pwd', 'pwd')
      @obm.workdir = '/tmp'
      @obm.rollout
      @obm.status[2] == "/tmp"
    end
    
  end
end