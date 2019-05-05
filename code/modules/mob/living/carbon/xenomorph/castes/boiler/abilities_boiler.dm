// ***************************************
// *********** Long range sight
// ***************************************

/datum/action/xeno_action/toggle_long_range
	name = "Toggle Long Range Sight (20)"
	action_icon_state = "toggle_long_range"
	mechanics_text = "Activates your weapon sight in the direction you are facing. Must remain stationary to use."
	plasma_cost = 20

/datum/action/xeno_action/toggle_long_range/can_use_action()
	var/mob/living/carbon/Xenomorph/Boiler/X = owner
	if(X && !X.incapacitated() && !X.lying && !X.buckled && (X.is_zoomed || X.plasma_stored >= plasma_cost) && !X.stagger)
		return TRUE

/datum/action/xeno_action/toggle_long_range/action_activate()
	var/mob/living/carbon/Xenomorph/Boiler/X = owner
	if(X.is_zoomed)
		X.zoom_out()
		X.visible_message("<span class='notice'>[X] stops looking off into the distance.</span>", \
		"<span class='notice'>You stop looking off into the distance.</span>", null, 5)
	else
		X.visible_message("<span class='notice'>[X] starts looking off into the distance.</span>", \
			"<span class='notice'>You start focusing your sight to look off into the distance.</span>", null, 5)
		if(!do_after(X, 20, FALSE)) return
		if(X.is_zoomed) return
		X.zoom_in()
		..()

// ***************************************
// *********** Gas type toggle
// ***************************************

/datum/action/xeno_action/toggle_bomb
	name = "Toggle Bombard Type"
	action_icon_state = "toggle_bomb0"
	mechanics_text = "Switches Boiler Bombard type between Corrosive Acid and Neurotoxin."
	plasma_cost = 0

/datum/action/xeno_action/toggle_bomb/action_activate()
	var/mob/living/carbon/Xenomorph/Boiler/X = owner
	to_chat(X, "<span class='notice'>You will now fire [X.ammo.type == /datum/ammo/xeno/boiler_gas ? "corrosive acid. This is lethal!" : "neurotoxic gas. This is nonlethal."]</span>")
	button.overlays.Cut()
	if(X.ammo.type == /datum/ammo/xeno/boiler_gas)
		X.ammo = GLOB.ammo_list[/datum/ammo/xeno/boiler_gas/corrosive]
		button.overlays += image('icons/mob/actions.dmi', button, "toggle_bomb1")
	else
		X.ammo = GLOB.ammo_list[/datum/ammo/xeno/boiler_gas]
		button.overlays += image('icons/mob/actions.dmi', button, "toggle_bomb0")

// ***************************************
// *********** Super strong acid
// ***************************************

/datum/action/xeno_action/activable/corrosive_acid/Boiler
	name = "Corrosive Acid (200)"
	acid_plasma_cost = 200
	acid_type = /obj/effect/xenomorph/acid/strong

// ***************************************
// *********** Gas cloud bombs
// ***************************************

/datum/action/xeno_action/bombard
	name = "Bombard"
	action_icon_state = "bombard"
	mechanics_text = "Launch a glob of neurotoxin or acid. Must remain stationary for a few seconds to use."
	plasma_cost = 0

/datum/action/xeno_action/bombard/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Boiler/X = owner
	return !X.bomb_cooldown

/datum/action/xeno_action/bombard/action_activate()
	var/mob/living/carbon/Xenomorph/Boiler/X = owner

	if(X.is_bombarding)
		if(X.client)
			X.client.mouse_pointer_icon = initial(X.client.mouse_pointer_icon) //Reset the mouse pointer.
		X.is_bombarding = 0
		to_chat(X, "<span class='notice'>You relax your stance.</span>")
		return

	if(X.bomb_cooldown)
		to_chat(X, "<span class='warning'>You are still preparing another spit. Be patient!</span>")
		return

	if(!isturf(X.loc))
		to_chat(X, "<span class='warning'>You can't do that from there.</span>")
		return

	X.visible_message("<span class='notice'>\The [X] begins digging their claws into the ground.</span>", \
	"<span class='notice'>You begin digging yourself into place.</span>", null, 5)
	if(do_after(X, 30, FALSE, 5, BUSY_ICON_GENERIC))
		if(X.is_bombarding) return
		X.is_bombarding = 1
		X.visible_message("<span class='notice'>\The [X] digs itself into the ground!</span>", \
		"<span class='notice'>You dig yourself into place! If you move, you must wait again to fire.</span>", null, 5)
		X.bomb_turf = get_turf(X)
		if(X.client)
			X.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
	else
		X.is_bombarding = 0
		if(X.client)
			X.client.mouse_pointer_icon = initial(X.client.mouse_pointer_icon)

/mob/living/carbon/Xenomorph/Boiler/proc/bomb_turf(var/turf/T)
	if(!istype(T) || T.z != src.z || T == get_turf(src))
		to_chat(src, "<span class='warning'>This is not a valid target.</span>")
		return

	if(!isturf(loc)) //In a locker
		return

	var/turf/U = get_turf(src)

	if(bomb_turf && bomb_turf != U)
		is_bombarding = FALSE
		if(client)
			client.mouse_pointer_icon = initial(client.mouse_pointer_icon) //Reset the mouse pointer.
		return

	if(!check_state())
		return

	if(!is_bombarding)
		to_chat(src, "<span class='warning'>You must dig yourself in before you can do this.</span>")
		return

	if(bomb_cooldown)
		to_chat(src, "<span class='warning'>You are still preparing another spit. Be patient!</span>")
		return

	if(get_dist(T, U) <= 5) //Magic number
		to_chat(src, "<span class='warning'>You are too close! You must be at least 7 meters from the target due to the trajectory arc.</span>")
		return

	if(!check_plasma(200))
		return

	var/offset_x = rand(-1, 1)
	var/offset_y = rand(-1, 1)

	if(prob(30))
		offset_x = 0
	if(prob(30))
		offset_y = 0

	var/turf/target = locate(T.x + offset_x, T.y + offset_y, T.z)

	if(!istype(target))
		return

	to_chat(src, "<span class='xenonotice'>You begin building up acid.</span>")
	if(client)
		client.mouse_pointer_icon = initial(client.mouse_pointer_icon) //Reset the mouse pointer.
	bomb_cooldown = TRUE
	is_bombarding = FALSE
	use_plasma(200)

	if(!do_after(src, 50, FALSE, 5, BUSY_ICON_HOSTILE))
		bomb_cooldown = FALSE
		to_chat(src, "<span class='warning'>You decide not to launch any acid.</span>")
		return

	if(!check_state())
		bomb_cooldown = FALSE
		return
	bomb_turf = null
	visible_message("<span class='xenowarning'>\The [src] launches a huge glob of acid hurling into the distance!</span>", \
	"<span class='xenowarning'>You launch a huge glob of acid hurling into the distance!</span>", null, 5)

	var/obj/item/projectile/P = new /obj/item/projectile(loc)
	P.generate_bullet(ammo)
	P.fire_at(target, src, null, ammo.max_range, ammo.shell_speed)
	playsound(src, 'sound/effects/blobattack.ogg', 25, 1)
	if(ammo.type == /datum/ammo/xeno/boiler_gas/corrosive)
		round_statistics.boiler_acid_smokes++
	else
		round_statistics.boiler_neuro_smokes++

	addtimer(CALLBACK(src, .bomb_cooldown), xeno_caste.bomb_delay)

/mob/living/carbon/Xenomorph/Boiler/proc/bomb_cooldown()
	bomb_cooldown = FALSE
	to_chat(src, "<span class='notice'>You feel your toxin glands swell. You are able to bombard an area again.</span>")
	update_action_button_icons()
	
// ***************************************
// *********** Acid spray
// ***************************************
/mob/living/carbon/Xenomorph/proc/acid_spray(atom/T, plasmacost = 250, acid_d = xeno_caste.acid_delay)
	if(!T)
		to_chat(src, "<span class='warning'>You see nothing to spit at!</span>")
		return

	if(!check_state())
		return

	if(!isturf(loc) || isspaceturf(loc))
		to_chat(src, "<span class='warning'>You can't do that from there.</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>The shock disrupts you!</span>")
		return

	if(!check_plasma(plasmacost))
		return

	if(acid_cooldown)
		to_chat(src, "<span class='xenowarning'>You're not yet ready to spray again! You can do so in [( (last_spray_used + acid_d) - world.time) * 0.1] seconds.</span>")
		return

	if(!do_after(src, 5, TRUE, 5, BUSY_ICON_HOSTILE, TRUE, TRUE))
		return

	var/turf/target

	if(isturf(T))
		target = T
	else
		target = get_turf(T)

	if(!target || !istype(target)) //Something went horribly wrong. Clicked off edge of map probably
		return

	if(target == loc)
		to_chat(src, "<span class='warning'>That's far too close!</span>")
		return

	acid_cooldown = TRUE
	last_spray_used = world.time
	use_plasma(plasmacost)
	playsound(loc, 'sound/effects/refill.ogg', 50, 1)
	visible_message("<span class='xenowarning'>\The [src] spews forth a virulent spray of acid!</span>", \
	"<span class='xenowarning'>You spew forth a spray of acid!</span>", null, 5)
	var/turflist = getline(src, target)
	spray_turfs(turflist)

	addtimer(CALLBACK(src, .acid_cooldown_end), acid_d)

/mob/living/carbon/Xenomorph/proc/acid_cooldown_end()
	acid_cooldown = FALSE
	playsound(loc, 'sound/voice/alien_drool1.ogg', 50, 1)
	to_chat(src, "<span class='xenodanger'>You feel your acid glands refill. You can spray acid again.</span>")
	update_action_buttons()

