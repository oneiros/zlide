require "spec_helper"

describe Zlide::Redcarpet::Renderers::Array do

  describe "parsing a deck of two slides" do
    let(:markdown) { File.read(File.expand_path("../2slides.md", __FILE__)) }
    let(:renderer) { Zlide::Redcarpet::Renderers::Array.new }

    before(:each) do
      Redcarpet::Markdown.new(renderer, fenced_code_blocks: true, tables: true).render(markdown)
    end

    it "should return two pages" do
      renderer.slides.size.should == 2
    end

    it "should have only one elment on page 1" do
      renderer.slides.first.size.should == 1
    end

    it "should have a headline on page 1" do
      renderer.slides.first.first[:type].should == :headline
    end

    it "should have three elements on page 2" do
      renderer.slides[1].size.should == 3
    end

    it "should have an unordered list on page 2" do
      renderer.slides[1].select{|e| e[:type] == :unordered_list}.size.should == 1
    end

    it "should have three items in the list on page 2" do
      renderer.slides[1].select{|e| e[:type] == :unordered_list}.first[:items].size.should == 3
    end

  end

end
