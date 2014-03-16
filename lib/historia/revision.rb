
class Historia::Revision
  attr_reader :repo, :revname
  def initialize(repo, revname)
    @repo, @revname = [repo, revname]
  end

  def to_commit
    deref(try_sha || try_full_reference || try_short_branch || try_short_tag)
  end

  private
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
