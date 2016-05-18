
function iterator(self)
	local val = {}
	local i = 0
	for k, v in pairs(self) do
		if type(v) == "table" then
			val[#val+1] = v 
		end 
	end 
	return function(index)
		if index == nil then index = 1000000007 end
			index = index % #val + 1 
			return val[index]
		end, 
		function() i = i % #val + 1; return val[i] end
end 

return {
	iterator=iterator
}
