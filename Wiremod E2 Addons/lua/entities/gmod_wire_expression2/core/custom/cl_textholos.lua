Drawtable = {}
Fonts = {}
Blocks = {}
Fonts[1] = "HUDNumber3"
Fonts[2] = "DefaultFixedOutline"
Fonts[3] = "TabLarge"
Fonts[4] = "DefaultBold"
Fonts[5] = "DefaultUnderline"
Fonts[6] = "DefaultSmall"
Fonts[7] = "DefaultSmallDropShadow"
Fonts[8] = "DefaultVerySmall"
Fonts[9] = "DefaultLarge"
Fonts[10] = "ConsoleText"
Fonts[11] = "Trebuchet18"
Fonts[12] = "Trebuchet19"
Fonts[13] = "Trebuchet20"
Fonts[14] = "Trebuchet22"
Fonts[15] = "Trebuchet24"
Fonts[16] = "DefaultFixedDropShadow"
Fonts[17] = "CloseCaption_Normal"
Fonts[18] = "CloseCaption_Bold"
Fonts[19] = "CloseCaption_BoldItalic"
Min = CreateClientConVar("wire_textholo_sizemin",1)
Max = CreateClientConVar("wire_textholo_sizemax",5)
------------------------------------------------------------------------------------------------------------------------------------------------------------------
function setpos(um)
	//print("Wire_TextHolo Debug: SetPos clientside ran")
	Ply = um:ReadEntity()
	Index = um:ReadShort()
	Pos = um:ReadVector()
	if(Drawtable[Ply]) then
		if(Drawtable[Ply][Index]) then
			if(Drawtable[Ply][Index]["ParentPos"] and Drawtable[Ply][Index]["Parent"] and Drawtable[Ply][Index]["ParentEnt"]) then
				if(Drawtable[Ply][Index]["ParentEnt"]:IsValid()) then
					Drawtable[Ply][Index]["ParentPos"] = Drawtable[Ply][Index]["ParentEnt"]:WorldToLocal(Pos)
				end
			else
				Drawtable[Ply][Index]["Pos"] = Pos
			end
		end
	end
end

function setang(um)
	//print("Wire_TextHolo Debug: SetAng clientside ran")
	Ply = um:ReadEntity()
	Index = um:ReadShort()
	Ang = um:ReadAngle()
	if(Drawtable[Ply]) then
		if(Drawtable[Ply][Index]) then
			if(Drawtable[Ply][Index]["ParentAng"] and Drawtable[Ply][Index]["Parent"] and Drawtable[Ply][Index]["ParentEnt"]) then
				if(Drawtable[Ply][Index]["ParentEnt"]:IsValid()) then
					Drawtable[Ply][Index]["ParentAng"] = Drawtable[Ply][Index]["ParentEnt"]:WorldToLocalAngles(Ang)
				end
			else
				Drawtable[Ply][Index]["Ang"] = Ang
			end
		end
	end
end

function settext(um)
	//print("Wire_TextHolo Debug: SetText clientside ran")
	Ply = um:ReadEntity()
	Index = um:ReadShort()
	Text = um:ReadString()
	if(Drawtable[Ply]) then
		if(Drawtable[Ply][Index]) then
			Drawtable[Ply][Index]["Txt"] = Text
		end
	end
end

function setscale(um)
	//print("Wire_TextHolo Debug: SetScale clientside ran")
	Ply = um:ReadEntity()
	Index = um:ReadShort()
	Scale = um:ReadShort()
	if(Drawtable[Ply]) then
		if(Drawtable[Ply][Index]) then
			Drawtable[Ply][Index]["Scl"] = math.Clamp(Scale,Min:GetInt(),Max:GetInt())
		end
	end
end

function setcolor(um)
	//print("Wire_TextHolo Debug: SetColor clientside ran")
	Ply = um:ReadEntity()
	Index = um:ReadShort()
	rgb = um:ReadVector()
	a = um:ReadShort()
	if(Drawtable[Ply]) then
		if(Drawtable[Ply][Index]) then
			Drawtable[Ply][Index]["Clr"] = Color(rgb.r,rgb.g,rgb.b,a)
		end
	end
end

function delete(um)
	Ply = um:ReadEntity()
	Index = um:ReadShort()
	if(Drawtable[Ply]) then
		Drawtable[Ply][Index] = {}
	end
end

function add(um)
	//print("Wire_TextHolo Debug: Add clientside ran")
	Ent = um:ReadEntity()
	if(!Drawtable[Ent]) then
		Drawtable[Ent] = {}
	end
	Drawtable[Ent][um:ReadShort()] = {}
end

function parent(um)
	Index = um:ReadShort()
	Ent = um:ReadEntity()
	//print(Ent)
	Ply = um:ReadEntity()
	//print("recived:\n"..Index.."\n"..tostring(Ent).."\n"..tostring(Ply))
	if(Drawtable[Ply]) then
		if(Drawtable[Ply][Index]) then
			Drawtable[Ply][Index]["ParentEnt"] = Ent
			Drawtable[Ply][Index]["ParentPos"] = Ent:WorldToLocal(Drawtable[Ply][Index]["Pos"])
			Drawtable[Ply][Index]["ParentAng"] = Ent:WorldToLocalAngles(Drawtable[Ply][Index]["Ang"])
			Drawtable[Ply][Index]["Unparentpos"] = Drawtable[Ply][Index]["Pos"]
			Drawtable[Ply][Index]["Pos"] = nil
			Drawtable[Ply][Index]["Parent"] = 1
		end
	end
end

function font(um)
	//print("Font called")
	Font = um:ReadString()
	index = um:ReadShort()
	ply = um:ReadEntity()
	if(Drawtable[ply]) then
		if(Drawtable[ply][index]) then
			for k,v in pairs(Fonts) do
				if(v == Font) then
					Drawtable[ply][index]["Font"] = Font
					//print("Font set!")
				end
			end
		end
	end
end

function FindPly(nick)
	Table = {}
	for k,v in pairs(player.GetAll()) do
		if(v:Nick()==nick) then 
			Playa = v
		end
	end
	return Playa or false
end

//function Autocomp()
//return player.GetAll()
//end
//function Block(ply,cmd,args)
	//Blocks[ply] = FindPly(args[1])
//	print("lolwut")
//end

------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Draw()
	for k,v in pairs(Drawtable) do
		if(!Blocks[k]) then
			for k2,v2 in pairs(v) do
				if(v2["Parent"] == 1) then
					if(v2["ParentEnt"] and v2["ParentEnt"]:IsValid()) then
						if(v2["Ang"] and v2["Scl"] and v2["Txt"] and v2["Clr"]) then
							cam.Start3D2D(v2["ParentEnt"]:LocalToWorld(v2["ParentPos"]),v2["ParentEnt"]:LocalToWorldAngles(v2["ParentAng"]),v2["Scl"])
								draw.SimpleText(v2["Txt"],v2["Font"] or "HUDNumber5",0,0,v2["Clr"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
							cam.End3D2D()
						end
					end
				elseif(v2["Pos"] and v2["Ang"] and v2["Scl"] and v2["Txt"] and v2["Clr"]) then
					cam.Start3D2D(v2["Pos"],v2["Ang"],v2["Scl"])
						draw.SimpleText(v2["Txt"],v2["Font"] or "HUDNumber5",0,0,v2["Clr"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
					cam.End3D2D()
				end
			end
		end
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------
hook.Add("PostDrawOpaqueRenderables","wire_textholo_draw",Draw)
usermessage.Hook("wire_textholo_setpos",setpos)
usermessage.Hook("wire_textholo_setang",setang)
usermessage.Hook("wire_textholo_settext",settext)
usermessage.Hook("wire_textholo_setscl",setscale)
usermessage.Hook("wire_textholo_setclr",setcolor)
usermessage.Hook("wire_textholo_delete",delete)
usermessage.Hook("wire_textholo_add",add)
usermessage.Hook("wire_textholo_parent",parent)
usermessage.Hook("wire_textholo_setfont",font)
//concommand.Add("wire_textholo_blocknick",block)