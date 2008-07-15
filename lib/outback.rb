require 'outback/manager'
require 'outback/shelltask'
require 'outback/yaml'

module Outback
  
  class Error < RuntimeError; end
  class TransactionError < Error; end
  
end