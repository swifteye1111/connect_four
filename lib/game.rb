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
    display_game_end
  end

  def play_turn
    verified_input = get_input
    update_board(verified_input)
    switch_player
  end

  def switch_player
    @current_player = @current_player == player_one ? player_two : player_one
  end

  def get_input
    invite_input
    loop do
      user_input = gets.chomp
      verified_column = verify_input(user_input) if user_input.match?(/[A-G]/)
      return verified_column if verified_column

      puts 'Input error!'
      invite_input
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
    @columns_key.each_pair { |letter, num| column_names << letter if column_nums.include?(num) }
    column_names
  end

  def names_to_nums(column_names)
    column_nums = []
    @columns_key.each_pair { |letter, num| column_nums << num if column_names.include?(letter) }
    column_nums
  end

  def game_over?
    return true if get_available_columns.nil?

    @winner = @current_player if check_horizontal_win || check_vertical_win || check_diagonal_win
    return true unless @winner.nil?
    false
  end

  def check_horizontal_win
    board_transposed = @board.transpose
    6.times do |column|
      p_one_count = board_transposed[column].count(@player_one.token)
      p_two_count = board_transposed[column].count(@player_two.token)
      greater_count = p_one_count > p_two_count ? p_one_count : p_two_count
      return true if greater_count >= 4
    end
    false
  end

  def check_vertical_win
    7.times do |column|
      p_one_count = @board[column].count(@player_one.token)
      p_two_count = @board[column].count(@player_two.token)
      greater_count = p_one_count > p_two_count ? p_one_count : p_two_count
      return true if greater_count >= 4
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
      p_one_count = diagonal_values.flatten.count(@player_one.token)
      p_two_count = diagonal_values.flatten.count(@player_two.token)
      greater_count = p_one_count > p_two_count ? p_one_count : p_two_count
      return true if greater_count >= 4
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
    puts "Please input a column from the available columns: #{get_available_columns}:"
  end

  def display_grid
    puts @board
  end

  def display_game_end
    puts "winner is #{@current_player}"
  end
end