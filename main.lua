local nameplate_shown; -- Stores whether friendly nameplates are already shown, so they are not disabled by the addon.
-- table of tables. Keys are message IDs, values are a table with two entries:
	-- Message Text
	-- Table with players as keys and a boolean indicating that an addons message acknowledgement has been received as value
local message_recipients = {};
local next_message_id = 0;


local ADDN_PRFX = "LSRP"
C_ChatInfo.RegisterAddonMessagePrefix( ADDN_PRFX )


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
	local players_to_write_to = {}
	local message_id = next_message_id
	next_message_id = next_message_id + 1

	for i = 1, 40 do
		local unitID = "nameplate"..i
		local name = UnitName( unitID )
		if name and UnitIsPlayer( unitID ) and UnitIsFriend( "player", unitID ) and CheckInteractDistance( unitID, 3 ) then
			print(name, "while hear from you")
			-- Should we pass name or unitID here? Nameplate ordering can change while waiting, potentially?
			players_to_write_to[ name] = false
		end
	end
	message_recipients[message_id] = { msg, players_to_write_to }
	SetCVar( "nameplateShowFriends", nameplate_shown ) -- reset the display 
	send_message_addon_channel( message_id ) -- send message on the adodn channel, to be recived by those who also have the addon
	LSRP__wait( 0.2, send_message_whsiper_channel, message_id ) -- send message to all nearby people who haven't send an addon repsonse
end

function send_message_addon_channel( message_id )
	local message_to_send = message_recipients[ message_id ]
	local message_text = message_to_send[ 1 ]
	local recipients = message_to_send[ 2 ]

	local addon_message = "sm\t" .. message_id .. "\t0\t" .. message_text
	
	if #addon_message > 254 - #ADDN_PRFX then
		addon_message = string.sub( addon_message, 1, 254 )
	end
	
	for player, addon_ack_send in pairs( recipients ) do
			C_ChatInfo.SendAddonMessage( ADDN_PRFX, addon_message, "WHISPER", player );
	end
end

function send_message_whsiper_channel( message_id )
	local message_to_send = message_recipients[ message_id ]
	local message_text = message_to_send[ 1 ]
	local recipients = message_to_send[ 2 ]

	for player, addon_ack_send in pairs( recipients ) do
		if not addon_ack_send then
			SendChatMessage( message_text, "WHISPER" , nil , player );
		end
	end
end

function handle_addon_message( message, dist_type, sender )
	local action, message_id, series_number, message_text = message.stringsplit("\t")
	if action == "sm" then
		receive_message( message_text, sender )
		send_acknolwedgment( message_id, sender )
	elseif action == "sa" then
		handle_message_acknowledgement( message_text, sender )
	end
end

function receive_message( message_text, sender )
	print( sender, ": ", message_text )
end

function send_acknolwedgment( message_id, sender )
	C_ChatInfo.SendAddonMessage( ADDN_PRFX, "sa\t" .. message_id, "WHISPER" , sender );
end

function handle_message_acknowledgement( message_id, sender )
	message_recipients[ message_id ][ 2 ][ sender ] = true
end

--
-- Handle received addon messages
--

local message_receiver_frame = CreateFrame( "Frame", "message_receiver_frame" )
message_receiver_frame:RegisterEvent( "CHAT_MSG_ADDON" )
local function eventHandler( self, event, ... )
	if event == "CHAT_MSG_ADDON" then
		local prefix, message, dist_type, sender = ...
		if prefix == ADDN_PRFX then
			handle_addon_message( message, dist_type, sender )
		end
	end
end
message_receiver_frame:SetScript( "OnEvent", eventHandler )





--
-- External Code
--

-- This wait function taken from https://wowwiki.fandom.com/wiki/USERAPI_wait
local waitTable = {};
local waitFrame = nil;
function LSRP__wait( delay, func, ... )
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

-- taken from https://stackoverflow.com/a/7615129/2532489
local function stringsplit( inputstr, sep )
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end


local function starts_with(str, start)
   return str:sub(1, #start) == start
end