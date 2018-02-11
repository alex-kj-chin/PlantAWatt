-- 
-- Plant-A-Watt
-- © Alex Chin 2013-2016

display.setStatusBar( display.HiddenStatusBar )


-- WAIT FOR SPLASH SCREEN
-- 
Kw = 0

timestart = os.time() + 0 -- delays this many seconds
local f = display.newImage("Default.png");
while os.time() < timestart do
	local i = 5
	end
f:removeSelf() 


local widget = require( "widget" )
local json = require( "json" )
require "pubnub"
local http = require("socket.http")
local audioFiles = { "soil", "plantg" }
 

multiplayer = pubnub.new({
    publish_key   = "demo",            
    subscribe_key = "demo",            
    secret_key    = nil,               
    ssl           = nil,               
    origin        = "pubsub.pubnub.com"
})

--
-- receive msg w/pubnub
--
multiplayer:subscribe({
    channel  = "lua-corona-demo-channel",
    callback = function(message)
        -- MESSAGE RECEIVED!!!
        print(message[1])
    end,
    errorback = function()
        print("Network Connection Lost")
    end
})

--
-- publish msg w/pubnub
--
function send_a_message(text)
	multiplayer:publish({
	    channel  = "lua-corona-demo-channel",
	    message  = { text },
	    callback = function(info)
	 
	        -- WAS MESSAGE DELIVERED?
	        if info[1] then
	            print("MESSAGE DELIVERED SUCCESSFULLY!")
	        else
	            print("MESSAGE FAILED BECAUSE -> " .. info[2])
	        end
	 
	    end
	})
end

function send_hello_world()
	 send_a_message( "Hello World" )
end

timer.performWithDelay( 500, send_hello_world, 10 )

function saveTable( t, filename )
	print("startSave")
	local path = system.pathForFile( filename, system.DocumentsDirectory )
	local file = io.open( path, "w" )
	if file then
		print ("saving")
		local contents = json.encode(t)
		file:write( contents )
		io.close( file )
		return true
	else
		return false
	end
end

function loadTable( filename )
	local path = system.pathForFile( filename, system.DocumentsDirectory )
	print(path)
	local contents = ""
	local myTable = {}
	local file = io.open( path, "r" )
	if file then
		print ( "loading" )
		local contents = file:read( "*a" )
		myTable = json.decode( contents );
		io.close( file )
		return myTable
	end
		return nil
end

-- SET CONSTANTS
--
local audioLoaded = nil
page = 0
money = 1000
energy = 30
clicker = 1
topLimit = 0
bottomLimit = -10
rightLimit = 0
leftLimit = -300
menuTransparency = 0.75 -- This controls transparency of menu
windreturn = 14400
solarreturn = 3600
plantstable = {
	{"move", 0, 0, 0, 0, 1},
	{"grass", 30, 25, 50, 1, 1},
	{"strawberry", 10, 50, 150, 1, 1},
	{"corn", 3600, 80, 300, 1, 1},
	{"blueberry", 300, 7, 30, 1, 0, 5, "unlock1x1"}, --5
	{"apple", 86400, 1000, 10, 0, 0, 10, "unlock2x3"},
	{"peach", 43200, 5000, 700, 0, 0, 10, "unlock1x2"},
	{"banana", 172800, 500, 40, 0, 0, 15, "unlock3x6"},
	{"watermelon", 864000, 100, 100, 1, 0, 7},
	{"pumpkin", 32400, 300, 1000, 1, 0, 7, "unlock2x1"}, --10
	{"grape", 14400, 100, 700, 1, 0, 7, "unlock2x2"},
	{"rice", 3600, 100, 400, 1, 0, 10, "unlock3x2"},
	{"chile", 28800, 50, 350, 1, 0, 10, "unlock2x4"},
	{"onion", 1200, 70, 150, 1, 0, 10, "unlock3x1"} --14
}
friends = {
	matsala={200, 400}
}
survey = {
	{"Single-Paned Windows", 0, 1, 1, 0, "Please Enter Number of Windows"},
	{"Double-Paned Windows", 0, 1, 1, 0, "Please Enter Number of Windows"},
	{"Single-Paned Windows south", 0, 0, 1, 0, "Please Enter Number of Windows"},
	{"Double-Paned Windows", 0, -1, 1, 0, "Please Enter Number of Windows"},
	{"Insulation", 0, -5, {1, 0.25, 0.5, 1.1, 1.5, 1.7, 5, 0.875, 0.6125, 0.7875, 1, 0.975, 1.2, 1.25, 1.7, 0.875, 0}, 
	{"High Density Blanket Batts and Rolls", "Concrete Blocks", "Concrete Block w/ Foam", "Polystyrene Foam board", "Polyurethane Foam Board", 
		"Polyisocyanurate (Polyiso) Foam Board", "Insulating Concrete Forms", "Loose-fill and blown-in Cellulose", 
		"Loose-fill and blown-in Fiberglass", "Loose-fill and blown-in Rock Wool", "Rigid Fibrous or Fiber Insulation", 
		"Sprayed Foam or Foamed-in-place (cementitious)", "Sprayed Foam or Foamed-in-place (phenolic)", "Sprayed Foam or Foamed-in-place (Polyurethane)", 
		"Sprayed Foam or Foamed-in-place (Polyisocyanurate or polyiso)", "Structural Insulated Panels", "Don't Know"}, "Please Enter Insulation Thickness"},
	{"House Size", 0, 0.01, 1, 0, "Please Enter Square Footage"},
	{"Number of Doors", 0, 4, 1, 0, "Please Enter Number of Doors"},
	{"Number of LEDs", 0, 0.1, 1, 0, "Please Enter Number of LEDs"},
	{"Number of Flourescents", 0, 0.5, 1, 0, "Please Enter Number of Flourescents"},
	{"Number of Incandescent", 0, 2, 1, 0, "Please Enter Number of Incandescent"},
	{"Number of Electric Appliance Hours", 0, 1, {.85, 1}, {"Energy Star", "Regular"}, "Please Enter Number of Hours"},
	{"Electric Vehicles", 0, -1, {7, 4, 32, 24, 16, 7.6, 72.5, 1.4, 0.7, 20, 16, 23, 53, 34, 42, 0}, 
		{"Ford Fusion Energi", "Toyota Prius", "BMW ActiveE", "Nissan Leaf", "Chevorlet Volt", "Ford C-Max Energi", 
		"Tesla Model S", "Infiniti M35h", "Mercedes-Benz S400 Hybrid", "Honda Fit EV", "Mitsubishi I-MiEV", "Ford Focus Electric", 
		"Tesla Roadster", "Coda", "Toyota RAV4 EV", "None"}, "Please Enter Number of Times You Charge Your EV"},
	{"Televisions", 0, 5, 1, 0, "Please Enter Number of Hours in Use"},
	{"Ceiling Fans", 0, 0.5, 1, 0, "Please Enter Number of Hours in Use"},
	{"AC", 0, 5, {3, 0.9}, {"Central", "Room (enter hours of use * number of rooms with AC)"}, "Please Enter Number of Hours in Use"},
	{"Refrigerator", 0, 5, 1, 0, "Please Enter Number of Refrigerators"},
	{"Dryers", 0, 4, {3.75, 0.4}, {"Dryer-Electric", "Dryer-Gas"}, "Please Enter Number of Hours in Use"},
	{"Heating System", 0, 5, {1, 1, 1}, {"Forced Air", "Air Heaters (Per Room)", "Radiant Heaters"}, "Please Enter Number of Hours in Use"},
	{"Dishwasher", 0, 3, {0.8125, 0.5}, {"Dishwasher-Heat", "Dishwasher-Air"}, "Please Enter Number of Hours in Use"},
	{"Water Heater", 0, 5, {1, 1, 1}, {"Regular", "On Demand", "Solar Thermal"}, "Please Enter Number of Hours in Use"}
}
local audioVolume = 1
local backgroundVolume = 1
audio.setVolume( audioVolume, { channel = 1 } )
audio.setVolume( audioVolume, { channel = 2 } )
audio.setVolume( audioVolume, { channel = 3 })
audio.setVolume( audioVolume, { channel = 4 })
audio.setVolume( backgroundVolume, { channel = 5 })
audioLoaded = audio.loadSound( "sounds.mp3" )
audio.play( audioLoaded, { channel = 5, loops = -1 } ) 

-- SET UP MENU BAR

menuBar = display.newGroup()
menuBar.x = 1
menuBar.y = 1

local menuRect = display.newRect(0,0,350,59)
gr = graphics.newGradient({200,24,50},{255,255,1})
menuRect:setFillColor( gr )
local money1title = display.newText("Money", 60, 10, "Times New Roman", 15)
local money1t = display.newText(money, 60, 25, "Helvetica", 12)
local clicker1title = display.newText("Clicker", 150, 10, "Times New Roman", 15)
local clicker1t = display.newText("None", 150, 35, 320, 0, "Helvetica", 12)
local energy1title = display.newText("Energy", 250, 10, "Times New Roman", 15)
local energy1t = display.newText(energy, 250, 25, "Helvetica", 12)
friendreqls = {}

menuBar:insert( menuRect )
menuBar:insert( money1title )
menuBar:insert( money1t )
menuBar:insert( clicker1title )
menuBar:insert( clicker1t )
menuBar:insert( energy1title )
menuBar:insert( energy1t )
menuBar.alpha = menuTransparency
local options = 
{
	-- Required params
	width = 64,
	height = 64,
	numFrames = 256,

	-- content scaling
	sheetContentWidth = 1024,
	sheetContentHeight = 1024,
}
local sheet = graphics.newImageSheet( "dancers@2.png", options )

local sequenceData = {}

local w = 64
local h = 64
local halfW = w*0.5
local halfH = h*0.5

-- SET SEQUENCE TABLE 

local sequencetable = {}
for rows = 1, 46 do
	local numFrames = 4
	local realrow = math.round( ( rows ) / 3 ) + 1
	local realcol = ( ( rows + 1 ) % 3 ) + 1
	if rows == 1 then
		realcol = 1
		realrow = 1
	end
	local start = ( realrow * 16 ) - 19 + ( 4 * realcol )
	local dancerx = "dancerx" .. rows
	local sequence = { name=dancerx, start=start, count=numFrames, time=1000, loopDirection="bounce" }
	table.insert (sequencetable, sequence)
end	


-- {SET UP KID TABLES, KID SPRITE SEQUENCE}
kids_moving = {
	"no",
	"no",
	"no"
	}

number_of_kids = 1

field_to_work_on = {} -- THIS IS THE ARRAY WITH FIELDS THAT HAVE BEEN PLANTED


-- regular indexOf method to find the index position of objects within a display group, returns nil or nf param if not found
-- param t: display group to look in
-- param obj: display object to look for
-- param nf: value to return when the obj is not found within the t display group
display.indexOf = function( t, obj, nf )
        for i=1, t.numChildren do
                if (t[i] == obj) then
                        return i
                end
        end
        if (nf) then
                return nf
        else
                return nil
        end
end

local kid_options = 
{
	-- Required params
	width = 100,
	height = 100,
	numFrames = 128,

	-- content scaling
	sheetContentWidth = 1600,
	sheetContentHeight = 800,
}
local kid_sheet = graphics.newImageSheet( "Characters.png",kid_options )

local kidsequenceData = {}

local kid_w = 100
local kid_h = 100
local kid_halfW = w*0.5
local kid_halfH = h*0.5
local kidsequencetable = {}
for rows = 1, 3 do
	local kidx = "kidx" .. rows
	local numFrames = 4
	local start = ( rows * 16 ) - 15 +4
	local sequence = { name=kidx, start=start, count=numFrames, time=1000, loopDirection="bounce" }
	table.insert (kidsequencetable, sequence)
end	


page = 0
local function createTiles( x, y, xMax, yMax, group )
	local xStart = x
	local j = 0
	while ( true ) do
		local i = 1+math.fmod( j, 16 )
		j = j + 1
		
		local dancer = "dancerx" .. i
		local numFrames = 4
		local start = (i % 16)*numFrames + 1

		local sprite

		sprite = display.newSprite( sheet, sequencetable )
		
function sprite:tap(event) 
	if event.numTaps == 2 then
	local touchedSprite = event.target 
	if clicker == 15 and touchedSprite.running == 1 then
		if energy >= 15 then
			local runner = 2 + ( ( clicker - 2 ) * 3 )
			touchedSprite:setSequence( "dancerx" .. runner )
			touchedSprite:play()
			touchedSprite.time = os.time()
			touchedSprite.running = runner
			encodeSprite( Tiles, spriteTable )
			saveTable( spriteTable, "spriteSave.json")
			energy = energy - 15
			energy1t.text = energy
			toSave = {}
			encoder( money, energy, toSave)
			saveTable( toSave, "toSave.json" ) 
			
			-- {Add sprite to list of fields to plow}
			sprite_index = display.indexOf( group, touchedSprite)
			table.insert(field_to_work_on,sprite_index)

		else
			clicker1t.text = "You don't have enough energy."
		end
	elseif clicker == 16 and touchedSprite.running == 1 then
		if energy >= 15 then
			local runner = 2 + ( ( clicker - 2 ) * 3 )
			touchedSprite:setSequence( "dancerx" .. runner )
			touchedSprite:play()
			touchedSprite.time = os.time()
			touchedSprite.running = runner
			encodeSprite( Tiles, spriteTable )
			saveTable( spriteTable, "spriteSave.json")
			energy = energy - 15
			energy1t.text = energy
			toSave = {}
			encoder( money, energy, toSave)
			saveTable( toSave, "toSave.json" ) 
			
			-- {Add sprite to list of fields to plow}
			sprite_index = display.indexOf( group, touchedSprite)
			table.insert(field_to_work_on,sprite_index)

		else
			clicker1t.text = "You don't have enough energy."
		end
	else
	if touchedSprite.running == 1 and clicker ~= 1 then
			if money >= plantstable[clicker][3] then
				local runner = 2 + ( ( clicker - 2 ) * 3 )
				touchedSprite:setSequence( "dancerx" .. runner )
				touchedSprite:play()
				touchedSprite.time = os.time()
				touchedSprite.running = runner
				encodeSprite( Tiles, spriteTable )
				saveTable( spriteTable, "spriteSave.json")
				money = money - plantstable[clicker][3]
				money1t.text = money
				toSave = {}
				encoder( money, energy, toSave)
				saveTable( toSave, "toSave.json" )
				audio.stop(1)
				audioLoaded = audio.loadSound( "soil.wav" )
				audio.play( audioLoaded, { channel = 1, loops = 0 } ) 
				
				-- {Add sprite to list of fields to plow}
				sprite_index = display.indexOf( group, touchedSprite)
				table.insert(field_to_work_on,sprite_index)

			elseif touchedSprite.sequence == "dancerx1" then
				clicker1t.text = "That costs too much."
			end
		else
			z = touchedSprite.running
			local temporary = z - 2
			local modulo = temporary % 3
			local plantindex = (temporary - modulo)/3 + 2
			if modulo == 2 and touchedSprite.running ~= 1 then
				touchedSprite:setSequence( "dancerx1" )
				touchedSprite:play()
				touchedSprite.running = 1
				encodeSprite( Tiles, spriteTable )
				saveTable( spriteTable, "spriteSave.json")
				money = money - 10
				money1t.text = money
				toSave = {}
				encoder( money, energy, toSave)
				saveTable( toSave, "toSave.json" ) 
				
				-- {Add sprite to list of fields to plow}
				sprite_index = display.indexOf( group, touchedSprite)
				table.insert(field_to_work_on,sprite_index)
				
			elseif modulo == 1 then
				audio.stop (2)
				audioLoaded = audio.loadSound( "harvest.mp3" )
				audio.play( audioLoaded, { channel = 2, loops = 0 } )
				local plantindex = (temporary - modulo)/3 + 2
				if plantstable[plantindex][5] == 1 then
					money = money + plantstable[plantindex][4]
					money1t.text = money
					toSave = {}
					encoder( money, energy, toSave)
					saveTable( toSave, "toSave.json" ) 
					local wither = z + 1
					touchedSprite:setSequence( "dancerx" .. wither )
					touchedSprite.time = touchedSprite.time - ( 4 * plantstable[plantindex][2] )
					encodeSprite( Tiles, spriteTable )
					saveTable( spriteTable, "spriteSave.json")
				elseif plantstable[plantindex][5] == 0 then
					money = money + plantstable[plantindex][4]
					money1t.text = money
					toSave = {}
					encoder( money, energy, toSave)
					saveTable( toSave, "toSave.json" ) 
					local unharvest = z - 1
					touchedSprite.time = os.time()
					touchedSprite:setSequence( "dancerx" .. unharvest )
					touchedSprite.running = unharvest
					encodeSprite( Tiles, spriteTable )
					saveTable( spriteTable, "spriteSave.json")
				end
			end
		end
	end
end
end
			
		sprite:addEventListener( "tap", sprite )
		sprite.running = 1
						
		if ( group ) then
			group:insert( sprite )
			end

		sprite:translate( x, y )
		sprite:setSequence( "dancerx1" )
		sprite:play()	

		x = x + w
		if ( x > xMax ) then
			x = xStart
			y = y + h
		end

		if ( y > yMax ) then
			break
		end
	end

end

local function createTileGroup( nx, ny )
	local group = display.newGroup( sheet )
	group.xMin = -(nx-1)*display.contentWidth - halfW
	group.yMin = -(ny-1)*display.contentHeight - halfH
	group.xMax = halfW
	group.yMax = halfH
	function group:touch( event )

		if ( "began" == event.phase ) then
			self.xStart = self.x
			self.yStart = self.y
			self.xBegan = event.x
			self.yBegan = event.y
		elseif ( "moved" == event.phase ) then
			local dx = event.x - self.xBegan
			local dy = event.y - self.yBegan
			local x = dx + self.xStart
			local y = dy + self.yStart
			if ( x < self.xMin ) then x = self.xMin end
			if ( x > self.xMax ) then x = self.xMax end
			if ( y < self.yMin ) then y = self.yMin end
			if ( y > self.yMax ) then y = self.yMax end
			self.x = x
			self.y = y
			if x - self.xStart == 0 and y - self.yStart == 0 then
				return true
			end
		end
		return true
	end
	group:addEventListener( "touch", group )
	
	
	local x = halfW
	local y = halfH
	
	local xMax = nx * display.contentWidth
	local yMax = ny * display.contentHeight
	
	createTiles( x, y, xMax, yMax, group )

	return group
end
local nx = 2
local ny = 2

Tiles = createTileGroup( nx, ny )

-- {Add Kids to Tile}

local function createKidTiles( kid, kid_x, kid_y, group )
		

		kid_sprite_1 = display.newSprite( kid_sheet, kidsequencetable )
		
		kid_sprite_1:translate( kid_x, kid_y )
		kid_sprite_1:setSequence( "kidx" .. kid )
		kid_sprite_1:play()
		group:insert(kid_sprite_1) 

	end

createKidTiles( 3, 70, 230, Tiles )


--

local prevTime = system.getTimer()




local plantsf = function( event )
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )
	plantset.alpha = 1
	pbackground.alpha = .2
	return true
end

menuBar:toFront();

local menuf = function( event )
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )
	menuset.alpha = menuTransparency
	mbackground.alpha = .2
	return true
end

local closeseed = function( event )
	plantset.alpha = 0
	menu.alpha = menuTransparency
	return true
end
local rightf = function( event )
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )
	if ( page < 4) then
		page = page + 1
		plant1t.text = plantstable[(page * 6) + 1][1]
		plant2t.text = plantstable[(page * 6) + 2][1]
		plant3t.text = plantstable[(page * 6) + 3][1]
		plant4t.text = plantstable[(page * 6) + 4][1]
	end
	return true
end
local leftf = function( event )
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )
	if ( page > 0 ) then
		page = page - 1
		plant1t.text = plantstable[(page * 6) + 1][1]
		plant2t.text = plantstable[(page * 6) + 2][1]
		plant3t.text = plantstable[(page * 6) + 3][1]
		plant4t.text = plantstable[(page * 6) + 4][1]
	end
	return true
end

local unlockf = function( event )
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )
	unlockset.alpha = menuTransparency
	unlockclose.alpha = 1
	background.alpha = .1
end

local planter1 = function( event )
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )
	print "plant clicked"
	if plantstable[(page * 6) + 1][6] == 1 then
		clicker = (page * 6) + 1
		clicker1t.text = plantstable[(page * 6) + 1][1]
		return true
	else
		clicker1t.text = "You're out of those seeds!"
		clicker = 0
	end
	return true
end

local planter2 = function( event )
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )
	if plantstable[(page * 6) + 2][6] == 1 then
		clicker = (page * 6) + 2
		clicker1t.text = plantstable[(page * 6) + 2][1]
		return true
	else
		clicker1t.text = "You're out of those seeds!"
		clicker = 0
	end
	return true
end

local planter3 = function( event )
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )
	if plantstable[(page * 6) + 3][6] == 1 then
		clicker = (page * 6) + 3
		clicker1t.text = plantstable[(page * 6) + 3][1]
		return true
	else
		clicker1t.text = "You're out of those seeds!"
		clicker = 0
	end
	return true
end

local planter4 = function( event )
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )
	if plantstable[(page * 6) + 4][6] == 1 then
		clicker = (page * 6) + 4
		clicker1t.text = plantstable[(page * 6) + 4][1]
		return true
	else
		clicker1t.text = "You're out of those seeds!"
		clicker = 0
	end
	return true
end

local planter5 = function( event )
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )
	if plantstable[(page * 6) + 5][6] == 1 then
		clicker = (page * 6) + 5
		clicker1t.text = plantstable[(page * 6) + 5][1]
		return true
	else
		clicker1t.text = "You're out of those seeds!"
		clicker = 0
	end
	return true
end

local planter6 = function( event )
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )
	if plantstable[(page * 6) + 6][6] == 1 then
		clicker = (page * 6) + 6
		clicker1t.text = plantstable[(page * 6) + 6][1]
		return true
	else
		clicker1t.text = "You're out of those seeds!"
		clicker = 0
	end
	return true
end


local resetmain = function( event )
	menu.alpha = menuTransparency
	menuset.alpha = 0
	return true
end
local unlockclosef = function( event )
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )
	menu.alpha = menuTransparency
	unlockset.alpha = 0
	unlockclose.alpha = 0
	return true
end

unlockset = display.newGroup()

background = display.newImage( "background2.png", true )

background.x = 130; background.y = 240;

unlockset:insert( background )

background.alpha = .2

local unlock1x1 = display.newImage( "blueberryg.png" )

unlock1x1.x, unlock1x1.y = 100, 173

unlock1x1.value = 5

unlock1x1.id = 0

unlockset:insert( unlock1x1 ) 

local unlock1x2 = display.newImage( "peachg.png" ) 

unlock1x2.x, unlock1x2.y = 100,380.5

unlock1x2.value = 9

unlock1x2.id = 0

unlockset:insert( unlock1x2 ) 

local unlock2x1 = display.newImage( "pumpking.png" )

unlock2x1.x, unlock2x1.y = 285, 213.5

unlock2x1.value = 10

unlock2x1.id = 5

unlockset:insert( unlock2x1 )

local unlock2x2 = display.newImage( "grapeg.png" )

unlock2x2.x, unlock2x2.y = 285, 132.5

unlock2x2.value = 11

unlock2x2.id = 5

unlockset:insert( unlock2x2 )

local unlock2x3 = display.newImage( "appleg.png" )

unlock2x3.x, unlock2x3.y = 285, 340

unlock2x3.value = 6

unlock2x3.id = 9

unlockset:insert( unlock2x3 )

local unlock2x4 = display.newImage( "chileg.png" )

unlock2x4.x, unlock2x4.y = 285, 421

unlock2x4.value = 13

unlock2x4.id = 9

unlockset:insert( unlock2x4 ) 

local unlock3x1 = display.newImage( "oniong.png" )

unlock3x1.x, unlock3x1.y = 474, 92

unlock3x1.value = 14

unlock3x1.id = 10

unlockset:insert( unlock3x1 )

local unlock3x2 = display.newImage( "riceg.png" )

unlock3x2.x, unlock3x2.y = 474, 173

unlock3x2.value = 12

unlock3x2.id = 10

unlockset:insert( unlock3x2 )

local unlock3x5 = display.newImage( "peachg.png" )

unlock3x5.x, unlock3x5.y = 474, 380.5

unlock3x5.value = 7

unlock3x5.id = 6

unlockset:insert( unlock3x5 )

local unlock3x6 = display.newImage( "bananag.png" )

unlock3x6.x, unlock3x6.y = 474, 299.5

unlock3x6.value = 8

unlock3x6.id = 6

unlockset:insert( unlock3x6 )

unlockclose = widget.newButton{
	default = "close.png",
	onPress = unlockclosef
}

unlockclose.x, unlockclose.y = 307, 12

unlocktouch = function( event )
	if event.phase == "began" then
		if event.target.id == 0 then
			important = event.target.value
			if plantstable[event.target.value][6] == 0 and energy >= plantstable[important][7] then
				plantstable[event.target.value][6] = 1
				energy = energy - plantstable[important][7]
				energy1t.text = energy
				toSave = {}
				encoder( money, energy, toSave)
				saveTable( toSave, "toSave.json" ) 
				print(plantstable[event.target.value][8])
				clicker1t.text = ( "You unlocked " .. plantstable[event.target.value][1] )
				unlock1x1:removeSelf()
				plantstable[event.target.value][8] = nil
				plantstable[event.target.value][8] = display.newImage( plantstable[event.target.value][1] .. "g2.png", 100, 173 )
				plantstable[event.target.value][8]:addEventListener( "touch", unlocktouch )
				plantstable[event.target.value][8].x, plantstable[event.target.value][8].y = 100, 173
				plantstable[event.target.value][8].value = 5
				plantstable[event.target.value][8].id = 0
				unlockset:insert( plantstable[event.target.value][8] )
			elseif energy < plantstable[important][7] then
				clicker1t.text = "You don't have enough energy."
			else
				clicker1t.text = "That is already unlocked."
			end
		elseif plantstable[event.target.id][6] == 1 then
			important = event.target.value
			if plantstable[event.target.value][6] == 0 and energy >= plantstable[important][7] then
				plantstable[event.target.value][6] = 1
				energy = energy - plantstable[important][7]
				energy1t.text = energy
				toSave = {}
				encoder( money, energy, toSave)
				saveTable( toSave, "toSave.json" ) 
				clicker1t.text = ( "You unlocked " .. plantstable[event.target.value][1] )
			elseif energy < plantstable[important][7] then
				clicker1t.text = "You don't have enough energy."
			else
				clicker1t.text = "That is already unlocked."
			end
		else
			local once = plantstable[event.target.id][1]
			clicker1t.text = ( "You have to unlock \n" .. once .. " first" )
		end
	end
	return true
end

unlock1x1:addEventListener( "touch", unlocktouch )
unlock1x2:addEventListener( "touch", unlocktouch )
unlock2x1:addEventListener( "touch", unlocktouch )
unlock2x2:addEventListener( "touch", unlocktouch )
unlock2x3:addEventListener( "touch", unlocktouch )
unlock2x4:addEventListener( "touch", unlocktouch )
unlock3x1:addEventListener( "touch", unlocktouch )
unlock3x2:addEventListener( "touch", unlocktouch )
unlock3x5:addEventListener( "touch", unlocktouch )
unlock3x6:addEventListener( "touch", unlocktouch )

function unlockset:touch( event )
    if event.phase == "began" then
    	
        self.markX = self.x    -- store x location of object
        self.markY = self.y    -- store y location of object
        
    elseif event.phase == "moved" then
	
        local x = (event.x - event.xStart) + self.markX
        local y = (event.y - event.yStart) + self.markY
        
        if ( x > rightLimit ) then
        	x = rightLimit
        end
        if ( x < leftLimit ) then
        	x = leftLimit
        end
        if ( y < bottomLimit ) then
        	y = bottomLimit
        end
        if ( y > topLimit ) then
        	y = topLimit
        end
        self.x, self.y = x, y    -- move object based on calculations above

    end
    return true
end

unlockset:addEventListener( "touch", unlockset )


unlockset.x, unlockset.y = 0, 0

local function onRowRender( event )
	local row = event.row
	for key in pairs(row) do
		print (key)
	end

	if row.isCategory == false then
			print ("running onRowRender")
		
			local id = row.index
			counter = 1

			for key, v in pairs(friends) do
				if id == counter then
					print (key .. " key")
					name = key
					break
				end
				counter = counter + 1
			end
			
			row.textObj = display.newRetinaText( event.view, name .. "      " .. friends[name][1] .. "   " .. friends[name][2], 0, 0, native.systemFont, 16 )
			row.textObj:setTextColor( 0 )
			row.textObj:setReferencePoint( display.CenterLeftReferencePoint )
			row.textObj.x, row.textObj.y = 20, event.view.contentHeight * 0.5
		
			return true
	end
end

local function onRowRender2( event )
	local row = event.row

	if row.isCategory == false then
			print ("running onRowRender")
		
			local id = row.index

			row.textObj = display.newRetinaText( event.view, survey[id][1], 0, 0, native.systemFont, 16 )
			row.textObj:setTextColor( 0 )
			row.textObj:setReferencePoint( display.CenterLeftReferencePoint )
			row.textObj.x, row.textObj.y = 20, event.view.contentHeight * 0.5
		
			return true
	end
end

quan = ""

local function onRowTouch( event )
	local row = event.row
	local background = event.background
	
	if event.phase == "press" then
		print( "Pressed row: " .. row.index )
		background:setFillColor( 0, 110, 233, 255 )

	elseif event.phase == "release" or event.phase == "tap" then

		if survey[row.index][5] == 0 then
			local function inputListenerquan( event )
			    if event.phase == "began" then
			
			        -- user begins editing textBox
			
			    elseif event.phase == "ended" then
					
					jsontemporary = json.encode(quan)
			        filenamer = (survey[row.index][1] .. "quan")
			        saveTable( jsontemporary, filenamer .. ".json")
			        textBox4:removeSelf()
			
			    elseif event.phase == "editing" then
			
			    	quan = event.text
			
			    end
			end
			textBox4 = native.newTextBox( 0, 0, 325, 55 )
				filenamer = (survey[row.index][1] .. "quan")
				if loadTable( filenamer..".json" ) == nil then
					textBox4.text = survey[row.index][6]
				else
					texts = json.decode(loadTable( filenamer .. ".json" ))
					textBox4.text = texts
				end
				textBox4.isEditable = true
				textBox4:addEventListener( "userInput", inputListenerquan )
		else
			subsurvey = survey[row.index][5]
			optionset.alpha = 0
			textBox:removeSelf()
			textBox2:removeSelf()
			textBox7:removeSelf()

			local function inputListenerquan2( event )
			    if event.phase == "began" then
			
			        -- user begins editing textBox
			
			    elseif event.phase == "ended" then
					
					jsontemporary = json.encode(quan)
			        filenamer = (subsurvey[1] .. "quan")
			        saveTable( jsontemporary, filenamer .. ".json")
			        textBox5:removeSelf()
			        surveyw:removeSelf()
			
			    elseif event.phase == "editing" then
			
			    	quan = event.text
			
			    end
			end
			textBox5 = native.newTextBox( 0, 340, 325, 140 )
				filenamer = (subsurvey[1] .. "quan")
				if loadTable( filenamer..".json" ) == nil then
					textBox5.text = survey[row.index][6]
				else
					texts = json.decode(loadTable( filenamer .. ".json" ))
					textBox5.text = texts
				end
				textBox5.isEditable = true
				textBox5:addEventListener( "userInput", inputListenerquan2 )

			local function onRowRender3( event )
				local row = event.row
			
				if row.isCategory == false then
						print ("working")
					
						local id = row.index
			
						row.textObj = display.newRetinaText( event.view, subsurvey[id], 0, 0, native.systemFont, 16 )
						row.textObj:setTextColor( 0 )
						row.textObj:setReferencePoint( display.CenterLeftReferencePoint )
						row.textObj.x, row.textObj.y = 20, event.view.contentHeight * 0.5
					
						return true
				end
			end

			surveyw = widget.newTableView{
				left = 0,
				top = 0,
				height = 300,
				width = 350,
				onRowRender = onRowRender3,
				listener = onRowTouch2
			}

			local function onRowTouch2( event )
				local row = event.row
				local background = event.background
				
				if event.phase == "press" then
					print( "Pressed row: " .. row.index )
					background:setFillColor( 0, 110, 233, 255 )
			
				elseif event.phase == "release" or event.phase == "tap" then

					background:setFillColor( 0, 0, 0, 0 )
					row.reRender = true
					for i=1, #survey do
						if survey[i][5] == subsurvey then
							pointer = i
						end
					end
					jsontemporary = survey[pointer][5][row.index]
					namer = survey[pointer][1] .. "type"
					saveTable( jsontemporary, namer .. ".json")
					textBox5.text = "You have selected " .. subsurvey[row.index]
				end
			end

			for i=1, #subsurvey do
				print(i)
				surveyw:insertRow( {
					params = {name = subsurvey[i]},
					onRender = onRowRender3,
					isCategory = false,
					listener = onRowTouch2
				})
end
		end

		print( "Tapped and/or Released row: " .. row.index )
		background:setFillColor( 0, 0, 0, 0 )
		row.reRender = true
	end
end

groupsset = widget.newTableView{
	left = 0,
	top = 115,
	height = 375,
	width = 350,
	onRowRender = onRowRender
}

plantset = display.newGroup()

local plant1 = widget.newButton{
	default = "unlockedtemplate.png",
	onPress = planter1,
	onRelease = closeseed
}
local plant2 = widget.newButton{
	default = "unlockedtemplate.png",
	onPress = planter2,
	onRelease = closeseed
}
local plant3 = widget.newButton{
	default = "unlockedtemplate.png",
	onPress = planter3,
	onRelease = closeseed
}
local plant4 = widget.newButton{
	default = "unlockedtemplate.png",
	onPress = planter4,
	onRelease = closeseed
}
local arrowright = widget.newButton{
	default = "rightarrow.png",
	onPress = rightf,
}
local arrowleft = widget.newButton{
	default = "leftarrow.png",
	onPress = leftf,
}

pbackground = display.newImage( "background.png" )

pbackground.x = 130; pbackground.y = 240;
plant1.x = 150; plant1.y = 100
plant2.x = 150; plant2.y = 188
plant3.x = 150; plant3.y = 276
plant4.x = 150; plant4.y = 364
arrowright.x = 290; arrowright.y = 220;
arrowleft.x = 20; arrowleft.y = 220;

returntrue = function( event )
	return true
end

pbackground:addEventListener( "touch", returntrue )


planttext = display.newGroup()

plant1t = display.newText( plantstable[1][1], 45, 135, "Times New Roman", 20)
plant2t = display.newText( plantstable[2][1], 175, 135, "Times New Roman", 20)
plant3t = display.newText( plantstable[3][1], 45, 255, "Times New Roman", 20)
plant4t = display.newText( plantstable[4][1], 175, 255, "Times New Roman", 20)

planttext:insert( plant1t )
planttext:insert( plant2t )
planttext:insert( plant3t )
planttext:insert( plant4t )

plantset:insert( pbackground )
plantset:insert( arrowright )
plantset:insert( arrowleft )
plantset:insert( plant1 )
plantset:insert( plant2 )
plantset:insert( plant3 )
plantset:insert( plant4 )
plantset:insert( plant1t )
plantset:insert( plant2t )
plantset:insert( plant3t )
plantset:insert( plant4t )

local energyclosef = function( event )
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )
	menu.alpha = menuTransparency
	energyclose.alpha = 0
	energyset.alpha = 0
	return true
end

energyset = display.newGroup()

ebackground = display.newImage( "background.png" ) 

ebackground.x = 130; ebackground.y = 240;

ebackground:addEventListener( "touch", returntrue )

energyset:insert( ebackground )

usage = display.newImage( "Energystuff2.png" )

usage.x = 150; usage.y = 300;

usage.alpha = 0

local solarf = function( event )
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )
	clicker = 16
	clicker1t.text = "Solar Panels"
	menu.alpha = menuTransparency
	energyclose.alpha = 0
	energyset.alpha = 0
end

local windf = function( event )
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )
	clicker = 15
	clicker1t.text = "Windmills"
	menu.alpha = menuTransparency
	energyclose.alpha = 0
	energyset.alpha = 0
end

energyclose = widget.newButton {
	default = "close.png",
	onPress = energyclosef
}

energyclose.x, energyclose.y = 307, 12

local solar = widget.newButton {
	default = "solar_panel.png",
	onPress = solarf
}

solar.x, solar.y = 150, 150

energyset:insert( solar )

local wind = widget.newButton{
	default = "Windmill.png",
	onPress = windf
}

wind.x, wind.y = 150, 300

energyset:insert( wind )

menu = widget.newButton{
	default = "menu.png",
	over = "menu.png",
	onPress = menuf
}
menuBar:insert(menu)

local closemain = function( event )
	menuset.alpha = 0
	return true
end
local unlockf = function( event ) 
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )
	unlockset.alpha = menuTransparency
	unlockclose.alpha = 1
	return true
end

local energyf = function( event )
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )
	energyset.alpha = 1
	ebackground.alpha = .2
	energyclose.alpha = 1
	return true
end

function networkListenerf( event )
		if ( event.isError ) then
			print("Error")
		else
			responsefr = json.decode(event.response)
			for i=1, #responsefr['requests'] do
				table.insert( friendreqls, Each)
			end
			print (event.response)
			if #responsefr['requests'] == 0 then
				textBox6:removeSelf()
				groupyes:removeSelf()
				groupno:removeSelf()
			end
			for key in pairs(friends) do
				if responsefr[key] ~= nil then
					friends[key] = responsefr[key]
				end
			end
		end
	end

function groupclosef( event )
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )

	groupyes:removeSelf()
	groupno:removeSelf()
	groupclose.alpha = 0
	gbackground.alpha = 0
	groupfinalset.alpha = 0
	groupclose.alpha = 0
	groupsset.alpha = 0
	submit.alpha = 0
	textBox3:removeSelf()
	textBox6:removeSelf()
end

groupclose = widget.newButton{
	default = "close.png",
	onPress = groupclosef
}

groupclose.x, groupclose.y = 307, 12
groupclose.alpha = 0

groupfinalset = display.newGroup()

--
groupfinalset:insert(groupsset)
--
groupfinalset.alpha = 0

grbackground = display.newImage( "background.png" ) 
grbackground.x = 150
grbackground.y = 10

grouptitle = display.newText( "Friends", 100, 10, "Times New Roman", 40)

groupfinalset:insert(grbackground)

groupfinalset:insert(grouptitle)

grouptitle:toFront()

groupsset:toFront()

optionset = display.newGroup()

obackground = display.newImage( "background.png" ) 

obackground.x = 130; obackground.y = 240;

obackground.alpha = 0

obackground:toBack()

Tiles:toBack()

friendreq = ""

function networkListenerfg( event )
		if ( event.isError ) then
			print("Error")
		else

			if responsefr['friendRequest'] ~= nil then
				textBox3.text = responsefr["friendRequest"]
			else
				textBox3.test = "Invalid username"
			end
		end
	end

local groupsf = function( event )
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )
	submit.alpha = 1
	submit:toFront()
	local yesf = function( event )
		audioLoaded = audio.loadSound( "button.mp3" )
		audio.play( audioLoaded, { channel = 4, loops = 0 } )
		groupyes.alpha = 0
		groupno.alpha = 0
	end
	groupyes = widget.newButton{
		default = "button.png",
		onPress = yesf,
		label = "Yes"
	}
	groupyes.x, groupyes.y = 80, 250
	local nof = function( event )
		audioLoaded = audio.loadSound( "button.mp3" )
		audio.play( audioLoaded, { channel = 4, loops = 0 } )
		groupno.alpha = 0
		groupyes.alpha = 0
	end
	groupno = widget.newButton{
		default = "button.png",
		onPress = nof,
		label = "No"
	}
	groupno.x, groupno.y = 220, 250

	local paramsg = {}
	bodyg = {
		todo = friends,
		typeage = "update",
		SAID = "1823927350",
		PIN = "999888"
	}
	paramsg.body = json.encode(bodyg)
	print (bodyg)
	network.request( "http://secure.plant-a-watt.org/friends/pythonhandler.py", "POST", networkListenerf, paramsg)
	groupsset:deleteAllRows()
	for key, v in pairs(friends) do
		groupsset:insertRow( {
			params = {name = key, money = v[1], energy = v[2]},
			onRender = onRowRender,
			isCategory = false
			}
		)
	end
	gbackground.alpha = .2
	groupfinalset.alpha = 1
	groupsset.alpha = 1
	groupclose.alpha = 1
	submit.alpha = 1
	groupclose:toFront()
	groupsset:toFront()
	textBox3 = native.newTextBox( 0, 60, 325, 55 )
	textBox3.text = "Request a friend here!"

	friendrequest = ""
	
	local function inputListenerfriend( event )
	    if event.phase == "began" then

	    elseif event.phase == "ended" then
	
	    elseif event.phase == "editing" then

	    	Friendrequest = event.text
	    	print(Friendrequest)
   		end
	end
	textBox3.isEditable = true
	textBox3:addEventListener( "userInput", inputListenerfriend )

textBox6 = native.newTextBox( 0, 375, 325, 100 )
textBox6.isEditable = false

end

local function submitf( event )
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )
	textBox3.text = "Please wait..."
	local paramsg2 = {}
	print(Friendrequest)
	SAIDES = json.decode(loadTable( "SAID.json" ))
	PINES = json.decode(loadTable( "PIN.json" ))
	bodyg2 = {
		todo = Friendrequest,
		typeage = "friendRequest",
		SAID = SAIDES,
		PIN = PINES
	}
	print(bodyg2['typeage'])
	paramsg2.body = json.encode(bodyg2)
	network.request( "http://secure.plant-a-watt.org/friends/pythonhandler.py", "POST", networkListenerfg, paramsg2)
	return true
end	

submit = widget.newButton{
		default = "button2.png",
		onPress = submitf,
		label = "Go"
	}

submit.x, submit.y = 20, 20

groupfinalset:insert(submit)

submit.alpha = 0

PIN = ""

local function inputListenerPIN( event )
    if event.phase == "began" then

        -- user begins editing textBox

    elseif event.phase == "ended" then

        jsontemporary = json.encode(PIN)
        saveTable( jsontemporary, "PIN.json")

    elseif event.phase == "editing" then

    	PIN = event.text
        

    end
end

SAID = ""

local function inputListenerSAID( event )
    if event.phase == "began" then

        -- user begins editing textBox

    elseif event.phase == "ended" then

        jsontemporary = json.encode(SAID)
        saveTable( jsontemporary, "SAID.json")

    elseif event.phase == "editing" then

    	SAID = event.text


    end
end

local function optionclosef( event )
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )
	optionset.alpha = 0
	textBox:removeSelf()
	textBox2:removeSelf()
	textBox7:removeSelf()
	obackground.alpha = 0
	return true
end	

userna = ""

local function inputListenerusername ( event )
	if event.phase == "began" then

        -- user begins editing textBox

    elseif event.phase == "ended" then

        jsontemporary = json.encode(userna)
        saveTable( jsontemporary, "username.json")
        SAIDSS = json.decode(loadTable( "SAID.json" ))
		PINSS = json.decode(loadTable( "PIN.json" ))
		user = json.decode(loadTable("username.json"))
		body3 = {
			username = user, 
			SAID = SAIDSS, 
			PIN = PINSS
		}
		paramsa = {}
		paramsa.body = json.encode(body3)

		function networkListenera( event )
			if ( event.isError ) then
				print("Error")
			else
				print(event.response)
			end
		end
	
		network.request( "http://secure.plant-a-watt.org/account/pythonhandler.py", "POST", networkListenera, paramsa)

    elseif event.phase == "editing" then

    	userna = event.text

    end
end

local function optionsf( event )
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )
	optionset.alpha = 1
	obackground.alpha = 0.2
	menuset.alpha = 0
	optionclose.alpha = 1
	usage.alpha = 1
	optionclose:toFront()
	textBox = native.newTextBox( 0, 50, 160, 50 )
	if loadTable("SAID.json") == nil then
		textBox.text = "Please enter SAID"
	else
		SAIDS = json.decode(loadTable( "SAID.json" ))
		textBox.text = SAIDS
	end
	textBox.isEditable = true
	textBox:addEventListener( "userInput", inputListenerSAID )
	
	optionset:insert( textBox )
	
	textBox7 = native.newTextBox( 0, 100, 320, 50 )
	textBox7.isEditable = true
	textBox7:addEventListener( "userInput", inputListenerusername )
	if loadTable( "username.json" ) == nil then
		textBox7.text = "Please enter username"
	else
		USN = json.decode(loadTable( "username.json" ))
		textBox7.text = USN
	end

	textBox2 = native.newTextBox( 160, 50, 160, 50 )

	if loadTable( "PIN.json" ) == nil then
		textBox2.text = "Please enter PIN"
	else
		PINS = json.decode(loadTable( "PIN.json" ))
		textBox2.text = PINS
	end
	textBox2.isEditable = true
	textBox2:addEventListener( "userInput", inputListenerPIN )
	
	optionset:insert( textBox2 )
	optionclose:toFront()
end

optionclose = widget.newButton{
	default = "close.png",
	onPress = optionclosef,
}

optionclose.x, optionclose.y = 307, 12

optionset:insert( optionclose )

optionset.alpha = 0

menuset = display.newGroup()


local plants = widget.newButton{
	default = "plants.png",
	onPress = plantsf,
	onRelease = closemain
}
local groups = widget.newButton{
	default = "friends.png",
	onPress = groupsf,
	onRelease = closemain
}
local energybutton = widget.newButton{
	default = "altEnergy.png",
	onPress = energyf,
	onRelease = closemain
}
local unlock = widget.newButton{
	default = "unlocks.png",
	onPress = unlockf,
	onRelease = closemain
}
local options = widget.newButton{
	default = "energy.png",
	onPress = optionsf,
	onRelease = closemain
}
mbackground = display.newImage( "background.png" ) 
gbackground = display.newImage( "background.png" ) 

mbackground.x = 130; mbackground.y = 240;
gbackground.x = 130; gbackground.y = 240;
plants.x = 75; plants.y = 350
groups.x = 250; groups.y = 350
energybutton.x = 75; energybutton.y = 150
unlock.x = 250; unlock.y = 150
options.x = 160; options.y = 250

gbackground:toBack()
Tiles:toBack()

mbackground:addEventListener( "touch", returntrue )
obackground:addEventListener( "touch", returntrue )
gbackground:addEventListener( "touch", returntrue)
groupsset:toFront()

menuset:insert( mbackground )
menuset:insert( unlock )
menuset:insert( energybutton )
menuset:insert( plants )
menuset:insert( groups )
menuset:insert( options )

menuset.alpha = 0
plantset.alpha = 0
menu.alpha = menuTransparency
unlockset.alpha = 0
unlockclose.alpha = 0
energyset.alpha = 0
energyclose.alpha = 0
gbackground.alpha = 0
groupsset.alpha = 0



local checker = function( event )

	-- Move Kids	
	if table.maxn(field_to_work_on) > 0 then
		for kid_i = 1, number_of_kids do
			if kids_moving[1] == "no" then
				goto_field = field_to_work_on[1]
				table.remove(field_to_work_on,1)
				local to_x = Tiles[goto_field].x + Tiles.x
				local to_y = Tiles[goto_field].y + Tiles.y
				transition.to( kid_sprite_1, { time=500, x=to_x, y=to_y, alpha=1.0} )
				end
			end
		end
		
	for i = 1, 150 do
		if Tiles[i].running ~= 1 then
			local y = os.time() - Tiles[i].time
			local z = Tiles[i].running
			local temporary = z - 2
			local modulo = temporary % 3
			local plantindex = (temporary - modulo)/3 + 2
			if plantindex ~= 15 and plantindex ~= 16 then
				if modulo == 0 then
					if y > plantstable[plantindex][2] then
						if y < 4 * plantstable[plantindex][2] then
							local harvest = z + 1
							Tiles[i]:setSequence( "dancerx" .. harvest )
							Tiles[i].running = harvest
							Tiles[i]:play()
							encodeSprite( Tiles, spriteTable )
							saveTable( spriteTable, "spriteSave.json")
							audioLoaded = audio.loadSound( "plantg.wav" )
							audio.play( audioLoaded, { channel = 350, loops = 0 } )

						else
							local wither = z + 2
							Tiles[i]:setSequence( "dancerx" .. wither )
							Tiles[i].running = wither
							Tiles[i]:play()
							encodeSprite( Tiles, spriteTable )
							saveTable( spriteTable, "spriteSave.json")
						end
					end
				elseif modulo == 1 then
					if y > 4 * plantstable[plantindex][2] then
						local wither = z + 1
						Tiles[i]:setSequence( "dancerx" .. wither )
						Tiles[i].running = wither
						Tiles[i]:play()
						encodeSprite( Tiles, spriteTable )
						saveTable( spriteTable, "spriteSave.json")
					end
				elseif modulo == 2 then
					if y > 8 * plantstable[plantindex][2] then
						Tiles[i].running = 1
						Tiles[i]:setSequence( "dancerx1" )
						Tiles[i]:play()
						encodeSprite( Tiles, spriteTable )
						saveTable( spriteTable, "spriteSave.json")
					end
				end
			elseif plantindex == 15 then
				local x = Tiles[i].time
				x = os.time() - x
				if x > windreturn then
					if z == 41 then
						Tiles[i]:setSequence( "dancerx" .. 42 )
						Tiles[i]:play()
						local set = 42
						Tiles[i].running = set
						Tiles[i].time = os.time()
						encodeSprite( Tiles, spriteTable )
						saveTable( spriteTable, "spriteSave.json")
					else
						energy = energy + 3
						energy1t.text = energy
						toSave = {}
						encoder( money, energy, toSave)
						saveTable( toSave, "toSave.json" ) 
						Tiles[i].time = os.time()
						encodeSprite( Tiles, spriteTable )
						saveTable( spriteTable, "spriteSave.json")
					end
				end
			elseif plantindex == 16 then
				local x = Tiles[i].time
				x = os.time() - x
				if x > solarreturn then
					if z == 44 then
						Tiles[i]:setSequence( "dancerx" .. 45 )
						Tiles[i]:play()
						local set = 45
						Tiles[i].running = set
						Tiles[i].time = os.time()
						encodeSprite( Tiles, spriteTable )
						saveTable( spriteTable, "spriteSave.json")
					else
						energy = energy + 1
						energy1t.text = energy
						toSave = {}
						encoder( money, energy, toSave)
						saveTable( toSave, "toSave.json" ) 
						Tiles[i].time = os.time()
						encodeSprite( Tiles, spriteTable )
						saveTable( spriteTable, "spriteSave.json")
					end
				end
			end
		end
	end
end

Runtime:addEventListener( "enterFrame", checker )

local toSave = {}

function encoder( m, e, table )
	table[1] = m
	table[2] = e
end

function decodere( table )
	e = table[2]
	return e
end

function decoderm( table )
	m = table[1]
	return m
end

spriteTable = {}

function encodeSprite( sprites, table )
	for i = 1, 150 do
		t = i * 2
		y = t-1
		table[y] = sprites[i].running
		table[t] = sprites[i].time
	end
end	

function decodeSprite( sprites, table )
	for i = 1, 150 do
		t = i * 2
		y = t-1
		sprites[i].running = table[y]
		if sprites[i].running == nil then
			sprites[i].running = 1
		end
		sprites[i]:setSequence( "dancerx" .. sprites[i].running )
		sprites[i]:play()
		sprites[i].time = table[t]
		if sprites[i].time == nil then
			sprites[i].time = 0
		end
	end
end

function serverEncode ( m, e, S, P )
	finalTable = {
		money = m,
		energy = e,
		SAID = S,
		PIN = P
	}
	return finalTable
end

function networkListener( event )
		if ( event.isError ) then
			print("Error")
		else
			print ("Response: " .. event.response)
		end
	end

local params = {}

local function onSystemEvent( event )
	SAIDS = json.decode(loadTable( "SAID.json" ))
	PINS = json.decode(loadTable( "PIN.json" ))
	toSave = loadTable( "toSave.json" )
    energy = decodere( toSave )
    money = decoderm( toSave )
    print (SAIDS)
    print (PINS)
	body = serverEncode( money, energy, SAIDS, PINS )
	params.body = json.encode(body)
	print (params.body)

    if (event.type == "applicationExit") then


    elseif (event.type == "applicationStart") then
		
		print("applicationstart")
		network.request( "http://secure.plant-a-watt.org/smartphone/pythonhandler.py", "POST", networkListener, params)
        toSave = loadTable( "toSave.json" )
        energy = decodere( toSave )
        money = decoderm( toSave )
        print (toSave[1])
        money1t.text = money
        energy1t.text = energy
        spriteTable = loadTable( "spriteSave.json" )
        decodeSprite( Tiles, spriteTable )
        print (spriteTable)
        print ("spriteTable")
        plantstable = loadTable( "plant.json" )
        if plantstable == nil then
        	plantstable = {
					{"move", 0, 0, 0, 0, 1},
					{"grass", 30, 25, 50, 1, 1},
					{"strawberry", 10, 50, 150, 1, 1},
					{"corn", 3600, 80, 300, 1, 1},
					{"blueberry", 300, 7, 30, 1, 0, 5, "unlock1x1"}, --5
					{"apple", 86400, 1000, 10, 0, 0, 10, "unlock2x3"},
					{"peach", 43200, 5000, 700, 0, 0, 10, "unlock1x2"},
					{"banana", 172800, 500, 40, 0, 0, 15, "unlock3x6"},
					{"watermelon", 864000, 100, 100, 1, 0, 7},
					{"pumpkin", 32400, 300, 1000, 1, 0, 7, "unlock2x1"}, --10
					{"grape", 14400, 100, 700, 1, 0, 7, "unlock2x2"},
					{"rice", 3600, 100, 400, 1, 0, 10, "unlock3x2"},
					{"chile", 28800, 50, 350, 1, 0, 10, "unlock2x4"},
					{"onion", 1200, 70, 150, 1, 0, 10, "unlock3x1"} --14
			}
		end
        print ( plantstable )
        print ( "applicationstart" )
    end
end

Runtime:addEventListener( "system", onSystemEvent )

-- placeholder variables

Mw = 23
KwDays = 1
Trees = 37

XBubble = 200


ScoreScreen = display.newGroup ()

function close_scoreScreen ()
	audioLoaded = audio.loadSound( "button.mp3" )
	audio.play( audioLoaded, { channel = 4, loops = 0 } )
	ScoreScreen.alpha = 0
	end

function make_scoreScreen (group)	

myImage = display.newImage( "SpeechBubble2.png", 10, 45 )	
group:insert( myImage )

	
local scoreText1 = display.newEmbossedText( "Since ".. KwDays .. " days ago,", 0, 0, "Marker Felt Thin", 12 )
scoreText1:setReferencePoint( display.CenterReferencePoint )
scoreText1:setTextColor( 30 )
scoreText1.x = XBubble
scoreText1.y =  100
group:insert( scoreText1 )

local scoreText4 = display.newEmbossedText( "You have saved " .. Kw .. " Kw!", 0, 0, "Marker Felt Thin", 12 )
scoreText4:setReferencePoint( display.CenterReferencePoint )
scoreText4:setTextColor( 30 )
scoreText4.x = XBubble
scoreText4.y =  120
group:insert( scoreText4 )

local scoreText2 = display.newEmbossedText( "Your team has saved " .. Mw .. " Mw!", 0, 0, "Marker Felt Thin", 12 )
scoreText2:setReferencePoint( display.CenterReferencePoint )
scoreText2:setTextColor( 30 )
scoreText2.x = XBubble
scoreText2.y =  140
group:insert( scoreText2 )

local scoreText3 = display.newEmbossedText( "You have saved " .. Trees .. " trees!", 0, 0, "Marker Felt Thin", 12 )
scoreText3:setReferencePoint( display.CenterReferencePoint )
scoreText3:setTextColor( 30 )
scoreText3.x = XBubble
scoreText3.y =  160
group:insert( scoreText3 )

optionset:insert( usage )

OK_button = widget.newButton{
	label = "OK",
	emboss = true,
	onPress = close_scoreScreen,
	left = 100,
	top = 300
	}
	group:insert( OK_button )


return group
end

make_scoreScreen (ScoreScreen)
optionclose:toFront()
submit:toFront()