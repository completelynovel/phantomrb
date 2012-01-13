$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'phantomrb'

script = PhantomRb.new("hello_world.coffee")
ret = script.run({
  :message => "Hello Javascript"
})
puts ret.data.message