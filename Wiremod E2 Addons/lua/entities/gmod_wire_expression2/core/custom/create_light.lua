local function CheckIndex( self, Index )
	if (self.LightEnt) then
		if (self.LightEnt[Index]) then
			return (self.LightEnt[Index].Index == Index)
		end
	else
		if (!self.player.LightEnt) then self.player.LightEnt = {} end
		self.LightEnt = {}
		return false
	end
end

local function GetLight( self, Index )
	if (CheckIndex( self, Index )) then
		return self.LightEnt[Index] or nil
	end
end

local function GetIndex( self, light )
	if (!light:IsValid()) then return nil end
	return light.Index or nil
end

local function Create( self, Index, Clr, Pos, Distance, Brightness )
	local light = GetLight( self, Index )
	if (!light) then
		light = ents.Create("light_dynamic")
		if (!light:IsValid()) then return end
		self.LightEnt[Index] = light
		self.player.LightEnt[table.Count(self.player.LightEnt)+1] = light
		light.Index = Index
		light:SetPos( Pos )
		light:SetKeyValue("_light", Clr[1] .. " " .. Clr[2] .. " " .. Clr[3] .. " " .. 255 )
		light:SetKeyValue("style",0)
		light:SetKeyValue("distance", math.Clamp(Distance,50,255))
		light:SetKeyValue("brightness",math.Clamp(Brightness,1,10))
		light:Spawn()
	else
		light:SetPos( Pos )
		light:SetKeyValue("_light", Clr[1] .. " " .. Clr[2] .. " " .. Clr[3] .. " " .. 255 )
		light:SetKeyValue("style",0)
		light:SetKeyValue("distance", math.Clamp(Distance,50,255))
		light:SetKeyValue("brightness", math.Clamp(Brightness,1,10))
	end
end

local function Position( self, Index, Pos )
	if (CheckIndex( self, Index )) then
		GetLight( self, Index ):SetPos( Pos )
	end
end

-- For some reason this does not work... :(
local function Color( self, Index, Clr )
	if (CheckIndex( self, Index )) then
		GetLight( self, Index):SetKeyValue("_light", Clr[1] .. " " .. Clr[2] .. " " .. Clr[3] .. " " .. 255 )
		--GetLight( self, Index):SetColor( Clr[1], Clr[2], Clr[3], 255 )
	end
end

local function RemoveLight( self, Index )
	if (CheckIndex( self, Index )) then
		local light = GetLight( self, Index )
		self.LightEnt[Index] = nil
		light:Remove()
	end
end

local function ToggleLight( self, Index, OnOff )
	if (CheckIndex( self, Index )) then
		if (OnOff != 0) then
			GetLight(self, Index):Fire("TurnOn","","0")
		else
			GetLight(self, Index):Fire("TurnOff","","0")
		end
	end
end

local function ClearLights( self )
	if (!self.player.LightEnt) then return end
	for _,ent in pairs(self.player.LightEnt) do
		local index = GetIndex( self, ent )
		if (index) then
			RemoveLight( self, index )
		end
	end
end

-----------------------------

e2function void lightCreate( number Index )
	Create( self, Index, {255,255,255}, self.entity:GetPos() + Vector(0,0,10), 255, 5 )
end

e2function void lightCreate( number Index, vector Clr )
	Create( self, Index, Clr, self.entity:GetPos() + Vector(0,0,10), 255, 5 )
end

e2function void lightCreate( number Index, vector Clr, vector Pos )
	Create( self, Index, Clr , Vector( Pos[1], Pos[2], Pos[3] ), 255, 5 )
end

e2function void lightCreate( number Index, vector Clr, vector Pos, number Distance )
	Create( self, Index, Clr , Vector( Pos[1], Pos[2], Pos[3] ), Distance, 5 )
end

e2function void lightCreate( number Index, vector Clr, vector Pos, number Distance, number Brightness )
	Create( self, Index, Clr , Vector( Pos[1], Pos[2], Pos[3] ), Distance, Brightness )
end

e2function void lightPos( number Index, vector Pos )
	Position( self, Index, Vector( Pos[1], Pos[2], Pos[3] ) )
end

-- Does not work :(
e2function void lightColor( number index, vector Clr )
	Color( self, Index, Clr )
end

e2function void lightRemove( number Index )
	RemoveLight( self, Index )
end

e2function entity lightEntity( number Index )
	return GetLight( self, Index )
end

e2function void lightToggle( number Index, number OnOff )
	ToggleLight( self, Index, OnOff )
end

e2function void lightRemoveAll()
	ClearLights( self )
end

e2function void lightParent( number Index, number Index2 )
	if (!CheckIndex( self, Index ) or !CheckIndex( self, Index2)) then return end
	GetLight( self, Index):SetParent( GetLight( self, Index2 ))
end

e2function void lightParent( number Index, entity Entity )
	if (!CheckIndex( self, Index ) or !Entity:IsValid()) then return end
	GetLight( self, Index):SetParent( Entity )
end

e2function void lightUnparent( number Index )
	if (!CheckLight( self, Index )) then return end
	local light = GetLight( self, Index )
	light:SetParent( nil )
	light:SetParentPhysNum(0)
end

-----------------------------


registerCallback("construct", function(self)
	ClearLights( self )
end)

registerCallback( "destruct", function(self)
	if !self or !validEntity(self.entity) then return end
	ClearLights( self )
end)