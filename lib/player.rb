# frozen_string_literal: true

# keeps track of player name and id
class Player
  attr_reader :name, :id

  def initialize(name, id)
    @name = name
    @id = id
  end
end
