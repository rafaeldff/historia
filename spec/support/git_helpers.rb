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
