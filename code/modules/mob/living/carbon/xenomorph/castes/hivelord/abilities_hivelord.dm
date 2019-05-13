// ***************************************
// *********** Resin building
// ***************************************
/datum/action/xeno_action/choose_resin/hivelord
	buildable_structures = list(
		/turf/closed/wall/resin/thick,
		/obj/structure/bed/nest,
		/obj/effect/alien/resin/sticky,
		/obj/structure/mineral_door/resin/thick)

/datum/action/xeno_action/activable/secrete_resin/hivelord
	plasma_cost = 100

GLOBAL_LIST_INIT(thickenable_resin, typecacheof(list(
	/turf/closed/wall/resin,
	/turf/closed/wall/resin/membrane,
	/obj/structure/mineral_door/resin), FALSE, TRUE))

/datum/action/xeno_action/activable/secrete_resin/hivelord/use_ability(atom/A)
	if(get_dist(src,A) > 1)
		return ..()

	if(!is_type_in_typecache(A, GLOB.thickenable_resin))
		return build_resin(get_turf(A))

	if(istype(A, /turf/closed/wall/resin))
		var/turf/closed/wall/resin/WR = A
		var/oldname = WR.name
		if(WR.thicken())
			owner.visible_message("<span class='xenonotice'>\The [owner] regurgitates a thick substance and thickens [oldname].</span>", \
			"<span class='xenonotice'>You regurgitate some resin and thicken [oldname].</span>", null, 5)
			playsound(owner.loc, "alien_resin_build", 25)
			return succeed_activate()
		to_chat(owner, "<span class='xenowarning'>[WR] can't be made thicker.</span>")
		return fail_activate()

	if(istype(A, /obj/structure/mineral_door/resin))
		var/obj/structure/mineral_door/resin/DR = A
		var/oldname = DR.name
		if(DR.thicken())
			owner.visible_message("<span class='xenonotice'>\The [owner] regurgitates a thick substance and thickens [oldname].</span>", \
				"<span class='xenonotice'>You regurgitate some resin and thicken [oldname].</span>", null, 5)
			playsound(owner.loc, "alien_resin_build", 25)
			return succeed_activate()
		to_chat(owner, "<span class='xenowarning'>[DR] can't be made thicker.</span>")
		return fail_activate()
	return fail_activate() //will never be reached but failsafe

// ***************************************
// *********** Resin walker
// ***************************************
/datum/action/xeno_action/toggle_speed
	name = "Resin Walker"
	action_icon_state = "toggle_speed"
	mechanics_text = "Move faster on resin."
	plasma_cost = 50

/datum/action/xeno_action/toggle_speed/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/mob/living/carbon/Xenomorph/Hivelord/X = owner
	if(X.speed_activated)
		return TRUE

/datum/action/xeno_action/toggle_speed/action_activate()
	var/mob/living/carbon/Xenomorph/Hivelord/X = owner
	if(X.speed_activated)
		to_chat(X, "<span class='warning'>You feel less in tune with the resin.</span>")
		X.speed_activated = FALSE
		return fail_activate()

	succeed_activate()
	X.speed_activated = TRUE
	to_chat(X, "<span class='notice'>You become one with the resin. You feel the urge to run!</span>")

// ***************************************
// *********** Tunnel
// ***************************************
/datum/action/xeno_action/build_tunnel
	name = "Dig Tunnel"
	action_icon_state = "build_tunnel"
	mechanics_text = "Create a tunnel entrance. Use again to create the tunnel exit."
	plasma_cost = 200
	cooldown_timer = HIVELORD_TUNNEL_COOLDOWN

/datum/action/xeno_action/build_tunnel/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/turf/T = get_turf(owner)
	if(locate(/obj/structure/tunnel) in T)
		to_chat(owner, "<span class='warning'>There already is a tunnel here.</span>")
		return
	if(!T.can_dig_xeno_tunnel())
		if(!silent)
			to_chat(owner, "<span class='warning'>You scrape around, but you can't seem to dig through that kind of floor.</span>")
		return FALSE
	if(owner.get_active_held_item())
		if(!silent)
			to_chat(owner, "<span class='warning'>You need an empty claw for this!</span>")
		return FALSE

/datum/action/xeno_action/build_tunnel/on_cooldown_finish()
	to_chat(src, "<span class='notice'>You are ready to dig a tunnel again.</span>")
	return ..()

/datum/action/xeno_action/build_tunnel/action_activate()
	var/turf/T = get_turf(owner)

	owner.visible_message("<span class='xenonotice'>[owner] begins digging out a tunnel entrance.</span>", \
	"<span class='xenonotice'>You begin digging out a tunnel entrance.</span>", null, 5)
	if(!do_after(owner, HIVELORD_TUNNEL_DIG_TIME, TRUE, T, BUSY_ICON_BUILD))
		to_chat(owner, "<span class='warning'>Your tunnel caves in as you stop digging it.</span>")
		return fail_activate()

	if(!can_use_action(TRUE))
		return fail_activate()

	var/mob/living/carbon/Xenomorph/Hivelord/X = owner
	if(!X.start_dig) //Let's start a new one.
		X.visible_message("<span class='xenonotice'>\The [X] digs out a tunnel entrance.</span>", \
		"<span class='xenonotice'>You dig out the first entrance to your tunnel.</span>", null, 5)
		X.start_dig = new /obj/structure/tunnel(T)
		X.start_dig.creator = X
		playsound(T, 'sound/weapons/pierce.ogg', 25, 1)
		return succeed_activate()

	to_chat(X, "<span class='xenonotice'>You dig your tunnel all the way to the original entrance, connecting both entrances!</span>")
	var/obj/structure/tunnel/newt = new /obj/structure/tunnel(T)
	newt.other = X.start_dig
	newt.creator = X

	if(newt.z != newt.other.z)
		X.start_dig = newt
		to_chat(X, "<span class='xenonotice'>The first tunnel of this set has been destroyed as it cannot connect to this tunnel.</span>")
		newt.other.obj_integrity = 0
		newt.other.healthcheck()
		newt.other = null
		return fail_activate()

	X.start_dig.other = newt //Link the two together
	X.start_dig = null //Now clear it

	X.tunnels.Add(newt)
	X.tunnels.Add(newt.other)

	add_cooldown()

	to_chat(X, "<span class='xenonotice'>You dig your tunnel all the way to the original entrance, connecting both entrances! You now have [X.tunnels.len * 0.5] of [HIVELORD_TUNNEL_SET_LIMIT] tunnel sets.</span>")

	var/msg = copytext(sanitize(input("Add a description to the tunnel:", "Tunnel Description") as text|null), 1, MAX_MESSAGE_LEN)
	newt.other.tunnel_desc = "[get_area(newt.other)] (X: [newt.other.x], Y: [newt.other.y]) [msg]"
	newt.tunnel_desc = "[get_area(newt)] (X: [newt.x], Y: [newt.y]) [msg]"

	if(length(X.tunnels) * 0.5 > HIVELORD_TUNNEL_SET_LIMIT) //if we exceed the limit, delete the oldest tunnel set.
		var/obj/structure/tunnel/old_tunnel = X.tunnels[1]
		old_tunnel.obj_integrity = 0
		old_tunnel.healthcheck()
		to_chat(X, "<span class='xenodanger'>Having exceeding your tunnel set limit, your oldest tunnel set has collapsed.</span>")

	succeed_activate()
	playsound(T, 'sound/weapons/pierce.ogg', 25, 1)

// ***************************************
// *********** plasma transfer
// ***************************************
/datum/action/xeno_action/activable/transfer_plasma/improved
	plasma_transfer_amount = PLASMA_TRANSFER_AMOUNT * 4
	transfer_delay = 0.5 SECONDS
	max_range = 7
