require 'active_record'
require 'pg'
require 'json'


print "Establishing Database Connection..."
ActiveRecord::Base.establish_connection(
	:adapter 	=> "postgresql",
	:host	 	=> "localhost",
	:username 	=> "tom",
	:password 	=> "tom",
	:database 	=> "test"	
)

print "Done!\n"

class CreatePlayerTable < ActiveRecord::Migration

	def up
		create_table :melee_players do |t|
			t.string 		:name, null: false
			t.string 		:region
			t.integer 		:elo
			t.text 			:chars, array: true, default: []
			t.text			:matches

			t.timestamps
		end

		puts "ran player up method"
	end

	def down
		drop_table :melee_players
		puts "ran player down method"
	end
end

class CreateMatchTable < ActiveRecord::Migration

	def up
		create_table :melee_matches do |t|
			t.integer		:playerID, null: false
			t.integer		:opponentID, null: false
			t.string 		:name, null: false
			t.string		:opponentName, null: false
			t.string		:tournamentName, null: false
			t.date 			:date, null: false
			t.boolean 		:win, null: false
			t.integer 		:eloChange, null: false
			t.integer  		:elo, null: false
			t.integer 		:opponentElo, null: false

			t.timestamps
		end

		puts "ran match up method"
	end

	def down
		drop_table :melee_matches
		puts "ran match down method"
	end
end

print "Dropping old table..."

if ActiveRecord::Base.connection.table_exists? :melee_players
	CreatePlayerTable.migrate(:down)
end

if ActiveRecord::Base.connection.table_exists? :melee_matches
	CreateMatchTable.migrate(:down)
end


print "Done!\nCreating new tables..."
CreatePlayerTable.migrate(:up)
CreateMatchTable.migrate(:up)

print "Done!\n"

class MeleePlayer < ActiveRecord::Base
	self.primary_key = :id
end

class MeleeMatch < ActiveRecord::Base
end



puts "Starting migration process..."
data = JSON.parse(File.read('newFormatOutputSSBM.json'), quirks_mode: true)
dataSize = data["players"].size
i = 1

data["players"].each do |player|

	print "\rMelee Migration Progress...#{(i/dataSize.to_f * 100).round(2)}%"
	i+=1

	p = MeleePlayer.new

	p.id 		= player['id'].to_i
	p.name 		= player['playerName'].downcase
	p.region	= player['region'].downcase
	p.elo 		= player['currentElo'].to_i
	p.chars 	= player['mains']
	p.matches 	= player['matches'].to_json

	player["matches"].each do |match|

		m = MeleeMatch.new

		m.playerID 			= p.id
		m.opponentID 		= match["opponentID"].to_i
		m.name 				= p.name
		m.opponentName 		= match["opponentName"].downcase
		m.tournamentName 	= match["tournamentName"].downcase
		m.date 				= match["date"]
		m.win 				= match["win"].to_s == "true" ? true : false
		m.eloChange			= match["eloChange"].to_i
		m.elo 				= match["elo"].to_i
		m.opponentElo 		= match["opponentElo"].to_i

		m.save

	end

	p.save

end