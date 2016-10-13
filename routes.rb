require 'json'
require 'sinatra'
require 'cgi'
require 'active_record'
require 'pg'
require 'date'
require 'json'
require './db-stats.rb'

class StatsApp < Sinatra::Base

	ActiveRecord::Base.establish_connection(
		:adapter 	=> "postgresql",
		:host	 	=> "localhost",
		:username 	=> "", 
		:password 	=> "", 
		:database 	=> "stats"	
	)

	class MeleePlayer < ActiveRecord::Base
		self.primary_key = :id
	end

	class Smash4Player < ActiveRecord::Base
		self.primary_key = :id
	end

	class MeleeMatch < ActiveRecord::Base
	end

	class Smash4Match < ActiveRecord::Base
	end

	lastUpdated = "2016-10-05T20:20:20"[0..18].split('T').join(' ')

	get '/' do 
		erb :index, :locals => {:updated => lastUpdated}
	end

	post '/' do 
		playerNames = params[:players].split(',').map{|x| x.strip.gsub(" ", "%20")}
		date = params[:startDate]
		game = params[:game]
		against = params[:against]

		if against == ""
			against = nil
		end
		if (against != nil)
			against = against.strip.gsub(" ", "%20")
			redir = "/data?game=#{game}&players=#{playerNames.join(',')}&date=#{date}&against=#{against}"
		else 
			redir = "/data?game=#{game}&players=#{playerNames.join(',')}&date=#{date}"
		end
		redirect to(redir)
	end

	get '/about' do
		erb :about
	end
	
	
	get '/data' do
		begin
			playerNames = params[:players].split(',').map{|x| x.downcase.strip}
			date = params[:date]
			game = params[:game]
			against = params[:against]
			if against == ""
				against = nil
			end

			if against != nil
				against = against.to_i
				puts "#{game}, #{playerNames}, #{date}, #{against}, stats"
			else

				puts "#{game}, #{playerNames}, #{date}, stats"
			end
			playerNames = playerNames.map{|name| ActiveRecord::Base::sanitize(name)}
			playerNames = playerNames.map{|name| name.gsub("'", "")}

			if game == "Smash4"


				players = Smash4Player.where(name: playerNames)
		

				if against != nil
					against = Smash4Player.find(against)
				end

			elsif game == "Melee"

				players =  MeleePlayer.where(name: playerNames)
				if against != nil
					against = MeleePlayer.find(against)
				end
			else
				redirect 'blargh'
			end
			statString = Stats.getStats(players, date, against)
			if  (statString == "==========================================================================================\n")
				redirect '/blargh'
			end
			statString =  CGI.escapeHTML(statString)
			erb :displayStats, :locals =>	{:stats => statString}
	
		rescue
			redirect '/blargh'
		end
	end

	get '/json' do
		playerNames = params[:players].split(',').map{|x| x.downcase.strip}
		date = params[:date]
		game = params[:game]
		against = params[:against]

		if against == ""
			against = nil
		end
		
		if against != nil
			against = against.to_i
			puts "#{game}, #{playerNames}, #{date}, #{against}, stats"
		else

			puts "#{game}, #{playerNames}, #{date}, stats"
		end

		playerNames = playerNames.map{|name| ActiveRecord::Base::sanitize(name)}
		playerNames = playerNames.map{|name| name.gsub("'", "")}

		if game == "Smash4"
			players = Smash4Player.where(name: playerNames)

			if against != nil
				against = Smash4Player.find(against)
			end

		elsif game == "Melee"
			players =  MeleePlayer.where(name: playerNames)
			if against != nil
				against = MeleePlayer.find(against)
			end
		else
			redirect 'blargh'
		end

		json = Stats.getJson(players, date, against)
		json =  CGI.escapeHTML(json)
		erb :displayStats, :locals =>	{:stats => json}

	end

	get '/blargh' do
		erb :blargh
	end
end