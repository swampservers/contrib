-- This file is subject to copyright - contact swampservers@gmail.com for more information.
function PPM.loadResources()
    if CLIENT then
        PPM.m_bodyf = Material("models/ppm/base/bodyf")
        PPM.m_bodym = Material("models/ppm/base/bodym")

        
        PPM.m_body = Material("models/ppm/base/body")
        PPM.m_wings = Material("models/ppm/base/wings")
        PPM.m_horn = Material("models/ppm/base/horn")
        PPM.m_cmark = Material("models/ppm/base/cmark")
        PPM.m_hair1 = Material("models/ppm/base/hair_color_1")
        PPM.m_hair2 = Material("models/ppm/base/hair_color_2")
        PPM.m_tail1 = Material("models/ppm/base/tail_color_1")
        PPM.m_tail2 = Material("models/ppm/base/tail_color_2")
        PPM.m_eyel = Material("models/ppm/base/eye_l")
        PPM.m_eyer = Material("models/ppm/base/eye_r")

        PPM.m_cmarks = {
            {"models/ppm/cmarks/8ball.vtf"},
            {"models/ppm/cmarks/dice.vtf"},
            {"models/ppm/cmarks/magichat.vtf"},
            {"models/ppm/cmarks/magichat02.vtf"},
            {"models/ppm/cmarks/record.vtf"},
            {"models/ppm/cmarks/microphone.vtf"},
            {"models/ppm/cmarks/bits.vtf"},
            {"models/ppm/cmarks/checkered.vtf"},
            {"models/ppm/cmarks/lumps.vtf"},
            {"models/ppm/cmarks/mirror.vtf"},
            {"models/ppm/cmarks/camera.vtf"},
            {"models/ppm/cmarks/magnifier.vtf"},
            {"models/ppm/cmarks/padlock.vtf"},
            {"models/ppm/cmarks/binaryfile.vtf"},
            {"models/ppm/cmarks/floppydisk.vtf"},
            {"models/ppm/cmarks/cube.vtf"},
            {"models/ppm/cmarks/bulb.vtf"},
            {"models/ppm/cmarks/battery.vtf"},
            {"models/ppm/cmarks/deskfan.vtf"},
            {"models/ppm/cmarks/flames.vtf"},
            {"models/ppm/cmarks/alarm.vtf"},
            {"models/ppm/cmarks/myon.vtf"},
            {"models/ppm/cmarks/beer.vtf"},
            {"models/ppm/cmarks/berryglass.vtf"},
            {"models/ppm/cmarks/roadsign.vtf"},
            {"models/ppm/cmarks/greentree.vtf"},
            {"models/ppm/cmarks/seasons.vtf"},
            {"models/ppm/cmarks/palette.vtf"},
            {"models/ppm/cmarks/palette02.vtf"},
            {"models/ppm/cmarks/palette03.vtf"},
            {"models/ppm/cmarks/lightningstone.vtf"},
            {"models/ppm/cmarks/partiallycloudy.vtf"},
            {"models/ppm/cmarks/thunderstorm.vtf"},
            {"models/ppm/cmarks/storm.vtf"},
            {"models/ppm/cmarks/stoppedwatch.vtf"},
            {"models/ppm/cmarks/twistedclock.vtf"},
            {"models/ppm/cmarks/surfboard.vtf"},
            {"models/ppm/cmarks/surfboard02.vtf"},
            {"models/ppm/cmarks/star.vtf"},
            {"models/ppm/cmarks/ussr.vtf"},
            {"models/ppm/cmarks/vault.vtf"},
            {"models/ppm/cmarks/anarchy.vtf"},
            {"models/ppm/cmarks/suit.vtf"},
            {"models/ppm/cmarks/deathscythe.vtf"},
            {"models/ppm/cmarks/shoop.vtf"},
            {"models/ppm/cmarks/smiley.vtf"},
            {"models/ppm/cmarks/dawsome.vtf"},
            {"models/ppm/cmarks/weegee.vtf"}
        }

        -- Procedurally generate the material objects from their paths
        for index, wrappedPath in ipairs(PPM.m_cmarks) do
            PPM.m_cmarks[index][2] = Material(wrappedPath[1])
        end

        PPM.m_bodyt0 = {Material("models/ppm/texclothes/clothes_wbs_light.png"),
        Material("models/ppm/texclothes/clothes_wbs_full.png"),
         Material("models/ppm/texclothes/clothes_sbs_full.png"),
         Material("models/ppm/texclothes/clothes_sbs_light.png"),
         Material("models/ppm/texclothes/clothes_royalguard.png")}

        PPM.m_bodyt0[6] = PPM.m_bodyt0[5] -- Done to prevent bizarre memory bug in GMOD itself...

        PPM.m_bodydetails = {
            {Material("models/ppm/partrender/body_leggrad1.png"), "Leg grad"},
            {Material("models/ppm/partrender/body_lines1.png"), "Lines"},
            {Material("models/ppm/partrender/body_stripes1.png"), "Stripes"},
            {Material("models/ppm/partrender/body_headstripes1.png"), "Head stripes"},
            {Material("models/ppm/partrender/body_freckles.png"), "Freckles"},
            {Material("models/ppm/partrender/body_hooves1.png"), "Hooves big"},
            {Material("models/ppm/partrender/body_hooves2.png"), "Hooves small"},
            {Material("models/ppm/partrender/body_headmask1.png"), "Head layer"},
            {Material("models/ppm/partrender/body_hooves1_crit.png"), "Hooves big rnd"},
            {Material("models/ppm/partrender/body_hooves2_crit.png"), "Hooves small rnd"},
            {Material("models/ppm/partrender/body_spots1.png"), "Spots 1"},
            {Material("models/ppm/partrender/body_cowspots.png"), "Spots 2"},
            {Material("models/ppm/partrender/body_eyeliner.png"), "Head eyeliner"},
            {Material("models/ppm/partrender/body_muzzle1.png"), "Muzzle 1"},
            {Material("models/ppm/partrender/body_muzzle2.png"), "Muzzle 2"},
            {Material("models/ppm/partrender/body_nosefreckles.png"), "Nose freckles"},
            {Material("models/ppm/partrender/body_socks_primary.png"), "Socks primary"},
            {Material("models/ppm/partrender/body_socks_secondary.png"), "Socks secondary"},
            {Material("models/ppm/partrender/body_collar.png"), "Collar"},
            {Material("models/ppm/partrender/body_lipstick.png"), "Lipstick"}
        }
    end
end