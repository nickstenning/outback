require 'outback/manager'
require 'outback/task_helper'
require 'outback/task'

module Outback
  
  class Error < RuntimeError; end
  class TransactionError < Error; end
  
end