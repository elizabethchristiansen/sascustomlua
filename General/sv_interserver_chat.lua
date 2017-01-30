if not SERVER then return end

require( "tmysql" )
require( "datastream" )

include( "cl_interserver_chat.lua" )
AddCSLuaFile( "autorun/cl_interserver_chat.lua" )

local id = nil

function GetCurrentChatID()  

	tmysql.query( "SELECT MAX(id) FROM sas_chat", function( res, status, error )
		if !status then Error( "Error: " ..error.. "\n") end
		
		id = res[1][1]
		
	end )
		
end
hook.Add( "InitPostEntity", "GetCurrentChatID", GetCurrentChatID ) 

function UpdateChat( ply, str )
	
	if str == "" then return end
	
	local name = tmysql.escape( ply:Nick() )
	
	local string = tmysql.escape( str )
	
	local srv = GetConVar( "server_number" ):GetInt()
	
	local colour = team.GetColor( ply:Team() )
	local colourr = math.floor( colour.r )
	local colourg = math.floor( colour.g )
	local colourb = math.floor( colour.b )
	local colourstr = tostring( colourr )..","..tostring( colourg )..","..tostring( colourb )
	
	tmysql.query( "INSERT INTO sas_chat ( server, player, string, colour, time, type ) VALUES ( "..srv..", \'"..name.."\', \'"..string.."\', \'"..colourstr.."\', UNIX_TIMESTAMP(), 'chat' )" )
	
end
hook.Add( "PlayerSay", "UpdateChatDatabase", UpdateChat )

function ConnectChat( nick )

	local name = tmysql.escape( nick )
	
	local srv = GetConVar( "server_number" ):GetInt()
	
	tmysql.query( "INSERT INTO sas_chat ( server, player, string, time, type ) VALUES ( "..srv..", \'"..name.."\', '*CONNECT*', UNIX_TIMESTAMP(), 'connection' )" )
	
end
hook.Add( "PlayerConnect", "PlayerConnected", ConnectChat )

function DisconnectChat( ply )

	local name = tmysql.escape( ply:Nick() )
	
	local srv = GetConVar( "server_number" ):GetInt()
	
	tmysql.query("INSERT INTO sas_chat ( server, player, string, time, type ) VALUES ( "..srv..", \'"..name.."\', '*DISCONNECT*', UNIX_TIMESTAMP(), 'connection' )" )
	
end
hook.Add( "PlayerDisconnected", "PlayerDiscon", DisconnectChat )  

function RecieveChat()

	if id == nil then
		GetCurrentChatID()
		if id == nil then return end
	end
	
	local srv = GetConVar( "server_number" ):GetInt()
	
	tmysql.query( "SELECT * FROM sas_chat WHERE id > "..id.."  AND server != "..srv.."", function( res, status, error )
		if !status then Error( "Error: " ..error.. "\n") end
		
		local players = player.GetAll()
		
		local red = 255
		local green = 255
		local blue = 255
		
		for k, v in pairs( res ) do
		
			local server = v[2]
			local name = v[3]
			local text = v[4]
			local colourstr = v[5]
			local entrytype = v[7]
			
			if entrytype == "chat" then
		
				if text != "" then
		
					local colourexp = string.Explode( ",", colourstr )
					red = tonumber( colourexp[1] )
					green = tonumber( colourexp[2] )
					blue = tonumber( colourexp[3] )
					
					if server != "Web" then
						server = "#"..server
					end
					
					local num = string.len( server ) + 3
					
					local stringln = num + string.len( name ) + string.len( text )
					
					for _, ply in pairs( players ) do
						
						if stringln > 250 then
						
							local chatinfo = {
								server,
								name,
								text,
								red,
								green,
								blue
							}
						
							datastream.StreamToClients( ply, "GlobalChat", chatinfo )
						
						else
						
							umsg.Start( "addchat", ply )

								umsg.String( server )
								umsg.String( name )
								umsg.String( text )
								
								umsg.Char( math.floor( red - 128 ) )
								umsg.Char( math.floor( green - 128 ) )
								umsg.Char( math.floor( blue - 128 ) )
								
							umsg.End()
						
						end
					end
				end
				
				id = v[1]
				
			elseif entrytype == "connection" then
			
				local str = ""
			
				if text == "*CONNECT*" then
					str = "Player "..name.." has joined server "..server
				elseif text == "*DISCONNECT*" then
					str = "Player "..name.." has left server "..server
				end
			
				for _, ply in pairs( players ) do
				
					umsg.Start( "addchatconnection", ply )

						umsg.String( str )
						
					umsg.End()
					
				end
				
				id = v[1]
			
			elseif entrytype == "command" then
			
				local commandstr = string.Explode( "[]", text )
				local colours = string.Explode( "[]", colourstr )
				
				if server != "Web" then
					server = "#"..server
				end
				
				for _, ply in pairs( players ) do
				
					umsg.Start( "commandstate", ply )
						umsg.Char( 1 )
						umsg.String( server )
					umsg.End()
					
					for k, v in pairs( commandstr ) do
						local assocolour = colours[k]
						
						local rgb = string.Explode( ",", assocolour )
						local red = tonumber( rgb[1] )
						local green = tonumber( rgb[2] )
						local blue = tonumber( rgb[3] )
						
						umsg.Start( "addchatcommand", ply )
							
							umsg.String( v )
							
							umsg.Char( math.floor( red - 128 ) )
							umsg.Char( math.floor( green - 128 ) )
							umsg.Char( math.floor( blue - 128 ) )
							
						umsg.End()
						
					end
					
					umsg.Start( "commandstate", ply )
						umsg.Char( 0 )
					umsg.End()
					
				end
			
				id = v[1]
			
			end
			
		end
		
	end )
				
end
timer.Create( "RecieveChat", 5, 0, RecieveChat )