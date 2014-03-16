require 'spec_helper.rb'

describe Historia::Revision do
  let (:repo) { Rugged::Repository.new 'spec/support/fixtures/simple' }

  describe :to_commit do
    context :shas do
      it "locates the commit from a given sha" do
        Historia::Revision.new(repo, '90924db0e05ae2bc9274c789942b470c300b6489').to_commit.should eq repo.head.target
      end

      it "locates the commit from a shortened sha" do
        Historia::Revision.new(repo, '90924db0').to_commit.should eq repo.head.target
      end
    end

    context :references do
      it "locates the master branch by the full reference path" do
        Historia::Revision.new(repo, 'refs/heads/master').to_commit.should eq repo.head.target
      end

      it "locates the master branch by the local branch name" do
        Historia::Revision.new(repo, 'master').to_commit.should eq repo.head.target
      end

      it "locates a tag by the full reference path" do
        Historia::Revision.new(repo, 'refs/tags/v1').to_commit.should eq repo.head.target
      end

      it "locates a tag by the short name" do
        Historia::Revision.new(repo, 'v1').to_commit.should eq repo.head.target
      end
    end
  end
end
