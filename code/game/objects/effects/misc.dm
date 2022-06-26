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
	flags_pass = PASSTABLE


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


/obj/effect/shut_controller
	name = "shut controller"
	var/moving = null
	var/list/parts = list(  )




//Exhaust effect
/obj/effect/engine_exhaust
	name = "engine exhaust"
	icon = 'icons/effects/effects.dmi'
	icon_state = "exhaust"
	anchored = TRUE

	New(var/turf/nloc, var/ndir, var/temp)
		setDir(ndir)
		..(nloc)

		spawn(20)
			loc = null



/obj/effect/rune/attunement
	luminosity = 5



/obj/effect/forcefield
	anchored = TRUE
	opacity = FALSE
	density = TRUE
	icon_state = "blocker"


/obj/effect/forcefield/fog
	name = "dense fog"
	desc = "It looks way too dangerous to traverse. Best wait until it has cleared up."
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	opacity = TRUE


/obj/effect/forcefield/fog/Initialize()
	. = ..()
	dir  = pick(CARDINAL_DIRS)
	GLOB.fog_blockers += src
	if(icon_state == "blocker")
		icon_state = ""


/obj/effect/forcefield/fog/Destroy()
	GLOB.fog_blockers -= src
	return ..()


/obj/effect/forcefield/fog/attack_hand(mob/living/user)
	to_chat(user, span_notice("You peer through the fog, but it's impossible to tell what's on the other side..."))
	return TRUE


/obj/effect/forcefield/fog/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	return attack_hand(X)


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

/obj/effect/forcefield/fog/passable_fog/Initialize()
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_cross,
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
	addtimer(CALLBACK(src, .proc/reset), 30 SECONDS)

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

/obj/effect/opacifier/Initialize(mapload, initial_opacity)
	. = ..()
	set_opacity(initial_opacity)


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
	blocks_emissive = NONE

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


//Makes a tile fully lit no matter what
/obj/effect/fullbright
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "white"
	plane = LIGHTING_PLANE
	layer = BACKGROUND_LAYER + LIGHTING_PRIMARY_LAYER
	blend_mode = BLEND_ADD

/obj/effect/overlay/temp/timestop_effect
	icon = 'icons/effects/160x160.dmi'
	icon_state = "time"
	layer = FLY_LAYER
	plane = GAME_PLANE
	alpha = 70
