AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

--ENT.ConWeldTable = {}

function ENT:Initialize()
	--self.Entity:SetModel( "models/props_c17/substation_transformer01b.mdl" )
	--self.Entity:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
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
	
	self.timer = CurTime()
	self.OneSecond = CurTime() + 1
	--timer.Create( "onesectime", 1, 0, self:OneSecond_Think )
	
	self.Outputs = Wire_CreateOutputs( self.Entity, { 
	"Shield", 
	"Armor", 
	"Hull",
	"Capacitor", 
	"Max Shield", 
	"Max Armor", 
	"Max Hull",
	"Max Capacitor",
	"% Shield",
	"% Armor",
	"% Hull",
	"% Capacitor"
	} ) 	

	self.Hull = {
		Max = 250,
		HP = 250,
		Percent = 1,
		Ratio = 1.00
	}
	self.HullRes = {
		EM		= self.BaseHullRes.EM,
		EXP		= self.BaseHullRes.EXP,
		KIN		= self.BaseHullRes.KIN,
		THERM	= self.BaseHullRes.THERM
	}

	self.Armor = {
		Max = 250,
		HP = 250,
		Percent = 1,
		Ratio = 1.00
	}
	self.ArmorRes = {
  		EM		= self.BaseArmorRes.EM,
		EXP		= self.BaseArmorRes.EXP,
		KIN		= self.BaseArmorRes.KIN,
		THERM	= self.BaseArmorRes.THERM
	}

	self.Shield = {
		Max = 250,
		HP = 250,
		Percent = 1,
		Ratio = 1.00,
		RechargeTime = 100
	}
	self.ShieldRes = {
  		EM		= self.BaseShieldRes.EM,
		EXP		= self.BaseShieldRes.EXP,
		KIN		= self.BaseShieldRes.KIN,
		THERM	= self.BaseShieldRes.THERM
	}
	
	self.Cap = {
		Max = 250,
		CAP = 250,
		Percent = 1,
		Ratio = 1.00,
		RechargeTime = 100
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
		LOW_R	= 1.00,
		LOW_M	= 8,
		LOW_U	= 0,
		TUR     = 2,
		TUR_R	= 1.00,
		TUR_M	= 8,
		TUR_U	= 0,
		ML		= 2,
		ML_R	= 1.00,
		ML_M	= 8,
		ML_U	= 0
	}

	self.Fitting = {
		CPU		= 50,
		CPU_R	= 1.00,
		CPU_U	= 0,
		PG		= 50,
		PG_R	= 1.00,
		PG_U	= 0
	}
	
	self.WeaponStats = {
		Optimal 		= 1,
		Falloff 		= 1,
		TrackingSpeed 	= 1,
		EnergyFireRate 	= 1,
		EnergyDamage 	= 1
	}
	
	 self.sigrad = 1
	 self.total_mass = 1
	 
	 self.fittingtable = {}
end


function ENT:SpawnFunction( ply, tr )
if ( !tr.Hit ) then return end    	
	local SpawnPos = tr.HitPos + tr.HitNormal * 50
	local ent = ents.Create( "ship_core_base" )
		ent:SetPos( SpawnPos )
		ent:Spawn()
		ent:Activate() 
	return ent
end


function ENT:OnRemove()

	local mul = math.Clamp(self.Hull.Percent,0.01,1)

	for _,i in pairs(self.ConWeldTable) do
		if i:IsValid() and i.SC_Health and i.SC_MaxHealth then --Don't want errors if the ents been removed or messed up
			i.SC_CoreEnt = nil
			i.SC_Health = math.Clamp(i.SC_MaxHealth * mul, SC_MinHealth(), SC_MaxHealth())
		end
	end 
	
	Wire_Remove(self.Entity)
	
end 

--Experimental stuff in here
function ENT:Use(ply,call)
	
	--Msg("\n==============================\n")
	--PrintTable( self.ConWeldTable )
	--Msg("==============================\n\n")

	Msg("Player: "..tostring(ply).."\tCaller: "..tostring(call).."\n")
	print("Player: "..tostring(ply).."\tCaller: "..tostring(call).."\n")
	
	umsg.Start("Ship_Core_UMSG", ply)
	umsg.Entity(self.Entity)
	umsg.End()     	

end

function ENT:CalcHealth()

    local start = SysTime()
    --print(start.."\n")

	if self.ConWeldTable then
		for _,i in pairs(self.ConWeldTable) do
			if i:IsValid() then --Don't want errors if the ents been removed
				i.SC_CoreEnt = nil --Clear out all the old tables ents in case they've been unwelded
			end
		end
	end

	self.ConWeldTable = constraint.GetAllWeldedEntities( self ) --New table of constrained ents
	
	for _,i in pairs(self.ConWeldTable) do
		if i.SC_CoreEnt and i.SC_CoreEnt != self.Entity and not string.find(i:GetClass(), "ship_core") then --No more then 1 core per ship
		    Msg("Already a core welded to those props\n")
		    Msg("\n==============================\n")
			PrintTable( self.ConWeldTable )
			Msg("==============================\n\n")
		    constraint.RemoveAll( self )
		    self.ConWeldTable = {} --Clear the table I guess since odd things were happeneing once in awhile.
			return false
		end
	end
	
	local Hull = 5
	--local HullHP = 500
	local Volume2 = 0
	
	local SC_HP = 1
	
	local mintable_X = {}
	local mintable_Y = {}
	local mintable_Z = {}
	
	local maxtable_X = {}
	local maxtable_Y = {}
	local maxtable_Z = {}
	
	self.fittingtable = {}
	
	local total_mass	= 1
	
	for _,i in pairs(self.ConWeldTable) do
		if not string.find(i:GetClass(),"wire") then --No more Wire chips giving 10hp >_<
			if not i.SC_Fitting then
		
		    	local min = i:OBBMins() + i:GetPos()
		    	local max = i:OBBMaxs() + i:GetPos()
		    
		    	table.insert(mintable_X, min.x)
		    	table.insert(mintable_Y, min.y)
		    	table.insert(mintable_Z, min.z)
		    
		    	table.insert(maxtable_X, max.x)
		    	table.insert(maxtable_Y, max.y)
		    	table.insert(maxtable_Z, max.z)
			
				total_mass = total_mass + i:GetPhysicsObject():GetMass()
				
				local volume = GetVolume(i)
				local multiplier = 0.75
				--local healthmax = math.Round((((volume)^(0.515))*multiplier)/10)*10
				local healthmax = math.Round((((volume)^(1.000))*multiplier)/10/17500)*10
				--Entity:BoundingRadius()
				Hull = Hull + healthmax
				Volume2 = Volume2 + volume
			else
                table.insert(self.fittingtable, i) --Save these ents for later once fitting is calced
			end
		end
		
		i.SC_CoreEnt = self.Entity --So when an Ent takes damage, pass it to this ent
		
	end
	
	self.total_mass = total_mass
	
	table.sort(mintable_X)
	table.sort(mintable_Y)
	table.sort(mintable_Z)
	
	table.sortdesc(maxtable_X)
	table.sortdesc(maxtable_Y)
	table.sortdesc(maxtable_Z)
	--print("Min: "..tostring(Vector(mintable_X[1],mintable_Y[1],mintable_Z[1])).." Max: " ..tostring(Vector(maxtable_X[1],maxtable_Y[1],maxtable_Z[1])))
	--PrintTable(mintable_X) 	
	
	local tempsigrad = Vector(maxtable_X[1],maxtable_Y[1],maxtable_Z[1]) - Vector(mintable_X[1],mintable_Y[1],mintable_Z[1]) 
	self.sigrad = tempsigrad:Length()
	--print("Sig Rad: " ..self.sigrad)
	
	--if Hull < 150 then Hull = 150 end 
	  	
	self.Hull.Max = math.Round((Hull * self.Hull.Ratio)/10)*10
	if self.Hull.Max < 25 then self.Hull.Max = 50 end
	self.Hull.HP = self.Hull.Max * self.Hull.Percent
	
	self.Armor.Max = math.Round((Hull * self.Armor.Ratio)/10)*10
	if self.Armor.Max < 200 then self.Armor.Max = 200 end
	self.Armor.HP = self.Armor.Max * self.Armor.Percent
	
	self.Shield.Max = math.Round((Hull * self.Shield.Ratio)/10)*10
	if self.Shield.Max < 250 then self.Shield.Max = 250 end
	self.Shield.HP = self.Shield.Max * self.Shield.Percent
	
	--self.Shield.RechargeTime = math.floor((20 + ((Hull/10)^0.95))/1)
	self.Shield.RechargeTime = math.floor((20 + ((Hull/4.775)^0.85))/1) --3--2--1 times faster till proper mods put in
	
	self.Cap.Max = math.Round((((Hull/20.00) * self.Cap.Ratio)^1.175)/1)*1
	if self.Cap.Max < 175 then self.Cap.Max = 175 end
	self.Cap.CAP = self.Cap.Max * self.Cap.Percent
	
	--self.Cap.RechargeTime = math.floor((100 + ((Hull/2.25)^0.7125))/1) --3--2--1 times faster till proper mods put in
	
	self.Cap.RechargeTime = math.floor((100 + ((Hull/2.6)^0.7125))/1.25) 

	--self.Slots.HIGH = math.Clamp(math.floor(2+((((Hull^0.75)*10)/5000)*self.Slots.HIGH_R)) , 2, self.Slots.HIGH_M)
	--self.Slots.MED = math.Clamp(math.floor(2+((((Hull^0.75)*10)/5000)*self.Slots.MED_R)) , 2, self.Slots.MED_M)
	--self.Slots.LOW = math.Clamp(math.floor(2+((((Hull^0.75)*10)/5000)*self.Slots.LOW_R)) , 2, self.Slots.LOW_M)
	
	--self.Slots.HIGH = math.Clamp(math.floor(2+((((Hull^0.7)*15)/5000)*self.Slots.HIGH_R)) , 2, self.Slots.HIGH_M)
	--self.Slots.MED = math.Clamp(math.floor(2+((((Hull^0.7)*15)/5000)*self.Slots.MED_R)) , 2, self.Slots.MED_M)
	--self.Slots.LOW = math.Clamp(math.floor(2+((((Hull^0.7)*15)/5000)*self.Slots.LOW_R)) , 2, self.Slots.LOW_M)
	
	--self.Slots.HIGH = math.Clamp(math.floor(2+((((Hull^0.4)*250)/5000)*self.Slots.HIGH_R)) , 2, self.Slots.HIGH_M)
	--self.Slots.MED = math.Clamp(math.floor(2+((((Hull^0.4)*250)/5000)*self.Slots.MED_R)) , 2, self.Slots.MED_M)
	--self.Slots.LOW = math.Clamp(math.floor(2+((((Hull^0.4)*250)/5000)*self.Slots.LOW_R)) , 2, self.Slots.LOW_M)
	
	--self.Slots.HIGH = math.Clamp(math.floor(2+((((Hull^0.35)*400)/5500)*self.Slots.HIGH_R)) , 2, self.Slots.HIGH_M)
	--self.Slots.MED = math.Clamp(math.floor(2+((((Hull^0.35)*400)/5500)*self.Slots.MED_R)) , 2, self.Slots.MED_M)
	--self.Slots.LOW = math.Clamp(math.floor(2+((((Hull^0.35)*400)/5500)*self.Slots.LOW_R)) , 2, self.Slots.LOW_M)
	
	self.Slots.HIGH = math.Clamp(math.floor(2+((((Hull^0.5)*100)/5500)*self.Slots.HIGH_R)) , 2, self.Slots.HIGH_M)
	self.Slots.MED = math.Clamp(math.floor(2+((((Hull^0.5)*100)/5500)*self.Slots.MED_R)) , 2, self.Slots.MED_M)
	self.Slots.LOW = math.Clamp(math.floor(2+((((Hull^0.5)*100)/5500)*self.Slots.LOW_R)) , 2, self.Slots.LOW_M)
	
	self.Fitting.CPU = math.floor(100+(((Hull/37.5)^0.815)*self.Fitting.CPU_R))
	--self.Fitting.PG = math.floor(25+(((((Hull^1.50)/100)/750)^1.7)*self.Fitting.PG_R))
	self.Fitting.PG = math.floor(25+(((((Hull^1.50)/50)/750)^1.6275)*self.Fitting.PG_R))
	
	
	self.Slots.HIGH_U = 0
	self.Slots.MED_U = 0
	self.Slots.LOW_U = 0

	self.Fitting.CPU_U = 0
	self.Fitting.PG_U = 0
	
	local ArmorBonus_HP = {}
	local ArmorBonus_HPA = {}
	local ArmorBonus_EM = {}
	local ArmorBonus_EXP = {}
	local ArmorBonus_KIN = {}
	local ArmorBonus_THERM = {}
	
	local ShieldBonus_HP = {}
	local ShieldBonus_HPA = {}
	local ShieldBonus_RE = {}
	local ShieldBonus_EM = {}
	local ShieldBonus_EXP = {}
	local ShieldBonus_KIN = {}
	local ShieldBonus_THERM = {}
	
	local EnergyBonus_CRE = {}
	local EnergyBonus_CAP = {}
	local EnergyBonus_CAPP = {} 
	local EnergyBonus_PG = {}
	local EnergyBonus_CPU = {}	
	
	local WeaponBonus_OPT = {}
	local WeaponBonus_FALL = {}
	local WeaponBonus_TS = {}
	local WeaponBonus_EFR = {}
	local WeaponBonus_EDMG = {}
	
	for _,i in pairs(self.fittingtable) do
	
	    if i.SC_Fitting.Slot == "HIGH" then
	        if self.Slots.HIGH_U < self.Slots.HIGH then
	            if (self.Fitting.CPU_U + i.SC_Fitting.CPU) <= self.Fitting.CPU then
	                if (self.Fitting.PG_U + i.SC_Fitting.PG) <= self.Fitting.PG then

						self.Slots.HIGH_U = self.Slots.HIGH_U + 1
						self.Fitting.CPU_U = self.Fitting.CPU_U + i.SC_Fitting.CPU
						self.Fitting.PG_U = self.Fitting.PG_U + i.SC_Fitting.PG
												
						if i.SC_ShieldBonus then
							if i.SC_ShieldBonus.HP and i.SC_ShieldBonus.HP > 0 then
								table.insert(ShieldBonus_HP, i.SC_ShieldBonus.HP)
							end 
							if i.SC_ShieldBonus.HPA and i.SC_ShieldBonus.HPA > 0 then 
								table.insert(ShieldBonus_HPA, i.SC_ShieldBonus.HPA)
							end 
							if i.SC_ShieldBonus.RE and i.SC_ShieldBonus.RE > 0 then 
								table.insert(ShieldBonus_RE, i.SC_ShieldBonus.RE)
							end 
							if i.SC_ShieldBonus.EM and i.SC_ShieldBonus.EM > 0 then
								table.insert(ShieldBonus_EM, i.SC_ShieldBonus.EM)
							end 
							if i.SC_ShieldBonus.EXP and i.SC_ShieldBonus.EXP > 0 then
								table.insert(ShieldBonus_EXP, i.SC_ShieldBonus.EXP)
							end 
							if i.SC_ShieldBonus.KIN and i.SC_ShieldBonus.KIN > 0 then
								table.insert(ShieldBonus_KIN, i.SC_ShieldBonus.KIN)
							end 
							if i.SC_ShieldBonus.THERM and i.SC_ShieldBonus.THERM > 0 then
								table.insert(ShieldBonus_THERM, i.SC_ShieldBonus.THERM)
							end 
						end
						if i.SC_EnergyBonus then
							if i.SC_EnergyBonus.CRE  and i.SC_EnergyBonus.CRE > 0 then
								table.insert(EnergyBonus_CRE, i.SC_EnergyBonus.CRE)	
							end 
							if i.SC_EnergyBonus.CAP  and i.SC_EnergyBonus.CAP > 0 then
								table.insert(EnergyBonus_CAP, i.SC_EnergyBonus.CAP)	
							end 
							if i.SC_EnergyBonus.CAPP  and i.SC_EnergyBonus.CAPP > 0 then
								table.insert(EnergyBonus_CAPP, i.SC_EnergyBonus.CAPP)	
							end 
							if i.SC_EnergyBonus.SRE  and i.SC_EnergyBonus.SRE > 0 then
								table.insert(ShieldBonus_RE, i.SC_EnergyBonus.SRE)	
							end 
							if i.SC_EnergyBonus.SHLD  and i.SC_EnergyBonus.SHLD > 0 then
								table.insert(ShieldBonus_HP, i.SC_EnergyBonus.SHLD)	
							end 
							if i.SC_EnergyBonus.PG  and i.SC_EnergyBonus.PG > 0 then
								table.insert(EnergyBonus_PG, i.SC_EnergyBonus.PG)	
							end 
							if i.SC_EnergyBonus.CPU  and i.SC_EnergyBonus.CPU  > 0 then
								table.insert(EnergyBonus_CPU, i.SC_EnergyBonus.CPU)	
							end 						
						end 						
						
						i.SC_Status = "Online"
				
	                else
	                    i.SC_Status = "Offline - PG"
	                end
	            else
	                i.SC_Status = "Offline - CPU"
	            end
	        else
	            i.SC_Status = "Offline - High Slot"
	        end 
	    elseif i.SC_Fitting.Slot == "MED" then   
	    
	    	if self.Slots.MED_U < self.Slots.MED then
	            if (self.Fitting.CPU_U + i.SC_Fitting.CPU) <= self.Fitting.CPU then
	                if (self.Fitting.PG_U + i.SC_Fitting.PG) <= self.Fitting.PG then

						self.Slots.MED_U = self.Slots.MED_U + 1
						self.Fitting.CPU_U = self.Fitting.CPU_U + i.SC_Fitting.CPU
						self.Fitting.PG_U = self.Fitting.PG_U + i.SC_Fitting.PG
												
						if i.SC_ShieldBonus then
							if i.SC_ShieldBonus.HP and i.SC_ShieldBonus.HP > 0 then
								table.insert(ShieldBonus_HP, i.SC_ShieldBonus.HP)
							end 
							if i.SC_ShieldBonus.HPA and i.SC_ShieldBonus.HPA > 0 then 
								table.insert(ShieldBonus_HPA, i.SC_ShieldBonus.HPA)
							end 
							if i.SC_ShieldBonus.RE and i.SC_ShieldBonus.RE > 0 then 
								table.insert(ShieldBonus_RE, i.SC_ShieldBonus.RE)
							end 
							if i.SC_ShieldBonus.EM and i.SC_ShieldBonus.EM > 0 then
								table.insert(ShieldBonus_EM, i.SC_ShieldBonus.EM)
							end 
							if i.SC_ShieldBonus.EXP and i.SC_ShieldBonus.EXP > 0 then
								table.insert(ShieldBonus_EXP, i.SC_ShieldBonus.EXP)
							end 
							if i.SC_ShieldBonus.KIN and i.SC_ShieldBonus.KIN > 0 then
								table.insert(ShieldBonus_KIN, i.SC_ShieldBonus.KIN)
							end 
							if i.SC_ShieldBonus.THERM and i.SC_ShieldBonus.THERM > 0 then
								table.insert(ShieldBonus_THERM, i.SC_ShieldBonus.THERM)
							end 
						end
						if i.SC_EnergyBonus then
							if i.SC_EnergyBonus.CRE  and i.SC_EnergyBonus.CRE > 0 then
								table.insert(EnergyBonus_CRE, i.SC_EnergyBonus.CRE)	
							end 
							if i.SC_EnergyBonus.CAP  and i.SC_EnergyBonus.CAP > 0 then
								table.insert(EnergyBonus_CAP, i.SC_EnergyBonus.CAP)	
							end 
							if i.SC_EnergyBonus.CAPP  and i.SC_EnergyBonus.CAPP > 0 then
								table.insert(EnergyBonus_CAPP, i.SC_EnergyBonus.CAPP)	
							end 
							if i.SC_EnergyBonus.SRE  and i.SC_EnergyBonus.SRE > 0 then
								table.insert(ShieldBonus_RE, i.SC_EnergyBonus.SRE)	
							end 
							if i.SC_EnergyBonus.SHLD  and i.SC_EnergyBonus.SHLD > 0 then
								table.insert(ShieldBonus_HP, i.SC_EnergyBonus.SHLD)	
							end 
							if i.SC_EnergyBonus.PG  and i.SC_EnergyBonus.PG > 0 then
								table.insert(EnergyBonus_PG, i.SC_EnergyBonus.PG)	
							end 
							if i.SC_EnergyBonus.CPU  and i.SC_EnergyBonus.CPU  > 0 then
								table.insert(EnergyBonus_CPU, i.SC_EnergyBonus.CPU)	
							end 						
						end 						
						
						if i.SC_WeaponBonus then
							if i.SC_WeaponBonus.OPT and i.SC_WeaponBonus.OPT > 0 then
								table.insert( WeaponBonus_OPT, i.SC_WeaponBonus.OPT )
							end
							if i.SC_WeaponBonus.FALL and i.SC_WeaponBonus.FALL > 0 then
								table.insert( WeaponBonus_FALL, i.SC_WeaponBonus.FALL )
							end
							if i.SC_WeaponBonus.TS and i.SC_WeaponBonus.TS > 0 then
								table.insert( WeaponBonus_TS, i.SC_WeaponBonus.TS )
							end
						end
						
						i.SC_Status = "Online"
						
	                else
	                    i.SC_Status = "Offline - PG"
	                end
	            else
	                i.SC_Status = "Offline - CPU"
	            end
	        else
	            i.SC_Status = "Offline - Mid Slot"
	        end 	

	    elseif i.SC_Fitting.Slot == "LOW" then
	    
	        if self.Slots.LOW_U < self.Slots.LOW then
	            if (self.Fitting.CPU_U + i.SC_Fitting.CPU) <= self.Fitting.CPU then
	                if (self.Fitting.PG_U + i.SC_Fitting.PG) <= self.Fitting.PG then

						self.Slots.LOW_U = self.Slots.LOW_U + 1
						self.Fitting.CPU_U = self.Fitting.CPU_U + i.SC_Fitting.CPU
						self.Fitting.PG_U = self.Fitting.PG_U + i.SC_Fitting.PG
						
						if i.SC_ArmorBonus then 
							if i.SC_ArmorBonus.HP and i.SC_ArmorBonus.HP > 0 then
								table.insert(ArmorBonus_HP, i.SC_ArmorBonus.HP)
							end
							if i.SC_ArmorBonus.HPA and i.SC_ArmorBonus.HPA > 0 then 
								table.insert(ArmorBonus_HPA, i.SC_ArmorBonus.HPA)
							end
							if i.SC_ArmorBonus.EM and i.SC_ArmorBonus.EM > 0 then
								table.insert(ArmorBonus_EM, i.SC_ArmorBonus.EM)
							end
							if i.SC_ArmorBonus.EXP and i.SC_ArmorBonus.EXP > 0 then
								table.insert(ArmorBonus_EXP, i.SC_ArmorBonus.EXP)
							end
							if i.SC_ArmorBonus.KIN and i.SC_ArmorBonus.KIN > 0 then
								table.insert(ArmorBonus_KIN, i.SC_ArmorBonus.KIN)
							end
							if i.SC_ArmorBonus.THERM and i.SC_ArmorBonus.THERM > 0 then
								table.insert(ArmorBonus_THERM, i.SC_ArmorBonus.THERM)
							end
						end
						
						if i.SC_ShieldBonus then
							if i.SC_ShieldBonus.HP and i.SC_ShieldBonus.HP > 0 then
								table.insert(ShieldBonus_HP, i.SC_ShieldBonus.HP)
							end
							if i.SC_ShieldBonus.HPA and i.SC_ShieldBonus.HPA > 0 then 
								table.insert(ShieldBonus_HPA, i.SC_ShieldBonus.HPA)
							end 
							if i.SC_ShieldBonus.RE and i.SC_ShieldBonus.RE > 0 then 
								table.insert(ShieldBonus_RE, i.SC_ShieldBonus.RE)
							end 
							if i.SC_ShieldBonus.EM and i.SC_ShieldBonus.EM > 0 then
								table.insert(ShieldBonus_EM, i.SC_ShieldBonus.EM)
							end 
							if i.SC_ShieldBonus.EXP and i.SC_ShieldBonus.EXP > 0 then
								table.insert(ShieldBonus_EXP, i.SC_ShieldBonus.EXP)
							end 
							if i.SC_ShieldBonus.KIN and i.SC_ShieldBonus.KIN > 0 then
								table.insert(ShieldBonus_KIN, i.SC_ShieldBonus.KIN)
							end 
							if i.SC_ShieldBonus.THERM and i.SC_ShieldBonus.THERM > 0 then
								table.insert(ShieldBonus_THERM, i.SC_ShieldBonus.THERM)
							end 
						end
						
						if i.SC_EnergyBonus then
							if i.SC_EnergyBonus.CRE  and i.SC_EnergyBonus.CRE > 0 then
								table.insert(EnergyBonus_CRE, i.SC_EnergyBonus.CRE)	
							end 
							if i.SC_EnergyBonus.CAP  and i.SC_EnergyBonus.CAP > 0 then
								table.insert(EnergyBonus_CAP, i.SC_EnergyBonus.CAP)	
							end 
							if i.SC_EnergyBonus.CAPP  and i.SC_EnergyBonus.CAPP > 0 then
								table.insert(EnergyBonus_CAPP, i.SC_EnergyBonus.CAPP)	
							end 
							if i.SC_EnergyBonus.SRE  and i.SC_EnergyBonus.SRE > 0 then
								table.insert(ShieldBonus_RE, i.SC_EnergyBonus.SRE)	
							end 
							if i.SC_EnergyBonus.SHLD  and i.SC_EnergyBonus.SHLD > 0 then
								table.insert(ShieldBonus_HP, i.SC_EnergyBonus.SHLD)	
							end 
							if i.SC_EnergyBonus.PG  and i.SC_EnergyBonus.PG > 0 then
								table.insert(EnergyBonus_PG, i.SC_EnergyBonus.PG)	
							end 
							if i.SC_EnergyBonus.CPU  and i.SC_EnergyBonus.CPU  > 0 then
								table.insert(EnergyBonus_CPU, i.SC_EnergyBonus.CPU)	
							end 						
						end 
						
						if i.SC_WeaponBonus then
							if i.SC_WeaponBonus.OPT and i.SC_WeaponBonus.OPT > 0 then
								table.insert( WeaponBonus_OPT, i.SC_WeaponBonus.OPT )
							end
							if i.SC_WeaponBonus.FALL and i.SC_WeaponBonus.FALL > 0 then
								table.insert( WeaponBonus_FALL, i.SC_WeaponBonus.FALL )
							end
							if i.SC_WeaponBonus.TS and i.SC_WeaponBonus.TS > 0 then
								table.insert( WeaponBonus_TS, i.SC_WeaponBonus.TS )
							end
							if i.SC_WeaponBonus.EFR and i.SC_WeaponBonus.EFR > 0 then 
								table.insert( WeaponBonus_EFR, i.SC_WeaponBonus.EFR )	
							end
							if i.SC_WeaponBonus.EDMG and i.SC_WeaponBonus.EDMG > 0 then
								table.insert( WeaponBonus_EDMG, i.SC_WeaponBonus.EDMG )	
							end
						end
						
						i.SC_Status = "Online"
	                else
	                    i.SC_Status = "Offline - PG"
	                end
	            else
	                i.SC_Status = "Offline - CPU"
	            end
	        else
	            i.SC_Status = "Offline - Low Slot"
	        end
	    else
	        print("FAIL: Unknown slot?")
	    end
	
	end
	
	local stackm = 1.00
	
	if ArmorBonus_HP then 
		table.sortdesc( ArmorBonus_HP )
		for k,v in pairs(ArmorBonus_HP) do		
			self.Armor.Max = self.Armor.Max * v
			self.Armor.HP = self.Armor.Max * self.Armor.Percent
		end	  
	
	end
	if ArmorBonus_HPA then 
		table.sortdesc( ArmorBonus_HPA )
		for k,v in pairs(ArmorBonus_HPA) do		
			self.Armor.Max = self.Armor.Max + v
			self.Armor.HP = self.Armor.Max * self.Armor.Percent
		end	  
	
	end
	self.ArmorRes.EM = self.BaseArmorRes.EM
	if ArmorBonus_EM then 
		table.sortdesc( ArmorBonus_EM )
		for k,v in pairs(ArmorBonus_EM) do
			if k == 1 then stackm = 1.00
			elseif k == 2 then stackm = 0.86912 
			elseif k == 3 then stackm = 0.5705831
			elseif k == 4 then stackm = 0.2829552 
			elseif k == 5 then stackm = 0.1059926 
			elseif k == 6 then stackm = 0.0299912 
			elseif k == 7 then stackm = 0.0064102
			elseif k == 8 then stackm = 0.0010349 end
		
			self.ArmorRes.EM = (self.ArmorRes.EM) + (ArmorBonus_EM[k] * 0.01 * stackm) * (1-(self.ArmorRes.EM))
			
			--print("Calcing Armor EM: "..tostring(ArmorBonus_EM[k]).." "..tostring(self.ArmorRes.EM))
			
		end	 
		
	end
	self.ArmorRes.EXP = self.BaseArmorRes.EXP
	if ArmorBonus_EXP then 
		table.sortdesc( ArmorBonus_EXP )
		for k,v in pairs(ArmorBonus_EXP) do
			if k == 1 then stackm = 1.00
			elseif k == 2 then stackm = 0.86912 
			elseif k == 3 then stackm = 0.5705831
			elseif k == 4 then stackm = 0.2829552 
			elseif k == 5 then stackm = 0.1059926 
			elseif k == 6 then stackm = 0.0299912 
			elseif k == 7 then stackm = 0.0064102
			elseif k == 8 then stackm = 0.0010349 end

			self.ArmorRes.EXP = (self.ArmorRes.EXP) + (ArmorBonus_EXP[k] * 0.01 * stackm) * (1-(self.ArmorRes.EXP))
			
		end	  
	
	end
	self.ArmorRes.KIN = self.BaseArmorRes.KIN 
	if ArmorBonus_KIN then 
		table.sortdesc( ArmorBonus_KIN ) 
		for k,v in pairs(ArmorBonus_KIN) do
			if k == 1 then stackm = 1.00
			elseif k == 2 then stackm = 0.86912 
			elseif k == 3 then stackm = 0.5705831
			elseif k == 4 then stackm = 0.2829552 
			elseif k == 5 then stackm = 0.1059926 
			elseif k == 6 then stackm = 0.0299912 
			elseif k == 7 then stackm = 0.0064102
			elseif k == 8 then stackm = 0.0010349 end 			
			
			self.ArmorRes.KIN = (self.ArmorRes.KIN) + (ArmorBonus_KIN[k] * 0.01 * stackm) * (1-(self.ArmorRes.KIN))
			
		end			
		
	end
	self.ArmorRes.THERM = self.BaseArmorRes.THERM
	if ArmorBonus_THERM then 
		table.sortdesc( ArmorBonus_THERM )
		for k,v in pairs(ArmorBonus_THERM) do
			if k == 1 then stackm = 1.00
			elseif k == 2 then stackm = 0.86912 
			elseif k == 3 then stackm = 0.5705831
			elseif k == 4 then stackm = 0.2829552 
			elseif k == 5 then stackm = 0.1059926 
			elseif k == 6 then stackm = 0.0299912 
			elseif k == 7 then stackm = 0.0064102
			elseif k == 8 then stackm = 0.0010349 end 		
			
			self.ArmorRes.THERM = (self.ArmorRes.THERM) + (ArmorBonus_THERM[k] * 0.01 * stackm) * (1-(self.ArmorRes.THERM))
			
		end	
		 
	end
	
	if ShieldBonus_HP then 
		table.sortdesc( ShieldBonus_HP )
		for k,v in pairs(ShieldBonus_HP) do		
			self.Shield.Max = self.Shield.Max * v
			self.Shield.HP = self.Shield.Max * self.Shield.Percent
		end		
	end
	if ShieldBonus_HPA then 
		table.sortdesc( ShieldBonus_HPA )
		for k,v in pairs(ShieldBonus_HPA) do		
			self.Shield.Max = self.Shield.Max + v
			self.Shield.HP = self.Shield.Max * self.Shield.Percent
		end	
	end
	if ShieldBonus_RE then 
		table.sortdesc( ShieldBonus_RE )
		for k,v in pairs(ShieldBonus_RE) do		
			self.Shield.RechargeTime = self.Shield.RechargeTime * v 			
		end		
	end
	self.ShieldRes.EM = self.BaseShieldRes.EM
	if ShieldBonus_EM then 
		table.sortdesc( ShieldBonus_EM )
		for k,v in pairs(ShieldBonus_EM) do
			if k == 1 then stackm = 1.00
			elseif k == 2 then stackm = 0.86912 
			elseif k == 3 then stackm = 0.5705831
			elseif k == 4 then stackm = 0.2829552 
			elseif k == 5 then stackm = 0.1059926 
			elseif k == 6 then stackm = 0.0299912 
			elseif k == 7 then stackm = 0.0064102
			elseif k == 8 then stackm = 0.0010349 end
		
			self.ShieldRes.EM = (self.ShieldRes.EM) + (ShieldBonus_EM[k] * 0.01 * stackm) * (1-(self.ShieldRes.EM))
			
			--print("Calcing Shield EM: "..tostring(ShieldBonus_EM[k]).." "..tostring(self.ShieldRes.EM))
			
		end	 
		
	end
	self.ShieldRes.EXP = self.BaseShieldRes.EXP
	if ShieldBonus_EXP then 
		table.sortdesc( ShieldBonus_EXP )
		for k,v in pairs(ShieldBonus_EXP) do
			if k == 1 then stackm = 1.00
			elseif k == 2 then stackm = 0.86912 
			elseif k == 3 then stackm = 0.5705831
			elseif k == 4 then stackm = 0.2829552 
			elseif k == 5 then stackm = 0.1059926 
			elseif k == 6 then stackm = 0.0299912 
			elseif k == 7 then stackm = 0.0064102
			elseif k == 8 then stackm = 0.0010349 end

			self.ShieldRes.EXP = (self.ShieldRes.EXP) + (ShieldBonus_EXP[k] * 0.01 * stackm) * (1-(self.ShieldRes.EXP))
			
		end	  
	
	end
	self.ShieldRes.KIN = self.BaseShieldRes.KIN 
	if ShieldBonus_KIN then 
		table.sortdesc( ShieldBonus_KIN ) 
		for k,v in pairs(ShieldBonus_KIN) do
			if k == 1 then stackm = 1.00
			elseif k == 2 then stackm = 0.86912 
			elseif k == 3 then stackm = 0.5705831
			elseif k == 4 then stackm = 0.2829552 
			elseif k == 5 then stackm = 0.1059926 
			elseif k == 6 then stackm = 0.0299912 
			elseif k == 7 then stackm = 0.0064102
			elseif k == 8 then stackm = 0.0010349 end 			
			
			self.ShieldRes.KIN = (self.ShieldRes.KIN) + (ShieldBonus_KIN[k] * 0.01 * stackm) * (1-(self.ShieldRes.KIN))
			
		end			
		
	end
	self.ShieldRes.THERM = self.BaseShieldRes.THERM
	if ShieldBonus_THERM then 
		table.sortdesc( ShieldBonus_THERM )
		for k,v in pairs(ShieldBonus_THERM) do
			if k == 1 then stackm = 1.00
			elseif k == 2 then stackm = 0.86912 
			elseif k == 3 then stackm = 0.5705831
			elseif k == 4 then stackm = 0.2829552 
			elseif k == 5 then stackm = 0.1059926 
			elseif k == 6 then stackm = 0.0299912 
			elseif k == 7 then stackm = 0.0064102
			elseif k == 8 then stackm = 0.0010349 end 		
			
			self.ShieldRes.THERM = (self.ShieldRes.THERM) + (ShieldBonus_THERM[k] * 0.01 * stackm) * (1-(self.ShieldRes.THERM))
			
		end	
		 
	end
	
	/*
	self.SC_EnergyBonus.CRE 	
	self.SC_EnergyBonus.CAP		
	self.SC_EnergyBonus.CAPP	
	self.SC_EnergyBonus.SRE 
	self.SC_EnergyBonus.SHLD 	
	self.SC_EnergyBonus.PG	
	self.SC_EnergyBonus.CPU	
 	*/
	
	if EnergyBonus_CRE then 
		table.sortdesc( EnergyBonus_CRE )
		for k,v in pairs(EnergyBonus_CRE) do		
			self.Cap.RechargeTime = self.Cap.RechargeTime * v 			
		end		
	end
	if EnergyBonus_CAP then 
		table.sortdesc( EnergyBonus_CAP )
		for k,v in pairs(EnergyBonus_CAP) do		
			self.Cap.Max = self.Cap.Max + v 
			self.Cap.CAP = self.Cap.Max * self.Cap.Percent			
		end		
	end
	if EnergyBonus_CAPP then 
		table.sortdesc( EnergyBonus_CAPP )
		for k,v in pairs(EnergyBonus_CAPP) do		
			self.Cap.Max = self.Cap.Max * v 
			self.Cap.CAP = self.Cap.Max * self.Cap.Percent			
		end		
	end
	if EnergyBonus_PG then 
		table.sortdesc( EnergyBonus_PG )
		for k,v in pairs(EnergyBonus_PG) do		
			self.Fitting.PG = self.Fitting.PG * v 			
		end		
	end
	if EnergyBonus_CPU then 
		table.sortdesc( EnergyBonus_CPU )
		for k,v in pairs(EnergyBonus_CPU) do		
			self.Fitting.CPU = self.Fitting.CPU * v 			
		end		
	end
	
	local stack = 1
	
	if WeaponBonus_OPT then 
		table.sortdesc( WeaponBonus_OPT )
		for k,v in pairs( WeaponBonus_OPT ) do
			stack = 0.5^(((k-1) / 2.22292081) ^2)				
			
			self.WeaponStats.Optimal = self.WeaponStats.Optimal + ( self.WeaponStats.Optimal * ( WeaponBonus_OPT[k] * stack ) )
			
		end	
		 
	end
	if WeaponBonus_FALL then 
		table.sortdesc( WeaponBonus_FALL )
		for k,v in pairs( WeaponBonus_FALL ) do
			stack = 0.5^(((k-1) / 2.22292081) ^2)				
			
			self.WeaponStats.Falloff = self.WeaponStats.Falloff + ( self.WeaponStats.Falloff * ( WeaponBonus_FALL[k] * stack ) )
			
		end	
		 
	end
	if WeaponBonus_TS then 
		table.sortdesc( WeaponBonus_TS )
		for k,v in pairs( WeaponBonus_TS ) do
			stack = 0.5^(((k-1) / 2.22292081) ^2)				
			
			self.WeaponStats.TrackingSpeed = self.WeaponStats.TrackingSpeed + ( self.WeaponStats.TrackingSpeed * ( WeaponBonus_TS[k] * stack ) )
			
		end	
		 
	end
	if WeaponBonus_EFR then 
		table.sortdesc( WeaponBonus_EFR )
		for k,v in pairs( WeaponBonus_EFR ) do
			stack = 0.5^(((k-1) / 2.22292081) ^2)				
			
			self.WeaponStats.EnergyFireRate = self.WeaponStats.EnergyFireRate + ( self.WeaponStats.EnergyFireRate * ( WeaponBonus_EFR[k] * stack ) )
			
		end	
		 
	end
	if WeaponBonus_EDMG then 
		table.sortdesc( WeaponBonus_EDMG )
		for k,v in pairs( WeaponBonus_EDMG ) do
			stack = 0.5^(((k-1) / 2.22292081) ^2)				
			
			self.WeaponStats.EnergyDamage = self.WeaponStats.EnergyDamage + ( self.WeaponStats.EnergyDamage * ( WeaponBonus_EDMG[k] * stack ) )
			
		end	
		 
	end
	
	self:SetNWFloat( "HullHP", self.Hull.HP )
	self:SetNWFloat( "HullMAX", self.Hull.Max )
	self:SetNWFloat( "HullP", self.Hull.Percent )
	self:SetNWFloat( "HullR1", self.HullRes.EM )
	self:SetNWFloat( "HullR2", self.HullRes.EXP )
	self:SetNWFloat( "HullR3", self.HullRes.KIN )
	self:SetNWFloat( "HullR4", self.HullRes.THERM )
	
	self:SetNWFloat( "ArmorHP", self.Armor.HP )
	self:SetNWFloat( "ArmorMAX", self.Armor.Max )
	self:SetNWFloat( "ArmorP", self.Armor.Percent )
	self:SetNWFloat( "ArmorR1", self.ArmorRes.EM )
	self:SetNWFloat( "ArmorR2", self.ArmorRes.EXP )
	self:SetNWFloat( "ArmorR3", self.ArmorRes.KIN )
	self:SetNWFloat( "ArmorR4", self.ArmorRes.THERM )
	
	self:SetNWFloat( "ShieldHP", self.Shield.HP )
	self:SetNWFloat( "ShieldMAX", self.Shield.Max )
	self:SetNWFloat( "ShieldP", self.Shield.Percent )
	self:SetNWFloat( "ShieldR1", self.ShieldRes.EM )
	self:SetNWFloat( "ShieldR2", self.ShieldRes.EXP )
	self:SetNWFloat( "ShieldR3", self.ShieldRes.KIN )
	self:SetNWFloat( "ShieldR4", self.ShieldRes.THERM )
	
	self:SetNWFloat( "SlotH", self.Slots.HIGH )
	self:SetNWFloat( "SlotH_U", self.Slots.HIGH_U )
	self:SetNWFloat( "SlotM", self.Slots.MED )
	self:SetNWFloat( "SlotM_U", self.Slots.MED_U )
	self:SetNWFloat( "SlotL", self.Slots.LOW )
	self:SetNWFloat( "SlotL_U", self.Slots.LOW_U )
	
	self:SetNWFloat( "FitCPU", self.Fitting.CPU )
	self:SetNWFloat( "FitCPU_U", self.Fitting.CPU_U )
	self:SetNWFloat( "FitPG", self.Fitting.PG )
	self:SetNWFloat( "FitPG_U", self.Fitting.PG_U )
	
	
    local stop = SysTime()
    --print(stop.."\n")
	
	local runtotal = stop-start
	local runtotal2 = (stop-start)*1000
	--print("Core HP Calculation Time: "..runtotal2.."ms")
	
	--PrintTable(self.fittingtable)

end


function ENT:Think()
	--self.BaseClass.Think(self) 
	
	self:SetOverlayText(self.PrintName.."\n\n"
	.."Hull: "..sc_ds(self.Hull.HP).."/"..sc_ds(self.Hull.Max).."\n"
	.."Armor: "..sc_ds(self.Armor.HP).."/"..sc_ds(self.Armor.Max).."\n"
	.."Shield: "..sc_ds(self.Shield.HP).."/"..sc_ds(self.Shield.Max).."\n"
	.."Shield Recharge: "..sc_ds(self.Shield.RechargeTime).."\n\n"
	.."Capacitor: "..sc_ds(self.Cap.CAP).."/"..sc_ds(self.Cap.Max).."\n"
	.."CAP Recharge: "..sc_ds(self.Cap.RechargeTime).."\n\n"
	.."Mass: "..sc_ds(self.total_mass).."KG\n"
	.."SigRad: "..sc_ds(self.sigrad/39.3700787).."m"
	)

	if (self.timer + self.ReCalcTime) <= (CurTime()) then
		self.timer = self.timer + self.ReCalcTime
		self:CalcHealth()
	end
	
	if self.OneSecond <= CurTime() then
		self.OneSecond = self.OneSecond + 1
		self:OneSecond_Think() --Think for things doing stuff every second
		--Msg(" Curtime: "..tostring(CurTime()).."\n")
	end
	
	self:Displays()
	
end

function ENT:OneSecond_Think()

	if self.Shield.HP < self.Shield.Max then
		--Old Formula
	    --local Recharge = ((self.Shield.Max^(0.4))/4)
	    --local Multiplier = cubic_curve(0.000012746884, -0.0025851618, 0.1243869249, 0.8555418808, (self.Shield.Percent*100))
	    --local HP =  (Recharge * Multiplier) + self.Shield.HP
	    --local NP = HP / self.Shield.Max
	    
	    local C_max		= self.Shield.Max
	    local C 		= math.Clamp(self.Shield.HP, 1, self.Shield.Max)
	    local R_time	= self.Shield.RechargeTime	    
	    local tau 		= 5.0/R_time
	    local formula	= tau*(1-C/C_max)*math.sqrt(2*C/C_max - (C/C_max)^2)
	    local HP		= (math.Clamp(formula * C_max, 0.1 ,self.Shield.Max)) + C
		local NP		= HP/C_max
		
		--Msg("FORMULA * C_max: "..tostring(formula*C_max).." PERCENT: "..tostring(self.Shield.Percent*100).." FORMULA: "..tostring(formula).."\n")
		--Msg("CURTIME: "..tostring(CurTime()).."\n")
	    
	    if HP < self.Shield.Max then
	        self.Shield.HP  	= HP
	        self.Shield.Percent = NP
	    else
	    	self.Shield.HP  	= self.Shield.Max
	        self.Shield.Percent = 1
	    end
	end 
	
	if self.Cap.CAP < self.Cap.Max then 		
	    
	    local C_max		= self.Cap.Max
	    local C 		= math.Clamp(self.Cap.CAP, 1, self.Cap.Max)
	    local R_time	= self.Cap.RechargeTime	    
	    local tau 		= 5.0/R_time
	    local formula	= tau*(1-C/C_max)*math.sqrt(2*C/C_max - (C/C_max)^2)
	    local HP		= (math.Clamp(formula * C_max, 0.1 ,self.Cap.Max)) + C
		local NP		= HP/C_max
		
		--Msg("CAP FORMULA * C_max: "..tostring(formula*C_max).." PERCENT: "..tostring(self.Cap.Percent*100).." FORMULA: "..tostring(formula).."\n")
	    
	    if HP < self.Cap.Max then
	        self.Cap.CAP  		= HP
	        self.Cap.Percent	= NP
	    else
	    	self.Cap.CAP  		= self.Cap.Max
	        self.Cap.Percent	= 1
	    end
	end 

end


function ENT:Displays() 

	Wire_TriggerOutput(self.Entity, "Shield", self.Shield.HP)	
	Wire_TriggerOutput(self.Entity, "Armor", self.Armor.HP)
	Wire_TriggerOutput(self.Entity, "Hull", self.Hull.HP)
	Wire_TriggerOutput(self.Entity, "Capacitor", self.Cap.CAP)
	
	Wire_TriggerOutput(self.Entity, "Max Shield", self.Shield.Max)
	Wire_TriggerOutput(self.Entity, "Max Armor", self.Armor.Max)
	Wire_TriggerOutput(self.Entity, "Max Hull", self.Hull.Max)
	Wire_TriggerOutput(self.Entity, "Max Capacitor", self.Cap.Max)
	
	Wire_TriggerOutput(self.Entity, "% Shield", math.Round(self.Shield.Percent*10000)/100)
	Wire_TriggerOutput(self.Entity, "% Armor", math.Round(self.Armor.Percent*10000)/100)
	Wire_TriggerOutput(self.Entity, "% Hull", math.Round(self.Hull.Percent*10000)/100)
	Wire_TriggerOutput(self.Entity, "% Capacitor", math.Round(self.Cap.Percent*10000)/100)

end

function ENT:GetCap()
	return self.Cap.CAP
end

function ENT:GetCoreInfo()
	local coreinfo = { }
	coreinfo.shield = self.Shield.HP
	coreinfo.shieldmax = self.Shield.Max
	coreinfo.armor = self.Armor.HP
	coreinfo.armormax = self.Armor.Max
	coreinfo.hull = self.Hull.HP
	coreinfo.hullmax = self.Hull.Max
	return coreinfo
end

function ENT:GetSig()
	return self.sigrad
end

function ENT:ConsumeCap(amount)
	self.Cap.CAP = math.Clamp(self.Cap.CAP - amount,0,self.Cap.Max)
	self.Cap.Percent = self.Cap.CAP/self.Cap.Max
end

function ENT:GenerateCap(amount)
	self.Cap.CAP = math.Clamp(self.Cap.CAP + amount,0,self.Cap.Max)
	self.Cap.Percent = self.Cap.CAP/self.Cap.Max
end

function ENT:RepairArmor(amount)
 	self.Armor.HP = math.Clamp(self.Armor.HP + amount, 0, self.Armor.Max)
	self.Armor.Percent = self.Armor.HP/self.Armor.Max
end

function ENT:RepairShield(amount)
 	self.Shield.HP = math.Clamp(self.Shield.HP + amount, 0, self.Shield.Max)
	self.Shield.Percent = self.Shield.HP/self.Shield.Max
end

function ENT:RepairHull(amount)
 	self.Hull.HP = math.Clamp(self.Hull.HP + amount, 0, self.Hull.Max)
	self.Hull.Percent = self.Hull.HP/self.Hull.Max
end

function ENT:GetWeaponInfo()
	local info = self.WeaponStats
	return info
end