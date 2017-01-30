AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function Make_sc_armor_hardener(pl, Pos, Ang, type)
	if ( !pl:CheckLimit( "sc_armor_hardener" ) ) then return nil end
		
	local Core = ents.Create("sc_armor_hardener")
		
	Core:SetPos(Pos)
	Core:SetAngles(Ang)
	Core:Spawn()
	Core:Activate()
	Core:Setup(type, pl)

	Core.Owner = pl

	pl:AddCount( "sc_armor_hardener", Core )
		
	return Core
end

function ENT:Setup( type, ply )

	local plyaccess = ply:GetNWInt( "accesslevel" )	

	self.type = type
	
	if type == "Armor Hardener: EM" then
  		self.BaseArmorBonus = {
  			HP		= 0.00,
        	EM		= 50.00,
			EXP		= 0.00,
			KIN		= 0.00,
			THERM	= 0.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	33.00,
			PG = 	1.00
		}
		self.NameLable = type

	elseif type == "Armor Hardener: EXP" then
    	self.BaseArmorBonus = {
    		HP		= 0.00,
        	EM		= 0.00,
			EXP		= 50.00,
			KIN		= 0.00,
			THERM	= 0.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	33.00,
			PG = 	1.00
		}
		self.NameLable = type

	elseif type == "Armor Hardener: KIN" then
 		self.BaseArmorBonus = {
 			HP		= 0.00,
        	EM		= 0.00,
			EXP		= 0.00,
			KIN		= 50.00,
			THERM	= 0.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	33.00,
			PG = 	1.00
		}
		self.NameLable = type

	elseif type == "Armor Hardener: THERM" then
  		self.BaseArmorBonus = {
  			HP		= 0.00,
        	EM		= 0.00,
			EXP		= 0.00,
			KIN		= 0.00,
			THERM	= 50.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	33.00,
			PG = 	1.00
		}
		self.NameLable = type
		
	elseif type == "Energized Plating: EM" then
  		self.BaseArmorBonus = {
  			HP		= 0.00,
        	EM		= 32.50,
			EXP		= 0.00,
			KIN		= 0.00,
			THERM	= 0.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	25.00,
			PG = 	1.00
		}
		self.NameLable = type

	elseif type == "Energized Plating: EXP" then
    	self.BaseArmorBonus = {
    		HP		= 0.00,
        	EM		= 0.00,
			EXP		= 32.50,
			KIN		= 0.00,
			THERM	= 0.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	25.00,
			PG = 	1.00
		}
		self.NameLable = type

	elseif type == "Energized Plating: KIN" then
 		self.BaseArmorBonus = {
 			HP		= 0.00,
        	EM		= 0.00,
			EXP		= 0.00,
			KIN		= 32.50,
			THERM	= 0.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	25.00,
			PG = 	1.00
		}
		self.NameLable = type

	elseif type == "Energized Plating: THERM" then
  		self.BaseArmorBonus = {
  			HP		= 0.00,
        	EM		= 0.00,
			EXP		= 0.00,
			KIN		= 0.00,
			THERM	= 32.50
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	25.00,
			PG = 	1.00
		}
		self.NameLable = type
		
	elseif type == "Energized Plating: Adaptive" then
  		self.BaseArmorBonus = {
  			HP		= 0.00,
        	EM		= 15.00,
			EXP		= 15.00,
			KIN		= 15.00,
			THERM	= 15.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	30.00,
			PG = 	1.00
		}
		self.NameLable = type
		
	elseif type == "Energized Plating: Addition" then
  		self.BaseArmorBonus = {
  			HP		= 1.125,
        	EM		= 0.00,
			EXP		= 0.00,
			KIN		= 0.00,
			THERM	= 0.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	25.00,
			PG = 	1.00
		}
		self.NameLable = type
		
	elseif type == "Plating: EM" then
  		self.BaseArmorBonus = {
  			HP		= 0.00,
        	EM		= 20.00,
			EXP		= 0.00,
			KIN		= 0.00,
			THERM	= 0.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	0.00,
			PG = 	1.00
		}
		self.NameLable = type

	elseif type == "Plating: EXP" then
    	self.BaseArmorBonus = {
    		HP		= 0.00,
        	EM		= 0.00,
			EXP		= 20.00,
			KIN		= 0.00,
			THERM	= 0.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	0.00,
			PG = 	1.00
		}
		self.NameLable = type

	elseif type == "Plating: KIN" then
 		self.BaseArmorBonus = {
 			HP		= 0.00,
        	EM		= 0.00,
			EXP		= 0.00,
			KIN		= 20.00,
			THERM	= 0.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	0.00,
			PG = 	1.00
		}
		self.NameLable = type

	elseif type == "Plating: THERM" then
  		self.BaseArmorBonus = {
  			HP		= 0.00,
        	EM		= 0.00,
			EXP		= 0.00,
			KIN		= 0.00,
			THERM	= 20.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	0.00,
			PG = 	1.00
		}
		self.NameLable = type
		
	elseif type == "Plating: Adaptive" then
  		self.BaseArmorBonus = {
  			HP		= 0.00,
        	EM		= 8.00,
			EXP		= 8.00,
			KIN		= 8.00,
			THERM	= 8.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	0.00,
			PG = 	1.00
		}
		self.NameLable = type
		
	elseif type == "Plating: Addition" then
  		self.BaseArmorBonus = {
  			HP		= 1.06,
        	EM		= 0.00,
			EXP		= 0.00,
			KIN		= 0.00,
			THERM	= 0.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	0.00,
			PG = 	1.00
		}
		self.NameLable = type
		
	elseif type == "[Concord] Armor Enhancer" and plyaccess >= GetConVar( "access_ship_core_conc" ):GetInt() then
		self.BaseArmorBonus = {
			HP		= 1.20,
        	EM		= 45.00,
			EXP		= 45.00,
			KIN		= 45.00,
			THERM	= 45.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	52.00,
			PG = 	5.00
		}
		self.NameLable = "[Concord] Armor Enhancer"

	elseif type == "[Jove] Armor Enhancer" and plyaccess >= GetConVar( "access_ship_core_jove" ):GetInt() then
		self.BaseArmorBonus = {
			HP		= 1.50,
        	EM		= 75.00,
			EXP		= 75.00,
			KIN		= 75.00,
			THERM	= 75.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	50.00,
			PG = 	5.00
		}
		self.NameLable = "[Jove] Armor Enhancer"
		
		
	elseif type == "[Polaris] Armor Enhancer" and plyaccess >= GetConVar( "access_ship_core_polaris" ):GetInt() then
		self.BaseArmorBonus = {
			HP		= 2.00,
        	EM		= 85.00,
			EXP		= 85.00,
			KIN		= 85.00,
			THERM	= 85.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	50.00,
			PG = 	5.00
		}
		self.NameLable = "[Polaris] Armor Enhancer"

	else
		self.BaseArmorBonus = {
			HP		= 0.95,
        	EM		= 5.00,
			EXP		= 5.00,
			KIN		= 5.00,
			THERM	= 5.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	1.00,
			PG = 	1.00
		}
		self.NameLable = "FAIL"

	end
	
	self.SC_Status = "Offline"	

end

duplicator.RegisterEntityClass("sc_armor_hardener", Make_sc_armor_hardener, "Pos", "Ang","type")

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
	local ent = ents.Create( "sc_armor_hardener" )
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
	
	self.SC_ArmorBonus = {
		HP 		= self.BaseArmorBonus.HP * 1.00,
		EM		= self.BaseArmorBonus.EM * 1.00,
		EXP		= self.BaseArmorBonus.EXP * 1.00,
		KIN		= self.BaseArmorBonus.KIN * 1.00,
		THERM	= self.BaseArmorBonus.THERM * 1.00
	} 	
	
	local reslab = ""
	if self.SC_ArmorBonus.EM > 0 then
		reslab = reslab.."EM: "..tostring(self.SC_ArmorBonus.EM).."%".."\n"
	end
	if self.SC_ArmorBonus.EXP > 0 then
		reslab = reslab.."EXP: "..tostring(self.SC_ArmorBonus.EXP).."%".."\n"
	end
	if self.SC_ArmorBonus.KIN > 0 then
		reslab = reslab.."KIN: "..tostring(self.SC_ArmorBonus.KIN).."%".."\n"
	end
	if self.SC_ArmorBonus.THERM > 0 then
		reslab = reslab.."THERM: "..tostring(self.SC_ArmorBonus.THERM).."%".."\n"
	end
	if self.SC_ArmorBonus.HP > 0 then
		reslab = reslab.."HP: "..tostring(self.SC_ArmorBonus.HP*100-100).."%".."\n"
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




