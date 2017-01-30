
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()   
self.Done = CurTime() + 1
self:Think()
end   

function ENT:Think()
local tbl = self.Entity.tbl
	if tbl[8] == "Sprite" then
		self.Entity:SetNWString("name",tbl[1])
		self.Entity:SetNWVector("pos",tbl[2])
		self.Entity:SetNWFloat("sizex",tbl[3])
		self.Entity:SetNWFloat("sizey",tbl[4])
		self.Entity:SetNWVector("color",tbl[5])
		self.Entity:SetNWFloat("alpha",tbl[6])
		self.Entity:SetNWFloat("parent",tbl[7])
		self.Entity:SetNWString("Type",tbl[8])
	end
	if tbl[10] == "Beam" then
		self.Entity:SetNWString("name",tbl[1])
		self.Entity:SetNWVector("startpos",tbl[2])
		self.Entity:SetNWVector("endpos",tbl[3])
		self.Entity:SetNWFloat("width",tbl[4])
		self.Entity:SetNWFloat("TextStart",tbl[5])
		self.Entity:SetNWFloat("TextEnd",tbl[6])
		self.Entity:SetNWVector("color",tbl[7])
		self.Entity:SetNWFloat("alpha",tbl[8])
		self.Entity:SetNWFloat("parent",tbl[9])
		self.Entity:SetNWString("Type",tbl[10])
	end
	if tbl[5] == "light" then
		self.Entity:SetNWVector("pos",tbl[1])
		self.Entity:SetNWFloat("size",tbl[2])
		self.Entity:SetNWVector("color",tbl[3])
		self.Entity:SetNWFloat("bright",tbl[4])
		self.Entity:SetNWString("Type",tbl[5])
	end
	if tbl[10] == "Quad" then
		self.Entity:SetNWString("name",tbl[1])
		self.Entity:SetNWVector("pos",tbl[2])
		self.Entity:SetNWVector("Dir",tbl[3])
		self.Entity:SetNWFloat("sizex",tbl[4])
		self.Entity:SetNWFloat("sizey",tbl[5])
		self.Entity:SetNWVector("color",tbl[6])
		self.Entity:SetNWFloat("alpha",tbl[7])
		self.Entity:SetNWAngle("ang",tbl[8])
		self.Entity:SetNWFloat("parent",tbl[9])
		self.Entity:SetNWString("Type",tbl[10])
	end
	if tbl[4] == "Clip" then
		if self.Done > CurTime() then
			datastream.StreamToClients( player.GetAll( ), "Array", tbl[1])
		end
		self.Entity:SetNWEntity("Ent",self.Entity)
		self.Entity:SetNWVector("Plane",tbl[2])
		self.Entity:SetNWFloat("Dis",tbl[3])
		self.Entity:SetNWString("Type",tbl[4])
		
	end
end
