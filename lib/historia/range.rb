class Historia::Range
  attr_reader :repo, :rangespec

  def initialize repo, rangespec
    @repo, @rangespec = [repo, rangespec]
  end

  def apply_to walker
    commands.each do |command|
      command.call walker
    end
  end

  private
  def commands
    rangespec.split(/\s+/).flat_map do |range_part|
      if (negation = /^\^(.*)$/.match range_part)
        [hide(revision negation[1])]
      elsif (symetric = /^(.*)\.\.(.*)$/.match range_part)
        [hide(revision symetric[1]),
         push(revision symetric[2])]
      else
        [push(revision range_part)]
      end
    end
  end

  def push revision
    Proc.new do |walker|
      walker.push revision.to_sha
    end
  end
  
  def hide revision
    Proc.new do |walker|
      walker.hide revision.to_sha
    end
  end

  def revision revname
    Historia::Revision.new repo, revname
  end
end
