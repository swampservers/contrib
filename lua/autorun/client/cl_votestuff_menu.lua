local sw, sh = ScrW(), ScrH();
local filterPattern = "&#?[%w]+;"
local PANEL = {}
function PANEL:Init()
		self:Adaptate(300, 400, 0.01, 0.2)
end;
function PANEL:Populate()
	self.Time = self:Add("DLabel")
	self.Time:SetText("Time left: 00:00")
	self.Time:SetContentAlignment(6)
	self.Time:Dock(TOP)
	self.Time:SetFont("Question-font")
	self.Time:SizeToContents()
	self.Time:DockMargin(0, 0, sw * 0.01, 0)

	self.Question = self:Add("CScrollPanel")
	self.Question:Dock(FILL)
	self.Question:DockMargin(sw * 0.008, sh * 0.05, sw * 0.008, sh * 0.002)
	self.Question:PaintLess()
	
	local qTable = BetterWrapText(TASKS.question, sw * 0.10, "Question-font");
	local i = 1;
	while (i <= #qTable) do
		local str = qTable[i];
		str = str:gsub(filterPattern, "");
		local text = self.Question:Add("DLabel")
		text:SetText(str)
		text:Dock(TOP)
		text:SetContentAlignment(5)
		text:SetFont("Question-font")
		text:SizeToContents()
		i = i + 1;
	end;

	self.Answer = self:Add("CScrollPanel")
	self.Answer:Dock(BOTTOM)
	self.Answer:SetTall(sh * 0.12)
	self.Answer:PaintLess()
	self.Answer:DockMargin(0, 0, 0, sh * 0.005)

	local i = 1;
	while (i <= #TASKS.answers) do
			local ans = TASKS.answers[i];
			ans = ans:gsub(filterPattern, "")
			local anwser = self.Answer:Add("DButton")
			anwser:Dock(TOP)
			anwser:SetText(i .. ": " .. ans)
			anwser:DockMargin( sw * 0.005, sh * 0.005, sw * 0.005, sh * 0.005)
			anwser:SetTextColor( Color( 255, 255, 255 ) )
			anwser:SetFont("Anwser-font")
			anwser:InitHover(Color(80, 80, 80), Color(100, 100, 100), 0.5)

			-- anwser.DoClick = function(this)
					-- netstream.Start('vote::SendAnAnwser', this:GetText());
					-- surface.PlaySound("buttons/button15.wav")
					
					-- TASKS = nil;
					-- self:Close()
			-- end;

			i = i + 1;
	end;

end;
function PANEL:Paint( w, h )
		self:DebugClose()
		draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 60, 255))
end;
vgui.Register( 'RVotePanel', PANEL, 'CPanel' )