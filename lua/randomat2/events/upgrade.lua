local EVENT = {}

EVENT.Title = "An innocent has been upgraded!"
EVENT.id = "upgrade"

util.AddNetworkString("UpgradeEventBegin")
util.AddNetworkString("RdmtCloseUpgradeFrame")
util.AddNetworkString("rdmtPlayerChoseSur")
util.AddNetworkString("rdmtPlayerChoseSk")
CreateConVar("randomat_upgrade_chooserole", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether the innocent should choose their new role.")
	
function EVENT:Begin()
	local k = 0

	for i, ply in RandomPairs(self:GetAlivePlayers(true)) do
		if ply:GetRole() == ROLE_INNOCENT or ply:GetRole() == ROLE_PHANTOM then
			if k == 0 then
				if GetConVar("randomat_upgrade_chooserole"):GetBool() then
					net.Start("UpgradeEventBegin")
					net.Send(ply)
				else
					ply:SetRole(ROLE_MERCENARY)
					ply:SetCredits(GetConVar("ttt_mer_credits_starting"):GetInt())
					SendFullStateUpdate()
					k = 1
				end
			end
		end
	end
end

function EVENT:End()
	net.Start("RdmtCloseUpgradeFrame")
	net.Broadcast()
end

function EVENT:Condition()
	local s = 0
    local i = 0
    local sk = 0
	for k, v in pairs(self:GetAlivePlayers()) do
		if v:GetRole() == ROLE_MERCENARY then
			s = 1
		elseif v:GetRole() == ROLE_KILLER then
			sk = 1
		elseif v:GetRole() == ROLE_INNOCENT then
			i = 1
		end
	end
	if s == 0 and sk == 0 and i == 1 then
		return true
	else
		return false
	end
end

net.Receive("rdmtPlayerChoseSk", function()
	local v = net.ReadEntity()
	v:SetRole(ROLE_KILLER)
	SendFullStateUpdate()
	v:SetCredits(GetConVar("ttt_kil_credits_starting"):GetInt())
	v:StripWeapon("weapon_zm_improvised")
	v:Give("weapon_kil_knife")
end)

net.Receive("rdmtPlayerChoseSur", function()
	local v = net.ReadEntity()
	v:SetRole(ROLE_MERCENARY)
	SendFullStateUpdate()
	v:SetCredits(GetConVar("ttt_mer_credits_starting"):GetInt())
end)

Randomat:register(EVENT)