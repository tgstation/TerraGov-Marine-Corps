// It is a gizmo that flashes a small area

/obj/machinery/flasher
	name = "Mounted flash"
	desc = "A wall-mounted flashbulb device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mflash1"
	anchored = TRUE
	power_channel = EQUIP
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 1500
	var/id = null
	var/range = 2 //this is roughly the size of brig cell
	var/disable = 0
	var/last_flash = 0 //Don't want it getting spammed like regular flashes
	var/strength = 20 SECONDS //How knocked down targets are when flashed.
	var/base_state = "mflash"

/obj/machinery/flasher/cell1
	name = "Cell 1 Flash"

/obj/machinery/flasher/cell2
	name = "Cell 2 Flash"

/obj/machinery/flasher/portable //Portable version of the flasher. Only flashes when anchored
	name = "portable flasher"
	desc = "A portable flashing device. Wrench to activate and deactivate. Cannot detect slow movements."
	icon_state = "pflash1"
	strength = 8
	anchored = FALSE
	base_state = "pflash"
	density = TRUE


/obj/machinery/flasher/update_icon_state()
	if(!(machine_stat & NOPOWER))
		icon_state = "[base_state]1"
	else
		icon_state = "[base_state]1-p"


/obj/machinery/flasher/wirecutter_act(mob/living/user, obj/item/W)
	disable = !disable
	if (disable)
		user.visible_message(span_warning(" [user] has disconnected the [src]'s flashbulb!"), span_warning(" You disconnect the [src]'s flashbulb!"))
	if (!disable)
		user.visible_message(span_warning(" [user] has connected the [src]'s flashbulb!"), span_warning(" You connect the [src]'s flashbulb!"))

/obj/machinery/flasher/attack_ai()
	if (anchored)
		return flash()
	else
		return

/obj/machinery/flasher/proc/flash()
	if (!(powered()))
		return
	if ((disable) || (last_flash && world.time < last_flash + 150))
		return

	playsound(loc, 'sound/weapons/flash.ogg', 25, 1)
	flick("[base_state]_flash", src)
	last_flash = world.time
	use_power(active_power_usage)

	for(var/mob/living/L in viewers(src, null))
		if (get_dist(src, L) > range)
			continue

		if(isxeno(L))
			continue

		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(H.get_eye_protection() > 0)
				continue
			var/datum/internal_organ/eyes/E = H.internal_organs_by_name["eyes"]
			if(E && (E.damage > E.min_bruised_damage && prob(E.damage + 50)))
				H.flash_act()
				E.take_damage(rand(1, 5))
		else
			L.flash_act()


		L.Paralyze(strength)


/obj/machinery/flasher/emp_act(severity)
	if(machine_stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(prob(75/severity))
		flash()
	..(severity)

/obj/machinery/flasher/portable/HasProximity(atom/movable/AM as mob|obj)
	if ((disable) || (last_flash && world.time < last_flash + 150))
		return

	if(iscarbon(AM))
		var/mob/living/carbon/M = AM
		if ((M.m_intent != MOVE_INTENT_WALK) && (anchored))
			flash()

/obj/machinery/flasher/portable/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(iswrench(I))
		anchored = !anchored

		if(!anchored)
			user.show_message(span_warning("[src] is now secured."))
			overlays += "[base_state]-s"
		else
			user.show_message(span_warning(" [src] can now be moved."))
			overlays.Cut()

/obj/machinery/flasher_button/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/flasher_button/attackby(obj/item/I, mob/user, params)
	. = ..()
	return attack_hand(user)

/obj/machinery/flasher_button/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(active)
		return

	if(!allowed(user))
		to_chat(user, span_warning("Access Denied."))
		return

	use_power(active_power_usage)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/flasher/M in GLOB.machines)
		if(M.id == id)
			INVOKE_ASYNC(M, /obj/machinery/flasher.proc/flash)

	sleep(50)

	icon_state = "launcherbtt"
	active = 0

