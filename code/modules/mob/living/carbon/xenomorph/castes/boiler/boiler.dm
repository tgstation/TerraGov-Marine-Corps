/mob/living/carbon/xenomorph/boiler
	caste_base_type = /mob/living/carbon/xenomorph/boiler
	name = "Boiler"
	desc = "A huge, grotesque xenomorph covered in glowing, oozing acid slime."
	icon = 'icons/Xeno/castes/boiler.dmi'
	icon_state = "Boiler Walking"
	bubble_icon = "alienroyal"
	health = 200
	maxHealth = 200
	plasma_stored = 450
	pixel_x = -16
	old_x = -16
	mob_size = MOB_SIZE_BIG
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_NORMAL
	gib_chance = 100
	drag_delay = 6 //pulling a big dead xeno is hard
	var/datum/effect_system/smoke_spread/xeno/smoke
	//Boiler ammo
	var/corrosive_ammo = 0
	var/neuro_ammo = 0

/mob/living/carbon/xenomorph/boiler/get_liquid_slowdown()
	return BOILER_WATER_SLOWDOWN

///updates the boiler's glow, based on its base glow/color, and its ammo reserves. More green ammo = more green glow; more yellow = more yellow.
/mob/living/carbon/xenomorph/boiler/proc/update_boiler_glow()
	var/current_ammo = corrosive_ammo + neuro_ammo
	var/ammo_glow = BOILER_LUMINOSITY_AMMO * current_ammo
	var/glow = CEILING(BOILER_LUMINOSITY_BASE + ammo_glow, 1)
	var/color = BOILER_LUMINOSITY_BASE_COLOR
	if(current_ammo)
		var/ammo_color = BlendRGB(BOILER_LUMINOSITY_AMMO_CORROSIVE_COLOR, BOILER_LUMINOSITY_AMMO_NEUROTOXIN_COLOR, neuro_ammo/current_ammo)
		color = BlendRGB(color, ammo_color, (ammo_glow*2)/glow)
	if(!light_on && glow >= BOILER_LUMINOSITY_THRESHOLD)
		set_light_on(TRUE)
	else if(glow < BOILER_LUMINOSITY_THRESHOLD && !fire_luminosity)
		set_light_range_power_color(0, 0)
		set_light_on(FALSE)
	set_light_range_power_color(glow, 4, color)

// ***************************************
// *********** Init
// ***************************************
/mob/living/carbon/xenomorph/boiler/Initialize(mapload)
	. = ..()
	smoke = new /datum/effect_system/smoke_spread/xeno/acid(src)
	ammo = GLOB.ammo_list[/datum/ammo/xeno/boiler_gas]
	update_boiler_glow()
	RegisterSignal(src, COMSIG_XENOMORPH_GIBBING, PROC_REF(gib_explode))
	RegisterSignal(src, COMSIG_MOB_STAT_CHANGED, PROC_REF(on_stat_change))
	RegisterSignals(src, list(COMSIG_LIVING_STATUS_STUN,
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_LIVING_STATUS_PARALYZE,
		COMSIG_LIVING_STATUS_IMMOBILIZE,
		COMSIG_LIVING_STATUS_UNCONSCIOUS,
		COMSIG_LIVING_STATUS_SLEEP,
		COMSIG_LIVING_STATUS_STAGGER), PROC_REF(on_stun))

// ***************************************
// *********** Gibbing behaviour
// ***************************************
/mob/living/carbon/xenomorph/boiler/proc/gib_explode()
	SIGNAL_HANDLER
	visible_message(span_danger("[src] begins to bulge grotesquely, and explodes in a cloud of corrosive gas!"))
	smoke.set_up(2, get_turf(src))
	smoke.start()

/// Handles boilers changing stat, you unroot yourself if you change stat, like going from conscious to unconscious
/mob/living/carbon/xenomorph/boiler/proc/on_stat_change(datum/source, old_state, new_state)
	SIGNAL_HANDLER
	var/datum/action/ability/activable/xeno/bombard/bombard_action = actions_by_path[/datum/action/ability/activable/xeno/bombard]
	if(HAS_TRAIT_FROM(src, TRAIT_IMMOBILE, BOILER_ROOTED_TRAIT))
		bombard_action.set_rooted(FALSE)

/// Handles getting staggered, stunned and other various debuffs
/mob/living/carbon/xenomorph/boiler/proc/on_stun(datum/source, amount)
	SIGNAL_HANDLER
	if(!(amount > 0) || !HAS_TRAIT_FROM(src, TRAIT_IMMOBILE, BOILER_ROOTED_TRAIT))
		return
	var/datum/action/ability/activable/xeno/bombard/bombard_action = actions_by_path[/datum/action/ability/activable/xeno/bombard]
	balloon_alert_to_viewers("[src] scrambles out of the ground from the impact!")
	bombard_action.set_rooted(FALSE)
