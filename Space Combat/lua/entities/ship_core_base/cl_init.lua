include('shared.lua')

function ENT:Think()
end

function ENT:DoNormalDraw()
	local e = self.Entity;
	if (LocalPlayer():GetEyeTrace().Entity == e and EyePos():Distance(e:GetPos()) < 1024) then
		if ( self.RenderGroup == RENDERGROUP_OPAQUE) then
			self.OldRenderGroup = self.RenderGroup
			self.RenderGroup = RENDERGROUP_TRANSLUCENT
		end
		self.Entity:DrawModel()
		if(self:GetOverlayText() ~= "") then
			AddWorldTip(e:EntIndex(),self:GetOverlayText(),0.5,e:GetPos(),e)
		end
	else
		if(self.OldRenderGroup) then
			self.RenderGroup = self.OldRenderGroup
			self.OldRenderGroup = nil
		end
		e:DrawModel()
	end
end

function ENT:DrawEntityOutline( size )
end

function sc_base_frame(data)
	local ent = data:ReadEntity()
	local test = string.Replace( ent.PrintName, "Ship Core ", "" )
	
	local frame1 = vgui.Create("DFrame")
	 
	frame1:SetPos(100,100)
	frame1:SetSize(350,400)	
	--frame1:SetTitle("Ship Info")
	frame1:SetTitle("Ship Info - "..test)	
	frame1:MakePopup()
	
	
	local PropertySheet = vgui.Create( "DPropertySheet" )
	PropertySheet:SetParent( frame1 )
	PropertySheet:SetPos( 5, 30 )
	PropertySheet:SetSize( 325, 350 )	
  	
  	
	local HPCol = vgui.Create("DListView")
	HPCol:Clear()
	HPCol:SetMultiSelect(false)
	HPCol:AddColumn("Type") 
	HPCol:AddColumn("Amount") 
	HPCol:AddColumn("Max Amount")
	HPCol:AddColumn("Percent")
	
	HPCol:AddLine("Hull", sc_ds(ent:GetNWFloat("HullHP")), sc_ds(ent:GetNWFloat("HullMAX")), (math.Round(ent:GetNWFloat("HullP")*10000)/100).."%")
	HPCol:AddLine("Armor", sc_ds(ent:GetNWFloat("ArmorHP")), sc_ds(ent:GetNWFloat("ArmorMAX")), (math.Round(ent:GetNWFloat("ArmorP")*10000)/100).."%")
	HPCol:AddLine("Shield", sc_ds(ent:GetNWFloat("ShieldHP")), sc_ds(ent:GetNWFloat("ShieldMAX")), (math.Round(ent:GetNWFloat("ShieldP")*10000)/100).."%")
	
	
	local RESCol = vgui.Create("DListView")
	RESCol:Clear()
	RESCol:SetMultiSelect(false)
	RESCol:AddColumn("") 
	RESCol:AddColumn("Hull") 
	RESCol:AddColumn("Armor")
	RESCol:AddColumn("Shield")
	
	RESCol:AddLine("EMP", (math.Round(ent:GetNWFloat("HullR1")*10000)/100).."%", (math.Round(ent:GetNWFloat("ArmorR1")*10000)/100).."%", (math.Round(ent:GetNWFloat("ShieldR1")*10000)/100).."%")
	RESCol:AddLine("Explosive", (math.Round(ent:GetNWFloat("HullR2")*10000)/100).."%", (math.Round(ent:GetNWFloat("ArmorR2")*10000)/100).."%", (math.Round(ent:GetNWFloat("ShieldR2")*10000)/100).."%")
	RESCol:AddLine("Kinetic", (math.Round(ent:GetNWFloat("HullR3")*10000)/100).."%", (math.Round(ent:GetNWFloat("ArmorR3")*10000)/100).."%", (math.Round(ent:GetNWFloat("ShieldR3")*10000)/100).."%")
	RESCol:AddLine("Thermal", (math.Round(ent:GetNWFloat("HullR4")*10000)/100).."%", (math.Round(ent:GetNWFloat("ArmorR4")*10000)/100).."%", (math.Round(ent:GetNWFloat("ShieldR4")*10000)/100).."%")
	
	
	local FITCol = vgui.Create("DListView")
	FITCol:Clear()
	FITCol:SetMultiSelect(false)
	FITCol:AddColumn("Type") 
	FITCol:AddColumn("Amount") 
	FITCol:AddColumn("Used")
	FITCol:AddColumn("Percent")
	
	FITCol:AddLine("High", ent:GetNWFloat("SlotH"), ent:GetNWFloat("SlotH_U"), (math.Round((ent:GetNWFloat("SlotH_U")/ent:GetNWFloat("SlotH"))*10000)/100).."%")
	FITCol:AddLine("Middle", ent:GetNWFloat("SlotM"), ent:GetNWFloat("SlotM_U"), (math.Round((ent:GetNWFloat("SlotM_U")/ent:GetNWFloat("SlotM"))*10000)/100).."%")
	FITCol:AddLine("Low", ent:GetNWFloat("SlotL"), ent:GetNWFloat("SlotL_U"), (math.Round((ent:GetNWFloat("SlotL_U")/ent:GetNWFloat("SlotL"))*10000)/100).."%")
	
	FITCol:AddLine("CPU", sc_ds(ent:GetNWFloat("FitCPU")), sc_ds(ent:GetNWFloat("FitCPU_U")), (math.Round((ent:GetNWFloat("FitCPU_U")/ent:GetNWFloat("FitCPU"))*10000)/100).."%")
	FITCol:AddLine("Power Grid", sc_ds(ent:GetNWFloat("FitPG")), sc_ds(ent:GetNWFloat("FitPG_U")), (math.Round((ent:GetNWFloat("FitPG_U")/ent:GetNWFloat("FitPG"))*10000)/100).."%")
	 
	  
	PropertySheet:AddSheet( "Health", HPCol, "gui/silkicons/heart", false, false, "Ship Health" )
	PropertySheet:AddSheet( "Resistance", RESCol, "gui/silkicons/shield", false, false, "Ship Resistances" )
	PropertySheet:AddSheet( "Fitting", FITCol, "gui/silkicons/wrench", false, false, "Ship Fitting" ) 	
	
end
usermessage.Hook("Ship_Core_UMSG", sc_base_frame)



