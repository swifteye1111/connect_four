# frozen_string_literal: true

require_relative '../lib/game'

describe Game do
  describe '#play_game' do
    subject(:game_play) { described_class.new }

    context 'when game_over? is false once' do
      before do
        allow(game_play).to receive(:introduction)
        allow(game_play).to receive(:display_board)
        allow(game_play).to receive(:display_game_end)
        allow(game_play).to receive(:game_over?).and_return(false, true)
      end

      it 'calls play_turn one time' do
        expect(game_play).to receive(:play_turn).once
        game_play.play_game
      end
    end

    context 'when game_over? is false eight times' do
      before do
        allow(game_play).to receive(:introduction)
        allow(game_play).to receive(:display_board)
        allow(game_play).to receive(:display_game_end)
        allow(game_play).to receive(:game_over?).and_return(false, false, false, false, false, false, false, false, true)
      end

      it 'calls play_turn eight times time' do
        expect(game_play).to receive(:play_turn).exactly(8).times
        game_play.play_game
      end
    end
  end

  describe '#play_turn' do
    subject(:game_round) { described_class.new }

    before do
      allow(game_round).to receive(:switch_player)
      allow(game_round).to receive(:display_board)
      allow(game_round).to receive(:receive_input)
      allow(game_round).to receive(:update_board)
    end

    it 'sends switch_player' do
      expect(game_round).to receive(:switch_player).once
      game_round.play_turn
    end

    it 'sends receive_input' do
      expect(game_round).to receive(:receive_input).once
      game_round.receive_input
    end

    it 'sends update_board' do
      expect(game_round).to receive(:update_board).once
      game_round.update_board('B')
    end
  end

  describe '#switch_player' do
    subject(:game_select) { described_class.new }

    context 'when player 1 is current_player' do
      it 'changes current_player to player 2' do
        player_one = game_select.instance_variable_get(:@player_one)
        player_two = game_select.instance_variable_get(:@player_two)
        expect { game_select.switch_player }.to change{ game_select.instance_variable_get(:@current_player) }.from(player_one).to(player_two)
      end
    end
  end

  describe '#receive_input' do
    subject(:game_input) { described_class.new }

    context 'when user inputs a valid value' do
      before do
        valid_input = 'A'
        allow(game_input).to receive(:gets).and_return(valid_input)
        allow(game_input).to receive(:invite_input)
        allow(game_input).to receive(:verify_input).and_return('A')
      end

      it 'stops loop and does not display error message' do
        expect(game_input).not_to receive(:puts)
        game_input.receive_input
      end
    end

    context 'when user inputs an invalid value once, then a valid value' do
      before do
        num = '99'
        valid_input = 'B'
        allow(game_input).to receive(:gets).and_return(num, valid_input)
        allow(game_input).to receive(:invite_input)
        allow(game_input).to receive(:verify_input).and_return(nil)
        allow(game_input).to receive(:verify_input).and_return('B')
      end

      it 'completes loop and displays error message once' do
        error_message = "Sorry, 99\'s not an available column."
        expect(game_input).to receive(:puts).with(error_message).once
        game_input.receive_input
      end
    end
  end

  describe '#verify_input' do
    subject(:game_verify) { described_class.new }

    context 'when given a valid input as argument' do
      it 'returns valid input' do
        allow(game_verify).to receive(:check_available_columns).and_return(%w[B])
        user_input = 'B'
        verified_input = game_verify.verify_input(user_input)
        expect(verified_input).to eq('B')
      end
    end

    context 'when given invalid input as argument' do
      it 'returns nil' do
        allow(game_verify).to receive(:check_available_columns).and_return(%w[A B C E])
        user_input = 'F'
        verified_input = game_verify.verify_input(user_input)
        expect(verified_input).to be_nil
      end
    end
  end

  describe '#check_available_columns' do
    subject(:game_columns) { described_class.new }

    context 'when one column is available' do
      before do
        allow(game_columns).to receive(:nums_to_names).and_return('A')
        token = '⚪'
        board = game_columns.instance_variable_get(:@board)
        7.times do |column|
          6.times do |row|
            board[column][row] = token
          end
        end
        board[0][5] = nil
      end

      it 'sends the number of that column to nums_to_names' do
        expect(game_columns).to receive(:nums_to_names).with([0])
        game_columns.check_available_columns
      end

      it 'returns that column' do
        expect(game_columns).to receive(:check_available_columns).and_return([1])
        game_columns.check_available_columns
      end
    end

    context 'when no columns are available' do
      it 'returns nil' do
        token = '⚪'
        board = game_columns.instance_variable_get(:@board)
        7.times do |column|
          6.times do |row|
            board[column][row] = token
          end
        end
        expect(game_columns).to receive(:check_available_columns).and_return(nil)
        game_columns.check_available_columns
      end
    end

    context 'when more than one column is available' do
      it 'returns the available columns' do
        token = '⚪'
        board = game_columns.instance_variable_get(:@board)
        7.times do |column|
          6.times do |row|
            board[column][row] = token
          end
        end
        board[0][5] = nil
        board[0][5] = nil
        expect(game_columns).to receive(:check_available_columns).and_return(%w[A B])
        game_columns.check_available_columns
      end
    end
  end

  describe '#update_board' do
    subject(:game_update) { described_class.new }

    context 'when Player 1 makes a move' do
      it 'updates the grid with Player 1\'s token' do
        board = game_update.instance_variable_get(:@board)
        token = '⚪'
        5.times { |row| board[6][row] = token }
        board[6][5] = nil
        expect { game_update.update_board('G') }.to change { board[6][5] }.to be(token)
      end
    end

    context 'when player makes a move and the column is empty' do
      it 'updates the bottom space with the player\s token' do
        board = game_update.instance_variable_get(:@board)
        6.times { |row| board[2][row] = nil }
        token = '⚪'
        expect { game_update.update_board('C') }.to change { board[2][0] }.to be(token)
      end
    end

    context 'when player makes a move and the column is partially full' do
      it 'updates the correct space with the player\s token' do
        board = game_update.instance_variable_get(:@board)
        6.times { |row| board[3][row] = nil }
        token = '⚪'
        3.times { |row| board[3][row] = token }
        expect { game_update.update_board('D') }.to change { board[3][3] }.to be(token)
      end
    end
  end

  describe '#nums_to_names' do
    subject(:game_conversion) { described_class.new }

    context 'when columns 0, 2, and 4 are given' do
      it 'returns A, C, and E' do
        nums = [0, 2, 4]
        names = game_conversion.nums_to_names(nums)
        expect(names).to eq(%w[A C E])
      end
    end
  end

  describe '#game_over?' do
    subject(:game_end) { described_class.new }

    context 'when the game is over because spaces are full' do
      before do
        allow(game_end).to receive(:check_available_columns).and_return(nil)
        board = game_end.instance_variable_get(:@board)
        token = '⚪'
        board[0][0] = token
      end

      it 'returns true' do
        expect(game_end).to be_game_over
        game_end.game_over?
      end
    end

    context 'when the game is not over' do
      before do
        allow(game_end).to receive(:check_available_columns).and_return('A')
        allow(game_end).to receive(:check_adjoining_win).and_return(false)
        allow(game_end).to receive(:check_diagonal_win).and_return(false)
      end

      it 'returns false' do
        expect(game_end).not_to be_game_over
        game_end.game_over?
      end
    end
  end

  describe '#check_adjoining_win' do
    subject(:game_adjoining) { described_class.new }

    context 'when player takes 4 consecutive horizontal spaces' do
      it 'returns true' do
        board = game_adjoining.instance_variable_get(:@board)
        token = '⚪'
        4.times { |column| board[column][0] = token }
        board = board.transpose
        adjoining_win = game_adjoining.check_adjoining_win(board, 7)
        expect(adjoining_win).to be true
      end
    end

    context 'when player takes 4 consecutive vertical spaces' do
      it 'returns true' do
        board = game_adjoining.instance_variable_get(:@board)
        token = '⚪'
        4.times { |row| board[0][row + 2] = token }
        adjoining_win = game_adjoining.check_adjoining_win(board, 6)
        expect(adjoining_win).to be true
      end
    end

    context 'when player takes 3 consecutive vertical spaces' do
      it 'returns false' do
        board = game_adjoining.instance_variable_get(:@board)
        token = '⚪'
        3.times { |row| board[0][row + 2] = token }
        board[0][4] = token
        adjoining_win = game_adjoining.check_adjoining_win(board, 6)
        expect(adjoining_win).not_to be true
      end
    end
  end

  describe '#consecutive_four?' do
    subject(:game_consecutive) { described_class.new }

    context 'when given the first in a set of 4 consecutive tokens' do
      it 'returns true' do
        column = [nil, nil, '⚪', '⚪', '⚪', '⚪']
        consecutive = game_consecutive.consecutive_four?(column, 2)
        expect(consecutive).to be true
      end
    end

    context 'when given the first in a set of 3 tokens' do
      it 'returns false' do
        column = [nil, nil, '⚪', '⚪', '⚪', nil]
        consecutive = game_consecutive.consecutive_four?(column, 2)
        expect(consecutive).not_to be true
      end
    end
  end

  describe '#check_diagonal_win' do
    subject(:game_diagonal) { described_class.new }

    context 'when a player wins diagonally (lower left to upper right)' do
      it 'returns true' do
        board = game_diagonal.instance_variable_get(:@board)
        token = '⚪'
        board[0][1] = token
        board[1][2] = token
        board[2][3] = token
        board[3][4] = token
        diagonal_win = game_diagonal.check_diagonal_win
        expect(diagonal_win).to be true
      end
    end

    context 'when only 3 consecutive spaces are taken' do
        it 'returns false' do
        board = game_diagonal.instance_variable_get(:@board)
        token = '⚪'
        board[0][0] = token
        board[1][1] = token
        board[2][2] = token
        board[4][4] = token
        diagonal_win = game_diagonal.check_diagonal_win
        expect(diagonal_win).not_to be true
      end
    end

    context 'when a player wins diagonally (upper left to lower right)' do
      it 'returns true' do
        board = game_diagonal.instance_variable_get(:@board)
        token = '⚪'
        board[0][4] = token
        board[1][3] = token
        board[2][2] = token
        board[3][1] = token
        diagonal_win = game_diagonal.check_diagonal_win
        expect(diagonal_win).to be true
      end
    end
  end
end