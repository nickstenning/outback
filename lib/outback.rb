require 'outback/manager'
require 'outback/task_helper'
require 'outback/task'
require 'outback/command'
require 'outback/yaml'

module Outback
  
  class Error < RuntimeError; end
  class TransactionError < Error; end
  
end