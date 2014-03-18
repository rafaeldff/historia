
class Historia::Revision
  attr_reader :repo, :revname
  def initialize(repo, revname)
    @repo, @revname = [repo, revname]
  end

  def to_commit
    reference = try_numbered || try_parent || try_sha || try_full_reference || try_short_branch || try_short_tag
    deref(reference)
  end

  def to_sha
    to_commit.oid
  end

  private
  def try_numbered
    if (m = /^([^~]+)~([0-9]+)$/.match revname)
      child = self.class.new(repo, m[1]).to_commit
      parents = m[2].to_i
      get_ancestor child, parents
    end
  rescue
    nil
  end

  def try_parent
    if (m = /^([^^]+)(\^+)$/.match revname)
      child = self.class.new(repo, m[1]).to_commit
      parents = m[2].size
      get_ancestor child, parents
    end
  rescue
    nil
  end

  def get_ancestor child, parents
    return child if parents == 0
    return nil if child.parents.empty?
    get_ancestor child.parents.first, parents - 1
  end

  def try_sha
    repo.lookup(revname) rescue nil
  end

  def try_full_reference
    repo.references[revname] rescue nil
  end
  
  def try_short_branch
    repo.branches[revname] rescue nil
  end

  def try_short_tag
    repo.references["refs/tags/#{revname}"] rescue nil
  end

  def deref obj
    if obj.is_a? Rugged::Commit
      return obj
    elsif obj.respond_to? :target
      deref obj.target
    else
      nil
    end
  end
end
