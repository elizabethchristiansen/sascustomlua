include('shared.lua')     
function ENT:Initialize()
self.Done = false
end
function ENT:Think()
self.Type = self.Entity:GetNWString("Type")
	if self.Type == "Sprite" then
		self.name = self.Entity:GetNWString("name")
		self.pos = self.Entity:GetNWVector("pos")
		self.sizex = self.Entity:GetNWFloat("sizex")
		self.sizey = self.Entity:GetNWFloat("sizey")
		self.color = self.Entity:GetNWVector("color")
		self.alpha = self.Entity:GetNWFloat("alpha")
		self.parent = self.Entity:GetNWFloat("parent")
		self.Glow = Material(self.name)
		self.Glow:SetMaterialInt("$spriterendermode",9)
		self.Glow:SetMaterialInt("$ignorez",1)
		self.Glow:SetMaterialInt("$illumfactor",8)
		self.Glow:SetMaterialFloat("$alpha",0.6)
		self.Glow:SetMaterialInt("$nocull",1)
	end
	if self.Type == "Beam" then
		self.name = self.Entity:GetNWString("name")
		self.startpos = self.Entity:GetNWVector("startpos")
		self.endpos = self.Entity:GetNWVector("endpos")
		self.width = self.Entity:GetNWFloat("width")
		self.TextStart = self.Entity:GetNWFloat("TextStart")
		self.TextEnd = self.Entity:GetNWFloat("TextEnd")
		self.color = self.Entity:GetNWVector("color")
		self.alpha = self.Entity:GetNWFloat("alpha")
		self.parent = self.Entity:GetNWFloat("parent")
		self.Glow = Material(self.name)
		self.Glow:SetMaterialInt("$spriterendermode",9)
		self.Glow:SetMaterialInt("$ignorez",1)
		self.Glow:SetMaterialInt("$illumfactor",8)
		self.Glow:SetMaterialFloat("$alpha",0.6)
		self.Glow:SetMaterialInt("$nocull",1)
	end
	if self.Type == "Quad" then
		self.name = self.Entity:GetNWString("name")
		self.pos = self.Entity:GetNWVector("pos")
		self.dir = self.Entity:GetNWVector("Dir")
		self.sizex = self.Entity:GetNWFloat("sizex")
		self.sizey = self.Entity:GetNWFloat("sizey")
		self.color = self.Entity:GetNWVector("color")
		self.alpha = self.Entity:GetNWFloat("alpha")
		self.ang = self.Entity:GetNWAngle("ang")
		self.parent = self.Entity:GetNWFloat("parent")
		self.Glow = Material(self.name)
		self.Glow:SetMaterialInt("$spriterendermode",9)
		self.Glow:SetMaterialInt("$ignorez",1)
		self.Glow:SetMaterialInt("$illumfactor",8)
		self.Glow:SetMaterialFloat("$alpha",0.6)
		self.Glow:SetMaterialInt("$nocull",1)
	end
	if self.Type == "light" then
		local pos = self.Entity:GetNWVector("pos")
		local size = self.Entity:GetNWFloat("size")
		local color = self.Entity:GetNWVector("color")
		local bright = self.Entity:GetNWFloat("bright")
		local dlight = DynamicLight( self:EntIndex() )
			if ( dlight ) then
				dlight.Pos = self.Entity:GetPos()
				dlight.r = color.x
				dlight.g = color.y
				dlight.b = color.z
				dlight.Brightness = bright
				dlight.Size = size
				dlight.Decay = size * 5
				dlight.DieTime = CurTime() + 1
			end
	end
	if self.Type == "Clip" then
		self.Ent = self.Entity:GetNWEntity("Ent")
		self.Plane = self.Entity:GetNWVector("Plane")
		self.Dis = self.Entity:GetNWFloat("Dis")
		if not self.Array then
			datastream.Hook("Array", 
				function( handler, id, encoded, decoded )
					self.Array = decoded
				end)
		end
		local dis = self.Plane:Dot(self.Dis)
		if self.Array then
			for k,v in pairs(self.Array) do
				self:ClipPlane(v,self.Plane,dis)
			end
		end
	end
	self.Done = true
end	

function ENT:ClipPlane(ent,plane,dis)	
	ent:SetRenderClipPlaneEnabled( true )
	ent:SetRenderClipPlane(plane, dis)
end

function ENT:OnRemove()
	if self.Array then
		for k,v in pairs( self.Array ) do
			v:SetRenderClipPlaneEnabled( false )
		end
	end
end

function ENT:Draw()
	if self.Type == "Sprite" then  --Lets draw Sprites
			if self.Done == true && self.parent == 0 then
				render.SetMaterial(self.Glow)
				render.DrawSprite(self.pos,self.sizex,self.sizey,Color(self.color.x,self.color.y,self.color.z,self.alpha))
			end
			if self.Done == true && self.parent == 1 then
				if not Dif then
					local Dif = self.Entity:GetPos() - self.pos
				end
				render.SetMaterial(self.Glow)
				render.DrawSprite(self.Entity:GetPos() + Vector(Dif),self.sizex,self.sizey,Color(self.color.x,self.color.y,self.color.z,self.alpha))
			end
	end
	
	if self.Type == "Beam" then --Lets draw a Beam
		if self.Done == true && self.parent == 0 then
			render.SetMaterial(self.Glow)
			render.DrawBeam(self.startpos, self.endpos, self.width, self.TextStart, self.TextEnd, Color(self.color.x,self.color.y,self.color.z,self.alpha))
		end
		if self.Done == true && self.parent == 1 then
			if not starDif && not endDif then
				starDif = self.startpos - self.Entity:GetPos()
				endDif =  self.endpos - self.Entity:GetPos()
			end
			render.SetMaterial(self.Glow)
			render.DrawBeam(self.Entity:GetPos() - starDif, self.Entity:GetPos() - endDif, self.width, self.TextStart, self.TextEnd, Color(self.color.x,self.color.y,self.color.z,self.alpha))
		end
	end
	
	if self.Type == "Quad" then --Lets draw a Quad
		if self.Done == true && self.parent == 0 then
			render.SetMaterial(self.Glow)
			render.DrawQuadEasy(self.pos, self.dir, self.sizex, self.sizey, Color(self.color.x, self.color.y, self.color.z, self.alpha),self.ang)
		end
		if self.Done == true && self.parent == 1 then
			if not Dif then 
				local Dif = self.Entity:GetPos() - self.pos
			end
			render.SetMaterial(self.Glow)
			render.DrawQuadEasy(self.Entity:GetPos() + Vector(Dif), self.dir, self.sizex, self.sizey, Color(self.color.x, self.color.y, self.color.z, self.alpha),self.ang)
		end
	end
end

