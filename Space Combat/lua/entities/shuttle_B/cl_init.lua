include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
	if ( LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance( self.Entity:GetPos() ) < 512 ) then
		AddWorldTip(self.Entity:EntIndex(),"Health: "..tostring(self.Entity:GetNetworkedInt("health",0)),0.5,self.Entity:GetPos(),self.Entity)
	end
end

function sCalc( ply, origin, angles, fov )
	if not LocalPlayer().sDistz then
		LocalPlayer().sDistz=100
	end
	if LocalPlayer().sDistz<1 then LocalPlayer().sDistz=1 end
	if LocalPlayer().sDistz>1000 then LocalPlayer().sDistz=1000 end
	local shut=LocalPlayer():GetNetworkedEntity("Shuttle",LocalPlayer())
	if LocalPlayer():GetNetworkedBool("isDriveShuttle",false) and shut~=LocalPlayer() and shut:IsValid() then
		local view = {}
			view.origin = shut:GetPos()+ply:GetAimVector():GetNormal()*-LocalPlayer().sDistz
			view.angles = angles
		return view
	end
end
hook.Add("CalcView", "MyCalcView", sCalc)

function ENT:Think()
	if LocalPlayer():GetNetworkedBool("isDriveShuttle",false) then
		if LocalPlayer():KeyDown(IN_JUMP) then
			LocalPlayer().sDistz=LocalPlayer().sDistz+5
		end
		if LocalPlayer():KeyDown(IN_DUCK) then
			LocalPlayer().sDistz=LocalPlayer().sDistz-5
		end
	end
end