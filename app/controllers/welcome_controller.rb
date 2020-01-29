class WelcomeController < ApplicationController

  before_action :confirm_logged_in

  def index
    unless params[:teamPicker]
      params[:teamPicker] = false
    end
    @teamPicker = params[:teamPicker]
    unless params[:id]
      params[:id] = Time.now.strftime("%Y-%m-%d") + " - " + Time.now.strftime("%Y-%m-%d")
    end
    @game_index = params[:id]
    @game_start_index = @game_index[0..9]
    @game_end_index = @game_index[13..23]
    if @teamPicker != false
			@games = Game.where("home_team LIKE ? AND game_date < ? AND game_type <> ?", '%' + @teamPicker, Date.today, "CFB1")
                   .or(Game.where("away_team LIKE ? AND game_date < ? AND game_type <> ?", '%' + @teamPicker, Date.today, "CFB1"))
									 .order("game_date")
    else
      @games = Game.where("game_date between ? and ? AND game_type <> ?", Date.strptime(@game_start_index).beginning_of_day, Date.strptime(@game_end_index).end_of_day, "CFB1")
                   .order("game_state")
                   .order("game_status")
                   .order("game_date")
    end
    @teams = Game.distinct.pluck(:home_team)
		@away_teams = Game.distinct.pluck(:away_team)
		@teams = @teams.concat(@away_teams).map{|team| team[0] == '#' ? team.split(' ')[1..-1].join(' ') : team}.uniq.sort
  end
  
end
