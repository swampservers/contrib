-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
net.Receive("LootBoxAnimation", function(len)
    local mdl = net.ReadString()
    local others = net.ReadTable()
    local namedata = net.ReadTable()
    local rating = net.ReadFloat()
    LootBoxAnimation(mdl, others, namedata, rating)
end)

function LootBoxAnimation(mdl, othermdls, namedata, rating)
    if IsValid(LOOTBOXPANEL) then
        LOOTBOXPANEL:Remove()
    end

    surface.PlaySound("lootbox.ogg")
    local delay = 4
    local size = 600

    LOOTBOXPANEL = vgui("DFrame", function(p)
        p:SetSize(size, size)
        p:Center()
        p:MakePopup()
        p:SetZPos(10000)
        -- p:SetBackgroundBlur(true)
        p:SetTitle("")
        p:ShowCloseButton(false)
        p:CloseOnEscape()

        function p:Paint(w, h)
            render.ClearDepth()
            DisableClipping(true)
            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(-3000, -3000, 8000, 8000)
            DisableClipping(false)
            draw.BoxShadow(150, 150, w - 300, h - 300, 300, 1)
        end

        vgui("Panel", function(p)
            p:Dock(FILL)

            local infopanel = vgui("DButton", function(p)
                p:SetText("Close (esc)")

                function p:DoClick()
                    LOOTBOXPANEL:Remove()
                end

                p:DockMargin(200, 10, 200, 10)
                p:Dock(BOTTOM)
            end)

            infopanel:SetAlpha(0)

            vgui("DModelPanel", function(p)
                p:Dock(FILL)
                local otheri = 1
                p:SetModel(othermdls[otheri])
                local boxmodel = ClientsideModel("models/Items/ammocrate_smg1.mdl")
                boxmodel:SetNoDraw(true)

                timer.Simple(0.2, function()
                    if not IsValid(boxmodel) then return end
                    local id, dur = boxmodel:LookupSequence("Close") --Open doesn't work???
                    boxmodel:ResetSequence(id)
                    boxmodel:SetPlaybackRate(0.1) -- doesn't work???
                end)

                function p:OnRemove()
                    if IsValid(boxmodel) then
                        boxmodel:Remove()
                    end
                end

                local t1 = SysTime()

                function p:PreDrawModel(ent)
                    boxmodel:SetPos(Vector(0, 0, ((SysTime() - t1) ^ 2) * -40))
                    boxmodel:SetAngles(Angle(0, 90, 0))
                    -- render.ModelM
                    boxmodel:DrawModel()
                end

                local t1 = SysTime()

                function p:LayoutEntity(ent)
                    local min, max = self.Entity:GetRenderBounds()
                    local center, radius = (min + max) / 2, min:Distance(max) / 2

                    if self.Entity.ScaledToModel ~= self.Entity:GetModel() then
                        self.Entity.ScaledToModel = self.Entity:GetModel()
                        self.Entity:SetModelScale(20 / radius)
                        -- self.Entity:InvalidateBoneCache()
                        -- self.Entity:SetupBones()
                        min, max = self.Entity:GetRenderBounds()
                        center, radius = (min + max) / 2, min:Distance(max) / 2
                    end

                    self.Entity:SetPos(self.Entity:GetPos() - self.Entity:LocalToWorld(center))
                    -- self.Entity:SetModelScale(0.5)
                    -- print(radius)
                    -- (radius + 1)
                    self:SetCamPos((60 * Vector(math.cos((SysTime() - t1) * 1.5) * 0.2, 1, 0.2))) --(radius + 1) *
                    self:SetLookAt(Vector(0, 0, 0))
                end

                namedata = table.Reverse(namedata)
                local appeartime = nil

                function p:PaintOver(w, h)
                    if appeartime then
                        local alpha = math.Clamp((SysTime() - appeartime) * 2, 0, 1)
                        y = h

                        for i, v in ipairs(namedata) do
                            local font = "DermaDefault"

                            if i == #namedata then
                                local bw = 100
                                h = h - 20
                                surface.SetDrawColor(0, 0, 0, 255 * alpha)
                                surface.DrawRect(w / 2 - bw, h, bw * 2, 16)
                                local r = SS_GetRating(rating)
                                surface.SetDrawColor(r.color.r, r.color.g, r.color.b, 255 * alpha)
                                surface.DrawRect(w / 2 - bw + 1, h + 1, (bw * 2 - 2) * rating, 14)
                                draw.SimpleText("Rating: " .. r.name, "DermaDefault", w / 2, h + 8, Color(255, 255, 255, 255 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                                font = "Trebuchet24"
                            end

                            draw.WordBox(8, w / 2, h, v, font, Color(0, 0, 0, 150 * alpha), Color(255, 255, 255, 255 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
                            h = h - 32
                        end
                    end
                end

                local rollspeed = 0.3
                local lastarg

                for i = rollspeed, delay, rollspeed do
                    local arg = {}
                    lastarg = arg

                    timer.Simple(i, function()
                        if not IsValid(p) then return end

                        if arg[1] then
                            p:SetModel(mdl)

                            timer.Simple(0.5, function()
                                if IsValid(infopanel) then
                                    infopanel:SetAlpha(255)
                                end
                            end)

                            appeartime = SysTime()
                        else
                            otheri = (otheri % (#othermdls)) + 1
                            p:SetModel(othermdls[otheri])
                        end
                    end)
                end

                lastarg[1] = true
            end)
        end)
    end)
end