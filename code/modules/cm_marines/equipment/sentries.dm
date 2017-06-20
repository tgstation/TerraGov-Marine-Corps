//Deployable turrets. They can be either automated, manually fired, or installed with a pAI.
//They are built in stages, and only engineers have access to them.

/obj/item/sentry_ammo
	name = "M30 box magazine (10x28mm Caseless)"
	desc = "A box of three hundred 10x28mm caseless rounds for the UA 571-C Sentry Gun. Just feed it into the sentry gun's ammo port when its ammo is depleted."
	w_class = 4
	icon = 'icons/obj/ammo.dmi'
	icon_state = "ua571c" //PLACEHOLDER

/obj/item/weapon/storage/box/sentry
	name = "\improper UA 571-C sentry crate"
	desc = "A large case containing all you need to set up an automated sentry, minus the tools."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sentry_case"
	w_class = 5
	storage_slots = 6
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.

	New()
		..()
		spawn(1)
			var/obj/item/stack/sheet/plasteel/plasteel_stack = new(src)
			plasteel_stack.amount = 20
			var/obj/item/stack/sheet/metal/metal_stack = new(src)
			metal_stack.amount = 10
			new /obj/item/device/turret_top(src)
			new /obj/item/device/turret_sensor(src)
			new /obj/item/weapon/cell(src)
			new /obj/item/sentry_ammo(src)

/obj/machinery/marine_turret_frame
	name = "\improper UA 571-C turret frame"
	desc = "An unfinished turret frame. It requires wrenching, cable coil, a turret piece, a sensor, and metal plating."
	icon = 'icons/Marine/turret.dmi'
	icon_state = "turret-nocable"
	anchored = 0
	density = 1
	layer = 3.4
	var/has_cable = 0
	var/has_top = 0
	var/has_sensor = 0
	var/has_plates = 0

	examine(mob/user as mob)
		..()
		if(!anchored)
			usr << "<span class='info'>It must be <B>wrenched</b> to the floor.</span>"
		if(!has_cable)
			usr << "<span class='info'>It requires <b>cable coil</b> for wiring.</span>"
		if(!has_top)
			usr << "<span class='info'>The <b>main turret</b> is not installed.</span>"
		if(!has_sensor)
			usr << "<span class='info'>It does not have a <b>turret sensor</b> installed.</span>"
		if(!has_plates)
			usr << "<span class='info'>It does not have <B>metal</b> plating installed and welded.</span>"

	attackby(var/obj/item/O as obj, mob/user as mob)
		if(!ishuman(user))
			return
		if(isnull(O))
			return

		if(istype(O,/obj/item/weapon/wrench))
			if(anchored)
				playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
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
			else
				if(locate(/obj/machinery/marine_turret) in loc)
					user << "<span class='warning'>There already is a turret in this position.</span>"
					return

				user.visible_message("<span class='notice'>[user] begins securing [src] to the ground.</span>",
				"<span class='notice'>You begin securing [src] to the ground.</span>")
				if(do_after(user, 40, TRUE, 5, BUSY_ICON_CLOCK))
					playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
					user.visible_message("<span class='notice'>[user] secures [src] to the ground.</span>",
					"<span class='notice'>You secure [src] to the ground.</span>")
					anchored = 1
			return
		if(istype(O,/obj/item/stack/cable_coil))
			if(!anchored)
				user << "<span class='warning'>You must secure [src] to the ground first.</span>"
				return

			var/obj/item/stack/cable_coil/CC = O
			if(has_cable)
				user << "<span class='warning'>[src]'s wiring is already installed.</span>"
				return
			user.visible_message("<span class='notice'>[user] begins installing [src]'s wiring.</span>",
			"<span class='notice'>You begin installing [src]'s wiring.</span>")
			if(do_after(user, 40, TRUE, 5, BUSY_ICON_CLOCK))
				if(CC.use(10))
					has_cable = 1
					playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)
					user.visible_message("<span class='notice'>[user] installs [src]'s wiring.</span>",
					"<span class='notice'>You install [src]'s wiring.</span>")
					icon_state = "turret-bottom"
					return
				else
					user << "<span class='warning'>You will need at least ten cable lengths to finish [src]'s wiring.</span>"

		if(istype(O, /obj/item/device/turret_top))
			if(!has_cable)
				user << "<span class='warning'>You must install [src]'s wiring first.</span>"
				return
			if(has_top)
				user << "<span class='warning'>[src] already has a turret installed.</span>"
				return
			user.visible_message("<span class='notice'>[user] begins installing [O] on [src].</span>",
			"<span class='notice'>You begin installing [O] on [src].</span>")
			if(do_after(user, 60, TRUE, 5, BUSY_ICON_CLOCK))
				playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)
				user.visible_message("<span class='notice'>[user] installs [O] on [src].</span>",
				"<span class='notice'>You install [O] on [src].</span>")
				has_top = 1
				icon_state = "turret-nosensor"
				user.drop_held_item()
				cdel(O)
				return

		if(istype(O, /obj/item/device/turret_sensor))
			if(!has_top)
				user << "<span class='warning'>You must install [src]'s turret first.</span>"
				return
			if(has_sensor)
				user << "<span class='warning'>[src] already has a sensor installed.</span>"
				return
			user.visible_message("<span class='notice'>[user] begins installing [O] on [src].</span>",
			"<span class='notice'>You begin installing [O] on [src].</span>")
			if(do_after(user, 40, TRUE, 5, BUSY_ICON_CLOCK))
				has_sensor = 1
				playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)
				user.visible_message("<span class='notice'>[user] installs [O] on [src].</span>",
				"<span class='notice'>You install [O] on [src].</span>")
				icon_state = "turret-0"
				user.drop_held_item()
				cdel(O)
				return

		if(istype(O, /obj/item/stack/sheet/metal))
			var/obj/item/stack/sheet/metal/M = O
			if(!has_sensor)
				user << "<span class='warning'>You must install [src]'s sensor first.</span>"
				return
			if(has_plates)
				user << "<span class='warning'>[src] already has plates installed.</span>"
				return
			if(M.amount < 10)
				user << "<span class='warning'>[src]'s plating will require at least ten sheets of metal.</span>"
				return
			user.visible_message("<span class='notice'>[user] begins installing [src]'s reinforced plating.</span>",
			"<span class='notice'>You begin installing [src]'s reinforced plating.</span>")
			if(do_after(user, 50, TRUE, 5, BUSY_ICON_CLOCK))
				if(!M) return
				if(M.amount >= 10)
					has_plates = 1
					playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)
					user.visible_message("<span class='notice'>[user] installs [src]'s reinforced plating.</span>",
					"<span class='notice'>You install [src]'s reinforced plating.</span>")
					M.amount -= 10
					if(M.amount <= 0)
						user.drop_held_item()
						cdel(M)
					return
				else
					user << "<span class='warning'>[src]'s plating will require at least ten sheets of metal.</span>"
					return
		if(istype(O, /obj/item/weapon/weldingtool))
			if(!has_plates)
				user << "<span class='warning'>You must install [src]'s plating first.</span>"
				return
			var/obj/item/weapon/weldingtool/WT = O
			playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)
			user.visible_message("<span class='notice'>[user] begins welding [src]'s parts together.</span>",
			"<span class='notice'>You begin welding [src]'s parts together.</span>")
			if(do_after(user,60, TRUE, 5, BUSY_ICON_CLOCK))
				if(!src || !WT || !WT.isOn()) return
				if(WT.remove_fuel(0, user))
					playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)
					user.visible_message("<span class='notice'>[user] welds [src]'s parts together.</span>",
					"<span class='notice'>You weld [src]'s parts together.</span>")
					var/obj/machinery/marine_turret/T = new(loc)  //Bing! Create a new turret.
					T.dir = dir
					cdel(src)
					return
				else
					user << "<span class='warning'>You need more welding fuel to complete this task.</span>"
					return

		return ..() //Just do normal stuff.

/obj/item/device/turret_sensor
	name = "\improper UA 571-C turret sensor"
	desc = "An AI control and locking sensor for an automated sentry. This must be installed on the final product for it to work."
	unacidable = 1
	w_class = 1
	icon = 'icons/Marine/turret.dmi'
	icon_state = "turret-sensor"

/obj/item/device/turret_top
	name = "\improper UA 571-C turret"
	desc = "The turret part of an automated sentry turret. This must be installed on a turret frame and welded together for it to do anything."
	unacidable = 1
	w_class = 5
	icon = 'icons/Marine/turret.dmi'
	icon_state = "turret-top"

/obj/machinery/marine_turret
	name = "\improper UA 571-C sentry gun"
	desc = "A deployable, semi-automated turret with AI targeting capabilities. Armed with an M30 Autocannon and a 300-round drum magazine."
	icon = 'icons/Marine/turret.dmi'
	icon_state = "turret-0"
	anchored = 1
	unacidable = 1
	density = 1
	layer = MOB_LAYER+0.1 //So you can't hide it under corpses
	use_power = 0
	flags_atom = RELAY_CLICK
	req_one_access = list(ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_ENGPREP, ACCESS_MARINE_LEADER)
	var/iff_signal = ACCESS_IFF_MARINE
	var/dir_locked = 1
	var/safety_off = 0
	var/rounds = 300
	var/rounds_max = 300
	var/locked = 0
	var/atom/target = null
	var/mob/living/carbon/human/worker = null
	var/manual_override = 0
	var/on = 0
	var/health = 200
	var/health_max = 200
	stat = 0 //Used just like mob.stat
	var/datum/effect_system/spark_spread/spark_system // the spark system, used for generating... sparks?
	var/obj/item/weapon/cell/cell = null
	var/burst_fire = 0
	var/obj/machinery/camera/camera = null
	var/fire_delay = 5
	var/last_fired = 0
	var/is_bursting = 0
	var/obj/item/turret_laptop/laptop = null
	var/immobile = 0 //Used for prebuilt ones.
	var/datum/ammo/bullet/turret/ammo = /datum/ammo/bullet/turret
	var/obj/item/projectile/in_chamber = null

	New()
		spark_system = new /datum/effect_system/spark_spread
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		cell = new (src)
		camera = new (src)
		camera.network = list("military")
		camera.c_tag = "[name] ([rand(0, 1000)])"
		spawn(2)
			stat = 0
			processing_objects.Add(src)
		ammo = ammo_list[ammo]

	Dispose() //Clear these for safety's sake.
		if(operator && operator.machine)
			operator.machine = null
			operator = null
		if(camera)
			cdel(camera)
			camera = null
		if(cell)
			cdel(cell)
			cell = null
		if(target)
			target = null
		if(worker)
			worker = null
		SetLuminosity(0)
		processing_objects.Remove(src)
		. = ..()

/obj/machinery/marine_turret/attack_hand(mob/user as mob)
	if(isYautja(user))
		user << "<span class='warning'>You punch [src] but nothing happens.</span>"
		return
	src.add_fingerprint(user)

	if(!cell || cell.charge <= 0)
		user << "<span class='warning'>You try to activate [src] but nothing happens. The cell must be empty.</span>"
		return

	if(!anchored)
		user << "<span class='warning'>It must be anchored to the ground before you can activate it.</span>"
		return

	if(immobile)
		user << "<span class='warning'>[src]'s panel is completely locked, you can't do anything.</span>"
		return

	if(stat)
		user.visible_message("<span class='notice'>[user] begins to set [src] upright.</span>",
		"<span class='notice'>You begin to set [src] upright.</span>")
		if(do_after(user,20, TRUE, 5, BUSY_ICON_CLOCK))
			user.visible_message("<span class='notice'>[user] sets [src] upright.</span>",
			"<span class='notice'>You set [src] upright.</span>")
			stat = 0
			update_icon()
			update_health()
		return

	if(locked)
		user << "<span class='warning'>[src]'s control panel is locked! Only a Squad Leader or Engineer can unlock it now.</span>"
		return


	worker = user

	user.set_machine(src)
	ui_interact(user)

	return

/obj/machinery/marine_turret/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)

	var/list/data = list(
		"self_ref" = "\ref[src]",
		"name" = copytext(src.name, 2),
		"is_on" = on,
		"rounds" = rounds,
		"rounds_max" = rounds_max,
		"health" = health,
		"health_max" = health_max,
		"has_cell" = (cell ? 1 : 0),
		"cell_charge" = cell.charge,
		"cell_maxcharge" = cell.maxcharge,
		"dir_locked" = dir_locked,
		"dir" = dir,
		"burst_fire" = burst_fire,
		"safety_toggle" = !safety_off,
		"manual_override" = manual_override,
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "cm_sentry.tmpl", "[src.name] UI", 625, 525)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/marine_turret/Topic(href, href_list)
	if(usr.stat)
		return

	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return

	if(get_dist(src.loc, user.loc) > 1)
		return

	usr.set_machine(src)
	switch(href_list["op"])
		if("direction")
			if(user.stat || get_dist(src.loc, user.loc) < 1)
				return
			if(!cell || cell.charge <= 0 || !anchored || immobile || !on || stat)
				return

			if(dir_locked)
				dir_locked = 0
				visible_message("\icon[src] The [src]'s turret begins turning side to side.")
				usr << "\blue You deactivate the direction lock."
			else
				dir_locked = 1
				usr.visible_message("<span class='notice'>[usr] activates [src]'s direction lock.</span>",
				"<span class='notice'>You activate [src]'s direction lock.</span>")
				visible_message("\icon[src] <span class='notice'>The [name]'s turret stops rotating.</span>")

			return

		if("burst")
			if(user.stat || get_dist(src.loc, user.loc) < 1)
				return
			if(!cell || cell.charge <= 0 || !anchored || immobile || !on || stat)
				return

			if(burst_fire)
				burst_fire = 0
				visible_message("\icon[src] A green light on [src] blinks slowly.")
				usr << "\blue You deactivate the burst fire mode."
			else
				burst_fire = 1
				fire_delay = 15
				usr.visible_message("<span class='notice'>[usr] activates [src]'s burst fire mode.</span>",
				"<span class='notice'>You activate [src]'s burst fire mode.</span>")
				visible_message("\icon[src] <span class='notice'>A green light on [src] blinks rapidly.</span>")

			return

		if("safety")
			if(user.stat || get_dist(src.loc, user.loc) < 1)
				return
			if(!cell || cell.charge <= 0 || !anchored || immobile || !on || stat)
				return

			if(!safety_off)
				safety_off = 1
				visible_message("\icon[src] A red light on [src] blinks brightly!")
				usr << "\blue You deactivate the safety lock. Careful now!"
			else
				safety_off = 0
				usr.visible_message("<span class='notice'>[usr] activates [src]'s safety lock.</span>",
				"<span class='notice'>You activate [src]'s safety lock.</span>")
				visible_message("\icon[src] <span class='notice'>A red light on [src] blinks rapidly.</span>")


			return

		if("manual") //Alright so to clean this up, fuck that manual control pop up. Its a good idea but its not working out in practice.
			if(!dir_locked) //Direction lock check
				usr << "<span class='warning'>[src] can only be fired manually in direction-locked mode.</span>"
				manual_override = 0 //Make sure we jump back to AI mode, was a small bug when testing new handle_click()
				return
			if(user.machine != src) //Make sure if we're using a machine we can't use another one (ironically now impossible due to handle_click())
				usr << "<span class='warning'>You can't multitask like this!</span>"
				return
			if(operator != user && operator) //Don't question this. If it has operator != user it wont fucken work. Like for some reason this does it proper.
				usr << "<span class='warning'>Someone is already controlling [src].</span>"
				return
			if(!operator) //Make sure we can use it.
				operator = usr
				usr.visible_message("<span class='notice'>[usr] takes manual control of [src]</span>",
				"<span class='notice'>You take manual control of [src]</span>")
				visible_message("\icon[src] <span class='warning'>The [name] buzzes: <B>WARNING!</b> MANUAL OVERRIDE INITIATED.</span>")
				user.machine = src
				manual_override = 1
			else
				if(user.machine)
					operator = null
					usr.visible_message("<span class='notice'>[usr] lets go of [src]</span>",
					"<span class='notice'>You let go of [src]</span>")
					visible_message("\icon[src] <span class='notice'>The [name] buzzes: AI targeting re-initialized.</span>")
					user.machine = null
					manual_override = 0
				else
					user << "<span class='warning'>You are not currently overriding this turret.</span>" //Should be system only failure
			if(stat == 2)
				stat = 0 //Weird bug goin on here
			return
		if("power")
			if(!on)
				user << "You turn on the [src]."
				visible_message("\blue [src] hums to life and emits several beeps.")
				visible_message("\icon[src] [src] buzzes in a monotone: 'Default systems initiated.'")
				dir_locked = 1
				target = null
				worker = null
				on = 1
				SetLuminosity(7)
				if(!camera)
					camera = new /obj/machinery/camera(src)
					camera.network = list("military")
					camera.c_tag = src.name
				update_icon()
			else
				on = 0
				user.visible_message("<span class='notice'>[user] deactivates [src].</span>",
				"<span class='notice'>You deactivate [src].</span>")
				visible_message("\icon[src] <span class='notice'>The [name] powers down and goes silent.</span>")
				update_icon()
			return

	attack_hand(user)
	return

/obj/machinery/marine_turret/attackby(var/obj/item/O as obj, mob/user as mob)
	if(!ishuman(user))
		return ..()

	if(isnull(O)) return

	if(istype(O, /obj/item/weapon/card/id))
		if(allowed(user))
			locked = !locked
			user.visible_message("<span class='notice'>[user] [locked ? "locks" : "unlocks"] [src]'s panel.</span>",
			"<span class='notice'>You [locked ? "lock" : "unlock"] [src]'s panel.</span>")
			if(locked)
				if(user.machine == src)
					user.unset_machine()
					user << browse(null, "window=turret")
			else
				if(user.machine == src)
					attack_hand(user)
		else
			user << "<span class='warning'>Access denied.</span>"
		return
	if(iswrench(O))
		if(immobile)
			user << "<span class='warning'>[src] is completely welded in place. You can't move it without damaging it.</span>"
			return
		if(on)
			user << "<span class='warning'>[src] is currently active. The motors will prevent you from rotating it safely.</span>"
			return
		else
			playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
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

	if(isscrewdriver(O))
		if(immobile)
			user << "<span class='warning'>[src] is completely welded in place. You can't move it without damaging it.</span>"
			return

		if(!anchored)
			if(loc) //Just to be safe.
				user.visible_message("<span class='notice'>[user] begins securing [src] to the ground.</span>",
				"<span class='notice'>You begin securing [src] to the ground.</span>")
				if(do_after(user, 40, TRUE, 5, BUSY_ICON_CLOCK))
					user.visible_message("<span class='notice'>[user] secures [src] to the ground.</span>",
					"<span class='notice'>You secure [src] to the ground.</span>")
					anchored = 1
					playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
			return
		else
			if(on)
				user << "<span class='warning'>[src] is currently active. The motors will prevent you from unanchoring it safely.</span>"
				return
			else
				user.visible_message("<span class='notice'>[user] begins unanchoring [src] from the ground.</span>",
				"<span class='notice'>You begin unanchoring [src] from the ground.</span>")
				if(do_after(user, 40, TRUE, 5, BUSY_ICON_CLOCK))
					user.visible_message("<span class='notice'>[user] unanchores [src] from the ground.</span>",
					"<span class='notice'>You unanchor [src] from the ground.</span>")
					anchored = 0
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
		return

	if(istype(O, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = O
		if(health < 0 || stat)
			user << "<span class='warning'>[src]'s internal circuitry is ruined, there's no way you can salvage this on the go.</span>"
			return

		if(health >= health_max)
			user << "<span class='warning'>[src] isn't in need of repairs.</span>"
			return

		if(WT.remove_fuel(0, user))
			user.visible_message("<span class='notice'>[user] begins repairing [src].</span>",
			"<span class='notice'>You begin repairing [src].</span>")
			if(do_after(user, 50, TRUE, 5, BUSY_ICON_CLOCK))
				user.visible_message("<span class='notice'>[user] repairs [src].</span>",
				"<span class='notice'>You repair [src].</span>")
				update_health(-50)
				playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)
		return

	if(istype(O, /obj/item/weapon/cell))
		user << "You begin the new power cell installation.."
		if(do_after(user, 30, TRUE, 5, BUSY_ICON_CLOCK))
			user.drop_inv_item_to_loc(O, src)
			if(cell)
				user.visible_message("<span class='notice'>[user] swaps out [src]'s power cell.</span>",
				"<span class='notice'>You swap out [src]'s power cell.</span>")
				cell.forceMove(loc)
				cell = O
			else
				user.visible_message("<span class='notice'>[user] installs a new power cell into [src].</span>",
				"<span class='notice'>You install a new power cell into [src].</span>")
				cell = O
		return
	if(istype(O, /obj/item/sentry_ammo))
		if(rounds)
			user << "<span class='warning'>You can only swap the box magazine when it's empty.</span>"
			return
		user.visible_message("<span class='notice'>[user] begins fitting a new box magazine into [src].</span>",
		"<span class='notice'>You begin fitting a new box magazine into [src].</span>")
		if(do_after(user, 70, TRUE, 5, BUSY_ICON_CLOCK))
			playsound(src.loc, 'sound/weapons/unload.ogg', 25, 1)
			user.visible_message("<span class='notice'>[user] fits a new box magazine into [src].</span>",
			"<span class='notice'>You fit a new box magazine into [src].</span>")
			user.drop_held_item()
			rounds = rounds_max
			cdel(O)
		return

	if(O.force)
		update_health(O.force/2)
	return ..()

/obj/machinery/marine_turret/update_icon()
	if(stat && health > 0) //Knocked over
		icon_state = "turret-fallen"
	else
		if(on)
			icon_state = "turret-1"
		else
			icon_state = "turret-0"

/obj/machinery/marine_turret/proc/update_health(var/damage) //Negative damage restores health.
	health -= damage
	if(health <= 0 && stat != 2)
		stat = 2
		visible_message("\icon[src] <span class='warning'>The [name] starts spitting out sparks and smoke!")
		playsound(loc, 'sound/mecha/critdestrsyndi.ogg', 25, 1)
		for(var/i = 1 to 6)
			dir = pick(1, 2, 3, 4)
			sleep(2)
		spawn(10)
			if(src && loc)
				explosion(loc, -1, -1, 2, 0)
				new /obj/machinery/marine_turret_frame(loc)
				if(src)
					cdel(src)
		return

	if(health > health_max)
		health = health_max
	if(!stat && damage > 0 && !immobile)
		if(prob(10))
			spark_system.start()
		if(prob(5 + round(damage/5)))
			visible_message("\icon[src] <span class='danger'>The [name] is knocked over!</span>")
			stat = 1
			on = 0
	if(stat)
		density = 0
	else
		density = initial(density)
	update_icon()

/obj/machinery/marine_turret/proc/check_power(var/power)
	if(!cell || !on || stat)
		on = 0
		return 0

	if(cell.charge - power <= 0)
		cell.charge = 0
		visible_message("\icon[src] <span class='warning'>[src] emits a low power warning and immediately shuts down!</span>")
		playsound(loc, 'sound/weapons/smg_empty_alarm.ogg', 25, 1)
		on = 0
		update_icon()
		SetLuminosity(0)
		return 0

	cell.charge -= power
	return 1

/obj/machinery/marine_turret/emp_act(severity)
	if(cell)
		check_power(-(rand(100,500)))
	if(on)
		if(prob(50))
			visible_message("\icon[src] <span class='danger'>[src] beeps and buzzes wildly, flashing odd symbols on its screen before shutting down!</span>")
			playsound(loc, 'sound/mecha/critdestrsyndi.ogg', 25, 1)
			for(var/i = 1 to 6)
				dir = pick(1, 2, 3, 4)
				sleep(2)
			on = 0
	if(health > 0)
		update_health(25)
	return

/obj/machinery/marine_turret/ex_act(severity)
	if(health <= 0)
		return
	switch(severity)
		if(1)
			update_health(rand(90, 150))
			return
		if(2)
			update_health(rand(50, 150))
			return
		if(3)
			update_health(rand(30, 100))
			return
	return

/obj/machinery/marine_turret/attack_alien(mob/living/carbon/Xenomorph/M)
	if(isXenoLarva(M)) return //Larvae can't do shit
	M.visible_message("<span class='danger'>[M] has slashed [src]!</span>",
	"<span class='danger'>You slash [src]!</span>")
	playsound(loc, 'sound/weapons/slice.ogg', 25, 1)
	if(prob(10))
		if(!locate(/obj/effect/decal/cleanable/blood/oil) in loc)
			new /obj/effect/decal/cleanable/blood/oil(loc)
	update_health(rand(M.melee_damage_lower,M.melee_damage_upper))

/obj/machinery/marine_turret/bullet_act(var/obj/item/projectile/Proj) //Nope.
	if(prob(30))
		return 0

	visible_message("[src] is hit by the [Proj.name]!")

	if(Proj.ammo.flags_ammo_behavior & AMMO_XENO_ACID) //Fix for xenomorph spit doing baby damage.
		update_health(round(Proj.damage/3))
	else
		update_health(round(Proj.damage/10))
	return 1

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
		return

	manual_override = 0
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

	if(isnull(target)) return //Acqure our victim.

	if(!ammo) return

	if(burst_fire && target && !last_fired)
		if(rounds > 3)
			for(var/i = 1 to 3)
				is_bursting = 1
				fire_shot()
				sleep(2)
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

	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	var/scatter_chance = 5
	if(burst_fire) scatter_chance = 20

	if(prob(scatter_chance))
		U = locate(U.x + rand(-1, 1), U.y + rand(-1, 1), U.z)

	if(!istype(T) || !istype(U))
		return

	if(!check_power(2)) return
	if(!dir_locked)
		var/dx = U.x - x
		var/dy = U.y - y //Calculate which way we are relative to them. Should be 90 degree cone..

		if(abs(dx) < abs(dy))
			if(dy > 0)	dir = NORTH
			else		dir = SOUTH
		else
			if(dx > 0)	dir = EAST
			else		dir = WEST

	if(load_into_chamber() == 1)
		if(istype(in_chamber,/obj/item/projectile))
			in_chamber.original = target
			in_chamber.dir = dir
			in_chamber.def_zone = pick("chest", "chest", "chest", "head")
			playsound(loc, 'sound/weapons/gun_rifle.ogg', 75, 1)
			in_chamber.fire_at(U,src,null,ammo.max_range,ammo.shell_speed)
			if(target)
				var/angle = round(Get_Angle(src,target))
				muzzle_flash(angle)
			in_chamber = null
			rounds--
			if(rounds == 0)
				visible_message("\icon[src] <span class='warning'>The [name] beeps steadily and its ammo light blinks red.</span>")
				playsound(loc, 'sound/weapons/smg_empty_alarm.ogg', 25, 1)
	return

//Mostly taken from gun code.
/obj/machinery/marine_turret/proc/muzzle_flash(var/angle)
	if(isnull(angle)) return

	if(prob(65))
		var/layer = MOB_LAYER - 0.1

		var/image/reusable/I = rnew(/image/reusable, list('icons/obj/projectiles.dmi',src,"muzzle_flash",layer))
		var/matrix/rotate = matrix() //Change the flash angle.
		rotate.Translate(0, 5)
		rotate.Turn(angle)
		I.transform = rotate

		I.flick_overlay(src, 3)

/obj/machinery/marine_turret/proc/get_target()
	var/list/targets = list()
	var/range = 7

	if(!dir_locked)
		range = 3

	var/list/turf/path = list()
	var/turf/T
	var/mob/M

	for(M in oview(range,src))
		if(!isliving(M) || M.stat || isrobot(M)) continue //No unconscious/deads, or non living.

		/*
		I really, really need to replace this with some that isn't insane. You shouldn't have to fish for access like this.
		This should be enough shortcircuiting, but it is possible for the code to go all over the possibilities and generally
		slow down. It'll serve for now.
		*/
		var/mob/living/carbon/human/H = M
		if(istype(H) && H.get_target_lock(iff_signal)) continue

		if(dir_locked) //We're dir locked and facing the right way.
			var/angle = get_dir(src,M)
			if(dir == NORTH && (angle == NORTHEAST || angle == NORTHWEST)) //There's probably an easier way to do this. MEH
				angle = NORTH
			if(dir == SOUTH && (angle == SOUTHEAST || angle == SOUTHWEST))
				angle = SOUTH
			if(dir == EAST && (angle == NORTHEAST || angle == SOUTHEAST))
				angle = EAST
			if(dir == WEST && (angle == NORTHWEST || angle == SOUTHWEST))
				angle = WEST

			if(angle == dir) path = getline2(src,M)

		else path = getline2(src,M) //Otherwise grab everyone around us.

		if(path.len)
			for(T in path)
				if(T.density) continue
			targets += M

	if(targets.len) . = pick(targets)

//direct replacement to new proc. Everything works.
/obj/machinery/marine_turret/handle_click(var/mob/living/carbon/human/user, var/atom/A, var/params)
	if(!operator || !istype(user)) return 0
	if(operator != user) return 0
	if(istype(A, /obj/screen)) return 0
	if(!manual_override) return 0
	if(operator.machine != src) return 0
	if(is_bursting) return
	if(get_dist(user, src) > 1 || user.stat)
		user.visible_message("<span class='notice'>[usr] lets go of [src]</span>",
		"<span class='notice'>You let go of [src]</span>")
		visible_message("\icon[src] <span class='notice'>The [name] buzzes: AI targeting re-initialized.</span>")
		manual_override = 0
		user.machine = null
		operator = null
		return 0
	if(user.get_active_hand() != null)
		usr << "<span class='warning'>You need a free hand to shoot [src].</span>"
		return 0

	target = A
	if(!istype(target))
		return 0

	if(target.z != z || target.z == 0 || z == 0 || isnull(operator.loc) || isnull(loc))
		return 0

	if(get_dist(target, loc) > 10)
		return 0

	var/list/modifiers = params2list(params) //Only single clicks.
	if(modifiers["middle"] || modifiers["shift"] || modifiers["alt"] || modifiers["ctrl"])	return 0

	if(!dir_locked)
		user << "<span class='warning'>[src] can only be fired manually in direction-locked mode.</span>"
		return 0

	var/dx = target.x - x
	var/dy = target.y - y //Calculate which way we are relative to them. Should be 90 degree cone..
	var/direct

	if(abs(dx) < abs(dy))
		if(dy > 0)	direct = NORTH
		else		direct = SOUTH
	else
		if(dx > 0)	direct = EAST
		else		direct = WEST

	if(direct == dir && target.loc != src.loc && target.loc != operator.loc)
		process_shot()
		return 1

	return 0
/*
/obj/item/turret_laptop
	name = "UA 571-C Turret Control Laptop"
	desc = "A small device used for remotely controlling sentry turrets."
	w_class = 4
	icon = 'icons/obj/computer.dmi'
	icon_state = "turret_off"
	unacidable = 1
	var/linked_turret = null
	var/on = 0
	var/mob/living/carbon/human/user = null
	var/obj/machinery/camera/current = null

	check_eye(var/mob/user as mob)
		if (user.z == 0 || user.stat || ((get_dist(user, src) > 1 || user.blinded) && !istype(user, /mob/living/silicon))) //user can't see - not sure why canmove is here.
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
	immobile = 1
	on = 1
	burst_fire = 1
	rounds = 900
	rounds_max = 900
	icon_state = "turret-1"

	New()
		spark_system = new /datum/effect_system/spark_spread
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		var/obj/item/weapon/cell/super/H = new(src) //Better cells in these ones.
		cell = H
		camera = new (src)
		camera.network = list("military")
		camera.c_tag = "[src.name] ([rand(0,1000)])"
		spawn(2)
			stat = 0
			processing_objects.Add(src)
		ammo = ammo_list[ammo]

/obj/machinery/marine_turret/premade/dumb
	name = "Modified UA-577 Gauss Turret"
	iff_signal = 0
	ammo = /datum/ammo/bullet/turret/dumb

//the turret inside the sentry deployment system
/obj/machinery/marine_turret/premade/dropship
	density = 0
	var/obj/structure/dropship_equipment/sentry_holder/deployment_system

	Dispose()
		if(deployment_system)
			deployment_system.deployed_turret = null
			deployment_system = null
		. = ..()
