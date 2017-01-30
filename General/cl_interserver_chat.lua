if not CLIENT then return end 

local commandt = {}
local colourt = {}

function GetChatInfo ( um )

	local server = um:ReadString()
	local name = um:ReadString()
	local text = um:ReadString()
	
	local red = ( um:ReadChar() + 128 )
	local green = ( um:ReadChar() + 128 )
	local blue = ( um:ReadChar() + 128 )
	
	local chattype = 1
	
	EnterChat( chattype, server, name, text, red, green, blue )

end
usermessage.Hook( "addchat", GetChatInfo )

datastream.Hook( "GlobalChat", function( handler, id, encoded, decoded )

	local t = decoded
	
	local server = t[1]
	local name = t[2]
	local text = t[3]
	
	local red = t[4]
	local green = t[5]
	local blue = t[6]
	
	local chattype = 1
	
	EnterChat( chattype, server, name, text, red, green, blue )
	
end )

function GetConnectionInfo ( um )

	local text = um:ReadString()
	local chattype = 2

	EnterChat( chattype, "0", "none", text, 0, 0, 0 )

end
usermessage.Hook( "addchatconnection", GetConnectionInfo )

function GetCommandState( um )

	local state = um:ReadChar()
	
	if state == 1 then
		commandt = {}
		colourt = {}
	else
		local chattype = 3
		local server = um:ReadString()
		
		EnterChat( chattype, server, "none", commandt, colourt, 0, 0 )
		
	end

end
usermessage.Hook( "commandstate", GetCommandState )

function GetCommandInfo ( um )

	local text = um:ReadString()
	
	local red = ( um:ReadChar() + 128 )
	local green = ( um:ReadChar() + 128 )
	local blue = ( um:ReadChar() + 128 )
	
	local ct = { red, green, blue }
	
	table.insert( commandt, text )
	table.insert( colourt, ct )
	
end
usermessage.Hook( "addchatcommand", GetCommandInfo )

function EnterChat( chattype, server, name, text, red, green, blue )

	if chattype == 1 then
		chat.AddText(
			Color( 255, 150, 0 ), "["..tostring( server ).."] ",
			Color( red, green, blue ), tostring( name ),
			Color( 255, 255, 255 ), ": "..tostring( text )
		)
		chat.PlaySound()
	elseif chattype == 2 then
		chat.AddText(
			Color( 153, 255, 153 ), text
		)
		chat.PlaySound()
	elseif chattype == 3 then
		chat.AddText(
			Color( 255, 150, 0 ), "["..tostring( server ).."] ",
			Color( red[1][1], red[1][2], red[1][3] ), text[1],
			Color( red[2][1], red[2][2], red[2][3] ), text[2],
			Color( red[3][1], red[3][2], red[3][3] ), text[3],
			Color( red[4][1], red[4][2], red[4][3] ), text[4],
			Color( red[5][1], red[5][2], red[5][3] ), text[5]
		)
		chat.PlaySound()	
	end

end