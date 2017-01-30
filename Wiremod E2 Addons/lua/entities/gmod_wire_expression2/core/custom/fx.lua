AddCSLuaFile('fx.lua')

function createEffectsfromE2(self,effect,pos,magnitude,angles,pos2,scale,entity)
	local exclude = {"ptorpedoimpact", "effect_explosion_scaleable", "nuke_blastwave", "nuke_blastwave_cheap", "nuke_disintegrate", "nuke_effect_air", "nuke_effect_ground", "nuke_vaporize"}
	local ent = self.entity
    if not ent.Delay then
		ent.Delay = 0
    end
	
	-- addition by daed, removed delay for admins and fixed arbitrary effect positions :)
	if self.player:IsAdmin() then ent.Delay=0 end
	if pos then pos=Vector(pos[1],pos[2],pos[3]) end
	if pos2 then pos2=Vector(pos2[1],pos2[2],pos2[3]) end
	
    if table.HasValue(exclude, effect) then return nil end
    if angles && pos2 && scale && entity && ent.Delay < CurTime() then
		fx = EffectData()
		fx:SetOrigin(pos)
		fx:SetStart(pos2)
		fx:SetMagnitude(magnitude)
		fx:SetAngle(Angle(angles[1], angles[2], angles[3]))
		fx:SetScale(scale)
		fx:SetEntity(entity)
		util.Effect(effect,fx)
		ent.Delay = CurTime() + 0.5
    elseif !angles && !pos2 && !scale && !entity && ent.Delay < CurTime() then
		fx = EffectData()
		fx:SetOrigin(pos)
		fx:SetMagnitude(magnitude)
		util.Effect(effect,fx)
		ent.Delay = CurTime() + 0.5
    elseif !pos2 && !scale && !entity && ent.Delay < CurTime() then
		fx = EffectData()
		fx:SetOrigin(pos)
		fx:SetMagnitude(magnitude)
		fx:SetAngle(Angle(angles[1], angles[2], angles[3]))
		util.Effect(effect,fx)
		ent.Delay = CurTime() + 0.5
	elseif !scale && !entity && ent.Delay < CurTime() then
		fx = EffectData()
		fx:SetOrigin(pos)
		fx:SetMagnitude(magnitude)
		fx:SetAngle(Angle(angles[1], angles[2], angles[3]))
		fx:SetStart(pos2)
		util.Effect(effect,fx)
		ent.Delay = CurTime() + 0.5
	elseif !entity && ent.Delay < CurTime() then
		fx = EffectData()
		fx:SetOrigin(pos)
		fx:SetMagnitude(magnitude)
		fx:SetAngle(Angle(angles[1], angles[2], angles[3]))
		fx:SetStart(pos2)
		fx:SetScale(scale)
		util.Effect(effect,fx)
		ent.Delay = CurTime() + 0.5
    end
    return fx   
end

function createParticle(self,effect,entity)
	local Ent = self.entity
	local MaxParticles = 5
	
    if not Ent.Count then
		Ent.Count = 0
    end
    
	if effect == "finish" then
		if Ent.Count > 0 then
			Ent:StopParticles()
			Ent.Count = 0
		end
		
		return nil
	elseif not entity && Ent.Count < MaxParticles then
        ParticleEffectAttach(effect,PATTACH_ABSORIGIN_FOLLOW,Ent,0)
        Ent.Count = Ent.Count + 1
    elseif entity && Ent.Count < MaxParticles then
        ParticleEffectAttach(effect,PATTACH_ABSORIGIN_FOLLOW,entity,0)
        Ent.Count = Ent.Count + 1
    end
    return Particle
end

       
e2function void particle(string effect)
    return createParticle(self,effect)
 end
e2function void particle(string effect, entity entity)
    return createParticle(self,effect,entity)
 end
                
e2function void fx(string effect, vector pos, number magnitude)
    return createEffectsfromE2(self,effect,pos,magnitude)
end

e2function void fx(string effect, vector pos, number magnitude, angle angles)
    return createEffectsfromE2(self,effect,pos,magnitude,angles)
end

e2function void fx(string effect, vector pos, number magnitude, angle angles,vector pos2)
    return createEffectsfromE2(self,effect,pos,magnitude,angles,pos2)
end

e2function void fx(string effect, vector pos, number magnitude, angle angles,vector pos2,number scale)
    return createEffectsfromE2(self,effect,pos,magnitude,angles,pos2,scale)
end
	
e2function void fx(string effect, vector pos, number magnitude, angle angles,vector pos2,number scale,entity entity)
    return createEffectsfromE2(self,effect,pos,magnitude,angles,pos2,scale,entity)
end