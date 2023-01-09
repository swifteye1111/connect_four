# frozen_string_literal: true

require_relative '../lib/game'

# Game Notes:
# 7 columns, 6 rows:
#   x, y grid
# Player 1, player 2 (player class)
# Discs can only go in from top to bottom

describe Game do
  describe '#play_game' do
    subject(:game_play) { described_class.new }

    context 'when game_over? is false once' do
      before do
        allow(game_play).to receive(:introduction)
        allow(game_play).to receive(:game_over?).and_return(false, true)
      end

      it 'calls play_round one time' do
        expect(game_play).to receive(:play_round).once
        game_play.play_game
      end
    end

    context 'when game_over? is false eight times' do
      before do
        allow(game_play).to receive(:introduction)
        allow(game_play).to receive(:game_over?).and_return(false, false, false, false, false, false, false, false, true)
      end

      it 'calls play_round eight times time' do
        expect(game_play).to receive(:play_round).exactly(8).times
        game_play.play_game
      end
    end
  end

  describe '#play_round' do
    subject(:game_round) { described_class.new }

    before do
      allow(game_round).to receive(:switch_player)
      allow(game_round).to receive(:display_grid)
      allow(game_round).to receive(:get_input)
      allow(game_round).to receive(:update_board)
    end

    it 'sends switch_player' do
      expect(game_round).to receive(:switch_player).once
      game_round.play_round
    end

    it 'sends get_input' do
      expect(game_round).to receive(:get_input).once
      game_round.get_input
    end

    it 'sends update_board' do
      expect(game_round).to receive(:update_board).once
      game_round.update_board
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

  describe '#get_input' do
    subject(:game_input) { described_class.new }

    # Looping Script Method -> Test the behavior of the method (for example, it
    # stops when certain conditions are met).

    # NOTE: #player_input will stop looping when valid_input is a space where
    # player can go

    # grid hash (build using combos & permutations)
    # 1: [0, 0], 2: [0, 1], 3: [0, 2], 4: [0, 3], 5: [0, 4], 6: [0, 5], 7: [0, 6]
    # 11: [1, 0], 12: [1, 1], 13: [1, 2], 14: [1, 3], 15: [1, 4], 16: [1, 5], 17: [1, 6] 
    # 21: [2, 0] etc etc

    # and/or...allow player to input a column letter A-G only

    context 'when user inputs a valid value' do
      before do
        valid_input = 'A'
        allow(game_input).to receive(:gets).and_return(valid_input)
        #allow(game_input).to receive(:invite_input)
      end

      xit 'stops loop and does not display error message' do
        expect(game_input).not_to receive(:puts)
        game_input.get_input
      end
    end

    context 'when user inputs an invalid value once, then a valid value' do
      before do
        num = '99'
        valid_input = 'A'
        allow(game_input).to receive(:gets).and_return(num, valid_input)
        #allow(game_input).to receive(:invite_input)
      end

      xit 'completes loop and displays error message once' do
        columns = game_input.instance_variable_get(:@columns_available)
        error_message = "Input error! Please enter one of the available columns #{columns}"
        expect(game_input).to receive(:puts).with(error_message).once
        game_input.get_input
      end
    end
  end

  describe '#verify_input' do
    subject(:game_verify) { described_class.new }

    context 'when given a valid input as argument' do
      xit 'returns valid input' do
        columns = game_input.instance_variable_get(:@columns_available)
        columns = ['A', 'B', 'C', 'D', 'E', 'F']
        user_input = 'B'
        verified_input = game_verify.verify_input(user_input)
        expect(verified_input).to eq('B')
      end
    end

    context 'when given invalid input as argument' do
      xit 'returns nil' do
        columns = game_input.instance_variable_get(:@columns_available)
        columns = ['A', 'B', 'C', 'D', 'E', 'F']
        user_input = 'X'
        verified_input = game_verify.verify_input(user_input)
        expect(verified_input).to be_nil
      end
    end
  end

  describe '#get_available_columns' do
    subject(:game_columns) { described_class.new }

    context 'when one column is available' do
      before do
        allow(game_columns).to receive(:convert_column_nums).and_return('A')
        token = '⚪'
        board = game_columns.instance_variable_get(:@board)
        7.times do |row|
          6.times do |column|
            board[row][column] = token
          end
        end
        board[5][0] = nil
      end

      it 'sends the number of that column to convert_column_nums' do
        expect(game_columns).to receive(:convert_column_nums).with([0])
        game_columns.get_available_columns
      end

      it 'returns that column' do
        expect(game_columns).to receive(:get_available_columns).and_return([1])
        game_columns.get_available_columns
      end
    end

    context 'when no columns are available' do
      it 'returns nil' do
        token = '⚪'
        board = game_columns.instance_variable_get(:@board)
        7.times do |row|
          6.times do |column|
            board[row][column] = token
          end
        end
        expect(game_columns).to receive(:get_available_columns).and_return(nil)
        game_columns.get_available_columns
      end
    end

    context 'when more than one column is available' do
      it 'returns the available columns' do
        token = '⚪'
        board = game_columns.instance_variable_get(:@board)
        7.times do |row|
          6.times do |column|
            board[row][column] = token
          end
        end
        board[5][0] = nil
        board[5][1] = nil
        expect(game_columns).to receive(:get_available_columns).and_return(%w[A B])
        game_columns.get_available_columns
      end
    end
  end

  describe '#update_board' do
    subject(:game_update) { described_class.new }

      context 'when Player 1 makes a move' do
        before do
          let(:player_one) { instance_double('Player') }
        end

        xit 'updates the grid with Player 1\'s token' do
          board = game_update.instance_variable_get(:@board)
          token = '⚪'
          board[6][5] = nil
          expect { game_update.update_board(player_one, 'G') }.to change { board[6][5] }.to eql(token)
        end
      end

      context 'when Player 2 makes a move' do
        xit 'updates the board with Player 2\'s token' do
          before do
            let(:player_two) { instance_double('Player') }
          end
        end

        xit 'updates the grid with Player 2\'s token' do
          board = game_update.instance_variable_get(:@board)
          token = '⚫'
          board[3][6] = nil
          expect { game_update.update_board(player_two, 'D') }.to change { board[3][5] }.to eql(token)
        end
      end
  end

  describe '#game_over?' do
    subject(:game_end) { described_class.new }

    context 'when the game is over because Player 1 connected 4 spaces horizontally' do
      let(:player_one) { instance_double('Player') }

      before do
        allow(game_end).to receive(:display_game_end)
      end

      xit 'returns true' do
        board = game_update.instance_variable_get(:@board)
        token = '⚪'
        4.times do |column|
          board[0][column] = token
        end
        expect(game_end).to be_game_over?
        game_end.game_over?
      end

      xit 'changes @winner to player_one' do
        winner = game_end.instance_variable_get(:@winner)
        expect{ game_end.game_over? }.to change { winner }.to(player_one)
      end
    end

    context 'when the game is over because Player 2 connected 4 spaces vertically' do
      let(:player_two) { instance_double('Player') }

      before do
        allow(game_end).to receive(:display_game_end)
      end

      xit 'returns true' do
        board = game_update.instance_variable_get(:@board)
        token = '⚫'
        4.times do |row|
          board[row][5] = token
        end
        expect(game_end).to be_game_over?
        game_end.game_over?
      end

      xit 'changes @winner to player_one' do
        winner = game_end.instance_variable_get(:@winner)
        expect{ game_end.game_over? }.to change { winner }.to(player_two)
      end
    end

    context 'when the game is over because a player connected 4 spaces diagonally' do
      before do
        allow(game_end).to receive(:display_game_end)
      end

      xit 'returns true' do
        board = game_update.instance_variable_get(:@board)
        token = '⚪'
        board[0][1] = token
        board[1][2] = token
        board[2][3] = token
        board[3][4] = token
        expect(game_end).to be_game_over?
        game_end.game_over?
      end
    end
    
    context 'when the game is over because spaces are full' do
      before do
        allow(game_end).to receive(:get_available_columns).and_return(nil)
        allow(game_end).to receive(:display_game_end)
      end

      xit 'returns true' do
        expect(game_end).to be_game_over?
        game_end.game_over?
      end
    end

    context 'when the game is not over' do
      before do
        allow(game_end).to receive(:get_available_columns).and_return('A')
        allow(game_end).to receive(:display_game_end)
      end

      xit 'returns false' do
        expect(game_end).not_to be_game_over?
        game_end.game_over?
      end
    end
  end
end

# other methods:
#  #introduction
#  #display_grid
#  #display_game_end
#  #invite_input
    # puts msg to player with available columns
