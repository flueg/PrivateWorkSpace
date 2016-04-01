
function iterator(self)
	local val = {}
	local i = 0
	for k, v in pairs(self) do
		if type(v) == "table" then
			val[#val+1] = v 
		end 
	end 
	return function (index)
			index = index % #val + 1 
			return val[index]
		end, 
		function () 
			i = i % #val
			i = i + 1
			return val[i]
		end
end 

return {
	iterator=iterator
}
