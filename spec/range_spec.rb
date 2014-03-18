require 'spec_helper'

describe Historia::Range do
  let (:walker) { mock }
  let (:repo) { Rugged::Repository.new 'spec/support/fixtures/house' }
  let (:commit) { repo.head.target }
  

  context "parse" do
    it "a single sha becomes a single push" do
      range = Historia::Range.new repo, "af95734"

      walker.should_receive(:push).with "af95734f23943f2829692b45be7fa7abe3e906db" 

      range.apply_to walker
    end

    it "a single negated sha becomes a single hide" do
      range = Historia::Range.new repo, "^5b2691f"

      walker.should_receive(:hide).with "5b2691f3cf7a544dcff3463ff0ce34204aa2dba0" 

      range.apply_to walker
    end

    it "several shas become several pushes" do
      range = Historia::Range.new repo, "af95734 5b2691f"

      walker.should_receive(:push).with "af95734f23943f2829692b45be7fa7abe3e906db"
      walker.should_receive(:push).with "5b2691f3cf7a544dcff3463ff0ce34204aa2dba0"
      range.apply_to walker
    end

    it "parses a mix of pushes and hides" do
      range = Historia::Range.new repo, "af95734 ^5b2691f"

      walker.should_receive(:push).with "af95734f23943f2829692b45be7fa7abe3e906db"
      walker.should_receive(:hide).with "5b2691f3cf7a544dcff3463ff0ce34204aa2dba0"

      range.apply_to walker
    end

  end
end

