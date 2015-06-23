$:.push File.expand_path("../lib", __FILE__)
require "knife-rackspace-database/version"

Gem::Specification.new do |s|
  s.name = "knife-rackspace-database"
  s.version = Knife::RackspaceDatabase::VERSION
  s.authors = ["Tom Alexandrowicz"]
  s.email = "talexand@thoughtworks.com"
  s.summary = "Rackspace cloud database support for knife"
  s.description = "A gem to extend knife-rackspace allowing cloud database management."
  s.homepage = "https://github.com/tlalexan/knife-rackspace-database"
  s.licenses = ["Apache"]
  s.files = `git ls-files`.split("\n")
  s.add_dependency "chef", ">= 0.10.8"
  s.add_dependency "knife-rackspace", "~> 0.10.0"
  s.add_dependency "fog", "~> 1.18"
  s.require_paths = ["lib"]
end
