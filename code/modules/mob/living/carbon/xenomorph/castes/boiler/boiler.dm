/mob/living/carbon/xenomorph/boiler
	caste_base_type = /mob/living/carbon/xenomorph/boiler
	name = "Boiler"
	desc = "A huge, grotesque xenomorph covered in glowing, oozing acid slime."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Boiler Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 450
	pixel_x = -16
	old_x = -16
	mob_size = MOB_SIZE_BIG
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_ZERO
	gib_chance = 100
	drag_delay = 6 //pulling a big dead xeno is hard
	var/datum/effect_system/smoke_spread/xeno/smoke
	//Boiler ammo
	var/corrosive_ammo = 0
	var/neuro_ammo = 0

///updates the boiler's glow, based on its base glow/color, and its ammo reserves. More green ammo = more green glow; more yellow = more yellow.
/mob/living/carbon/xenomorph/boiler/proc/update_boiler_glow()
	var/current_ammo = corrosive_ammo + neuro_ammo
	var/ammo_glow = BOILER_LUMINOSITY_AMMO * (current_ammo/2)
	var/glow = CEILING(BOILER_LUMINOSITY_BASE + ammo_glow, 1)
	var/color = BOILER_LUMINOSITY_BASE_COLOR
	if(current_ammo)
		var/ammo_color = BlendRGB(BOILER_LUMINOSITY_AMMO_CORROSIVE_COLOR, BOILER_LUMINOSITY_AMMO_NEUROTOXIN_COLOR, neuro_ammo/current_ammo)
		color = BlendRGB(color, ammo_color, (ammo_glow*2)/glow)
	if(!light_on && glow >= 2)
		set_light_on(TRUE)
	else if(glow < 2 && !fire_luminosity)
		set_light_range_power_color(0, 0)
		set_light_on(FALSE)
	set_light_range_power_color(glow, 4, color)

// ***************************************
// *********** Init
// ***************************************
/mob/living/carbon/xenomorph/boiler/Initialize()
	. = ..()
	smoke = new /datum/effect_system/smoke_spread/xeno/acid(src)
	ammo = GLOB.ammo_list[/datum/ammo/xeno/boiler_gas]
	update_boiler_glow()
	RegisterSignal(src, COMSIG_XENOMORPH_GIBBING, .proc/gib_explode)

// ***************************************
// *********** Gibbing behaviour
// ***************************************
/mob/living/carbon/xenomorph/boiler/proc/gib_explode()
	SIGNAL_HANDLER
	visible_message(span_danger("[src] begins to bulge grotesquely, and explodes in a cloud of corrosive gas!"))
	smoke.set_up(2, get_turf(src))
	smoke.start()
