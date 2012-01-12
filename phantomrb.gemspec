# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
Gem::Specification.new do |s|
  s.name        = "phantomrb"
  s.version     = "0.1.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Orange Mug"]
  #s.email       = ["example@example.com"]
  s.homepage    = "http://github.com/completelynovel/phantomrb"
  s.summary     = "PhantomRb is a simple interface with phantomjs for Ruby"
  s.description = "PhantomRb is a simple interface with phantomjs for Ruby"
 
  s.required_rubygems_version = ">= 1.3.6"
  #s.rubyforge_project         = "example"
 
  # No tests yet
  #s.add_development_dependency "rspec"
 
  s.files        = Dir.glob("{lib}/**/*") + %w(README.md)
  s.require_path = 'lib'
end