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

netstream.Hook('TaskVotes::sendTasks', function(time, tasks)
		local sw, sh = ScrW(), ScrH();
		TASKS = tasks;

		LocalPlayer():AddPlayerOption( "MakeNewVote", 
		time, 
		function(num)
				if TASKS.answers[num] then
					netstream.Start('TaskVotes::SendAnAnwser', TASKS[num]);
					surface.PlaySound("buttons/button15.wav")
				end;

				TASKS = nil;
				return true;
		end, 
		function() 
			local timeLeft = timer.RepsLeft("TimerForVote");
			local lFont = "Question-font"
			local aFont = "Anwser-font"
			draw.RoundedBox(0, sw * 0.01, sh * 0.2, sw * (300 / 1920), sh * (400 / 1080), Color(60, 60, 60, 255))
			draw.SimpleText("Time left: " .. RFormatTime(timeLeft), lFont, sw * 0.1, sh * 0.2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

			local qTable = BetterWrapText(TASKS.question, sw * 0.15, lFont);
			local i = 1;
			while (i <= #qTable) do
				local str = qTable[i];
				str = str:gsub(filterPattern, "");
				draw.SimpleText(str, lFont, sw * 0.085, sh * (0.23 + i * 0.014), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				i = i + 1;
			end;

			local i = 1;
			while (i <= #TASKS.answers) do
					local ans = TASKS.answers[i];
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
end);

netstream.Hook('TaskVotes::notify', function(r, amount)
		chat.AddText(
			r && Color(150, 255, 150) || Color(255, 100, 100), 
			r && "You're won! Have your ".. amount .." points!" || "Your anwser is wrong."			
		);
end);