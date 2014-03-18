class Historia::Range
  class Command 
    attr_reader :name
    def initialize name, &block
      @name, @block = [name, block]
    end

    def call(*args)
      @block.call *args
    end
  end

  def self.push revision
    Command.new :push do |walker|
      walker.push revision.to_sha
    end
  end
  
  def self.hide revision
    Command.new :hide do |walker|
      walker.hide revision.to_sha
    end
  end

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
    rangespec.split(/\s+/).map do |range_part|
      if (negation=/^\^(.*)/.match range_part)
        self.class.hide(revision negation[1])
      else
        self.class.push(revision range_part)
      end
    end
  end

    def revision revname
      Historia::Revision.new repo, revname
    end
end
