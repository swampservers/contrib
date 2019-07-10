CreateClientConVar("hellpromptdisable","0",true,false)
local TeleportingPlayers = {}

surface.CreateFont("HellPrompt",{
	font = "Arial",
	extended = false,
	size = 20,
	weight = 800,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

function HellPromptPlayer()

	if IsValid(HellPanel) then return end
	
	if GetConVar("hellpromptdisable"):GetInt() == 1 then
		net.Start("HellTeleport")
		net.SendToServer()
		return
	end
	
	HellPanel = vgui.Create("DFrame")
	HellPanel:SetSize(700,400)
	HellPanel:SetPos(ScrW()*0.5 - 400,ScrH()*0.5 - 250)
	HellPanel:SetTitle("")
	HellPanel:Center()
	HellPanel:MakePopup()
	
	function HellPanel:OnRemove()
		HellPanel = nil
	end
	
	function HellPanel:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,Color(0,0,0))
		draw.DrawText("Warning","Trebuchet24",w*.5,h*.5-120,Color(255,64,64),TEXT_ALIGN_CENTER)
		draw.DrawText("The Hell theater allows shock videos, which include:","HellPrompt",w*.5-235,h*.5-95,Color(192,192,192),TEXT_ALIGN_LEFT)
		draw.DrawText("-Torture/execution footage, except for illegal-to-distribute animal crush videos.","HellPrompt",w*.5-235,h*.5-75,Color(192,192,192),TEXT_ALIGN_LEFT)
		draw.DrawText("-Shocking/disgusting live-action pornography.","HellPrompt",w*.5-235,h*.5-55,Color(192,192,192),TEXT_ALIGN_LEFT)
		draw.DrawText("All other rules are still enforced in here.","HellPrompt",w*.5-235,h*.5-35,Color(192,192,192),TEXT_ALIGN_LEFT)
		draw.DrawText("Go to the Hell theater?","HellPrompt",w*.5,h*.5+10,Color(255,255,255),TEXT_ALIGN_CENTER)
	end
	
	local accept = vgui.Create("DButton",HellPanel)
	accept:SetText("Accept")
	accept:CenterHorizontal()
	accept:SetPos(accept:GetPos()-120,HellPanel:GetTall()*.5+45)
	accept:SetSize(50,20)
	accept.DoClick = function()
			net.Start("HellTeleport")
			net.SendToServer()
			HellPanel:Remove()
	end
	
	local decline = vgui.Create("DButton",HellPanel)
	decline:SetText("Decline")
	decline:CenterHorizontal()
	decline:SetPos(decline:GetPos()+120,HellPanel:GetTall()*.5+45)
	decline:SetSize(50,20)
	decline.DoClick = function()
			GetConVar("hellpromptdisable"):SetBool(false)
			HellPanel:Remove()
	end
	
	local toggleprompt = vgui.Create("DCheckBoxLabel",HellPanel)
	toggleprompt:SetText("Always accept from now on.")
	toggleprompt:CenterHorizontal()
	toggleprompt:SetPos(toggleprompt:GetPos(),HellPanel:GetTall()*.5+85)
	toggleprompt:SetConVar("hellpromptdisable")
	toggleprompt:SetValue(0)
	
end

net.Receive("HellTeleportEffect",function()
	local ply = net.ReadEntity()
	if not IsValid(ply) then return end
	TeleportingPlayers[ply] = {["BackToEarth"] = net.ReadBool(),["TeleportSpriteCount"] = 0,["EffectTwo"] = Vector(-50,4608,0),["PlayerPosition"] = ply:GetPos()}
end)

local floor =     Material("hell/SFLR6_1")
local skybox1 =   Material("hell/03_FR")
local skybox2 =   Material("hell/03_RT")
local skybox3 =   Material("hell/03_BK")
local skybox4 =   Material("hell/03_LF")
local wall =      Material("hell/FLOOR6_2")
local ceiling =   Material("hell/03_UP")
local tree1 =     Material("hell/TRE1A0")
local tree2 =     Material("hell/TRE2A0")
local torch =    {Material("hell/TREDB0"),
				  Material("hell/TREDC0")}
local TpSprite = {Material("hell/TFOGA0"),
				  Material("hell/TFOGB0"),
				  Material("hell/TFOGC0"),
				  Material("hell/TFOGD0"),
				  Material("hell/TFOGE0"),
				  Material("hell/TFOGF0"),
				  Material("hell/TFOGG0"),
				  Material("hell/TFOGH0"),
				  Material("hell/TFOGI0"),
				  Material("hell/TFOGJ0")}
local tppad =	  Material("hell/GATE3")
				  
local corner1a,corner1b,corner2a,corner2b,corner3a,corner3b,corner4a,corner4b
local tc = 1

local TpSpriteSize = {
	{16,74},
	{32,74},
	{32,74},
	{32,74},
	{16,42},
	{8,26},
	{4,18},
	{8,26},
	{16,42},
	{16,42}
}

local function ChangeRenderZ(Zdn,Zup)
	corner1a = Vector(-.5,4096.5,Zdn)
	corner1b = Vector(-.5,4096.5,Zup)
	corner2a = Vector(-1023.5,4096.5,Zup)
	corner2b = Vector(-1023.5,4096.5,Zdn)
	corner3a = Vector(-.5,5119.5,Zdn)
	corner3b = Vector(-.5,5119.5,Zup)
	corner4a = Vector(-1023.5,5119.5,Zdn)
	corner4b = Vector(-1023.5,5119.5,Zup)
end

local function Draw2DSprite(plypos,vec,width,minheight,maxheight)
	local rad = math.atan2(plypos.y - vec.y,plypos.x - vec.x)
	local y1 = vec.y - (width * math.cos(rad))
	local y2 = vec.y + (width * math.cos(rad))
	local x1 = vec.x + (width * math.sin(rad))
	local x2 = vec.x - (width * math.sin(rad))
	render.DrawQuad(Vector(x1,y1,minheight),Vector(x1,y1,maxheight),Vector(x2,y2,maxheight),Vector(x2,y2,minheight))
end

hook.Add("PostDrawOpaqueRenderables","HellRenderTeleportEffect",function(depth,skybox)

	if depth or skybox then return end
	local plypos = EyePos()
	
	//teleport animation
	for k,v in pairs(TeleportingPlayers) do
	
		v.HellTpTime = v.HellTpTime or CurTime()
		if (v.HellTpTime <= CurTime()) then
			v.TeleportSpriteCount = v.TeleportSpriteCount + 1
			v.HellTpTime = CurTime() + .2
		end
		
		local tsc = v.TeleportSpriteCount
		render.SetMaterial(TpSprite[tsc])
		
		if v.BackToEarth then
			v.EffectTwo = v.PlayerPosition
			Draw2DSprite(plypos,Vector(-14,-230,1),TpSpriteSize[tsc][1],10,TpSpriteSize[tsc][2])
		end
		Draw2DSprite(plypos,v.EffectTwo + Vector(-14,0,0),TpSpriteSize[tsc][1],10,TpSpriteSize[tsc][2])
		
		if tsc == 10 then TeleportingPlayers[k] = nil end
		
	end
	
end)

hook.Add("PostDrawOpaqueRenderables","HellRender",function(depth,skybox)

	if depth or skybox then return end
	if !EyePos():WithinAABox(Vector(0,4097,0),Vector(-1023,5119,1203)) then return end
	
	local ply = LocalPlayer()
	local plypos = EyePos()
	
	//ceiling
	local z = 691
	render.SetMaterial(ceiling)
	render.DrawQuad(Vector(-.1,5119.5,z),Vector(-1023.8,5119.5,z),Vector(-1023.8,4096.5,z),Vector(-.1,4096.5,z))
	
	//skybox
	ChangeRenderZ(175,1024)
	render.SetMaterial(skybox1)
	render.DrawQuad(corner1a,corner1b,corner2a,corner2b)
	render.SetMaterial(skybox2)
	render.DrawQuad(corner3a,corner3b,corner1b,corner1a)
	render.SetMaterial(skybox3)
	render.DrawQuad(corner4a,corner4b,corner3b,corner3a)
	render.SetMaterial(skybox4)
	render.DrawQuad(corner2b,corner2a,corner4b,corner4a)
	
	//walls
	ChangeRenderZ(0,175)
	render.SetMaterial(wall)
	render.DrawQuad(corner1a,corner1b,corner2a,corner2b)
	render.DrawQuad(corner3a,corner3b,corner1b,corner1a)
	render.DrawQuad(corner4a,corner4b,corner3b,corner3a)
	render.DrawQuad(corner2b,corner2a,corner4b,corner4a)
	
	//floor
	z = .5
	render.SetMaterial(floor)
	render.DrawQuad(Vector(-.1,4096.5,z),Vector(-1023.8,4096.5,z),Vector(-1023.8,5119.5,z),Vector(-.1,5119.5,z))
	
	//teleporter
	z = .6
	render.SetMaterial(tppad)
	render.DrawQuad(Vector(-100.6,5119.5,z),Vector(-.1,5119.5,z),Vector(-.1,5019,z),Vector(-100.6,5019,z))
	
	//torch animation
	TorchTime = TorchTime or CurTime()
	if (TorchTime <= CurTime()) then
		tc = (tc % 2) + 1
		TorchTime = CurTime() + .5
	end
	
	
	//custom sprites
	
	//trees
	render.SetMaterial(tree1)
	Draw2DSprite(plypos,Vector(-459,4294,70),75,0,150)
	Draw2DSprite(plypos,Vector(-309,4945,70),75,0,150)
	render.SetMaterial(tree2)
	Draw2DSprite(plypos,Vector(-168,4424,100),100,0,200)
	
	//torches
	render.SetMaterial(torch[tc])
	Draw2DSprite(plypos,Vector(-1000,4383,95),25,-5,200)
	Draw2DSprite(plypos,Vector(-1000,4833,95),25,-5,200)
	
end)

timer.Create("HellPortalDoomMusic",96,0,function()
	sound.PlayFile("sound/hell/doom_e1m1.ogg","3d mono noplay",function(e1m1)
		if IsValid(e1m1) then 
			e1m1:SetPos(Vector(3498,3470,-1020))
			e1m1:SetVolume(.5)
			e1m1:Set3DCone(100,190,0)
			e1m1:Set3DFadeDistance(150,-1)
			e1m1:Play()
		end
	end)
end)
