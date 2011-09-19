require 'undo_redo_stack'

describe UndoRedoStack do
  let(:stack)  { UndoRedoStack.new }

  context 'by default' do
    it 'starts out empty' do
      stack.should_not have_commands
    end
  end

  context 'doing commands' do
    it 'records when a command is done' do
      stack.should_not have_commands
      stack.do(:command1)
      stack.commands_size.should == 1
    end

    it 'can do several commands at once' do
      stack.do(:command1, :command2)
      stack.commands_size.should == 2
    end

  end

  context 'undoing commands' do
    it 'does not allow undoing when no commands have been issued' do
      stack.should_not have_commands
      expect { stack.undo }.to raise_error(UndoRedoStack::NothingToUndoError)
    end

    it 'undos the latest command' do
      stack.do(:command1)
      stack.do(:command2)
      stack.undo.should == :command2
      stack.undo.should == :command1
    end
  end

  context 'redoing commands' do
    it 'allows you to redo the last undone command' do
      stack.do(:command1, :command2)
      stack.undo

      stack.redo.should == :command2
    end

    it 'does not allow redoing prior to undoing' do
      stack.do(:command)
      expect { stack.redo }.to raise_error(UndoRedoStack::NothingToRedoError)
    end

    it 'redos the last command that was undone' do
      stack.do(:command1, :command2)
      2.times { stack.undo }

      stack.redo.should == :command1
      stack.redo.should == :command2
    end

    context 'undoing and redoing after a series of interactions' do
      before do
        stack.do(:command1, :command2)
        stack.undo
        stack.do(:command3)
        stack.undo
      end

      it 'can redo last undone command or undo prior' do
        stack.redo.should == :command3
      end

      it 'undos the the last done command after another redo' do
        stack.redo
        stack.undo.should == :command3
      end

      it 'undoing and redoing another level' do
        stack.undo
        stack.redo.should == :command1
      end
    end

    context 'redoing a command, and then undoing that' do
      before do
        stack.do(:command1, :command2)
        stack.undo
        stack.redo
      end

      it 'undos the last command that was redone' do
        stack.undo.should == :command2
      end

    end

  end

end
