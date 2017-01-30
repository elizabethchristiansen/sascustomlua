//-----------------------------------//
//--HighSpeed E2 Support Version0.5--//
//-----------------------------------//

///Local functions, to be transplanted dynamically ;)

local function ReadCell( Address, Shifted )
	if type(Address)=="Entity" then
	if ( Shifted >= 0 and Shifted <= Address.context.data.hsmemoryamount ) then
		return Address.Memory[Shifted]
	end
	else
	if ( Address >= 0 and Address <= self.context.data.hsmemoryamount ) then
		return self.Memory[Address]
	end
	end
end

local function WriteCell( Address, Value, Shifted )
	if type(Address)=="Entity" then
	if ( Value >= 0 and Value <= Address.context.data.hsmemoryamount ) then
		Address.Memory[Value] = Shifted
		return true
	end
	else
	if ( Address >= 0 and Address <= self.context.data.hsmemoryamount ) then
		self.Memory[Address] = Value
		return true
	end
	end
end

//Exp2 Commands

registerFunction("allocMem", "n", "", function(self, args)
    local op1 = args[2]
    local rv1 = op1[1](self, op1)
	if rv1>=1 then
		if (rv1-1)>2047 then rv1=2048 end
		self.entity.Memory = {}
		for i = 0, (rv1-1) do
			self.entity.Memory[i] = 0
		end
		if !self.entity.ReadCell then
			self.entity.ReadCell = ReadCell
		end
		if !self.entity.WriteCell then
			self.entity.WriteCell = WriteCell
		end
		self.data.hsmemoryamount = rv1-1
	else
		self.entity.Memory = nil
		self.entity.ReadCell = nil
		self.entity.WriteCell = nil
		self.data.hsmemoryamount = 0
	end
end)

/*registerFunction("memoryOut", "", "n", function(self, args)
	if !self.entity.Memory then return 0 end
	return self.entity.Memory
end)*/

registerFunction("writeCell", "nn", "n", function(self, args)
	local op1, op2 = args[2], args[3]
	local rv1, rv2 = op1[1](self, op1), op2[1](self, op2)
	if !self.entity.WriteCell then return 0 end

	if self.entity:WriteCell(rv1, rv2)
	   then return 1 else return 0 end
end)

registerFunction("readCell", "n", "n", function(self, args)
	local op1 = args[2]
	local rv1 = op1[1](self, op1)
	if !self.entity.ReadCell then return 0 end
	
	local ret = self.entity:ReadCell(rv1)
	if ret then return ret else return 0 end
end)

/******************************************************************************/
registerCallback("construct", function(self)
	if self.data.hsmemoryamount != 0 then
		self.data.hsmemoryamount = 0
	end
	if self.entity.Memory then
		self.entity.Memory = nil
	end
	if self.entity.WriteCell then
		self.entity.WriteCell = nil
	end
	if self.entity.ReadCell then
		self.entity.ReadCell = nil
	end
end)