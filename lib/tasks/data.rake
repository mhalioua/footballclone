namespace :data do
  task :import => :environment do
    require 'csv'
    filename = File.join Rails.root, 'csv', "football_data.csv"
    CSV.foreach(filename, headers: true) do |row|
      game = row.to_h
      game['game_id'] = nil
      game['game_date'] = nil
      game['home_abbr'] = nil
      game['away_abbr'] = nil
      FootballDatum.create(game)
    end
  end

  task :match_to_export => :environment do
    games = FootballDatum.where('game_id is null')
    games.each do |game|
      month_day = game.month_day.upcase
      home_team = game.home_team
      away_team = game.away_team
      home_team = @team[home_team] if @team[home_team]
      away_team = @team[away_team] if @team[away_team]
      date = month_day[-3..-1] + ('  ' + month_day[0..-5])[-3..-1]
      export = Export.where("home_team = ? AND away_team = ? AND time = ? AND year = ? AND date = ? AND week = ?", home_team, away_team, game.local_time, game.year, date, game.day_week).first
      if export
        game.update(game_id: export.game_id,
                    game_date: export.game_date,
                    home_abbr: export.home_abbr,
                    away_abbr: export.away_abbr)
      end
    end
  end

  task :football_kicked => :environment do
    games = FootballDatum.where('kicked is null')
    games.each do |game|
      site_game = Game.where("game_id = ?", game.game_id).first
      if site_game
        kicked = ""
        if site_game.kicked === 'home'
          kicked = game.home_team
        elsif site_game.kicked === 'away'
          kicked = game.away_team
        end
        game.update(kicked_home_away: site_game.kicked,
                    kicked: kicked)
      end
    end
  end

  @team = {
      'Floridatl' => 'Florida Intl',
      'San Josͩ State' => 'San José State'
  }
end