require 'json'
require 'nokogiri'
require 'date'
require './helpers.rb'

qldsmashData = JSON.parse(File.read('newOutput.json'))

newFormatHash = {:lastUpdated => qldsmashData['createDate'], :game => qldsmashData['gameShort'], :players => []}



playerIDHash 	= Helpers.getPlayerIDHash qldsmashData
tourneyIDHash 	= Helpers.getTourneyIDHash qldsmashData
charIDHash 		= Helpers.getCharIDHash qldsmashData
regionIDHash 	= Helpers.getRegionIDHash qldsmashData

#puts playerIDHash.to_s
#puts tourneyIDHash.to_s
#puts charIDHash.to_s
#puts regionIDHash.to_s

playerDataItems = qldsmashData['items']

playerDataItems.each do |item|

	playerID 	= item["playerID"].to_i
	regionID 	= playerIDHash[playerID][:regionID].to_i
	region 		= regionIDHash[regionID][:short]
	playerName	= playerIDHash[playerID][:name]
	currentElo	= item['score'].to_i
	mains 		= item['characters'].map {|char| charIDHash[char][:short]}

	playerInfo = {:playerName => playerName, :id => playerID, :region => region, :currentElo => currentElo, :mains => mains, :matches => []}

	matchData = item["movements"]

	matchData.each do |match|

		opponentName 	= match['oppName']
		opponentID 		= match['oppID'].to_i
		tournamentID 	= match['tourneyID'].to_i
		tournamentName	= tourneyIDHash[tournamentID][:name]
		date 			= tourneyIDHash[tournamentID][:date]
		win 			= match['isWin']
		eloChange 		= match['change']
		elo 			= match['oldScore'].to_i
		opponentElo 	= match['oppOldScore'].to_i


		matchInfo = {:opponentName => opponentName, :opponentID => opponentID, :tournamentName => tournamentName,
					 :tournamentID => tournamentID, :date => date, :win => win, :eloChange => eloChange, :elo => elo,
					 :opponentElo => opponentElo}

		playerInfo[:matches].push matchInfo
	end

	newFormatHash[:players].push playerInfo
end
File.open("newFormatOutput.json", 'w') { |file| file.write(JSON.pretty_generate(newFormatHash))}
