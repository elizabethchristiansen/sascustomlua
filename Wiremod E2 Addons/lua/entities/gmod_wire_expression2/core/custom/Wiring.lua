AddCSLuaFile('Wiring.lua')

/******************************************************************************\
This is the wiring addon, created by Jeremydeath , thanks to Divran for the idea :)
Call the E:createWire(E,S,S) function to create an invisible wire between the two entitys 
	E: is the input entity
	E is the output entity
	S is the name of the input of the input entity
	S is the name of the output of the output entity
	returns 1 if it succeds, 0 if it fails
Call the E:createWire(E,S,S,N,V,S) function to create an wire between the two entitys, 
	E: is the input entity
	E is the output entity
	S is the name of the input of the input entity
	S is the name of the output of the output entity
	N is the width of the wire (Clamped between 0 and 10)
	V is the color of the wire in Vector( R,G,B) form
	S is the material of the wire. (Note that you do not have to put the "cable/" or "arrowire/" extension in the material)
	returns 1 if it succeds, 0 if it fails
Call the E:deleteWire(S) function to delete wire leading to entity E:, input S
	E: is the entity
	S is the input name
Call the E:getWireInputs() function to get a string array of the inputs of the entity
	E: is the entity
	returns the inputs if it succeds, an empty array if it fails
Call the E:getWireOutputs() function to get a string array of the outputs of the entity
	E: is the entity
	returns the outputs if it succeds, an empty array if it fails
Call the E:getWireInputType(S) function to get the wire type of inputS of the entity as a string 
	E: is the entity
	S is the name of the input
	returns the input type if it succeds, an empty string if it fails
Call the E:getWireOutputType(S) function to get the wire type of output S of the entity as a string 
	E: is the entity
	S is the name of the output
	returns the output type if it succeds, an empty string if it fails
\******************************************************************************/

registerFunction("createWire", "e:ess", "n", function(self,args)
	local op1, op2, op3, op4 = args[2], args[3], args[4], args[5]
	local rv1, rv2, rv3, rv4 = op1[1](self,op1), op2[1](self,op2), op3[1](self,op3), op4[1](self,op4)
	if(!validEntity(rv1) or !validEntity(rv2)) then return 0 end 
	if((!self.player:IsAdmin() and !self.player:IsSuperAdmin()) and (!isOwner(self, rv1) or !isOwner(self, rv2))) then return 0 end
	
	local EntInput = rv1
	local EntOutput = rv2
	local Input = rv3
	local Output = rv4
	
	if (CLIENT) then return end
	
	if(!EntInput.Inputs or !EntOutput.Outputs) then return 0 end
	if(Input == "" or Output == "") then return 0 end
	if(!EntInput.Inputs[Input] or !EntOutput.Outputs[Output]) then return 0 end
	if(EntInput.Inputs[Input].Src) then
		local CheckInput = EntInput.Inputs[Input]
		if(CheckInput.SrcId == Output and CheckInput.Src == EntOutput) then return 0 end
	end
	
	Wire_Link_Start(self.player:UniqueID(), EntInput, EntInput:WorldToLocal(EntInput:GetPos()), Input, "cable/rope", Vector(255,255,255), 0)
	Wire_Link_End(self.player:UniqueID(), EntOutput, EntOutput:WorldToLocal(EntOutput:GetPos()), Output, self.player)
	
	return 1
end)

registerFunction("createWire", "e:essnvs", "n", function(self,args)
	local op1, op2, op3, op4, op5, op6, op7 = args[2], args[3], args[4], args[5], args[6], args[7] , args[8]
	local rv1, rv2, rv3, rv4, rv5, rv6, rv7 = op1[1](self,op1), op2[1](self,op2), op3[1](self,op3), op4[1](self,op4), op5[1](self,op5), op6[1](self,op6), op7[1](self,op7)
	if(!validEntity(rv1) or !validEntity(rv2)) then return 0 end
	if((!self.player:IsAdmin() and !self.player:IsSuperAdmin()) and (!isOwner(self, rv1) or !isOwner(self, rv2))) then return 0 end	
	if(!rv5 or !rv7) then return 0 end
	
	local EntInput = rv1
	local EntOutput = rv2
	local Input = rv3
	local Output = rv4
	local Width = rv5
	local Color = Vector(rv6[1],rv6[2],rv6[3])
	local WireMaterial = rv7
	
	local ValidWireMat = {"cable/rope", "cable/cable2", "cable/xbeam", "cable/redlaser", "cable/blue_elec", "cable/physbeam", "cable/hydra", "arrowire/arrowire", "arrowire/arrowire2"}
	if(!table.HasValue(ValidWireMat,WireMaterial)) then
		if(table.HasValue(ValidWireMat,"cable/"..WireMaterial)) then
			WireMaterial = "cable/"..WireMaterial
		elseif(table.HasValue(ValidWireMat,"arrowire/"..WireMaterial)) then
			WireMaterial = "arrowire/"..WireMaterial
		else
			return 0
		end
	end
	
	Width = math.Clamp(Width, 0, 10)
	
	if (CLIENT) then return end
	
	if(!EntInput.Inputs or !EntOutput.Outputs) then return 0 end
	if(Input == "" or Output == "") then return 0 end
	if(!EntInput.Inputs[Input] or !EntOutput.Outputs[Output]) then return 0 end
	if(EntInput.Inputs[Input].Src) then
		local CheckInput = EntInput.Inputs[Input]
		if(CheckInput.SrcId and CheckInput.Src == EntOutput) then return 0 end
	end
	
	Wire_Link_Start(self.player:UniqueID(), EntInput, EntInput:WorldToLocal(EntInput:GetPos()), Input, WireMaterial, Color, Width)
	Wire_Link_End(self.player:UniqueID(), EntOutput, EntOutput:WorldToLocal(EntOutput:GetPos()), Output, self.player)
	
	return 1
end)

registerFunction("deleteWire", "e:s", "n", function(self,args)
	local op1, op2 = args[2], args[3]
	local rv1, rv2 = op1[1](self,op1), op2[1](self,op2)
	if(!validEntity(rv1) or !rv2) then return 0 end
	if((!self.player:IsAdmin() and !self.player:IsSuperAdmin()) and (!isOwner(self, rv1) or !isOwner(self, rv2))) then return 0 end
	
	local TargetEnt = rv1
	local Input = rv2
	
	if(!TargetEnt.Inputs) then return 0 end
	if(Input == "") then return 0 end
	if(!TargetEnt.Inputs[Input]) then return 0 end
	if(TargetEnt.Inputs[Input].Src) then
		Wire_Link_Clear(TargetEnt, Input)
		return 1
	end
	return 0
end)
	


registerFunction("getWireInputs", "e:", "r", function(self,args)
	local op1= args[2]
	local rv1= op1[1](self,op1)
	if(!validEntity(rv1)) then return {} end
	
	local EntInput = rv1
	local InputNames = {}
	
	if(EntInput.Inputs) then
	    local WireInputs = EntInput.Inputs
		local Count = 0
		for k,v in pairs(WireInputs) do
			if(k != "") then 
				Count = Count + 1
				InputNames[Count] = k
			end
		end
		return InputNames 
	end

	return {}
end)

registerFunction("getWireOutputs", "e:", "r", function(self,args)
	local op1= args[2]
	local rv1= op1[1](self,op1)
	if(!validEntity(rv1)) then return {} end
	
	local EntOutput = rv1
	local OutputNames = {}
	
	if(EntOutput.Outputs) then
		local WireOutputs = EntOutput.Outputs
		local Count = 0
		for k,v in pairs(WireOutputs) do
			if(k != "") then 
				Count = Count + 1
				OutputNames[Count] = k
			end
		end
		return OutputNames 
	end

	return {}
end)

registerFunction("getWireInputType", "e:s", "s", function(self,args)
	local op1, op2 = args[2], args[3]
	local rv1, rv2 = op1[1](self,op1), op2[1](self,op2)
	if(!validEntity(rv1)) then return "" end
	
	local EntInput = rv1
	
	if(!EntInput.Inputs) then return "" end
	if(!EntInput.Inputs[rv2]) then return "" end
	local WireInput = EntInput.Inputs[rv2]
	local Type = WireInput.Type
	if(Type) then return Type end
	return ""
end)

registerFunction("getWireOutputType", "e:s", "s", function(self,args)
	local op1= args[2]
	local rv1= op1[1](self,op1)
	if(!validEntity(rv1)) then return "" end
	
	local EntOutput = rv1

	if(!EntOutput.Outputs) then return "" end
	if(!EntOutput.Outputs[rv2]) then return "" end
	local WireOutput = EntOutput.Outputs[rv2]
	local Type = WireOutput.Type
	if(Type) then return Type end
	return ""
end)