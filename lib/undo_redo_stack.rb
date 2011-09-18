require File.expand_path('stack', File.dirname(__FILE__))
class UndoRedoStack

  class NothingToUndoError < StandardError; end
  class NothingToRedoError < StandardError; end

  def initialize
    @commands = Stack.new
    @undos    = Stack.new
  end

  def has_commands?
    !@commands.empty?
  end

  def do(*commands)
    @commands.push *commands
  end

  def commands_size
    @commands.size
  end

  def undo
    raise NothingToUndoError if !has_commands?
    @commands.pop.tap do |command|
      @undos.push command
    end
  end

  def has_undos?
    !@undos.empty?
  end

  def redo
    raise NothingToRedoError if !has_undos?
    @undos.pop
  end
end
