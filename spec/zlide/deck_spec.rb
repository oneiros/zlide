require "spec_helper"

describe Zlide::Deck do

  describe "deck initialization" do

    it "should look for .md files in a slides folder" do
      Dir.should_receive(:glob).with('slides/*.md').and_return([])
      Zlide::Deck.new
    end

    it "should read file contents from .md files" do
      Dir.stub(:glob).and_return(["test1", "test2"])
      File.should_receive(:read).with("test1").and_return("!SLIDE\n# test1")
      File.should_receive(:read).with("test2").and_return("!SLIDE\n# test2")
      Zlide::Deck.new
    end

  end

  describe "output rendering" do

    it "should produce html from markdown" do
      Dir.stub(:glob).and_return(["test1"])
      File.stub(:read).and_return("!SLIDE\n# Test")
      deck = Zlide::Deck.new
      File.unstub(:read)
      deck.to_html.should match(/<h1>Test<\/h1>/)
    end

  end
end
