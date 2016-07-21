local iterator=require "iterator"

local config = {
	gateway = {
		[1] = {flueg="liu", host=4},
		[2] = {flueg="lai", host=3},
		[3] = {flueg="flueg", host=2},
		[4] = {flueg="alice", host=1},
		--[1] = "flueg=liu",
		--[2] = "flueg=lai",
		--[3] = "flueg=flueg",
		--[4] = "flueg=alice",
	    	},
}

-- iterator will return a function.
local nxt  = iterator.randomiter(config.gateway);

local n = tonumber(arg[1])
if n == nil then n = 10 end

local i = 0
while i < n do
	i = i + 1
	t = nxt()
	print(i, t.flueg, t.host)
end
