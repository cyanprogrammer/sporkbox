function math.average(t)
  local sum = 0
  for _,v in pairs(t) do -- Get the sum of all numbers in t
    sum = sum + v
  end
  return sum / #t
end

function bot(weights, weights2)
	local bot = {
		money=5,
		defenses=1,
		mode=0,
		--the input layer for the bot works as follows:
		--values are divided by 100 
		--1 - money 
		--2 - ammount of living bots in the world
		--3 - average money for every bot
		--4 - the bot's mode, which is 1 if it's in "*UNDERWORLD MODE*" and 0 all other times
		--5 - the time: the ammount of ticks that have passed since the creation of the world
		input={0, 0, 0, 0},
		middle={{weights=weights, output=0}, {weights=weights, output=0},},
		--the output layer works like this:
		--1 - enter *UNDERWORLD MODE*, which enables hacking, but makes you easy pickings for computer-goblins
		--2 - hack one of the topmost bots in terms of money; only possible during *UNDERWORLD MODE*
		--3 - hack one of the topmost bots in terms of defenses; only possible during *UNDERWORLD MODE*
		--4 - bolster defenses for money
		output={0, 1, 0, 0},
	}
	
	for l=1, #bot.middle do
			bot.middle[l].output = math.average(bot.input) * bot.middle[l].weights
	end
	
	function bot:undmode()
		bot.mode = 1
	end
	
	function bot:hackMoney()
		love.graphics.print("hackerman", 60, 60)
	end
	
	function bot:update(bot_ammount, average_money, t)
		bot.mode = 0
		
		--handle input nodes
		bot.input[1] = bot.money / 100
		bot.input[2] = bot_ammount / 100
		bot.input[3] = average_money / 100
		bot.input[4] = bot.mode
		bot.input[5] = t
		
		for l=1, #bot.middle do
			bot.middle[l].output = math.average(bot.input) * bot.middle[l].weights
		end
		
		--handle output nodes
		for o=1, #bot.output do
			bot.output[o] = math.average(bot.middle[#bot.middle])
		end
		
		if bot.output[1] > 0.5 then
			bot:undmode()
		end
		if bot.output[2] > 0.5 then
			bot:hackMoney()
		end
		
	end
	
	function bot:draw()
		love.graphics.print(tostring(bot.mode), 100, 100)
	end
	
	return bot
end

function love.load()
	-- a group of variables to configure the simulation
	max_ais = 100

	--creates the table containing every bot in the world
	all = {}
	--for bi=1, max_ais do
		table.insert(all, bot(4, 0.5))
	--end
	
	--initialize time variable
	t = 0
end

function love.update(dt)
	t = t + 1
	--figure out the average money of all bots
	local mt = {}
	local m = 0
	for mi=1, #all do
		table.insert(mt, all[mi].money)
	end
	m = math.average(mt)
	
	--update all bots
	for bui=1, #all do
		all[bui]:update(#all, m, t)
	end
end

function love.draw()
	--draw all bots
	for bdi=1, #all do
		all[bdi]:draw()
	end
end