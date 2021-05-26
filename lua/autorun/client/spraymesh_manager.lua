-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local SprayThumbnails = {}
local SprayList, SprayMeshManagerBase, selected, selectedbutton, page, pagecount

local function FormatTable(tab)
    for k, v in pairs(tab) do
        local s = string.find(tab[k], "%w+%.gfycat%.com/%a+%.webm$", 0, false)

        if s and tab[k]:len() < 100 then
            tab[k] = tab[k]:sub(s, -1)
        else
            local id = SanitizeImgurId(tab[k])

            if id then
                tab[k] = "i.imgur.com/" .. id
            else
                table.remove(tab, k)
            end
        end
    end

    for k, v in pairs(tab) do
        local c = {}

        for k2, v2 in pairs(tab) do
            if v == v2 and k ~= k2 then
                table.insert(c, k2)
            end
        end

        if #c > 0 then
            for k3, v3 in pairs(c) do
                table.remove(tab, v3)
            end
        end
    end

    return tab
end

function ReloadManager()
    for k, v in pairs(SprayThumbnails) do
        SprayThumbnails[k].html:Remove()
        SprayThumbnails[k].button:Remove()
    end

    if IsValid(selected) then
        selected:Remove()
        selectedbutton:Remove()
    end

    SprayList = FormatTable(SprayList)
    SprayMeshManagerThumbnails()
    file.Write("sprays/savedsprays.txt", util.TableToJSON(SprayList))
end

local function SprayOptions(link)
    local menu = DermaMenu()

    menu:AddOption("Remove", function()
        table.RemoveByValue(SprayList, link)
        ReloadManager()
    end)

    menu:AddOption("Copy link to clipboard", function()
        SetClipboardText("https://" .. link)
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
        SprayOptions(GetConVar("SprayMesh_URL"):GetString())
    end
end

function SprayMeshManagerThumbnails()
    SprayList = FormatTable(SprayList)
    pagecount = math.ceil(#SprayList / 12)
    local outlinecheck = false

    for k, v in pairs(SprayList) do
        if k > page * 12 then
            if (SprayThumbnails[v] ~= nil) then
                SprayThumbnails[v].html:Remove()
                SprayThumbnails[v].button:Remove()
            end

            continue
        end

        if k <= (page - 1) * 12 then
            if (SprayThumbnails[v] ~= nil) then
                SprayThumbnails[v].html:Remove()
                SprayThumbnails[v].button:Remove()
            end

            continue
        end

        local key = (k - 1) % 12
        local height = math.floor(key / 3) * 138 + 30
        local width = (key % 3) * 138 + 12

        SprayThumbnails[v] = {
            ["html"] = vgui.Create("DHTML", SprayMeshManagerBase),
            ["button"] = vgui.Create("DButton", SprayMeshManagerBase)
        }

        local panel = SprayThumbnails[v]
        panel["button"]:SetSize(128, 128)
        panel["button"]:SetPos(width, height)
        panel["button"]:SetText("")
        local pb = panel["button"]

        function pb:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
        end

        panel["button"].DoClick = function()
            RunConsoleCommand("SprayMesh_URL", v)

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
            SprayOptions(v)
        end

        local link = ""

        if string.find(v, "%w+%.gfycat%.com/%a+%.webm$", 0, false) then
            link = "<video id='media' onload='FixSize()' src='" .. "https://" .. v .. "' style='width:100%;height:auto' autoplay loop muted/>"
        else
            link = "<img id='media' onload='FixSize()' src='" .. "http://" .. v .. "'></img>"
        end

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

        if GetConVar("SprayMesh_URL"):GetString() == v then
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

    if not file.Exists("sprays", "DATA") then
        file.CreateDir("sprays")
    end

    if not file.Exists("sprays/savedsprays.txt", "DATA") then
        file.Write("sprays/savedsprays.txt", "")
    end

    local SavedSprays = util.JSONToTable(file.Read("sprays/savedsprays.txt"))
    SprayList = {}

    if SavedSprays then
        SprayList = SavedSprays
    elseif file.Size("sprays/savedsprays.txt", "DATA") > 0 then
        Derma_Message("An error occurred while loading your saved sprays.", "Error", "Ok")
    end

    page = 1
    SprayMeshManagerBase = vgui.Create("DFrame")
    SprayMeshManagerBase:SetSize(430, 620)
    SprayMeshManagerBase:SetPos(10, ScrH() * 0.1)
    SprayMeshManagerBase:SetTitle("")
    SprayMeshManagerBase:MakePopup()

    function SprayMeshManagerBase:OnRemove()
        SprayMeshManagerBase = nil
    end

    function SprayMeshManagerBase:Paint(w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0))
        draw.DrawText(page, "Trebuchet18", w * .5, h - 25, Color(255, 255, 255), TEXT_ALIGN_CENTER)
    end

    SprayMeshManagerAddSpray = vgui.Create("DImageButton", SprayMeshManagerBase)
    SprayMeshManagerAddSpray:SetSize(16, 16)
    SprayMeshManagerAddSpray:SetPos(10, 5)
    SprayMeshManagerAddSpray:SetImage("icon16/add.png")

    function SprayMeshManagerAddSpray:DoClick()
        Derma_StringRequest("Add New Spray", "Input an imgur with correct formating   Example: i.imgur.com/nbn0zwo.jpg", "", function(link)
            table.insert(SprayList, link)
            ReloadManager()
        end)
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

    SprayMeshManagerThumbnails()
end

concommand.Add("SprayMesh_Manager", SprayMeshManager)