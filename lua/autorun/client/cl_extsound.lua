

net.Receive("ExtSound",function(len)
	local ply = net.ReadEntity()
	local sound = net.ReadString()
	local pitch = net.ReadFloat()
	local options = net.ReadTable()
	if IsValid(ply) and (not options.shared) or (ply ~= LocalPlayer()) then
		ExtSoundEmitSound(ply, sound, pitch, options)
	end
end)

function ExtSoundEmitSound(ply, sound, pitch, options)
	if IsValid(LocalPlayer()) and LocalPlayer():InTheater() and GetConVar("cinema_mutegame"):GetBool() then return end
	if IsValid(options.ent) then ply=options.ent end
	if IsValid(ply) then
		ply:EmitSound(sound, options.level or 75, pitch, options.volume or 1, options.channel or CHAN_AUTO)
	end
end


net.Receive("SetSpeech",function() 
	local ply = net.ReadEntity()
	if IsValid(ply) then
		ply.MouthCloseTime = RealTime() + net.ReadFloat() + 0.3
	end
end)

net.Receive("playerGesture",function() 
	local ply = net.ReadEntity()
	if IsValid(ply) then
		ply:AnimRestartGesture(net.ReadInt(8), net.ReadInt(16), net.ReadBool())
	end
end)

timer.Simple(1,function()
	function GAMEMODE:MouthMoveAnimation (ply)
		if not ply.vapeMouthOpenAmt then ply.vapeMouthOpenAmt=0 end
		if not ply.autismSpeaks then ply.autismSpeaks=0 end

		local FlexNum = ply:GetFlexNum() - 1
		if ( FlexNum <= 0 ) then return end
		
		local chewing = false
		local weight
		if ((ply.ChewScale or 0) > 0) then
			local x = CurTime()-ply.ChewStart
			weight = 0.5*math.sin(x*(2*math.pi/0.625)-0.5*math.pi)+0.5
			chewing = true
		end
		
		for i=0, FlexNum-1 do 
		
			local Name = ply:GetFlexName( i )
			if ( Name == "jaw_drop" || Name == "right_part" || Name == "left_part" || Name == "right_mouth_drop" || Name == "left_mouth_drop" ) then
				if ( ply:IsSpeaking() ) then
					ply:SetFlexWeight( i, math.Clamp( ply:VoiceVolume() * 2, 0, 2 ) )
				elseif ((ply.ChewScale or 0) > 0) then
					
					ply.ChewScale = math.Clamp((ply.ChewStart+ply.ChewDur - CurTime())/ply.ChewDur,0,1)
					if (Name == "jaw_drop" ) then
						ply:SetFlexWeight( i, weight*(ply.ChewScale*2) )
					else
						ply:SetFlexWeight( i, weight*((ply.ChewScale*2)-1.25) )
					end
				elseif ply.vapeMouthOpenAmt>0 then
					ply:SetFlexWeight( i, ply.vapeMouthOpenAmt*0.7 )
				else
					local open = math.Clamp(((ply.MouthCloseTime or 0) - RealTime())/0.3,0,1)
					ply:SetFlexWeight( i, math.Rand(0,2)*open )
				end
			end
		end
	end
end)