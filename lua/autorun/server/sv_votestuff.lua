if !SERVER then return end

util.AddNetworkString( "tv::SendTasks" )
util.AddNetworkString( "tv::SendAnswer" )

Seconds = { // Each X seconds will appear a vote for all online players. They will have X/2 seconds to anwser;
	10,
} 
GivePoints = 100; // Amount of points to give the winner;
Curr_Task = Curr_Task || {}

// Creating a random timer on init;
local uniqueID = 'FetchQuestions'
local time = Seconds[math.random(1, #Seconds)]
timer.Create(uniqueID, time, 0, function()
	if !timer.Exists(uniqueID) then timer.Remove(uniqueID) return; end;

	http.Fetch( "https://opentdb.com/api.php?amount=1&difficulty=easy",
	function(body, length, headers, code)
			body = util.JSONToTable(body);
			local task = body["results"][1];
			if next(task) == nil then return end;
			
			local correct = task.correct_answer:gsub("&#?[%w]+;", "");
			Curr_Task.question = task.question;
			Curr_Task.answers = table.Copy(task.incorrect_answers);
			Curr_Task.answers[#Curr_Task.answers + 1] = correct
			Curr_Task.correct = correct
			table.sort(Curr_Task.answers)

			net.Start( "tv::SendTasks" )
				net.WriteUInt( math.Round(time/2), 16 ) // time always will be 0 or more; 2^16 = 65536;
				net.WriteTable(Curr_Task) // Sending a table; In my opinion faster is sending a JSON string instead of table itself;
			net.Broadcast() // Sending to everyone;
	end)
	
		math.randomseed( os.time() );
		timer.Adjust(uniqueID, time + Seconds[math.random(1, #Seconds)], 0, nil)
end);

net.Receive("tv::SendAnswer", function( len, ply )
		if !ply:IsValid() || !Curr_Task.correct then return end;
		local anwser = net.ReadString()
		local correct = Curr_Task.correct == anwser;

		if correct then
				-- client:SS_GivePoints( GivePoints )
		end

		ply:Notify(
				correct && "You're won! Have your ".. GivePoints .." points!" || "Your anwser is wrong."			
		)
end)
