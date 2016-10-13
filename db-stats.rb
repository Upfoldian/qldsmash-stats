require 'active_record'
require 'pg'
require 'date'
require 'json'


beginning_time = Time.now

ActiveRecord::Base.establish_connection(
	:adapter 	=> "postgresql",
	:host	 	=> "localhost",
	:username 	=> "",
	:password 	=> "",
	:database 	=> "test"	
)

module Stats

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

	def self.getStats(players, date, against)


		targetDate = Date.strptime(date, "%Y-%m-%d")


		returnHash = {:data => []}
		statsString = "==========================================================================================\n"


		players.each do |player|
			stats = {:totalWinPercent => 0, :totalEvents => 0, :totalSets => 0, :wins => 0, :losses => 0}
			wins = 0
			losses = 0
			events = []
			matches = JSON.parse('{"matches": ' + player.matches + '}', quirks_mode: true)["matches"]
			
			#String Stuff
			hashName = "#{player.name} (#{player.region}, #{player.id})" 

			#If Head-to-head needed

			if against != nil
				matches = matches.select{|match| against.id == match['opponentID'].to_i}
				statsString += "#{hashName}'s stats after #{targetDate} against #{against.name}\n"
			else
				statsString += "#{hashName}'s stats after #{targetDate} against everyone\n"
			end

			matches = matches.sort_by{|x| x["date"]}.reverse

			#Gathers match statistics
			matches.each do |match|

				next unless Date.strptime(match["date"], "%Y-%m-%d") > targetDate

				matchStr = ""
				#Wins/Losses
				if match["win"].to_s == "true" 
					wins +=1 
					matchStr = "W"
				elsif match["win"].to_s ==  "false"
					losses += 1
					matchStr = "L"
				else
					puts "erk"
				end
				#At which event
				tourneyName = match["tournamentName"].strip
				tourneyStr = tourneyName
				matchName = match["opponentName"]
				oppoStr = matchName

				if tourneyName.size > 30
					tourneyStr = tourneyName[0..30] + "..."
				end

				if matchName.size > 12
					oppoStr = matchName[0..12] + "..."
				end
				
				statsString +=  "\t #{oppoStr.ljust(16)} #{matchStr.ljust(4)} #{tourneyStr.ljust(35)} #{match["date"]}\n"

				if !events.include? tourneyName 
					stats[:totalEvents] += 1
					events.push tourneyName
				end
			end
			#Write valeus to hash
			stats[:totalWinPercent] = (wins/(wins+losses*1.0)*100).round(2)
			stats[:totalSets] = wins + losses
			stats[:wins] = wins
			stats[:losses] = losses

			# Fix this for multiple againsts
			statsString +=  "\n==========================================================================================\n"
			if against == nil
				if stats[:totalEvents] == 0
					statsString +=  "#{hashName} has not played in this period\n"
				else
					statsString +=  "#{hashName} has played at #{stats[:totalEvents]} different events this period\n"
					statsString +=  "#{hashName} has won #{stats[:totalWinPercent]}% of sets this period\n"
				end
			else
				if stats[:totalEvents] == 0
					statsString +=  "#{hashName} has not played against #{against.name} in this period\n"
				else
					statsString +=  "#{hashName} has played #{stats[:totalSets]} against #{against.name} in this period\n"
					statsString +=  "#{hashName} has won #{stats[:totalWinPercent]}% of sets against #{against.name} in this period\n"
				end
			end
			statsString +=  "\n==========================================================================================\n"


		end
		return statsString
	end

	def self.getJson(players, date, against)
		#SANITIZE STUFF YO


		targetDate = Date.strptime(date, "%Y-%m-%d")
		returnHash = {:data => []}

		players.each do |player|
			stats = {:totalWinPercent => 0, :totalEvents => 0, :totalGames => 0, :wins => 0, :losses => 0}
			wins = 0
			losses = 0
			events = []
			matches = JSON.parse('{"matches": ' + player.matches + '}', quirks_mode: true)["matches"]

			#If Head-to-head needed
			if against != nil
				matches = matches.select{|match| against.id == match['opponentID'].to_i}
			end


			matches = matches.sort_by{|match| match["date"]}.reverse

			#Gathers match statistics
			matches.each do |match|

				next unless Date.strptime(match["date"], "%Y-%m-%d") > targetDate

				if match["win"].to_s == "true" 
					wins +=1 
				elsif match["win"].to_s ==  "false"
					losses += 1
				else
					puts "erk"
				end

				tourneyName = match["tournamentName"]

				if !events.include? tourneyName 
					stats[:totalEvents] += 1
					events.push tourneyName
				end
			end
			#Write valeus to hash
			stats[:totalWinPercent] = (wins/(wins+losses*1.0)*100).round(2)
			stats[:totalGames] = wins + losses
			stats[:wins] = wins
			stats[:losses] = losses

			#Turn db entry into hash and append extra data

			hashName = "{player.name} (#{player.region}, #{player.id})" 
			tempHash = player.serializable_hash
			tempHash['stats'] = stats
			tempHash['matches'] = matches

			returnHash[:data].push tempHash

			#puts returnHash
		end

		return JSON.pretty_generate(returnHash)
	end
end
# p = Smash4Player.where(name: ["Baker"])

# puts "from stats: #{p.class}"
# # a = nil#MeleePlayer.find(1245)

# #puts Stats.getJson(p, "2010-01-01", nil)
# # puts "\n\n ***************************** \n\n"
# # puts Stats.getStats(p, "2010-01-01", a)
