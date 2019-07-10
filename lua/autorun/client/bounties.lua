
function NewBounty(b)

	local bounty = vgui.Create("DFrame")
	bounty:SetTitle("New Bounty")
	bounty:SetSize(300, 144)
	bounty:SetDeleteOnClose(true)
	bounty:SetBackgroundBlur(true)
	bounty:SetDrawOnTop(true)
	
	local l1 = vgui.Create("DLabel", bounty)
	l1:SetText("Player:")
	l1:Dock(TOP)
	l1:DockMargin(4, 0, 4, 4)
	l1:SizeToContents()

	local pselect = vgui.Create("DComboBox", bounty)
	pselect:SetValue("Select A Player")
	pselect:SetTall(24)
	pselect:Dock(TOP)

	for _, ply in pairs(player.GetHumans()) do
		pselect:AddChoice(ply:Nick(),ply:UniqueID())
	end

	local l2 = vgui.Create("DLabel", bounty)
	l2:SetText(PS.Config.PointsName..":")
	l2:Dock(TOP)
	l2:DockMargin(4, 2, 4, 4)
	l2:SizeToContents()

	local pointsselector = vgui.Create("DNumberWang", bounty)
	pointsselector:SetTextColor( Color(0, 0, 0, 255) )
	pointsselector:SetTall(24)
	pointsselector:Dock(TOP)
	
	local btnlist = vgui.Create("DPanel", bounty)
	btnlist:SetDrawBackground(false)
	btnlist:DockMargin(0, 5, 0, 0)
	btnlist:Dock(BOTTOM)

	local cancel = vgui.Create('DButton', btnlist)
	cancel:SetText('Cancel')
	cancel:DockMargin(4, 0, 0, 0)
	cancel:Dock(RIGHT)

	local done = vgui.Create('DButton', btnlist)
	done:SetText('Send')
	done:DockMargin(0, 0, 4, 0)
	done:Dock(RIGHT)
	
	pselect.OnSelect = function(ind,val,data)
		bounty.ply = data
	end

	done.DoClick = function()
		local n = tonumber(pointsselector:GetValue())
		if n > 1000 and type(bounty.ply) == "string" then
			net.Start("IncreaseBounty")
				net.WriteUInt(n,32)
				net.WriteString(bounty.ply)
			net.SendToServer()
			bounty:Close()
			b:Close()
		end
	end

	cancel.DoClick = function()
		bounty:Close()
	end

	bounty:Center()
	bounty:MakePopup()
end

net.Receive("Bounties",function()

	local t = net.ReadTable()

	local Bounties = vgui.Create("DFrame")
	Bounties:SetSize(300,400)
	Bounties:SetPos((ScrW()/2)-150,(ScrH()/2)-200)
	Bounties:SetTitle("Bounties")
	Bounties:MakePopup()
	
	Bounties.Button = vgui.Create("DButton",Bounties)
	local Button = Bounties.Button
	Button:Dock(BOTTOM)
	Button:SetText("New Bounty")
	
	function Button:DoClick()
		NewBounty(Bounties)
	end
	
	Bounties.List = vgui.Create("DListView",Bounties)
	local List = Bounties.List
	List:Dock(FILL)
	List:AddColumn("Name")
	List:AddColumn("Bounty")
	
	table.sort(t,function(a,b) return a[2] > b[2] end)

	for _,v in pairs(t) do
		List:AddLine(v[1]:Nick(),v[2])
	end

	function List:OnRowRightClick(id,line)
		m = DermaMenu()
		m:AddOption("Increase Bounty",function()
			Derma_StringRequest(
				"Increase Bounty",
				"Input the amount of points to increase the bounty by.",
				"",
				function(amount)
					local n = tonumber(amount)
					if type(n) != nil then
						if n > 1000 then
							net.Start("IncreaseBounty")
								net.WriteUInt(n,32)
								net.WriteString(line:GetColumnText(1))
							net.SendToServer()
						end
					end
					Bounties:Close()
				end
			)
		end)
		m:Open()
	end
	
end)