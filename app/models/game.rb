class Game
  include Mongoid::Document
  include Mongoid::Timestamps
  
  after_create :get_players
  
  has_many :players


  field :number_of_players, :type => Integer, :default => 1
  field :frame_number, :type => Integer, :default => 1
  field :current_bowl_number, :type => Integer, :default => 1
  field :current_player_id, :type => Integer, :default => 1
  field :winner_name
  field :winner_score, :type => Integer
  
  def get_players
    for i in 1..self.number_of_players
      self.players.create(
	:name => "Player " + i.to_s,
        :player_id => i
      )
    end
  end
  
  def process_bowl(params)
    unless self.winner_name.present?
      player = Player.where(:game_id => self._id, :player_id => self.current_player_id).first    
      player.calc_score(params[:pins_knocked_down], self.frame_number, self.current_bowl_number)
    end
  end
  
  def increment_player
    if self.current_player_id == self.number_of_players #if last player has completed their frame
      if self.frame_number == 10 #if game has ended
        winner = self.players.desc.first
	self.winner_name = winner.name
	self.winner_score = winner.total_score
      else
	self.current_player_id = 1
        self.frame_number = self.frame_number + 1
      end
    else
      self.current_player_id = self.current_player_id + 1
    end
    self.save
  end
  
  def set_bowl_number(number)
    self.current_bowl_number = number.to_i
    self.save
  end


end