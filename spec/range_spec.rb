require 'spec_helper'

describe Historia::Range do
  let (:repo) { Rugged::Repository.new 'spec/support/fixtures/simple' }
  let (:commit) { repo.head.target }
  
  context "commands" do
    let (:revision) { stub(:to_sha => "sha") }

    it "push command pushes the revision's commit to the walker" do
      command = Historia::Range.push(revision)
      command.name.should == :push

      walker = mock
      walker.should_receive(:push).with "sha"

      command.call(walker)
    end

    it "hide command hides the commit for the given revision on the walker" do
      command = Historia::Range.hide(revision)
      command.name.should == :hide

      walker = mock
      walker.should_receive(:hide).with "sha"

      command.call(walker)
    end
  end

  context "parse" do
    it "a single sha becomes a single push" do
      range = Historia::Range.new repo, "90924db0"
      walker = mock

      walker.should_receive(:push).with "90924db0e05ae2bc9274c789942b470c300b6489" 

      range.apply_to walker
    end

    it "several shas become several pushes" do
      range = Historia::Range.new repo, "90924db0 54d4c97dc"
      walker = mock

      walker.should_receive(:push).with "54d4c97dcd9146df328c1a18afadca31e7b47bed" 
      range.apply_to walker
    end
  end
end

