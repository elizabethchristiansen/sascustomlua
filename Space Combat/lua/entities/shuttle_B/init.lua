AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

local DESTROYABLE=true -- set to false to prevent damage
local HEALTH=500 -- change to set spawn health of shuttles

local soundx=Sound("ambient/atmosphere/undercity_loop1.wav")

function ENT:SpawnFunction( ply, tr)
	local SpawnPos = tr.HitPos + tr.HitNormal * 100
	local ent = ents.Create( "shuttle" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self.Entity:SetNetworkedInt("health",HEALTH)

	if (!self.Sound) then
 		self.Sound = CreateSound( self.Entity, soundx )
 	end

	self.Entity:SetUseType( SIMPLE_USE )

	self.Firee=nil
	self.Inflight=false
	self.Pilot=nil
	--self.Entity:SetModel("models/props_combine/headcrabcannister01a.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
		local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then
			--phys:Wake()
			phys:SetMass(10000)
		end
	self.Entity:StartMotionController()
	self.Accel=0
end

function ENT:DoKill()
	--util.BlastDamage( self.Entity, self.Entity, self.Entity:GetPos(), 300, 100 )  ARRRR

 	local effectdata = EffectData() 
 		effectdata:SetOrigin( self.Entity:GetPos() ) 
  	util.Effect( "Explosion", effectdata, true, true ) 

	self.Sound:Stop()
	
	self.Pilot:UnSpectate()
	self.Pilot:DrawViewModel(true)
	self.Pilot:DrawWorldModel(true)
	self.Pilot:Spawn()
	self.Pilot:SetNetworkedBool("isDriveShuttle",false)
	self.Pilot:SetPos(self.Entity:GetPos()+Vector(0,0,100))
	self.Entity:Remove()
end

function ENT:OnTakeDamage(dmg)
	/*
	if self.Inflight and DESTROYABLE and not self.Done then
		local health=self.Entity:GetNetworkedInt("health")
		self.Entity:SetNetworkedInt("health",health-dmg:GetDamage())
		local health=self.Entity:GetNetworkedInt("health")
		if health<1 then
			self.Entity:DoKill()
			self.Done=true
		end
	end
	*/
end

function ENT:OnRemove()
	if self.Pilot then
		self.Pilot:UnSpectate()
		self.Pilot:DrawViewModel(true)
		self.Pilot:DrawWorldModel(true)
		self.Pilot:Spawn()
		self.Pilot:SetNetworkedBool("isDriveShuttle",false)
		self.Pilot:SetPos(self.Entity:GetPos()+Vector(0,0,100))
	end
 	if (self.Sound) then
 		self.Sound:Stop()
 	end
end

function ENT:Think()
	if self.Inflight and self.Pilot and self.Pilot:IsValid() then
		if self.Sound then
			self.Sound:ChangePitch(math.Clamp(self.Entity:GetVelocity():Length()/5,1,150),0.001)
		end
		self.Pilot:SetPos(self.Entity:GetPos())
		if self.Pilot:KeyDown(IN_USE) then
			self.Sound:Stop()

			self.Pilot:UnSpectate()
			self.Pilot:DrawViewModel(true)
			self.Pilot:DrawWorldModel(true)
			self.Pilot:Spawn()
			self.Pilot:SetNetworkedBool("isDriveShuttle",false)
			self.Pilot:SetPos(self.Entity:GetPos()+Vector(0,0,100))

			self.Accel=0
			self.Inflight=false
			if self.Firee then
				self.Firee:Remove()
			end
			self.Entity:SetLocalVelocity(Vector(0,0,0))
			self.Pilot=nil
		end	
		self.Entity:NextThink(CurTime())
	else
		self.Entity:NextThink(CurTime()+1)
	end

return true
end

function ENT:Use(ply,caller)
	if self.Inflight then 

	else
		self.Sound:Play()

		self.Entity:GetPhysicsObject():Wake()
		self.Entity:GetPhysicsObject():EnableMotion(true)
		self.Inflight=true
		self.Pilot=ply

		ply:Spectate( OBS_MODE_CHASE  )
		ply:SpectateEntity( self.Entity )
		ply:DrawViewModel(false)
		ply:DrawWorldModel(false)
		ply:StripWeapons()
		ply:SetNetworkedBool("isDriveShuttle",true)
		ply:SetNetworkedEntity("Shuttle",self.Entity)
	end
end

function ENT:PhysicsSimulate( phys, deltatime )
	if self.Inflight then
		local num=0
		if self.Pilot:KeyDown(IN_ATTACK) then
			num=650
		elseif self.Pilot:KeyDown(IN_ATTACK2) then
			num=-500
		elseif self.Pilot:KeyDown(IN_FORWARD) then
			num=1250
		else
			
		end
		phys:Wake()
			self.Accel=math.Approach(self.Accel,num,10)
			if self.Accel>-200 and self.Accel < 200 then return end
		local pr={}
			pr.secondstoarrive	= 1
			pr.pos				= self.Entity:GetPos()+self.Entity:GetForward()*self.Accel
			pr.maxangular		= 5000
			pr.maxangulardamp	= 10000
			pr.maxspeed			= 1000000
			pr.maxspeeddamp		= 10000
			pr.dampfactor		= 0.8
			pr.teleportdistance	= 5000
			pr.angle		= self.Pilot:GetAimVector():Angle()
			if self.Pilot:KeyDown(IN_SPEED) then
				pr.angle=self.Entity:GetAngles()
			end
			pr.deltatime		= deltatime
		phys:ComputeShadowControl(pr)
	end
end
