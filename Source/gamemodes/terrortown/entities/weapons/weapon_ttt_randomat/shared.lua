if SERVER then
	resource.AddWorkshop("662342819")
	AddCSLuaFile("shared.lua")
	resource.AddFile("materials/VGUI/ttt/icon_randomat.vmt")
	util.AddNetworkString("RandomatRandomWeapons")
	SWEP.LimitedStock = not GetConVar("ttt_randomat_rebuyable"):GetBool()
end

if CLIENT then
	SWEP.PrintName = "Randomat-4000"
	SWEP.Slot = 7

	SWEP.ViewModelFOV = 60
	SWEP.ViewModelFlip = false

	SWEP.Icon = "VGUI/ttt/icon_randomat"
	SWEP.EquipMenuData = {
		type = "weapon",
		desc = "The Randomat-4000 will do something Random! \nWho guessed that!"
	}

	function SWEP:PrimaryAttack() end
end

CreateConVar("ttt_randomat_chooseevent", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Allows you to choose out of a selection of events")

SWEP.ViewModel = "models/weapons/gamefreak/c_csgo_c4.mdl"
SWEP.WorldModel = "models/weapons/gamefreak/w_c4_planted.mdl"
SWEP.Weight = 2

SWEP.Base = "weapon_tttbase"
SWEP.Spawnable = true
SWEP.AutoSpawnable = false
SWEP.HoldType = "slam"
SWEP.AdminSpawnable = true
SWEP.AutoSwitchFrom = false
SWEP.AutoSwitchTo = false
SWEP.Kind = WEAPON_EQUIP2

SWEP.InLoadoutFor = nil
SWEP.AllowDrop = false
SWEP.IsSilent = false
SWEP.NoSights = true
SWEP.UseHands = true
SWEP.HeadshotMultiplier = 0
SWEP.CanBuy = { ROLE_DETECTIVE }
SWEP.AmmoEnt = nil

SWEP.Primary.Delay = 10
SWEP.Primary.Recoil = 0
SWEP.Primary.Automatic = false
SWEP.Primary.NumShots = 1
SWEP.Primary.Damage = 0
SWEP.Primary.Cone = 0
SWEP.Primary.Ammo = nil
SWEP.Primary.ClipSize = -1
SWEP.Primary.ClipMax = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Sound = ""


function SWEP:Initialize()
	util.PrecacheSound("weapons/c4_initiate.wav")
end

function SWEP:OnRemove()
	if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
		RunConsoleCommand("lastinv")
	end
end

function SWEP:PrimaryAttack()
	if SERVER and IsFirstTimePredicted() then
		if GetConVar("ttt_randomat_chooseevent"):GetBool() then
			Randomat:SilentTriggerEvent("choose", self.Owner)

		else
			Randomat:TriggerRandomEvent(self.Owner)
		end
		DamageLog("RANDOMAT: " .. self.Owner:Nick() .. " [" .. self.Owner:GetRoleString() .. "] used his Randomat")
		self:SetNextPrimaryFire(CurTime() + 10)

		self:Remove()
	end
end