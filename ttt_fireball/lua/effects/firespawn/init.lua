function EFFECT:Init( data )
	
	self.Position = data:GetOrigin()	

	local emitter = ParticleEmitter( self.Position )
	local emittersed = ParticleEmitter( self.Position )

		for i=1, 40 do	
		
			local particle = emitter:Add( "effects/flame", self.Position )

				particle:SetVelocity(Vector(math.random(-30,40),math.random(-30,40), math.random(0, 70)))
				particle:SetDieTime(math.Rand( 2, 3 ))
				particle:SetStartAlpha(230)
				particle:SetEndAlpha(0)
				particle:SetStartSize(math.random(10, 40))
				particle:SetEndSize( 0 )
				particle:SetRoll( math.Rand( 0,10  ) )
				particle:SetRollDelta(math.Rand( -0.2, 0.2 ))
				particle:SetColor( 255, 255, 255 )
				--particle:VelocityDecay( false )
			
			
			local particle = emitter:Add( "effects/flame", self.Position )

				particle:SetVelocity(Vector(math.random(-30,40),math.random(-30,40), math.random(0, 70)))
				particle:SetDieTime(math.Rand( 2,3 ))
				particle:SetStartAlpha(0)
				particle:SetEndAlpha(150)
				particle:SetStartSize(math.random(10, 40))
				particle:SetEndSize( 0 )
				particle:SetRoll( math.Rand( 0,10  ) )
				particle:SetRollDelta(math.Rand( -0.2, 0.2 ))
				particle:SetColor( math.Rand(0, 50), math.Rand(0, 50), math.Rand(0, 50) )
				--particle:VelocityDecay( false )


	end			


	emitter:Finish()
		end


function EFFECT:Think( )
	return false	
end

function EFFECT:Render()

end



