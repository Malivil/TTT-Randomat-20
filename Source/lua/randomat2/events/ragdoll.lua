local EVENT = {}

EVENT.Title = "Bad Trip"
EVENT.id = "ragdoll"

local t = {start=nil,endpos=nil,mask=MASK_PLAYERSOLID,filter=nil}
local ply = nil

local function PlayerNotStuck()

	t.start = ply:GetPos()
	t.endpos = t.start
	t.filter = ply
	
	return util.TraceEntity(t,ply).StartSolid == false
	
end

local function FindPassableSpace( direction, step )

	local i = 0
	while ( i < 100 ) do
		local origin = ply:GetPos()

		--origin = VectorMA( origin, step, direction )
		origin = origin + step * direction
		
		ply:SetPos( origin )
		if PlayerNotStuck( ply ) then
			NewPos = ply:GetPos()
			return true
		end
		i = i + 1
	end
	return false
end



-- 	
--	Purpose: Unstucks player
--	Note: Very expensive to call, you have been warned!
--
local function UnstuckPlayer( pl )
	ply = pl

	NewPos = ply:GetPos()
	local OldPos = NewPos
	
	if not PlayerNotStuck( ply ) then
	
		local angle = ply:GetAngles()
		
		local forward = angle:Forward()
		local right = angle:Right()
		local up = angle:Up()
		
		local SearchScale = 1 -- Increase and it will unstuck you from even harder places but with lost accuracy. Please, don't try higher values than 12

		if	not FindPassableSpace( forward, SearchScale ) and	-- forward
			not FindPassableSpace( right, SearchScale ) and  	-- right
			not FindPassableSpace( right, -SearchScale ) and 	-- left
			not FindPassableSpace( up, SearchScale ) and    	-- up
			not FindPassableSpace( up, -SearchScale ) and   	-- down
			not FindPassableSpace( forward, -SearchScale )   	-- back
		then								
			--Msg( "Can't find the world for player "..tostring(ply).."\n" )
			return false
		end
		
		if OldPos == NewPos then 
			return true -- Not stuck?
		else
			ply:SetPos( NewPos )
			if SERVER and ply and ply:IsValid() and ply:GetPhysicsObject():IsValid() then
				if ply:IsPlayer() then
					ply:SetVelocity(vector_origin)
				end
				ply:GetPhysicsObject():SetVelocity(vector_origin) -- prevents bugs :s
			end
		
			return true
		end
		
	end
	
	
end

local function unragdollPlayer( v )
	v.inRagdoll = false
	v:SetParent()

	local ragdoll = v.ragdoll
	v.ragdoll = nil -- Gotta do this before spawn or our hook catches it

	v:Spawn()

	if ragdoll:IsValid() then
		local pos = ragdoll:GetPos()
		pos.z = pos.z + 10
		v:SetPos( pos )
		v:SetVelocity( ragdoll:GetVelocity() )
		local yaw = ragdoll:GetAngles().yaw
		v:SetAngles( Angle( 0, yaw, 0 ) )
		ragdoll:DisallowDeleting( false )
		ragdoll:Remove()
	end

	v:SetHealth(v.spawnInfo.health)
	for i, j in pairs(v.spawnInfo.weps) do
		v:Give(i)
		local wep = v:GetWeapon( i )
		if v.spawnInfo.weps[i].Clip then
			wep:SetClip1(v.spawnInfo.weps[i].Clip)
		end
		v:SetAmmo(v.spawnInfo.weps[i].Reserve, wep:GetPrimaryAmmoType(), true)
		v:SelectWeapon(v.spawnInfo.activeWeapon)
	end

	
	v:SetCredits(v.spawnInfo.credits)

	for i, j in pairs(v.spawnInfo.equipment) do
		if j then
			v:GiveEquipmentItem(i)
		end
	end

	timer.Simple(0.1, function()
		if v:IsInWorld() then
			UnstuckPlayer(v) -- Thanks to SunRed on GitHub for the unstuck script
		end
	end)

end

local function ragdollPlayer( v )
	v.inRagdoll = true

	v.spawnInfo = {}

	local weps = {}
	for i, j in pairs(v:GetWeapons()) do
		weps[j.ClassName] = {}
		weps[j.ClassName].Clip = j:Clip1()
		weps[j.ClassName].Reserve = v:GetAmmoCount(j:GetPrimaryAmmoType())
	end

	local equipment = {}
	equipment[EQUIP_RADAR] = false
	equipment[EQUIP_ARMOR] = false
	equipment[EQUIP_DISGUISE] = false

	if v:HasEquipmentItem(EQUIP_RADAR) then
		equipment[EQUIP_RADAR] = true
	end
	if v:HasEquipmentItem(EQUIP_ARMOR) then
		equipment[EQUIP_ARMOR] = true
	end
	if v:HasEquipmentItem(EQUIP_DISGUISE) then
		equipment[EQUIP_DISGUISE] = true
	end

	local info = {}
	info.weps = weps
	info.activeWeapon = v:GetActiveWeapon().ClassName
	info.health = v:Health()
	info.credits = v:GetCredits()
	info.equipment = equipment
	v.spawnInfo = info
	
	local ragdoll = ents.Create( "prop_ragdoll" )
	ragdoll.ragdolledPly = v
	ragdoll:SetPos( v:GetPos() )
	local velocity = v:GetVelocity()
	ragdoll:SetAngles( v:GetAngles() )
	ragdoll:SetModel( v:GetModel() )
	ragdoll:Spawn()
	ragdoll:Activate()
	v:SetParent( ragdoll )

	for j=0, ragdoll:GetPhysicsObjectCount() -1 do
		local phys_obj = ragdoll:GetPhysicsObjectNum(j)
		phys_obj:SetVelocity(velocity)
	end

	v:Spectate( OBS_MODE_CHASE )
	v:SpectateEntity( ragdoll )
	v:StripWeapons() 

	ragdoll:DisallowDeleting( true, function( old, new )
		if v:IsValid() then v.ragdoll = new end
	end )

	v.ragdoll = ragdoll
	hook.Add("Think", v:Nick().."UnragdollTimer", function()
		if ragdoll:IsValid() then
			if ragdoll:GetPhysicsObjectNum( 1 ):GetVelocity():Length() <= 10 then
				unragdollPlayer(v)
				hook.Remove("Think", v:Nick().."UnragdollTimer")
			end
		end
	end)
end





function EVENT:Begin()
	for k, v in pairs(player.GetAll()) do
		v.inRagdoll = false
	end
	hook.Add("Think", "rdmtRagdollInAir", function()
		for k, v in pairs(self:GetAlivePlayers(true)) do
			if not v:IsOnGround() and not v.inRagdoll and v:WaterLevel() == 0 then
				ragdollPlayer(v)
			end
		end
	end)
end

function EVENT:End()
	for k, v in pairs(player.GetAll()) do
		if v.inRagdoll then
			Unragdoll(v)
			hook.Remove("Think", v:Nick().."UnragdollTimer")
		end	
	end
	hook.Remove("Think", "rdmtRagdollInAir")
end

hook.Add("EntityTakeDamage", "RdmtRagdollDMGTaken", function(ent, dmg)
	for k, v in pairs(player.GetAll()) do
		for i, j in pairs(ent:GetChildren()) do
			if j == v then
				v:TakeDamageInfo(dmg)
			end
		end
	end
end)

Randomat:register(EVENT)