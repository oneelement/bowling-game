class Frame
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :player
  
  field :frame_number, :type => Integer
  field :first_bowl, :type => Integer
  field :second_bowl, :type => Integer
  field :third_bowl, :type => Integer
  field :total_score, :type => Integer, :default => 0
  field :cumulative_score, :type => Integer, :default => 0
  field :is_spare, :type => Boolean, :default => false
  field :is_strike, :type => Boolean, :default => false
  
  def set_scores(pins_knocked_down, current_bowl_number)
    if current_bowl_number.to_i == 1
      self.first_bowl = pins_knocked_down.to_i
      self.total_score = pins_knocked_down.to_i
      if pins_knocked_down.to_i == 10
        self.is_strike = true
	if self.frame_number == 10
	  self.player.game.set_bowl_number(2)
	else
	  next_player(1)
	end
      else
	self.player.game.set_bowl_number(2)
      end
      unless self.frame_number == 1
        check_for_spare
      end
    else
      if self.frame_number == 10
        if current_bowl_number.to_i == 2
	  self.second_bowl = pins_knocked_down.to_i
	  self.total_score = self.total_score + pins_knocked_down.to_i
	  if self.total_score > 10 #if total score greater than 10 then 3 bowls are required
            self.is_spare = true
	    self.player.game.set_bowl_number(3)
	  else
	    next_player(1)
          end 
	else
	  self.third_bowl = pins_knocked_down.to_i
          self.total_score = self.total_score + pins_knocked_down.to_i
	  next_player(1)
	end
      else
        self.second_bowl = pins_knocked_down.to_i
        self.total_score = self.total_score + pins_knocked_down.to_i
        if self.total_score == 10
          self.is_spare = true
        end
        next_player(1)
      end
    end
    unless self.frame_number == 1
      check_for_strike(current_bowl_number)
    end
    set_cumulative_score    
  end
  
  def next_player(bowl_number)
    self.player.game.increment_player
    self.player.game.set_bowl_number(bowl_number)
  end
  
  def set_cumulative_score
    if self.frame_number > 1
      cumulative_score = Frame.where(:player_id => self.player_id, :frame_number.lt => self.frame_number).sum(:total_score)
    else
      cumulative_score = 0
    end
    self.cumulative_score = cumulative_score + self.total_score
    self.save
  end
  
  def check_for_spare
    previous_frame = prev_frame
    if previous_frame.is_spare == true
      previous_frame.total_score = previous_frame.total_score + self.first_bowl
      previous_frame.set_cumulative_score
    end
  end
  
  def check_for_strike(current_bowl_number)
    previous_frame = prev_frame
    if previous_frame.is_strike == true
      if current_bowl_number.to_i == 2
        previous_frame.total_score = previous_frame.total_score + self.total_score
	previous_frame.set_cumulative_score
      elsif current_bowl_number.to_i == 1
	unless prev_frame.frame_number == 1
          prev_prev_frame = previous_frame.prev_frame
	  if prev_prev_frame.is_strike == true
	    prev_prev_frame.total_score = prev_prev_frame.total_score + previous_frame.total_score + self.first_bowl
	    prev_prev_frame.set_cumulative_score
	    previous_frame.set_cumulative_score
	  end
	end
      end      
    end
  end
  
  def prev_frame
    prev_frame_number = self.frame_number - 1
    prev_frame = Frame.where(:player_id => self.player_id, :frame_number => prev_frame_number).first
    return prev_frame
  end

  
end