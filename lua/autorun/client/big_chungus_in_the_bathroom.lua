BIG_CHUNGUS_LOCATION = Vector(0, 1598, 64)	
BIG_CHUNGUS_NORMAL = Vector(1,0,0)

function MAKE_CHUNGUS()
if(!IsValid(CHUNGUS_ENTITY))then
CHUNGUS_ENTITY = ClientsideModel("models/hunter/blocks/cube025x025x025.mdl")
end
CHUNGUS_ENTITY:SetPos(BIG_CHUNGUS_LOCATION)
CHUNGUS_ENTITY:SetAngles(BIG_CHUNGUS_NORMAL:Angle())
CHUNGUS_ENTITY:SetMaterial("pyroteknik/bigchungus")
CHUNGUS_ENTITY:ManipulateBoneScale(0,Vector(0.02,1,1.2))
end

hook.Add("InitPostEntity","make_chungus_in_bathroom",function()
	MAKE_CHUNGUS()
end)

local function Chungus_Function( ply, key )
	if ( key == IN_USE and ply:EyePos():Distance(CHUNGUS_ENTITY:GetPos()) < 64 and ply:GetEyeTrace().HitPos:Distance(CHUNGUS_ENTITY:GetPos()) < 25) then
	RunConsoleCommand("say_team","lol big chungus")
	surface.PlaySound( "weapon_funnybanana/hahaha.ogg" )
	end
end  

timer.Create("Chungus_Checker",1,0,function()
if(true or LocalPlayer().GetLocationName and LocalPlayer():GetLocationName() == "Bathroom")then

hook.Add("KeyPress","Chungus",Chungus_Function)
else
hook.Remove("KeyPress","Chungus")
end
end)


