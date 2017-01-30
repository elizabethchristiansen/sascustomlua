/******************************************************************************\
  Input support v1.1
\******************************************************************************/

local IsListeningForKey = {}

if CLIENT then

IsListeningForKey.chat = {false}

usermessage.Hook("e2keystartlistening", function( um )
	local key = um:ReadShort()
	if key>130 then
		key = key-131
		IsListeningForKey.chat[1] = key~=0
		return
	elseif key<0 then
		IsListeningForKey[-key] = nil
		return
	end
	IsListeningForKey[key] = 0
end)

hook.Add("CalcView", "e2keythink", function()
	if (WIRE_CLIENT_INSTALLED) then
		if IsListeningForKey.chat[1] and IsListeningForKey.chat[2] then return end
		for k,v in pairs(IsListeningForKey) do
			if k!="chat" then
				if(input.IsKeyDown(k) && v!=1) then
					// The key has been pressed
					IsListeningForKey[k]=1
					RunConsoleCommand("e2keystate",k,1)
				elseif(!input.IsKeyDown(k) && v!=0) then 
					// The key has been released
					IsListeningForKey[k]=0
					RunConsoleCommand("e2keystate",k,0)
				end
			end
		end
	end
end)

hook.Add("StartChat", "e2chatcheckinitiated", function()
	IsListeningForKey.chat[2] = true
	if IsListeningForKey.chat[1] then
		for k,v in pairs(IsListeningForKey) do
			if k!="chat" and v==1 then
				RunConsoleCommand("e2keystate",k,0)
			end
		end
	end
	return false
end) 

hook.Add("FinishChat", "e2chatcheckfinished", function()
	IsListeningForKey.chat[2] = false
	return
end)

elseif SERVER then

if !Keyboard_ReMap then
include('entities/gmod_wire_keyboard/remap.lua')
end

concommand.Add( "e2keystate", function( player, command, args )
	args[1] = Keyboard_ReMap[tonumber(args[1])]
	IsListeningForKey[player] = IsListeningForKey[player] or {}
	IsListeningForKey[player][args[1]] = tonumber(args[2])
end)

InvertedKeyMap = {}
for k,v in pairs(Keyboard_ReMap)do
	InvertedKeyMap[v] = k
end

end

registerFunction("keyDown", "e:n", "n", function(self,args)
    local op1, op2 = args[2], args[3]
    local rv1, rv2 = op1[1](self,op1), op2[1](self,op2)
	rv2 = rv2 - rv2 % 1
	if rv1:IsPlayer() and rv1:KeyDown(rv2) then
		return 1
	end
	return 0
end)

registerFunction("keyDown", "n", "n", function(self,args)
    local op1 = args[2]
    local rv1 = op1[1](self,op1)
	rv1 = rv1 - rv1 % 1
	if self.player:KeyDown(rv1) then
		return 1
	end
	return 0
end)

registerFunction("listenForKey", "n", "", function(self,args)
    local op1 = args[2]
    local rv1 = op1[1](self,op1)
	rv1 = rv1 - rv1 % 1
	if !InvertedKeyMap[rv1] then return end
	local prekey = rv1
	rv1 = InvertedKeyMap[rv1]
	IsListeningForKey[self.player] = IsListeningForKey[self.player] or {}
	if !IsListeningForKey[self.player][prekey] then
		umsg.Start("e2keystartlistening", self.player)
			umsg.Short(rv1)
		umsg.End()
		IsListeningForKey[self.player] = IsListeningForKey[self.player] or {}
		IsListeningForKey[self.player][prekey] = 0
	end
end)

registerFunction("listenForKeyStop", "n", "", function(self,args)
    local op1 = args[2]
    local rv1 = op1[1](self,op1)
	rv1 = rv1 - rv1 % 1
	if !InvertedKeyMap[rv1] then return end
	local prekey = rv1
	rv1 = InvertedKeyMap[rv1]
	umsg.Start("e2keystartlistening", self.player)
		umsg.Short(-rv1)
	umsg.End()
	IsListeningForKey[self.player] = IsListeningForKey[self.player] or {}
	IsListeningForKey[self.player][prekey] = nil
end)

registerFunction("cKeyDown", "n", "n", function(self,args)
    local op1 = args[2]
    local rv1 = op1[1](self,op1)
	rv1 = rv1 - rv1 % 1
	if IsListeningForKey[self.player] and IsListeningForKey[self.player][rv1] then
		return IsListeningForKey[self.player][rv1]
	end
	return 0
end)

registerFunction("cKeyDown", "e:n", "n", function(self,args)
    local op1, op2 = args[2], args[3]
    local rv1, rv2 = op1[1](self,op1), op2[1](self,op2)
	rv2 = rv2 - rv2 % 1
	if rv1:IsPlayer() and IsListeningForKey[rv1:IsPlayer()] and IsListeningForKey[rv1:IsPlayer()][rv2] then
		return IsListeningForKey[rv1:IsPlayer()][rv2]
	end
	return 0
end)

registerFunction("cIgnoreChat", "n", "", function(self,args)
    local op1 = args[2]
    local rv1 = op1[1](self,op1)
	rv1 = rv1 - rv1 % 1
	rv1 = rv1~=0
	IsListeningForKey[self.player] = IsListeningForKey[self.player] or {}
	IsListeningForKey[self.player].chat = IsListeningForKey[self.player].chat or {}
	if IsListeningForKey[self.player] and IsListeningForKey[self.player].chat[1]!=rv1 then
		if rv1 then rv1=132 else rv1=131 end
		umsg.Start("e2keystartlistening", self.player)
			umsg.Short(rv1)
		umsg.End()
		IsListeningForKey[self.player].chat[1] = rv1
	end
end)

registerFunction("toAscii", "n", "n", function(self,args)
    local op1 = args[2]
    local rv1 = op1[1](self,op1)
	if !Keyboard_ReMap[rv1] then return 0 end
	return Keyboard_ReMap[rv1]
end)

registerFunction("fromAscii", "n", "n", function(self,args)
    local op1 = args[2]
    local rv1 = op1[1](self,op1)
	if !InvertedKeyMap[rv1] then return 0 end
	return InvertedKeyMap[rv1]
end)