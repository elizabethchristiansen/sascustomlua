//print("Running textholos.lua")
Plyind = {}
Max = CreateConVar("wire_textholo_max",10)
------------------------------------------------------------------------------------------------------------------------------------------------------------------
function setpos(index,pos,ply)
	if(ply and ply:IsValid() and index and pos) then
		//print("Wire_TextHolo Debug: SetPos ran.")
		umsg.Start("wire_textholo_setpos")
		umsg.Entity(ply)
		umsg.Short(index)
		umsg.Vector(pos)
		umsg.End()
	else
		print("Setpos was called, but one or more of the argumetns were nil or not valid")
	end
end

function setang(index,ang,ply)
	if(ply and ply:IsValid() and index and ang) then
		//print("Wire_TextHolo Debug: SetAng ran.")
		umsg.Start("wire_textholo_setang")
		umsg.Entity(ply)
		umsg.Short(index)
		umsg.Angle(ang)
		umsg.End()
	else
		print("Setang was called, but one or more of the argumetns were nil or not valid")
	end
end

function settext(index,text,ply)
	if(ply and ply:IsValid() and index and text) then
		//print("Wire_TextHolo Debug: SetText ran.")
		umsg.Start("wire_textholo_settext")
		umsg.Entity(ply)
		umsg.Short(index)
		umsg.String(text)
		umsg.End()
	else
		print("Settext was called, but one or more of the argumetns were nil or not valid")
	end
end

function setscale(index,scale,ply)
	if(ply and ply:IsValid() and index and scale) then
		if(scale<1) then
			scale=1
		end
		//print("Wire_TextHolo Debug: SetScale ran.")
		umsg.Start("wire_textholo_setscl")
		umsg.Entity(ply)
		umsg.Short(index)
		umsg.Short(scale)
		umsg.End()
	else
		print("Setscale was called, but one or more of the argumetns were nil or not valid")
	end
end

function setcolor(index,color,ply)
	if(ply and ply:IsValid() and index and color) then
		//print("Wire_TextHolo Debug: SetColor ran.")
		umsg.Start("wire_textholo_setclr")
		umsg.Entity(ply)
		umsg.Short(index)
		umsg.Vector(Vector(color.r,color.g,color.b))
		umsg.Short(color.a)
		umsg.End()
	else
		print("Setcolor was called, but one or more of the argumetns were nil or not valid")
	end
end

function delete(index,ply)
	if(ply and ply:IsValid() and index) then
		//print("Wire_TextHolo Debug: Delete ran")
		Plyind[ply][index] = nil
		umsg.Start("wire_textholo_delete")
		umsg.Entity(ply)
		umsg.Short(index)
		umsg.End()
	else
		print("delete was called, but one or more of the argumetns were nil or not valid")
	end
end

function parent(index,ent,ply)
	if((ent and ent:IsValid()) and (ply and ply:IsValid()) and index) then
		//print("sending:\n"..index.."\n"..tostring(ent).."\n"..tostring(ply))
		umsg.Start("wire_textholo_parent")
		umsg.Short(index)
		umsg.Entity(ent)
		umsg.Entity(ply)
		umsg.End()
	else
		print("parent was called, but one or more of the argumetns were nil or not valid")
	end
end

function setfont(index,font,ply)
	if(index and font and ply and ply:IsValid()) then
		umsg.Start("wire_textholo_setfont")
		umsg.String(font)
		umsg.Short(index)
		umsg.Entity(ply)
		umsg.End()
	else
		print("setfont was called, but one or more of the argumetns were nil or not valid")
	end
end

function CanCreatee(ply)
	if(ply and ply:IsValid()) then
		Count = 0
		if(Plyind[ply]) then
			for k,v in pairs(Plyind[ply]) do
				Count = Count + 1
			end
			//print("Player "..ply:Nick().." has "..Count.." holo texts.")
			return Count
		else
			return false
		end
	end
	return false
end
function CanCreate(ply)
	if(type(CanCreatee(ply) == "number")) then
		if(CanCreatee(ply)<Max:GetInt()) then
			return true
		end
		return false
	end
	return false
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------
function new(index,ply,ent,pos,ang,text,scale,color,font)
	if(index and ply and ply:IsValid() and ent) then
		//print("Wire_TextHolo Debug: NewText ran.")
		if(!Plyind[ply]) then
			Plyind[ply] = {}
		end
		if(CanCreate(ply)) then
			Plyind[ply][index] = {}
			Plyind[ply][index]["Entity"] = ent
			umsg.Start("wire_textholo_add")
				umsg.Entity(ply)
				umsg.Short(index)
			umsg.End()
			setpos(index,pos or ent:GetPos(),ply)
			setang(index,ang or ent:GetAngles(),ply)
			settext(index,text or "Hello world",ply)
			setscale(index,scale or 1,ply)
			setcolor(index,color or Color(255,255,255,255),ply)
			setfont(index,font or "Trebuchet24",ply)
		end
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------
__e2setcost(150*2)
e2function void holoTextCreate(number index)
	new(index,self.player,self.entity)
end
__e2setcost(60*2)
e2function void holoTextPos(number index,vector pos)
	setpos(index,Vector(pos[1],pos[2],pos[3]),self.player)
end
__e2setcost(60*2)
e2function void holoTextAng(number index,angle ang)
	setang(index,Angle(ang[1],ang[2],ang[3]),self.player)
end
__e2setcost(50*2)
e2function void holoText(number index,string text)
	text = string.sub(text,1,254)
	settext(index,text,self.player)
end
__e2setcost(20*2)
e2function void holoTextScale(number index,number scale)
	setscale(index,scale,self.player)
end
__e2setcost(80*2)
e2function void holoTextColor(number index,vector4 rgba)
	setcolor(index,Color(rgba[1],rgba[2],rgba[3],rgba[4]),self.player)
end
__e2setcost(10*2)
e2function void holoTextDelete(number index)
	delete(index,self.player)
end
__e2setcost(30*2)
e2function void holoTextParent(number index, entity ent)
	parent(index, ent, self.player)
	//print("Parenting: \n"..tostring(index).."\n"..tostring(ent).."\n"..self.player:Nick())
end
__e2setcost(50*2)
e2function void holoTextFont(number index,string font)
	setfont(index,font,self.player)
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------
function deocnstruct(self)
	if not self or not validEntity(self.entity) then return end -- TODO: evaluate necessity
	for k,v in pairs(Plyind) do
		for k2,v2 in pairs(v) do
			if(v2["Entity"] == self.entity) then
				//print(k2)
				delete(k2,self.player)
				//print("lol")
			end
		end
	end
end
registerCallback("destruct", deocnstruct)