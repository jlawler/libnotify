require 'helper'

context Libnotify do
  setup { Libnotify }

  asserts("responds to new").respond_to(:new)
  asserts("responds to show").respond_to(:show)

  asserts("#new calls API#new") do
    mock(Libnotify::API).new(hash_including(:body => "test"))
    Libnotify.new(:body => "test")
    RR.verify
  end
  asserts("#show calls API#show") do
    mock(Libnotify::API).show(hash_including(:body => "test"))
    Libnotify.show(:body => "test")
    RR.verify
  end
end

context Libnotify::API do
  setup { Libnotify::API }

  context "without options and block" do
    setup { topic.new }

    asserts("summary is whitspaced") { topic.summary }.equals(" ")
    asserts("body is whitspaced") { topic.body }.equals(" ")
    asserts("urgency is :normal") { topic.urgency }.equals(:normal)
    asserts("timeout is nil") { topic.timeout }.nil
    asserts("icon_path is nil") { topic.icon_path }.nil
  end

  context "with options and block" do
    setup do
      topic.new(:summary => "hello", :body => "body", :invalid_option => 23) do |n|
        n.body = "overwritten"
        n.icon_path = "/path/to/icon"
      end
    end

    asserts("summary is set") { topic.summary }.equals("hello")
    asserts("body was overwritten by block") { topic.body }.equals("overwritten")
    asserts("icon_path set") { topic.icon_path }.equals("/path/to/icon")
  end

  context "timeout=" do
    setup { topic.new }

    asserts("with float") { topic.timeout = 2.5; topic.timeout }.equals(2500)
    asserts("with fixnum ms") { topic.timeout = 100; topic.timeout }.equals(100)
    asserts("with fixnum ms") { topic.timeout = 101; topic.timeout }.equals(101)
    asserts("with fixnum seconds") { topic.timeout = 1; topic.timeout }.equals(1000)
    asserts("with fixnum seconds") { topic.timeout = 99; topic.timeout }.equals(99000)
    asserts("with nil") { topic.timeout = nil; topic.timeout }.nil
    asserts("with false") { topic.timeout = false; topic.timeout }.nil
    asserts("with to_s.to_i") { topic.timeout = :"2 seconds"; topic.timeout }.equals(2)
  end

  # TODO mock this!
  context "show!" do
    setup { topic.new(:timeout => 1.0, :icon_path => "/usr/share/icons/gnome/scalable/emblems/emblem-default.svg") }

    [ :low, :normal, :critical ].each do |urgency|
      asserts("with urgency #{urgency}") do
        topic.summary = "#{RUBY_VERSION} at #{RUBY_PLATFORM}"
        topic.body = defined?(RUBY_DESCRIPTION) ? RUBY_DESCRIPTION : '?'
        topic.urgency = urgency; topic.show!
      end
    end
  end
end
