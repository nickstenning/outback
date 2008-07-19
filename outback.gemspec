Gem::Specification.new do |s|
  s.name = %q{outback}
  s.version = "0.0.3"
 
  s.specification_version = 2 if s.respond_to? :specification_version=
 
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nick Stenning"]
  s.date = %q{2008-07-14}
  s.email = ["nick@whiteink.com"]
  s.files = ["lib/outback/manager.rb", "lib/outback/shelltask.rb", "lib/outback/yaml.rb", "lib/outback.rb", "outback.gemspec", "spec/outback/manager_spec.rb", "spec/outback/shelltask_spec.rb", "spec/outback/yaml_spec.rb", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/nickstenning/outback}
  s.require_paths = ["lib"]
  s.summary = %q{Run pairs of rollout/rollback tasks in a transactional manner.}
  s.description = %{Run pairs of rollout/rollback tasks in a transactional manner.}
 
  s.add_dependency("open4", [">= 0.9.0"])
end
