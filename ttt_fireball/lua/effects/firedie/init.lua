function EFFECT:Init( data )
	
	self.Position = data:GetOrigin()
	
	local Pos = self.Position

	local emitter = ParticleEmitter( Pos )
	

		for i=1, 100 do
		
			local particle = emitter:Add( "effects/flame", Pos )

				particle:SetVelocity(Vector(math.random(-400,400),math.random(-400,400), math.random(-400,400)))
				particle:SetLifeTime(0)
				particle:SetDieTime(0.7)
				particle:SetStartAlpha(math.random(100, 255))
				particle:SetEndAlpha(0)
				particle:SetStartSize( math.random(5, 20))
				particle:SetEndSize( 0 )
				particle:SetRoll( math.Rand(360,480 ) )
				particle:SetRollDelta( math.Rand( -1, 1 ) )
				particle:SetColor( 255, 255, 255 )
				--particle:VelocityDecay( true )

			local particle = emitter:Add( "effects/flame", Pos )

				particle:SetVelocity(Vector(math.random(-500,500),math.random(-500,500), math.random(-500,500)))
				particle:SetLifeTime(0)
				particle:SetDieTime(0.7)
				particle:SetStartAlpha(math.random(100, 255))
				particle:SetEndAlpha(0)
				particle:SetStartSize(0)
				particle:SetEndSize( math.random(5, 20) )
				particle:SetRoll( math.Rand(360,480 ) )
				particle:SetRollDelta( math.Rand( -1, 1 ) )
				particle:SetColor( math.Rand(10, 80), math.Rand(10, 80), math.Rand(10, 80) )
				--particle:VelocityDecay( true )

			end

	emitter:Finish()
		end


function EFFECT:Think( )
	return false	
end


function EFFECT:Render()
end



