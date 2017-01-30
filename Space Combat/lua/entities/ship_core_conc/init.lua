AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.ConWeldTable = {}

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self.ReCalcTime		= 3

	self.Hull = {
		Max = 400,
		HP = 400,
		Percent = 1,
		Ratio = 1.15*1.8
	}
	self.HullRes = {
		EM		= self.BaseHullRes.EM,
		EXP		= self.BaseHullRes.EXP,
		KIN		= self.BaseHullRes.KIN,
		THERM	= self.BaseHullRes.THERM
	}

	self.Armor = {
		Max = 600,
		HP = 600,
		Percent = 1,
		Ratio = 1.40*1.12
	}
	self.ArmorRes = {
  		EM		= self.BaseArmorRes.EM,
		EXP		= self.BaseArmorRes.EXP,
		KIN		= self.BaseArmorRes.KIN,
		THERM	= self.BaseArmorRes.THERM
	}

	self.Shield = {
		Max = 650,
		HP = 650,
		Percent = 1,
		Ratio = 1.65*1.15,
		RechargeTime = 100
	}
	self.ShieldRes = {
  		EM		= self.BaseShieldRes.EM,
		EXP		= self.BaseShieldRes.EXP,
		KIN		= self.BaseShieldRes.KIN,
		THERM	= self.BaseShieldRes.THERM
	}
	
	self.Slots = {
		HIGH	= 2,
		HIGH_R	= 2.00, --Ratio
		HIGH_M	= 8, 	--Max
		HIGH_U	= 0,	--Used
		MED 	= 2,
		MED_R	= 1.50,
		MED_M	= 8,
		MED_U	= 0,
		LOW  	= 2,
		LOW_R	= 0.50,
		LOW_M	= 5,
		LOW_U	= 0,
		TUR     = 2,
		TUR_R	= 1.00,
		TUR_M	= 2,
		TUR_U	= 0,
		ML		= 2,
		ML_R	= 1.00,
		ML_M	= 8,
		ML_U	= 0
	}

	self.Fitting = {
		CPU		= 50,
		CPU_R	= 1.25,
		CPU_U	= 0,
		PG		= 50,
		PG_R	= 0.75,
		PG_U	= 0
	}
								
end

function ENT:SpawnFunction( ply, tr )
if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 50
	local ent = ents.Create( "ship_core_conc" )
		ent:SetPos( SpawnPos )
		ent:Spawn()
		ent:Activate()
	return ent
end

function ENT:PostEntityPaste( owner )
	
	local ent = self
	local class = ent:GetClass()
	local plyaccess = owner:GetNWInt( "accesslevel" )	
	
	if class == "ship_core_conc" then
		if plyaccess < GetConVar( "access_ship_core_conc" ):GetInt() then
			owner:PrintMessage( HUD_PRINTTALK, "This core is blocked for your access level." )
			ent:Remove()
		end
	end
end	

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)	
end 

function ENT:Use(ply,call)
	umsg.Start("Ship_Core_UMSG", ply)
	umsg.Entity(self.Entity)
	umsg.End()
end

function ENT:CalcHealth()
	self.BaseClass.CalcHealth(self)
end


function ENT:Think()
	self.BaseClass.Think(self)
	self.BaseClass.BaseClass.Think(self)
end


function ENT:Displays() 
self.BaseClass.Displays(self)	
end



