require 'outback/manager'
require 'outback/shelltask'
require 'outback/yaml'
require 'outback/runner'

module Outback
  
  class Error < RuntimeError; end
  class TransactionError < Error; end
  class DuplicateNamedTaskError < Error; end
  
end