-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

PS_WeaponProduct({
	class="weapon_anonymous",
	name="Anonymous Mask",
	description="We are 9GAG. We are Legion.",
	model="models/v/maskhq.mdl"
})

PS_WeaponProduct({
	class="weapon_autism",
	name="Autistic Outbursts",
	description="HOI WOOWIE",
	model='models/props_junk/TrafficCone001a.mdl'
})

PS_WeaponProduct({
	class="weapon_funnybanana",
	name="Funny Banana Picture",
	description="Save the pic, it\'s all yours my friend :)",
	model='models/chev/bananaframe.mdl'
})

PS_WeaponProduct({
	class="weapon_monke",
	name="Return to Monke",
	description="Reject modernity, Embrace tradition.",
	model="models/props/cs_italy/bananna.mdl"
})

PS_WeaponProduct({
	class="gmod_camera",
	name="Cringe Compiler",
	description="*SNAP*",
	model='models/MaxOfS2D/camera.mdl'
})

PS_WeaponProduct({
	class="weapon_encyclopedia",
	name="Bulletproof Book",
	description="Hold up this encyclopedia to block incoming bullets, just like that one youtube video.",
	model="models/props_lab/bindergreen.mdl"
})

PS_WeaponProduct({
	class="weapon_switch",
	name="Nintendo Switch",
	description="Great for photos. Try to contain your excitement!",
	model="models/swamponions/switchbox.mdl"
})

PS_WeaponProduct({
	class="weapon_fidget",
	name="Fidget Spinner",
	description='The correct term for a person with a fidget spinner is "helicopter tard".',
	model='models/props_workshop/fidget_spinner.mdl'
})

PS_WeaponProduct({
	class="weapon_flappy",
	name="Flappy Fedora",
	description="A dashing rainbow fedora. Tip it (press jump) to take flight.",
	model='models/fedora_rainbowdash/fedora_rainbowdash.mdl'
})

PS_WeaponProduct({
	class="weapon_kleiner",
	name="Dr. Isaac Kleiner",
	description="Lamarr, get down from there!",
	model="models/player/kleiner.mdl"
})

PS_WeaponProduct({
	class="weapon_spraypaint",
	name="Spraypaint",
	description="Deface the server with this handy graffiti tool.",
	model="models/props_junk/propane_tank001a.mdl"
})

PS_WeaponProduct({
	class="weapon_vape",
	name="Mouth Fedora",
	description="The classy alternative to blazing",
	model='models/swamponions/vape.mdl'
})

PS_WeaponProduct({
	class="weapon_shotgun",
	name="Defense Shotgun",
	description="Use this free, unlimited ammo shotgun to defend your private theater.",
	model='models/weapons/w_shotgun.mdl',
	CanBuyStatus=function(self,v)
		if v:GetTheater() and v:GetTheater():IsPrivate() and v:GetTheater():GetOwner()==v and v:GetTheater()._PermanentOwnerID==nil then
		else
			return PS_BUYSTATUS_PRIVATETHEATER
		end
	end,
	OnBuy=function(self,ply)
		ply.didJustShotgun=4 shotguncontrolfunc()
	end
})

PS_WeaponProduct({
	class="weapon_airhorn",
	price=100,
	name="MLG Airhorn",
	description="We can still drive memes right into the ground.",
	model="models/rockyscroll/airhorn/airhorn.mdl"
})

PS_WeaponProduct({
	class="weapon_beans",
	name="Baked Beans",
	description="For eating in theaters while watching Cars 2.",
	model="models/noz/beans.mdl",
	extrapreviewgap=1
})

PS_WeaponProduct({
	class="weapon_monster",
	name="Monster Zero",
	description="*sip* yeap, Quake was a good game",
	model="models/noz/monsterzero.mdl",
	extrapreviewgap=2
})
