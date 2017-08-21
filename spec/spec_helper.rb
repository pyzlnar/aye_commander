# NOTE Coverage must be required and initialized before anything else
require 'simplecov'
SimpleCov.start do
  add_filter 'spec/'
end

require 'pry'
require 'aye_commander'

# Shared context for command tests
shared_context :command do
  let(:command) do
    Class.new do
      include AyeCommander::Command
      define_method(:call) {}
    end
  end

  let(:commandsc)    { command.singleton_class }
  let(:instance)     { command.new }
  let(:result)       { command.result_class.new }
  let(:result_class) { command.result_class }

  let(:inheriter) { Class.new(command) }
  let(:includer)  { Module.new.send(:include, AyeCommander::Command) }
  let(:includer2) { Module.new.send(:include, includer) }
end

# Shared context for commander tests
shared_context :commander do
  let(:command) do
    Class.new do
      include AyeCommander::Command
      define_method(:call) {}
    end
  end

  let(:commander) { Class.new.send(:include, AyeCommander::Commander) }
  let(:instance)  { commander.new }
  let(:commandi)  { command.new }

  let(:includer)  { Module.new.send(:include, AyeCommander::Commander) }
  let(:includer2) { Module.new.send(:include, includer) }
  let(:inheriter) { Class.new(commander) }
end
