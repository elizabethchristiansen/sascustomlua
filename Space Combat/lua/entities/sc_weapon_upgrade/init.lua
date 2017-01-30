AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function Make_sc_weapon_upgrade(pl, Pos, Ang, type)
	if ( !pl:CheckLimit( "sc_weapon_upgrade" ) ) then return nil end
		
	local Core = ents.Create("sc_weapon_upgrade")
		
	Core:SetPos(Pos)
	Core:SetAngles(Ang)
	Core:Spawn()
	Core:Activate()
	Core:Setup(type, pl)

	Core.Owner = pl

	pl:AddCount( "sc_weapon_upgrade", Core )
		
	return Core
end

function ENT:Setup( type, ply )
	
	self.type = type

	if type == "Tracking Enhancer I" then
    	self.BaseWeaponBonus = {   	
			OPT 	= 0.10,
			FALL	= 0.20,
			TS		= 0.07		
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	10.00,
			PG = 	1.00
		}
		self.NameLable = type
			
	elseif type == "Tracking Computer I" then
  		self.BaseWeaponBonus = {   	
			OPT 	= 0.05,
			FALL	= 0.10,
			TS		= 0.10
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	35.00,
			PG = 	1.00
		}
		self.NameLable = type		
		
	elseif type == "Heat Sink I" then
    	self.BaseWeaponBonus = {   	
			EDMG 	= 	0.07,
			EFR		= 	0.075	
		}
		self.SC_Fitting = {
			Slot 	= 	"LOW",
			CPU 	= 	30.00,
			PG 		= 	1.00
		}
		self.NameLable = type
		
	else
	
		self.BaseWeaponBonus = {   	
			OPT 	= 0,
			FALL	= 0,
			TS		= 0,
			EDMG 	= 0,
			EFR 	= 0
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	1.00,
			PG = 	1.00
		}
		self.NameLable = "Fail"

	end
	
	self.SC_Status = "Offline"	

end

duplicator.RegisterEntityClass("sc_weapon_upgrade", Make_sc_weapon_upgrade, "Pos", "Ang","type")

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
	local ent = ents.Create( "sc_weapon_upgrade" )
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
	
	if not self.BaseWeaponBonus.OPT then self.BaseWeaponBonus.OPT = 0 end 
	if not self.BaseWeaponBonus.FALL then self.BaseWeaponBonus.FALL = 0 end 
	if not self.BaseWeaponBonus.TS then self.BaseWeaponBonus.TS = 0 end 
	if not self.BaseWeaponBonus.EDMG then self.BaseWeaponBonus.EDMG = 0 end 
	if not self.BaseWeaponBonus.EFR then self.BaseWeaponBonus.EFR = 0 end 
	
	self.SC_WeaponBonus = {
		OPT 	= self.BaseWeaponBonus.OPT * 1.00,
		FALL	= self.BaseWeaponBonus.FALL * 1.00,
		TS		= self.BaseWeaponBonus.TS * 1.00,
		EDMG	= self.BaseWeaponBonus.EDMG * 1.00,
		EFR 	= self.BaseWeaponBonus.EFR * 1.00
	} 	
	
	local reslab = ""
	if self.SC_WeaponBonus.OPT > 0 then
		reslab = reslab.."Optimal Range Bonus: "..tostring(self.SC_WeaponBonus.OPT*100).."%".."\n"
	end
	if self.SC_WeaponBonus.FALL > 0 then
		reslab = reslab.."Falloff Bonus: "..tostring(self.SC_WeaponBonus.FALL*100).."%".."\n"
	end
	if self.SC_WeaponBonus.TS > 0 then
		reslab = reslab.."Tracking Speed Bonus: "..tostring(self.SC_WeaponBonus.TS*100).."%".."\n"
	end
	if self.SC_WeaponBonus.EFR > 0 then
		reslab = reslab.."Energy Turret Fire Rate Bonus: "..tostring(self.SC_WeaponBonus.EFR*100).."%".."\n"
	end
	if self.SC_WeaponBonus.EDMG > 0 then
		reslab = reslab.."Energy Turret Damage Bonus: "..tostring(self.SC_WeaponBonus.EDMG*100).."%".."\n"
	end
	
	self:SetOverlayText(self.NameLable.."\n"..
	reslab.."\n"..
	"-Fitting-".."\n"..
	"Slot: "..tostring(self.SC_Fitting.Slot).."\n"..
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