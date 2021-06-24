-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA


surface.CreateFont( "DermaMedium", {
	font		= "Roboto",
	size		= 22,
	weight		= 0,
	extended	= true
} )

local almostwhite = Color(224,224,224)
local succgreen = Color(64, 224, 64)
local warnyellow = Color(224, 224, 64)


-- Delay so convars get initialized by other files
timer.Simple(0, function()

    local basedpanel

    local urlconvar, nsfwconvar= GetConVar("spraymesh_url"), GetConVar("spraymesh_nsfw")

    if not file.Exists("swamp_sprays.txt", "DATA") and file.Exists("sprays/savedsprays.txt", "DATA") then
        file.Rename( "sprays/savedsprays.txt","swamp_sprays.txt")
    end

    local filetxt = file.Read("swamp_sprays.txt", "DATA")
    local SprayList = util.JSONToTable(filetxt or "") or {}


    local function RemoveId(id)
        for i, v in ipairs(SprayList) do
            if v[1] == id then
                return table.remove(SprayList, i)
            end
        end
    end


    local function UpdateList()
        -- Sanitize
        for i,v in ipairs(SprayList) do
            if not istable(v) then
                v = {v}
                SprayList[i] = v
            end
            if v[2]==1 then
                v[2]=true
            end
            if v[2]==0 then
                v[2]=false
            end
        end
        local i = 1
        local found = {}
        while i <= #SprayList do
            local id = SanitizeImgurId(SprayList[i][1])
            if id and not found[id] then
                SprayList[i][1] = id
                i=i+1
                found[id] = true
            else
                table.remove(SprayList, i)
            end
        end

        -- Force current url to the end, and update nsfw
        local cur_id = SanitizeImgurId(urlconvar:GetString())
        if cur_id then
            local latest = RemoveId(cur_id) or {cur_id}
            local nsfwsetting = GetSprayMeshNSFW(cur_id, nsfwconvar:GetString())
            if nsfwsetting~=nil then
                latest[2] = nsfwsetting
            end
            table.insert(SprayList, latest)
        end

        local newfiletxt = util.TableToJSON(SprayList)
        if newfiletxt~=filetxt then
            filetxt = newfiletxt
            file.Write("swamp_sprays.txt", filetxt)
        end
        if IsValid(basedpanel) then SprayMeshManagerThumbnails() end
    end

    UpdateList()
    
    cvars.AddChangeCallback("spraymesh_url", UpdateList)
    cvars.AddChangeCallback("spraymesh_nsfw", UpdateList)

    function SprayMeshManagerThumbnails()
        for _, v in ipairs(basedpanel.thumbnails:GetChildren() ) do
            v:Remove()
        end

        for k, v in pairs(table.Reverse(SprayList)) do
            vgui("DButton", basedpanel.thumbnails, function(p)
                basedpanel.thumbnails:Add(p)
                local thumb = p
                p.id = v[1]
                p.url = "i.imgur.com/"..v[1]
                p.nsfw = v[2]

                local s = 139
                p:SetSize(s,s)
                -- p:SetPos(x, y)
                p:SetText("")
                
                function p:Paint(w, h)
                    -- draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
                    local this = self.url == urlconvar:GetString()
                    if this or self:IsHovered() then
                        surface.SetDrawColor(this and succgreen or almostwhite)
                        surface.DrawRect(0, 0, w,h)

                        surface.SetDrawColor( 0,0,0, 255 )
                        surface.DrawRect(2,2, w-4, h-4 )
                    else
                        surface.SetDrawColor( 0,0,0, 255 )
                        surface.DrawRect(0, 0, w,h)
                    end
                    

                    local m = ImgurMaterial({id=self.id, shader = "UnlitGeneric",worksafe=(not p.nsfw)})

                    surface.SetDrawColor( 255, 255, 255, 255 ) 
                    surface.SetMaterial( m )
                    surface.DrawTexturedRect( 2,2, w-4, h-4 )

                end

                function p:DoClick()
                    urlconvar:SetString(self.url)
                    if self.nsfw ~= nil then
                        nsfwconvar:SetString(self.id..(self.nsfw and "=1" or "=0"))
                    end
                    basedpanel.inputholder:ApplyText()
                end

                function p:DoRightClick()
                    local menu = DermaMenu()
                    menu:AddOption("Remove", function()
                        RemoveId(self.id)
                        UpdateList()
                    end)
                    menu:AddOption("Copy link to clipboard", function()
                        SetClipboardText("https://"..self.url)
                    end)
                    menu:Open()
                end

                local nsfw = p.nsfw
                if nsfw ~= nil then
                    vgui("DImage", function(p)
                        p:SetSize(16, 16)
                        local x,y = thumb:GetSize()
                        p:SetPos(x-20,y-20)
                        p:SetImage(nsfw and "icon16/flag_red.png" or "icon16/flag_green.png")
                    end)
                end
            end)
        end
    end

    function SprayMeshManager()
        print("To open the spray manager quickly, run: bind <key> spray")
        if IsValid(basedpanel) then basedpanel:Remove() end

        vgui("DFrame", function(p)
            basedpanel = p
            p:SetSize(480,568)
            p:SetTitle("")
            p:Center()
            p:MakePopup()
            
            if gui.IsGameUIVisible() then
                gui.HideGameUI()
            end
            hook.Add("Think", "SMMCloser", function()
                if IsValid(p) then
                    if gui.IsGameUIVisible() then
                        gui.HideGameUI()
                        p:Close()
                    end
                else
                    hook.Remove("Think", "SMMCloser")
                end
            end)

            function p:Paint(w, h)
                
                draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 192))
                
                local x,y = self.inputholder:GetPos()
                local w2,h2 = self.inputholder:GetSize()
                draw.RoundedBox(0, 0, y-2, w, h2+4, Color(64,64,64, 255))
                draw.RoundedBox(0, 0, y, w, h2, Color(0, 0, 0, 255))
                
                -- draw.RoundedBox(0, 0, 0, w, y+h2, Color(0, 0, 0, 224))
                draw.DrawText("Spray Manager", "DermaLarge", 20, 4, almostwhite, TEXT_ALIGN_LEFT)
                -- draw.DrawText("Recent Sprays", "DermaMedium", 20, y+h2 + 4, Color(255, 255, 255), TEXT_ALIGN_LEFT)
            end

            -- function p:PaintOver(w, h)
            --     if basedpanel.input:GetValue()!="" then
            --         local x,y = self.scrollzone:GetPos()
            --         local w2,h2 = self.scrollzone:GetSize()

            --         surface.SetDrawColor(0,0,0,128)
            --         surface.DrawRect(x,y,w2,h2)
                    
            --         local id = basedpanel.input.SanitizedInput 
            --         if id then
            --             local m = ImgurMaterial({id=id, shader = "UnlitGeneric"})
            --             surface.SetDrawColor( 255, 255, 255, 255 ) 
            --             surface.SetMaterial( m )
            --             surface.DrawTexturedRect( x+(w2/2) - 128, y+(h2/2) - 128,256,256 ) 
            --         end
            --     end
            -- end

            


            basedpanel.inputholder = vgui("Panel", function(p)
                p:SetTall(56)
                p:Dock(TOP)
                p:DockMargin(0,16+8,0,8+8)

                function p:ApplyText()
                    p.Text="Spray applied! Press ESC to close."
                    p.TextColor = succgreen
                end

                function p:ResetText()
                    p.Text = "To set your spray, upload it to imgur.com, then\npaste the URL here ➔"
                    p.TextColor = almostwhite
                end
                p:ResetText()



                function p:Paint(w,h)
                    -- draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
                    draw.DrawText(self.Text, "DermaMedium", 40,4,self.TextColor)
                end

                basedpanel.input = vgui("DTextEntry", function(p)
                    -- p:Dock(TOP)
                    p:SetSize(160,20)
                    p:SetPos(230,28)

                    function p:OnChange()
                        local val = self:GetValue()
                        SingleAsyncSanitizeImgurId(val, function(id)
                            if not IsValid(self) then return end
                            -- self.SanitizedInput = id
                            if id then
                                urlconvar:SetString("i.imgur.com/"..id)
                                basedpanel.inputholder:ApplyText()
                            else
                                if val ~= "" then
                                    basedpanel.inputholder.Text="Invalid imgur URL. GIFs aren't supported!"
                                    basedpanel.inputholder.TextColor = warnyellow
                                else
                                    basedpanel.inputholder:ResetText()
                                end
                            end
                        end)
                    end
                end)

                -- vgui("Panel", function(p)
                --     p:Dock(TOP)

                --     basedpanel.checkbox = vgui("DCheckBoxLabel", function(p)
                --         p:Dock(LEFT)
                --         p:SetText("Is this spray pornograhic?")
                --     end)

                --     vgui("DButton", function(p)
                --         p:Dock(RIGHT)
                --         p:SetText("OK")

                --         function p:DoClick()
                --             if basedpanel.input.SanitizedInput then
                --                 urlconvar:SetString("i.imgur.com/"..basedpanel.input.SanitizedInput)
                --                 nsfwconvar:SetString(basedpanel.input.SanitizedInput..(basedpanel.checkbox:GetChecked() and "=1" or "=0"))
                --             end
                --         end
                --     end)
                -- end)

                -- p:InvalidateLayout( true )
                -- p:SizeToChildren( false, true )
            end)

            basedpanel.scrollzone = vgui( "DScrollPanel", function(p)
                p:Dock(FILL)
                basedpanel.thumbnails = vgui("DIconLayout", function(p)
                    p:Dock(FILL)
                    p:SetSpaceX(10)
                    p:SetSpaceY(10)
                end)
            end)
        end)

        SprayMeshManagerThumbnails()
    end

    concommand.Add("spraymesh_manager", SprayMeshManager)
    concommand.Add("spray", SprayMeshManager)
    concommand.Add("+spray", SprayMeshManager)
    concommand.Add("-spray", function() if IsValid(basedpanel) then basedpanel:Remove() end end)
end)