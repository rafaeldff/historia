require 'spec_helper'

describe Historia::Range do
  let (:walker) { mock }

  attr_reader :repo
  attr_reader :head_left
  attr_reader :head_right
  attr_reader :common
  
  before (:all) {
    @repo = init "house" 

    common_0 = commit @repo
    @common = commit @repo, common_0

    @head_left  = commit @repo, @common
    repo.branches.create('l', @head_left)
    
    @head_right = commit @repo, @common
    repo.branches.create('r', @head_right)
  } 

  context "parse" do
    it "a single sha becomes a single push" do
      range = Historia::Range.new repo, (short head_left)

      walker.should_receive(:push).with head_left

      range.apply_to walker
    end

    it "a single negated sha becomes a single hide" do
      range = Historia::Range.new repo, "^#{short head_right}"

      walker.should_receive(:hide).with head_right 

      range.apply_to walker
    end

    it "several shas become several pushes" do
      range = Historia::Range.new repo, "#{short head_left} #{short head_right}"

      walker.should_receive(:push).with head_left
      walker.should_receive(:push).with head_right
      range.apply_to walker
    end

    it "parses a mix of pushes and hides" do
      range = Historia::Range.new repo, "#{short head_left} ^#{short head_right}"

      walker.should_receive(:push).with head_left
      walker.should_receive(:hide).with head_right

      range.apply_to walker
    end

    it "understands a range given by two dots" do
      range = Historia::Range.new repo, "#{short common}..#{short head_right}"

      walker.should_receive(:hide).with common
      walker.should_receive(:push).with head_right

      range.apply_to walker
    end


    it "understands a range given by three dots" do
      range = Historia::Range.new repo, "#{short head_left}...#{short head_right}"

      walker.should_receive(:hide).with common
      walker.should_receive(:push).with head_left
      walker.should_receive(:push).with head_right

      range.apply_to walker
    end

    it "understands a range given by three dots, using branch names" do
      range = Historia::Range.new repo, "l...r"

      walker.should_receive(:hide).with common
      walker.should_receive(:push).with head_left
      walker.should_receive(:push).with head_right

      range.apply_to walker
    end
  end
end

