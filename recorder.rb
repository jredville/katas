require 'delegate'
module Recorder
  class Wrapper < SimpleDelegator
    def self.wrap(obj)
      new(obj) unless obj.__proxy?
    end

    def __proxy
      @__proxy ||= Proxy.new(self)
    end

    def __proxy?
      true
    end

    def method_missing(*args, &blk)
      __proxy.record(*args, &blk)
      super
    end
  end

  class Message < Struct.new(:name, :args, :blk)
    def initialize(name, *args, &blk)
      super(name, args, blk)
    end

    def apply(obj)
      obj.send(name, *args, &blk)
    end

    def ==(other)
      other.name == name &&
        other.args == args &&
        other.blk == blk
    end
  end

  class Proxy
    attr_reader :target, :messages
    def initialize(target)
      @target = target
      reset_messages
    end

    def record(*args, &blk)
      @messages << Message.new(*args, &blk)
    end

    def replay
      @messages.map do |m|
        begin
          m.apply(target.__getobj__)
        rescue StandardError => e
          e
        end
      end
    end

    def unwrap
      target.__getobj__
    end

    def wrap(obj)
      target.__setobj__(obj)
    end

    def reset_messages
      @messages = []
    end
  end
end

def Recorder(obj)
  Recorder::Wrapper.wrap(obj)
end

class Object
  def __proxy?
    false
  end
end

require 'minitest/autorun'
require 'ostruct'
class TestClass
  def initialize
    reset
  end

  def name(a, b, &blk)
    [a, blk.call(b)]
  end

  def step1
    @step1 = :called
  end

  def step2(arg)
    if @step1 != :called
      raise 'nope'
    end
    @step2 = arg
  end

  def step3(arg, &blk)
    if @step1 != :called && !@step2 != :called
      raise 'nope'
    end
    @step3 = blk.call(self, arg)
  end

  def step3_blk
    :called
  end

  def reset
    @step1 = @step2 = @step3 = nil
  end

  def completed?
    [@step1, @step2, @step3].all? {|a| a == :called }
  end
end

class NullObject
  def method_missing(*)
    true
  end

  def respond_to_missing?(*)
    true
  end
end

describe "Message" do
  before do
    @blk = lambda {|a| a }
    @obj = Recorder::Message.new(:name, :a, :b, &@blk)
  end

  it 'equals another message with the same args and blk' do
    @obj.must_equal Recorder::Message.new(:name, :a, :b, &@blk)
  end

  it 'can apply itself to an object' do
    obj = TestClass.new
    @obj.apply(obj).must_equal [:a, :b]
  end
end

describe "Recorder" do
  before do
    @target = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
    @obj = Recorder(@target)
  end

  it 'returns true for __proxy? is called' do
    @obj.__proxy?.must_equal true
  end

  it 'proxies methods' do
    @obj.split[0].must_equal @target.split[0]
  end

  it 'unwraps the object' do
    @obj.__proxy.unwrap.must_equal @target
  end

  it 'can wrap a new object' do
    target = Object.new
    @obj.__proxy.wrap(target)
    @obj.__proxy.target.must_equal target
  end

  it 'records messages' do
    @obj.gsub(/[aeiou]/, '<vowel>')
    message = Recorder::Message.new(:gsub, /[aeiou]/, '<vowel>')
    @obj.__proxy.messages.must_equal [message]
  end

  it 'replays messages' do
    t = TestClass.new
    obj = Recorder(t)
    obj.step1
    obj.step2(:called)
    obj.step3(:arg) {|o| o.step3_blk }
    t.reset
    obj.__proxy.replay
    t.completed?.must_equal true
  end

  it 'returns the results of replaying messages' do
    t = TestClass.new
    res = []
    obj = Recorder(t)
    res << obj.step1
    res << obj.step2(:called)
    res << obj.step3(:arg) {|o| o.step3_blk }
    t.reset
    obj.__proxy.replay.must_equal res
  end

  it 'replays messages on a new object' do
    t = TestClass.new
    t2 = NullObject.new
    obj = Recorder(t2)
    obj.step1
    obj.step2(:called)
    obj.step3(:arg) {|o| o.step3_blk }
    obj.__proxy.wrap(t)
    obj.__proxy.replay
    t.completed?.must_equal true
  end
end
