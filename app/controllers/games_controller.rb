class GamesController < ApplicationController
  def new
    @game = Game.new
  end
  
  def create
    @game = Game.new(params[:game])

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game }
      end
    end
  end
  
  def show
    @game = Game.find(params[:id])
  end
  
  def play
    @game = Game.find(params[:game_id])
    @game.process_bowl(params)
    
    redirect_to @game
  end
end
