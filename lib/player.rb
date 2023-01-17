# frozen_string_literal: true

# keeps track of player name and id
class Player
  attr_reader :name, :id, :token

  def initialize(name, id, token)
    @name = name
    @id = id
    @token = token
  end
end
