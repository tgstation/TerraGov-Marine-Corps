//Deployable turrets. They can be either automated, manually fired, or installed with a pAI.
//They are built in stages, and only engineers have access to them.

/obj/item/sentry_ammo
	name = "M30 box magazine"
	desc = "A box of 300 armor-piercing rounds for the UA 571-C Sentry Gun. Just click the sentry with this to reload it."
	w_class = 4
	icon = 'icons/obj/ammo.dmi'
	icon_state = "a762"

/obj/item/weapon/storage/box/sentry
	name = "UA 571-C Sentry Crate"
	desc = "A large case containing all you need to set up an automated sentry, minus the tools."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sentry_case"
	w_class = 5
	storage_slots = 6
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.

	New()
		..()
		spawn(1)
			var/obj/item/stack/sheet/plasteel/P = new(src)
			P.amount = 20
			var/obj/item/stack/sheet/metal/Q = new(src)
			Q.amount = 10
			new /obj/item/device/turret_top(src)
			new /obj/item/device/turret_sensor(src)
			new /obj/item/weapon/cell(src)
			new /obj/item/sentry_ammo(src)

/obj/machinery/marine_turret_frame
	name = "UA 571-C Turret Frame"
	desc = "Half of an automated sentry turret. It requires wrenching, cable coil, a turret piece, a sensor, and metal plating."
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
			usr << "It must be <B>wrenched</b> to the floor."
		if(!has_cable)
			usr << "It requires <b>cable coil</b> for wiring."
		if(!has_top)
			usr << "The <b>main turret</b> is not installed."
		if(!has_sensor)
			usr << "It does not have a <b>turret sensor</b> installed."
		if(!has_plates)
			usr << "It does not have <B>metal</b> plating installed and welded."

	attackby(var/obj/item/O as obj, mob/user as mob)
		if(!ishuman(user))
			return
		if(isnull(O))
			return

		if(istype(O,/obj/item/weapon/wrench))
			if(anchored)
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				user.visible_message("[user] rotates the [src].","You rotate the [src].")
				if(dir == NORTH)
					dir = EAST
				else if(dir == EAST)
					dir = SOUTH
				else if(dir == SOUTH)
					dir = WEST
				else if(dir == WEST)
					dir = NORTH
			else
				if(locate(/obj/machinery/marine_turret) in src.loc)
					user << "There's already a turret here. Drag the frame off first."
					return

				user << "You begin wrenching [src] into place.."
				if(do_after(user,40))
					playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
					user.visible_message("\blue [user] anchors [src] into place.","\blue You anchor [src] into place.")
					anchored = 1
			return
		if(istype(O,/obj/item/stack/cable_coil))
			if(!anchored)
				user << "It must be anchored to the floor first."
				return

			var/obj/item/stack/cable_coil/CC = O
			if(has_cable)
				user << "There is already wiring installed on the [src]."
				return
			user << "You begin installing the wiring.."
			if(do_after(user,40))
				if (CC.use(10))
					has_cable = 1
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					user.visible_message("\blue [user] installs wiring in the [src].","\blue You install the wiring in the [src].")
					icon_state = "turret-bottom"
					return
				else
					user << "<span class='notice'>Not enough cable!</span>"

		if(istype(O,/obj/item/device/turret_top))
			if(!has_cable)
				user << "It must have wiring installed first."
				return
			if(has_top)
				user << "The top section is already installed!"
				return
			user << "You begin installing the turret gun section.."
			if(do_after(user,60))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				user.visible_message("\blue [user] installs [O] into place.","\blue You install [O] into place.")
				has_top = 1
				icon_state = "turret-nosensor"
				user.drop_from_inventory(O)
				del(O)
				return

		if(istype(O,/obj/item/device/turret_sensor))
			if(!has_top)
				user << "The gun section must be installed first!"
				return
			if(has_sensor)
				user << "It already has a sensor!"
				return
			user << "You begin installing the [O].."
			if(do_after(user,40))
				has_sensor = 1
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
				user.visible_message("\blue [user] installs the control sensor on the [src].","\blue You install the control sensor.")
				icon_state = "turret-0"
				user.drop_from_inventory(O)
				del(O)
				return

		if(istype(O,/obj/item/stack/sheet/metal))
			var/obj/item/stack/sheet/metal/M = O
			if(!has_sensor)
				user << "It needs the sensor installed first!"
				return
			if(has_plates)
				user << "It already has plating installed. Just weld it together."
				return
			if(M.amount < 10)
				user << "You require at least 10 sheets of metal to reinforce the plating. You have only [M.amount]."
				return
			user << "You begin installing the reinforced plating.."
			if(do_after(user,50))
				if(M.amount >= 10)
					has_plates = 1
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					user.visible_message("\blue [user] installs the plating on the [src].","\blue You install the plating.")
					M.amount -= 10
					if(M.amount <= 0)
						user.drop_from_inventory(M)
						del(M)
					return
				else
					user << "You need more metal!"
					return
		if(istype(O, /obj/item/weapon/weldingtool))
			if(!has_plates)
				user << "You need to install the metal plates first."
				return
			var/obj/item/weapon/weldingtool/WT = O
			user << "You begin welding the parts together.."
			if(do_after(user,60))
				if(!src || !WT || !WT.isOn()) return
				if(WT.remove_fuel(0, user))
					playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
					user.visible_message("\blue [user.name] welds [src.name] together!","\blue You complete the [src]!")
					var/obj/machinery/marine_turret/T = new(src.loc)  //Bing! Create a new turret.
					T.visible_message("\icon[T] <B>[T] is now complete!</B>")
					T.dir = src.dir
					del(src)
					return
				else
					user << "\red You need more welding fuel to complete this task."
					return

		return ..() //Just do normal stuff.

/obj/item/device/turret_sensor
	name = "UA 571-C Turret Sensor"
	desc = "An AI control and locking sensor for an automated sentry. This must be installed on the final product for it to work."
	unacidable = 1
	w_class = 1
	icon = 'icons/Marine/turret.dmi'
	icon_state = "turret-sensor"

/obj/item/device/turret_top
	name = "UA 571-C Turret"
	desc = "The top half of an automated sentry turret. This must be installed on a turret frame for it to do anything."
	unacidable = 1
	w_class = 5
	icon = 'icons/Marine/turret.dmi'
	icon_state = "turret-top"

/obj/machinery/marine_turret
	name = "UA 571-C Sentry Gun"
	desc = "A deployable, semi-automated turret with AI targeting capabilities. Armed with an M30 Autocannon and a 300-round drum magazine."
	icon = 'icons/Marine/turret.dmi'
	icon_state = "turret-0"
	anchored = 1
	unacidable = 1
	density = 1
	layer = 3.5
	use_power = 0
	req_one_access = list(access_sulaco_engineering,access_marine_leader)
	var/dir_locked = 1
	var/safety_off = 0
	var/rounds = 300
	var/rounds_max = 300
	var/locked = 0
	var/atom/target = null
	var/mob/living/carbon/human/operator = null
	var/mob/living/carbon/human/gunner = null
	var/mob/living/silicon/pai = null //Are we being controlled by a pAI?
	var/manual_override = 0
	var/on = 0
	var/health = 200
	var/health_max = 200
	stat = 0 //Used just like mob.stat
	var/datum/effect/effect/system/spark_spread/spark_system // the spark system, used for generating... sparks?
	var/obj/item/weapon/cell/cell = null
	var/burst_fire = 0
	var/obj/machinery/camera/camera = null
	var/fire_delay = 6
	var/last_fired = 0
	var/is_bursting = 0
	var/obj/item/turret_laptop/laptop = null
	var/immobile = 0 //Used for prebuilt ones.
	var/datum/ammo/bullet/turret/ammo //Pre-makes the bullet data.
	var/obj/item/projectile/in_chamber = null

	New()
		spark_system = new /datum/effect/effect/system/spark_spread
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		cell = new (src)
		camera = new (src)
		camera.network = list("SULACO")
		camera.c_tag = "[src.name] ([rand(0,1000)])"
		spawn(2)
			stat = 0
			processing_objects.Add(src)
		ammo = new /datum/ammo/bullet/turret()

	Del() //Clear these for safety's sake.
		if(gunner && gunner.turret_control)
			gunner.turret_control = null
			gunner = null
		if(camera)
			del(camera)
		if(cell)
			del(cell)
		if(target)
			target = null
		if(operator)
			operator = null
		if(pai)
			pai = null
		SetLuminosity(0)
		processing_objects.Remove(src)
		..()

/obj/machinery/marine_turret/attack_hand(mob/user as mob)
	if(isYautja(user))
		user << "Some human machinery. You punch it but nothing happens."
		return
	src.add_fingerprint(user)

	if(!cell || cell.charge <= 0)
		user << "Nothing happens. It doesn't look like it's functioning - probably needs a new battery."
		return

	if(!anchored)
		user << "It must be anchored to the ground before you can use it."
		return

	if(immobile)
		user << "The panel on this one is permanently locked."
		return

	if(!on && !stat)
		user << "You turn on the [src]."
		visible_message("\blue [src] hums to life and emits several beeps.")
		visible_message("\icon[src] [src] buzzes in a monotone: 'Default systems initiated.'")
		dir_locked = 1
		target = null
		operator = null
		pai = null
		on = 1
		SetLuminosity(7)
		if(!camera)
			camera = new /obj/machinery/camera(src)
			camera.network = list("SULACO")
			camera.c_tag = src.name
		update_icon()
		return

	if(stat)
		user.visible_message("[user] begins to right the [src].","You begin to put the [src] upright..")
		if(do_after(user,20))
			user.visible_message("[user] rights the [src].","You put the [src] upright.")
			stat = 0
			update_icon()
			update_health()
		return

	if(locked)
		user << "\red The control panel is locked! It requires a squad leader or engineer ID to unlock."
		return


	operator = user

	var/dat = "<b>[src.name]:</b> <BR><BR>"
	dat += "--------------------<BR><BR>"
	dat += "<B>Current Rounds:</b> [rounds] / [rounds_max]<BR>"
	dat += "<B>Structural Integrity:</b> [round(health * 100 / health_max)] percent <BR>"
	if(cell)
		dat += "<B>Power Cell:</b> [cell.charge] / [cell.maxcharge]<BR>"
	dat += "<B><A href='?src=\ref[src];op=power'>Power Down</a></B><br>"
	dat += "--------------------<BR><BR>"
	dat += "<B><A href='?src=\ref[src];op=direction'>Direction Cycle Lock</a>:</B> "
	if(dir_locked)
		switch(dir)
			if(NORTH)
				dat += "NORTH (conical)<BR>"
			if(EAST)
				dat += "EAST (conical)<BR>"
			if(SOUTH)
				dat += "SOUTH (conical)<BR>"
			if(WEST)
				dat += "WEST (conical)<BR>"
	else
		dat += "360 Degree Rotation<br>"


	dat += "<B><A href='?src=\ref[src];op=burst'>Burst Fire</a>:</B> "
	if(burst_fire)
		dat += "ON<BR>"
	else
		dat += "OFF<BR>	"

	dat += "<B><A href='?src=\ref[src];op=safety'>Safety Toggle</a>:</B> "
	if(safety_off)
		dat += "<font color='red'>OFF</font><BR><BR>"
	else
		dat += "ON<BR><BR>"

	dat += "--------------------<BR><BR>"
	dat += "<B>AI Logic:</B> "
	if(manual_override)
		dat += "MANUAL OVERRIDE<BR>"
	else
		dat += "ON<BR>"

	dat += "<A href='?src=\ref[src];op=manual'>Manual Override Toggle</a><BR><BR>"
	dat += "--------------------<BR><BR>"
	dat += "<A href='?src=\ref[src];op=close'>{Close}</a><BR>"
	user.set_machine(src)
	user << browse(dat, "window=turret;size=300x400")
	onclose(user, "turret")
	return

/obj/machinery/marine_turret/Topic(href, href_list)
	if(usr.stat)
		return

	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return

	usr.set_machine(src)
	switch(href_list["op"])
		if("direction")
			if(alert(usr,"Do you want to turn on the direction lock? This will keep the turret aimed where it's facing.","Direction Lock", "Yes", "No") == "Yes")
				if(dir_locked)
					usr << "It's already direction locked."
				else
					dir_locked = 1
					visible_message("\icon[src] The [src]'s turret stops rotating.")
					usr << "\blue You activate the direction lock."
			else
				if(!dir_locked)
					usr << "It's already on 360 degree rotation."
				else
					dir_locked = 0
					visible_message("\icon[src] The [src]'s turret begins turning side to side.")
					usr << "\blue You deactivate the direction lock."
		if("burst")
			if(alert(usr,"Do you want to turn on the burst fire function? It will be much less accurate.","Burst Fire", "Yes", "No") == "Yes")
				if(burst_fire)
					usr << "It's already firing in a burst."
				else
					burst_fire = 1
					visible_message("\icon[src] A green light on [src] blinks rapidly.")
					usr << "\blue You activate the burst fire mode."
			else
				if(!burst_fire)
					usr << "It's already firing single shots."
				else
					burst_fire = 0
					visible_message("\icon[src] A green light on [src] blinks slowly.")
					usr << "\blue You deactivate the burst fire mode."
		if("safety")
			if(alert(usr,"Do you want to turn on the safety lock? It will not stop firing when a friendly is in the way.","Safety", "Yes", "No") == "Yes")
				if(!safety_off)
					usr << "It's already safety locked."
				else
					safety_off = 0
					visible_message("\icon[src] A red light on [src] blinks rapidly.")
					usr << "\blue You activate the safety lock."
			else
				if(safety_off)
					usr << "It's already not safety locked."
				else
					safety_off = 1
					visible_message("\icon[src] A red light on [src] blinks brightly!")
					usr << "\blue You deactivate the safety lock. Careful now!"
		if("manual")
			if(!dir_locked)
				usr << "The turret can only be fired manually in direction-locked mode."
			else
				if(alert(usr,"Are you sure you want to take manual control over the sentry?","MANUAL OVERRIDE", "Yes", "No") == "Yes")
					if(gunner)
						usr << "Someone's already controlling it."
					else
						if(user.turret_control)
							usr << "You're already controlling one!"
						else
							gunner = usr
							visible_message("\icon[src] \red[src] buzzes: <B>WARNING!</b> MANUAL OVERRIDE INITIATED.")
							usr << "\blue You take manual control of the turret."
							user.turret_control = src
							manual_override = 1
				else
					if(user.turret_control)
						gunner = null
						visible_message("\icon[src] \blue[src] buzzes: AI targeting re-initialized.")
						usr << "\blue You let the AI take over."
						user.turret_control = null
						manual_override = 0
					else
						user << "You're not controlling this turret."
			if(stat == 2)
				stat = 0 //Weird bug goin on here
		if("power")
			on = 0
			visible_message("\icon[src] [src] powers down and goes silent.")
			user << "You switch off the turret."
			update_icon()
			return

	src.attack_hand(user)
	return

/obj/machinery/marine_turret/attackby(var/obj/item/O as obj, mob/user as mob)
	if(!ishuman(user))
		return ..()

	if(isnull(O)) return

	if(istype(O,/obj/item/weapon/card/id))
		if (src.allowed(user))
			locked = !locked
			user << "<span class='notice'>You [ locked ? "lock" : "unlock"] the panel.</span>"
			if (locked)
				if (user.machine==src)
					user.unset_machine()
					user << browse(null, "window=turret")
			else
				if (user.machine==src)
					src.attack_hand(user)
		else
			user << "<span class='warning'>Access denied.</span>"
		return
	if(istype(O,/obj/item/weapon/wrench))
		if(immobile)
			user << "This one is anchored in place and cannot be moved."
			return
		if(on)
			user << "You can't rotate the sentry when it's turned on. Way too dangerous!"
			return
		else
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			user.visible_message("[user] rotates the [src].","You rotate the [src].")
			if(dir == NORTH)
				dir = EAST
			else if(dir == EAST)
				dir = SOUTH
			else if(dir == SOUTH)
				dir = WEST
			else if(dir == WEST)
				dir = NORTH
		return

	if(istype(O, /obj/item/weapon/screwdriver))
		if(immobile)
			user << "This one is anchored in place and cannot be moved."
			return

		if(!anchored)
			if(src.loc) //Just to be safe.
				user << "You begin securing the [src] to the floor."
				if(do_after(user,40))
					user.visible_message("\blue [user] secures [src] to the floor!","\blue You secure [src] to the floor!")
					anchored = 1
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 75, 1)
			return
		else
			if(on)
				user << "Turn it off first."
				return
			else
				user << "You begin unscrewing the anchoring bolts.."
				if(do_after(user,40))
					user.visible_message("\blue [user] unsecures [src] from the floor!","\blue You unsecure [src] from the floor!")
					anchored = 0
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 75, 1)
		return

	if(istype(O, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = O
		if(health < 0 || stat)
			user << "It's too damaged for that. Better just to build a new one."
			return

		if(health >= health_max)
			user << "It's already in perfect condition."
			return

		if(WT.remove_fuel(0, user))
			user.visible_message("\blue [user] begins repairing damage to the [src].","\blue You begin repairing the damage to the [src].")
			if(do_after(user,50))
				user.visible_message("\blue [user] repairs the damaged [src].","\blue Your repair the [src]'s damage.")
				update_health(-50)
				playsound(src.loc, 'sound/items/Welder2.ogg', 75, 1)
		return

	if(istype(O,/obj/item/weapon/cell))
		user << "You begin the new power cell installation.."
		if(do_after(user,30))
			if(cell)
				user.visible_message("[user] swaps out the power cells in the [src].","You swap out the power cells.")
				user.drop_from_inventory(O)
				cell.loc = src.loc
				user.put_in_active_hand(cell)
				user.drop_from_inventory(cell) //Put it on the ground.
				cell = O
				O.loc = src
			else
				user.visible_message("[user] installs a new power cell in [src].","You install the new cell.")
				user.drop_from_inventory(O)
				cell = O
				O.loc = src
		return
	if(istype(O,/obj/item/sentry_ammo))
		if(rounds)
			user << "It can only be reloaded when empty."
			return
		user.visible_message("[user] begins fitting a new box magazine into the sentry turret.","You begin reloading..")
		if(do_after(user,70))
			playsound(src.loc, 'sound/weapons/unload.ogg', 60, 1)
			user.visible_message("\blue [user] reloads the [src].","\blue You reload the [src].")
			user.drop_from_inventory(O)
			rounds = rounds_max
			del(O)
		return

	if(O.force)
		update_health(O.force / 2)
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
		visible_message("\icon[src] <span class='warning'>The [src] starts spitting out sparks and smoke!")
		playsound(src.loc, 'sound/mecha/critdestrsyndi.ogg', 100, 1)
		for(var/i = 1 to 6)
			dir = pick(1,2,3,4)
			sleep(2)
		spawn(10)
			if(src && src.loc)
				explosion(src.loc,-1,-1,2,0)
				new /obj/machinery/marine_turret_frame(src.loc)
				if(src)
					del(src)
		return

	if(health > health_max)
		health = health_max
	if(!stat && damage > 0 && !immobile)
		if(prob(10))
			spark_system.start()
		if(prob(5 + round(damage / 5)))
			visible_message("\red <B>The [src] is knocked over!</B>")
			stat = 1
			on = 0
	if(stat)
		density = 0
	else
		density = 1
	update_icon()

/obj/machinery/marine_turret/proc/check_power(var/power)
	if(!cell || !on || stat)
		on = 0
		return 0

	if(cell.charge - power <= 0)
		cell.charge = 0
		visible_message("\icon[src] [src] shuts down from lack of power!")
		playsound(src.loc, 'sound/weapons/smg_empty_alarm.ogg', 60, 1)
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
			visible_message("\icon[src] [src] beeps wildly and shuts off!")
			on = 0
	if(health > 0)
		update_health(25)
	return

/obj/machinery/marine_turret/ex_act(severity)
	if(health <= 0)
		return
	switch(severity)
		if(1)
			update_health(rand(90,150))
			return
		if(2)
			update_health(rand(50,150))
			return
		if(3)
			update_health(rand(30,100))
			return
	return

/obj/machinery/marine_turret/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if(isXenoLarva(M)) return //Larvae can't do shit
	src.visible_message("\red <B>[M] has slashed [src]!</B>")
	playsound(src.loc, 'sound/weapons/slice.ogg', 25, 1, -1)
	if(prob(10))
		if(!locate(/obj/effect/decal/cleanable/blood/oil) in src.loc)
			new /obj/effect/decal/cleanable/blood/oil(src.loc)
	update_health(rand(M.melee_damage_lower,M.melee_damage_upper))

/obj/machinery/marine_turret/bullet_act(var/obj/item/projectile/Proj) //Nope.
	if(prob(30))
		return 0

	visible_message("\The [src] is hit by the [Proj.name]!")
	update_health(round(Proj.damage / 10))
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

	if(gunner || manual_override) //If someone's firing it manually.
		return

	if(rounds == 0)
		return

	manual_override = 0
	target = get_target()
	process_shot()
	return

/obj/machinery/marine_turret/proc/load_into_chamber()
	if(!ammo) return 0 //Our ammo datum is missing. We need one, and it should have set when we reloaded, so, abort.

	if(in_chamber) return 1 //Already set!
	if(!on || !cell || rounds == 0 || stat == 1) return 0

	var/obj/item/projectile/P = new(src.loc) //New bullet!
	P.ammo = ammo //Share the ammo type. This does all the heavy lifting.
	P.name = P.ammo.name
	P.icon_state = P.ammo.icon_state //Make it look fancy.
	P.damage = P.ammo.damage //For reverse lookups.
	P.damage_type = P.damage_type
	in_chamber = P
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
		U = locate(U.x + rand(-1,1),U.y + rand(-1,1),U.z)

	if (!istype(T) || !istype(U))
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
		if(istype(in_chamber,/obj/item/projectile) && in_chamber.ammo == ammo)
			in_chamber.original = target
			in_chamber.dir = src.dir
			in_chamber.def_zone = pick("chest","chest","chest","head")
			playsound(src.loc, 'sound/weapons/gunshot_rifle.ogg', 100, 1)
			in_chamber.fire_at(U,src,null,ammo.max_range,ammo.shell_speed)
			in_chamber = null
			rounds--
			if(rounds == 0)
				visible_message("\icon[src] \red The turret beeps steadily and its ammo light blinks red.")
				playsound(src.loc, 'sound/weapons/smg_empty_alarm.ogg', 50, 1)
	return

/obj/machinery/marine_turret/proc/get_target()
	var/list/targets = list()
	var/range = 9

	if(!dir_locked)
		range = 3

	var/list/turf/path = list()
	var/turf/T
	var/blocked = 0

	for(var/mob/living/carbon/C in oview(range,src))
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(!isnull(H.wear_id) && !isYautja(C))//Just do a blanket ID check for now..
				continue
			if(istype(H.get_active_hand(),/obj/item/weapon/card))
				continue

		if(C.stat) continue //No unconscious/deads.

		if(dir_locked) //We're dir locked and facing the right way.
			var/angle = get_dir(src,C)
			if(dir == NORTH && (angle == NORTHEAST || angle == NORTHWEST)) //There's probably an easier way to do this. MEH
				angle = NORTH
			if(dir == SOUTH && (angle == SOUTHEAST || angle == SOUTHWEST))
				angle = SOUTH
			if(dir == EAST && (angle == NORTHEAST || angle == SOUTHEAST))
				angle = EAST
			if(dir == WEST && (angle == NORTHWEST || angle == SOUTHWEST))
				angle = WEST

			if(angle == dir)
				path = getline2(src,C)
				blocked = 0
				for(T in path)
					if(T.density) //Simple density check on turfs in the firing path.
						blocked = 1
				if(blocked == 0)
					targets += C
		else  //Otherwise grab everyone around us.
			path = getline2(src,C)
			blocked = 0
			for(T in path)
				if(T.density)
					blocked = 1
			if(blocked == 0)
				targets += C

	if(targets.len)
		var/mob/P = pick(targets)
		if(P)
			return P

	return null

/obj/machinery/marine_turret/proc/handle_manual_fire(var/mob/living/carbon/human/user, var/atom/A, var/params)
	if(!gunner || !istype(user)) return 0
	if(gunner != user) return 0
	if(istype(A,/obj/screen)) return 0
	if(!manual_override) return 0
	if(gunner.turret_control != src) return 0
	if(is_bursting) return
	if(get_dist(user,src) > 1 || user.stat)
		user.turret_control = null
		gunner = null
		return 0

	target = A
	if(!istype(target))
		return 0

	if(target.z != src.z || target.z == 0 || src.z == 0 || isnull(gunner.loc) || isnull(src.loc))
		return 0

	if(get_dist(target,src.loc) > 10)
		return 0

	var/list/modifiers = params2list(params) //Only single clicks.
	if(modifiers["middle"] || modifiers["shift"] || modifiers["alt"] || modifiers["ctrl"])	return 0

	if(!dir_locked)
		user << "The turret can only be fired manually in direction-locked mode."
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

	if(direct == dir && target.loc != src.loc && target.loc != gunner.loc)
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
		spark_system = new /datum/effect/effect/system/spark_spread
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		var/obj/item/weapon/cell/super/H = new(src) //Better cells in these ones.
		cell = H
		camera = new (src)
		camera.network = list("SULACO")
		camera.c_tag = "[src.name] ([rand(0,1000)])"
		spawn(2)
			stat = 0
			processing_objects.Add(src)
		ammo = new /datum/ammo/bullet/turret()
