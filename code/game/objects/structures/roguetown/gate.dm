GLOBAL_LIST_EMPTY(biggates)

/obj/structure/gate
	name = "gate"
	desc = ""
	icon = 'icons/roguetown/misc/gate.dmi'
	icon_state = "gate1"
	density = TRUE
	anchored = TRUE
	blade_dulling = DULLING_BASHCHOP
	max_integrity = 5000
	bound_width = 96
	appearance_flags = NONE
	opacity = TRUE
	var/base_state = "gate"
	var/isSwitchingStates = FALSE
	var/list/turfsy = list()
	var/list/blockers = list()
	var/gid
	attacked_sound = list('sound/combat/hits/onmetal/sheet (1).ogg', 'sound/combat/hits/onmetal/sheet (2).ogg')
	var/obj/structure/attached_to

/obj/structure/gate/preopen
	icon_state = "gate0"

/obj/structure/gate/preopen/Initialize()
	. = ..()
	open()

/obj/structure/gate/bars
	icon_state = "bar1"
	base_state = "bar"
	opacity = FALSE

/obj/structure/gate/bars/preopen
	icon_state = "bar0"

/obj/structure/gate/bars/preopen/Initialize()
	. = ..()
	open()

/obj/gblock
	name = ""
	desc = ""
	icon = null
	mouse_opacity = 0
	opacity = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/structure/gate/Initialize()
	. = ..()
	update_icon()
	if(initial(opacity))
		var/turf/T = loc
		var/G = new /obj/gblock(T)
		turfsy += T
		blockers += G
		T = get_step(T, EAST)
		G = new /obj/gblock(T)
		turfsy += T
		blockers += G
		T = get_step(T, EAST)
		G = new /obj/gblock(T)
		turfsy += T
		blockers += G
	GLOB.biggates += src

/obj/structure/gate/Destroy()
	for(var/A in blockers)
		qdel(A)
	if(attached_to)
		var/obj/structure/winch/W = attached_to
		W.attached_gate = null
	..()

/obj/structure/gate/update_icon()
	cut_overlays()
	icon_state = "[base_state][density]"
	if(!density && !isSwitchingStates)
		add_overlay(mutable_appearance(icon, "[base_state]0_part", ABOVE_MOB_LAYER))
	else
		add_overlay(mutable_appearance(icon, "[base_state]1_part", ABOVE_MOB_LAYER))

/obj/structure/gate/proc/toggle()
	if(density)
		open()
	else
		close()

/obj/structure/gate/proc/open()
	if(isSwitchingStates || !density)
		return
	isSwitchingStates = TRUE
	playsound(src, 'sound/misc/gate.ogg', 100, extrarange = 5)
	flick("[base_state]_opening",src)
	layer = initial(layer)
	sleep(15)
	density = FALSE
	opacity = FALSE
	for(var/obj/gblock/B in blockers)
		B.opacity = FALSE
	isSwitchingStates = FALSE
	update_icon()


/obj/structure/gate/proc/close()
	if(isSwitchingStates || density)
		return
	isSwitchingStates = TRUE
	update_icon()
	layer = ABOVE_MOB_LAYER
	playsound(src, 'sound/misc/gate.ogg', 100, extrarange = 5)
	flick("[base_state]_closing",src)
	sleep(10)
	for(var/turf/T in turfsy)
		for(var/mob/living/M in T)
			M.gib()
	density = initial(density)
	opacity = initial(opacity)
	layer = initial(layer)
	for(var/obj/gblock/B in blockers)
		B.opacity = TRUE
	isSwitchingStates = FALSE
	update_icon()

/obj/structure/winch
	name = "winch"
	desc = ""
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "winch"
	density = TRUE
	anchored = TRUE
	max_integrity = 0
	var/gid
	var/obj/structure/gate/attached_gate

/obj/structure/winch/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/winch/Destroy()
	if(attached_gate)
		var/obj/structure/gate/W = attached_gate
		W.attached_to = null
	..()

/obj/structure/winch/LateInitialize()
	for(var/obj/structure/gate/G in GLOB.biggates)
		if(G.gid == gid)
			GLOB.biggates -= G
			attached_gate = G
			G.attached_to = src

/obj/structure/winch/attack_hand(mob/user)
	. = ..()
	if(!attached_gate)
		to_chat(user, "<span class='warning'>The chain is not attached to anything.</span>")
		return
	if(attached_gate.isSwitchingStates)
		return
	if(isliving(user))
		var/mob/living/L = user
		L.changeNext_move(CLICK_CD_MELEE)
		var/used_time = 105 - (L.STASTR * 10)
		user.visible_message("<span class='warning'>[user] cranks the winch.</span>")
		playsound(src, 'sound/foley/winch.ogg', 100, extrarange = 3)
		if(do_after(user, used_time, target = user))
			attached_gate.toggle()

