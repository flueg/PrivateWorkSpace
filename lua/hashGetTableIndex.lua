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

local userno = arg[1];
-- iterator will return two function.
local iter, nxt  = iterator.iterator(config.gateway);
--local t = iter(userno)
local t = iter(userno)
print(t.flueg, t.host);

--[[
t = nxt()
while t.host ~= 1
do
	print("host is: ",t.host)
	t = nxt()
end
]]

local i = 0
while i < 3 do
	i = i + 1
	if t.host ~= 1 then
		t = iter(userno + i)
		print(t.flueg, t.host)
	end
end
