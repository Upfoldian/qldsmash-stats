require 'rubygems'
require 'json'
require 'nokogiri'

xml = Nokogiri::XML(File.read "SSBU.xml")
xml = xml.xpath("//EloXmlModel")

createDate 	= xml.xpath("CreatedDate").text
gameName 	= xml.xpath("GameName").text
gameShort 	= xml.xpath("GameShort").text

#puts "#{createDate}, #{gameName}, #{gameShort}" 

eloHash = {:createDate => createDate, :gameName => gameName, :gameShort => gameShort, :items => [], :players => [], :tourneys => [], :characters => [], :regions => []}

xml.xpath("Items//EloItemXmlModel").each do |item|
	
	rank 				= item.xpath("Rank").text.to_i
	localRank 			= item.xpath("LocalRank").text.to_i
	score 				= item.xpath("Score").text.to_i
	rankMovement 		= item.xpath("RankMovement").text.to_i
	localRankMovement	= item.xpath("LocalRankMovement").text.to_i
	scoreMovement 		= item.xpath("ScoreMovement").text.to_i
	movements 			= []

	item.xpath("Movements/EloMovementXmlModel").each do |movement|

		oldScore 		= movement.xpath("OldScore").text.to_i
		newScore 		= movement.xpath("NewScore").text.to_i
		oppOldScore 	= movement.xpath("OpponentOldScore").text.to_i
		oppNewScore 	= movement.xpath("OpponentNewScore").text.to_i
		oppID 			= movement.xpath("OpponentID").text.to_i
		oppName 		= movement.xpath("OpponentName").text
		oppIsTagged		= movement.xpath("OpponentIsTagged").text
		tourneyID 		= movement.xpath("TourneyID").text.to_i
		eventName 		= movement.xpath("EventName").text
		playerCharImg 	= movement.xpath("PlayerCharImage").text
		isWin 			= movement.xpath("IsWin").text
		change 			= movement.xpath("Change").text.to_i
		winnerName 		= movement.xpath("WinnerName").text
		note 			= movement.xpath("Note").text


		movementHash = {:oldScore => oldScore, :newScore => newScore, :oppOldScore => oppOldScore, :oppNewScore => oppNewScore,
						:oppID => oppID, :oppName => oppName, :oppIsTagged => oppIsTagged, :tourneyID => tourneyID,
						:eventName => eventName, :playerCharImg => playerCharImg, :isWin => isWin, :change => change,
						:winnerName => winnerName, :note => note}
		#puts "#{oldScore}, #{newScore}, #{oppOldScore}, #{oppNewScore}, #{oppID}, #{oppName}, #{oppIsTagged}, #{tourneyID}"
		#puts "#{eventName}, #{playerCharImg}, #{isWin}, #{change}, #{winnerName}, #{note}"
		#puts movementHash.to_s

		movements.push movementHash

	end


	playerID 			= item.xpath("PlayerID").text.to_i
	characters 			= []


	item.xpath("Characters/int").each do |character|

		characterID 	= character.text.to_i
		characters.push characterID

	end


	hasCharacterData 	= item.xpath("HasCharacterData").text
	characterUsage 		= []


	item.xpath("CharacterUsage/EloItemCharacterUsageItem").each do |charUsage|
		
		overallCharUse 	= charUsage.xpath("OverallCharacterUsage").text.to_i
		relativeCharUse = charUsage.xpath("RelativeCharacterUsage").text.to_i
		characterID		= charUsage.xpath("CharacterID").text.to_i

		characterHash = {:overallCharUse => overallCharUse, :relativeCharUse => relativeCharUse, :characterID => characterID}
		characterUsage.push characterHash
		#puts characterHash.to_s
	end

	itemHash = {:rank => rank, :localRank => localRank, :score => score, :rankMovement => rankMovement, :localRankMovement => localRankMovement,
				:scoreMovement => scoreMovement, :movements => movements, :playerID => playerID, :characters => characters, 
				:hasCharacterData => hasCharacterData, :characterUsage => characterUsage}

	#puts itemHash.to_s

	eloHash[:items].push itemHash

end

xml.xpath("Players//XmlPlayerModel").each do |player|

	playerID 			= player.xpath("ID").text.to_i
	name 				= player.xpath("Name").text
	siteLink 			= player.xpath("SiteLink").text
	siteLinkTitle 		= player.xpath("SiteLinkTitle").text
	regionID 			= player.xpath("RegionID").text

	playerHash = {:playerID => playerID, :name => name, :siteLink => siteLink, :siteLinkTitle => siteLinkTitle, :regionID => regionID}
	#puts playerHash.to_s
	eloHash[:players].push playerHash

end

xml.xpath("Tourneys//XmlTourneyModel").each do |tourney|

	tourneyID 			= tourney.xpath("ID").text.to_i
	name 				= tourney.xpath("Name").text
	displayName 		= tourney.xpath("DisplayName").text
	regionID 			= tourney.xpath("RegionID").text.to_i
	tourneyDate 		= tourney.xpath("TourneyDate").text
	siteLink 			= tourney.xpath("SiteLink").text
	siteLinkTitle 		= tourney.xpath("SiteLinkTitle").text

	tourneyHash =	{:tourneyID => tourneyID, :name => name, :displayName => displayName, :regionID => regionID, :tourneyDate => tourneyDate,
					 :siteLink => siteLink, :siteLinkTitle => siteLinkTitle}
	#puts tourneyHash.to_s
	eloHash[:tourneys].push tourneyHash
end

xml.xpath("Characters//XmlCharacterModel").each do |character|

	characterID 		= character.xpath("ID").text.to_i
	name 				= character.xpath("Name").text
	short 				= character.xpath("Short").text
	imgURL 				= character.xpath("ImageUrl").text
	colour 				= character.xpath("Colour").text

	characterHash = {:characterID => characterID, :name => name, :short => short, :imgURL => imgURL, :colour => colour}
	#puts characterHash.to_s
	eloHash[:characters].push characterHash
end

xml.xpath("Regions//XmlRegionModel").each do |region|

	regionID 			= region.xpath("ID").text.to_i
	imgURL 				= region.xpath("ImageUrl").text
	name 				= region.xpath("Name").text
	short 				= region.xpath("Short").text

	regionHash = {:regionID => regionID, :imgURL => imgURL, :name => name, :short => short}
	#puts regionHash.to_s
	eloHash[:regions].push regionHash

end

File.open("newOutput.json", 'w') { |file| file.write(JSON.pretty_generate(eloHash))}
