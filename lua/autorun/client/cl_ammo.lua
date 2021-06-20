-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local hide = {
	["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true,
    ["CHudHealth"] = true,
}
hook.Add( "HUDShouldDraw", "HideAmmo", function( name )
	if ( hide[name]) then
		return false
	end
end )


local LASTAMMOTEXT = {}
local LASTAMMOICON
local grey = 25
local grey_ab = 200

hook.Add("HUDPaint","SwampHealthAmmo",function()

    if(GetConVar("cinema_hideinterface") and GetConVar("cinema_hideinterface"):GetBool() == true)then return end
    local ply=  LocalPlayer()
    local drawhealth = true or ply:Alive() and ply:Health() < ply:GetMaxHealth()
    HEALTH_ALPHA = math.Approach(HEALTH_ALPHA or 0,drawhealth and 1 or 0,FrameTime()*4)
    local alpha = HEALTH_ALPHA
    local col = Color(255, 255, 255, alpha*255)
    surface.SetFont("Trebuchet24")
    local str  = "Health:"..ply:Health()
    local tw,th = surface.GetTextSize(str)
    local boxw,boxh = math.max(128,tw + 16),24
    local textcx,textcy = 8  + boxw/2,ScrH() - boxh/2 - 8
    draw.RoundedBox( 8, textcx - boxw/2, textcy - boxh/2, boxw, boxh, Color(grey,grey,grey,grey_ab*alpha) )
    if ply:Health() < 30 then
        col = Color(255, 0, 0, alpha*255)
    end
    draw.SimpleText(str, "Trebuchet24", textcx, textcy, col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

 
    local wep = ply:GetActiveWeapon()

    local alpha = AMMO_ALPHA
    local drawammo = IsValid(wep) and ((wep.DrawAmmo != nil and wep.DrawAmmo) or (wep.DrawAmmo == nil and true))
    if(drawammo)then
        local clip = wep:Clip1()
        local clipsize = (wep.Primary and wep.Primary.ClipSize) or wep:GetMaxClip1()
        local ammotype = wep:GetPrimaryAmmoType()
        local ammo = ply:GetAmmoCount(wep:GetPrimaryAmmoType())
        local ammosize = game.GetAmmoMax( wep:GetPrimaryAmmoType() )
        
        if(ammotype == nil or ammotype == -1)then
            ammo = nil
        end
        
        if(clip <= 1 and clipsize <= 1)then
            clip = nil
        end

        if(wep.ClipDisplayValue)then
            clip = wep:ClipDisplayValue() 
            clipsize = 9999
        end
        if(wep.AmmoDisplayValue)then
            ammo = wep:AmmoDisplayValue() 
        end

        if(clipsize or ammo)then LASTAMMOTEXT = {} end

        if(clipsize)then 
            table.insert(LASTAMMOTEXT,clip)
        end

        if(ammo)then 
            table.insert(LASTAMMOTEXT,ammo)
        end
        if(#LASTAMMOTEXT == 0)then drawammo = false end

    end

    AMMO_ALPHA = math.Approach(AMMO_ALPHA or 0,drawammo and 1 or 0,FrameTime()*4)
    print(wep:GetModel())
    if(drawammo and wep:GetModel())then
        LASTAMMOICON = GetAutoIcon(wep:GetModel(), AUTOICON_HL2WEAPONSELECT)  
    end
    if(LASTAMMOICON == nil)then 
        return 
    end
    local x,y = ScrW() - 64,ScrH() - 50
   
    local whitec = Color(255,255,255,255*alpha)
    local redc = Color(255, 0, 0, alpha*255)

    local size = 200
    local iconx,icony = ScrW() - size*0.5,ScrH() - size*0.25

    
    render.SetMaterial(LASTAMMOICON)
    LASTAMMOICON:SetVector("$color2", Vector(1,1,1) * (alpha)*0.5)

    cam.Start2D()
    render.OverrideBlend(true, BLEND_ONE_MINUS_DST_COLOR, BLEND_ONE, BLENDFUNC_ADD, BLEND_ZERO, BLEND_ONE, BLENDFUNC_ADD)
    render.DrawScreenQuadEx(iconx - (size/2), icony - (size/2), size, size)
    render.OverrideBlend(false)
    
    cam.End2D()

    if(#LASTAMMOTEXT > 0)then
    local tw,th = surface.GetTextSize(LASTAMMOTEXT[1])
    local boxw,boxh = math.max(64,tw+16),24
    if(LASTAMMOTEXT[2])then
        local tw2,th2 = surface.GetTextSize(LASTAMMOTEXT[2])
        boxw = math.max(48,math.max(tw2,tw)*2 + 16 + 12)
    end

    local textcx,textcy = ScrW() - boxw/2 - 8 ,ScrH() - boxh/2 - 8
    draw.RoundedBox( 8, textcx - boxw/2, textcy - boxh/2, boxw, boxh, Color(grey,grey,grey,grey_ab*alpha) )
    
    if(LASTAMMOTEXT[2])then
        surface.SetDrawColor(255,255,255,128*alpha)
        surface.DrawRect(textcx-1, textcy- ((boxh-12)/2), 2, boxh -12)
        
        draw.SimpleText(LASTAMMOTEXT[1], "Trebuchet24", textcx - 6, textcy, (LASTAMMOTEXT[1] == 0 and redc) or whitec,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
        draw.SimpleText(LASTAMMOTEXT[2], "Trebuchet24", textcx + 6, textcy, (LASTAMMOTEXT[2] == 0 and redc) or whitec,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
 
    else
        draw.SimpleText(LASTAMMOTEXT[1], "Trebuchet24", textcx, textcy, (LASTAMMOTEXT[1] == 0 and redc) or whitec,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
 
    end
    

end
end)