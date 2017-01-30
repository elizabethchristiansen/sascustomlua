local core 

usermessage.Hook( "EVECore", function( um )

	core = um:ReadEntity()
	
end )

function eveShipHealthHUD()
	local ply = LocalPlayer()

	if ply:GetNWBool( "evehud" ) == true then
	
		if ply:GetNWBool( "useevehud" ) == true then
	
			if !ply:Alive() then return end
		
			if ValidEntity( core ) then
			
				shieldperc = math.Round( ( core:GetNWFloat( "ShieldHP" ) / core:GetNWFloat( "ShieldMAX" ) ) * 100 )
				armorperc = math.Round( (  core:GetNWFloat( "ArmorHP" ) / core:GetNWFloat( "ArmorMAX" ) ) * 100 )
				hullperc = math.Round( (  core:GetNWFloat( "HullHP" ) / core:GetNWFloat( "HullMAX" ) ) * 100 )
			
				wheelNormalTex = surface.GetTextureID("VGui/gradient-u")

				function drawWheel(centerX, centerY, radius, percent, numRectangles)

					surface.SetTexture(wheelNormalTex)

					gap = 3
					width = (math.pi * radius - (numRectangles-1)*gap ) / numRectangles
					
					angularDiff = math.pi/(numRectangles-1)
					for i = 1, numRectangles do
					
						local ang = (i-1) * angularDiff
						local x = centerX + radius * math.cos(ang + math.pi)
						local y = centerY + radius * math.sin(ang + math.pi)
					
						if i <= percent/100 * numRectangles then
							surface.SetDrawColor(255,255,255,255) 
						else
							surface.SetDrawColor(255,0,0,255) 
						end
						
						
						surface.DrawTexturedRectRotated(x, y, width, 16, 90 - ang*180/math.pi)
					
						
					end
				
				end
				
				drawWheel(ScrW()/2, ScrH() - 30, 120, shieldperc, 50)

				drawWheel(ScrW()/2, ScrH() - 30, 100, armorperc, 40)
				 
				drawWheel(ScrW()/2, ScrH() - 30, 80, hullperc, 30)
				
			end
		
		end
		
	end
 
end

hook.Add("HUDPaint", "eveShipHealthHUD", eveShipHealthHUD)