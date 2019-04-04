// ***************************************
// *********** Resin building
// ***************************************
/datum/action/xeno_action/activable/secrete_resin/hivelord
	name = "Secrete Resin (100)"
	resin_plasma_cost = 100

// ***************************************
// *********** Resin walker
// ***************************************
/datum/action/xeno_action/toggle_speed
	name = "Resin Walker (50)"
	action_icon_state = "toggle_speed"
	mechanics_text = "Move faster on resin."
	plasma_cost = 50

/datum/action/xeno_action/toggle_speed/can_use_action()
	var/mob/living/carbon/Xenomorph/Hivelord/X = owner
	if(X && !X.incapacitated() && !X.lying && !X.buckled && (X.speed_activated || X.plasma_stored >= plasma_cost) && !X.stagger)
		return TRUE

/datum/action/xeno_action/toggle_speed/action_activate()
	var/mob/living/carbon/Xenomorph/Hivelord/X = owner
	if(!X.check_state())
		return

	if(X.speed_activated)
		to_chat(X, "<span class='warning'>You feel less in tune with the resin.</span>")
		X.speed_activated = 0
		return

	if(!X.check_plasma(50))
		return
	X.speed_activated = 1
	X.use_plasma(50)
	to_chat(X, "<span class='notice'>You become one with the resin. You feel the urge to run!</span>")

// ***************************************
// *********** Tunnel
// ***************************************
/datum/action/xeno_action/build_tunnel
	name = "Dig Tunnel (200)"
	action_icon_state = "build_tunnel"
	mechanics_text = "Create a tunnel entrance. Use again to create the tunnel exit."
	plasma_cost = 200

/datum/action/xeno_action/build_tunnel/can_use_action()
	var/mob/living/carbon/Xenomorph/Hivelord/X = owner
	if(X.tunnel_delay) return FALSE
	return ..()

/datum/action/xeno_action/build_tunnel/action_activate()
	var/mob/living/carbon/Xenomorph/Hivelord/X = owner
	X.build_tunnel()

/mob/living/carbon/Xenomorph/Hivelord/proc/build_tunnel()
	if(!check_state())
		return

	if(action_busy)
		to_chat(src, "<span class='warning'>You should finish up what you're doing before digging.</span>")
		return

	var/turf/T = loc
	if(!istype(T)) //logic
		to_chat(src, "<span class='warning'>You can't do that from there.</span>")
		return

	if(!T.can_dig_xeno_tunnel())
		to_chat(src, "<span class='warning'>You scrape around, but you can't seem to dig through that kind of floor.</span>")
		return

	if(locate(/obj/structure/tunnel) in loc)
		to_chat(src, "<span class='warning'>There already is a tunnel here.</span>")
		return

	if(tunnel_delay)
		to_chat(src, "<span class='warning'>You are not ready to dig a tunnel again.</span>")
		return

	if(get_active_held_item())
		to_chat(src, "<span class='warning'>You need an empty claw for this!</span>")
		return

	if(!check_plasma(200))
		return

	visible_message("<span class='xenonotice'>[src] begins digging out a tunnel entrance.</span>", \
	"<span class='xenonotice'>You begin digging out a tunnel entrance.</span>", null, 5)
	if(!do_after(src, HIVELORD_TUNNEL_DIG_TIME, TRUE, 5, BUSY_ICON_BUILD))
		to_chat(src, "<span class='warning'>Your tunnel caves in as you stop digging it.</span>")
		return
	if(!check_plasma(200))
		return
	if(!start_dig) //Let's start a new one.
		visible_message("<span class='xenonotice'>\The [src] digs out a tunnel entrance.</span>", \
		"<span class='xenonotice'>You dig out the first entrance to your tunnel.</span>", null, 5)
		start_dig = new /obj/structure/tunnel(T)
		start_dig.creator = src
	else
		to_chat(src, "<span class='xenonotice'>You dig your tunnel all the way to the original entrance, connecting both entrances!</span>")
		var/obj/structure/tunnel/newt = new /obj/structure/tunnel(T)
		newt.other = start_dig
		newt.creator = src

		if(newt.y != newt.other.y)
			start_dig = newt
			to_chat(src, "<span class='xenonotice'>The first tunnel of this set has been destroyed as it cannot connect to this tunnel.</span>")
			newt.other.health = 0
			newt.other.healthcheck()
			newt.other = null
			return

		start_dig.other = newt //Link the two together
		start_dig = null //Now clear it

		tunnels.Add(newt)
		tunnels.Add(newt.other)

		tunnel_delay = TRUE
		addtimer(CALLBACK(src, .tunnel_cooldown), HIVELORD_TUNNEL_COOLDOWN)

		to_chat(src, "<span class='xenonotice'>You dig your tunnel all the way to the original entrance, connecting both entrances! You now have [tunnels.len * 0.5] of [HIVELORD_TUNNEL_SET_LIMIT] tunnel sets.</span>")

		var/msg = copytext(sanitize(input("Add a description to the tunnel:", "Tunnel Description") as text|null), 1, MAX_MESSAGE_LEN)
		newt.other.tunnel_desc = "[get_area(newt.other)] (X: [newt.other.x], Y: [newt.other.y]) [msg]"
		newt.tunnel_desc = "[get_area(newt)] (X: [newt.x], Y: [newt.y]) [msg]"

		if(length(tunnels) * 0.5 > HIVELORD_TUNNEL_SET_LIMIT) //if we exceed the limit, delete the oldest tunnel set.
			var/obj/structure/tunnel/old_tunnel = tunnels[1]
			old_tunnel.health = 0
			old_tunnel.healthcheck()
			to_chat(src, "<span class='xenodanger'>Having exceeding your tunnel set limit, your oldest tunnel set has collapsed.</span>")

	use_plasma(200)
	playsound(loc, 'sound/weapons/pierce.ogg', 25, 1)

/mob/living/carbon/Xenomorph/Hivelord/proc/tunnel_cooldown()
	to_chat(src, "<span class='notice'>You are ready to dig a tunnel again.</span>")
	tunnel_delay = FALSE
