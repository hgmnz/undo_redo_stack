require 'undo_redo_stack'

describe UndoRedoStack do
  let(:stack)  { UndoRedoStack.new }

  context 'by default' do
    it 'starts out empty' do
      stack.should be_empty
    end
  end

  context 'doing commands' do
    it 'records when a command is done' do
      stack.commands_size be_zero
      stack.do(1)
      stack.commands_size.should == 1
    end
  end

  context 'undoing commands' do
    it 'does not allow undoing when no commands have been issued' do
      expect { stack.undo }.to raise_error(UndoRedoStack::NothingToUndoError)
    end

    it 'undos the latest command' do
      stack.do(:command1)
      stack.do(:command2)
      stack.undo.should == :command1
      stack.undo.should == :command2
    end
  end

  context 'undoing' do
    it 'allows you to undo the last command' do
      stack.do(:command1, :command2)
      stack.undo

      stack.redo.should == :command2
    end

    it 'raises when there is nothing to redo' do
      stack.push(:command1, :command2)
      expect { stack.redo }.to raise_error(UndoRedoStack::NothingToRedoError)

      stack.undo
      expect { stack.redo }.to_not raise_error
    end
  end

  context 'redoing commands' do
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
        stack.undo.should == :command1
      end
    end

  end

end
