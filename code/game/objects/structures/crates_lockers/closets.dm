/obj/structure/closet
	name = "closet"
	desc = ""
	icon = 'icons/obj/closet.dmi'
	icon_state = "generic"
	density = TRUE
	drag_slowdown = 1.5		// Same as a prone mob
	max_integrity = 200
	integrity_failure = 0.25
	armor = list("melee" = 20, "bullet" = 10, "laser" = 10, "energy" = 0, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 60)

	var/icon_door = null
	var/icon_door_override = FALSE //override to have open overlay use icon different to its base's
	var/secure = FALSE //secure locker or not, also used if overriding a non-secure locker with a secure door overlay to add fancy lights
	var/opened = FALSE
	var/welded = FALSE
	var/locked = FALSE
	var/large = TRUE
	var/wall_mounted = 0 //never solid (You can always pass over it)
	var/breakout_time = 1200
	var/message_cooldown
	var/can_weld_shut = TRUE
	var/horizontal = FALSE
	var/allow_objects = FALSE
	var/allow_dense = FALSE
	var/dense_when_open = FALSE //if it's dense when open or not
	var/max_mob_size = MOB_SIZE_HUMAN //Biggest mob_size accepted by the container
	var/mob_storage_capacity = 2 // how many human sized mob/living can fit together inside a closet.
	var/storage_capacity = 30 //This is so that someone can't pack hundreds of items in a locker/crate then open it in a populated area to crash clients.
	var/cutting_tool = /obj/item/weldingtool
	var/open_sound = 'sound/misc/cupboard_open.ogg'
	var/close_sound = 'sound/misc/cupboard_close.ogg'
	var/open_sound_volume = 100
	var/close_sound_volume = 100
	var/material_drop
	var/material_drop_amount = 2
	var/delivery_icon = "deliverycloset" //which icon to use when packagewrapped. null to be unwrappable.
	var/anchorable = TRUE
	var/icon_welded = "welded"
	var/keylock = FALSE
	var/lockhash
	var/lockid = null
	var/masterkey = FALSE
	throw_speed = 1
	throw_range = 1
	anchored = FALSE

/obj/structure/closet/pre_sell()
	open()
	..()

/obj/structure/closet/Initialize(mapload)
	if(mapload && !opened)		// if closed, any item at the crate's loc is put in the contents
		addtimer(CALLBACK(src, .proc/take_contents), 0)
	. = ..()
	update_icon()
	PopulateContents()

	if(lockhash)
		GLOB.lockhashes += lockhash
	else if(keylock)
		if(lockid)
			if(GLOB.lockids[lockid])
				lockhash = GLOB.lockids[lockid]
			else
				lockhash = rand(1000,9999)
				while(lockhash in GLOB.lockhashes)
					lockhash = rand(1000,9999)
				GLOB.lockhashes += lockhash
				GLOB.lockids[lockid] = lockhash
		else
			lockhash = rand(1000,9999)
			while(lockhash in GLOB.lockhashes)
				lockhash = rand(1000,9999)
			GLOB.lockhashes += lockhash

//USE THIS TO FILL IT, NOT INITIALIZE OR NEW
/obj/structure/closet/proc/PopulateContents()
	return

/obj/structure/closet/Destroy()
	dump_contents()
	return ..()

/obj/structure/closet/update_icon()
	cut_overlays()
	if(!opened)
		layer = OBJ_LAYER
		if(icon_door)
			add_overlay("[icon_door]_door")
		else
			add_overlay("[icon_state]_door")
		if(welded)
			add_overlay(icon_welded)
		if(secure && !broken)
			if(locked)
				add_overlay("locked")
			else
				add_overlay("unlocked")

	else
		layer = BELOW_OBJ_LAYER
		if(icon_door_override)
			add_overlay("[icon_door]_open")
		else
			add_overlay("[icon_state]_open")

/obj/structure/closet/examine(mob/user)
	. = ..()
/*	if(welded)
		. += "<span class='notice'>It's welded shut.</span>"
	if(anchored)
		. += "<span class='notice'>It is <b>bolted</b> to the ground.</span>"
	if(opened)
		. += "<span class='notice'>The parts are <b>welded</b> together.</span>"
	else if(secure && !opened)
		. += "<span class='notice'>Alt-click to [locked ? "unlock" : "lock"].</span>"
	if(isliving(user))
		var/mob/living/L = user
		if(HAS_TRAIT(L, TRAIT_SKITTISH))
			. += "<span class='notice'>Ctrl-Shift-click [src] to jump inside.</span>"*/

/obj/structure/closet/CanPass(atom/movable/mover, turf/target)
	if(wall_mounted)
		return TRUE
	return !density

/obj/structure/closet/proc/can_open(mob/living/user)
	if(welded || locked)
		if(user)
			to_chat(user, "<span class='warning'>Locked.</span>" )
		return FALSE
//	var/turf/T = get_turf(src)
//	for(var/mob/living/L in T)
//		if(L.anchored || horizontal && L.mob_size > MOB_SIZE_TINY && L.density)
//			if(user)
//				to_chat(user, "<span class='danger'>There's something large on top of [src], preventing it from opening.</span>" )
//			return FALSE
	return TRUE

/obj/structure/closet/proc/can_close(mob/living/user)
//	var/turf/T = get_turf(src)
//	for(var/obj/structure/closet/closet in T)
//		if(closet != src && !closet.wall_mounted)
//			return FALSE
//	for(var/mob/living/L in T)
//		if(L.anchored || horizontal && L.mob_size > MOB_SIZE_TINY && L.density)
//			if(user)
//				to_chat(user, "<span class='danger'>There's something too large in [src], preventing it from closing.</span>")
//			return FALSE
	return TRUE

/obj/structure/closet/dump_contents()
	var/atom/L = drop_location()
	for(var/atom/movable/AM in src)
		AM.forceMove(L)
		if(throwing) // you keep some momentum when getting out of a thrown closet
			step(AM, dir)
	if(throwing)
		throwing.finalize(FALSE)

/obj/structure/closet/proc/take_contents()
	var/atom/L = drop_location()
	for(var/atom/movable/AM in L)
		if(AM != src && insert(AM) == -1) // limit reached
			break

/obj/structure/closet/proc/open(mob/living/user)
	if(opened)
		return
	if(user)
		if(!can_open(user))
			return
	playsound(loc, open_sound, open_sound_volume, FALSE, -3)
	opened = TRUE
	if(!dense_when_open)
		density = FALSE
//	climb_time *= 0.5 //it's faster to climb onto an open thing
	dump_contents()
	update_icon()
	return 1

/obj/structure/closet/proc/insert(atom/movable/AM)
	if(contents.len >= storage_capacity)
		return -1
	if(insertion_allowed(AM))
		AM.forceMove(src)
		return TRUE
	else
		return FALSE

/obj/structure/closet/proc/insertion_allowed(atom/movable/AM)
	if(ismob(AM))
		testing("begin")
		if(!isliving(AM)) //let's not put ghosts or camera mobs inside closets...
			return FALSE
		var/mob/living/L = AM
		if(L.anchored || (L.buckled && L.buckled != src) || L.incorporeal_move || L.has_buckled_mobs())
			return FALSE
		if(L.mob_size > MOB_SIZE_TINY) // Tiny mobs are treated as items.
			if(horizontal && L.density)
				return FALSE
			if(L.mob_size > max_mob_size)
				return FALSE
			var/mobs_stored = 0
			for(var/mob/living/M in contents)
				if(++mobs_stored >= mob_storage_capacity)
					return FALSE
			for(var/obj/structure/closet/crate/C in contents)
				if(C != src)
					return FALSE
		testing("enmd")
		L.stop_pulling()

	else if(isobj(AM))
		if((!allow_dense && AM.density) || AM.anchored || AM.has_buckled_mobs())
			return FALSE
		else if(isitem(AM) && !HAS_TRAIT(AM, TRAIT_NODROP))
			return TRUE
		else if(!allow_objects && !istype(AM, /obj/effect/dummy/chameleon))
			return FALSE
//		for(var/mob/living/M in contents)
//			return FALSE
	else
		return FALSE

	return TRUE

/obj/structure/closet/proc/close(mob/living/user)
	if(!opened)
		return FALSE
	if(user)
		if(!can_close(user))
			return FALSE
	take_contents()
	playsound(loc, close_sound, close_sound_volume, FALSE, -3)
//	climb_time = initial(climb_time)
	opened = FALSE
	density = TRUE
	update_icon()
	return TRUE

/obj/structure/closet/proc/toggle(mob/living/user)
	if(opened)
		return close(user)
	else
		return open(user)

/obj/structure/closet/deconstruct(disassembled = TRUE)
	if(ispath(material_drop) && material_drop_amount && !(flags_1 & NODECONSTRUCT_1))
		new material_drop(loc, material_drop_amount)
	qdel(src)

/obj/structure/closet/obj_break(damage_flag)
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
		bust_open()
	..()


/obj/structure/closet/attackby(obj/item/W, mob/user, params)
	if(user in src)
		return
	if(istype(W, /obj/item/roguekey) || istype(W, /obj/item/keyring))
		trykeylock(W, user)
		return
	if(src.tool_interact(W,user))
		return 1 // No afterattack
	else
		return ..()

/obj/structure/closet/proc/trykeylock(obj/item/I, mob/user)
	if(opened)
		return
	if(!keylock)
		to_chat(user, "<span class='warning'>There's no lock on this.</span>")
		return
	if(broken)
		to_chat(user, "<span class='warning'>The lock is broken.</span>")
		return
	if(istype(I,/obj/item/keyring))
		var/obj/item/keyring/R = I
		if(!R.keys.len)
			return
		var/list/keysy = shuffle(R.keys.Copy())
		for(var/obj/item/roguekey/K in keysy)
			if(user.cmode)
				if(!do_after(user, 10, TRUE, src))
					break
			if(K.lockhash == lockhash)
				togglelock(user)
				break
			else
				if(user.cmode)
					playsound(src, 'sound/foley/doors/lockrattle.ogg', 100)
		return
	else
		var/obj/item/roguekey/K = I
		if(K.lockhash == lockhash)
			togglelock(user)
			return
		else
			playsound(src, 'sound/foley/doors/lockrattle.ogg', 100)

/obj/structure/closet/proc/tool_interact(obj/item/W, mob/user)//returns TRUE if attackBy call shouldnt be continued (because tool was used/closet was of wrong type), FALSE if otherwise
	. = TRUE
	if(opened)
		if(user.transferItemToLoc(W, drop_location())) // so we put in unlit welder too
			return



/obj/structure/closet/proc/after_weld(weld_state)
	return

/obj/structure/closet/MouseDrop_T(atom/movable/O, mob/living/user)
	if(!istype(O) || O.anchored || istype(O, /obj/screen))
		return
	if(!istype(user) || user.incapacitated() || !(user.mobility_flags & MOBILITY_STAND))
		return
	if(!Adjacent(user) || !user.Adjacent(O))
		return
	if(user == O) //try to climb onto it
		return ..()
	if(!opened)
		return
	if(!isturf(O.loc))
		return

	var/actuallyismob = 0
	if(isliving(O))
		actuallyismob = 1
	else if(!isitem(O))
		return
	var/turf/T = get_turf(src)
	var/list/targets = list(O, src)
	add_fingerprint(user)
	user.visible_message("<span class='warning'>[user] [actuallyismob ? "tries to ":""]stuff [O] into [src].</span>", \
				 	 	"<span class='warning'>I [actuallyismob ? "try to ":""]stuff [O] into [src].</span>", \
				 	 	"<span class='hear'>I hear clanging.</span>")
	if(actuallyismob)
		if(do_after_mob(user, targets, 40))
			user.visible_message("<span class='notice'>[user] stuffs [O] into [src].</span>", \
							 	 "<span class='notice'>I stuff [O] into [src].</span>", \
							 	 "<span class='hear'>I hear a loud bang.</span>")
			var/mob/living/L = O
			if(!issilicon(L))
				L.Paralyze(40)
			O.forceMove(T)
			close()
	else
		O.forceMove(T)
	return 1

/obj/structure/closet/relaymove(mob/user)
	if(user.stat || !isturf(loc) || !isliving(user))
		return
	if(locked)
		if(message_cooldown <= world.time)
			message_cooldown = world.time + 50
			to_chat(user, "<span class='warning'>I'm trapped!</span>")
		return
	container_resist(user)

/obj/structure/closet/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!(user.mobility_flags & MOBILITY_STAND) && get_dist(src, user) > 0)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	toggle(user)

/obj/structure/closet/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/closet/attack_robot(mob/user)
	if(user.Adjacent(src))
		return attack_hand(user)

// tk grab then use on self
/obj/structure/closet/attack_self_tk(mob/user)
	return attack_hand(user)

/obj/structure/closet/verb/verb_toggleopen()
	set src in view(1)
	set hidden = 1
	set name = "Toggle Open"

	if(!usr.canUseTopic(src, BE_CLOSE) || !isturf(loc))
		return

	if(iscarbon(usr) || issilicon(usr) || isdrone(usr))
		return toggle(usr)
	else
		to_chat(usr, "<span class='warning'>This mob type can't use this verb.</span>")

// Objects that try to exit a locker by stepping were doing so successfully,
// and due to an oversight in turf/Enter() were going through walls.  That
// should be independently resolved, but this is also an interesting twist.
/obj/structure/closet/Exit(atom/movable/AM)
	open()
	if(AM.loc == src)
		return 0
	return 1

/obj/structure/closet/container_resist(mob/living/user)
	if(opened)
		return
	if(ismovableatom(loc))
		user.changeNext_move(CLICK_CD_BREAKOUT)
		user.last_special = world.time + CLICK_CD_BREAKOUT
		var/atom/movable/AM = loc
		AM.relay_container_resist(user, src)
		return
	if(!welded && !locked)
		open()
		return

	//okay, so the closet is either welded or locked... resist!!!
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message("<span class='warning'>[src] shakes violently!</span>")

/obj/structure/closet/proc/bust_open()
	welded = FALSE //applies to all lockers
	locked = FALSE //applies to critter crates and secure lockers only
	broken = TRUE //applies to secure lockers only
	open()
/*
/obj/structure/closet/AltClick(mob/user)
	..()
	return
	if(!user.canUseTopic(src, BE_CLOSE) || !isturf(loc))
		return
	if(opened || !secure)
		return
	else
		togglelock(user)
*/
/obj/structure/closet/CtrlShiftClick(mob/living/user)
	if(!HAS_TRAIT(user, TRAIT_SKITTISH))
		return ..()
	if(!user.canUseTopic(src, BE_CLOSE) || !isturf(user.loc))
		return
	dive_into(user)

/obj/structure/closet/proc/togglelock(mob/living/user, silent)
	user.changeNext_move(CLICK_CD_MELEE)
	if(locked)
		user.visible_message("<span class='warning'>[user] unlocks [src].</span>", \
			"<span class='notice'>I unlock [src].</span>")
		playsound(src, 'sound/foley/doors/lock.ogg', 100)
		locked = 0
	else
		user.visible_message("<span class='warning'>[user] locks [src].</span>", \
			"<span class='notice'>I lock [src].</span>")
		playsound(src, 'sound/foley/doors/lock.ogg', 100)
		locked = 1

/obj/structure/closet/emag_act(mob/user)
	if(secure && !broken)
		user.visible_message("<span class='warning'>Sparks fly from [src]!</span>",
						"<span class='warning'>I scramble [src]'s lock, breaking it open!</span>",
						"<span class='hear'>I hear a faint electrical spark.</span>")
		playsound(src, "sparks", 50, TRUE)
		broken = TRUE
		locked = FALSE
		update_icon()

/obj/structure/closet/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /obj/screen/fullscreen/impaired, 1)

/obj/structure/closet/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if (!(. & EMP_PROTECT_CONTENTS))
		for(var/obj/O in src)
			O.emp_act(severity)
	if(secure && !broken && !(. & EMP_PROTECT_SELF))
		if(prob(50 / severity))
			locked = !locked
			update_icon()
		if(prob(20 / severity) && !opened)
			if(!locked)
				open()
			else
				req_access = list()
				req_access += pick(get_all_accesses())

/obj/structure/closet/contents_explosion(severity, target)
	for(var/atom/A in contents)
		A.ex_act(severity, target)
		CHECK_TICK

/obj/structure/closet/singularity_act()
	dump_contents()
	..()

/obj/structure/closet/AllowDrop()
	return TRUE


/obj/structure/closet/return_temperature()
	return

/obj/structure/closet/proc/dive_into(mob/living/user)
	var/turf/T1 = get_turf(user)
	var/turf/T2 = get_turf(src)
	if(!opened)
		if(locked)
			togglelock(user, TRUE)
		if(!open(user))
			to_chat(user, "<span class='warning'>It won't budge!</span>")
			return
	step_towards(user, T2)
	T1 = get_turf(user)
	if(T1 == T2)
		user.resting = TRUE //so people can jump into crates without slamming the lid on their head
		if(!close(user))
			to_chat(user, "<span class='warning'>I can't get [src] to close!</span>")
			user.resting = FALSE
			return
		user.resting = FALSE
		togglelock(user)
		T1.visible_message("<span class='warning'>[user] dives into [src]!</span>")
