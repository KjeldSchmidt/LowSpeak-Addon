local nameplate_shown -- Stores whether friendly nameplates are already shown, so they are not disabled by the addon.
local message_recepients = {} -- 


SLASH_LOWSPEAK1 = "/ss"
SLASH_LOWSPEAK2 = "/ls"
SLASH_LOWSPEAK3 = "/qs"
SLASH_LOWSPEAK4 = "/lowspeak"
SLASH_LOWSPEAK5 = "/low"
SLASH_LOWSPEAK6 = "/quiet"

SlashCmdList[ "LOWSPEAK" ] = function( msg )
	nameplate_shown = GetCVarBool( "nameplateShowFriends" )
	if not nameplate_shown then
		SetCVar( "nameplateShowFriends", true )
	end
	LSRP__wait( 0.1, create_recipient_table, msg )
end


function create_recipient_table( msg )
	local player_to_write_to = {}
	for i = 1, 40 do
		local unitID = "nameplate"..i
		local name = UnitName( unitID )
		if name and UnitIsPlayer( unitID ) and UnitIsFriend( "player", unitID ) and CheckInteractDistance( unitID, 3 ) then
			print(name, "while hear from you")
			-- Should we pass name or unitID here? Nameplate ordering can change while waiting, potentially?
			table.insert( player_to_write_to, name ) 
		end
	end
	SetCVar( "nameplateShowFriends", nameplate_shown ) -- reset the display 
	send_message_addon_channel(  ) -- send message on the adodn channel, to be recived by those who also have the addon
	LSRP__wait( 0.2, send_message_whsiper_channel ) -- send message to all nearby people who haven't send an addon repsonse
end

function send_message_addon_channel( ... )
	-- body
end

function send_message_whsiper_channel( ... )
	
end









--
-- External Code
--

-- This wait function taken from https://wowwiki.fandom.com/wiki/USERAPI_wait
local waitTable = {};
local waitFrame = nil;
function LSRP__wait(delay, func, ...)
	if ( type( delay ) ~= "number" or type( func ) ~= "function" ) then
		return false;
	end
	if ( waitFrame == nil ) then
		waitFrame = CreateFrame( "Frame","WaitFrame", UIParent );
		waitFrame:SetScript( 
			"onUpdate",
			function ( self, elapse )
				local count = #waitTable;
				local i = 1;
				while(i<=count) do
					local waitRecord = tremove( waitTable, i );
					local d = tremove( waitRecord, 1 );
					local f = tremove( waitRecord, 1 );
					local p = tremove( waitRecord, 1 );
					if( d > elapse ) then
						tinsert( waitTable, i, { d-elapse, f, p } );
						i = i + 1;
					else
						count = count - 1;
						f( unpack( p ) );
					end
				end
			end
		);
	end
	tinsert( waitTable, { delay, func, {...} } );
	return true;
end