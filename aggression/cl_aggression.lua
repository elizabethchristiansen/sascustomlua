if not CLIENT then return end 

function Aggression( um )
	
	local chatstring = "lolwewt"
	local aggression = um:ReadString()
	
	if aggression == "aggression" then
		chatstring = "You Now Have Aggression!"
		colour = Color(255,255,0)
	elseif aggression == "global" then
		chatstring = "You Now Have Global Aggression!"
		colour = Color(255,0,0)
	elseif aggression == "none" then
		chatstring = "You Have Lost All Aggression!"
		colour = Color(255,255,255)
	end
	
	ChatWarn( chatstring, colour )
	
end

function AggressionWarning( um )

	local chatstring = "lolwewt"
	local aggression = um:ReadString()
	local nick = um:ReadString()
	
	if aggression == "aggression" then
		chatstring = nick.." Now Has Aggression!"
		colour = Color(255,255,0)
	elseif aggression == "global" then
		chatstring = nick.." Now Has Global Aggression!"
		colour = Color(255,0,0)
	elseif aggression == "none" then
		chatstring = nick.." Has Lost All Aggression!"
		colour = Color(255,255,255)
	end
	
	ChatWarn( chatstring, colour )
	
end

function ChatWarn( chatstring, colour )
	
	chat.AddText(
		colour, chatstring
	)
	chat.PlaySound()

end

function DrawText( x, y, text, font, colours )
 
	surface.SetFont( font )			
 
	surface.SetTextPos( x + 1, y + 1 ) 
	surface.SetTextColor( clr( colours.shadow ) )
	surface.DrawText( text )
 
	surface.SetTextPos( x, y )
	surface.SetTextColor( clr( colours.text ) )
	surface.DrawText( text )
 
end

function DrawPanel( x, y, w, h, colors )
 
	surface.SetDrawColor( clr( colors.border ) )
	surface.DrawOutlinedRect( x, y, w, h )
 
	x = x + 1
	y = y + 1
	w = w - 2
	h = h - 2
 
	surface.SetDrawColor( clr( colors.background ) )
	surface.DrawRect( x, y, w, h )
 
end
 

function HudPaint()
	
	local ply = LocalPlayer()
	local usehud = ply:GetNWBool("usehud")
	local showaggro = ply:GetNWBool("showaggrotable")
	
	if usehud == true then
	
		local aggression = ply:GetNWString("aggression")
	
		if aggression == "aggression" then
			colour = Color(255,255,0,255)
		elseif aggression == "global" then
			colour = Color(255,0,0,255)
		end
		
		local colours = { }
		
		colours.text = colour
		colours.shadow = Color(0,0,0,255)
	
		local text = ply:GetNWString("hudstring")
		
		DrawText( 1, 1, text, "TargetID", colours )
	
	end
	
	if showaggro == true then
		
		local font = "default"
		local y = 180		
		local width = 200
		
		local _, th = TextSize( "TEXT", font )
		
		local panelcolours = { }
		local colours = { }
		
		panelcolours.border = Color(0,0,0,100)
		panelcolours.background = Color(0,0,0,100)
		colours.text = Color(255,255,255,255)
		colours.shadow = Color(0,0,0,255)
		
		local entries = table.Count(player.GetAll())
		local h = 20 + ( entries * th )
		
		DrawPanel( 10, 160, width, h, panelcolours )
		
		DrawText( 12, 160, "Aggression List", font, colours )
		
		for _, ply in pairs(player.GetAll()) do
		
			local text = ply:GetNWString("tablestring")
			local aggro = ply:GetNWString("aggression")
	
			if aggro == "aggression" then
				colour = Color(255,255,0,255)
			elseif aggro == "global" then
				colour = Color(255,0,0,255) 
			elseif aggro == "none" then
				colour = Color(255,255,255,255)
			end
		
			colours.text = colour
			colours.shadow = Color(0,0,0,255)
			
			DrawText( 12, y, text, font, colours )
			y = y + th
			
		end
		
	end

end

function TextSize( text, font )
 
	surface.SetFont( font )
	return surface.GetTextSize( text )
 
end

function clr( color ) 
	return color.r, color.g, color.b, color.a 
end

usermessage.Hook("aggression", AggressionWarning)
usermessage.Hook("plyaggression", Aggression)

hook.Add("HUDPaint", "DrawText", HudPaint)