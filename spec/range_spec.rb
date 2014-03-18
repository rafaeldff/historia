require 'spec_helper'

describe Historia::Range do
  let (:walker) { mock }
  let (:repo) { Rugged::Repository.new 'spec/support/fixtures/simple' }
  let (:commit) { repo.head.target }
  
  context "parse" do
    it "a single sha becomes a single push" do
      range = Historia::Range.new repo, "90924db0"

      walker.should_receive(:push).with "90924db0e05ae2bc9274c789942b470c300b6489" 

      range.apply_to walker
    end

    it "a single negated sha becomes a single hide" do
      range = Historia::Range.new repo, "^54d4c97dc"

      walker.should_receive(:hide).with "54d4c97dcd9146df328c1a18afadca31e7b47bed" 

      range.apply_to walker
    end

    it "several shas become several pushes" do
      range = Historia::Range.new repo, "90924db0 54d4c97dc"

      walker.should_receive(:push).with "90924db0e05ae2bc9274c789942b470c300b6489"
      walker.should_receive(:push).with "54d4c97dcd9146df328c1a18afadca31e7b47bed"
      range.apply_to walker
    end

    it "parses a mix of pushes and hides" do
      range = Historia::Range.new repo, "90924db0 ^54d4c97dc"

      walker.should_receive(:push).with "90924db0e05ae2bc9274c789942b470c300b6489"
      walker.should_receive(:hide).with "54d4c97dcd9146df328c1a18afadca31e7b47bed"

      range.apply_to walker
    end
  end
end

