# frozen_string_literal: true

require_relative 'player'

class Game
  attr_reader :player_one, :player_two
  attr_accessor :board

  def initialize
    @player_one = Player.new('Player 1', 1)
    @player_two = Player.new('Player 2', 2)
    @current_player = @player_one
    @columns_key = {  'A': 0,
                      'B': 1,
                      'C': 2,
                      'D': 3,
                      'E': 4,
                      'F': 5,
                      'G': 6 }
    @board = Array.new(7) { Array.new(6) }
  end

  def play_game
    introduction
    play_round until game_over?
  end

  def play_round
    get_input
    update_board
    switch_player
  end

  def switch_player
    @current_player = @current_player == player_one ? player_two : player_one
  end

  def get_input
    invite_input
  end

  def get_available_columns
    available_columns = []
    row = 5
    6.times { |column| available_columns << column if @board[row][column].nil? }
    available_columns = convert_column_nums(available_columns)
  end

  def convert_column_nums(column_nums)
    column_names = []
    @column_keys.each_pair { |letter, num| column_names << letter if column_nums.include?(num) }
    column_names
  end

  def game_over?
  end

  def update_board
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
  end
end