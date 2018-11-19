//Deployable turrets. They can be either automated, manually fired, or installed with a pAI.
//They are built in stages, and only engineers have access to them.

/obj/item/ammo_magazine/sentry
	name = "M30 box magazine (10x28mm Caseless)"
	desc = "A box of 500 10x28mm caseless rounds for the UA 571-C Sentry Gun. Just feed it into the sentry gun's ammo port when its ammo is depleted."
	w_class = 4
	icon_state = "ua571c"
	flags_magazine = NOFLAGS //can't be refilled or emptied by hand
	caliber = "10x28mm"
	max_rounds = 500
	default_ammo = /datum/ammo/bullet/turret
	gun_type = null

/obj/item/storage/box/sentry
	name = "\improper UA 571-C sentry crate"
	desc = "A large case containing all you need to set up an automated sentry, minus the tools."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sentry_case"
	w_class = 5
	storage_slots = 6
	can_hold = list(
					/obj/item/stack/sheet/plasteel/sentry_stack,
					/obj/item/stack/sheet/metal/small_stack,
					/obj/item/device/turret_top,
					/obj/item/device/turret_sensor,
					/obj/item/cell,
					/obj/item/ammo_magazine/sentry,
					)


/obj/item/storage/box/sentry/New()
	. = ..()
	new /obj/item/stack/sheet/plasteel/sentry_stack(src)
	new /obj/item/stack/sheet/metal/small_stack(src)
	new /obj/item/device/turret_top(src)
	new /obj/item/device/turret_sensor(src)
	new /obj/item/cell/high(src)
	new /obj/item/ammo_magazine/sentry(src)

/obj/machinery/marine_turret_frame
	name = "\improper UA 571-C turret frame"
	desc = "An unfinished turret frame. It requires wrenching, cable coil, a turret piece, a sensor, and metal plating."
	icon = 'icons/Marine/turret.dmi'
	icon_state = "sentry_base"
	anchored = FALSE
	density = TRUE
	throwpass = TRUE //You can throw objects over this, despite it's density.
	flags_atom = ON_BORDER
	layer = ABOVE_OBJ_LAYER
	var/has_cable = FALSE
	var/has_top = FALSE
	var/has_plates = FALSE
	var/is_welded = FALSE
	var/has_sensor = FALSE
	var/frame_hp = 100


/obj/machinery/marine_turret_frame/proc/update_health(damage)
	frame_hp -= damage
	if(frame_hp <= 0)
		if(has_cable)
			new /obj/item/stack/cable_coil(loc, 10)
		if(has_top)
			new /obj/item/device/turret_top(loc)
		if(has_sensor)
			new /obj/item/device/turret_sensor(loc)
		cdel(src)


/obj/machinery/marine_turret_frame/attack_alien(mob/living/carbon/Xenomorph/M)
	if(isXenoLarva(M))
		return //Larvae can't do shit
	M.visible_message("<span class='danger'>[M] has slashed [src]!</span>",
	"<span class='danger'>You slash [src]!</span>")
	M.animation_attack_on(src)
	M.flick_attack_overlay(src, "slash")
	playsound(loc, "alien_claw_metal", 25)
	update_health(rand(M.xeno_caste.melee_damage_lower,M.xeno_caste.melee_damage_upper))

/obj/machinery/marine_turret_frame/examine(mob/user as mob)
	..()
	if(!anchored)
		to_chat(user, "<span class='info'>It must be <B>wrenched</B> to the floor.</span>")
	if(!has_cable)
		to_chat(user, "<span class='info'>It requires <B>cable coil</B> for wiring.</span>")
	if(!has_top)
		to_chat(user, "<span class='info'>The <B>main turret</B> is not installed.</span>")
	if(!has_plates)
		to_chat(user, "<span class='info'>It does not have <B>metal</B> plating installed.</span>")
	if(!is_welded)
		to_chat(user, "<span class='info'>It requires the metal plating to be <B>welded</B>.</span>")
	if(!has_sensor)
		to_chat(user, "<span class='info'>It does not have a <b>turret sensor</B> installed.</span>")

/obj/machinery/marine_turret_frame/attackby(var/obj/item/O as obj, mob/user as mob)
	if(!ishuman(user))
		return
	//Rotate/Secure Sentry
	if(istype(O,/obj/item/tool/wrench))
		if(anchored)
			playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
			user.visible_message("<span class='notice'>[user] rotates [src].</span>",
			"<span class='notice'>You rotate [src].</span>")
			switch(dir)
				if(SOUTH)
					dir = WEST
				if(NORTH)
					dir = EAST
				if(EAST)
					dir = SOUTH
				if(WEST)
					dir = NORTH
		else
			if(locate(/obj/machinery/marine_turret) in loc)
				to_chat(user, "<span class='warning'>There already is a turret in this position.</span>")
				return

			user.visible_message("<span class='notice'>[user] begins securing [src] to the ground.</span>",
			"<span class='notice'>You begin securing [src] to the ground.</span>")
			if(do_after(user, 40, TRUE, 5, BUSY_ICON_BUILD))
				playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
				user.visible_message("<span class='notice'>[user] secures [src] to the ground.</span>",
				"<span class='notice'>You secure [src] to the ground.</span>")
				anchored = TRUE
		return


	//Install wiring
	if(istype(O,/obj/item/stack/cable_coil))
		if(!anchored)
			to_chat(user, "<span class='warning'>You must secure [src] to the ground first.</span>")
			return

		var/obj/item/stack/cable_coil/CC = O
		if(has_cable)
			to_chat(user, "<span class='warning'>[src]'s wiring is already installed.</span>")
			return
		user.visible_message("<span class='notice'>[user] begins installing [src]'s wiring.</span>",
		"<span class='notice'>You begin installing [src]'s wiring.</span>")
		if(do_after(user, 40, TRUE, 5, BUSY_ICON_BUILD))
			if(CC.use(10))
				has_cable = TRUE
				playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)
				user.visible_message("<span class='notice'>[user] installs [src]'s wiring.</span>",
				"<span class='notice'>You install [src]'s wiring.</span>")
				icon_state = "sentry_base_wired"
				return
			else
				to_chat(user, "<span class='warning'>You will need at least ten cable lengths to finish [src]'s wiring.</span>")

	//Install turret head
	if(istype(O, /obj/item/device/turret_top))
		if(!has_cable)
			to_chat(user, "<span class='warning'>You must install [src]'s wiring first.</span>")
			return
		if(has_top)
			to_chat(user, "<span class='warning'>[src] already has a turret installed.</span>")
			return
		user.visible_message("<span class='notice'>[user] begins installing [O] on [src].</span>",
		"<span class='notice'>You begin installing [O] on [src].</span>")
		if(do_after(user, 60, TRUE, 5, BUSY_ICON_BUILD))
			playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)
			user.visible_message("<span class='notice'>[user] installs [O] on [src].</span>",
			"<span class='notice'>You install [O] on [src].</span>")
			has_top = TRUE
			icon_state = "sentry_armorless"
			user.drop_held_item()
			cdel(O)
			return

	//Install plating
	if(istype(O, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = O
		if(!has_top)
			to_chat(user, "<span class='warning'>You must install [src]'s turret first.</span>")
			return

		if(has_plates)
			to_chat(user, "<span class='warning'>[src] already has plates installed.</span>")
			return

		if(M.amount < 10)
			to_chat(user, "<span class='warning'>[src]'s plating will require at least ten sheets of metal.</span>")
			return

		user.visible_message("<span class='notice'>[user] begins installing [src]'s reinforced plating.</span>",
		"<span class='notice'>You begin installing [src]'s reinforced plating.</span>")
		if(do_after(user, 50, TRUE, 5, BUSY_ICON_BUILD))
			if(!M) return
			if(M.amount >= 10)
				has_plates = TRUE
				playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)
				user.visible_message("<span class='notice'>[user] installs [src]'s reinforced plating.</span>",
				"<span class='notice'>You install [src]'s reinforced plating.</span>")
				M.use(10)
				return
			else
				to_chat(user, "<span class='warning'>[src]'s plating will require at least ten sheets of metal.</span>")
				return

	//Weld plating
	if(istype(O, /obj/item/tool/weldingtool))
		if(!has_plates)
			to_chat(user, "<span class='warning'>You must install [src]'s plating first.</span>")
			return
		var/obj/item/tool/weldingtool/WT = O
		playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] begins welding [src]'s parts together.</span>",
		"<span class='notice'>You begin welding [src]'s parts together.</span>")
		if(do_after(user,60, TRUE, 5, BUSY_ICON_BUILD))
			if(!src || !WT || !WT.isOn()) return
			if(WT.remove_fuel(0, user))
				playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)
				user.visible_message("<span class='notice'>[user] welds [src]'s plating to the frame.</span>",
				"<span class='notice'>You weld [src]'s plating to the frame.</span>")
				is_welded = TRUE
				icon_state = "sentry_sensor_none"
				return
			else
				to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
				return

	//Install sensor
	if(istype(O, /obj/item/device/turret_sensor))
		if(!is_welded)
			to_chat(user, "<span class='warning'>You must weld the plating on the [src] first!</span>")
			return

		if(has_sensor)
			to_chat(user, "<span class='warning'>[src] already has a sensor installed.</span>")
			return

		user.visible_message("<span class='notice'>[user] begins installing [O] on [src].</span>",
		"<span class='notice'>You begin installing [O] on [src].</span>")
		if(do_after(user, 40, TRUE, 5, BUSY_ICON_BUILD))
			has_sensor = TRUE
			playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)
			user.visible_message("<span class='notice'>[user] installs [O] on [src].</span>",
			"<span class='notice'>You install [O] on [src].</span>")
			icon_state = "sentry_off"
			user.drop_held_item()
			cdel(O)

			var/obj/machinery/marine_turret/T = new(loc)  //Bing! Create a new turret.
			T.dir = dir
			cdel(src)
			return

	return ..() //Just do normal stuff.

/obj/item/device/turret_sensor
	name = "\improper UA 571-C turret sensor"
	desc = "An AI control and locking sensor for an automated sentry. This must be installed on the final product for it to work."
	unacidable = TRUE
	w_class = 1
	icon = 'icons/Marine/turret.dmi'
	icon_state = "sentry_sensor"

/obj/item/device/turret_top
	name = "\improper UA 571-C turret"
	desc = "The turret part of an automated sentry turret. This must be installed on a turret frame and welded together for it to do anything."
	unacidable = TRUE
	w_class = 5
	icon = 'icons/Marine/turret.dmi'
	icon_state = "sentry_head"

/obj/machinery/marine_turret
	name = "\improper UA 571-C sentry gun"
	desc = "A deployable, semi-automated turret with AI targeting capabilities. Armed with an M30 Autocannon and a 500-round drum magazine."
	icon = 'icons/Marine/turret.dmi'
	icon_state = "sentry_off"
	anchored = TRUE
	unacidable = TRUE
	density = TRUE
	layer = ABOVE_MOB_LAYER //So you can't hide it under corpses
	use_power = 0
	flags_atom = RELAY_CLICK
	req_one_access = list(ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_ENGPREP, ACCESS_MARINE_LEADER)
	var/iff_signal = ACCESS_IFF_MARINE
	var/safety_off = FALSE
	var/rounds = 500
	var/rounds_max = 500
	var/burst_size = 5
	var/max_burst = 6
	var/min_burst = 2
	var/locked = FALSE
	var/atom/target = null
	var/manual_override = FALSE
	var/on = FALSE
	var/health = 200
	var/health_max = 200
	stat = 0 //Used just like mob.stat
	var/datum/effect_system/spark_spread/spark_system //The spark system, used for generating... sparks?
	var/obj/item/cell/cell = null
	var/burst_fire = FALSE
	var/obj/machinery/camera/camera = null
	var/fire_delay = 3
	var/burst_delay = 5
	var/last_fired = 0
	var/is_bursting = FALSE
	var/range = 7
	var/muzzle_flash_lum = 3 //muzzle flash brightness
	var/obj/item/turret_laptop/laptop = null
	var/immobile = 0 //Used for prebuilt ones.
	var/datum/ammo/bullet/turret/ammo = /datum/ammo/bullet/turret
	var/obj/item/projectile/in_chamber = null
	var/alerts_on = TRUE
	var/last_alert = 0
	var/last_damage_alert = 0
	var/list/obj/alert_list = list()
	var/radial_mode = FALSE
	var/knockdown_threshold = 100
	var/work_time = 40 //Defines how long it takes to do most maintenance actions
	var/magazine_type = /obj/item/ammo_magazine/sentry

/obj/machinery/marine_turret/examine(mob/user)
	. = ..()
	var/list/details = list()
	if(on)
		details +=("It's turned on.</br>")

	if(!safety_off)
		details +=("Its safeties are on.</br>")

	if(manual_override)
		details +=("Its manual override is active.</br>")
	else
		details += ("It's set to [radial_mode ? "360" : "directional targeting"] mode.</br>")

	if(alerts_on)
		details +=("Its alert mode is active.</br>")

	if(!ammo)
		details +=("<span class='danger'>It has no ammo!</br></span>")

	if(!cell || cell.charge == 0)
		details +=("<span class='danger'>It is unpowered!</br></span>")

	to_chat(user, "<span class='warning'>[details.Join(" ")]</span>")


/obj/machinery/marine_turret/New()
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	cell = new /obj/item/cell/high(src)
	camera = new (src)
	camera.network = list("military")
	camera.c_tag = "[name] ([rand(0, 1000)])"
	spawn(2)
		stat = 0
	//processing_objects.Add(src)
	ammo = ammo_list[ammo]


/obj/machinery/marine_turret/Dispose() //Clear these for safety's sake.
	if(operator)
		operator.unset_interaction()
		operator = null
	if(camera)
		cdel(camera)
		camera = null
	if(cell)
		cdel(cell)
		cell = null
	if(target)
		target = null
	alert_list = list()
	SetLuminosity(0)
	stop_processing()
	. = ..()

/obj/machinery/marine_turret/attack_hand(mob/user as mob)
	if(isYautja(user))
		to_chat(user, "<span class='warning'>You punch [src] but nothing happens.</span>")
		return
	src.add_fingerprint(user)

	if(!cell || cell.charge <= 0)
		to_chat(user, "<span class='warning'>You try to activate [src] but nothing happens. The cell must be empty.</span>")
		return

	if(!anchored)
		to_chat(user, "<span class='warning'>It must be anchored to the ground before you can activate it.</span>")
		return

	if(immobile)
		to_chat(user, "<span class='warning'>[src]'s panel is completely locked, you can't do anything.</span>")
		return

	if(stat)
		user.visible_message("<span class='notice'>[user] begins to set [src] upright.</span>",
		"<span class='notice'>You begin to set [src] upright.</span>")
		if(do_after(user,20, TRUE, 5, BUSY_ICON_FRIENDLY))
			user.visible_message("<span class='notice'>[user] sets [src] upright.</span>",
			"<span class='notice'>You set [src] upright.</span>")
			stat = 0
			update_icon()
			update_health()
		return

	if(locked)
		to_chat(user, "<span class='warning'>[src]'s control panel is locked! Only a Squad Leader or Engineer can unlock it now.</span>")
		return

	user.set_interaction(src)
	ui_interact(user)

	return

/obj/machinery/marine_turret/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 0)

	var/list/data = list(
		"self_ref" = "\ref[src]",
		"name" = copytext(src.name, 2),
		"is_on" = on,
		"rounds" = rounds,
		"rounds_max" = rounds_max,
		"health" = health,
		"health_max" = health_max,
		"has_cell" = (cell ? 1 : 0),
		"cell_charge" = cell ? cell.charge : 0,
		"cell_maxcharge" = cell ? cell.maxcharge : 0,
		"dir" = dir,
		"burst_fire" = burst_fire,
		"safety_toggle" = !safety_off,
		"manual_override" = manual_override,
		"alerts_on" = alerts_on,
		"radial_mode" = radial_mode,
		"burst_size" = burst_size,
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		if(!istype(src, /obj/machinery/marine_turret/mini)) //Check for mini-sentry
			ui = new(user, src, ui_key, "sentry.tmpl", "[src.name] UI", 625, 525)
		else
			ui = new(user, src, ui_key, "minisentry.tmpl", "[src.name] UI", 625, 525)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/marine_turret/Topic(href, href_list)
	if(usr.stat)
		return

	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return

	if(get_dist(loc, user.loc) > 1 || user.is_mob_incapacitated())
		return

	user.set_interaction(src)
	switch(href_list["op"])

		if("burst")
			if(!cell || cell.charge <= 0 || !anchored || immobile || !on || stat)
				return

			if(burst_fire)
				burst_fire = 0
				state("A green light on [src] blinks slowly.")
				to_chat(usr, "\blue You deactivate the burst fire mode.")
			else
				burst_fire = 1
				fire_delay = burst_delay
				user.visible_message("<span class='notice'>[user] activates [src]'s burst fire mode.</span>",
				"<span class='notice'>You activate [src]'s burst fire mode.</span>")
				state("<span class='notice'>A green light on [src] blinks rapidly.</span>")

		if("burstup")
			if(!cell || cell.charge <= 0 || !anchored || immobile || !on || stat)
				return

			burst_size = CLAMP(burst_size + 1, min_burst, max_burst)
			user.visible_message("<span class='notice'>[user] increments the [src]'s burst count.</span>",
			"<span class='notice'>You increment [src]'s burst fire count.</span>")

		if("burstdown")
			if(!cell || cell.charge <= 0 || !anchored || immobile || !on || stat)
				return

			burst_size = CLAMP(burst_size - 1, min_burst, max_burst)
			user.visible_message("<span class='notice'>[user] decrements the [src]'s burst count.</span>",
			"<span class='notice'>You decrement [src]'s burst fire count.</span>")

		if("safety")
			if(!cell || cell.charge <= 0 || !anchored || immobile || !on || stat)
				return

			if(!safety_off)
				safety_off = 1
				user.visible_message("<span class='warning'>[user] deactivates [src]'s safety lock.</span>",
				"<span class='warning'>You deactivate [src]'s safety lock.</span>")
				state("<span class='warning'>A red light on [src] blinks brightly!")
			else
				safety_off = 0
				user.visible_message("<span class='notice'>[user] activates [src]'s safety lock.</span>",
				"<span class='notice'>You activate [src]'s safety lock.</span>")
				state("<span class='notice'>A red light on [src] blinks rapidly.</span>")

		if("manual") //Alright so to clean this up, fuck that manual control pop up. Its a good idea but its not working out in practice.
			if(!manual_override)
				if(user.interactee != src) //Make sure if we're using a machine we can't use another one (ironically now impossible due to handle_click())
					to_chat(user, "<span class='warning'>You can't multitask like this!</span>")
					return
				if(operator != user && operator) //Don't question this. If it has operator != user it wont fucken work. Like for some reason this does it proper.
					to_chat(user, "<span class='warning'>Someone is already controlling [src].</span>")
					return
				if(!operator) //Make sure we can use it.
					operator = user
					user.visible_message("<span class='notice'>[user] takes manual control of [src]</span>",
					"<span class='notice'>You take manual control of [src]</span>")
					state("<span class='warning'>The [name] buzzes: <B>WARNING!</B> MANUAL OVERRIDE INITIATED.</span>")
					user.set_interaction(src)
					manual_override = TRUE
				else
					if(user.interactee)
						user.visible_message("<span class='notice'>[user] lets go of [src]</span>",
						"<span class='notice'>You let go of [src]</span>")
						state("<span class='notice'>The [name] buzzes: AI targeting re-initialized.</span>")
						user.unset_interaction()
					else
						to_chat(user, "<span class='warning'>You are not currently overriding this turret.</span>")
				if(stat == 2)
					stat = 0 //Weird bug goin on here
			else //Seems to be a bug where the manual override isn't properly deactivated; this toggle should fix that.
				state("<span class='notice'>The [name] buzzes: AI targeting re-initialized.</span>")
				manual_override = FALSE
				operator = null
				user.unset_interaction()

		if("power")
			if(!on)
				user.visible_message("<span class='notice'>[user] activates [src].</span>",
				"<span class='notice'>You activate [src].</span>")
				state("<span class='notice'>The [name] hums to life and emits several beeps.</span>")
				state("<span class='notice'>The [name] buzzes in a monotone voice: 'Default systems initiated'.</span>'")
				target = null
				on = TRUE
				SetLuminosity(7)
				if(!camera)
					camera = new /obj/machinery/camera(src)
					camera.network = list("military")
					camera.c_tag = src.name
				update_icon()
			else
				on = FALSE
				user.visible_message("<span class='notice'>[user] deactivates [src].</span>",
				"<span class='notice'>You deactivate [src].</span>")
				state("<span class='notice'>The [name] powers down and goes silent.</span>")
				processing_objects.Remove(src)
				update_icon()

		if("toggle_alert")
			if(!alerts_on)
				user.visible_message("<span class='notice'>[user] activates [src]'s alert notifications.</span>",
				"<span class='notice'>You activate [src]'s alert notifications.</span>")
				state("<span class='notice'>The [name] buzzes in a monotone voice: 'Alert notification system initiated'.</span>'")
				alerts_on = TRUE
				update_icon()
			else
				alerts_on = FALSE
				user.visible_message("<span class='notice'>[user] deactivates [src]'s alert notifications.</span>",
				"<span class='notice'>You deactivate [src]'s alert notifications.</span>")
				state("<span class='notice'>The [name] buzzes in a monotone voice: 'Alert notification system deactivated'.</span>'")
				update_icon()

		if("toggle_radial")
			radial_mode = !radial_mode
			var/rad_msg = radial_mode ? "activate" : "deactivate"
			user.visible_message("<span class='notice'>[user] [rad_msg]s [src]'s radial mode.</span>", "<span class='notice'>You [rad_msg] [src]'s radial mode.</span>")
			state("The [name] buzzes in a monotone voice: 'Radial mode [rad_msg]d'.'")
			range = radial_mode ? 3 : 7
			update_icon()

	attack_hand(user)

//Manual override turns off automatically once the user no longer interacts with the turret.
/obj/machinery/marine_turret/on_unset_interaction(mob/user)
	..()
	if(manual_override && operator == user)
		operator = null
		manual_override = FALSE

/obj/machinery/marine_turret/check_eye(mob/user)
	if(user.is_mob_incapacitated() || get_dist(user, src) > 1 || is_blind(user) || user.lying || !user.client)
		user.unset_interaction()

/obj/machinery/marine_turret/attackby(var/obj/item/O as obj, mob/user as mob)
	if(!ishuman(user))
		return ..()

	if(isnull(O)) return

	//Panel access
	if(istype(O, /obj/item/card/id))
		if(allowed(user))
			locked = !locked
			user.visible_message("<span class='notice'>[user] [locked ? "locks" : "unlocks"] [src]'s panel.</span>",
			"<span class='notice'>You [locked ? "lock" : "unlock"] [src]'s panel.</span>")
			if(locked)
				if(user.interactee == src)
					user.unset_interaction()
					user << browse(null, "window=turret")
			else
				if(user.interactee == src)
					attack_hand(user)
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
		return


	//Securing/Unsecuring
	if(iswrench(O))
		if(immobile)
			to_chat(user, "<span class='warning'>[src] is completely welded in place. You can't move it without damaging it.</span>")
			return

		//Unsecure
		if(anchored)
			if(on)
				on = FALSE
				to_chat(user, "<span class='warning'>You depower [src] to unanchor it safely.</span>")
				update_icon()

			user.visible_message("<span class='notice'>[user] begins unanchoring [src] from the ground.</span>",
			"<span class='notice'>You begin unanchoring [src] from the ground.</span>")

			if(do_after(user, work_time, TRUE, 5, BUSY_ICON_BUILD))
				user.visible_message("<span class='notice'>[user] unanchors [src] from the ground.</span>",
				"<span class='notice'>You unanchor [src] from the ground.</span>")
				anchored = 0
				playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
			return

		//Secure
		if(loc) //Just to be safe.
			user.visible_message("<span class='notice'>[user] begins securing [src] to the ground.</span>",
			"<span class='notice'>You begin securing [src] to the ground.</span>")

			if(do_after(user, work_time, TRUE, 5, BUSY_ICON_BUILD))
				user.visible_message("<span class='notice'>[user] secures [src] to the ground.</span>",
				"<span class='notice'>You secure [src] to the ground.</span>")
				anchored = 1
				playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
			return


	// Rotation
	if(isscrewdriver(O))

		if(immobile)
			to_chat(user, "<span class='warning'>[src] is completely welded in place. You can't move it without damaging it.</span>")
			return

		if(on)
			to_chat(user, "<span class='warning'>You deactivate [src] to prevent its motors from interfering with your rotation.</span>")
			on = FALSE
			update_icon()

		playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] rotates [src].</span>",
		"<span class='notice'>You rotate [src].</span>")
		if(dir == NORTH)
			dir = EAST
		else if(dir == EAST)
			dir = SOUTH
		else if(dir == SOUTH)
			dir = WEST
		else if(dir == WEST)
			dir = NORTH
		return


	if(istype(O, /obj/item/tool/weldingtool))
		var/obj/item/tool/weldingtool/WT = O
		if(health < 0 || stat)
			to_chat(user, "<span class='warning'>[src]'s internal circuitry is ruined, there's no way you can salvage this on the go.</span>")
			return

		if(health >= health_max)
			to_chat(user, "<span class='warning'>[src] isn't in need of repairs.</span>")
			return

		if(WT.remove_fuel(0, user))
			user.visible_message("<span class='notice'>[user] begins repairing [src].</span>",
			"<span class='notice'>You begin repairing [src].</span>")
			if(do_after(user, 50, TRUE, 5, BUSY_ICON_FRIENDLY))
				user.visible_message("<span class='notice'>[user] repairs [src].</span>",
				"<span class='notice'>You repair [src].</span>")
				update_health(-50)
				playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)
		return

	if(iscrowbar(O))

		//Remove battery if possible
		if(anchored || immobile)
			if(cell)
				if(on)
					on = FALSE
					to_chat(user, "<span class='warning'>You depower [src] to safely remove the battery.</span>")
					update_icon()

				user.visible_message("<span class='notice'>[user] begins removing [src]'s [cell.name].</span>",
				"<span class='notice'>You begin removing [src]'s [cell.name].</span>")

				if(do_after(user, work_time, TRUE, 5, BUSY_ICON_BUILD))
					user.visible_message("<span class='notice'>[user] removes [src]'s [cell.name].</span>",
					"<span class='notice'>You remove [src]'s [cell.name].</span>")
					playsound(loc, 'sound/items/Crowbar.ogg', 25, 1)
					user.put_in_hands(cell)
					cell = null
					update_icon()
			return

	if(istype(O, /obj/item/cell))
		if(cell)
			to_chat(user, "<span class='warning'>There is already \a [cell.name] installed in [src]! Remove it with a crowbar first!</span>")
			return

		user.visible_message("<span class='notice'>[user] begins installing \a [O.name] into [src].</span>",
		"<span class='notice'>You begin installing \a [O.name] into [src].</span>")
		if(do_after(user, work_time, TRUE, 5, BUSY_ICON_BUILD))
			user.drop_inv_item_to_loc(O, src)
			user.visible_message("<span class='notice'>[user] installs \a [O.name] into [src].</span>",
			"<span class='notice'>You install \a [O.name] into [src].</span>")
			cell = O
			update_icon()
		return


	if(istype(O, magazine_type))
		var/obj/item/ammo_magazine/M = O
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.heavy_weapons < SKILL_HEAVY_WEAPONS_TRAINED)
			user.visible_message("<span class='notice'>[user] begins fumbling about, swapping a new [O.name] into [src].</span>",
			"<span class='notice'>You begin fumbling about, swapping a new [O.name] into [src].</span>")
			if(user.action_busy)
				return
			if(!do_after(user, work_time, TRUE, 5, BUSY_ICON_FRIENDLY))
				return

		playsound(loc, 'sound/weapons/unload.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] swaps a new [O.name] into [src].</span>",
		"<span class='notice'>You swap a new [O.name] into [src].</span>")
		user.drop_held_item()
		update_icon()

		if(rounds)
			var/obj/item/ammo_magazine/S = new magazine_type(user.loc)
			S.current_rounds = rounds
		rounds = min(M.current_rounds, rounds_max)
		cdel(O)
		return

	if(O.force)
		update_health(O.force/2)
	return ..()

/obj/machinery/marine_turret/update_icon()
	if(stat && health > 0) //Knocked over
		on = FALSE
		density = FALSE
		icon_state = "sentry_fallen"
		return
	else
		density = initial(density)

	if(!cell)
		on = FALSE
		icon_state = "sentry_battery_none"
		return

	if(cell.charge <= 0)
		on = FALSE
		icon_state = "sentry_battery_dead"
		return

	if(!rounds)
		icon_state = "sentry_ammo_none"
		return

	if(on)
		start_processing()
		icon_state = "sentry_on[radial_mode ? "_radial" : null]"
	else
		icon_state = "sentry_off"
		stop_processing()

/obj/machinery/marine_turret/proc/update_health(var/damage) //Negative damage restores health.

	health = CLAMP(health - damage, 0, health_max) //Sanity; health can't go below 0 or above max

	if(damage > 0) //We don't report repairs.
		if(on && alerts_on && (world.time > (last_damage_alert + SENTRY_DAMAGE_ALERT_DELAY) || health <= 0) ) //Alert friendlies
			sentry_alert(SENTRY_ALERT_DAMAGE)
			last_damage_alert = world.time

	if(health > health_max) //Sanity
		health = health_max

	if(health <= 0 && stat != 2)
		stat = 2
		state("<span class='warning'>The [name] starts spitting out sparks and smoke!")
		playsound(loc, 'sound/mecha/critdestrsyndi.ogg', 25, 1)
		for(var/i = 1 to 6)
			dir = pick(1, 2, 3, 4)
			sleep(2)
		spawn(10)
			if(src && loc)
				explosion(loc, -1, -1, 2, 0)
				if(!disposed)
					cdel(src)
		return

	if(!stat && damage > 0 && !immobile)
		if(prob(10))
			spark_system.start()
		if(damage > knockdown_threshold) //Knockdown is certain if we deal this much in one hit; no more RNG nonsense, the fucking thing is bolted.
			state("<span class='danger'>The [name] is knocked over!</span>")
			stat = 1
			if(alerts_on && on)
				sentry_alert(SENTRY_ALERT_FALLEN)
			on = FALSE
	update_icon()

/obj/machinery/marine_turret/proc/check_power(var/power)
	if (!cell || !on || stat)
		update_icon()
		return FALSE

	if(cell.charge - power <= 0)
		cell.charge = 0
		sentry_alert(SENTRY_ALERT_BATTERY)
		state("<span class='warning'>[src] emits a low power warning and immediately shuts down!</span>")
		playsound(loc, 'sound/weapons/smg_empty_alarm.ogg', 50, 1)
		SetLuminosity(0)
		update_icon()
		return FALSE

	cell.charge -= power
	return TRUE

/obj/machinery/marine_turret/emp_act(severity)
	if(cell)
		check_power(-(rand(100, 500)))
	if(on)
		if(prob(50))
			state("<span class='danger'>[src] beeps and buzzes wildly, flashing odd symbols on its screen before shutting down!</span>")
			playsound(loc, 'sound/mecha/critdestrsyndi.ogg', 25, 1)
			for(var/i = 1 to 6)
				dir = pick(1, 2, 3, 4)
				sleep(2)
			on = FALSE
	if(health > 0)
		update_health(25)
	update_icon()
	return

/obj/machinery/marine_turret/ex_act(severity)
	if(health <= 0)
		return
	switch(severity)
		if(1)
			update_health(rand(90, 150))
		if(2)
			update_health(rand(50, 150))
		if(3)
			update_health(rand(30, 100))


/obj/machinery/marine_turret/attack_alien(mob/living/carbon/Xenomorph/M)
	if(isXenoLarva(M)) return //Larvae can't do shit
	M.visible_message("<span class='danger'>[M] has slashed [src]!</span>",
	"<span class='danger'>You slash [src]!</span>")
	M.animation_attack_on(src)
	M.flick_attack_overlay(src, "slash")
	playsound(loc, "alien_claw_metal", 25)
	if(prob(10))
		if(!locate(/obj/effect/decal/cleanable/blood/oil) in loc)
			new /obj/effect/decal/cleanable/blood/oil(loc)
	update_health(rand(M.xeno_caste.melee_damage_lower,M.xeno_caste.melee_damage_upper))

/obj/machinery/marine_turret/bullet_act(var/obj/item/projectile/Proj) //Nope.
	visible_message("[src] is hit by the [Proj.name]!")

	if(Proj.ammo.flags_ammo_behavior & AMMO_XENO_ACID) //Fix for xenomorph spit doing baby damage.
		update_health(round(Proj.damage * 0.33))
	else
		update_health(round(Proj.damage * 0.1))
	return TRUE

/obj/machinery/marine_turret/process()

	if(health > 0 && stat != 1)
		stat = 0
	if(!anchored)
		return

	if(!on || stat == 1 || !cell)
		return

	if(!check_power(2))
		return

	if(operator || manual_override) //If someone's firing it manually.
		return

	if(rounds == 0)
		update_icon()
		return

	//Clear the target list after the delay
	if(world.time > last_alert + SENTRY_ALERT_DELAY)
		alert_list = list()

	if(radial_mode) //Little hint for the xenos.
		playsound(loc, 'sound/items/tick.ogg', 25, FALSE)
	else
		playsound(loc, 'sound/items/detector.ogg', 25, FALSE)

	manual_override = FALSE
	target = get_target()
	process_shot()
	return

/obj/machinery/marine_turret/proc/load_into_chamber()
	if(in_chamber) return 1 //Already set!
	if(!on || !cell || rounds == 0 || stat == 1) return 0

	in_chamber = rnew(/obj/item/projectile, loc) //New bullet!
	in_chamber.generate_bullet(ammo)
	return 1

/obj/machinery/marine_turret/proc/process_shot()
	set waitfor = 0

	if(isnull(target)) return //Acquire our victim.

	if(!ammo) return

	if(burst_fire && target && !last_fired)
		if(rounds >= burst_size)
			for(var/i = 1 to burst_size)
				is_bursting = 1
				if(fire_shot())
					sleep(1)
				else
					break
			spawn(0)
				last_fired = 1
			spawn(fire_delay)
				last_fired = 0
		else
			burst_fire = 0
		is_bursting = 0

	if(!burst_fire && target && !last_fired)
		fire_shot()

	target = null

/obj/machinery/marine_turret/proc/fire_shot()
	if(!target || !on || !ammo) return
	if(last_fired) return

	if(!is_bursting)
		last_fired = 1
		spawn(fire_delay)
			last_fired = 0

	var/turf/my_loc = get_turf(src)
	var/turf/targloc = get_turf(target)

	if(!istype(my_loc) || !istype(target))
		return

	if(!check_power(2))
	 return

	var/target_dir = get_dir(src, targloc)
	//if( ( target_dir & turn(dir, 180) ) && !radial_mode)
	//	return

	if(radial_mode && !manual_override)
		dir = target_dir


	if(load_into_chamber())
		if(istype(in_chamber,/obj/item/projectile))

			if (burst_fire)
				//Apply scatter
				var/scatter_chance = in_chamber.ammo.scatter
				scatter_chance += (burst_size * 2)
				in_chamber.accuracy = round(in_chamber.accuracy * (config.base_hit_accuracy_mult - config.min_hit_accuracy_mult * max(0,burst_size - 2) ) ) //Accuracy penalty scales with burst count.

				if (prob(scatter_chance))
					var/scatter_x = rand(-1, 1)
					var/scatter_y = rand(-1, 1)
					var/turf/new_target = locate(targloc.x + round(scatter_x),targloc.y + round(scatter_y),targloc.z) //Locate an adjacent turf.
					if(new_target) //Looks like we found a turf.
						target = new_target
			else
				in_chamber.accuracy = round(in_chamber.accuracy * (config.base_hit_accuracy_mult + config.med_hit_accuracy_mult)) //much more accurate on single fire

			//Setup projectile
			in_chamber.original = target
			in_chamber.dir = dir
			in_chamber.def_zone = pick("chest", "chest", "chest", "head")

			//Shoot at the thing
			playsound(loc, 'sound/weapons/gun_rifle.ogg', 75, 1)
			in_chamber.fire_at(target, src, null, ammo.max_range, ammo.shell_speed)
			if(target)
				var/angle = round(Get_Angle(src,target))
				muzzle_flash(angle)
			in_chamber = null
			rounds--
			if(rounds == 0)
				state("<span class='warning'>The [name] beeps steadily and its ammo light blinks red.</span>")
				playsound(loc, 'sound/weapons/smg_empty_alarm.ogg', 50, FALSE)
				if(alerts_on)
					sentry_alert(SENTRY_ALERT_AMMO)

	return TRUE

//Mostly taken from gun code.
/obj/machinery/marine_turret/proc/muzzle_flash(var/angle)
	if(isnull(angle)) return

	SetLuminosity(muzzle_flash_lum)
	spawn(10)
		SetLuminosity(-muzzle_flash_lum)

	if(prob(65))
		var/layer = MOB_LAYER - 0.1

		var/image/reusable/I = rnew(/image/reusable, list('icons/obj/items/projectiles.dmi',src,"muzzle_flash",layer))
		var/matrix/rotate = matrix() //Change the flash angle.
		rotate.Translate(0, 5)
		rotate.Turn(angle)
		I.transform = rotate
		I.flick_overlay(src, 3)

/obj/machinery/marine_turret/proc/get_target()
	var/list/targets = list()

	var/list/turf/path = list()
	var/turf/T
	var/mob/living/M

	for(M in oview(range, src))
		if(M.stat == DEAD || isrobot(M)) //No dead or robots.
			continue
		if(!safety_off && !isXeno(M)) //When safeties are on, Xenos only.
			continue
		/*
		I really, really need to replace this with some that isn't insane. You shouldn't have to fish for access like this.
		This should be enough shortcircuiting, but it is possible for the code to go all over the possibilities and generally
		slow down. It'll serve for now.
		*/
		var/mob/living/carbon/human/H = M
		if(istype(H) && H.get_target_lock(iff_signal))
			continue



		var/angle = get_dir(src, M)
		if(angle & dir || radial_mode)
			path = getline2(src, M, TRUE)
			//path -= get_turf(src)
			if(alerts_on) //They're within our field of detection and thus can trigger the alarm
				if(world.time > (last_alert + SENTRY_ALERT_DELAY) || !(M in alert_list)) //if we're not on cooldown or the target isn't in the list, sound the alarm
					playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
					sentry_alert(SENTRY_ALERT_HOSTILE, M)
					alert_list.Add(M)
					last_alert = world.time
		else
			continue

		if(path.len)
			var/blocked = FALSE
			for(T in path)
				if(T.opacity || T.density)
					blocked = TRUE
					break //LoF Broken; stop checking; we can't proceed further.

				for(var/obj/machinery/MA in T)
					if(MA.opacity || MA.density && !(MA.flags_atom & ON_BORDER) )
						blocked = TRUE
						break //LoF Broken; stop checking; we can't proceed further.

				for(var/obj/structure/S in T)
					if(S.opacity || S.density && !(S.flags_atom & ON_BORDER) )
						blocked = TRUE
						break //LoF Broken; stop checking; we can't proceed further.
			if(!blocked)
				targets += M

	if(targets.len) . = pick(targets)

//Direct replacement to new proc. Everything works.
/obj/machinery/marine_turret/handle_click(mob/living/carbon/human/user, atom/A, params)
	if(!operator || !istype(user) || operator != user)
		return FALSE
	if(istype(A, /obj/screen))
		return FALSE
	if(!manual_override)
		return FALSE
	if(operator.interactee != src)
		return FALSE
	if(is_bursting)
		return
	if(get_dist(user, src) > 1 || user.is_mob_incapacitated())
		user.visible_message("<span class='notice'>[user] lets go of [src]</span>",
		"<span class='notice'>You let go of [src]</span>")
		state("<span class='notice'>The [name] buzzes: AI targeting re-initialized.</span>")
		user.unset_interaction()
		return FALSE
	if(user.get_active_hand() != null)
		to_chat(usr, "<span class='warning'>You need a free hand to shoot [src].</span>")
		return FALSE

	target = A
	if(!istype(target))
		return FALSE

	if(target.z != z || target.z == 0 || z == 0 || isnull(operator.loc) || isnull(loc))
		return FALSE

	if(get_dist(target, loc) > 10)
		return FALSE

	var/list/modifiers = params2list(params) //Only single clicks.
	if(modifiers["middle"] || modifiers["shift"] || modifiers["alt"] || modifiers["ctrl"])
		return FALSE

	var/dx = target.x - x
	var/dy = target.y - y //Calculate which way we are relative to them. Should be 90 degree cone..
	var/direct

	if(abs(dx) < abs(dy))
		if(dy > 0)
			direct = NORTH
		else
			direct = SOUTH
	else
		if(dx > 0)
			direct = EAST
		else
			direct = WEST

	if(direct == dir && target.loc != src.loc && target.loc != operator.loc)
		process_shot()
		return TRUE

	return FALSE
/*
/obj/item/turret_laptop
	name = "UA 571-C Turret Control Laptop"
	desc = "A small device used for remotely controlling sentry turrets."
	w_class = 4
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "turret_off"
	unacidable = 1
	var/linked_turret = null
	var/on = 0
	var/mob/living/carbon/human/user = null
	var/obj/machinery/camera/current = null

	check_eye(var/mob/user as mob)
		if (user.z == 0 || user.stat || ((get_dist(user, src) > 1 || is_blind(user)) && !istype(user, /mob/living/silicon))) //user can't see - not sure why canmove is here.
			return null
		if(!linked_turret || isnull(linked_turret.camera))
			return null
		user.reset_view(linked_turret.camera)
		return 1

	attack_self(mob/living/user as mob)
		if(!linked_turret)
*/
/obj/machinery/marine_turret/premade
	name = "UA-577 Gauss Turret"
	immobile = TRUE
	on = TRUE
	burst_fire = TRUE
	rounds = 500
	rounds_max = 500
	icon_state = "sentry_on"

/obj/machinery/marine_turret/premade/New()
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	var/obj/item/cell/super/H = new(src) //Better cells in these ones.
	cell = H
	camera = new (src)
	camera.network = list("military")
	camera.c_tag = "[src.name] ([rand(0,1000)])"
	spawn(2)
		stat = 0
	ammo = ammo_list[ammo]
	update_icon()

/obj/machinery/marine_turret/premade/dumb
	name = "Modified UA-577 Gauss Turret"
	desc = "A deployable, semi-automated turret with AI targeting capabilities. Armed with an M30 Autocannon and a high-capacity drum magazine. This one's IFF system has been disabled, and it will open fire on any targets within range."
	iff_signal = 0
	rounds = 1000000
	ammo = /datum/ammo/bullet/turret/dumb

/obj/machinery/marine_turret/premade/dumb/attack_hand(mob/user as mob)

	if(isYautja(user))
		to_chat(user, "<span class='warning'>You punch [src] but nothing happens.</span>")
		return
	src.add_fingerprint(user)

	if(!cell || cell.charge <= 0)
		to_chat(user, "<span class='warning'>You try to activate [src] but nothing happens. The cell must be empty.</span>")
		return

	if(!anchored)
		to_chat(user, "<span class='warning'>It must be anchored to the ground before you can activate it.</span>")
		return

	if(!on)
		to_chat(user, "You turn on the [src].")
		visible_message("\blue [src] hums to life and emits several beeps.")
		state("[src] buzzes in a monotone: 'Default systems initiated.'")
		target = null
		on = TRUE
		SetLuminosity(7)
		if(!camera)
			camera = new /obj/machinery/camera(src)
			camera.network = list("military")
			camera.c_tag = src.name
		update_icon()
	else
		on = FALSE
		user.visible_message("<span class='notice'>[user] deactivates [src].</span>",
		"<span class='notice'>You deactivate [src].</span>")
		state("<span class='notice'>The [name] powers down and goes silent.</span>")
		update_icon()

//the turret inside the sentry deployment system
/obj/machinery/marine_turret/premade/dropship
	density = FALSE
	ammo = /datum/ammo/bullet/turret/gauss //This is a gauss cannon; it will be significantly deadlier
	rounds = 1000000
	safety_off = TRUE
	burst_size = 10
	burst_delay = 15
	var/obj/structure/dropship_equipment/sentry_holder/deployment_system

/obj/machinery/marine_turret/premade/dropship/Dispose()
	if(deployment_system)
		deployment_system.deployed_turret = null
		deployment_system = null
	. = ..()


/obj/machinery/marine_turret/proc/sentry_alert(alert_code, mob/M)
	if(!alert_code)
		return
	var/notice
	switch(alert_code)
		if(SENTRY_ALERT_AMMO)
			notice = "<b>ALERT! [src]'s ammo depleted at: [get_area(src)]. Coordinates: (X: [x], Y: [y]).</b>"
		if(SENTRY_ALERT_HOSTILE)
			notice = "<b>ALERT! Hostile/unknown: [M] Detected at: [get_area(M)]. Coordinates: (X: [M.x], Y: [M.y]).</b>"
		if(SENTRY_ALERT_FALLEN)
			notice = "<b>ALERT! [src] has been knocked over at: [get_area(src)]. Coordinates: (X: [x], Y: [y]).</b>"
		if(SENTRY_ALERT_DAMAGE)
			var/percent = max(0,(health / max(1,health_max))*100)
			if(percent)
				notice = "<b>ALERT! [src] at: [get_area(src)] has taken damage. Coordinates: (X: [x], Y: [y]). Remaining Structural Integrity: [percent]%</b>"
			else
				notice = "<b>ALERT! [src] at: [get_area(src)], Coordinates: (X: [x], Y: [y]) has been destroyed.</b>"
		if(SENTRY_ALERT_BATTERY)
			notice = "<b>ALERT! [src]'s battery depleted at: [get_area(src)]. Coordinates: (X: [x], Y: [y]).</b>"
	var/mob/living/silicon/ai/AI = new/mob/living/silicon/ai(src, null, null, 1)
	AI.SetName("Sentry Alert System")
	AI.aiRadio.talk_into(AI,"[notice]","Almayer","announces")
	cdel(AI)

/obj/machinery/marine_turret/mini
	name = "\improper UA-580 Point Defense Sentry"
	desc = "A deployable, automated turret with AI targeting capabilities. This is a lightweight portable model meant for rapid deployment and point defense. Armed with an light, high velocity machine gun and a 500-round drum magazine."
	icon = 'icons/Marine/miniturret.dmi'
	icon_state = "minisentry_on"
	cell = /obj/item/cell/high
	on = FALSE
	anchored = FALSE
	burst_fire = TRUE
	burst_size = 3
	min_burst = 2
	max_burst = 5
	health = 155
	health_max = 155
	rounds = 500
	rounds_max = 500
	knockdown_threshold = 70 //lighter, not as well secured.
	work_time = 20 //significantly faster than the big sentry
	ammo = /datum/ammo/bullet/turret/mini //Similar to M39 AP rounds.
	magazine_type = /obj/item/ammo_magazine/minisentry

/obj/item/storage/box/sentry/New()
	. = ..()
	update_icon()

/obj/machinery/marine_turret/mini/MouseDrop(over_object, src_location, over_location) //Drag the tripod onto you to fold it.
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr //this is us
	if(!over_object == user || !in_range(src, user))
		return

	if(anchored)
		to_chat(user, "<span class='warning'>You must unanchor [src] to retrieve it!</span>")
		return

	if(on)
		to_chat(user, "<span class='warning'>You depower [src] to facilitate its retrieval.</span>")
		on = FALSE
		update_icon()

	user.visible_message("<span class='notice'>[user] begins to fold up and retrieve [src].</span>",
	"<span class='notice'>You begin to fold up and retrieve [src].</span>")
	if(do_after(user, work_time * 1.5, TRUE, 5, BUSY_ICON_BUILD))
		if(!src || on || anchored)//Check if we got exploded
			return
		to_chat(user, "<span class='notice'>You fold up and retrieve [src].</span>")
		var/obj/item/device/marine_turret/mini/P = new(loc)
		user.put_in_hands(P)
		P.health = health //track the health
		cdel(src)

/obj/machinery/marine_turret/mini/update_icon()
	if(stat && health > 0) //Knocked over
		on = FALSE
		density = FALSE
		icon_state = "minisentry_fallen"
		return
	else
		density = initial(density)

	if(!cell)
		on = FALSE
		icon_state = "minisentry_nobat"
		return

	if(cell.charge <= 0)
		on = FALSE
		icon_state = "minisentry_nobat"
		return

	if(!rounds)
		icon_state = "minisentry_noammo"
		return

	if(on)
		start_processing()
		if(!radial_mode)
			icon_state = "minisentry_on"
		else
			icon_state = "minisentry_on_radial"
	else
		icon_state = "minisentry_off"
		stop_processing()


/obj/item/device/marine_turret/mini
	name = "\improper UA-580 Point Defense Sentry (Folded)"
	desc = "A deployable, automated turret with AI targeting capabilities. This is a lightweight portable model meant for rapid deployment and point defense. Armed with an light, high velocity machine gun and a 500-round drum magazine. It is currently folded up."
	icon = 'icons/Marine/miniturret.dmi'
	icon_state = "minisentry_packed"
	item_state = "minisentry_packed"
	w_class = 4
	health = 150 //We keep track of this when folding up the sentry.
	flags_equip_slot = SLOT_BACK

/obj/item/device/marine_turret/mini/attack_self(mob/user) //click the sentry to deploy it.
	if(!ishuman(usr))
		return
	var/turf/target = get_step(user.loc,user.dir)
	if(!target)
		return

	if(check_blocked_turf(target)) //check if blocked
		to_chat(user, "<span class='warning'>There is insufficient room to deploy [src]!</span>")
		return
	if(do_after(user, 30, TRUE, 5, BUSY_ICON_BUILD))
		if(!src) //Make sure the sentry still exists
			return
		var/obj/machinery/marine_turret/mini/M = new /obj/machinery/marine_turret/mini(target)
		M.dir = user.dir
		user.visible_message("<span class='notice'>[user] deploys [M].</span>",
		"<span class='notice'>You deploy [M].</span>")
		playsound(target, 'sound/weapons/mine_armed.ogg', 25)
		M.health = health
		M.update_icon()
		cdel(src)

/obj/item/ammo_magazine/minisentry
	name = "M30 box magazine (10x28mm Caseless)"
	desc = "A box of 500 10x20mm caseless rounds for the UA-580 Point Defense Sentry. Just feed it into the sentry gun's ammo port when its ammo is depleted."
	w_class = 3
	icon_state = "ua580"
	flags_magazine = NOFLAGS //can't be refilled or emptied by hand
	caliber = "10x20mm"
	max_rounds = 500
	default_ammo = /datum/ammo/bullet/turret/mini
	gun_type = null

/obj/item/storage/box/minisentry
	name = "\improper UA-580 point defense sentry crate"
	desc = "A large case containing all you need to set up an UA-580 point defense sentry."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sentry_case"
	w_class = 5
	storage_slots = 4
	can_hold = list(/obj/item/device/marine_turret/mini, //gun itself
					/obj/item/tool/wrench, //wrench to hold it down into the ground
					/obj/item/tool/screwdriver, //screw the gun onto the post.
					/obj/item/ammo_magazine/minisentry)

/obj/item/storage/box/minisentry/New()
	. = ..()
	spawn(1)
		new /obj/item/device/marine_turret/mini(src) //gun itself
		new /obj/item/tool/wrench(src) //wrench to hold it down into the ground
		new /obj/item/tool/screwdriver(src) //screw the gun onto the post.
		new /obj/item/ammo_magazine/minisentry(src)
