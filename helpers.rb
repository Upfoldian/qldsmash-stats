module Helpers
	def self.getPlayerIDHash(jsonData)

		players = jsonData['players']
		playerIDHash = {}

		players.each do |player|

			name	 = player['name']
			playerID = player['playerID']
			regionID = player['regionID']

			playerIDHash[playerID] = {:name => name, :regionID => regionID}
		end
		return playerIDHash
	end

	def self.getTourneyIDHash(jsonData)

		tourneys 	= jsonData['tourneys']
		tourneyIDHash = {}

		tourneys.each do |tourney|

			tourneyID 	= tourney['tourneyID']
			regionID 	= tourney['regionID']
			name 		= tourney['name']
			date 		= tourney['tourneyDate'].split('T')[0]

			tourneyIDHash[tourneyID] = {:regionID => regionID, :name => name, :date => date}
		end
		return tourneyIDHash
	end

	def self.getCharIDHash(jsonData)
		characters = jsonData['characters']
		charIDHash = {}

		characters.each do |character|
			charID 		= character['characterID']
			name 		= character['name']
			short 		= character['short']

			charIDHash[charID] = {:name => name, :short => short}
		end
		return charIDHash
	end

	def self.getRegionIDHash(jsonData)
		regions = jsonData['regions']
		regionIDHash = {}

		regions.each do |region|
			regionID 	= region['regionID']
			name 		= region['name']
			short 		= region['short']

			regionIDHash[regionID] = {:name => name, :short => short}
		end
		return regionIDHash
	end
end
