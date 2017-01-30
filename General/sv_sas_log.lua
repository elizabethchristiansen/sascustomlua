local PLUGIN = exsto.CreatePlugin()

require( "tmysql" )

PLUGIN:SetInfo({
        Name = "SAS Logging Plugin",
        ID = "saslogs",
        Desc = "Logs select Exsto events to the database.",
        Owner = "SAS Elites (leet jeep sklz)",
} )

function PLUGIN:Init()

end


function PLUGIN:ExCommandCalled( id, plug, caller, ... )
        if type( plug ) == "Player" then caller = plug end
		
		local colour = ""
		
        local text = self:Player( caller ) .. " []has run []'" .. id .. "'"
		if self:Player( caller ) == "CONSOLE" then
			colour = "255,255,255"
		else
			local plycolour = team.GetColor( caller:Team() )
			colour = tostring( plycolour.r )..","..tostring( plycolour.g )..","..tostring( plycolour.b )
		end
		colour = colour.."[]".."255,255,255"
		colour = colour.."[]".."255,105,105"
		
        local index = 1
		
        if arg[1] then
                if type( arg[1] ) == "Player" then
                        text = text .. " []on player []" .. self:Player( arg[1] )
						local argcolour = team.GetColor( arg[1]:Team() )
						colour = colour.."[]".."255,255,255"
						colour = colour.."[]"..tostring( argcolour.r )..","..tostring( argcolour.g )..","..tostring( argcolour.b )
                        index = 2
                end
                
                if arg[ index ] then
                        text = text .. " []with args: []"
						colour = colour.."[]".."255,255,255"
						colour = colour.."[]".."255,105,105"
                        for I = index, #arg do
                                text = text .. tostring( arg[I] )
                        end
                end
        end
        
        self:SaveEvent( self:Player( caller ), text, colour )
end

function PLUGIN:Player( ply )

    if ply:EntIndex() == 0 then
        return "CONSOLE"
    else
        return ply:Nick()
    end
	
end

function PLUGIN:SaveEvent( player, text, colour )

    if text == "" then return end

	local srv = GetConVar( "server_number" ):GetInt()

    tmysql.query( "INSERT INTO sas_chat VALUES ('', '" .. srv .. "', 'Exsto', '" .. tmysql.escape( text ) .. "', '"..tmysql.escape( colour ).."', UNIX_TIMESTAMP(), 'command') " ) 
        
end

PLUGIN:Register()