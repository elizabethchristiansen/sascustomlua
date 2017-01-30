AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function Make_sc_shield_hardener(pl, Pos, Ang, type)
	if ( !pl:CheckLimit( "sc_shield_hardener" ) ) then return nil end
		
	local Core = ents.Create("sc_shield_hardener")
		
	Core:SetPos(Pos)
	Core:SetAngles(Ang)
	Core:Spawn()
	Core:Activate()
	Core:Setup(type, pl)

	Core.Owner = pl

	pl:AddCount( "sc_shield_hardener", Core )
		
	return Core
end

function ENT:Setup( type, ply )

	local plyaccess = ply:GetNWInt( "accesslevel" )	

	self.type = type
	
	if type == "Shield Hardener: EM" then
  		self.BaseShieldBonus = {
  			HP		= 0.00,
        	EM		= 50.00,
			EXP		= 0.00,
			KIN		= 0.00,
			THERM	= 0.00
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	40.00,
			PG = 	1.00
		}
		self.NameLable = type

	elseif type == "Shield Hardener: EXP" then
    	self.BaseShieldBonus = {
    		HP		= 0.00,
        	EM		= 0.00,
			EXP		= 50.00,
			KIN		= 0.00,
			THERM	= 0.00
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	40.00,
			PG = 	1.00
		}
		self.NameLable = type

	elseif type == "Shield Hardener: KIN" then
 		self.BaseShieldBonus = {
 			HP		= 0.00,
        	EM		= 0.00,
			EXP		= 0.00,
			KIN		= 50.00,
			THERM	= 0.00
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	40.00,
			PG = 	1.00
		}
		self.NameLable = type

	elseif type == "Shield Hardener: THERM" then
  		self.BaseShieldBonus = {
  			HP		= 0.00,
        	EM		= 0.00,
			EXP		= 0.00,
			KIN		= 0.00,
			THERM	= 50.00
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	40.00,
			PG = 	1.00
		}
		self.NameLable = type
		
	elseif type == "Shield Hardener: MULTI" then
  		self.BaseShieldBonus = {
  			HP		= 0.00,
        	EM		= 25.00,
			EXP		= 25.00,
			KIN		= 25.00,
			THERM	= 25.00
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	40.00,
			PG = 	1.00
		}
		self.NameLable = type
		
	elseif type == "Amplifier: EM" then
  		self.BaseShieldBonus = {
  			HP		= 0.00,
        	EM		= 32.50,
			EXP		= 0.00,
			KIN		= 0.00,
			THERM	= 0.00
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	25.00,
			PG = 	1.00
		}
		self.NameLable = type

	elseif type == "Amplifier: EXP" then
    	self.BaseShieldBonus = {
    		HP		= 0.00,
        	EM		= 0.00,
			EXP		= 32.50,
			KIN		= 0.00,
			THERM	= 0.00
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	25.00,
			PG = 	1.00
		}
		self.NameLable = type

	elseif type == "Amplifier: KIN" then
 		self.BaseShieldBonus = {
 			HP		= 0.00,
        	EM		= 0.00,
			EXP		= 0.00,
			KIN		= 32.50,
			THERM	= 0.00
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	25.00,
			PG = 	1.00
		}
		self.NameLable = type

	elseif type == "Amplifier: THERM" then
  		self.BaseShieldBonus = {
  			HP		= 0.00,
        	EM		= 0.00,
			EXP		= 0.00,
			KIN		= 0.00,
			THERM	= 32.50
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	25.00,
			PG = 	1.00
		}
		self.NameLable = type
		
	elseif type == "Amplifier: HP" then
  		self.BaseShieldBonus = {
  			HP		= 1.10,
        	EM		= 0.00,
			EXP		= 0.00,
			KIN		= 0.00,
			THERM	= 0.00
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	22.00,
			PG = 	1.00
		}
		self.NameLable = type
		
	elseif type == "Basic Amplifier: EM" then
  		self.BaseShieldBonus = {
  			HP		= 0.00,
        	EM		= 25.00,
			EXP		= 0.00,
			KIN		= 0.00,
			THERM	= 0.00
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	10.00,
			PG = 	0.00
		}
		self.NameLable = type

	elseif type == "Basic Amplifier: EXP" then
    	self.BaseShieldBonus = {
    		HP		= 0.00,
        	EM		= 0.00,
			EXP		= 25.00,
			KIN		= 0.00,
			THERM	= 0.00
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	10.00,
			PG = 	0.00
		}
		self.NameLable = type

	elseif type == "Basic Amplifier: KIN" then
 		self.BaseShieldBonus = {
 			HP		= 0.00,
        	EM		= 0.00,
			EXP		= 0.00,
			KIN		= 25.00,
			THERM	= 0.00
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	10.00,
			PG = 	0.00
		}
		self.NameLable = type

	elseif type == "Basic Amplifier: THERM" then
  		self.BaseShieldBonus = {
  			HP		= 0.00,
        	EM		= 0.00,
			EXP		= 0.00,
			KIN		= 0.00,
			THERM	= 25.00
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	10.00,
			PG = 	0.00
		}
		self.NameLable = type
		
	elseif type == "Basic Amplifier: HP" then
  		self.BaseShieldBonus = {
  			HP		= 1.05,
        	EM		= 0.00,
			EXP		= 0.00,
			KIN		= 0.00,
			THERM	= 0.00
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	8.00,
			PG = 	0.00
		}
		self.NameLable = type
		
	elseif type == "[Concord] Shield Enhancer" and plyaccess >= GetConVar( "access_ship_core_conc" ):GetInt() then
		self.BaseShieldBonus = {
			HP		= 1.20,
			RE		= 0.825,
        	EM		= 42.50,
			EXP		= 42.50,
			KIN		= 42.50,
			THERM	= 42.50
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	65.00,
			PG = 	5.00
		}
		self.NameLable = "[Concord] Shield Enhancer"

	elseif type == "[Jove] Shield Enhancer" and plyaccess >= GetConVar( "access_ship_core_jove" ):GetInt() then
		self.BaseShieldBonus = {
			HP		= 1.50,
			RE		= 0.75,
        	EM		= 72.50,
			EXP		= 72.50,
			KIN		= 72.50,
			THERM	= 72.50
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	60.00,
			PG = 	5.00
		}
		self.NameLable = "[Jove] Shield Enhancer"
		
		
	elseif type == "[Polaris] Shield Enhancer" and plyaccess >= GetConVar( "access_ship_core_polaris" ):GetInt() then
		self.BaseShieldBonus = {
			HP		= 2.00,
			RE		= 0.25,
        	EM		= 85.00,
			EXP		= 85.00,
			KIN		= 85.00,
			THERM	= 85.00
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	58.00,
			PG = 	5.00
		}
		self.NameLable = "[Polaris] Shield Enhancer"
		
	else
		self.BaseShieldBonus = {
			HP		= 0.95,
        	EM		= 5.00,
			EXP		= 5.00,
			KIN		= 5.00,
			THERM	= 5.00
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	1.00,
			PG = 	1.00
		}
		self.NameLable = "FAIL"

	end
	
	self.SC_Status = "Offline"	

end

duplicator.RegisterEntityClass("sc_shield_hardener", Make_sc_shield_hardener, "Pos", "Ang","type")

function ENT:Initialize()
	self.Entity:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS ) 	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS ) 
	self.Entity:SetUseType(SIMPLE_USE)  
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:EnableMotion(true)
	end 
		
	self.SC_Status = "Offline"
	self.SC_Immune2 = true
			 						
end

function ENT:SpawnFunction( ply, tr )
if ( !tr.Hit ) then return end    	
	local SpawnPos = tr.HitPos + tr.HitNormal * 100 	
	local ent = ents.Create( "sc_shield_hardener" )
		ent:SetPos( SpawnPos )
		ent:Spawn()
		ent:Activate() 
		ent:Setup()
	return ent
end

function ENT:OnRemove()
	
end
 
function ENT:Use()
	print(tostring(self.testv1))
end 

function ENT:Think()
	self.BaseClass.Think(self)
	
	if not self.SC_CoreEnt then self.SC_Status = "Offline" end 	

	if not self.BaseShieldBonus.HPA then self.BaseShieldBonus.HPA = 0 end
	if not self.BaseShieldBonus.RE then self.BaseShieldBonus.RE = 0 end   
	
	self.SC_ShieldBonus = {
		HP 		= self.BaseShieldBonus.HP * 1.00,
		HPA 	= self.BaseShieldBonus.HPA * 1.00,
		RE		= self.BaseShieldBonus.RE * 1.00,
		EM		= self.BaseShieldBonus.EM * 1.00,
		EXP		= self.BaseShieldBonus.EXP * 1.00,
		KIN		= self.BaseShieldBonus.KIN * 1.00,
		THERM	= self.BaseShieldBonus.THERM * 1.00
	} 	
	
	local reslab = ""
	if self.SC_ShieldBonus.EM > 0 then
		reslab = reslab.."EM: "..tostring(self.SC_ShieldBonus.EM).."%".."\n"
	end
	if self.SC_ShieldBonus.EXP > 0 then
		reslab = reslab.."EXP: "..tostring(self.SC_ShieldBonus.EXP).."%".."\n"
	end
	if self.SC_ShieldBonus.KIN > 0 then
		reslab = reslab.."KIN: "..tostring(self.SC_ShieldBonus.KIN).."%".."\n"
	end
	if self.SC_ShieldBonus.THERM > 0 then
		reslab = reslab.."THERM: "..tostring(self.SC_ShieldBonus.THERM).."%".."\n"
	end
	if self.SC_ShieldBonus.HP > 0 then
		reslab = reslab.."HP: "..tostring(self.SC_ShieldBonus.HP*100-100).."%".."\n"
	end
	if self.SC_ShieldBonus.HPA and self.SC_ShieldBonus.HPA > 0 then
		reslab = reslab.."HP Amount: "..tostring(self.SC_ShieldBonus.HPA).."\n"
	end
	if self.SC_ShieldBonus.RE and self.SC_ShieldBonus.RE > 0 then
		reslab = reslab.."Recharge: "..tostring(self.SC_ShieldBonus.RE*100-100).."%".."\n"
	end
	
	
	self:SetOverlayText(self.NameLable.."\n"..
	reslab.."\n"..
	"-Fitting-".."\n"..
	"CPU: "..tostring(self.SC_Fitting.CPU).."\n"..
	"PG: "..tostring(self.SC_Fitting.PG).."\n"..
	"Status: "..self.SC_Status	
	)
	
	
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




