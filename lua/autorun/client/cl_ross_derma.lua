// My derma library with many good utilities;

local math = math;
local appr = math.Approach;
local clamp = math.Clamp;

local panelMeta = FindMetaTable('Panel')
local PLUGIN = PLUGIN;
function panelMeta:Adaptate(w, h, x, y)
    local sW, sH = ScrW(), ScrH()
    local positions = (x && y && x + y > 0)

    w = clamp(w, 10, 1920);
    h = clamp(h, 10, 1080);
    self:SetSize( sW * (w / 1920), sH * (h / 1080) )

    x = positions && clamp(x, 0, 1.25) || 0;
    y = positions && clamp(y, 0, 1.25) || 0;
    self:SetPos( sW * x, sH * y )
    if !positions then self:Center() end
end;
    
function panelMeta:DebugClose()
	local use = input.IsKeyDown( KEY_PAD_MINUS );

	if use && CLOSEDEBUG then
        CLOSEDEBUG = false;
    	surface.PlaySound("ui/buttonclick.wav");
    	self:Close();
    end;
end;

function panelMeta:InitHover(defaultColor, incrementTo, colorSpeed, borderColor, roundBorder)
    self.initedHover = true;
    self.bColor = borderColor

    roundBorder = roundBorder or 0
    self.dColor = !defaultColor && Color(60, 60, 60) || defaultColor
    self.IncTo = !incrementTo && Color(70, 70, 70) || incrementTo
    self.cSpeed = !colorSpeed && 7 * 100 || colorSpeed * 700;
    self.cCopy = self.dColor // color copy to decrement

    self.Paint = function(s, w, h)
        if !CLIENT then return end;
        if !self.initedHover then return end;

        local incTo = self.IncTo; // Increment color to;
        local cCopy = self.cCopy;
        local dis = self.Disable
        local hov = self:IsHovered()
        
        if dis then
            draw.RoundedBox(roundBorder, 0, 0, w, h, Color(cCopy.r, cCopy.g, cCopy.b, 100))
            return;
        end
        local red, green, blue = self.dColor.r, self.dColor.g, self.dColor.b
        self.dColor = {
            r = appr(red, hov && incTo.r || cCopy.r, FrameTime() * self.cSpeed),
            g = appr(green, hov && incTo.g || cCopy.g, FrameTime() * self.cSpeed),
            b = appr(blue, hov && incTo.b || cCopy.b, FrameTime() * self.cSpeed)
        }
        draw.RoundedBox(roundBorder, 0, 0, w, h, self.dColor)

        if self.bColor then
            surface.SetDrawColor(Color(40, 40, 40))
            surface.DrawOutlinedRect( 0, 0, w, h, 1 )
        end;
    end;
end;

// I've taken it from the helix;
function BetterWrapText(text, maxWidth, font)
    font = font or "DefaultFont"
    surface.SetFont(font)

    local words = string.Explode("%s", text, true)
    local lines = {}
    local line = ""
    local lineWidth = 0

    -- we don't need to calculate wrapping if we're under the max width
    if (surface.GetTextSize(text) <= maxWidth) then
        return {text}
    end

    for i = 1, #words do
        local word = words[i]
        local wordWidth = surface.GetTextSize(word)

        -- this word is very long so we have to split it by character
        if (wordWidth > maxWidth) then
            local newWidth

            for i2 = 1, string.len(word) do
                local character = word[i2]
                newWidth = surface.GetTextSize(line .. character)

                -- if current line + next character is too wide, we'll shove the next character onto the next line
                if (newWidth > maxWidth) then
                    lines[#lines + 1] = line
                    line = ""
                end

                line = line .. character
            end

            lineWidth = newWidth
            continue
        end

        local newLine = line .. " " .. word
        local newWidth = surface.GetTextSize(newLine)

        if (newWidth > maxWidth) then
            -- adding this word will bring us over the max width
            lines[#lines + 1] = line

            line = word
            lineWidth = wordWidth
        else
            -- otherwise we tack on the new word and continue
            line = newLine
            lineWidth = newWidth
        end
    end

    if (line != "") then
        lines[#lines + 1] = line
    end

    return lines
end
    
function panelMeta:Close()
	gui.EnableScreenClicker(false);
	self:AlphaTo(0, .2, 0, function() self:SetVisible(false); self:Remove() end)
end;

function panelMeta:DrawBlur()
    return Derma_DrawBackgroundBlur( self, self.m_fCreateTime )
end

function panelMeta:PaintLess()
    self.Paint = function(s, w, h) end;
end;

function draw.OutlineRectangle(x, y, w, h, clr, bclr)
    surface.SetDrawColor(clr)
    surface.DrawRect(x, y, w, h)
    surface.SetDrawColor(bclr)
    surface.DrawOutlinedRect(x, y, w, h)
end;