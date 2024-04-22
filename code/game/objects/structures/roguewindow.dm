
/obj/structure/roguewindow
	name = "window"
	desc = ""
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "window-solid"
	layer = TABLE_LAYER
	density = TRUE
	anchored = TRUE
	opacity = FALSE
	max_integrity = 800
	integrity_failure = 0.1
	var/base_state = "window-solid"
	var/lockdir = 0
	var/brokenstate = 0
	blade_dulling = DULLING_BASHCHOP
	pass_flags = LETPASSTHROW
	climb_time = 20
	climb_offset = 10
	attacked_sound = 'sound/combat/hits/onglass/glasshit.ogg'
	break_sound = "glassbreak"
	destroy_sound = 'sound/combat/hits/onwood/destroywalldoor.ogg'

/obj/structure/roguewindow/Initialize()
	update_icon()
	..()

/obj/structure/roguewindow/update_icon()
	if(brokenstate)
		icon_state = "[base_state]br"
		return
	icon_state = "[base_state]"

/obj/structure/roguewindow/stained
	icon_state = "stained-silver"
	base_state = "stained-silver"
	opacity = TRUE
	max_integrity = 100
	integrity_failure = 0.75

/obj/structure/roguewindow/openclose
	icon_state = "woodwindowdir"
	base_state = "woodwindow"
	opacity = TRUE
	max_integrity = 100
	integrity_failure = 0.9

/obj/structure/roguewindow/openclose/Initialize()
	lockdir = dir
	icon_state = base_state
	GLOB.TodUpdate += src
	..()

/obj/structure/roguewindow/openclose/Destroy()
	GLOB.TodUpdate -= src
	return ..()

/obj/structure/roguewindow/openclose/update_tod(todd)
	update_icon()

/obj/structure/roguewindow/openclose/update_icon()
	var/isnight = FALSE
	if(GLOB.tod == "night")
		isnight = TRUE
	if(brokenstate)
		if(isnight)
			icon_state = "[base_state]br"
		else
			icon_state = "w-[base_state]br"
		return
	if(climbable)
		if(isnight)
			icon_state = "[base_state]op"
		else
			icon_state = "w-[base_state]op"
	else
		if(isnight)
			icon_state = "[base_state]"
		else
			icon_state = "w-[base_state]"

/obj/structure/roguewindow/openclose/attack_right(mob/user)
	if(get_dir(src,user) == lockdir)
		if(brokenstate)
			to_chat(user, "<span class='warning'>It's broken, that would be foolish.</span>")
			return
		if(climbable)
			close_up(user)
		else
			open_up(user)
	else
		to_chat(user, "<span class='warning'>The window doesn't close from this side.</span>")

/obj/structure/roguewindow/proc/open_up(mob/user)
	visible_message("<span class='info'>[user] opens [src].</span>")
	playsound(src, 'sound/foley/doors/windowup.ogg', 100, FALSE)
	climbable = TRUE
	opacity = FALSE
	update_icon()

/obj/structure/roguewindow/proc/close_up(mob/user)
	visible_message("<span class='info'>[user] closes [src].</span>")
	playsound(src, 'sound/foley/doors/windowdown.ogg', 100, FALSE)
	climbable = FALSE
	opacity = TRUE
	update_icon()

/obj/structure/roguewindow/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSTABLE) && climbable)
		return 1
	if(isliving(mover))
		if(mover.throwing)
			if(!climbable)
				take_damage(10)
			if(brokenstate)
				return 1
	else if(isitem(mover))
		var/obj/item/I = mover
		if(I.throwforce >= 10)
			take_damage(10)
			if(brokenstate)
				return 1
		else
			return !density
	return ..()

/obj/structure/roguewindow/attackby(obj/item/W, mob/user, params)
	return ..()

/obj/structure/roguewindow/attack_paw(mob/living/user)
	attack_hand(user)

/obj/structure/roguewindow/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(brokenstate)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	src.visible_message("<span class='info'>[user] knocks on [src].</span>")
	add_fingerprint(user)
	playsound(src, 'sound/misc/glassknock.ogg', 100)

/obj/structure/roguewindow/obj_break(damage_flag)
	if(!brokenstate)
		attacked_sound = list('sound/combat/hits/onwood/woodimpact (1).ogg','sound/combat/hits/onwood/woodimpact (2).ogg')
		new /obj/item/shard (get_turf(src))
		climbable = TRUE
		brokenstate = TRUE
		opacity = FALSE
	update_icon()
	..()
