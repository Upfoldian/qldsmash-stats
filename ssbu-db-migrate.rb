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

		create_table :smash4_players do |t|
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
		drop_table :smash4_players
		puts "ran player down method"
	end
end

class CreateMatchTable < ActiveRecord::Migration

	def up

		create_table :smash4_matches do |t|
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
		drop_table :smash4_matches
		puts "ran match down method"
	end
end

print "Dropping old table..."

if ActiveRecord::Base.connection.table_exists? :smash4_players
	CreatePlayerTable.migrate(:down)
end

if ActiveRecord::Base.connection.table_exists? :smash4_matches
	CreateMatchTable.migrate(:down)
end

print "Done!\nCreating new tables..."
CreatePlayerTable.migrate(:up)
CreateMatchTable.migrate(:up)

print "Done!\n"



class Smash4Player < ActiveRecord::Base
	self.primary_key = :id
end



class Smash4Match < ActiveRecord::Base
end

puts "Starting migration process..."

data = JSON.parse(File.read('newFormatOutputSSBU.json'), quirks_mode: true)
dataSize = data["players"].size
i = 1

data["players"].each do |player|

	print "\rSmash 4 Migration Progress...#{(i/dataSize.to_f * 100).round(2)}%"
	i+=1

	p = Smash4Player.new

	p.id 		= player['id'].to_i
	p.name 		= player['playerName'].downcase
	p.region	= player['region'].downcase
	p.elo 		= player['currentElo'].to_i
	p.chars 	= player['mains']
	p.matches 	= player['matches'].to_json

	p.save
	id = p.id
	name = p.name
	player["matches"].each do |match|

		m = Smash4Match.new

		m.playerID 			= id
		m.opponentID 		= match["opponentID"].to_i
		m.name 				= name
		m.opponentName 		= match["opponentName"].downcase
		m.tournamentName 	= match["tournamentName"].downcase
		m.date 				= match["date"]
		m.win 				= match["win"].to_s == "true" ? true : false
		m.eloChange			= match["eloChange"].to_i
		m.elo 				= match["elo"].to_i
		m.opponentElo 		= match["opponentElo"].to_i

		m.save
		
	end


end
print "\rSmash 4 Migration Progress....Done!\n"
puts "Migration Complete!"

#Match.where(name: 'Zxv', opponentName: 'Rainbow').order(date: :asc).each{|x| puts "#{x.elo} #{x.tournamentName}"}
