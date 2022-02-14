function PreDrawWrappedText(text, font, w, xalign, yalign, newlinespacing)
    newlinespacing = newlinespacing or 0
    local buffer = ""
    local lines = list()
    local totalheight = 0
    local lineheight = GetTextHeight(font)

    local function pushline(txt)
        local x = 0

        if xalign ~= TEXT_ALIGN_LEFT then
            local w = GetTextWidth(font, txt)
            x = xalign == TEXT_ALIGN_CENTER and -math.floor(w / 2) or -w
        end

        lines:Append({x, totalheight, txt})

        totalheight = totalheight + lineheight
    end

    for spaces, word in string.gmatch(text, "(%s*)(%S+)") do
        if spaces:find("\n") then
            if buffer ~= "" then
                pushline(buffer)
                buffer = ""
            end

            totalheight = totalheight + newlinespacing
        end

        if buffer == "" then
            buffer = word
        else
            local buffer2 = buffer .. " " .. word

            if GetTextWidth(font, buffer2) > w then
                pushline(buffer)
                buffer = word
            else
                buffer = buffer2
            end
        end
    end

    if buffer ~= "" or totalheight == 0 then
        pushline(buffer)
    end

    if yalign ~= TEXT_ALIGN_TOP then
        local offset = yalign == TEXT_ALIGN_CENTER and math.floor(totalheight / 2) or totalheight

        for i, line in ipairs(lines) do
            line[2] = line[2] - offset
        end
    end

    local function draw(x, y, col)
        surface.SetFont(font)
        surface.SetTextColor(col)

        for i, line in ipairs(lines) do
            surface.SetTextPos(x + line[1], y + line[2])
            surface.DrawText(line[3])
        end
    end

    return draw, totalheight
end

vgui.Register("SLabel", {
    Init = function(self)
        self.text = ""
        self.font = "DermaDefault"
        self.color = color_white
        self.xalign = TEXT_ALIGN_CENTER
        self.yalign = TEXT_ALIGN_CENTER
        self.newlinespacing = 0
    end,
    PerformLayout = function(self, w, h)
        -- if you need to override this move it into paint hook?
        local draw, th = PreDrawWrappedText(self.text, self.font, w, self.xalign, self.yalign, self.newlinespacing)

        if self.stretch then
            self:SetTall(th)
            h = th
        end

        local x, y = 0, 0

        if self.xalign == TEXT_ALIGN_CENTER then
            x = math.floor(w / 2)
        elseif self.xalign == TEXT_ALIGN_RIGHT then
            x = w
        end

        if self.yalign == TEXT_ALIGN_CENTER then
            y = math.floor(h / 2)
        elseif self.yalign == TEXT_ALIGN_BOTTOM then
            y = h
        end

        self.Paint = function()
            draw(x, y, self.color)
        end
    end,
    SetText = function(self, text)
        if self.text ~= text then
            self.text = text
            self:InvalidateLayout()
        end
    end,
    SetFont = function(self, font)
        if self.font ~= font then
            self.font = font
            self:InvalidateLayout()
        end
    end,
    SetColor = function(self, color)
        self.color = color
    end,
    SetContentAlignment = function(self, align)
        self.xalign = ({
            [0] = TEXT_ALIGN_LEFT,
            TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT
        })[(align - 1) % 3]

        self.yalign = ({
            [0] = TEXT_ALIGN_BOTTOM,
            TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP
        })[math.floor((align - 1) / 3)]

        self:InvalidateLayout()
    end,
    SetNewlineSpacing = function(self, space)
        self.newlinespacing = space
        self:InvalidateLayout()
    end,
    SetAutoStretchVertical = function(self, stretch)
        self.stretch = stretch
    end
}, "Panel")
