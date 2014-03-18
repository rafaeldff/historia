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
    shas = @rangespec.split /\s+/
    shas.map do |sha|
      revision = Historia::Revision.new repo, sha
      self.class.push(revision)
    end
  end
end
