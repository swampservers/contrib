-- This file is subject to copyright - contact swampservers@gmail.com for more information.

SWEP.PrintName = "Dr. Isaac Kleiner"

SWEP.Slot = 2

SWEP.WorldModel = ""

function SWEP:PrimaryAttack()
	if SERVER then self:ExtEmitSound(kleinersounds[ math.random( #kleinersounds ) ]) end
end

function SWEP:SecondaryAttack()
	self:ExtEmitSound("vo/k_lab2/kl_greatscott.wav", {shared=true})
end

function SWEP:Reload()
	if not self.justreloaded then self.justreloaded=0 end
	if self.justreloaded<1 then
		self:ExtEmitSound("vo/k_lab/kl_fiddlesticks.wav")
	end
	self.justreloaded=2
end

function SWEP:Tick()
	if not self.justreloaded then self.justreloaded=0 end
	self.justreloaded = self.justreloaded-1
end

kleinersounds = {"vo/k_lab/kl_ahhhh.wav",
"vo/k_lab/kl_almostforgot.wav",
"vo/k_lab/kl_barneyhonor.wav",
"vo/k_lab/kl_barneysturn.wav",
"vo/k_lab/kl_besokind.wav",
"vo/k_lab/kl_blast.wav",
"vo/k_lab/kl_bonvoyage.wav",
"vo/k_lab/kl_cantcontinue.wav",
"vo/k_lab/kl_cantwade.wav",
"vo/k_lab/kl_careful.wav",
"vo/k_lab/kl_charger01.wav",
"vo/k_lab/kl_charger02.wav",
"vo/k_lab/kl_coaxherout.wav",
"vo/k_lab/kl_comeout.wav",
"vo/k_lab/kl_credit.wav",
"vo/k_lab/kl_dearme.wav",
"vo/k_lab/kl_debeaked.wav",
"vo/k_lab/kl_delaydanger.wav",
"vo/k_lab/kl_diditwork.wav",
"vo/k_lab/kl_ensconced.wav",
"vo/k_lab/kl_excellent.wav",
"vo/k_lab/kl_fewmoments01.wav",
"vo/k_lab/kl_fewmoments02.wav",
"vo/k_lab/kl_fiddlesticks.wav",
"vo/k_lab/kl_finalsequence.wav",
"vo/k_lab/kl_finalsequence02.wav",
"vo/k_lab/kl_fitglove01.wav",
"vo/k_lab/kl_fitglove02.wav",
"vo/k_lab/kl_fruitlessly.wav",
"vo/k_lab/kl_getinposition.wav",
"vo/k_lab/kl_getoutrun01.wav",
"vo/k_lab/kl_getoutrun02.wav",
"vo/k_lab/kl_getoutrun03.wav",
"vo/k_lab/kl_gordongo.wav",
"vo/k_lab/kl_gordonthrow.wav",
"vo/k_lab/kl_hedyno01.wav",
"vo/k_lab/kl_hedyno02.wav",
"vo/k_lab/kl_hedyno03.wav",
"vo/k_lab/kl_helloalyx01.wav",
"vo/k_lab/kl_helloalyx02.wav",
"vo/k_lab/kl_heremypet01.wav",
"vo/k_lab/kl_heremypet02.wav",
"vo/k_lab/kl_hesnotthere.wav",
"vo/k_lab/kl_holdup01.wav",
"vo/k_lab/kl_holdup02.wav",
"vo/k_lab/kl_initializing.wav",
"vo/k_lab/kl_initializing02.wav",
"vo/k_lab/kl_interference.wav",
"vo/k_lab/kl_islamarr.wav",
"vo/k_lab/kl_lamarr.wav",
"vo/k_lab/kl_masslessfieldflux.wav",
"vo/k_lab/kl_modifications01.wav",
"vo/k_lab/kl_modifications02.wav",
"vo/k_lab/kl_moduli02.wav",
"vo/k_lab/kl_mygoodness01.wav",
"vo/k_lab/kl_mygoodness02.wav",
"vo/k_lab/kl_mygoodness03.wav",
"vo/k_lab/kl_nocareful.wav",
"vo/k_lab/kl_nonsense.wav",
"vo/k_lab/kl_nownow01.wav",
"vo/k_lab/kl_nownow02.wav",
"vo/k_lab/kl_ohdear.wav",
"vo/k_lab/kl_opportunetime01.wav",
"vo/k_lab/kl_opportunetime02.wav",
"vo/k_lab/kl_packing01.wav",
"vo/k_lab/kl_packing02.wav",
"vo/k_lab/kl_plugusin.wav",
"vo/k_lab/kl_projectyou.wav",
"vo/k_lab/kl_redletterday01.wav",
"vo/k_lab/kl_redletterday02.wav",
"vo/k_lab/kl_relieved.wav",
"vo/k_lab/kl_slipin01.wav",
"vo/k_lab/kl_slipin02.wav",
"vo/k_lab/kl_suitfits01.wav",
"vo/k_lab/kl_suitfits02.wav",
"vo/k_lab/kl_thenwhere.wav",
"vo/k_lab/kl_waitmyword.wav",
"vo/k_lab/kl_weowe.wav",
"vo/k_lab/kl_whatisit.wav",
"vo/k_lab/kl_wishiknew.wav",
"vo/k_lab/kl_yourturn.wav",
"vo/k_lab2/kl_aroundhere.wav",
"vo/k_lab2/kl_atthecitadel01.wav",
"vo/k_lab2/kl_atthecitadel01_b.wav",
"vo/k_lab2/kl_aweekago01.wav",
"vo/k_lab2/kl_blowyoustruck01.wav",
"vo/k_lab2/kl_blowyoustruck02.wav",
"vo/k_lab2/kl_cantleavelamarr.wav",
"vo/k_lab2/kl_cantleavelamarr_b.wav",
"vo/k_lab2/kl_comeoutlamarr.wav",
"vo/k_lab2/kl_dontgiveuphope02.wav",
"vo/k_lab2/kl_dontgiveuphope03.wav",
"vo/k_lab2/kl_givenuphope.wav",
"vo/k_lab2/kl_greatscott.wav",
"vo/k_lab2/kl_howandwhen01.wav",
"vo/k_lab2/kl_howandwhen02.wav",
"vo/k_lab2/kl_lamarr.wav",
"vo/k_lab2/kl_lamarrwary01.wav",
"vo/k_lab2/kl_lamarrwary02.wav",
"vo/k_lab2/kl_nolongeralone.wav",
"vo/k_lab2/kl_nolongeralone_b.wav",
"vo/k_lab2/kl_notallhopeless.wav",
"vo/k_lab2/kl_notallhopeless_b.wav",
"vo/k_lab2/kl_onehedy.wav",
"vo/k_lab2/kl_slowteleport01.wav",
"vo/k_lab2/kl_slowteleport01_b.wav",
"vo/k_lab2/kl_slowteleport02.wav"}
