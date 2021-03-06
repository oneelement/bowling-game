class Player
  include Mongoid::Document
  include Mongoid::Timestamps
  
  after_create :get_frames
  
  belongs_to :game
  has_many :frames, :order => "frame_number ASC"
  
  field :name
  field :player_id
  field :total_score, :type => Integer, :default => 0
  
  def get_frames
    for i in 1..10
      self.frames.create(
	:frame_number => i
      )
    end
  end
  
  def calc_score(pins_knocked_down, frame_number, current_bowl_number)
    frame = Frame.where(:player_id => self._id, :frame_number => frame_number).first
    unless pins_knocked_down.to_i > 10 || ((frame.first_bowl.to_i + pins_knocked_down.to_i) > 10)
      frame.set_scores(pins_knocked_down, current_bowl_number)
      set_total_score
    end
  end
  
  def set_total_score
    total_score = Frame.where(:player_id => self._id).sum(:total_score)
    self.total_score = total_score
    self.save
  end
  

  
end