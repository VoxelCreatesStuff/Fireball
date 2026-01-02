
if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )	
	
	
end

CreateConVar("ttt_fire_magic_ammo", 20, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "How much ammo should the Fireball have? (def. 20)")
CreateConVar("ttt_fire_magic_radius", 128, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Radius for the fire damage?(def. 128)")
CreateConVar("ttt_fire_magic_max_burn", 7, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Maximum time players will be burning (def. 5)")
CreateConVar("ttt_fire_magic_bounces", 0, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "How many times the fireballs can bounce before exploding. -1 for infinite bounces. (def. 0)")
CreateConVar("ttt_fire_magic_delay", 0.6, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "How long the delay between shots should be (def. 0.5)")
CreateConVar("ttt_fire_magic_damage", 20, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "How much damage a direct impact should deal (def. 15)")
CreateConVar("ttt_fire_magic_speed", 10000, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "How fast the Fireballs should be shot (def. 10000)")
CreateConVar("ttt_fire_magic_trail", 1, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Whether the user should have a trail or not (def. 1)")

if CLIENT then
	SWEP.PrintName       = "Fireball"
	SWEP.Author			= "Edited by Redhat2010"
	SWEP.Contact			= "";
	SWEP.Instructions	= "Throw fire"
	SWEP.Slot = 0
	SWEP.SlotPos = 1
	SWEP.IconLetter		= "M"
end

	SWEP.Base = "weapon_tttbase"
	SWEP.InLoadoutFor = nil
	SWEP.AllowDrop = true
	SWEP.IsSilent = false
	SWEP.NoSights = false
	SWEP.LimitedStock = true

	SWEP.Spawnable = true
	SWEP.AdminOnly = false
	
--SWEP.Kind = 42
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.AutoSpawnable = false
	
SWEP.ViewModel	= "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel	= ""

SWEP.HoldType		= "pistol"
	--SWEP.ViewModel  = "models/weapons/v_pist_deagle.mdl"
	--SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
	SWEP.Kind = 42
	SWEP.CanBuy = { ROLE_TRAITOR }
	SWEP.AutoSpawnable = false

--SWEP.ViewModelFOV	= 52
--SWEP.Slot			= 0
--SWEP.SlotPos		= 5

SWEP.Weight					= 7
	SWEP.DrawAmmo				= true

SWEP.Primary.Delay				= GetConVar("ttt_fire_magic_delay"):GetFloat()
SWEP.Primary.Recoil				= 0
SWEP.Primary.Damage				= 0
SWEP.Primary.NumShots			= 0
SWEP.Primary.Cone				= 0	
SWEP.Primary.ClipSize			= GetConVar("ttt_fire_magic_ammo"):GetInt()
SWEP.Primary.ClipMax			= GetConVar("ttt_fire_magic_ammo"):GetInt()
SWEP.Primary.DefaultClip		= GetConVar("ttt_fire_magic_ammo"):GetInt()
SWEP.Primary.Automatic   		= false
SWEP.Primary.Ammo         		= "none"

SWEP.Secondary.Delay			= GetConVar("ttt_fire_magic_delay"):GetFloat()
SWEP.Secondary.Recoil			= 0
SWEP.Secondary.Damage			= 0
SWEP.Secondary.NumShots			= 0
SWEP.Secondary.Cone		  		= 0
SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Automatic   		= false
SWEP.Secondary.Ammo         	= "none"

SWEP.IgniteProps = {}

SWEP.MakeFireBall = 0
SWEP.MakeFireBallDel = CurTime()

SWEP.PhysBall = NULL

SWEP.BallPos   = 0
SWEP.SecDelay  = CurTime()
SWEP.PrimDelay = CurTime()
SWEP.ReloadDelay = CurTime()

SWEP.FireEffect = CurTime()
SWEP.FireDie    = 0

SWEP.ShootFireBall = 0

SWEP.Ball = NULL

SWEP.ColorR = 255
SWEP.ColorG = 255
SWEP.ColorB = 5

SWEP.PlyHealth = NULL
SWEP.WepUse = 1

SWEP.SecAttack = 0

SWEP.FireTrail = false

function SWEP:Precache()
util.PrecacheSound("ambient/fire/ignite.wav")
util.PrecacheSound("ambient/fire/mtov_flame2.wav")
util.PrecacheSound("fireball/fireball.wav")
end

function SWEP:Initialize()

	if (SERVER) then
        self:SetWeaponHoldType( "fist" )
	end

end

function SWEP:Think()

	local vm = self.Owner:GetViewModel()
	local curtime = CurTime()
	local idletime = self:GetNextIdle()
	
	if ( idletime > 0 && CurTime() > idletime ) then

		vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_idle_0" .. math.random( 1, 2 ) ) )
		
		self:UpdateNextIdle()

	end


	if self.WepUse == 1 then

			self.Weapon:EmitSound("ambient/fire/ignite.wav")

			local effectdata = EffectData()
			effectdata:SetOrigin( self.Owner:GetPos() )			
			util.Effect( "FireSpawn", effectdata )
			self.WepUse = 0
	end 
------------GUIDING FIREBALL
	if self.Owner:KeyDown(IN_USE) == true and  self.MakeFireBall == 1 then

	if (SERVER) then

	local trace = {}
	trace.start = self.Owner:GetShootPos()
	trace.endpos = trace.start + (self.Owner:GetAimVector() * 99999)
	trace.filter = { self.Owner, self.Weaponm,}
	local tr = util.TraceLine( trace )
	local NotFireball = tr.Entity

		if self.Ball ~= NotFireball then


			local tr = util.GetPlayerTrace( self.Owner )
			local trace = util.TraceLine( tr )
			if (!trace.Hit) then return end


				local Vec = trace.HitPos - self.Ball:GetPos()
				Vec:Normalize()

				local speed = self.Ball:GetPhysicsObject():GetVelocity()
				self.Ball:GetPhysicsObject():SetVelocity( (Vec *20) + speed )
			end
		end
	end
------------------------GUIDING FIRE BALL END

	if self.ShootFireBall == 100 then --and self.MakeFireBallDel < CurTime() then

		self.ShootFireBall = 0
		self.MakeFireBall = 1
		local fball = ents.Create("prop_physics")
		self.Ball = fball
		self.Ball:SetModel("models/dav0r/hoverball.mdl")				
		self.Ball:SetAngles(self.Owner:EyeAngles())
		self.Ball:SetPos(self.Owner:GetShootPos()+(self.Owner:GetAimVector()*20))
		self.Ball:SetOwner(self.Owner)
		self.Ball:SetPhysicsAttacker(self.Owner)			
		self.Ball:SetMaterial("models/debug/debugwhite")
		self.Ball:SetName("Fireball")
		--self.Ball:PhysicsCollide( data, phys )
		local function CollisionEffect(ent, data)
				self.Ball:EmitSound("ambient/fire/ignite.wav")
				local effectdata2 = EffectData()
				effectdata2:SetOrigin( self.Ball:GetPos() )
				util.Effect( "FireExplosion", effectdata2 ) 
				local dist = GetConVar("ttt_fire_magic_radius"):GetInt()
				local IgnitePlayers = ents.FindInSphere( self.Ball:GetPos(), dist)
				if data.HitEntity:IsPlayer() then
					local d = DamageInfo()
					d:SetDamage( 10 )
					d:SetAttacker( self.Owner )
					d:SetDamageType( DMG_BURN ) 
					data.HitEntity:TakeDamageInfo(d)
				end
				for k, v in pairs(IgnitePlayers) do
					
					if v:GetName() == "Fireball" then
						
					elseif string.find(v:GetClass(), "prop_physics") or string.find(v:GetClass(), "prop_vehicle_*") or string.find(v:GetClass(), "prop_ragdoll") or string.find(v:GetClass(), "npc_*") or v:IsPlayer() then
						
					--if v:IsPlayer() then
					--print(Ignited[v:GetPos()])
						local distSqr = dist * dist
					--if not Ignited[v:GetPos()] then
						local burnTime = ((distSqr - v:GetPos():DistToSqr(self.Ball:GetPos())))
						--print(v:GetName())
						--print( 10 * burnTime / distSqr)
						v:Ignite(GetConVar("ttt_fire_magic_max_burn"):GetInt() * burnTime / distSqr , 1)
					--	Ignited[v:GetPos()] = true
					--end
					--print(Ignited[v:GetPos()])w
					end
				end
				timer.Stop("FireBallTmr")
				self.Ball:Remove()
		end
		self.Ball:AddCallback("PhysicsCollide",CollisionEffect)
		self.Ball:Spawn()
		self.PhysBall = self.Ball:GetPhysicsObject()
		self.Ball:EmitSound("fireball/fireball.wav")
		self.PhysBall:SetMass(10)
		self.PhysBall:ApplyForceCenter(self.Owner:GetAimVector() * 20000)
		self.Ball:Fire("kill", "", 2)		
		self.FireEffect  = CurTime()+2
		timer.Create("FireBallTmr",0.1,0,function() 
			local effectdata4 = EffectData()
			effectdata4:SetOrigin( self.Ball:GetPos() )
			util.Effect( "FireBall", effectdata4 ) 
		end)
		
	end
---------
	if (self.FireEffect - 1.8) < CurTime() and self.Ball ~= nil and self.Ball ~= NULL then end--self.Ball:Ignite( 20, 1000 ) end

	if  self.FireEffect > CurTime() and self.Ball ~= nil and self.Ball ~= NULL then

		--self.BallPos = self.PhysBall:GetPos()					
		local effectdata = EffectData()
		effectdata:SetOrigin( self.Ball:GetPos() )			
		util.Effect( "FireSpawn", effectdata )
			
		self.Ball:SetColor(Color(255, 153, 0, 0))
		IgniteProps = ents.FindInSphere( self.Ball:GetPos(), 50)

		for i=1,100 do 
			if IgniteProps[i] ~= nil and IgniteProps[i] ~= NULL and IgniteProps[i] ~= self.Owner then
				if string.find(IgniteProps[i]:GetClass(), "prop_physics") or string.find(IgniteProps[i]:GetClass(), "prop_vehicle_*") or string.find(IgniteProps[i]:GetClass(), "prop_ragdoll") or string.find(IgniteProps[i]:GetClass(), "npc_*")then
					--IgniteProps[i]:Ignite( 5, 50)
				end
			end
		end
	end
-------------
	if CurTime() > (self.FireEffect-0.3) and self.MakeFireBall==1 and self.Ball:IsValid() then  end
	if CurTime() > (self.FireEffect-0.2) and self.MakeFireBall==1 and self.Ball:IsValid() then self.FireDie = self.FireDie+1 end

		if self.FireDie == 100  and self.Ball ~= nil and self.Ball ~= NULL then			
			
			self.Weapon:EmitSound("ambient/fire/ignite.wav")
			--local effectdata3 = EffectData()
			--effectdata3:SetOrigin( self.Ball:GetPos() )			
			--util.Effect( "FireExplosion", effectdata3 )
			
			self.MakeFireBall = 0			
			self.FireDie = 20
			self.Ball:EmitSound("ambient/fire/ignite.wav")
			--print(self.Ball:GetPos())
			timer.Create("FireExplodeTmr",0.1,2,function() 
				self.Ball:EmitSound("ambient/fire/ignite.wav")
				local effectdata2 = EffectData()
				effectdata2:SetOrigin( self.Ball:GetPos() )
				util.Effect( "FireExplosion", effectdata2 ) 
				
				--StartFires(self.Ball:GetPos(), tr, 10, 20, false, self.Owner)
				--local effectdata3 = EffectData()
				--effectdata3:SetOrigin( self.Ball:GetPos() )
				--util.Effect( "FireSpawn", effectdata3 )
				--IgniteProps = ents.FindInSphere( self.Ball:GetPos(), 256)
				--IgniteProps = ents.FindInSphere( self.Ball:GetPos(), 256)
				--for i=1,IgniteProps.Count() do 
				--	if IgniteProps[i] ~= nil and IgniteProps[i] ~= NULL then
				--		print(i)
				--		print(IgniteProps[i]:GetPos())
				--		print(self.Owner:GetPos())
				--		IgniteProps[i]:Ignite( 1, 30)
				--	end
				--end
				local dist = GetConVar("ttt_fire_magic_radius"):GetInt()
				util.BlastDamage(self, self.Owner, self.Ball:GetPos(), dist, 5)
				local IgnitePlayers = ents.FindInSphere( self.Ball:GetPos(), dist)
				for k, v in pairs(IgnitePlayers) do
					
					if v:GetName() == "Fireball" then
						
					elseif string.find(v:GetClass(), "prop_physics") or string.find(v:GetClass(), "prop_vehicle_*") or string.find(v:GetClass(), "prop_ragdoll") or string.find(v:GetClass(), "npc_*") or v:IsPlayer() then
						
					--if v:IsPlayer() then
					--print(Ignited[v:GetPos()])
						local distSqr = dist * dist
					--if not Ignited[v:GetPos()] then
						local burnTime = ((distSqr - v:GetPos():DistToSqr(self.Ball:GetPos())))
						print(v:GetName())
						print( 10 * burnTime / distSqr)
						v:Ignite(GetConVar("ttt_fire_magic_max_burn"):GetInt() * burnTime / distSqr , 1)
					--	Ignited[v:GetPos()] = true
					--end
					--print(Ignited[v:GetPos()])w
					end
				end
				timer.Stop("FireExplodeTmr")
			end)
			timer.Stop("FireBallTmr")
			--timer.Stop("FireBallTmr2")
			
											
			
			--self.Ball:Ignite(10,1000)
			--for k, v in IgniteProps do
			--	v:Ignite(10,30)
			--end
			
			--IgniteProps = ents.FindInSphere( self.Ball:GetPos(), 256)
			--for i=1,4 do 
				--if IgniteProps[i] ~= nil and IgniteProps[i] ~= NULL then
			--		print(i)
			--		print(IgniteProps[i]:GetPos())
			--		print(self.Owner:GetPos())
					--IgniteProps[i]:Ignite( 1, 30)
				--end
			--end
			
			
			
			--local FireExp = ents.Create("env_explosion")
			--FireExp:SetPos(self.Ball:GetPos())
			--FireExp:SetKeyValue("magnitude", 200)
			--FireExp:SetKeyValue("radius", 200)
			--FireExp:SetKeyValue("spawnflags", "1")
			--FireExp:Spawn()
			--FireExp:Fire("Explode", "", 0)
			--FireExp:Fire("kill", "", 1)
		end
--------------------
	if self.SecAttack == 1 then

			self.SecAttack = 0

			self.Weapon:EmitSound("ambient/fire/ignite.wav")
			local effectdata = EffectData()
			effectdata:SetOrigin( self.Owner:GetPos() )			
			util.Effect( "FireExplosion", effectdata )
		
				IgniteProps = ents.FindInSphere( self.Owner:GetPos(), 200)
				
	if ( CLIENT ) then return end
			--local FireExp = ents.Create("env_physexplosion")
			--FireExp:SetPos(self.Owner:GetPos())
			--FireExp:SetParent(self.Owner)
			--FireExp:SetKeyValue("magnitude", 200)
			--FireExp:SetKeyValue("radius", 500)
			--FireExp:SetKeyValue("spawnflags", "1")
			--FireExp:Spawn()
			--FireExp:Fire("Explode", "", 0)
			--FireExp:Fire("kill", "", 2)

				for i=1,100 do 

					if IgniteProps[i] ~= nil and IgniteProps[i] ~= NULL then
						if string.find(IgniteProps[i]:GetClass(), "prop_physics") or string.find(IgniteProps[i]:GetClass(), "prop_vehicle_*") or string.find(IgniteProps[i]:GetClass(), "prop_ragdoll") or string.find(IgniteProps[i]:GetClass(), "npc_*")then
							--IgniteProps[i]:Ignite( 20, 10)
						end
					end	
			    end
	end
-----------------
	--timer.Create("FireTrailTmr",1,0,function() FireTrailSpawn(self.Owner) end) 
	--if self.FireTrail >= CurTime() then
		--local effectdata = EffectData()
		--effectdata:SetOrigin( self.Owner:GetPos() )			
		--util.Effect( "FireSpawn", effectdata )
			--local effectdata = EffectData()
			--effectdata:SetOrigin( self.Owner:GetPos() )			
			--util.Effect( "FireTrail", effectdata )
	--end
-----------------
end -- End of Think

function FireTrailSpawn(owner)
	--if CLIENT then end
	if GetConVar("ttt_fire_magic_trail"):GetBool() then
		local effectdata = EffectData()
		effectdata:SetOrigin( owner:GetPos() )			
		util.Effect( "FireTrail", effectdata )
	end
	--print("Timer")
end



function SWEP:Initialize()

	self:SetWeaponHoldType( "fist" )

end

function SWEP:PreDrawViewModel( vm, wep, ply )

	vm:SetMaterial( "engine/occlusionproxy" ) -- Hide that view model with hacky material

end

SWEP.HitDistance = 48

function SWEP:SetupDataTables()
	
	self:NetworkVar( "Float", 0, "NextMeleeAttack" )
	self:NetworkVar( "Float", 1, "NextIdle" )
	self:NetworkVar( "Int", 2, "Combo" )
	
end

function SWEP:UpdateNextIdle()

	local vm = self.Owner:GetViewModel()
	self:SetNextIdle( CurTime() + vm:SequenceDuration() )
	
end

function SWEP:PrimaryAttack( right )

	if self:Clip1() > 0 then
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		local anim = "fists_left"
		if ( right ) then anim = "fists_right" end
		if ( self:GetCombo() >= 2 ) then
			anim = "fists_uppercut"
		end
		
		--self.Weapon:EmitSound("ambient/fire/ignite.wav")

		local effectdata = EffectData()
		effectdata:SetOrigin( self.Owner:GetPos() )			
		util.Effect( "FireSpawn", effectdata )

		local vm = self.Owner:GetViewModel()
		vm:SendViewModelMatchingSequence( vm:LookupSequence( anim ) )

		self:UpdateNextIdle()
		self:SetNextMeleeAttack( CurTime() + self.Primary.Delay )
		
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay  )
		self:SetNextSecondaryFire( CurTime() + self.Primary.Delay  )

		if true then --self.PrimDelay < CurTime() then		
			self.PrimDelay = CurTime()+2.5


			if SERVER then	
				
				self.Weapon:EmitSound("ambient/fire/mtov_flame2.wav")		
						--self.ShootFireBall = 1
						self:MakeFireball()
						self.FireDie = 0		
						self.MakeFireBallDel = CurTime()+0.3

			end
		end

		local anim = "fists_left"
		if ( right ) then anim = "fists_right" end
		if ( self:GetCombo() >= 2 ) then
			anim = "fists_uppercut"
		end
		self:TakePrimaryAmmo(1)
		if self:Clip1() <= 0 then
			self:EmitSound( "Weapon_AR2.Empty" )
			if SERVER then 
				self:Remove()
			end
		end
	else
		self:EmitSound( "Weapon_AR2.Empty" )
		if SERVER then 
			self:Remove()
		end
	end

end

function SWEP:MakeFireball()
	local fball = ents.Create("prop_physics")
		--fball = fball
		fball:SetModel("models/dav0r/hoverball.mdl")				
		fball:SetAngles(self.Owner:EyeAngles())
		fball:SetPos(self.Owner:GetShootPos()+(self.Owner:GetAimVector()*20))
		fball:SetOwner(self.Owner)
		fball:SetPhysicsAttacker(self.Owner)			
		fball:SetMaterial("models/debug/debugwhite")
		fball:SetName("Fireball")
		fball.Time = CurTime()
		fball.bounces = 0
		--print(fball:GetElasticity())
		fball:SetElasticity(-1)
		--fball:PhysicsCollide( data, phys )
		local function CollisionEffect(ent, data)
			if fball.bounces < GetConVar("ttt_fire_magic_bounces"):GetInt() and not data.HitEntity:IsPlayer() then
				fball.bounces = fball.bounces + 1
			elseif GetConVar("ttt_fire_magic_bounces"):GetInt() == -1 and not data.HitEntity:IsPlayer() then
				
			else
				fball:EmitSound("ambient/fire/ignite.wav")
				local effectdata2 = EffectData()
				effectdata2:SetOrigin( fball:GetPos() )
				util.Effect( "FireExplosion", effectdata2 ) 
				local dist = GetConVar("ttt_fire_magic_radius"):GetInt()
				local IgnitePlayers = ents.FindInSphere( fball:GetPos(), dist)
				if data.HitEntity:IsPlayer() then
					local d = DamageInfo()
					d:SetDamage( GetConVar("ttt_fire_magic_damage"):GetInt() )
					d:SetAttacker( self.Owner )
					d:SetDamageType( DMG_BURN ) 
					data.HitEntity:TakeDamageInfo(d)
				end
				for k, v in pairs(IgnitePlayers) do
					
					if v:GetName() == "Fireball" then
						
					elseif string.find(v:GetClass(), "prop_physics") or string.find(v:GetClass(), "prop_vehicle_*") or string.find(v:GetClass(), "prop_ragdoll") or string.find(v:GetClass(), "npc_*") or v:IsPlayer() then
						
					--if v:IsPlayer() then
					--print(Ignited[v:GetPos()])
						local distSqr = dist * dist
					--if not Ignited[v:GetPos()] then
						local burnTime = ((distSqr - v:GetPos():DistToSqr(fball:GetPos())))
						--print(v:GetName())
						--print( 10 * burnTime / distSqr)
						v:Ignite(GetConVar("ttt_fire_magic_max_burn"):GetInt() * burnTime / distSqr , 1)
					--	Ignited[v:GetPos()] = true
					--end
					--print(Ignited[v:GetPos()])w
					end
				end
				timer.Stop("FireBallTmr"..fball.Time)
				timer.Stop("FireBallLife"..fball.Time)
				fball:Remove()
			end
		end
		fball:AddCallback("PhysicsCollide",CollisionEffect)
		fball:Spawn()
		self.PhysBall = fball:GetPhysicsObject()
		fball:SetColor(Color(255, 153, 0, 0))
		fball:EmitSound("fireball/fireball.wav")
		self.PhysBall:SetMass(10)
		self.PhysBall:ApplyForceCenter(self.Owner:GetAimVector() * GetConVar("ttt_fire_magic_speed"):GetInt())
		fball:Fire("kill", "", 2)		
		self.FireEffect  = CurTime()+2
		timer.Create("FireBallTmr"..fball.Time,0.1,0,function() 
			if fball:IsValid() then
				local effectdata4 = EffectData()
				effectdata4:SetOrigin( fball:GetPos() )
				util.Effect( "FireBall", effectdata4 )
			end
		end)
		timer.Create("FireBallLife"..fball.Time,2,1,function() 
			fball:EmitSound("ambient/fire/ignite.wav")
				local effectdata2 = EffectData()
				effectdata2:SetOrigin( fball:GetPos() )
				util.Effect( "FireExplosion", effectdata2 ) 
				local dist = GetConVar("ttt_fire_magic_radius"):GetInt()
				local IgnitePlayers = ents.FindInSphere( fball:GetPos(), dist)
				for k, v in pairs(IgnitePlayers) do
					
					if v:GetName() == "Fireball" then
						
					elseif string.find(v:GetClass(), "prop_physics") or string.find(v:GetClass(), "prop_vehicle_*") or string.find(v:GetClass(), "prop_ragdoll") or string.find(v:GetClass(), "npc_*") or v:IsPlayer() then
						
					--if v:IsPlayer() then
					--print(Ignited[v:GetPos()])
						local distSqr = dist * dist
					--if not Ignited[v:GetPos()] then
						local burnTime = ((distSqr - v:GetPos():DistToSqr(fball:GetPos())))
						--print(v:GetName())
						--print( 10 * burnTime / distSqr)
						v:Ignite(GetConVar("ttt_fire_magic_max_burn"):GetInt() * burnTime / distSqr , 1)
					--	Ignited[v:GetPos()] = true
					--end
					--print(Ignited[v:GetPos()])w
					end
				end
				fball:Remove()
				timer.Stop("FireBallTmr")
				timer.Stop("FireBallLife")
				fball:Remove() 
		end)
	end

function SWEP:SecondaryAttack()
	if self:Clip1() > 0 then
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		local anim = "fists_left"
		if ( right ) then anim = "fists_right" end
		if ( self:GetCombo() >= 2 ) then
			anim = "fists_uppercut"
		end
		
		--self.Weapon:EmitSound("ambient/fire/ignite.wav")

		local effectdata = EffectData()
		effectdata:SetOrigin( self.Owner:GetPos() )			
		util.Effect( "FireSpawn", effectdata )

		local vm = self.Owner:GetViewModel()
		vm:SendViewModelMatchingSequence( vm:LookupSequence( anim ) )

		self:UpdateNextIdle()
		self:SetNextMeleeAttack( CurTime() + self.Primary.Delay )
		
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )

		if true then --self.PrimDelay < CurTime() then		
			self.PrimDelay = CurTime()+2.5


			if SERVER then	
				
				self.Weapon:EmitSound("ambient/fire/mtov_flame2.wav")		
						--self.ShootFireBall = 1
						self:MakeFireball()
						self.FireDie = 0		
						self.MakeFireBallDel = CurTime()+0.3

			end
		end

		local anim = "fists_left"
		if ( right ) then anim = "fists_right" end
		if ( self:GetCombo() >= 2 ) then
			anim = "fists_uppercut"
		end
		self:TakePrimaryAmmo(1)
		if self:Clip1() <= 0 then
			self:EmitSound( "Weapon_AR2.Empty" )
			self:Remove()
		end
	else
		self:EmitSound( "Weapon_AR2.Empty" )
		self:Remove()
	end
	--if self:Clip1() > 0 then
		--if self.SecDelay < CurTime() then		
		--	self.SecDelay = CurTime() + 4		

		--self.Owner:SetAnimation( PLAYER_ATTACK1 )
		--self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )

		--		self.SecAttack = 1
		--end

		--self:PrimaryAttack( true )
		--self:TakePrimaryAmmo(1)
	--else
		--self:EmitSound( "Weapon_AR2.Empty" )
	--end

end


function SWEP:Reload()
	--if self.ReloadDelay < CurTime() then
	--	self.ReloadDelay = CurTime()+2
	--	self.Weapon:EmitSound("ambient/fire/mtov_flame2.wav")
	--	self.FireTrail = CurTime() + 1
	--	self.Owner:SetVelocity(Vector( 0, 0, 400))
	--end
	return false
end 

function SWEP:OnRemove()
	timer.Stop("FireTrailTmr")
	self.FireTrail = false
	if ( IsValid( self.Owner ) ) then
		local vm = self.Owner:GetViewModel()
		if ( IsValid( vm ) ) then vm:SetMaterial( "" ) end
	end
	
end

function SWEP:Holster( wep )

	self:OnRemove()

	return true

end



function SWEP:Deploy()

	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_draw" ) )
	if not self.FireTrail then
		timer.Create("FireTrailTmr",0.1,0,function() FireTrailSpawn(self.Owner) end)
		self.FireTrail = true
	end
	self:UpdateNextIdle()
	
	if ( SERVER ) then
		self:SetCombo( 0 )
	end
	
	return true

end

if CLIENT then
   -- Path to the icon material
   SWEP.Icon = "fireball.png"

   -- Text shown in the equip menu
	SWEP.EquipMenuData = {
	  type = "Weapon",
	  desc = "Throw fireballs at your enemies!"
	 };
end

