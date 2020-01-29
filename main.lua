SLASH_LOWSPEAK1 = "/ss"
SLASH_LOWSPEAK2 = "/ls"
SLASH_LOWSPEAK3 = "/qs"
SLASH_LOWSPEAK4 = "/lowspeak"
SLASH_LOWSPEAK5 = "/low"
SLASH_LOWSPEAK6 = "/quiet"
SlashCmdList["LOWSPEAK"] = function(msg)
	for i = 1, 40 do
		local name = UnitName("nameplate"..i)
		if name then
			print(i, name)
		end
	end
end