//The effect when you wrap a dead body in gift wrap
/obj/effect/spresent
	name = "strange present"
	desc = "It's a ... present?"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "strangepresent"
	density = TRUE
	anchored = FALSE


/obj/effect/beam
	name = "beam"
	var/def_zone
	allow_pass_flags = PASS_LOW_STRUCTURE


/obj/effect/begin
	name = "begin"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "begin"
	anchored = TRUE




/obj/effect/list_container
	name = "list container"

/obj/effect/list_container/mobl
	name = "mobl"
	var/master = null

	var/list/container = list(  )

/obj/effect/projection
	name = "Projection"
	desc = "This looks like a projection of something."
	anchored = TRUE

/obj/effect/soundplayer
	anchored = TRUE
	opacity = FALSE
	icon_state = "speaker"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	///The sound we want to loop
	var/datum/looping_sound/loop_sound
	///The typepath of our looping sound datum
	var/sound_type
	///Do we start immediately
	var/start_on_init = TRUE

/obj/effect/soundplayer/Initialize(mapload)
	. = ..()
	if(!sound_type)
		return INITIALIZE_HINT_QDEL
	icon_state = ""
	loop_sound = new sound_type(null, FALSE)
	if(start_on_init)
		loop_sound.start(src)

/obj/effect/soundplayer/Destroy()
	. = ..()
	QDEL_NULL(loop_sound)

/obj/effect/soundplayer/deltaplayer
	sound_type = /datum/looping_sound/alarm_loop
	start_on_init = FALSE

/obj/effect/soundplayer/deltaplayer/Initialize(mapload)
	. = ..()
	GLOB.ship_alarms += src
	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(on_alert_change))

/// Start/stop our active sound player when the alert level changes to/from `SEC_LEVEL_DELTA`
/obj/effect/soundplayer/deltaplayer/proc/on_alert_change(datum/source, datum/security_level/next_level, datum/security_level/previous_level)
	SIGNAL_HANDLER
	if(!(next_level.sec_level_flags & SEC_LEVEL_FLAG_STATE_OF_EMERGENCY))
		loop_sound.stop(src)
	else
		loop_sound.start(src)

/obj/effect/soundplayer/deltaplayer/Destroy()
	. = ..()
	GLOB.ship_alarms -= src

/obj/effect/soundplayer/riverplayer
	sound_type = /datum/looping_sound/river_loop

/obj/effect/soundplayer/dripplayer
	sound_type = /datum/looping_sound/drip_loop

/obj/effect/soundplayer/waterreservoirplayer
	sound_type = /datum/looping_sound/water_res_loop

/obj/effect/forcefield
	anchored = TRUE
	opacity = FALSE
	density = TRUE
	icon_state = "blocker"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = RESIST_ALL

/obj/effect/forcefield/Initialize(mapload)
	. = ..()
	if(icon_state == "blocker")
		icon_state = ""

/obj/effect/forcefield/allow_bullet_travel
	resistance_flags = RESIST_ALL | PROJECTILE_IMMUNE

/obj/effect/forcefield/fog
	name = "dense fog"
	desc = "It looks way too dangerous to traverse. Best wait until it has cleared up."
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	opacity = TRUE
	explosion_block = INFINITY

/obj/effect/forcefield/fog/Initialize(mapload)
	. = ..()
	dir = pick(CARDINAL_DIRS)
	GLOB.fog_blockers += src

/obj/effect/forcefield/fog/Destroy()
	GLOB.fog_blockers -= src
	return ..()


/obj/effect/forcefield/fog/attack_hand(mob/living/user)
	to_chat(user, span_notice("You peer through the fog, but it's impossible to tell what's on the other side..."))
	return TRUE


/obj/effect/forcefield/fog/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	return attack_hand(xeno_attacker)


/obj/effect/forcefield/fog/attack_animal(M)
	return attack_hand(M)


/obj/effect/forcefield/fog/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(isobj(mover)) //No grenades/bullets should cross this
		return FALSE
	if(isxeno(mover))
		return TRUE
	if(ishuman(mover) && !issynth(mover))
		var/mob/living/carbon/human/H = mover
		if(HAS_TRAIT(H, TRAIT_UNDEFIBBABLE)) // Allow pulled perma-dead humans to cross
			return TRUE
	return FALSE

/obj/effect/forcefield/fog/passable_fog
	name = "fog"
	desc = "It looks dangerous to traverse."
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	density = FALSE
	resistance_flags = RESIST_ALL|PROJECTILE_IMMUNE

/obj/effect/forcefield/fog/passable_fog/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/effect/forcefield/fog/passable_fog/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	return TRUE

/obj/effect/forcefield/fog/passable_fog/proc/on_cross(datum/source, atom/movable/mover, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(!opacity)
		return
	set_opacity(FALSE)
	alpha = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	addtimer(CALLBACK(src, PROC_REF(reset)), 30 SECONDS)

/obj/effect/forcefield/fog/passable_fog/proc/reset()
	alpha = initial(alpha)
	mouse_opacity = initial(mouse_opacity)
	set_opacity(TRUE)

//used to control opacity of multitiles doors
/obj/effect/opacifier
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	resistance_flags = RESIST_ALL
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_AIRLOCK)

/obj/effect/opacifier/Initialize(mapload, initial_opacity)
	. = ..()
	set_opacity(initial_opacity)

/obj/effect/opacifier/Destroy()
	. = ..()
	QUEUE_SMOOTH_NEIGHBORS(loc)

/obj/effect/supplypod_selector
	icon_state = "supplypod_selector"
	layer = FLY_LAYER


/obj/effect/dummy/lighting_obj
	name = "lighting fx obj"
	desc = "Tell a coder if you're seeing this."
	icon_state = "nothing"
	light_color = "#FFFFFF"
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	light_system = MOVABLE_LIGHT
	blocks_emissive = EMISSIVE_BLOCK_NONE

/obj/effect/dummy/lighting_obj/Initialize(mapload, _color, _range, _power, _duration)
	. = ..()
	if(!isnull(_range))
		set_light_range(_range)
	if(!isnull(_power))
		set_light_power(_power)
	if(!isnull(_color))
		set_light_color(_color)
	if(_duration)
		QDEL_IN(src, _duration)


/obj/effect/dummy/lighting_obj/moblight
	name = "mob lighting fx"


/obj/effect/dummy/lighting_obj/moblight/Initialize(mapload, _color, _range, _power, _duration)
	. = ..()
	if(!ismob(loc))
		return INITIALIZE_HINT_QDEL


/obj/effect/overlay/temp/timestop_effect
	icon = 'icons/effects/160x160.dmi'
	icon_state = "time"
	layer = FLY_LAYER
	plane = GAME_PLANE
	alpha = 70

///hologram alt appearance key
#define HOLO_INVIS_ALT_APPEARANCE "holo_invis_alt_appearance"

/obj/effect/build_hologram
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	smoothing_groups = list(SMOOTH_GROUP_HOLOGRAM)
	canSmoothWith = list(SMOOTH_GROUP_HOLOGRAM)
	alpha = 190

/obj/effect/build_hologram/Initialize(mapload, atom/copy_type, modify_color = FALSE, mob/owner)
	if(!ispath(copy_type))
		return INITIALIZE_HINT_QDEL

	icon = initial(copy_type.icon)
	icon_state = initial(copy_type.icon_state)
	base_icon_state = initial(copy_type.base_icon_state)
	color = initial(copy_type.color)
	smoothing_flags = initial(copy_type.smoothing_flags)
	. = ..()
	makeHologram(0.7, modify_color)

	var/image/disguised_icon = image(loc = src)
	disguised_icon.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/all_but_one_person, HOLO_INVIS_ALT_APPEARANCE, disguised_icon, owner)

/obj/effect/build_hologram/Destroy()
	remove_alt_appearance(HOLO_INVIS_ALT_APPEARANCE)
	return ..()
