

function createGlowShit(self,indx,name,pos,sizex,sizey,color,alpha,parent)
local Ent = self.entity
local n = indx
	if not Ent.IdxS then
		Ent.IdxS = { }
	end
		if table.Count(Ent.IdxS) < 5 then
			if not Ent.IdxS[n] then
				local sprite = ents.Create("E2_Light")
					sprite:SetModel("models/beer/wiremod/gate_e2.mdl" )
					sprite:SetColor(255,255,255,255)
					sprite:SetPos(Vector(pos[1], pos[2], pos[3]))
					sprite:SetParent(Ent)
					sprite:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
					sprite:SetAngles(Ent:GetAngles())
					sprite.Type = "Sprite"
					sprite.tbl = {name, Vector(pos[1], pos[2], pos[3]), sizex, sizey, Vector(color[1], color[2], color[3]), alpha, parent, sprite.Type}
					table.insert(Ent.IdxS, n, sprite)
					sprite:Spawn()
					sprite:Activate()
			end
		end
end
function clipPlane(self, indx, array, plane, dis)
local Ent = self.entity
local n = indx
	if not Ent.IdxC then
		Ent.IdxC = { }
	end
	print("wut")
	if table.Count(Ent.IdxC) < 50 then
		print("the entity is created")
			local Clip = ents.Create("E2_Light")
				Clip:SetModel("models/beer/wiremod/gate_e2.mdl" )
				Clip:SetColor(255,255,255,255)
				Clip:SetPos(Vector(plane[1], plane[2], plane[3]))
				Clip:SetParent(self.entity)
				Clip:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				Clip:SetAngles(self.entity:GetAngles())
				Clip.Type = "Clip"
				Clip.tbl = {array, Vector(plane[1], plane[2], plane[3]), Vector(dis[1], dis[2], dis[3]), Clip.Type}
				table.insert(Ent.IdxC, n, Clip)
				Clip:Spawn()
				Clip:Activate()
		end
	end

function DrawBeam(self,indx,name,startpos,endpos,width,TextStart,TextEnd,color,alpha,parent)
local Ent = self.entity
local n = indx
	if not Ent.IdxD then
		Ent.IdxD = { }
	end
		if table.Count(Ent.IdxD) < 5  then
			if not Ent.IdxD[n] then
				local beam = ents.Create("E2_Light")
					beam:SetModel("models/beer/wiremod/gate_e2.mdl" )
					beam:SetColor(255,255,255,255)
					beam:SetPos(Vector(startpos[1], startpos[2], startpos[3]))
					beam:SetParent(Ent)
					beam:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
					beam:SetAngles(Ent:GetAngles())
					beam.Type = "Beam"
					beam.tbl = {name, Vector(startpos[1], startpos[2], startpos[3]), Vector(endpos[1], endpos[2], endpos[3]), width, TextStart, TextEnd, Vector(color[1], color[2], color[3]), alpha, parent, beam.Type}
					table.insert(Ent.IdxD, n, beam)
					beam:Spawn()
					beam:Activate()
			end		
		end
end
function DynLight(self,indx,pos,size,color,brightnes)
local Ent = self.entity
local n = indx
	if not Ent.IdxL then
		Ent.IdxL = { }
	end
		if table.Count(Ent.IdxL) < 5 then
			if not Ent.IdxL[n] then
				local light = ents.Create("E2_Light")
					light:SetModel("models/beer/wiremod/gate_e2.mdl" )
					light:SetColor(255,255,255,255)
					light:SetPos(Vector(pos[1], pos[2], pos[3]))
					light:SetParent(Ent)
					light:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
					light:SetAngles(Ent:GetAngles())
					light.Type = "light"
					light.tbl = {Vector(pos[1], pos[2], pos[3]), size, Vector(color[1], color[2], color[3]), brightnes, light.Type}
					table.insert(Ent.IdxL, n, light)
					light:Spawn()
					light:Activate()
			end
		end
end

function DrawQuad(self,indx,name,pos,Dir,Sizex,Sizey,Color,alpha,ang,parent)
local Ent = self.entity
local n = indx
	if not Ent.IdxQ then
		Ent.IdxQ = { }
	end
		if table.Count(Ent.IdxQ) < 5 then
			if not Ent.IdxQ[n] then
				local Quad = ents.Create("E2_Light")
					Quad:SetModel("models/beer/wiremod/gate_e2.mdl" )
					Quad:SetColor(255,255,255,255)
					Quad:SetPos(Vector(pos[1], pos[2], pos[3]))
					Quad:SetParent(Ent)
					Quad:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
					Quad:SetAngles(Ent:GetAngles())
					Quad.Type = "Quad"
					Quad.tbl = {name,Vector(pos[1], pos[2], pos[3]),Vector(Dir[1],Dir[2],Dir[3]), Sizex, Sizey, Vector(Color[1], Color[2], Color[3]), alpha, ang, parent, Quad.Type}
					table.insert(Ent.IdxQ, n, Quad)
					Quad:Spawn()
					Quad:Activate()
			end
		end
end

e2function void drawQuad(number indx, string name, vector pos, vector Dir, number Sizex, number Sizey, vector Color, number alpha, angle ang, number parent)
	return DrawQuad(self,indx,name,pos,Dir,Sizex,Sizey,Color,alpha,ang,parent)
end

e2function void array:setRenderClipPlane(number indx, vector plane, vector distance)
	return clipPlane(self,indx,this,plane,distance)
end
e2function void setRenderClipDistance(number indx, vector dis)
local Ent = self.entity
local n = indx
	if (n > 0) then
		if Ent.IdxC then
			if Ent.IdxC[n] then
				Ent.IdxC[n].tbl[3] = Vector(dis[1], dis[2], dis[3])
			end
		end
	end
end

e2function void setRenderClipDirection(number indx, vector plane)
local Ent = self.entity
local n = indx
	if (n > 0) then
		if Ent.IdxC then
			if Ent.IdxC[n] then
				Ent.IdxC[n].tbl[2] = Vector(plane[1], plane[2], plane[3])
			end
		end
	end
end
e2function void drawSprite(number indx, string name, vector pos, number sizex, number sizey, vector color, number alpha, number parent)
	return createGlowShit(self,indx,name,pos,sizex,sizey,color,alpha,parent)
end

e2function void dLight(number indx, vector pos, number size, vector color, number brightnes)
	return DynLight(self,indx,pos,size,color,brightnes)
end

e2function void drawBeam(number indx, string name, vector startpos, vector endpos, number width, number TextStart, number TextEnd, vector color, number alpha, number parent)
	return DrawBeam(self,indx,name,startpos,endpos,width,TextStart,TextEnd,color,alpha,parent)
end

e2function void setSpritePos(number indx, vector pos)
local Ent = self.entity
local n = indx
	if (n > 0) then
		if Ent.IdxS then
			if Ent.IdxS[n] then
				Ent.IdxS[n].tbl[2] = Vector(pos[1], pos[2], pos[3])
			end
		end
	end
end

e2function void setQuadPos(number indx, vector pos)
local Ent = self.entity
local n = indx
	if (n > 0) then
		if Ent.IdxQ then
			if Ent.IdxQ[n] then
				Ent.IdxQ[n].tbl[2] = Vector(pos[1], pos[2], pos[3])
			end
		end
	end
end

e2function void setQuadDir(number indx, vector dir)
local Ent = self.entity
local n = indx
	if (n > 0) then
		if Ent.IdxQ then
			if Ent.IdxQ[n] then
				Ent.IdxQ[n].tbl[3] = Vector(dir[1], dir[2], dir[3])
			end
		end
	end
end

e2function void setSpriteColor(number indx, vector color)
local Ent = self.entity
local n = indx
	if (n > 0) then
		if Ent.IdxS then
			if Ent.IdxS[n] then
				Ent.IdxS[n].tbl[5] = Vector(color[1], color[2], color[3])
			end
		end
	end
end

e2function void setQuadColor(number indx, vector color)
local Ent = self.entity
local n = indx
	if (n > 0) then
		if Ent.IdxQ then
			if Ent.IdxQ[n] then
				Ent.IdxQ[n].tbl[6] = Vector(color[1], color[2], color[3])
			end
		end
	end
end

e2function void setDlightColor(number indx, vector color)
local Ent = self.entity
local n = indx
	if (n > 0) then
		if Ent.IdxL then
			if Ent.IdxL[n] then
				Ent.IdxL[n].tbl[3] = Vector(color[1], color[2], color[3])
			end
		end
	end
end

e2function void setDlightSize(number indx, number size)
local Ent = self.entity
local n = indx
	if (n > 0) then
		if Ent.IdxL then
			if Ent.IdxL[n] then
				Ent.IdxL[n].tbl[2] = size
			end
		end
	end
end

e2function void setDlightBright(number indx, number bright)
local Ent = self.entity
local n = indx
	if (n > 0) then
		if Ent.IdxL then
			if Ent.IdxL[n] then
				Ent.IdxL[n].tbl[4] = bright
			end
		end
	end
end

e2function void setSpriteAlpha(number indx, number alpha)
local Ent = self.entity
local n = indx
	if (n > 0) then
		if Ent.IdxS then
			if Ent.IdxS[n] then
				Ent.IdxS[n].tbl[6] = alpha
			end
		end
	end
end

e2function void setQuadAlpha(number indx, number alpha)
local Ent = self.entity
local n = indx
	if (n > 0) then
		if Ent.IdxQ then
			if Ent.IdxQ[n] then
				Ent.IdxQ[n].tbl[7] = alpha
			end
		end
	end
end

e2function void setSpriteSizeX(number indx, number sizex)
local Ent = self.entity
local n = indx
	if (n > 0) then
		if Ent.IdxS then
			if Ent.IdxS[n] then
				Ent.IdxS[n].tbl[3] = sizex
			end	
		end
	end
end

e2function void setSpriteSizeY(number indx, number sizey)
local Ent = self.entity
local n = indx
	if (n > 0) then
		if Ent.IdxS then
			if Ent.IdxS[n] then
				Ent.IdxS[n].tbl[4] = sizey
			end
		end
	end
end

e2function void setQuadSizeX(number indx, number sizex)
local Ent = self.entity
local n = indx
	if (n > 0) then
		if Ent.IdxQ then
			if Ent.IdxQ[n] then
				Ent.IdxQ[n].tbl[4] = sizex
			end	
		end
	end
end

e2function void setQuadSizeY(number indx, number sizey)
local Ent = self.entity
local n = indx
	if (n > 0) then
		if Ent.IdxQ then
			if Ent.IdxQ[n] then
				Ent.IdxQ[n].tbl[5] = sizey
			end
		end
	end
end

e2function void setQuadAngle(number indx, angle ang)
local Ent = self.entity
local n = indx
	if (n > 0) then
		if Ent.IdxQ then
			if Ent.IdxQ[n] then
				Ent.IdxQ[n].tbl[8] = Angle(ang[1],ang[2],ang[3])
			end
		end
	end
end

e2function void spriteParent(number indx, number parent)
local Ent = self.entity
local n = indx
	if (n > 0) then
		if Ent.IdxS then
			if Ent.IdxS[n] then
				Ent.IdxS[n].tbl[7] = parent
			end
		end
	end
end
		
e2function void removeSprite(number indx)
local Ent = self.entity
local n = indx
	if (n > 0 ) then
		if Ent.IdxS then
			if Ent.IdxS[n] then
				Ent.IdxS[n]:Remove()
				table.remove(Ent.IdxS, n)
			end
		end
	end
end

e2function void removeClip(number indx)
local Ent = self.entity
local n = indx
	if (n > 0 ) then
		if Ent.IdxC then
			if Ent.IdxC[n] then
				Ent.IdxC[n]:Remove()
				table.remove(Ent.IdxC, n)
			end
		end
	end
end

e2function void removeQuad(number indx)
local Ent = self.entity
local n = indx
	if (n > 0 ) then
		if Ent.IdxQ then
			if Ent.IdxQ[n] then
				Ent.IdxQ[n]:Remove()
				table.remove(Ent.IdxQ, n)
			end
		end
	end
end

e2function void removeDlight(number indx)
local Ent = self.entity
local n = indx
	if (n > 0 ) then
		if Ent.IdxL then
			if Ent.IdxL[n] then
				Ent.IdxL[n]:Remove()
				table.remove(Ent.IdxL, n)
			end
		end
	end
end

e2function void removeAllSprites()
local Ent = self.entity
	if Ent.IdxS then
		for k,v in pairs(Ent.IdxS) do
			v:Remove()
		end
		table.Empty(Ent.IdxS)
	end
end

e2function void removeAllClips()
local Ent = self.entity
	if Ent.IdxC then
		for k,v in pairs(Ent.IdxC) do
			v:Remove()
		end
		table.Empty(Ent.IdxC)
	end
end

e2function void removeAllQuads()
local Ent = self.entity
	if Ent.IdxQ then
		for k,v in pairs(Ent.IdxQ) do
			v:Remove()
		end
		table.Empty(Ent.IdxQ)
	end
end

e2function void removeAllDlights()
local Ent = self.entity
	if Ent.IdxL then
		for k,v in pairs(Ent.IdxL) do
			v:Remove()
		end
		table.Empty(Ent.IdxL)
	end
end

registerCallback("destruct", function(self)
local Ent = self.entity
	if Ent.IdxS then	
		if table.Count(Ent.IdxS) > 0 then
			for k,v in pairs (Ent.IdxS) do
				v:Remove()
			end		
		table.Empty(Ent.IdxS)
		end
	end
	
	if Ent.IdxD then
		if table.Count(Ent.IdxD) > 0 then
			for k,v in pairs(Ent.IdxD) do
				v:Remove()
			end
		table.Empty(Ent.IdxD)
		end
	end
	if Ent.IdxL then
		if table.Count(Ent.IdxL) > 0 then
			for k,v in pairs(Ent.IdxL) do
				v:Remove()
			end
		table.Empty(Ent.IdxL)
		end
	end
	if Ent.IdxQ then
		if table.Count(Ent.IdxQ) > 0 then
			for k,v in pairs(Ent.IdxQ) do
				v:Remove()
			end
		table.Empty(Ent.IdxQ)
		end
	end
	if Ent.IdxC then
		if table.Count(Ent.IdxC) > 0 then
			for k,v in pairs(Ent.IdxC) do
				v:Remove()
			end
		table.Empty(Ent.IdxC)
		end
	end
end)