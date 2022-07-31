//The effect when you wrap a dead body in gift wrap
/atom/movable/effect/spresent
	name = "strange present"
	desc = "It's a ... present?"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "strangepresent"
	density = TRUE
	anchored = FALSE


/atom/movable/effect/beam
	name = "beam"
	var/def_zone
	flags_pass = PASSTABLE


/atom/movable/effect/begin
	name = "begin"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "begin"
	anchored = TRUE




/atom/movable/effect/list_container
	name = "list container"

/atom/movable/effect/list_container/mobl
	name = "mobl"
	var/master = null

	var/list/container = list(  )

/atom/movable/effect/projection
	name = "Projection"
	desc = "This looks like a projection of something."
	anchored = TRUE


/atom/movable/effect/shut_controller
	name = "shut controller"
	var/moving = null
	var/list/parts = list(  )




//Exhaust effect
/atom/movable/effect/engine_exhaust
	name = "engine exhaust"
	icon = 'icons/effects/effects.dmi'
	icon_state = "exhaust"
	anchored = TRUE

	New(var/turf/nloc, var/ndir, var/temp)
		setDir(ndir)
		..(nloc)

		spawn(20)
			loc = null



/atom/movable/effect/rune/attunement
	luminosity = 5

/atom/movable/effect/soundplayer
	anchored = TRUE
	opacity = FALSE
	density = TRUE
	icon_state = "speaker"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/datum/looping_sound/alarm_loop/deltalarm

/atom/movable/effect/soundplayer/Initialize()
	. = ..()
	deltalarm = new(null, FALSE)
	GLOB.ship_alarms += src
	icon_state = ""

/atom/movable/effect/soundplayer/Destroy()
	. = ..()
	QDEL_NULL(deltalarm)
	GLOB.ship_alarms -= src

/atom/movable/effect/forcefield
	anchored = TRUE
	opacity = FALSE
	density = TRUE
	icon_state = "blocker"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/effect/forcefield/Initialize()
	. = ..()
	if(icon_state == "blocker")
		icon_state = ""

/atom/movable/effect/forcefield/fog
	name = "dense fog"
	desc = "It looks way too dangerous to traverse. Best wait until it has cleared up."
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	opacity = TRUE

/atom/movable/effect/forcefield/fog/Initialize()
	. = ..()
	dir  = pick(CARDINAL_DIRS)
	GLOB.fog_blockers += src

/atom/movable/effect/forcefield/fog/Destroy()
	GLOB.fog_blockers -= src
	return ..()


/atom/movable/effect/forcefield/fog/attack_hand(mob/living/user)
	to_chat(user, span_notice("You peer through the fog, but it's impossible to tell what's on the other side..."))
	return TRUE


/atom/movable/effect/forcefield/fog/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	return attack_hand(X)


/atom/movable/effect/forcefield/fog/attack_animal(M)
	return attack_hand(M)


/atom/movable/effect/forcefield/fog/CanAllowThrough(atom/movable/mover, turf/target)
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

/atom/movable/effect/forcefield/fog/passable_fog
	name = "fog"
	desc = "It looks dangerous to traverse."
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	density = FALSE

/atom/movable/effect/forcefield/fog/passable_fog/Initialize()
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_cross,
	)
	AddElement(/datum/element/connect_loc, connections)

/atom/movable/effect/forcefield/fog/passable_fog/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	return TRUE

/atom/movable/effect/forcefield/fog/passable_fog/proc/on_cross(datum/source, atom/movable/mover, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(!opacity)
		return
	set_opacity(FALSE)
	alpha = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	addtimer(CALLBACK(src, .proc/reset), 30 SECONDS)

/atom/movable/effect/forcefield/fog/passable_fog/proc/reset()
	alpha = initial(alpha)
	mouse_opacity = initial(mouse_opacity)
	set_opacity(TRUE)

//used to control opacity of multitiles doors
/atom/movable/effect/opacifier
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	resistance_flags = RESIST_ALL
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/effect/opacifier/Initialize(mapload, initial_opacity)
	. = ..()
	set_opacity(initial_opacity)


/atom/movable/effect/supplypod_selector
	icon_state = "supplypod_selector"
	layer = FLY_LAYER


/atom/movable/effect/dummy/lighting_obj
	name = "lighting fx obj"
	desc = "Tell a coder if you're seeing this."
	icon_state = "nothing"
	light_color = "#FFFFFF"
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	light_system = MOVABLE_LIGHT
	blocks_emissive = NONE

/atom/movable/effect/dummy/lighting_obj/Initialize(mapload, _color, _range, _power, _duration)
	. = ..()
	if(!isnull(_range))
		set_light_range(_range)
	if(!isnull(_power))
		set_light_power(_power)
	if(!isnull(_color))
		set_light_color(_color)
	if(_duration)
		QDEL_IN(src, _duration)


/atom/movable/effect/dummy/lighting_obj/moblight
	name = "mob lighting fx"


/atom/movable/effect/dummy/lighting_obj/moblight/Initialize(mapload, _color, _range, _power, _duration)
	. = ..()
	if(!ismob(loc))
		return INITIALIZE_HINT_QDEL


//Makes a tile fully lit no matter what
/atom/movable/effect/fullbright
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "white"
	plane = LIGHTING_PLANE
	layer = BACKGROUND_LAYER + LIGHTING_PRIMARY_LAYER
	blend_mode = BLEND_ADD

/atom/movable/effect/overlay/temp/timestop_effect
	icon = 'icons/effects/160x160.dmi'
	icon_state = "time"
	layer = FLY_LAYER
	plane = GAME_PLANE
	alpha = 70
