SLASH_LOWSPEAK1 = "/ss"
SLASH_LOWSPEAK2 = "/ls"
SLASH_LOWSPEAK3 = "/qs"
SLASH_LOWSPEAK4 = "/lowspeak"
SLASH_LOWSPEAK5 = "/low"
SLASH_LOWSPEAK6 = "/quiet"
SlashCmdList[ "LOWSPEAK" ] = function( msg )
	local nameplate_shown = GetCVarBool( "nameplateShowFriends" )
	if not nameplate_shown then
		print("Friendly nameplates were not turned on - the message could not be delivered.")
		print("The addon has turned them on automatically now. Please resend your message!")
		SetCVar("nameplateShowFriends", 1)
	else
		local player_to_write_to = {}
		for i = 1, 40 do
			local unitID = "nameplate"..i
			local name = UnitName( unitID )
			if name then
				if UnitIsPlayer( unitID ) and UnitIsFriend( "player", unitID ) and CheckInteractDistance( unitID, 3 ) then
					print(name, "while hear from you")
					-- Should we pass name or unitID here? Nameplate ordering can change while waiting, potentially?
					table.insert( player_to_write_to, name ) 
				end
			end
		end
	end
end