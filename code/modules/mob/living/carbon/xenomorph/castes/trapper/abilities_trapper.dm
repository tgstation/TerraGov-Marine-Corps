// ***************************************
// *********** Xeno Sensor
// ***************************************
/datum/action/xeno_action/sensor
	name = "Place sensor"
	action_icon_state = "sensor"
	mechanics_text = "Place a sensor on weeds to get an alert when a host passes by it."
	plasma_cost = 400

/datum/action/xeno_action/sensor/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/turf/T = get_turf(owner)
	if(!T || !T.is_weedable() || T.density)
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't do that here.</span>")
		return FALSE

	if(!(locate(/obj/effect/alien/weeds) in T))
		if(!silent)
			to_chat(owner, "<span class='warning'>We can only shape on weeds. We must find some resin before we start building!</span>")
		return FALSE

	if(!T.check_alien_construction(owner, silent))
		return FALSE

	if(locate(/obj/effect/alien/weeds/node) in T)
		if(!silent)
			to_chat(owner, "<span class='warning'>There is a resin node in the way!</span>")
		return FALSE

/datum/action/xeno_action/sensor/action_activate()
	var/turf/T = get_turf(owner)

	succeed_activate()

	playsound(T, "alien_resin_build", 25)
	new /obj/effect/alien/resin/sensor(T, owner)
	to_chat(owner, "<span class='xenonotice'>We place a hugger trap on the weeds, it still needs a facehugger.</span>")

// ***************************************
// *********** Xeno Tripwire
// ***************************************
/datum/action/xeno_action/tripwire
	name = "Place tripwire"
	action_icon_state = "tripwire"
	mechanics_text = "Place a tripwire that notifies you when a host trips over it."
	plasma_cost = 100

/datum/action/xeno_action/tripwire/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/turf/T = get_turf(owner)
	if(!T || !T.is_weedable() || T.density)
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't do that here.</span>")
		return FALSE

	if(!(locate(/obj/effect/alien/weeds) in T))
		if(!silent)
			to_chat(owner, "<span class='warning'>We can only shape on weeds. We must find some resin before we start building!</span>")
		return FALSE

	if(!T.check_alien_construction(owner, silent))
		return FALSE

	if(locate(/obj/effect/alien/weeds/node) in T)
		if(!silent)
			to_chat(owner, "<span class='warning'>There is a resin node in the way!</span>")
		return FALSE

/datum/action/xeno_action/tripwire/action_activate()
	var/turf/T = get_turf(owner)

	succeed_activate()

	playsound(T, "alien_resin_build", 25)
	new /obj/effect/alien/resin/tripwire(T, owner)
	to_chat(owner, "<span class='xenonotice'>We place a hugger trap on the weeds, it still needs a facehugger.</span>")

// ***************************************
// *********** Trapper Zoom
// ***************************************
/datum/action/xeno_action/toggle_queen_zoom/trapper
	name = "Toggle Trapper Zoom"
	action_icon_state = "toggle_queen_zoom"
	mechanics_text = "Zoom out for a larger view around wherever you are looking."
	plasma_cost = 0

// ***************************************
// *********** Trapper Tunnel
// ***************************************
/datum/action/xeno_action/build_tunnel/trapper
	name = "Dig Tunnel"
	action_icon_state = "build_tunnel"
	mechanics_text = "Create a tunnel entrance. Use again to create the tunnel exit."
	plasma_cost = 200
	cooldown_timer = 120 SECONDS
	keybind_signal = COMSIG_XENOABILITY_BUILD_TUNNEL

/datum/action/xeno_action/build_tunnel/trapper/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/turf/T = get_turf(owner)
	if(locate(/obj/structure/tunnel/trapper) in T)
		to_chat(owner, "<span class='warning'>There already is a tunnel here.</span>")
		return
	if(!T.can_dig_xeno_tunnel())
		if(!silent)
			to_chat(owner, "<span class='warning'>We scrape around, but we can't seem to dig through that kind of floor.</span>")
		return FALSE
	if(owner.get_active_held_item())
		if(!silent)
			to_chat(owner, "<span class='warning'>We need an empty claw for this!</span>")
		return FALSE

/datum/action/xeno_action/build_tunnel/trapper/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, "<span class='notice'>We are ready to dig a tunnel again.</span>")
	return ..()

/datum/action/xeno_action/build_tunnel/trapper/action_activate()
	var/turf/T = get_turf(owner)

	owner.visible_message("<span class='xenonotice'>[owner] begins digging out a tunnel entrance.</span>", \
	"<span class='xenonotice'>We begin digging out a tunnel entrance.</span>", null, 5)
	if(!do_after(owner, HIVELORD_TUNNEL_DIG_TIME, TRUE, T, BUSY_ICON_BUILD))
		to_chat(owner, "<span class='warning'>Our tunnel caves in as we stop digging it.</span>")
		return fail_activate()

	if(!can_use_action(TRUE))
		return fail_activate()

	var/mob/living/carbon/xenomorph/trapper/X = owner
	if(!X.start_dig) //Let's start a new one.
		X.visible_message("<span class='xenonotice'>\The [X] digs out a tunnel entrance.</span>", \
		"<span class='xenonotice'>We dig out the first entrance to our tunnel.</span>", null, 5)
		X.start_dig = new /obj/structure/tunnel/trapper(T)
		X.start_dig.creator = X
		playsound(T, 'sound/weapons/pierce.ogg', 25, 1)
		return succeed_activate()

	to_chat(X, "<span class='xenonotice'>We dig our tunnel all the way to the original entrance, connecting both entrances!</span>")
	var/obj/structure/tunnel/newt = new /obj/structure/tunnel/trapper(T)
	newt.other = X.start_dig
	newt.creator = X

	if(newt.z != newt.other.z)
		X.start_dig = newt
		to_chat(X, "<span class='xenonotice'>The first tunnel of this set has been destroyed as it cannot connect to this tunnel.</span>")
		newt.other.deconstruct(FALSE)
		newt.other = null
		return fail_activate()

	X.start_dig.other = newt //Link the two together
	X.start_dig = null //Now clear it

	X.tunnels.Add(newt)
	X.tunnels.Add(newt.other)

	add_cooldown()

	to_chat(X, "<span class='xenonotice'>We dig our tunnel all the way to the original entrance, connecting both entrances! We now have [length(X.tunnels) * 0.5] of [HIVELORD_TUNNEL_SET_LIMIT] tunnel sets.</span>")

	var/msg = stripped_input(X, "Add a description to the tunnel:", "Tunnel Description")
	newt.other.tunnel_desc = "[get_area(newt.other)] (X: [newt.other.x], Y: [newt.other.y]) [msg]"
	newt.tunnel_desc = "[get_area(newt)] (X: [newt.x], Y: [newt.y]) [msg]"

	if(length(X.tunnels) * 0.5 > HIVELORD_TUNNEL_SET_LIMIT) //if we exceed the limit, delete the oldest tunnel set.
		var/obj/structure/tunnel/trapper/old_tunnel = X.tunnels[1]
		old_tunnel.deconstruct(FALSE)
		to_chat(X, "<span class='xenodanger'>Having exceeding our tunnel set limit, our oldest tunnel set has collapsed.</span>")

	succeed_activate()
	playsound(T, 'sound/weapons/pierce.ogg', 25, 1)
