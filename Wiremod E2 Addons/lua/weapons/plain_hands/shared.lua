if (SERVER) then
	AddCSLuaFile("shared.lua")
	
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Plain hands"
	SWEP.Slot = 3
	SWEP.SlotPos = 1
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
end

SWEP.Author		= "TP Hunter NL"
SWEP.Contact		= "www.wiremod.com"
SWEP.Purpose		= "Useful for drawing holograms on"
SWEP.Instructions	= "Equip me and use E:setHoldType(S)"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= ""
SWEP.WorldModel			= ""

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"




function SWEP:Initialize()
	if (SERVER) then 
		self:SetWeaponHoldType("normal")
		self.animate				= true
		self.nextReload				= CurTime() + .2
	end
end

function SWEP:Reload()
	if self.nextReload < CurTime() then
		self.nextReload = CurTime() + .2
		if self.animate then 
			self.animate = false
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Your attack is no longer animated" )
		else
			self.animate = true 
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Your attack is now animated" )
		end
	end
end

function SWEP:PrimaryAttack()
	if self.animate then
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		self.Weapon:SetNextPrimaryFire(CurTime() + .5)
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
end
