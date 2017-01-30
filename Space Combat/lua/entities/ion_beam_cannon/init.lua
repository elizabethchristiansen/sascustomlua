AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self.Entity:SetModel( "models/Slyfo/mcpcannon.mdl" )
	self.Entity:DrawShadow(false)
	self.Entity:PhysicsInit( SOLID_VPHYSICS ) 	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	--self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self.Entity:SetSolid( SOLID_VPHYSICS ) 
	self.Entity:SetUseType(SIMPLE_USE)  
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:EnableMotion(false)
	end
	
	self.multiplier = 1 	
	
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire", "Multiplier" } ) 
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Multiplier", "Damage %", "Energy/Sec", "Coolant/Sec", "DPS" } )
	
	RD_AddResource(self.Entity,"energy", 0) -- To stop error spam!!
	RD_AddResource(self.Entity,"coolant", 0) -- To stop error spam!!
	
	Wire_TriggerOutput(self.Entity,"Multiplier",self.multiplier) 	
	
	self.playedcharge 	= false
	self.playedfire 	= false	
	self.playedfiring 	= false
	
	self.Sound = CreateSound( self.Entity, Sound("ambient/atmosphere/noise2.wav") )

	self:SetNWFloat( "multiplier", self.multiplier )  --Need this set or in some cases.. like advanced dupes, it can be nil and draw no effect (until the multiplier is changed)
	self:SetNWBool( "hit_eh", false )
	self:SetNWBool( "imp_eh", false )
	self:SetNWEntity( "ent_eh", nil)
	
	Msg(tostring(self:GetOwner()).."\n")
	
	self.LastThink = CurTime()
	self.PerSecondMulti = 1 / 0.195 --Its Not perfect, but a lot closer
					
end

function ENT:OnRemove()
	Dev_Unlink_All(self.Entity)
	Wire_Remove(self.Entity)
	self:StopSound(Sound("ambient.whoosh_huge_incoming1"))
	self:StopSound(Sound("explode_7"))
	self:StopSound(Sound("ambient/atmosphere/noise2.wav"))
	self:StopSound(Sound( "npc/strider/fire.wav" ))
 	--if self.playedfiring == true then
		self.Sound:Stop()
	--end
end

--Stuff from Wire Base so that hopefully you can Advance duplicator this >_<
function ENT:OnRestore()
    Wire_Restored(self.Entity)
end

function ENT:BuildDupeInfo()
	return WireLib.BuildDupeInfo(self.Entity)
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
	WireLib.ApplyDupeInfo( ply, ent, info, GetEntByID )
end

function ENT:PreEntityCopy()
	RD_BuildDupeInfo(self.Entity)
	//build the DupeInfo table and save it as an entity mod
	local DupeInfo = self:BuildDupeInfo()
	if(DupeInfo) then
		duplicator.StoreEntityModifier(self.Entity,"WireDupeInfo",DupeInfo)
	end
end

function ENT:PostEntityPaste(Player,Ent,CreatedEntities)
	RD_ApplyDupeInfo(Ent, CreatedEntities)
	//apply the DupeInfo
	if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
		if (!Player:CheckLimit("ion_cannons")) then self:Remove() return end
		Player:AddCount( "ion_cannons", self ) 
		self.Owner = Player	
		Ent:ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
	end
end
--End of Stuff From Wire Base--

function ENT:SpawnFunction( ply, tr )

if ( !tr.Hit ) then return end
if (!ply:CheckLimit("ion_cannons")) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 20
	
	local ent = ents.Create( "ion_beam_cannon" )
		ent:SetPos( SpawnPos )
		ent:Spawn()
		ent:Activate()
		
		Msg(tostring(ply).."\n")
		self.Owner = ply
		
		ply:AddCount( "ion_cannons", ent ) 	
	return ent
end 

function ENT:DoRes(multi)

	local energy = RD_GetResourceAmount(self, "energy")
	local energyneed = self.energybase * multi
	
	if (energy >= energyneed) then
		local coolant = RD_GetResourceAmount(self, "coolant")
		local coolantneed = self.coolantbase * multi
		
		if (coolant >= coolantneed) then
			RD_ConsumeResource(self, "coolant", coolantneed)
		else
			self:DoHeatDamage(multi)		
		end
	
		self.energytofire = true
		RD_ConsumeResource(self, "energy", energyneed)		
	 	return true		
	else
		self.energytofire = false
		return false
	end 
end

function ENT:DoHeatDamage(multi)
	self.HeatDamage = self.HeatDamage + (1 * multi)
	if self.HeatDamage >= self.HeatHP then
		local effectdata = EffectData()
			effectdata:SetOrigin( self.Entity:GetPos() )
			util.Effect( "Explosion", effectdata )			 -- Explosion effect
			util.Effect( "HelicopterMegaBomb", effectdata )	 -- Big flame

		local firing = self:GetNWBool( "drawbeam")
		
		if firing then
			
			local effectdata = EffectData()
				effectdata:SetMagnitude( 1 )

				local Pos = self.Entity:GetPos()

				effectdata:SetOrigin( Pos )
				effectdata:SetScale( 23000 )
				util.Effect( "warpcore_breach", effectdata )
				local tAllPlayers = player.GetAll()
				
				for _, pPlayer in pairs( tAllPlayers ) do
				pPlayer.Entity:EmitSound( "explode_9" )
				end
				
				self:EmitSound( "explode_9" )
			    if SpaceCombat then
			    	SC_Explode(Pos, 150*(self.multiplier^0.325), {EM=250*(self.multiplier^0.5),EXP=500*(self.multiplier^0.5),KIN=0,THERM=250*(self.multiplier^0.5)}, self.Owner, self.Entity )
				elseif(gcombat) then
					gcombat.hcgexplode( Pos, 150*(self.multiplier^0.325), 1000*(self.multiplier^0.5), 12 )
				else
					util.BlastDamage( self.Entity, self.Owner, Pos, 150*(self.multiplier^0.325), 1000*(self.multiplier^0.5) )
				end
			
		end
			
		self:Remove()	
	end
	Wire_TriggerOutput(self.Entity,"Damage %",(math.Round(((self.HeatDamage/self.HeatHP)*100)*1000))/1000)
end

function ENT:WeaponIdle()
	if self.HeatDamage > 0 then
		local newhp = self.HeatDamage - 1
		if newhp < 0 then
		   	newhp = 0
		end
		self.HeatDamage = newhp
		Wire_TriggerOutput(self.Entity,"Damage %",(math.Round(((self.HeatDamage/self.HeatHP)*100)*1000))/1000)
	end
	self:SetNWBool( "drawbeam", false )
	self:SetNWBool( "hit_eh", false )
	self:SetNWBool( "imp_eh", false )
	self:SetNWEntity( "ent_eh", nil)
	
	if self.playedfiring == true then
		self.Sound:Stop()
		self.playedfiring 	= false
	end

end

function ENT:WeaponFiring()
	local trace = {}
		trace.start = self:GetPos() + (self:GetForward() * 147.5) + (self:GetUp() * 9.25)
		trace.endpos = self:GetPos() + self.Entity:GetForward() * 100000
		trace.filter = self.Entity
			 
	local tr = nil 
				
	if StarGate.Installed then
		tr = StarGate.Trace:New(trace.start, self:GetForward() * 100000, trace.filter)
	else
		tr = util.TraceLine( trace )
	end
	
	local tr2 = nil
	
	if tr.Entity:GetClass() == "event_horizon" and tr.Entity.TargetGate:IsValid() then
	    local ent = tr.Entity.TargetGate.EventHorizon
	    if ent and ent:GetParent():IsBlocked() == false and not ent.ShuttingDown then
	    --Msg("Event Horizon: "..tostring(ent).."\n")
			self:SetNWBool( "hit_eh", true )
			self:SetNWEntity( "ent_eh", ent:EntIndex())
			self:SetNWBool( "imp_eh", true )
		
			local trace2 = {}
				trace2.start = ent:OBBCenter() + ent:GetPos()
				trace2.endpos = ent:GetForward() * 10000
				trace2.filter = {ent:GetParent(), ent}
				
				--Msg("Event Horizon Angle: "..tostring(ent:GetAngles()).."\n")
				--Msg("Beam Angle: "..tostring(self:GetAngles()).."\n")
				--Msg("NEW Angle: "..tostring(self:GetAngles() - ent:GetAngles()).."\n")
				--Msg("IRIS: "..tostring(ent:GetParent():IsBlocked()).."\n")
			
			tr2 = StarGate.Trace:New(trace2.start, trace2.endpos, trace2.filter)
		else
			self:SetNWBool( "hit_eh", false )
			self:SetNWEntity( "ent_eh", nil)
			self:SetNWBool( "imp_eh", true )
		end
	else
		self:SetNWBool( "hit_eh", false )
		self:SetNWEntity( "ent_eh", nil)
		self:SetNWBool( "imp_eh", false )
	end
	
	if not SpaceCombat then
		local i = nil
		if tr2 then
			i = tr2.Entity
		else
			i = tr.Entity
		end
	    if tr.Entity:GetClass() == "shield" then
	        i.Parent.Strength = math.Clamp(i.Parent.Strength-((((10 * self.multiplier)/2000)*100)/(i.Parent.StrengthMultiplier[1]*i.Parent.StrengthConfigMultiplier)),0,100)
			i:Hit(self.Entity,tr.HitPos,1.0) --So it still plays the shields hit effect
		end
		i:TakeDamage(self.damagebase * self.multiplier, self:GetOwner(), self.Entity)
	end
	    
		
	self:SetNWBool( "drawbeam", true )
	self:SetNWBool( "charging", false )
	
	if tr2 and tr2.Entity:IsValid() then
		--Msg("Damaging TR2: "..tostring(tr2.Entity).."\n")
		if SpaceCombat then
			if tr2.Entity:GetClass() == "sga_shield" then
				tr2.Entity:Hit(self, tr2.HitPos, self.damagebase * 2 * self.multiplier, -1*tr2.Normal)
			else 			
				SC_ApplyDamage(tr2.Entity, {EM=(self.damagebase*0.75)  * self.multiplier,EXP=0,KIN=0,THERM=(self.damagebase*0.25) * self.multiplier}, self.Owner, self.Entity)
	        end
		elseif(gcombat) then
			cbt_dealnrghit( tr2.Entity, self.damagebase  * self.multiplier, 12, tr2.HitPos, tr2.HitPos)
		else
		 	tr2.Entity:TakeDamage(self.damagebase  * self.multiplier, self.Owner, self.Entity)
		end
	else
		--Msg("Damaging TR: "..tostring(tr.Entity).."\n")
		if SpaceCombat then
			if tr.Entity:GetClass() == "sga_shield" then
				tr.Entity:Hit(self, tr.HitPos, self.damagebase * 2 * self.multiplier, -1*tr.Normal)
			else 			
				SC_ApplyDamage(tr.Entity, {EM=(self.damagebase*0.75)  * self.multiplier,EXP=0,KIN=0,THERM=(self.damagebase*0.25) * self.multiplier}, self.Owner, self.Entity)
	        end
		elseif(gcombat) then
			cbt_dealnrghit( tr.Entity, self.damagebase * self.multiplier, 12, tr.HitPos, tr.HitPos)
		else
			tr.Entity:TakeDamage(self.damagebase * self.multiplier, self.Owner, self.Entity)
		end
	end
end  

function ENT:Think()
	/*
	--Used to measure time think takes to run
	local thinkdelay = CurTime() - self.LastThink
	print(thinkdelay)
	self.LastThink = CurTime()
	*/


	if self.triggerfire then
		self:DoRes(self.multiplier)
		
		if self.playedcharge == false and self.energytofire then
			self:EmitSound(Sound("ambient.whoosh_huge_incoming1"))

			self:SetNWBool( "charging", true )
			self.playedcharge = true 				
		elseif not self.energytofire then
			self:StopSound(Sound("ambient.whoosh_huge_incoming1"))
			self.Sound:Stop()
			self.playedcharge = false
		end
		
		if not self.energytofire then  --stop it from holding charge when energy breaks
			self:SetNWBool( "charging", false )
			self.chargetime = CurTime() + 6	
		end		
					
		if	self.energytofire and CurTime() > self.chargetime  then
		
			if self.playedfire == false and self.energytofire then
				self:EmitSound(Sound("explode_7"))
				self:EmitSound(Sound( "npc/strider/fire.wav" ))
				self.playedfire = true 				
			elseif not self.energytofire then  				
				self:StopSound(Sound("explode_7"))
				self:StopSound(Sound( "npc/strider/fire.wav" ))
				self.playedfire = false 			
			end 
			
			if self.playedfiring == false and self.energytofire then
				--self:EmitSound(Sound("ambient/atmosphere/noise2.wav"))
				self.Sound:Play()
				self.playedfiring = true 				
			elseif not self.energytofire then   				
				self:StopSound(Sound("ambient/atmosphere/noise2.wav"))
				self.playedfiring = false 			
			end  			

			self:WeaponFiring()	
				
		else
			self:WeaponIdle()	
		end		
	else
		self:StopSound(Sound("ambient.whoosh_huge_incoming1"))
		self:StopSound(Sound("explode_7"))
		self:StopSound(Sound("ambient/atmosphere/noise2.wav"))
		self:StopSound(Sound( "npc/strider/fire.wav" ))
		
		if self.playedfiring == true then
			self.Sound:Stop()
			self.playedfiring 	= false
		end
		
		self:WeaponIdle()
		self:SetNWBool( "charging", false )
	end
	
	self:SetNWFloat( "multiplier", self.multiplier )
	
	local coolantneedsec = math.Round( (self.coolantbase * self.multiplier) * self.PerSecondMulti )
	local energyneedsec = math.Round( (self.energybase * self.multiplier) * self.PerSecondMulti )
	local damagesec = math.Round( (self.damagebase * self.multiplier) * self.PerSecondMulti )
	Wire_TriggerOutput(self.Entity,"Energy/Sec",energyneedsec)
	Wire_TriggerOutput(self.Entity,"Coolant/Sec",coolantneedsec)
	Wire_TriggerOutput(self.Entity,"DPS",damagesec)
	 		
end

function ENT:TriggerInput(iname, value)
	if (iname == "Fire") then
		if value == 1 then
			self.chargetime = CurTime() + 6			
			self.triggerfire = true
		else 			
			self.triggerfire = false
			

			self:StopSound(Sound("ambient.whoosh_huge_incoming1"))
			self:StopSound(Sound("explode_7"))
			self:StopSound(Sound("ambient/atmosphere/noise2.wav"))
			self:StopLoopingSound(Sound("ambient/atmosphere/noise2.wav"))
			
			if self.playedfiring == true then
				self.Sound:Stop()
				self.playedfiring = false
			end
   			self.playedcharge 	= false
			self.playedfire 	= false

			self:StopSound(Sound( "npc/strider/fire.wav" ))
			self:SetNWBool( "charging", false )
		end
	elseif (iname == "Multiplier") then
		if value < 1 then
			self.multiplier = 1
			self:SetNWFloat( "multiplier", self.multiplier )
		else
			if value > 1000 then -- Cap it to stop crashing :P 
				self.multiplier = 1000
				self:SetNWFloat( "multiplier", self.multiplier )
			else 			
				self.multiplier = value
				self:SetNWFloat( "multiplier", self.multiplier )
			end 	  		
		end
		Wire_TriggerOutput(self.Entity,"Multiplier",self.multiplier)
	end
end

