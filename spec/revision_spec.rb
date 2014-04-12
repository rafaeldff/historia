require 'spec_helper.rb'
require 'fileutils'

describe Historia::Revision do
  @repo, @first_sha, @first_short, @second_sha, @second_short = [nil, nil, nil, nil, nil]
  let (:repo_dir)  { 'spec/support/fixtures/a' }
  attr_reader :repo
  attr_reader :first_sha
  attr_reader :first_sha
  attr_reader :second_sha
  attr_reader :second_short

  def init repo
    repo_dir = "spec/support/fixtures/#{repo}"

    FileUtils.rm_rf repo_dir
    FileUtils.mkdir_p repo_dir
    Rugged::Repository.init_at repo_dir
  end

  def commit repo, *parents
    oid = repo.write("x", :blob)
    index = Rugged::Index.new.tap{|index| index.add path: "f", oid: oid, mode:  0100644}

    Rugged::Commit.create(repo,  {message: "message",
                                  update_ref: 'HEAD',
                                  tree: index.write_tree(repo),
                                  parents: parents})
  end

  before (:all) {
    @repo = init "a" 

    @first_sha = commit @repo
    @first_short = @first_sha[0..6]

    @second_sha = commit @repo, @first_sha
    @second_short = @second_sha[0..6]

    repo.tags.create('v1', repo.head.target, {message: 'msg'})
  }

  describe :to_commit do
    context :shas do
      it "locates the commit from a given sha" do
        Historia::Revision.new(repo, second_sha).to_commit.should eq repo.head.target
      end

      it "locates the commit from a shortened sha" do
        Historia::Revision.new(repo, second_short).to_commit.should eq repo.head.target
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

    context :relative_references do
      it "locates a reference relative to the parent" do
        Historia::Revision.new(repo, "#{second_short}^").to_commit.should eq repo.head.target.parents.first
        Historia::Revision.new(repo, "#{second_short}^^").to_commit.should eq repo.head.target.parents.first.parents.first
      end

      it "locates a numbered relative reference" do
        Historia::Revision.new(repo, "#{second_short}~1").to_commit.should eq repo.head.target.parents.first
        Historia::Revision.new(repo, "#{second_short}~2").to_commit.should eq repo.head.target.parents.first.parents.first
      end
    end
  end

  describe :to_sha do
    it "returns the sha corresponding to the located commit" do
        Historia::Revision.new(repo, second_short).to_sha.should eq repo.head.target_id
        Historia::Revision.new(repo, 'master').to_sha.should eq repo.head.target_id
    end
  end
end
