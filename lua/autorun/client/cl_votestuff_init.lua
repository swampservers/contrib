if SERVER then return end;

local filterPattern = "&#?[%w]+;"

surface.CreateFont( "Question-font", {
	font = "Century Gothic",
	size = ScreenScale(7),
	scanlines = 0,
	antialias = true,
	extended = true,
})

surface.CreateFont( "Anwser-font", {
	font = "Century Gothic",
	size = ScreenScale(6.5),
	scanlines = 0,
	antialias = true,
	extended = true,
})

net.Receive("tv::SendTasks", function( len )
		local time = net.ReadUInt(16);
		local tasks = net.ReadTable()
		local sw, sh = ScrW(), ScrH();

		LocalPlayer():AddPlayerOption( "MakeNewVote", 
		time, 
		function(num)
				if tasks.answers[num] then

					net.Start("tv::SendAnswer")
						net.WriteString( tasks.answers[num] )
					net.SendToServer()

					surface.PlaySound("buttons/button15.wav")
				end;
				return true;
		end, 
		function() 
			local lFont = "Question-font"
			local aFont = "Anwser-font"
			local time = string.FormattedTime(timer.RepsLeft("TimerForVote"), "%02i:%02i" );
			draw.RoundedBox(0, sw * 0.01, sh * 0.2, sw * (300 / 1920), sh * (400 / 1080), Color(60, 60, 60, 255))
			draw.SimpleText("Time left: " .. time, lFont, sw * 0.1, sh * 0.2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

			tasks.question = tasks.question:gsub(filterPattern, "");
			draw.WrappedText(
				tasks.question, 
				lFont, 
				sw * 0.085, 
				sh * 0.26, 
				sw * 0.13, 
				color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, false)

			local i = 1;
			while (i <= #tasks.answers) do
					local ans = tasks.answers[i];
					ans = ans:gsub(filterPattern, "")
					draw.RoundedBox(0, sw * 0.012, sh * (0.4 + i * 0.033), sw * (290 / 1920), sh * (30 / 1080), Color(80, 80, 80, 255))
					draw.SimpleText(i .. ": " .. ans, aFont, sw * 0.085, sh * (0.4 + i * 0.034), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
					i = i + 1;
			end;
		end)

		local uniqueID = 'TimerForVote'
		timer.Create(uniqueID, 1, time, function()
			if !timer.Exists(uniqueID) then timer.Remove(uniqueID) return; end;

			if timer.RepsLeft(uniqueID) <= 0 then
				LocalPlayer():AddPlayerOption( "MakeNewVote", 0, function(num) end, function() end);
			end;
		end);
end)