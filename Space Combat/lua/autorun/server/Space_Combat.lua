/*******************************************************************************
	Space Combat
*******************************************************************************/

SpaceCombat = 1 -- So you can detect this :)
SpaceCombat_debug = false  --Debug message spam 

CreateConVar( "scvar_PhysDmgAll", 	"1",	FCVAR_NOTIFY ) --All non-Cored things take damage from collisions when true
CreateConVar( "scvar_PhysDmgCore", 	"1",	FCVAR_NOTIFY ) --All Cored things take damage from collisions when true
CreateConVar( "scvar_HookDmgAll", 	"1",	FCVAR_NOTIFY ) --All non-Cored things take damage from normal guns and explosions (Overrides PhysDMG)
CreateConVar( "scvar_HookDmgCore", 	"1",	FCVAR_NOTIFY ) --All Cored things take damage from normal guns and explosions (Overrides PhysDMG)
CreateConVar( "scvar_DmgAll", 		"1",	FCVAR_NOTIFY ) --All non-Cored things take damage from the damage system (if false overrides everything else)
CreateConVar( "scvar_DmgCore", 		"1",	FCVAR_NOTIFY ) --All Cored things take damage from the damage system (if false overrides everything else)
CreateConVar( "scvar_Dmg", 			"1",	FCVAR_NOTIFY ) --All Damage, On or Off (includes GCombat when using sv_gcom_Damage.lua to run GCombat damage for this)

if file.Exists("../lua/entities/ship_core_base/.svn/entries") then
	SpaceCombatVersion = tonumber( string.Explode( "\n", file.Read( "../lua/entities/ship_core_base/.svn/entries" ) )[ 4 ] ) --get svn revision
else
	SpaceCombatVersion = "DEV"
end 

Msg("\n\n".."==========================================\n")
Msg("== Space Combat Version:\t"..tostring(SpaceCombatVersion).."\t==".."\n") -- You will see this if we loaded :)
Msg("==========================================\n\n")

/*******************************************************************************
	Values you can tweak below this line.
*******************************************************************************/

local AvoidMB = true
local ETSC_M 	= 6.0 --Multiplier for repair modual HP boost
local ETSC_CM 	= 1.00 --Multiplier for modual Cap use

--####	Basic Health Stuff	####--
local MaxHealth = 1000000	-- Max Health Allowed
local MinHealth = 100		-- Min Health Allowed
--This will only apply to individual props, not Cores

--MP3 in GMod memory leaks but WAV dosn't :(
local shieldsounds = {
	Sound("tech/shield/sga_impact_01.wav"),
	Sound("tech/shield/sga_impact_02.wav"),
	Sound("tech/shield/sga_impact_03.wav"),
	Sound("tech/shield/sga_impact_04.wav")
}

local armorsounds = {
	Sound("tech/armor/core_armourhit.wav"),
	Sound("tech/armor/core_armourhit2.wav"),
	Sound("tech/armor/core_armourhit3.wav")
}
	
for k,v in pairs(shieldsounds) do
	util.PrecacheSound(v)
end

for k,v in pairs(armorsounds) do
	util.PrecacheSound(v)
end

--####	Health Multipliers Based on Material	####--
local MULTI_CONCRETE 		= 1.50
local MULTI_METAL 			= 3.00
local MULTI_DIRT 			= 0.20
local MULTI_VENT 			= 1.50
local MULTI_GRATE 			= 1.50
local MULTI_TILE 			= 0.50
local MULTI_SLOSH 			= 0.10
local MULTI_WOOD 			= 0.25
local MULTI_COMPUTER 		= 1.00
local MULTI_GLASS 			= 0.50
local MULTI_FLESH 			= 0.25
local MULTI_BLOODYFLESH 	= 0.25
local MULTI_CLIP 			= 0.01
local MULTI_ANTLION 		= 0.50
local MULTI_ALIENFLESH 		= 0.50
local MULTI_FOLIAGE 		= 0.10
local MULTI_SAND 			= 0.15
local MULTI_PLASTIC 		= 0.75

--####	Stargate Shield Stuff ####--
local SgShield_MaxDamage 	= 2500 --This much damage will 1 shot a 0 multiplier sheild

--Global so I can use in the gcom damage script to.
--List of "Shield Bubble" ents that block blasts
SC_Shields = {
	"shield",
	"sga_shield"
}

/*******************************************************************************
	No More Tweaking!!! (unless you know what you're doing)
*******************************************************************************/

--####	Global functions to return some values so other stuff can read ####--
function SC_MaxHealth()	-- Get the MaxHealth
	return MaxHealth
end

function SC_MinHealth()	-- Get the MinHealth
	return MinHealth
end

function SC_SG_Shield_MaxDamage()
	return SgShield_MaxDamage
end

function SC_ETSCM()
	return ETSC_M	
end

function SC_ETSCCM()
	return ETSC_CM	
end

-- Messages that can easily be disabled.
function scPrint(mess)
	if SpaceCombat_debug then
		print(mess)
	end
	return
end

function scMsg(mess)
	if SpaceCombat_debug then
		Msg(mess.."\n")
	end
	return
end

function GetCvarBool(cvar) --Mainly just to save space
	return GetConVar(cvar):GetBool()
end

--####	Spawning of Stuff	####-- 

function SC_EntCreated(ent)
	if ent:IsValid() and not ent:IsPlayer() and not ent:IsWeapon() and CurTime() > 5 then
		timer.Simple( 0.25, SC_Filter, ent )  --Need the timer or the ent will be detect as the base class and with no model to calc health from.
	end
end 

hook.Add( "OnEntityCreated", "SC_EntCreated", SC_EntCreated)


function SC_Filter(ent) --Because the hook finds EVERYTHING, lets filter out some usless junk 
	if not ent:IsValid() then return false end    
    if ent:GetSolid() == SOLID_NONE then return false end
    if not ent:GetPhysicsObject():IsValid() then return false end    
    if ent:GetClass() == "sent_anim" or ent:GetClass() == "gmod_ghost" then return false end
    if ent:IsPlayer() or ent:IsNPC() then return false end
    if ent.SC_Immune or ent.SC_Health or ent.CDSIgnore then
        --Msg("SC_Spawned thinks that " ..tostring(ent).." is dumb".."\n")
        --Msg("Immune	: "..tostring(ent.SC_Immune).."\n")
		--Msg("Health	: "..tostring(ent.SC_Health).."\n")
		--Msg("CDS	: "..tostring(ent.CDSIgnore).."\n")
		return false
	end
	
	SC_Spawned( ent ) --Anything not filtered goes to the spawned function, it is used to assign hp
end 

function GetVolume(ent) 

	local dif = ent:OBBMaxs() - ent:OBBMins()
	local volume = dif.x * dif.y * dif.z
	
	--Msg("VOLUME Cubic Inches: "..tostring(volume).."\n")
	--Msg("VOLUME Cubic Feet: "..tostring(volume/1728).."\n")
	
	return volume
	
end

function SC_GetMatType(ent)	--Bad way to find material type.. but appears to be the only way there is :(   
	
	local tr = { 
		start = ent:OBBMins() + ent:GetPos(),
		endpos = ent:OBBMaxs() + ent:GetPos(),
	}
	tr = util.TraceLine( tr )			
	return tr.MatType 
end

function SC_GetHealthMultiplier(ent)
	local mat = SC_GetMatType(ent)
	local multi = 0.5 		
	
	if not mat then
		multi = 0.5 
		--Msg("I am: "..tostring(ent).." My collison hull is a pain in the ass to trace to :(".."\n")
		return multi 
	elseif mat == MAT_CONCRETE then
		multi = MULTI_CONCRETE
	elseif mat == MAT_METAL then
		multi = MULTI_METAL
	elseif mat == MAT_DIRT then
		multi = MULTI_DIRT
	elseif mat == MAT_VENT then
		multi = MULTI_VENT
	elseif mat == MAT_GRATE then
		multi = MULTI_GRATE
	elseif mat == MAT_TILE  then
		multi = MULTI_TILE
	elseif mat == MAT_SLOSH then
		multi = MULTI_SLOSH
	elseif mat == MAT_WOOD then
		multi = MULTI_WOOD
	elseif mat == MAT_COMPUTER then
		multi = MULTI_COMPUTER
	elseif mat == MAT_GLASS then
		multi = MULTI_GLASS
	elseif mat == MAT_FLESH  then
		multi = MULTI_FLESH
	elseif mat == MAT_BLOODYFLESH then
		multi = MULTI_BLOODYFLESH
	elseif mat == MAT_CLIP then
		multi = MULTI_CLIP
	elseif mat == MAT_ANTLION then
		multi = MULTI_ANTLION
	elseif mat == MAT_ALIENFLESH then
		multi = MULTI_ALIENFLESH
	elseif mat == MAT_FOLIAGE then
		multi = MULTI_FOLIAGE
	elseif mat == MAT_SAND  then
		multi = MULTI_SAND
	elseif mat == MAT_PLASTIC then
		multi = MULTI_PLASTIC
	end
	
	--Msg("I am: "..tostring(ent).."	My Material is: "..mat.."\n")
	--Msg("I am: "..tostring(ent).."	My Multiplier is: "..multi.."\n")
	
	return multi	
end

function SC_CalcHealth( ent )
	
	local volume = GetVolume(ent)	
	local multiplier = SC_GetHealthMultiplier(ent)
	
	--local health = math.Round(((volume*5)^(0.45))*multiplier)
	local health = math.Round(((volume)^(0.515))*multiplier)
	   
	return health
end

function SC_Spawned( ent )
    
    local MaxHealth = SC_MaxHealth()
    local MinHealth = SC_MinHealth()
	local Health = SC_CalcHealth( ent )
		
	--Msg("==========\n"..tostring(ent:GetTable().OnTakeDamage).."\n==========\n")    	
	
	local OldFunc = ent:GetTable().OnTakeDamage  
	function ent:OnTakeDamage(dmginfo) --Make sure the ent has an OnTakeDamage function so we can use that hook on it
		
		SC_EntityTakeDamage( self, dmginfo:GetInflictor(), dmginfo:GetAttacker(), dmginfo:GetDamage(), dmginfo ) 		
		OldFunc(self, dmginfo)
			
	end		
	
	if Health < MaxHealth and Health > MinHealth then
	    ent.SC_Health = Health
	    ent.SC_MaxHealth = Health
	    scMsg("I am: "..tostring(ent).."	My Health is: "..tostring(Health))
	elseif Health >= MaxHealth then
		ent.SC_Health = MaxHealth
		ent.SC_MaxHealth = MaxHealth
		scMsg("I am: "..tostring(ent).."	My Health is Max at: "..tostring(MaxHealth))
	elseif Health <= MinHealth then
		ent.SC_Health = MinHealth
		ent.SC_MaxHealth = MinHealth
		scMsg("I am: "..tostring(ent).."	My Health is Min at: "..tostring(MinHealth).." from: "..tostring(Health))
	else
		scMsg("You Broke Somthing... in the part where health is figured out")
	end
end

/*******************************************************************************
	Things to deal damage
*******************************************************************************/

function SC_EntityTakeDamage( ent, inflictor, attacker, amount, dmginfo )	
	
    if not ent:IsValid() then return false end
    if not GetCvarBool("scvar_Dmg") then return false end
    if not GetCvarBool("scvar_HookDmgAll") and not ent.SC_CoreEnt then return end
    if not GetCvarBool("scvar_HookDmgCore") and ent.SC_CoreEnt != nil then return end
	if not ent.SC_Immune and not ent.SC_Health and not ent.CDSIgnore and not ent:IsPlayer() and not ent:IsNPC() then
   		SC_CalcHealth(ent)
		--Msg("I failed and have no health \n")
		--Msg("Immune	1: "..tostring(ent.SC_Immune).."\n")
		--Msg("Health	2: "..tostring(ent.SC_Health).."\n")
		--Msg("CDS	3: "..tostring(ent.CDSIgnore).."\n")
		--Msg("Player	4: "..tostring(ent:IsPlayer()).."\n")
	end
    
    if not ent.SC_Immune and ent.SC_Health and not ent.CDSIgnore then
	
	if (string.find(inflictor:GetClass(), "point_hurt")) or (string.find(attacker:GetClass(), "point_hurt")) or (string.find(inflictor:GetClass(), "stargate_")) or (string.find(attacker:GetClass(), "stargate_")) then
		if ent:IsPlayer() or ent:IsNPC() then
			SC_ApplyDamage(ent, damage, attacker, inflictor)
		else
			return
		end
	end
	
    --print(tostring(dmginfo:GetInflictor()))
	local damage = {}
		if dmginfo:IsBulletDamage() then
			--Msg("BULLETS!!!\n")
			amount = amount / 5
			
			if amount > 50 then
				amount = 50
				
			end
			damage= {
				EM = 0,
				EXP = 0,
				KIN = amount,
				THERM = 0
				} 			
		elseif dmginfo:IsExplosionDamage() then
		    --Msg("BLAST!!!\n")
		    damage= {
				EM = 0,
				EXP = amount,
				KIN = 0,
				THERM = 0
				}
		else
			if ent.SC_CoreEnt != nil then
			    if not GetCvarBool("scvar_PhysDmgCore") then return end
				if dmginfo:GetInflictor():GetClass() == "prop_combine_ball" then
				 	amount = amount / 10
				else
					amount = amount * 2.0
				end
			else
				if not GetCvarBool("scvar_PhysDmgAll") then return end
				amount = amount / 2
			end
			
			damage= {
				EM = 0,
				EXP = 0,
				KIN = amount,
				THERM = 0
				} 	
		end
		
		scMsg("I got hurt by hooks for: "..tostring(amount).." damage")
		SC_ApplyDamage(ent, damage, attacker, inflictor)
		
	elseif (ent:IsPlayer()) or (ent:IsNPC()) then
	
	else
		--Msg("FAIL!\n")
	    return false  
	end
	--Msg("I COMPLETED!!!\n")
end

hook.Add( "EntityTakeDamage", "SC_EntityTakeDamage", SC_EntityTakeDamage)

--####	Kill A Destroyed Entity  ####--
function SC_KillEnt(ent)
	/*
	local smokepuff = ents.Create( "env_ar2explosion" ) -- smokey ring
   		smokepuff:SetPos(ent:GetPos())
    	smokepuff:SetKeyValue( "material", "particle/particle_noisesphere" )
    	smokepuff:Spawn()
		smokepuff:Activate()
		smokepuff:Fire("explode", "", 0)
		smokepuff:Fire("kill","",10)	
	*/
	ent:Remove()
end

--Msg("ShieldDamage: "..tostring(ShieldDamage).."\n")
		--Msg("ShieldDamageTable.EM: "..tostring(ShieldDamageTable.EM).."\n")
		--Msg("ShieldDamageTable.EXP: "..tostring(ShieldDamageTable.EXP).."\n")
		--Msg("ShieldDamageTable.KIN: "..tostring(ShieldDamageTable.KIN).."\n")
		--Msg("ShieldDamageTable.THERM: "..tostring(ShieldDamageTable.THERM).."\n")

--####	Damage Apply	####--

function SC_HelpMahFPS(ent)
	if not ent:IsValid() then return false end --Did it get Removed before the timer triggerd this function?
	ent.SC_Shieldglowing = false
	ent.SC_Armorglowing = false
end

function SC_HelpMahFPS2()
    AvoidMB = true
end


function SC_ApplyDamage(ent, damage, attacker, inflictor, origin) --Attacker is the player, inflictor is the weapon)
    if not GetCvarBool("scvar_Dmg") then return false end
	if not GetCvarBool("scvar_DmgAll")and not ent.SC_CoreEnt then return end
	if not GetCvarBool("scvar_DmgCore")and ent.SC_CoreEnt != nil then return end

	if not ent:IsValid() then return false end 

	if ent.SC_CoreEnt != nil then
		local hitent = ent
		ent = ent.SC_CoreEnt
		
		local ShieldDamageTable = {
			EM 		= damage.EM * (1 - ent.ShieldRes.EM),
			EXP 	= damage.EXP * (1 - ent.ShieldRes.EXP),
			KIN 	= damage.KIN * (1 - ent.ShieldRes.KIN),
			THERM	= damage.THERM * (1 - ent.ShieldRes.THERM)
			}
			
		local ShieldDamage = ShieldDamageTable.EM + ShieldDamageTable.EXP + ShieldDamageTable.KIN + ShieldDamageTable.THERM		
		
		if ent.Shield.HP >= ShieldDamage then
			ent.Shield.HP = ent.Shield.HP - ShieldDamage
			ent.Shield.Percent = ent.Shield.HP / ent.Shield.Max
			--Msg("CORE: "..tostring(ent).."	took: "..tostring(ShieldDamage).." ShieldDamage and has: "..tostring(ent.Shield.HP).." Shield Left".."\n")
			
			if not hitent.SC_ShieldSound and ent.Shield.Percent > 0.01 then 				
				hitent:EmitSound( shieldsounds[math.random(1,4)], 100, math.Rand(90,110) )
				--WorldSound( shieldsounds[math.random(1,4)], hitent:GetPos(), 100, 100 )
				hitent.SC_ShieldSound = true
 				timer.Simple( 0.2, function() hitent.SC_ShieldSound = false end )					
			end
			if not hitent.SC_Shieldglowing and ent.Shield.Percent > 0.01 then --Limit effect spam!!!
				local ed = EffectData()
 					ed:SetEntity( hitent )
 					util.Effect( "sc_shield_hit", ed, true, true)
 					hitent.SC_Shieldglowing = true
 					timer.Simple( 0.8, SC_HelpMahFPS, hitent )
 			end
 				
		elseif ent.Shield.HP < ShieldDamage then
			--Msg("CORE: "..tostring(ent).."	took: "..tostring(ShieldDamage).." ShieldDamage and has: "..tostring(ent.Shield.HP).." Shield Left".."\n")
		     
		    local total = damage.EM + damage.EXP + damage.KIN + damage.THERM
		    
		    local ratiotable = {
		    	EM 		= damage.EM / total,
		    	EXP		= damage.EXP / total,
		    	KIN		= damage.KIN / total,
		    	THERM	= damage.THERM / total		    
		    }
		    
		    --Msg("\n==============================\n")
			--PrintTable( ratiotable )
			--Msg("==============================\n\n")
		    
		    local leftover = 0
		    if ent.Shield.HP > 0 then
				leftover = (ent.Shield.HP - ShieldDamage) * -1
				
				--Recalc the Damage of each type that the shield didn't take 				
				damage = {
					EM 		= ratiotable.EM * (leftover / (1 - ent.ShieldRes.EM)),
		    		EXP		= ratiotable.EXP * (leftover / (1 - ent.ShieldRes.EXP)),
		    		KIN		= ratiotable.KIN * (leftover / (1 - ent.ShieldRes.KIN)),
		    		THERM	= ratiotable.THERM * (leftover / (1 - ent.ShieldRes.THERM))		    
		    	}
		    	
		    	--Msg("\nARMOR==============================\n")
				--PrintTable( damage )
				--Msg("ARMOR==============================\n\n")
				
			end 			
			
			ent.Shield.HP = 0
			ent.Shield.Percent = 0
			--Msg("LEFTOVER: "..tostring(leftover).."\n")
			
			local ArmorDamageTable = {
				EM 		= damage.EM * (1 - ent.ArmorRes.EM),
				EXP 	= damage.EXP * (1 - ent.ArmorRes.EXP),
				KIN 	= damage.KIN * (1 - ent.ArmorRes.KIN),
				THERM	= damage.THERM * (1 - ent.ArmorRes.THERM)
				}
				
			--Msg("\nARMOR==============================\n")
			--PrintTable( ArmorDamageTable )
			--Msg("ARMOR==============================\n\n")
			
			local ArmorDamage = ArmorDamageTable.EM + ArmorDamageTable.EXP + ArmorDamageTable.KIN + ArmorDamageTable.THERM		
			
			if ent.Armor.HP >= ArmorDamage then
				ent.Armor.HP = ent.Armor.HP - ArmorDamage
				ent.Armor.Percent = ent.Armor.HP / ent.Armor.Max
				--Msg("CORE: "..tostring(ent).."	took: "..tostring(ArmorDamage).." ArmorDamage and has: "..tostring(ent.Armor.HP).." Armor Left".."\n")
				
				if not hitent.SC_ArmorSound and ent.Armor.Percent > 0.01 then 				
					hitent:EmitSound( armorsounds[math.random(1,3)], 100, math.Rand(90,110) )
					--WorldSound( armorsounds[math.random(1,3)], hitent:GetPos(), 100, 100 )
					hitent.SC_ArmorSound = true
					timer.Simple( 0.2, function() hitent.SC_ArmorSound = false end )					
				end
				if not hitent.SC_Armorglowing and ent.Armor.Percent > 0.01 then --Limit effect spam!!!
					local ed = EffectData()
						ed:SetEntity( hitent )
						util.Effect( "sc_armor_hit", ed, true, true)
						hitent.SC_Armorglowing = true
						timer.Simple( 0.8, SC_HelpMahFPS, hitent )
				end
			elseif ent.Armor.HP < ArmorDamage then
				--Msg("CORE: "..tostring(ent).."	took: "..tostring(ArmorDamage).." ArmorDamage and has: "..tostring(ent.Armor.HP).." Armor Left".."\n")
	
			
			local total = damage.EM + damage.EXP + damage.KIN + damage.THERM  	 		    	
		    
		    	local leftover = 0
		    	if ent.Armor.HP > 0 then
					leftover = (ent.Armor.HP - ArmorDamage) * -1
				
					--Recalc the Damage of each type that the armor didn't take 				
					damage = {
						EM 		= ratiotable.EM * (leftover / (1 - ent.ArmorRes.EM)),
		    			EXP		= ratiotable.EXP * (leftover / (1 - ent.ArmorRes.EXP)),
		    			KIN		= ratiotable.KIN * (leftover / (1 - ent.ArmorRes.KIN)),
		    			THERM	= ratiotable.THERM * (leftover / (1 - ent.ArmorRes.THERM))			    
		    		}
		    		
		    		--Msg("\nHULL==============================\n")
					--PrintTable( damage )
					--Msg("HULL==============================\n\n")
		    		
				end 			
			
				ent.Armor.HP = 0
				ent.Armor.Percent = 0
				--Msg("LEFTOVER: "..tostring(leftover).."\n")
			
				local HullDamageTable = {
					EM 		= damage.EM * (1 - ent.HullRes.EM),
					EXP 	= damage.EXP * (1 - ent.HullRes.EXP),
					KIN 	= damage.KIN * (1 - ent.HullRes.KIN),
					THERM	= damage.THERM * (1 - ent.HullRes.THERM)
					}
					
				--Msg("\nHULL==============================\n")
				--PrintTable( HullDamageTable )
				--Msg("HULL==============================\n\n")
			
				local HullDamage = HullDamageTable.EM + HullDamageTable.EXP + HullDamageTable.KIN + HullDamageTable.THERM		
			
				if ent.Hull.HP > HullDamage then
					ent.Hull.HP = ent.Hull.HP - HullDamage
					ent.Hull.Percent = ent.Hull.HP / ent.Hull.Max
					--Msg("CORE: "..tostring(ent).."	took: "..tostring(HullDamage).." HullDamage and has: "..tostring(ent.Hull.HP).." Hull Left".."\n")
				elseif	ent.Hull.HP < HullDamage then
					for _,i in pairs( constraint.GetAllConstrainedEntities_B( ent ) ) do 
						if not i.SC_Immune2 then						
							if (string.find(i:GetClass(),"prop") ~= nil) then
								local delay = (math.random(300, 800) / 100)
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
								if (i.Entity != nil and i.Entity:IsValid()) and not string.find(i:GetClass(),"ship_core") then
									i.Entity:Remove()
								end
							end							
						else
							i.SC_Core = nil
						end 			
					end
					
					for _,i in pairs( ent.ConWeldTable ) do
         				if i:IsValid() then
						local physobj = i:GetPhysicsObject()
						local mass = 1
							if(physobj:IsValid()) then
								mass = physobj:GetMass()
							end
						physobj:ApplyForceCenter(Vector(math.random(mass*-250,mass*250),math.random(mass*-250,mass*250),math.random(mass*-250,mass*250)))
						end
					end
					ent.Hull.HP = 0
					--From Warp_core for temp usage :)
					if AvoidMB then
						local effectdata = EffectData()
						effectdata:SetMagnitude( 1 )
					
						local Pos = ent:GetPos()
	
						effectdata:SetOrigin( Pos )
						effectdata:SetScale( 23000 )
						util.Effect( "sc_explode", effectdata )
						local tAllPlayers = player.GetAll()
						for _, pPlayer in pairs( tAllPlayers ) do
							pPlayer.Entity:EmitSound( "explode_9" )
						end
						ent:EmitSound( "explode_9" )
						
						timer.Simple( 0.25, SC_HelpMahFPS2 )
						AvoidMB = false
					end
					
					SC_KillEnt(ent)
				end 
			end 				
		end 	
		return false
	else
		
		if ent.SC_Immune2 then return false end
	
		local damage2 = damage.EM + damage.EXP + damage.KIN + damage.THERM
		--Msg("Damage2: "..tostring(damage2).."\n")
	
	
		if not ent.SC_Health or ent.SC_Immune then
	    	if ent:IsValid() and ent:GetClass() == "shield" then
	    
	    		ent.Parent.Strength = math.Clamp(ent.Parent.Strength-(((damage2/SgShield_MaxDamage)*100)/(ent.Parent.StrengthMultiplier[1]*ent.Parent.StrengthConfigMultiplier)),0,100)
				ent:Hit(inflictor,ent:GetPos(),1.0) --So it still plays the shields hit effect 
			
				return	    	
	    	elseif ent:IsValid() and ent:GetClass() == "sga_shield" then
	    		if origin then	    		
					--print("AWAWASSSDSA=========================================================================")
					local tr = StarGate.Trace:New(origin, origin - ent:GetPos())
					ent:Hit(inflictor, tr.HitPos, damage2, -1*tr.Normal)
				end
				return	    
	    	end
			if not ent.SC_Immune then
			    if ent:IsPlayer() and ent:InVehicle() then
			    else
			    	--Msg("========== Owner: "..tostring(ent.Owner).."\n")
					ent:TakeDamage(damage2, attacker, inflictor)
				end
			end
	    	--Msg("I am: "..tostring(ent).."	I'M NOT gona take your Damage of: "..tostring(damage).."\n")
	    	return false 
		end
	    --Msg("========== Owner: "..tostring(ent.Owner).."\n")
		if ent.SC_Health > damage2 then
			ent.SC_Health = (ent.SC_Health - damage2)
			--Msg("I am: "..tostring(ent).."	I took: "..tostring(damage2).." Damage and have: "..tostring(ent.SC_Health).." Health Left".."\n")
		elseif ent.SC_Health < damage2 then
	    	--Msg("I am: "..tostring(ent).."	I took: "..tostring(damage2).." Damage and DIED!!! :(".."\n")
	    	SC_KillEnt(ent)
		end
	end
end




--####  Explode ####--
function SC_Explode(position, radius, damage, attacker, inflictor )
    if not GetCvarBool("scvar_Dmg") then return false end

	local damaged = ents.FindInSphere(position, radius)
	local fallofftable = {}
	local hitentstable = {}
	
	for _,i in pairs(damaged) do
	    local distance = (i:NearestPoint(position) - position):Length() -- New way
	    local falloff = (1 - (distance/radius))
		--Msg("=====\nFalloff: " ..tostring(falloff).."\nDistance: "..tostring(distance).."\nRadius: "..tostring(radius).."\n=====\n")
		if falloff < 0 then
			--Msg("\nWTF FALLOFF < 0!!!! "..tostring(distance).."\n\n")
			falloff = 0
			--The method above used to work fine, but garry broke it since update 43 when ents.FindInSphere was first broken
		end  	    
	    local damage_to_deal = {EM=damage.EM * falloff, EXP=damage.EXP * falloff, KIN=damage.KIN * falloff, THERM=damage.THERM * falloff}	

		                                                                  
		local tr = nil
		
		if StarGate.Installed then  --Use Stargates method of tracelines if available, since it can detect shields :)
			tr = StarGate.Trace:New(position,(i:NearestPoint(position) - position):Normalize()*distance,inflictor)
		else
			local trace = { 
				start = position,
				endpos = i:NearestPoint(position),
				filter = inflictor,
			}
			tr = util.TraceLine( trace ) 					
		end 
		
	
		--Msg("Trace Hit: "..tostring(tr.Entity).."\n")
				
		if tr.HitWorld == false and falloff > 0 then
			--if tr.Entity:IsValid() and tr.Entity:GetClass() == "shield" then
			if tr.Entity:IsValid() and table.HasValue( SC_Shields, tr.Entity:GetClass() ) then
	    		--SC_ApplyDamage(i, damage_to_deal, attacker, inflictor )
				--Msg("Shielded: "..tostring(i).."\n")
			else
				if i.SC_CoreEnt != nil then
					hitentstable[falloff] = i
					table.insert(fallofftable, falloff) 				
				else
					SC_ApplyDamage(i, damage_to_deal, attacker, inflictor, position )
       				--Msg("Damaging: "..tostring(i).."\n")
       			end
			end 			
		else
			--Msg("Trace Hit World, so did nothing \n")
		end	    
	end
	table.sortdesc( fallofftable )
	--Msg("\n==============================\n")
	--PrintTable( hitentstable )
	--Msg("==============================\n\n")
	--Msg("\n==============================\n")
	--PrintTable( fallofftable )
	--Msg("==============================\n\n")
	--All this stuff below makes it do explosion damage only for the ent that took the most damage, that way, hitting 1 massive prop or 50 wire chips deals the same damage
	local alreadyhit = {}
	for _,f in pairs(fallofftable) do 
		local test = hitentstable[f].SC_CoreEnt
		if table.HasValue(alreadyhit, test) then
			
		else
			local falloff = f
			local damage_to_deal = {EM=damage.EM * falloff, EXP=damage.EXP * falloff, KIN=damage.KIN * falloff, THERM=damage.THERM * falloff}
			table.insert(alreadyhit, test)
			SC_ApplyDamage(hitentstable[f], damage_to_deal, attacker, inflictor ) 		
			--Msg(tostring(test).."\n")
		end		
	end 	
end     
    
--#### Destruct Explode ####--
function SC_Destruct_Explode(position, radius, damage, attacker, inflictor )
    if not GetCvarBool("scvar_Dmg") then return false end

	local damaged = ents.FindInSphere(position, radius)
	local filter = {}
	
	--Filter out props that were part of the distructed object so they don't instantly die on blast since they will most likely have 1 hp
	for _,i in pairs(damaged) do
		if not i.SC_CoreEnt or i.SC_CoreEnt != inflictor then 
			table.insert(filter, i)
			--Msg("ADDED to table: " ..tostring(i).."\n")
		else
		 	--Msg("REJECTED from table: " ..tostring(i).."\t Due to: "..tostring(i.SC_CoreEnt).."\n")
		end
	end 	
	
	local fallofftable = {}
	local hitentstable = {}
	
	for _,i in pairs(filter) do
	    local distance = (i:NearestPoint(position) - position):Length() -- New way
	    local falloff = (1 - (distance/radius))
		----Msg("=====\nFalloff: " ..tostring(falloff).."\nDistance: "..tostring(distance).."\nRadius: "..tostring(radius).."\n=====\n")
		if falloff < 0 then
			--Msg("\nWTF FALLOFF < 0!!!! "..tostring(distance).."\n\n")
			falloff = 0
			--The method above used to work fine, but garry broke it since update 43 when ents.FindInSphere was first broken
		end  	    
	    local damage_to_deal = {EM=damage.EM * falloff, EXP=damage.EXP * falloff, KIN=damage.KIN * falloff, THERM=damage.THERM * falloff}	

		                                                                  
		local tr = nil
		
		if StarGate.Installed then  --Use Stargates method of tracelines if available, since it can detect shields :)
			tr = StarGate.Trace:New(position,(i:NearestPoint(position) - position):Normalize()*distance,inflictor)
		else
			local trace = { 
				start = position,
				endpos = i:NearestPoint(position),
				filter = inflictor,
			}
			tr = util.TraceLine( trace ) 					
		end 
		
	
		--Msg("Trace Hit: "..tostring(tr.Entity).."\n")
				
		if tr.HitWorld == false and falloff > 0 then
			if tr.Entity:IsValid() and table.HasValue( SC_Shields, tr.Entity:GetClass() ) then				
	    		--SC_ApplyDamage(i, damage_to_deal, attacker, inflictor )
				--Msg("Shielded: "..tostring(i).."\n")
			else
				if i.SC_CoreEnt != nil then
					hitentstable[falloff] = i
					table.insert(fallofftable, falloff) 				
				else
					SC_ApplyDamage(i, damage_to_deal, attacker, inflictor, position )
       				--Msg("Damaging: "..tostring(i).."\n")
       			end
			end 			
		else
			--Msg("Trace Hit World, so did nothing \n")
		end	    
	end
	table.sortdesc( fallofftable ) 
	--Msg("\n==============================\n")
	--PrintTable( hitentstable )
	--Msg("==============================\n\n")
	--Msg("\n==============================\n")
	--PrintTable( fallofftable )
	--Msg("==============================\n\n")
	--All this stuff below makes it do explosion damage only for the ent that took the most damage, that way, hitting 1 massive prop or 50 wire chips deals the same damage
	local alreadyhit = {}
	for _,f in pairs(fallofftable) do 
		local test = hitentstable[f].SC_CoreEnt
		if table.HasValue(alreadyhit, test) then
			
		else
			local falloff = f
			local damage_to_deal = {EM=damage.EM * falloff, EXP=damage.EXP * falloff, KIN=damage.KIN * falloff, THERM=damage.THERM * falloff}
			table.insert(alreadyhit, test)
			SC_ApplyDamage(hitentstable[f], damage_to_deal, attacker, inflictor ) 		
			--Msg(tostring(test).."\n")
		end		
	end 	
end
    

function constraint.GetAllWeldedEntities( ent, ResultTable ) --Modded constraint.GetAllConstrainedEntities to find only welded ents

	local ResultTable = ResultTable or {}
	
	if ( !ent ) then return end
	if ( !ent:IsValid() ) then return end
	if ( ResultTable[ ent ] ) then return end
	
	ResultTable[ ent ] = ent
	
	local ConTable = constraint.GetTable( ent )
	
	for k, con in ipairs( ConTable ) do
	
		for EntNum, Ent in pairs( con.Entity ) do
			if (con.Type == "Weld") or (con.Type == "Axis") or (con.Type == "Ballsocket") or (con.Type == "Hydraulic") then
				constraint.GetAllWeldedEntities( Ent.Entity, ResultTable )
			end
		end
	
	end

	return ResultTable
	
end

function constraint.GetAllConstrainedEntities_B( ent, ResultTable ) --Modded to filter out grabbers

	local ResultTable = ResultTable or {}
	
	if ( !ent ) then return end
	if ( !ent:IsValid() ) then return end
	if ( ResultTable[ ent ] ) then return end
	
	ResultTable[ ent ] = ent
	
	local ConTable = constraint.GetTable( ent )
	
	for k, con in ipairs( ConTable ) do
	
		for EntNum, Ent in pairs( con.Entity ) do
			if con.Type != ""  then
				constraint.GetAllWeldedEntities( Ent.Entity, ResultTable )
			end
		end
	
	end

	return ResultTable
	
end

--####  Math Stuff  ####--
function  cubic_curve( a, b, c, d, X )
	return( (a*(X^3)) + (b*(X^2)) + (c*(X)) + d );
end