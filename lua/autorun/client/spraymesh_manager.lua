
local SprayThumbnails = {}
local SprayList,SprayMeshManagerBase,page,pagecount

concommand.Add("SprayMesh_Manager",SprayMeshManager)

local function FormatTable(tab)
	for k,v in pairs(tab) do
		local sub = string.gsub(v,"^.+imgur.com/","")
		if string.len(sub) == 11 then
			local subext = string.Right(sub,4)
			if subext == ".jpg" or subext == ".png" then
				tab[k] = string.gsub(v,"^.+imgur.com/","")
			end
		else
			table.remove(tab,k)
		end
	end
	for k,v in pairs(tab) do
		local c = {}
		for k2,v2 in pairs(tab) do
			if v == v2 and k ~= k2 then table.insert(c,k2) end
		end
		if #c>0 then
			for k3,v3 in pairs(c) do
				table.remove(tab,v3)
			end
		end
	end
	return tab
end

function ReloadManager()
	for k,v in pairs(SprayThumbnails) do
		SprayThumbnails[k].html:Remove()
		SprayThumbnails[k].button:Remove()
	end
	SprayList = FormatTable(SprayList)
	SprayMeshManagerThumbnails()
	file.Write("sprays/savedsprays.txt",util.TableToJSON(SprayList))
end

function SprayMeshManagerThumbnails()
	
	SprayList = FormatTable(SprayList)
	
	pagecount = math.ceil(#SprayList/12)
	
	for k,v in pairs(SprayList) do
		if k>page*12 then
			if (SprayThumbnails[v] ~= nil) then
				SprayThumbnails[v].html:Remove()
				SprayThumbnails[v].button:Remove()
			end
			continue
		end
		if k<=(page-1)*12 then
			if (SprayThumbnails[v] ~= nil) then 
				SprayThumbnails[v].html:Remove()
				SprayThumbnails[v].button:Remove()
			end
			continue
		end
		
		local key = (k-1)%12
		local height = math.floor(key/3)*138+30
		local width = (key%3)*138+12
		
		SprayThumbnails[v] = {["html"] = vgui.Create("DHTML",SprayMeshManagerBase),["button"] = vgui.Create("DButton",SprayMeshManagerBase)}
		local panel = SprayThumbnails[v]
		
		panel["button"]:SetSize(128,128)
		panel["button"]:SetPos(width,height)
		panel["button"]:SetText("")
		
		local pb = panel["button"]
		function pb:Paint(w,h)
			draw.RoundedBox(0,0,0,w,h,Color(0,0,0,0))
		end
		
		panel["button"].DoClick = function()
			RunConsoleCommand("SprayMesh_URL","i.imgur.com/"..v)
		end
		
		panel["button"].DoRightClick = function()
			local menu = DermaMenu()
			menu:AddOption("Remove",function()
				table.remove(SprayList,k)
				ReloadManager()
			end)
			menu:AddOption("Copy link to clipboard",function() SetClipboardText("https://i.imgur.com/"..v) end)
			menu:Open()
		end
		
		panel["html"]:SetSize(128,128)
		panel["html"]:SetPos(width,height)
		panel["html"]:SetHTML([[
			<!DOCTYPE html>
			<html>
				<head>
					<meta charset="UTF-8">
					<title>title</title>
					<style type = "text/css">
						html {
							overflow: hidden;
						}
						body {
							text-align:center;
						}
					</style>
				</head>
				<body scroll="no">
					<img id='media' onload='FixImage()' src=']].."http://i.imgur.com/"..v..[['></img>
					<script>
						function FixImage(){
							var image = document.getElementById("media");
							if (image.height > image.width) {
								image.style.height = "]]..panel["html"]:GetTall()..[[px";
								image.style.width = "auto";
							}
							else{
								image.style.height = "auto";
								image.style.width = "]]..panel["html"]:GetWide()..[[px";
							}
						}
					</script>
				</body>
			</html>]]
		)
	end	
	
end

function SprayMeshManager()

	if IsValid(SprayMeshManagerBase) then return end
	
	if !file.Exists("sprays","DATA") then file.CreateDir("sprays") end
	if !file.Exists("sprays/savedsprays.txt","DATA") then file.Write("sprays/savedsprays.txt","") end
	local SavedSprays = util.JSONToTable(file.Read("sprays/savedsprays.txt"))
	SprayList = {}
	if SavedSprays then
		SprayList = SavedSprays
	elseif file.Size("sprays/savedsprays.txt","DATA") > 0 then
		Derma_Message("An error occurred while loading your saved sprays.","Error","Ok")
	end
	page = 1
	
	SprayMeshManagerBase = vgui.Create("DFrame")
	SprayMeshManagerBase:SetSize(430,620)
	SprayMeshManagerBase:SetPos(10,ScrH()*0.1)
	SprayMeshManagerBase:SetTitle("")
	SprayMeshManagerBase:MakePopup()
	
	function SprayMeshManagerBase:OnRemove()
		SprayMeshManagerBase = nil
	end
	
	function SprayMeshManagerBase:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,Color(0,0,0))
		draw.DrawText(page,"Trebuchet18",w*.5,h-25,Color(255,255,255),TEXT_ALIGN_CENTER)
	end
	
	SprayMeshManagerAddSpray = vgui.Create("DImageButton",SprayMeshManagerBase)
	SprayMeshManagerAddSpray:SetSize(16,16)
	SprayMeshManagerAddSpray:SetPos(10,5)
	SprayMeshManagerAddSpray:SetImage("plus.png")
	
	function SprayMeshManagerAddSpray:DoClick()
		Derma_StringRequest(
			"Add New Spray",
			"Input an imgur with correct formating   Example: i.imgur.com/nbn0zwo.jpg",
			"", //https://i.imgur.com/gSougja.jpg
			function(link)
				table.insert(SprayList,link)
				ReloadManager()
			end
		)
	end
	
	SprayMeshManagerPageLeft = vgui.Create("DImageButton",SprayMeshManagerBase)
	SprayMeshManagerPageLeft:SetSize(16,16)
	SprayMeshManagerPageLeft:SetPos(15,595)
	SprayMeshManagerPageLeft:SetImage("icon16/arrow_left.png")
	
	function SprayMeshManagerPageLeft:DoClick()
		if page-1>0 then
			page = page - 1
			SprayMeshManagerThumbnails()
		end
	end
	
	SprayMeshManagerPageRight = vgui.Create("DImageButton",SprayMeshManagerBase)
	SprayMeshManagerPageRight:SetSize(16,16)
	SprayMeshManagerPageRight:SetPos(400,595)
	SprayMeshManagerPageRight:SetImage("icon16/arrow_right.png")
	
	function SprayMeshManagerPageRight:DoClick()
		if page+1<=pagecount then
			page = page + 1
			SprayMeshManagerThumbnails()
		end
	end
	
	SprayMeshManagerThumbnails()
	
end