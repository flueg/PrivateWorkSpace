local iterator=require "iterator"

local endP = {flueg="single", host="dog"}
local config = {
	gateway1 = {endP},
	gateway = {
		{flueg="liu", host=4},
		{flueg="lai", host=3},
		{flueg="flueg", host=2},
		{flueg="alice", host=1},
		--[1] = "flueg=liu",
		--[2] = "flueg=lai",
		--[3] = "flueg=flueg",
		--[4] = "flueg=alice",
	    	},
}

-- iterator will return a function.
--local nxt  = iterator.randomiter(config.gateway);
local nxt  = iterator.randomiter(config.gateway1);

local n = tonumber(arg[1])
if n == nil then n = 10 end

local i = 0
while i < n do
	i = i + 1
	t = nxt()
	print(i, t.flueg, t.host)
end
