-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local SprayThumbnails = {}
local SprayList, SprayMeshManagerBase, selected, selectedbutton, page, pagecount

local function SanitizeList()

    for i,v in ipairs(SprayList) do
        if not istable(v) then
            SprayList[i] = {
                v, -1
            }
        end
    end

    local i = 1
    while i <= #SprayList do
        local id = SanitizeImgurId(SprayList[i][1])

        if id then
            SprayList[i][1] = id
            i=i+1
        else
            table.remove(SprayList, i)
        end
    end

    local found = {}
    i = 1
    while i <= #SprayList do
        local v = SprayList[i][1]
        if found[v] then
            table.remove(SprayList, i)
        else
            found[v]= true
            i=i+1
        end

    end
end

local function SprayOptions(link)
    local menu = DermaMenu()

    menu:AddOption("Remove", function()
        for k, v in pairs(SprayList) do
            if v[1] == link then
                table.remove(SprayList, k)
                break
            end
        end

        UpdateSprayList()
    end)

    menu:AddOption("Copy link to clipboard", function()
        SetClipboardText("https://i.imgur.com/" .. link)
    end)

    menu:Open()
end

local function OutlineCurrentSpray(width, height)
    selected = vgui.Create("DPanel", SprayMeshManagerBase)
    selected:SetPos(width - 15, height - 15)
    selected:SetSize(150, 150)

    function selected:Paint(w, h)
        surface.SetDrawColor(Color(255, 255, 255))
        surface.DrawOutlinedRect(10, 10, 138, 138)
    end

    selectedbutton = vgui.Create("DButton", SprayMeshManagerBase)
    selectedbutton:SetSize(150, 150)
    selectedbutton:SetPos(width - 15, height - 15)
    selectedbutton:SetText("")

    function selectedbutton:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
    end

    function selectedbutton:DoRightClick()
        SprayOptions(GetConVar("spraymesh_url"):GetString())
    end
end

function UpdateSprayList()    
    SprayMeshManagerThumbnails()
    file.Write("swamp_sprays.txt", util.TableToJSON(SprayList))
end

function SprayMeshManagerThumbnails()
    SanitizeList()


    if IsValid(selected) then
        selected:Remove()
        selectedbutton:Remove()
    end
    
    pagecount = math.ceil(#SprayList / 12)
    local outlinecheck = false

    for k, v in pairs(SprayList) do
        if k > page * 12 then
            if (SprayThumbnails[v[1]] ~= nil) then
                SprayThumbnails[v[1]].html:Remove()
                SprayThumbnails[v[1]].button:Remove()
            end

            continue
        end

        if k <= (page - 1) * 12 then
            if (SprayThumbnails[v[1]] ~= nil) then
                SprayThumbnails[v[1]].html:Remove()
                SprayThumbnails[v[1]].button:Remove()
            end

            continue
        end

        local key = (k - 1) % 12
        local height = math.floor(key / 3) * 138 + 30
        local width = (key % 3) * 138 + 12

        SprayThumbnails[v[1]] = {
            ["html"] = vgui.Create("DHTML", SprayMeshManagerBase),
            ["button"] = vgui.Create("DButton", SprayMeshManagerBase)
        }

        local panel = SprayThumbnails[v[1]]
        panel["button"]:SetSize(128, 128)
        panel["button"]:SetPos(width, height)
        panel["button"]:SetText("")
        local pb = panel["button"]

        function pb:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
        end

        panel["button"].DoClick = function()
            RunConsoleCommand("spraymesh_url", v[1])
            
            if tonumber(v[2]) == nil then
                Derma_Query("Is this spray pornographic?\nClick porn if unsure. Lying=ban", "NSFW Spray?", "It's clean", function()
                    RunConsoleCommand("swampspraymesh_nsfw", "0")
                    SprayList[k][2] = 0
                    UpdateSprayList()
                end, "It's porn", function()
                    RunConsoleCommand("swampspraymesh_nsfw", "1")
                    SprayList[k][2] = 1
                    UpdateSprayList()
                end)
            else
                RunConsoleCommand("swampspraymesh_nsfw_url", v[1])
                RunConsoleCommand("swampspraymesh_nsfw", v[2])
            end

            if not IsValid(selected) then
                OutlineCurrentSpray(width, height)
            elseif not selected:IsVisible() then
                OutlineCurrentSpray(width, height)
            else
                selected:SetPos(width - 15, height - 15)
                selectedbutton:SetPos(width - 15, height - 15)
            end
        end

        panel["button"].DoRightClick = function()
            SprayOptions(v[1])
        end

        local link = "<img id='media' onload='FixSize()' src='" .. "http://i.imgur.com/" .. v[1] .. "'></img>"

        panel["html"]:SetSize(128, 128)
        panel["html"]:SetPos(width, height)
        panel["html"]:SetHTML([[
			<!DOCTYPE html>
			<html>
				<head>
					<meta charset="UTF-8">
					<title></title>
					<style type = "text/css">
						html,body {
							margin:0;
							overflow:hidden;
							text-align:center;
						}
					</style>
				</head>
				<body scroll="no">
					]] .. link .. [[
					<script>
						function FixSize(){
							var image = document.getElementById("media");
							if (image.height > image.width) {
								image.style.height = "]] .. panel["html"]:GetTall() .. [[px";
								image.style.width = "auto";
							}
							else{
								image.style.height = "auto";
								image.style.width = "]] .. panel["html"]:GetWide() .. [[px";
							}
						}
					</script>
				</body>
			</html>]])

        if GetConVar("SprayMesh_URL"):GetString() == v[1] then
            OutlineCurrentSpray(width, height)
            selected:Show()
            outlinecheck = true
        elseif (key == 11 or k == #SprayList) and selected ~= nil and selected:IsVisible() and not outlinecheck then
            selected:Hide()
        end
    end
end

function SprayMeshManager()
    if IsValid(SprayMeshManagerBase) then return end

    if not file.Exists("swamp_sprays.txt", "DATA") and file.Exists("sprays/savedsprays.txt", "DATA") then
        file.Rename( "sprays/savedsprays.txt","swamp_sprays.txt")
    end

    SprayList = util.JSONToTable(file.Read("swamp_sprays.txt", "DATA") or "") or {}

    SanitizeList()



    page = 1
    SprayMeshManagerBase = vgui.Create("DFrame")
    SprayMeshManagerBase:SetSize(430, 720)
    SprayMeshManagerBase:SetPos(10, ScrH() * 0.1)
    SprayMeshManagerBase:SetTitle("")
    SprayMeshManagerBase:MakePopup()
    SprayMeshManagerBase:Center()

    if gui.IsGameUIVisible() then
        gui.HideGameUI()
    end
    hook.Add("Think", "SMMCloser", function()
        if IsValid(SprayMeshManagerBase) then
            if gui.IsGameUIVisible() then
                gui.HideGameUI()
                SprayMeshManagerBase:Close()
            end
        else
            hook.Remove("Think", "SMMCloser")
        end
    end)

    function SprayMeshManagerBase:OnRemove()
        SprayMeshManagerBase = nil
    end

    function SprayMeshManagerBase:Paint(w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0))
        draw.DrawText(page, "Trebuchet18", 430 * .5, 595, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        draw.DrawText("Upload your spray to imgur.com, copy", "Trebuchet18", 20, 625, Color(255, 255, 255), TEXT_ALIGN_LEFT)
        draw.DrawText("the url, and paste it below.", "Trebuchet18", 20, 640, Color(255, 255, 255), TEXT_ALIGN_LEFT)

        local id = SprayMeshManagerInput.SanitizedInput 
        if id then
            local m = ImgurMaterial({id=id, shader = "UnlitGeneric"})

            surface.SetDrawColor( 255, 255, 255, 255 ) 
            surface.SetMaterial( m )
            surface.DrawTexturedRect( 290, 615,100,100 ) 
        end
    end


    SprayMeshManagerPageLeft = vgui.Create("DImageButton", SprayMeshManagerBase)
    SprayMeshManagerPageLeft:SetSize(16, 16)
    SprayMeshManagerPageLeft:SetPos(15, 595)
    SprayMeshManagerPageLeft:SetImage("icon16/arrow_left.png")

    function SprayMeshManagerPageLeft:DoClick()
        if page - 1 > 0 then
            page = page - 1
            SprayMeshManagerThumbnails()
        end
    end

    SprayMeshManagerPageRight = vgui.Create("DImageButton", SprayMeshManagerBase)
    SprayMeshManagerPageRight:SetSize(16, 16)
    SprayMeshManagerPageRight:SetPos(400, 595)
    SprayMeshManagerPageRight:SetImage("icon16/arrow_right.png")

    function SprayMeshManagerPageRight:DoClick()
        if page + 1 <= pagecount then
            page = page + 1
            SprayMeshManagerThumbnails()
        end
    end

    SprayMeshManagerInput = vgui.Create("DTextEntry", SprayMeshManagerBase)
    SprayMeshManagerInput:SetSize(245, 16)
    SprayMeshManagerInput:SetPos(15, 665)
    SprayMeshManagerCheckbox = vgui.Create("DCheckBoxLabel", SprayMeshManagerBase)
    SprayMeshManagerCheckbox:SetSize(16, 16)
    SprayMeshManagerCheckbox:SetPos(430 * .3 - 90, 690)
    SprayMeshManagerCheckbox:SetText("Is this spray pornograhic?")
    SprayMeshManagerInputButton = vgui.Create("DButton", SprayMeshManagerBase)
    SprayMeshManagerInputButton:SetSize(40, 20)
    SprayMeshManagerInputButton:SetPos(430 * .3 + 70, 688)
    SprayMeshManagerInputButton:SetText("OK")

    function SprayMeshManagerInputButton:DoClick()
        if SprayMeshManagerInput.SanitizedInput then
            table.insert(SprayList, {
                [1] = SprayMeshManagerInput.SanitizedInput,
                [2] = SprayMeshManagerCheckbox:GetChecked() and 1 or 0
            })

            UpdateSprayList()
        end
    end


    SprayMeshManagerInput.OnChange = function(self)
        SingleAsyncSanitizeImgurId(self:GetValue(), function(id)
            SprayMeshManagerInput.SanitizedInput = id
        end)
    end

    SprayMeshManagerThumbnails()
end

concommand.Add("spraymesh_manager", SprayMeshManager)
concommand.Add("spraymesh", SprayMeshManager)