AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function Make_sc_turret(pl, Pos, Ang, type)
	if ( !pl:CheckLimit( "sc_turret" ) ) then return nil end
		
	local Core = ents.Create("sc_turret")
		
	Core:SetPos(Pos)
	Core:SetAngles(Ang)
	Core:Spawn()
	Core:Activate()
	Core:Setup(type, pl)

	Core.Owner = pl

	pl:AddCount( "sc_turret", Core )
		
	return Core
end

function ENT:Setup( type, ply )

	self.type = type
	
	if type == "Small Pulse Laser" then
  		
		self.SC_Fitting = {
			Slot = 	"HIGH",
			CPU = 	33.00,
			PG = 	10.00
		}
		
		self.SC_Turret = {
			OptimalRange = 2000,
			Scale = 1.0,
			TrackingAccuracy = 0.02,
			BaseDamage = 150,
			TrackingSpeed = 2,
			CapUse = 30,
			CycleTime = 2.7
		}
		
		self.NameLable = type

	
	elseif type == "Medium Pulse Laser" then
  		
		self.SC_Fitting = {
			Slot = 	"HIGH",
			CPU = 	38.00,
			PG = 	40.00
		}
		
		self.SC_Turret = {
			OptimalRange = 4000,
			Scale = 3.0,
			TrackingAccuracy = 0.01,
			BaseDamage = 1000,
			TrackingSpeed = 1.2,
			CapUse = 1000/5,
			CycleTime = 5.25
		}
		
		self.NameLable = type

	elseif type == "Large Pulse Laser" then
  		
		self.SC_Fitting = {
			Slot = 	"HIGH",
			CPU = 	70.00,
			PG = 	10000.00
		}
		
		self.SC_Turret = {
			OptimalRange = 7000,
			Scale = 6.0,
			TrackingAccuracy = 0.005,
			BaseDamage = 5000,
			TrackingSpeed = 1.2,
			CapUse = 1000,
			CycleTime = 7
		}
		
		self.NameLable = type

	else
		
		self.SC_Turret = {
			OptimalRange = 0,
			Scale = 1.0,
			TrackingAccuracy = 0,
			BaseDamage = 0,
			TrackingSpeed = 0,
			CapUse = 0,
			CycleTime = 0
		}
	
		
		self.SC_Fitting = {
			Slot = 	"HIGH",
			CPU = 	1.00,
			PG = 	1.00
		}
		self.NameLable = "FAIL"

	end
	
	self.SC_Status = "Offline"	
	
	
	--if not SERVER then
	--	local scale = Vector(self.SC_Turret.Scale, self.SC_Turret.Scale, self.SC_Turret.Scale)
		
	--	self.Entity:SetModelScale(scale)
		
	--	self.UpperEnt:SetPos(self.Entity:LocalToWorld(self.SC_Turret.Scale * Vector(34.2139-33.9297,12.6868-13.0935,53.9424-33.6768) ) )
	--	self.UpperEnt:SetModelScale(scale)
		
	--	self.BarrelEnt:SetPos(self.Entity:LocalToWorld(self.SC_Turret.Scale * Vector(0.6074-33.9297,0,82.7949-33.6768)) )
	--	self.BarrelEnt:SetModelScale(scale)
	--end
	
	--self.ShootOffset = self.SC_Turret.Scale * Vector(0,0,82.7949-33.6768)
	
end

duplicator.RegisterEntityClass("sc_turret", Make_sc_turret, "Pos", "Ang","type")

function ENT:Initialize()



	-- Create the entity
	self.Entity:SetModel( "models/stat_turrets/st_turretswivel.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS ) 	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS ) 
	self.Entity:SetUseType(SIMPLE_USE)  
	self.Entity:SetMaterial("models/gibs/metalgibs/metal_gibs")
	self.Entity:SetColor(100, 100,100,255)
	self.Entity:SetAngles(Angle(0,0,0))
	
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:EnableMotion(true)
	end 
	
	
	
	-- Create the upper ent
	self.UpperEnt = ents.Create( "base_anim" )
	self.UpperEnt:SetSolid( SOLID_NONE )
	self.UpperEnt:SetMoveType( MOVETYPE_NONE )
	self.UpperEnt:DrawShadow( true )
	self.UpperEnt:SetMaterial("models/gibs/metalgibs/metal_gibs")
	self.UpperEnt:SetModel( "models/stat_turrets/st_turretdualani.mdl" )
	self.UpperEnt:SetColor(100,100,100,255)
	self.UpperEnt:SetAngles(Angle(0,180,0))
	self.UpperEnt:SetPos(self.Entity:LocalToWorld(Vector(34.2139-33.9297,12.6868-13.0935,53.9424-33.6768) ) )
	self.UpperEnt:SetParent(self.Entity)
	
	-- Create the gun barrel
	self.BarrelEnt = ents.Create( "base_anim" )
	self.BarrelEnt:SetSolid( SOLID_NONE )
	self.BarrelEnt:SetMoveType( MOVETYPE_NONE )
	self.BarrelEnt:DrawShadow( true )
	self.BarrelEnt:SetModel( "models/slyfo/warhead.mdl" )
	self.BarrelEnt:SetAngles(Angle(0,0,0))
	self.BarrelEnt:SetPos(self.Entity:LocalToWorld(Vector(-30,0,82.7949-33.6768)) )
	self.BarrelEnt:SetParent(self.UpperEnt)
	self.BarrelEnt:SetColor(0,0,0,255)
	--self.SoundIsPlaying = false
	--self.SoundStartedAt = 0
	
	self.ShootOffset = Vector(0,0,82.7949-33.6768)
	self.SC_Status = "Offline"
	self.SC_Immune2 = true
	self.ShouldFire = false
	self.TargetPosition = nil
	self.TargetEntity = nil
	self.CurrentAim = self.Entity:GetForward()
	self.NextCycle = CurTime()
	self.LastThinkTime = CurTime()
	
	self.Inputs = WireLib.CreateSpecialInputs( self.Entity, {"Fire", "Target Position", "Target Entity"}, {"NORMAL","VECTOR","ENTITY"} )
	self.Outputs = Wire_CreateOutputs( self.Entity, {} )
end

function ENT:SpawnFunction( ply, tr )
if ( !tr.Hit ) then return end    	
	local SpawnPos = tr.HitPos + tr.HitNormal * 100 	
	local ent = ents.Create( "sc_turret" )
		ent:SetPos( SpawnPos )
		ent:Spawn()
		ent:Activate() 
		ent:Setup()
	return ent
end

function ENT:OnRemove()
	
end

function ENT:Use()
	
end 

function ENT:Think()
	self.BaseClass.Think(self)
	
	--if self.SoundIsPlaying == true and CurTime() >= self.SoundStartedAt + 1 then
	--	self.Entity:StopSound("npc/stalker/laser_flesh.wav")
	--	self.SoundIsPlaying = false
	--end
	
	
	if not self.SC_CoreEnt then self.SC_Status = "Offline" end
		
	local weaponinfo = {}	
	if ValidEntity( self.SC_CoreEnt ) then
		weaponinfo = self.SC_CoreEnt:GetWeaponInfo()
	end
		
	local reslab = ""
	
	if self.SC_Turret.OptimalRange > 0 then
		reslab = reslab .. "Optimal range: " .. self.SC_Turret.OptimalRange .. " units\n"
	end	
	if self.SC_Turret.BaseDamage > 0 then
		reslab = reslab .. "Base Damage: " .. self.SC_Turret.BaseDamage .. "\n"
	end	
	if self.SC_Turret.TrackingAccuracy > 0 then
		reslab = reslab .. "Tracking Accuracy: " .. self.SC_Turret.TrackingAccuracy .. " rads\n"
	end	
	if self.SC_Turret.TrackingSpeed > 0 then
		reslab = reslab .. "Tracking Speed: " .. self.SC_Turret.TrackingSpeed .. " rads/s\n"
	end	
	if self.SC_Turret.CapUse > 0 then
		reslab = reslab .. "Cap Use: " .. self.SC_Turret.CapUse .. " per shot\n"
	end	
	if self.SC_Turret.CycleTime > 0 then
		reslab = reslab .. "Cycle Time: " .. self.SC_Turret.CycleTime .. "s\n"
	end	

	self:SetOverlayText(self.NameLable.."\n"..
	reslab.."\n"..
	"-Fitting-".."\n"..
	"CPU: "..tostring(self.SC_Fitting.CPU).."\n"..
	"PG: "..tostring(self.SC_Fitting.PG).."\n"..
	"Status: "..self.SC_Status	
	)
	
	if self.SC_Status == "Offline" then return end
	
	-- Update the position of the upper turret and barrel to match our CurrentAim
	self.UpperEnt:SetAngles(self.CurrentAim:Normalize():Angle())
	
	
	
	if self.TargetEntity != nil then self.TargetPosition = self.TargetEntity:GetPos() end
	
	if self.TargetPosition != nil then
	
		-- Update our current aim position
		local idealAimDir = (self.TargetPosition - self.Entity:LocalToWorld(self.ShootOffset)):Normalize()
		
		if idealAimDir:Dot(self.Entity:GetUp() ) < -0.08 then return end
		
		local axis = self.CurrentAim:Normalize():Cross(idealAimDir)
		local missingAng = math.asin(axis:Length())
		
		
		-- How much time has passed?
		local dt = CurTime() - self.LastThinkTime
		self.LastThinkTime = CurTime()
		
		local angularChangeThisTick = dt * math.Clamp(missingAng/dt, -self.SC_Turret.TrackingSpeed, self.SC_Turret.TrackingSpeed)
		
		-- Limit the accuracy
		if (angularChangeThisTick < self.SC_Turret.TrackingAccuracy) and (angularChangeThisTick > 0) then
			angularChangeThisTick = 0
		elseif (angularChangeThisTick > -self.SC_Turret.TrackingAccuracy) and (angularChangeThisTick < 0) then
			angularChangeThisTick = 0
		end
		
		
		-- Perform the change
		local a = Angle(0,0,0)
		a:RotateAroundAxis(axis:Normalize(), (180/math.pi) * angularChangeThisTick)
		
		self.CurrentAim:Rotate( a )
	
	
		if self.ShouldFire == true then
			self:DoFire()
		end
	end
	
	self:NextThink(CurTime() + 1/66)
	return true
end


function ENT:DoFire()
	if not self.SC_CoreEnt then return false end


	if self.NextCycle <= CurTime() then
		
		-- Do we have enough cap?
		if self.SC_CoreEnt.Cap.CAP < self.SC_Turret.CapUse then return end
		
		-- We do, use some
		self.SC_CoreEnt:ConsumeCap(self.SC_Turret.CapUse)
		
		

		
		-- Trace to see if we hit something
		local traceParam = {}
		traceParam.start = self.Entity:LocalToWorld(self.ShootOffset) + self.CurrentAim:Normalize()
		traceParam.endpos = self.Entity:LocalToWorld(self.ShootOffset) + self.CurrentAim:Normalize() * 10000
		traceParam.filter = self.Entity

		local trace = nil
		trace = util.TraceLine( traceParam )
	
		local hitPos = nil
	
		if trace.Entity:IsValid() then
		
		
			hitPos = trace.HitPos
		
			local dist = (self.Entity:LocalToWorld(self.ShootOffset) - hitPos):Length()
		
			local distanceDmgScale = 1
			if dist > self.SC_Turret.OptimalRange then
				distanceDmgScale = ((self.SC_Turret.OptimalRange - dist) / dist) ^ 3
			end
		
			-- We did hit something, do some damage to it
		
			-- How much damage should we do?
		
			local dmg_kin = 0
			local dmg_em = 0.3 * self.SC_Turret.BaseDamage * distanceDmgScale
			local dmg_therm = 0.7 * self.SC_Turret.BaseDamage * distanceDmgScale
			local dmg_exp = 0 
			local totaldamage = dmg_em + dmg_exp + dmg_kin + dmg_therm
		
			if trace.Entity:GetClass() == "sga_shield" then
				trace.Entity:Hit( self.Entity, trace.HitPos, totaldamage, -1*trace.Normal )
			else			
				SC_ApplyDamage( trace.Entity, { EM = ( dmg_em ), EXP = ( dmg_exp ), KIN = ( dmg_kin ), THERM = ( dmg_therm ) }, self.Owner, self.Entity )
			end	
		
			--self.Entity:EmitSound("npc/stalker/laser_flesh.wav", 500, 60)
			--self.SoundIsPlaying = true
			--self.SoundStartedAt = CurTime()
		
		else
			hitPos = self.Entity:LocalToWorld(self.ShootOffset) + 10000 * self.CurrentAim:Normalize()
		
		end
		
		-- Create a laser effect
		fx = EffectData()
		fx:SetOrigin(self.Entity:LocalToWorld(self.ShootOffset))
		fx:SetStart(hitPos)
		fx:SetMagnitude(1)
		fx:SetAngle(Angle(0,0,0))
		fx:SetScale(120*self.SC_Turret.Scale)
		util.Effect("smallrailtrace",fx)
		
		
		
		
		
		-- Prepare for next cycle
		self.NextCycle = CurTime() + self.SC_Turret.CycleTime
	end
	
end

function ENT:TriggerInput(iname, value)
	if (iname == "Fire") then
		if value == 1 then
			self.ShouldFire = true
			self:DoFire() 
		else
		 	self.ShouldFire = false  
		end		
	end
	
	if (iname == "Target Position") then 
		self.TargetPosition = value
	end
	
	if (iname == "Target Entity") then
		self.TargetEntity = value
	end
end


function ENT:OnRestore()
    Wire_Restored( self )
end

function ENT:BuildDupeInfo()	
	local Info = WireLib.BuildDupeInfo( self.Entity )
	
	if Info == nil then
		Info = {}
	end
	
	local function frombool( Value )	
		if util.tobool( Value ) then 
			return 1 
		else 
			return 0 
		end
	end
	
	Info.type	= self.type 
    
	return Info
end

function ENT:ApplyDupeInfo( Player, Entity, Info, GetEntByID )
	self:Setup( Info.type, Player )
	self.Owner = Player
	
	WireLib.ApplyDupeInfo( Player, Entity, Info, GetEntByID )		
end

function ENT:PreEntityCopy()
	local DupeInfo = self:BuildDupeInfo()
	if DupeInfo then
		duplicator.StoreEntityModifier( self, "WireDupeInfo", DupeInfo )
	end
end

function ENT:PostEntityPaste( Player, Entity, CreatedEntities )
	if Entity.EntityMods and Entity.EntityMods.WireDupeInfo then
		Entity:ApplyDupeInfo( Player, Entity, Entity.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end )
	end
end




