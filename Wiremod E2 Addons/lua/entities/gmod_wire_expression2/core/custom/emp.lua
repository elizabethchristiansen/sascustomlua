local EMP_IGNORE_INPUTS = { Kill=true , Pod=true , Eject=true , Lock=true , Terminate = true, Brake = true };
EMP_IGNORE_INPUTS["Damage Armor"]=true;
EMP_IGNORE_INPUTS["Strip weapons"]=true;
EMP_IGNORE_INPUTS["Damage Health"]=true;

e2function void createEMPField(number status, number empnum, number range, vector pos)
	local reqaccess = GetConVar( "access_emp" ):GetInt()
	local plyaccess = self.player:GetNWInt( "accesslevel" )	
		
	if plyaccess >= reqaccess then
	
		local targets = ents.FindInSphere( pos, range )
		
		local te = { }

		for k, v in pairs( targets ) do
			
			if(v != self.entity) then
				if ( ValidEntity(v) and v.Inputs and v:GetClass() != "gmod_wire_numpad" ) then
					table.insert( te, v )
				end
			end
		end
		
		for _, i in pairs(te) do
			if i:GetClass() == "gmod_wire_expression2" then
				if !i.e2jam then i.e2jam = 0 end
				if status == 0 then
					i:Reset()
					i.e2jam = 0
				elseif (status != 0 and i.e2jam == 0) then
					i:Error("E2 EMP Interference Detected", "EMP Interference")
					i.e2jam = 1
				end
			else
				for k, v in pairs(i.Inputs) do
				
					if EMP_IGNORE_INPUTS[k] == nil then
							
						if v.Type == "NORMAL" then
							if status == 0 then
								i:TriggerInput(k, i.Inputs[ k ].Value )
							else
								if empnum == 0 then
									i:TriggerInput( k, ( math.abs(i.Inputs[ k ].Value) - math.abs(i.Inputs[ k ].Value) ) )
								else 
									i:TriggerInput( k, ( i.Inputs[ k ].Value - math.random(-100, 100 ) ) )	
								end
							end
											
						elseif v.Type == "VECTOR" then
										
							if status == 0 then
								i:TriggerInput( k, i.Inputs[ k ].Value )
							else
								if empnum == 0 then
									i:TriggerInput( k, Vector(0,0,0) )
								else 
									i:TriggerInput( k, ( i.Inputs[ k ].Value + Vector(math.random(-30000,30000), math.random(-30000,30000), math.random(-30000,30000) ) ) )
								end
							end
						end
					end
				end
			end
		end	
	end		
end

e2function void createEMP(number status, number empnum, entity target)
	if !ValidEntity(target) or target:IsPlayer() then return end
	
	local reqaccess = GetConVar( "access_emp" ):GetInt()
	local plyaccess = self.player:GetNWInt( "accesslevel" )	
		
	if plyaccess >= reqaccess then
	
		ttable = { }
		
		if(target != self.entity) then
			if (ValidEntity(target) and target.Inputs and target:GetClass() != "gmod_wire_numpad" ) then
				table.insert( ttable, target )
			end
		end
		
		for _, i in pairs(ttable) do
			if i:GetClass() == "gmod_wire_expression2" then
				if !i.e2jam then i.e2jam = 0 end
				if status == 0 then
					i:Reset()
					i.e2jam = 0
				elseif (status != 0 and i.e2jam == 0) then
					i:Error("E2 EMP Interference Detected", "EMP Interference")
					i.e2jam = 1
				end
			else

				for k, v in pairs(i.Inputs) do
				
					if EMP_IGNORE_INPUTS[k] == nil then
							
						if v.Type == "NORMAL" then
						
							if status == 0 then
								i:TriggerInput( k, i.Inputs[ k ].Value )
							else
								if empnum == 0 then
									i:TriggerInput( k, ( math.abs(i.Inputs[ k ].Value) - math.abs(i.Inputs[ k ].Value) ) )
								else 
									i:TriggerInput( k, ( i.Inputs[ k ].Value - math.random(-100, 100 ) ) )
								end
							end
							
						elseif v.Type == "VECTOR" then
						
							if status == 0 then
								i:TriggerInput( k, i.Inputs[ k ].Value )
							else
								if empnum == 0 then
									i:TriggerInput( k, Vector(0,0,0) )
								else 
									i:TriggerInput( k, ( i.Inputs[ k ].Value + Vector(math.random(-30000,30000), math.random(-30000,30000), math.random(-30000,30000) ) ) )	
								end
							end
						end
					end
				end
			end
		end
	end
end