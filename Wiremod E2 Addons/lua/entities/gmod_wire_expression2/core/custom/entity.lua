/******************************************************************************\
Entity Core by Informatixa and MetaGamerz Team
\******************************************************************************/

E2Lib.RegisterExtension("entitycore", false)

hook.Add("PlayerInitialSpawn", "wire_expression2_entitycore", function(ply)
	ply:SendLua('language.Add("Undone_e2_spawned_entity", "E2 Spawned Entity")')
end)

local sbox_e2_maxentitys = CreateConVar( "sbox_e2_maxentitys", "-1", FCVAR_ARCHIVE )
local sbox_e2_maxentitys_persecond = CreateConVar( "sbox_e2_maxentitys_persecond", "4", FCVAR_ARCHIVE )
local sbox_e2_entitycore = CreateConVar( "sbox_e2_entitycore", "2", FCVAR_ARCHIVE )

local E2Helper = { Descriptions = {} }
local E2totalspawnedentitys = 0
local E2tempSpawnedEntitys = 0
local TimeStamp = 0

local function TempReset()
 if (CurTime()>= TimeStamp) then
	E2tempSpawnedEntitys = 0
	TimeStamp = CurTime()+1
 end
end
hook.Add("Think","TempReset",TempReset)

local function ValidSpawn()
	--if E2tempSpawnedEntitys >= sbox_e2_maxentitys_persecond:GetInt() then return false end
	if sbox_e2_maxentitys:GetInt() <= -1 then
		return true
	elseif E2totalspawnedentitys >= sbox_e2_maxentitys:GetInt() then
		return false
	end
	return true
end

local function ValidAction(ply)
	return sbox_e2_entitycore:GetInt()==2 or (sbox_e2_entitycore:GetInt()==1 and ply:IsAdmin())
end

local function createentitysfromE2(self,entity,pos,angles,freeze)
	if not ValidSpawn() then return nil end
	local ent = ents.Create(entity)
	if not ValidEntity(ent) then return nil end
	ent:SetPos(pos)
	ent:SetAngles(angles)
	--ent:SetPlayer(self.player)
	ent:Spawn()
	self.player:AddCleanup( "props", ent )
	undo.Create("e2_spawned_entity")
		undo.AddEntity( ent )
		undo.SetPlayer( self.player )
	undo.Finish()
	local phys = ent:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		if freeze then phys:EnableMotion( false ) end
	end
	--ent.OnDieFunctions.GetCountUpdate.Function2 = ent.OnDieFunctions.GetCountUpdate.Function
	--ent.OnDieFunctions.GetCountUpdate.Function =  function(self,player,class)
	--	if CLIENT then return end
	--	E2totalspawnedentitys=E2totalspawnedentitys-1
	--	self.OnDieFunctions.GetCountUpdate.Function2(self,player,class)
	--end
	E2totalspawnedentitys = E2totalspawnedentitys+1
	E2tempSpawnedEntitys = E2tempSpawnedEntitys+1
	return ent.Entity
end

--------------------------------------------------------------------------------
e2function entity entitySpawn(string entity, number frozen)
	if not ValidAction(self.player) then return nil end
	return createentitysfromE2(self,entity,self.entity:GetPos()+self.entity:GetUp()*25,self.entity:GetAngles(),frozen)
end

e2function entity entitySpawn(entity template, number frozen)
	if not ValidAction(self.player) then return nil end
	if not validEntity(template) then return nil end
	return createentitysfromE2(self,template:GetClass(),self.entity:GetPos()+self.entity:GetUp()*25,self.entity:GetAngles(),frozen)
end

e2function entity entitySpawn(string entity, vector pos, number frozen)
	if not ValidAction(self.player) then return nil end
	return createentitysfromE2(self,entity,Vector(pos[1],pos[2],pos[3]),self.entity:GetAngles(),frozen)
end

e2function entity entitySpawn(entity template, vector pos, number frozen)
	if not ValidAction(self.player) then return nil end
	if not validEntity(template) then return nil end
	return createentitysfromE2(self,template:GetClass(),Vector(pos[1],pos[2],pos[3]),self.entity:GetAngles(),frozen)
end

e2function entity entitySpawn(string entity, angle rot, number frozen)
	if not ValidAction(self.player) then return nil end
	return createentitysfromE2(self,entity,self.entity:GetPos()+self.entity:GetUp()*25,Angle(rot[1],rot[2],rot[3]),frozen)
end

e2function entity entitySpawn(entity template, angle rot, number frozen)
	if not ValidAction(self.player) then return nil end
	if not validEntity(template) then return nil end
	return createentitysfromE2(self,template:GetClass(),self.entity:GetPos()+self.entity:GetUp()*25,Angle(rot[1],rot[2],rot[3]),frozen)
end

e2function entity entitySpawn(string entity, vector pos, angle rot, number frozen)
	if not ValidAction(self.player) then return nil end
	return createentitysfromE2(self,entity,Vector(pos[1],pos[2],pos[3]),Angle(rot[1],rot[2],rot[3]),frozen)
end

e2function entity entitySpawn(entity template, vector pos, angle rot, number frozen)
	if not ValidAction(self.player) then return nil end
	if not validEntity(template) then return nil end
	return createentitysfromE2(self,template:GetClass(),Vector(pos[1],pos[2],pos[3]),Angle(rot[1],rot[2],rot[3]),frozen)
end

e2function void entity:setModel(string model)
	if not ValidAction(self.player) then return end
	if not ValidEntity(this) then return nil end
	if(!isOwner(self, this)) then return end
	this:SetModel(model)
end

--------------------------------------------------------------------------------
e2function void entity:setPos(x, y, z)
	if not ValidAction(self.player) then return end
	if not validPhysics(this) then return end
	if not isOwner(self, this) then return end
	local phys = this:GetPhysicsObject()
	phys:SetPos(Vector(x,y,z))
	phys:Wake()
	if(!phys:IsMoveable())then
	phys:EnableMotion(true)
	phys:EnableMotion(false)
	end
end

e2function void entity:reposition(x, y, z) = e2function void entity:setPos(x, y, z)

e2function void entity:setAng(x, y, z)
	if not ValidAction(self.player) then return end
	if not validPhysics(this) then return end
	if not isOwner(self, this) then return end
	local phys = this:GetPhysicsObject()
	phys:SetAngle(Angle(x,y,z))
	phys:Wake()
	if(!phys:IsMoveable())then
	phys:EnableMotion(true)
	phys:EnableMotion(false)
	end
end

e2function void entity:rerotate(x, y, z) = e2function void entity:setAng(x, y, z)
