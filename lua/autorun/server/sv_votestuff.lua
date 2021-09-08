if !SERVER then return end

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

			local result = {}
			
			result.question = task.question;
			result.answers = table.Copy(task.incorrect_answers);
			task.correct_answer = task.correct_answer:gsub("&#?[%w]+;", "")
			result.answers[#result.answers + 1] = task.correct_answer;
			table.sort(result.answers)

			Curr_Task = result;
			Curr_Task.correct = task.correct_answer;

			// See sh_netstream.lua
			// nil = send to all players;
			netstream.Start(nil, 'TaskVotes::sendTasks', math.Round(time/2), result)
	end)
	
		math.randomseed( os.time() );
		timer.Adjust(uniqueID, time + Seconds[math.random(1, #Seconds)], 0, nil)
end);

netstream.Hook('TaskVotes::SendAnAnwser', function(client, anwser)
		if !client:IsValid() || !Curr_Task.correct then return end;
		anwser = tostring(anwser);

		local correct = Curr_Task.correct == anwser;

		// A result if correct;
		if correct then
				-- client:SS_GivePoints( GivePoints )
		end

		// It's just a callback for notification in chat;
		// See: cl_votestuff_init.lua
		netstream.Start(client, 'TaskVotes::notify', correct, GivePoints)
end);