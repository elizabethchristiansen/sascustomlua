AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self.Entity:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS ) 	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS ) 
	self.Entity:SetUseType(SIMPLE_USE)  
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		--phys:Wake()
		--phys:EnableGravity(true)
		--phys:EnableDrag(true)
		--phys:EnableCollisions(true)
		--phys:EnableMotion(true)
	end
	
	self.Inputs = Wire_CreateInputs( self.Entity, { "Destruct"} )
	
	self:SetOverlayText(self.PrintName)
	
	

end

function ENT:SpawnFunction( ply, tr )
if ( !tr.Hit ) then return end    	
	local SpawnPos = tr.HitPos + tr.HitNormal * 25
	local ent = ents.Create( "sc_self_destruct" )
		ent:SetPos( SpawnPos )
		ent:Spawn()
		ent:Activate()
		ent.Owner = ply 
	return ent
end

function ENT:OnRemove()

	Wire_Remove(self.Entity)
	
end 

function ENT:Use(ply)

end

function ENT:Think()
	self.BaseClass.Think(self)	
end

function ENT:Destruct()
	if not self.SC_CoreEnt:IsValid() then return false end
	
	local ent = self.SC_CoreEnt
	local coretable = ent.ConWeldTable
	local pos = ent:GetPos()
	
	local AvoidMB = true 	
	
	for _,i in pairs( constraint.GetAllConstrainedEntities_B( ent ) ) do 						
		if (string.find(i:GetClass(),"prop") ~= nil) then
			local delay = math.Rand(3, 10)
			i.Entity:SetSolid( SOLID_VPHYSICS )
			i.Entity:SetCollisionGroup(COLLISION_GROUP_PROJECTILE) 
			i.Entity:DrawShadow( false )
			i.Entity:SetKeyValue("exploderadius","1")
			i.Entity:SetKeyValue("explodedamage","1")
			i.Entity:Fire("break","",tostring(delay + 10))
			i.Entity:Fire("kill","",tostring(delay + 10))
			i.Entity:Fire("enablemotion","",0) --bye bye fort that took you 4 hours to make 							
			constraint.RemoveAll( i.Entity )
       		local physobj = i:GetPhysicsObject()
			if(physobj:IsValid()) then
        		physobj:Wake()
				physobj:EnableMotion(true)
			end
		else
			if (i.Entity:IsValid()) and not string.find(i:GetClass(),"ship_core") then
				i.Entity:Remove()
			end
		end 			
	end 	
	
	for _,i in pairs( ent.ConWeldTable ) do
        if i:IsValid() then
			local physobj = i:GetPhysicsObject()
			local vec = (i:NearestPoint(pos) - pos):Normalize()
			local dist = (i:NearestPoint(pos) - pos):Length()
			local vel = math.Clamp(dist,0,4000) 
			physobj:AddVelocity(vec * ((1-(vel/4000))*400))
		end
	end
	
	--Stops Multiple blast effects playing at once for whatever reason they do
	if AvoidMB then
		local effectdata = EffectData()
		effectdata:SetMagnitude( 1 )
					
		local Pos = ent:GetPos()
	
		effectdata:SetOrigin( Pos )
		effectdata:SetScale( 23000 )
		util.Effect( "warpcore_breach", effectdata )
		local tAllPlayers = player.GetAll()
		for _, pPlayer in pairs( tAllPlayers ) do
			pPlayer.Entity:EmitSound( "explode_9" )
		end
		ent:EmitSound( "explode_9" )
						
		AvoidMB = false
	end
	
	SC_Destruct_Explode(ent:GetPos(), (ent.Hull.Max^0.625), {EM=(ent.Hull.Max/4) ,EXP=(ent.Hull.Max/4) ,KIN=(ent.Hull.Max/4) ,THERM=(ent.Hull.Max/4)},ent, ent)
					
	ent:Remove()
	self:Remove()	

end  

function ENT:TriggerInput(iname, value)
	if (iname == "Destruct") then
		if(value == 1) then
			self:Destruct()
  		end
	end
end





