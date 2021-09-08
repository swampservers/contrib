if SERVER then return end;

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
		TASKS = tasks;

		if INTERFACE && INTERFACE:IsValid() then INTERFACE:Close() end;
		INTERFACE = vgui.Create('RVotePanel')
		INTERFACE:Populate()

		local uniqueID = 'TimerForVote'
		timer.Create(uniqueID, 1, time, function()
			if !timer.Exists(uniqueID) || (!INTERFACE || !INTERFACE:IsValid()) then timer.Remove(uniqueID) return; end;
			local timeLeft = timer.RepsLeft('TimerForVote');
			
			if timeLeft <= 0 then
					INTERFACE:Close();
					return;
			end

			INTERFACE.Time:SetText("Time left: " .. RFormatTime(timeLeft))
			INTERFACE.Time:SizeToContents()
		end);
end);

netstream.Hook('TaskVotes::notify', function(r, amount)
		chat.AddText(
			r && Color(150, 255, 150) || Color(255, 100, 100), 
			r && "You're won! Have your ".. amount .." points!" || "Your anwser is wrong."			
		);
end);