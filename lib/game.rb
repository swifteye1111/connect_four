# frozen_string_literal: true

require_relative 'player'

class Game
  attr_reader :player_one, :player_two

  def initialize
    @player_one = Player.new('Player 1', 1, '⚪')
    @player_two = Player.new('Player 2', 2, '⚫')
    @current_player = @player_one
    @columns_key = {  'A': 0,
                      'B': 1,
                      'C': 2,
                      'D': 3,
                      'E': 4,
                      'F': 5,
                      'G': 6 }
    @board = Array.new(7) { Array.new(6) }
    @winner = nil
  end

  def play_game
    introduction
    play_turn until game_over?
    display_board
    display_game_end
  end

  def play_turn
    display_board
    verified_input = get_input
    update_board(verified_input)
    switch_player
  end

  def switch_player
    @current_player = @current_player == player_one ? player_two : player_one
  end

  def get_input
    loop do
      invite_input
      user_input = gets.chomp.upcase
      verified_column = verify_input(user_input) if user_input.match?(/[A-G]/)
      return verified_column if verified_column

      puts "Sorry, #{user_input}\'s not an available column."
    end
  end

  def verify_input(input)
    return input if get_available_columns.include?(input)
  end

  def get_available_columns
    available_columns = []
    row = 5
    7.times { |column| available_columns << column if @board[column][row].nil? }
    available_columns = nums_to_names(available_columns)
    available_columns
  end

  def nums_to_names(column_nums)
    column_names = []
    @columns_key.each_pair { |letter, num| column_names << letter.to_s if column_nums.include?(num) }
    column_names
  end

  def names_to_nums(column_names)
    column_nums = []
    @columns_key.each_pair { |letter, num| column_nums << num if column_names.include?(letter) }
    column_nums
  end

  def game_over?
    return true if get_available_columns.nil?

    @winner = switch_player if check_horizontal_win || check_vertical_win || check_diagonal_win
    return true unless @winner.nil?
    false
  end

  def check_horizontal_win
    board_transposed = @board.transpose
    6.times do |column|
      sum = 0
      board_transposed[column].each_with_index do |spot, row|
        unless spot.nil?
          if spot == board_transposed[column][row - 1] || row.zero?
            sum += 1
            return true if sum >= 4
          else
            sum = 0
          end
        end
      end
    end
    false
  end

  def check_vertical_win
    7.times do |column|
      sum = 0
      @board[column].each_with_index do |spot, row|
        unless spot.nil?
          if spot == @board[column][row - 1] || row.zero?
            sum += 1
            return true if sum >= 4
          else
            sum = 0
          end
        end
      end
    end
    false
  end

  def check_diagonal_win
    lower_left_ends = [[0, 2], [0, 1], [0, 0], [1, 0], [2, 0], [3, 0]]
    upper_right_ends = [[3, 5], [4, 5], [5, 5], [6, 5], [6, 4], [6, 3]]
    diagonals = []
    lower_left_ends.each_with_index do |elm, idx|
      diagonal = [elm]
      x = elm[0]
      y = elm[1]
      until [x, y] == upper_right_ends[idx] do
        x += 1
        y += 1
        diagonal << [x, y]
      end
      diagonals << diagonal
    end
    diagonals.each do |diagonal|
      diagonal_values = []
      diagonal.each do |board_space|
        diagonal_values << @board[board_space[0]][board_space[1]]
      end
      sum = 0
      diagonal_values.each_with_index do |value, index|
        unless value.nil?
          if value == diagonal_values[index - 1] || index.zero?
            sum += 1
            return true if sum >= 4
          else
            sum = 0
          end
        end
      end
    end
    false
  end

  def update_board(column)
    column = @columns_key.fetch(column.to_sym)
    row = 0
    row += 1 until @board[column][row].nil?
    @board[column][row] = @current_player.token
  end

  private

  def introduction
    puts 'Welcome to Connect Four! Drop tokens into the grid from the top and try to connect four before your opponent! You win by getting 4 adjacent tokens - horizontally, vertically, or diagonally.
      Player 1\'s token: ⚪
      Player 2\'s token: ⚫.'
  end

  def invite_input
    puts "Please input a column from the available columns:\n#{get_available_columns.join(', ')}"
  end

  def display_board
    display = "\n"
    row = 5
    while row >= 0
      column = 0
      while column <= 6
        if @board[column][row].nil?
          display += '｜   '
        else
          display += "｜#{@board[column][row]} "
        end
        column += 1
      end
      display += "｜\n"
      row -= 1
    end
    display += "⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼\n"
    display += "｜ A ｜ B ｜ C ｜ D ｜ E ｜ F ｜ G ｜\n\n"
    puts display
  end

  def display_game_end
    puts "#{@current_player.name} wins!"
  end
end

#####SOMETHING IS WRONG WITH GAME END.
#If you have 4 in a row or column it declares a winner. Problem bc there are 7 columns.
# #count isn't enough...have to make it consecutive..how to make it consecutive?