/*
All of the hardpoints, for the tank or other
Currently only has the tank hardpoints
*/

/obj/item/hardpoint

	var/slot //What slot do we attach to?
	var/obj/vehicle/multitile/root/cm_armored/owner //Who do we work for?

	icon = 'icons/obj/vehicles/hardpoint_modules.dmi'
	icon_state = "tires" //Placeholder

	max_integrity = 100
	w_class = WEIGHT_CLASS_GIGANTIC

	var/obj/item/ammo_magazine/tank/ammo
	//If we use ammo, put it here
	var/obj/item/ammo_magazine/tank/starter_ammo

	//Strings, used to get the overlay for the armored vic
	var/disp_icon //This also differentiates tank vs apc vs other
	var/disp_icon_state

	var/next_use = 0
	var/is_activatable = FALSE
	var/max_angle = 180
	var/point_cost = 0

	var/list/backup_clips = list()
	var/max_clips = 1 //1 so they can reload their backups and actually reload once
	var/buyable = TRUE

/obj/item/hardpoint/Initialize(mapload)
	. = ..()
	if(starter_ammo)
		ammo = new starter_ammo

/obj/item/hardpoint/examine(mob/user)
	. = ..()
	var/status = obj_integrity <= 0.1 ? "broken" : "functional"
	var/span_class = obj_integrity <= 0.1 ? "<span class = 'danger'>" : "<span class = 'notice'>"
	if((user.skills.getRating(SKILL_ENGINEER) >= SKILL_ENGINEER_METAL) || isobserver(user))
		switch(PERCENT(obj_integrity / max_integrity))
			if(0.1 to 33)
				status = "heavily damaged"
				span_class = "<span class = 'warning'>"
			if(33.1 to 66)
				status = "damaged"
				span_class = "<span class = 'warning'>"
			if(66.1 to 90)
				status = "slighty damaged"
			if(90.1 to 100)
				status = "intact"
	to_chat(user, "[span_class]It's [status].</span>")

/obj/item/hardpoint/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/ammo_magazine/tank))
		try_add_clip(W, user)
		return
	if(!iswelder(W) && !iswrench(W))
		return ..()
	if(obj_integrity >= max_integrity)
		to_chat(user, span_notice("[src] is already in perfect conditions."))
		return
	var/repair_delays = 6
	var/obj/item/tool/repair_tool = /obj/item/tool/weldingtool
	switch(slot)
		if(HDPT_PRIMARY)
			repair_delays = 5
		if(HDPT_SECDGUN)
			repair_tool = /obj/item/tool/wrench
			repair_delays = 3
		if(HDPT_SUPPORT)
			repair_tool = /obj/item/tool/wrench
			repair_delays = 2
		if(HDPT_ARMOR)
			repair_delays = 10
	var/obj/item/tool/weldingtool/WT = iswelder(W) ? W : null
	if(!istype(W, repair_tool))
		to_chat(user, span_warning("That's the wrong tool. Use a [WT ? "wrench" : "welder"]."))
		return
	if(WT && !WT.isOn())
		to_chat(user, span_warning("You need to light your [WT] first."))
		return
	user.visible_message(span_notice("[user] starts repairing [src]."),
		span_notice("You start repairing [src]."))
	if(!do_after(user, 3 SECONDS * repair_delays, NONE, src, BUSY_ICON_BUILD))
		user.visible_message(span_notice("[user] stops repairing [src]."),
							span_notice("You stop repairing [src]."))
		return
	if(WT)
		if(!WT.isOn())
			return
		WT.remove_fuel(repair_delays, user)
	user.visible_message(span_notice("[user] finishes repairing [src]."),
		span_notice("You finish repairing [src]."))
	repair_damage(max_integrity)

//Called on attaching, for weapons sets the actual cooldowns
/obj/item/hardpoint/proc/apply_buff()
	return

//Called when removing, resets cooldown lengths, move delay, etc
/obj/item/hardpoint/proc/remove_buff()
	return

//Called when you want to activate the hardpoint, such as a gun
//This can also be used for some type of temporary buff, up to you
/obj/item/hardpoint/proc/active_effect(atom/A)
	return

/obj/item/hardpoint/proc/deactivate()
	return

/obj/item/hardpoint/proc/livingmob_interact(mob/living/M)
	return

//If our cooldown has elapsed
/obj/item/hardpoint/proc/is_ready()
	if(world.time < next_use)
		to_chat(usr, span_warning("This module is not ready to be used yet."))
		return FALSE
	if(!obj_integrity)
		to_chat(usr, span_warning("This module is too broken to be used."))
		return FALSE
	return TRUE

/obj/item/hardpoint/proc/try_add_clip(obj/item/ammo_magazine/tank/A, mob/user)

	if(!max_clips)
		to_chat(user, span_warning("This module does not have room for additional ammo."))
		return FALSE
	else if(length(backup_clips) >= max_clips)
		to_chat(user, span_warning("The reloader is full."))
		return FALSE
	else if(!istype(A, starter_ammo))
		to_chat(user, span_warning("That is the wrong ammo type."))
		return FALSE

	to_chat(user, span_notice("You start loading [A] in [src]."))

	var/atom/target = owner ? owner : src

	if(!do_after(user, 10, NONE, target) || QDELETED(src))
		to_chat(user, span_warning("Something interrupted you while loading [src]."))
		return FALSE

	user.temporarilyRemoveItemFromInventory(A, FALSE)
	user.visible_message(span_notice("[user] loads [A] in [src]"),
				span_notice("You finish loading [A] in \the [src]."), null, 3)
	backup_clips += A
	playsound(user.loc, 'sound/weapons/guns/interact/minigun_cocked.ogg', 25)
	return TRUE

//Returns the image object to overlay onto the root object
/obj/item/hardpoint/proc/get_icon_image(x_offset, y_offset, new_dir)

	var/icon_suffix = "NS"
	var/icon_state_suffix = "0"

	if(new_dir in list(NORTH, SOUTH))
		icon_suffix = "NS"
	else if(new_dir in list(EAST, WEST))
		icon_suffix = "EW"

	if(!obj_integrity)
		icon_state_suffix = "1"

	return image(icon = "[disp_icon]_[icon_suffix]", icon_state = "[disp_icon_state]_[icon_state_suffix]", pixel_x = x_offset, pixel_y = y_offset)

/obj/item/hardpoint/proc/firing_arc(atom/A)
	var/turf/T = get_turf(A)
	if(!T || !owner)
		return FALSE
	var/dx = T.x - owner.x
	var/dy = T.y - owner.y
	var/deg = 0
	switch(owner.dir)
		if(EAST) deg = 0
		if(NORTH) deg = -90
		if(WEST) deg = -180
		if(SOUTH) deg = -270

	var/nx = dx * cos(deg) - dy * sin(deg)
	var/ny = dx * sin(deg) + dy * cos(deg)
	if(nx == 0)
		return max_angle >= 90
	var/angle = arctan(ny/nx)
	if(nx < 0)
		angle += 180
	return abs(angle) <= max_angle

//Delineating between slots
/obj/item/hardpoint/primary
	slot = HDPT_PRIMARY
	is_activatable = TRUE

/obj/item/hardpoint/secondary
	slot = HDPT_SECDGUN
	is_activatable = TRUE

/obj/item/hardpoint/support
	slot = HDPT_SUPPORT

/obj/item/hardpoint/armor
	slot = HDPT_ARMOR
	max_clips = 0

/obj/item/hardpoint/treads
	slot = HDPT_TREADS
	max_clips = 0
	gender = PLURAL

////////////////////
// PRIMARY SLOTS // START
////////////////////

/obj/item/hardpoint/primary/cannon
	name = "LTB Cannon"
	desc = "A primary cannon for tanks that shoots explosive rounds"

	max_integrity = 500
	point_cost = 100

	icon_state = "ltb_cannon"

	disp_icon = "tank"
	disp_icon_state = "ltb_cannon"

	starter_ammo = /obj/item/ammo_magazine/tank/ltb_cannon
	max_clips = 3
	max_angle = 45

/obj/item/hardpoint/primary/cannon/broken
	obj_integrity = 0
	buyable = FALSE

/obj/item/hardpoint/primary/cannon/apply_buff()
	owner.internal_cooldowns["primary"] = 200
	owner.accuracies["primary"] = 0.97

/obj/item/hardpoint/primary/cannon/active_effect(atom/A)

	if(!(ammo?.current_rounds > 0))
		to_chat(usr, span_warning("This module does not have any ammo."))
		return

	next_use = world.time + owner.internal_cooldowns["primary"] * owner.misc_ratios["prim_cool"]
	var/obj/item/hardpoint/secondary/towlauncher/HP = owner.hardpoints[HDPT_SECDGUN]
	if(istype(HP))
		HP.next_use = world.time + owner.internal_cooldowns["secondary"] * owner.misc_ratios["secd_cool"]

	var/delay = 5
	var/turf/T = get_turf(A)
	if(!T)
		return
	var/obj/vehicle/multitile/root/cm_armored/tank/C = owner
	var/obj/effect/overlay/temp/tank_laser/TL
	if(C.is_zoomed)
		delay = 20
		TL = new /obj/effect/overlay/temp/tank_laser (T)

	to_chat(usr, span_warning("Preparing to fire... keep the tank still for [delay * 0.1] seconds."))

	if(!do_after(usr, delay, IGNORE_HELD_ITEM, src) || QDELETED(owner))
		to_chat(usr, span_warning("The [name]'s firing was interrupted."))
		qdel(TL)

		return

	qdel(TL)

	if(!prob(owner.accuracies["primary"] * 100 * owner.misc_ratios["prim_acc"]))
		T = get_step(T, pick(GLOB.cardinals))
	var/obj/projectile/P = new
	P.generate_bullet(new ammo.default_ammo)
	log_bomber(usr, "fired", src)
	P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
	playsound(get_turf(src), pick('sound/weapons/guns/fire/tank_cannon1.ogg', 'sound/weapons/guns/fire/tank_cannon2.ogg'), 60, 1)
	ammo.current_rounds--

/obj/item/hardpoint/primary/minigun
	name = "LTAA-AP Minigun"
	desc = "A primary weapon for tanks that spews bullets"

	max_integrity = 350
	point_cost = 100

	icon_state = "ltaaap_minigun"

	disp_icon = "tank"
	disp_icon_state = "ltaaap_minigun"

	starter_ammo = /obj/item/ammo_magazine/tank/ltaaap_minigun
	max_angle = 45

	//Miniguns don't use a conventional cooldown
	//If you fire quickly enough, the cooldown decreases according to chain_delays
	//If you fire too slowly, you slowly slow back down
	//Also, different sounds play and it sounds sick, thanks Rahlzel
	var/chained = 0 //how many quick succession shots we've fired
	var/list/chain_delays = list(4, 4, 3, 3, 2, 2, 2, 1, 1) //the different cooldowns in deciseconds, sequentially

	//MAIN PROBLEM WITH THIS IMPLEMENTATION OF DELAYS:
	//If you spin all the way up and then stop firing, your chained shots will only decrease by 1
	//TODO: Implement a rolling average for seconds per shot that determines chain length without being slow or buggy
	//You'd probably have to normalize it between the length of the list and the actual ROF
	//But you don't want to map it below a certain point probably since seconds per shot would go to infinity

	//So, I came back to this and changed it by adding a fixed reset at 1.5 seconds or later, which seems reasonable
	//Now the cutoff is a little abrupt, but at least it exists. --MadSnailDisease

/obj/item/hardpoint/primary/minigun/apply_buff()
	owner.internal_cooldowns["primary"] = 2 //will be overridden, please ignore
	owner.accuracies["primary"] = 0.33

/obj/item/hardpoint/primary/minigun/active_effect(atom/A)
	if(!(ammo?.current_rounds > 0))
		to_chat(usr, span_warning("This module does not have any ammo."))
		return
	var/S = 'sound/weapons/guns/fire/tank_minigun_start.ogg'
	if(world.time - next_use <= 5)
		chained++ //minigun spins up, minigun spins down
		S = 'sound/weapons/guns/fire/tank_minigun_loop.ogg'
	else if(world.time - next_use >= 15) //Too long of a delay, they restart the chain
		chained = 1
	else //In between 5 and 15 it slows down but doesn't stop
		chained--
		S = 'sound/weapons/guns/fire/tank_minigun_stop.ogg'
	if(chained <= 0)
		chained = 1

	next_use = world.time + (chained > length(chain_delays) ? 0.5 : chain_delays[chained]) * owner.misc_ratios["prim_cool"]
	if(!prob(owner.accuracies["primary"] * 100 * owner.misc_ratios["prim_acc"]))
		A = get_step(A, pick(GLOB.cardinals))
	var/obj/projectile/P = new
	P.generate_bullet(new ammo.default_ammo)
	P.fire_at(A, owner, src, P.ammo.max_range, P.ammo.shell_speed)

	playsound(get_turf(src), S, 60)
	ammo.current_rounds--

////////////////////
// PRIMARY SLOTS // END
////////////////////

/////////////////////
// SECONDARY SLOTS // START
/////////////////////

/obj/item/hardpoint/secondary/flamer
	name = "Secondary Flamer Unit"
	desc = "A secondary weapon for tanks that shoots flames"

	max_integrity = 300
	point_cost = 100

	icon_state = "flamer"

	disp_icon = "tank"
	disp_icon_state = "flamer"

	starter_ammo = /obj/item/ammo_magazine/tank/flamer
	max_angle = 90

/obj/item/hardpoint/secondary/flamer/apply_buff()
	owner.internal_cooldowns["secondary"] = 20
	owner.accuracies["secondary"] = 0.5

/obj/item/hardpoint/secondary/flamer/active_effect(atom/A)

	if(!(ammo?.current_rounds > 0))
		to_chat(usr, span_warning("This module does not have any ammo."))
		return

	next_use = world.time + owner.internal_cooldowns["secondary"] * owner.misc_ratios["secd_cool"]
	if(!prob(owner.accuracies["secondary"] * 100 * owner.misc_ratios["secd_acc"]))
		A = get_step(A, pick(GLOB.cardinals))
	var/obj/projectile/P = new
	P.generate_bullet(new ammo.default_ammo)
	P.fire_at(A, owner, src, P.ammo.max_range, P.ammo.shell_speed)
	playsound(get_turf(src), 'sound/weapons/guns/fire/tank_flamethrower.ogg', 60, 1)
	ammo.current_rounds--

/obj/item/hardpoint/secondary/towlauncher
	name = "TOW Launcher"
	desc = "A secondary weapon for tanks that shoots rockets"

	max_integrity = 500
	point_cost = 100

	icon_state = "tow_launcher"

	disp_icon = "tank"
	disp_icon_state = "towlauncher"

	starter_ammo = /obj/item/ammo_magazine/tank/towlauncher
	max_clips = 1
	max_angle = 90

/obj/item/hardpoint/secondary/towlauncher/apply_buff()
	owner.internal_cooldowns["secondary"] = 150
	owner.accuracies["secondary"] = 0.8

/obj/item/hardpoint/secondary/towlauncher/active_effect(atom/A)

	if(!(ammo?.current_rounds > 0))
		to_chat(usr, span_warning("This module does not have any ammo."))
		return

	var/delay = 3
	var/turf/T = get_turf(A)
	if(!T)
		return
	var/obj/vehicle/multitile/root/cm_armored/tank/C = owner
	var/obj/effect/overlay/temp/tank_laser/TL
	if(C.is_zoomed)
		delay = 15
		TL = new /obj/effect/overlay/temp/tank_laser (T)

	to_chat(usr, span_warning("Preparing to fire... keep the tank still for [delay * 0.1] seconds."))

	if(!do_after(usr, delay, IGNORE_HELD_ITEM, src) || QDELETED(owner))
		to_chat(usr, span_warning("The [name]'s firing was interrupted."))
		qdel(TL)
		return

	qdel(TL)

	next_use = world.time + owner.internal_cooldowns["secondary"] * owner.misc_ratios["secd_cool"]
	var/obj/item/hardpoint/primary/cannon/HP = owner.hardpoints[HDPT_PRIMARY]
	if(istype(HP))
		HP.next_use = world.time + owner.internal_cooldowns["primary"] * owner.misc_ratios["prim_cool"]

	if(!prob(owner.accuracies["secondary"] * 100 * owner.misc_ratios["secd_acc"]))
		T = get_step(T, pick(GLOB.cardinals))
	var/obj/projectile/P = new
	P.generate_bullet(new ammo.default_ammo)
	log_bomber(usr, "fired", src)
	P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
	ammo.current_rounds--

/obj/item/hardpoint/secondary/m56cupola/broken
	obj_integrity = 0
	buyable = FALSE

/obj/item/hardpoint/secondary/m56cupola/apply_buff()
	owner.internal_cooldowns["secondary"] = 3
	owner.accuracies["secondary"] = 0.7

/obj/item/hardpoint/secondary/m56cupola/active_effect(atom/A)

	if(!(ammo?.current_rounds > 0))
		to_chat(usr, span_warning("This module does not have any ammo."))
		return

	next_use = world.time + owner.internal_cooldowns["secondary"] * owner.misc_ratios["secd_cool"]
	if(!prob(owner.accuracies["secondary"] * 100 * owner.misc_ratios["secd_acc"]))
		A = get_step(A, pick(GLOB.cardinals))
	var/obj/projectile/P = new
	P.generate_bullet(new ammo.default_ammo)
	P.fire_at(A, owner, src, P.ammo.max_range, P.ammo.shell_speed)
	playsound(get_turf(src), pick(list('sound/weapons/guns/fire/smartgun1.ogg', 'sound/weapons/guns/fire/smartgun2.ogg', 'sound/weapons/guns/fire/smartgun3.ogg')), 60, 1)
	ammo.current_rounds--

/obj/item/hardpoint/secondary/grenade_launcher
	name = "Grenade Launcher"
	desc = "A secondary weapon for tanks that shoots grenades"

	max_integrity = 500
	point_cost = 25

	icon_state = "glauncher"

	disp_icon = "tank"
	disp_icon_state = "glauncher"

	starter_ammo = /obj/item/ammo_magazine/tank/tank_glauncher
	max_clips = 3
	max_angle = 90

/obj/item/hardpoint/secondary/grenade_launcher/apply_buff()
	owner.internal_cooldowns["secondary"] = 30
	owner.accuracies["secondary"] = 0.4

/obj/item/hardpoint/secondary/grenade_launcher/active_effect(atom/A)

	if(!(ammo?.current_rounds > 0))
		to_chat(usr, span_warning("This module does not have any ammo."))
		return

	next_use = world.time + owner.internal_cooldowns["secondary"] * owner.misc_ratios["secd_cool"]
	if(!prob(owner.accuracies["secondary"] * 100 * owner.misc_ratios["secd_acc"]))
		A = get_step(A, pick(GLOB.cardinals))
	var/obj/projectile/P = new
	P.generate_bullet(new ammo.default_ammo)
	log_bomber(usr, "fired", src)
	P.fire_at(A, owner, src, P.ammo.max_range, P.ammo.shell_speed)
	playsound(get_turf(src), 'sound/weapons/guns/fire/grenadelauncher.ogg', 60, 1)
	ammo.current_rounds--
/////////////////////
// SECONDARY SLOTS // END
/////////////////////

///////////////////
// SUPPORT SLOTS // START
///////////////////

/obj/item/hardpoint/support/smoke_launcher
	name = "Smoke Launcher"
	desc = "Launches smoke forward to obscure vision"

	max_integrity = 300
	point_cost = 10

	icon_state = "slauncher_0"

	disp_icon = "tank"
	disp_icon_state = "slauncher"

	starter_ammo = /obj/item/ammo_magazine/tank/tank_slauncher
	max_clips = 4
	is_activatable = TRUE

/obj/item/hardpoint/support/smoke_launcher/broken
	obj_integrity = 0
	buyable = FALSE

/obj/item/hardpoint/support/smoke_launcher/apply_buff()
	owner.internal_cooldowns["support"] = 30
	owner.accuracies["support"] = 0.8

/obj/item/hardpoint/support/smoke_launcher/active_effect(atom/A)

	if(!(ammo?.current_rounds > 0))
		to_chat(usr, span_warning("This module does not have any ammo."))
		return

	next_use = world.time + owner.internal_cooldowns["support"] * owner.misc_ratios["supp_cool"]
	if(!prob(owner.accuracies["support"] * 100 * owner.misc_ratios["supp_acc"]))
		A = get_step(A, pick(GLOB.cardinals))
	var/obj/projectile/P = new
	P.generate_bullet(new ammo.default_ammo)
	P.fire_at(A, owner, src, P.ammo.max_range, P.ammo.shell_speed)
	playsound(get_turf(src), 'sound/weapons/guns/fire/tank_smokelauncher.ogg', 60, 1)
	ammo.current_rounds--

/obj/item/hardpoint/support/smoke_launcher/get_icon_image(x_offset, y_offset, new_dir)

	var/icon_suffix = "NS"
	var/icon_state_suffix = "0"

	if(new_dir in list(NORTH, SOUTH))
		icon_suffix = "NS"
	else if(new_dir in list(EAST, WEST))
		icon_suffix = "EW"

	if(!obj_integrity)
		icon_state_suffix = "1"
	else if(!(ammo?.current_rounds > 0))
		icon_state_suffix = "2"

	return image(icon = "[disp_icon]_[icon_suffix]", icon_state = "[disp_icon_state]_[icon_state_suffix]", pixel_x = x_offset, pixel_y = y_offset)

/obj/item/hardpoint/support/weapons_sensor
	name = "Integrated Weapons Sensor Array"
	desc = "Improves the accuracy and fire rate of all onboard weapons"

	max_integrity = 250
	point_cost = 100
	max_clips = 0

	icon_state = "warray"

	disp_icon = "tank"
	disp_icon_state = "warray"

/obj/item/hardpoint/support/weapons_sensor/apply_buff()
	owner.misc_ratios["prim_cool"] = 0.67
	owner.misc_ratios["secd_cool"] = 0.67
	owner.misc_ratios["supp_cool"] = 0.67

	owner.misc_ratios["prim_acc"] = 1.67
	owner.misc_ratios["secd_acc"] = 1.67
	owner.misc_ratios["supp_acc"] = 1.67

/obj/item/hardpoint/support/weapons_sensor/remove_buff()
	owner.misc_ratios["prim_cool"] = 1
	owner.misc_ratios["secd_cool"] = 1
	owner.misc_ratios["supp_cool"] = 1

	owner.misc_ratios["prim_acc"] = 1
	owner.misc_ratios["secd_acc"] = 1
	owner.misc_ratios["supp_acc"] = 1

/obj/item/hardpoint/support/overdrive_enhancer
	name = "Overdrive Enhancer"
	desc = "Increases the movement speed of the vehicle it's atached to"

	max_integrity = 250
	point_cost = 100
	max_clips = 0

	icon_state = "odrive_enhancer"
	is_activatable = TRUE

	disp_icon = "tank"
	disp_icon_state = "odrive_enhancer"

	var/last_boost

/obj/item/hardpoint/support/overdrive_enhancer/proc/nitros_on(mob/M)
	owner.misc_ratios["move"] = 0.2
	if(M)
		to_chat(M, span_danger("You hit the nitros! RRRRRRRMMMM!!"))
	playsound(M, 'sound/mecha/hydraulic.ogg', 60, 1, vary = 0)
	addtimer(CALLBACK(src, PROC_REF(boost_off)), TANK_OVERDRIVE_BOOST_DURATION)
	addtimer(CALLBACK(src, PROC_REF(boost_ready_notice)), TANK_OVERDRIVE_BOOST_COOLDOWN)

/obj/item/hardpoint/support/overdrive_enhancer/remove_buff()
	var/obj/vehicle/multitile/root/cm_armored/tank/C = owner
	C.verbs -= /obj/vehicle/multitile/root/cm_armored/tank/verb/overdrive_multitile
	boost_off()

/obj/item/hardpoint/support/overdrive_enhancer/apply_buff()
	var/obj/vehicle/multitile/root/cm_armored/tank/C = owner
	C.verbs += /obj/vehicle/multitile/root/cm_armored/tank/verb/overdrive_multitile

/obj/item/hardpoint/support/overdrive_enhancer/proc/boost_off()
	owner.misc_ratios["move"] = 1

/obj/item/hardpoint/support/overdrive_enhancer/proc/boost_ready_notice()
	var/obj/vehicle/multitile/root/cm_armored/tank/C = owner
	if(C.driver)
		to_chat(C.driver, span_danger("The overdrive nitros are ready for use."))

/obj/item/hardpoint/support/overdrive_enhancer/proc/activate_overdrive()
	var/obj/vehicle/multitile/root/cm_armored/tank/C = owner
	if(!C.driver)
		return
	if(world.time < last_boost + TANK_OVERDRIVE_BOOST_COOLDOWN)
		to_chat(C.driver, span_warning("Your nitro overdrive isn't yet ready. It will be available again in [(last_boost + TANK_OVERDRIVE_BOOST_COOLDOWN - world.time) * 0.1] seconds."))
		return
	last_boost = world.time
	nitros_on(C.driver)

//How to get out, via verb
/obj/vehicle/multitile/root/cm_armored/tank/verb/overdrive_multitile()
	set category = "Vehicle"
	set name = "Activate Overdrive"
	set src in view(0)

	if(usr.incapacitated(TRUE))
		return

	if(usr != driver)
		to_chat(usr, span_warning("You need to be in the driver seat to use this!"))
		return

	var/obj/item/hardpoint/support/overdrive_enhancer/OE = hardpoints[HDPT_SUPPORT]
	if(!istype(OE, /obj/item/hardpoint/support/overdrive_enhancer) || OE.obj_integrity <= 0)
		to_chat(usr, span_warning("The overdrive engine is missing or too badly damaged!"))
		return
	OE.activate_overdrive(usr)

/obj/item/hardpoint/support/artillery_module
	name = "Artillery Module"
	desc = "Allows the gunner to look far into the distance."

	max_integrity = 250
	point_cost = 100
	max_clips = 0

	is_activatable = TRUE
	var/is_active = FALSE

	var/view_buff = "25x25" //This way you can VV for more or less fun
	var/view_tile_offset = 5

	icon_state = "artillery"

	disp_icon = "tank"
	disp_icon_state = "artillerymod"

/obj/item/hardpoint/support/artillery_module/active_effect(atom/A)
	var/obj/vehicle/multitile/root/cm_armored/tank/C = owner
	if(!C.gunner)
		return
	var/mob/M = C.gunner
	if(!M.client)
		return
	if(is_active)
		M.client.view_size.reset_to_default()
		M.client.pixel_x = 0
		M.client.pixel_y = 0
		is_active = FALSE
		C.is_zoomed = FALSE
		return
	M.client.view_size.reset_to_default()
	is_active = TRUE
	C.is_zoomed = TRUE
	switch(C.dir)
		if(NORTH)
			M.client.pixel_x = 0
			M.client.pixel_y = view_tile_offset * 32
		if(SOUTH)
			M.client.pixel_x = 0
			M.client.pixel_y = -1 * view_tile_offset * 32
		if(EAST)
			M.client.pixel_x = view_tile_offset * 32
			M.client.pixel_y = 0
		if(WEST)
			M.client.pixel_x = -1 * view_tile_offset * 32
			M.client.pixel_y = 0

/obj/item/hardpoint/support/artillery_module/deactivate()
	var/obj/vehicle/multitile/root/cm_armored/tank/C = owner
	if(!ismob(C.gunner))
		return
	var/mob/M = C.gunner
	if(!M.client)
		return
	is_active = FALSE
	M.client.view_size.reset_to_default()
	M.client.pixel_x = 0
	M.client.pixel_y = 0

/obj/item/hardpoint/support/artillery_module/remove_buff()
	deactivate()

/obj/item/hardpoint/support/artillery_module/is_ready()
	if(!obj_integrity)
		to_chat(usr, span_warning("This module is too broken to be used."))
		return FALSE
	return TRUE

///////////////////
// SUPPORT SLOTS // END
///////////////////

/////////////////
// ARMOR SLOTS // START
/////////////////

/obj/item/hardpoint/armor/ballistic
	name = "Ballistic Armor"
	desc = "Protects the vehicle from high-penetration weapons. Provides some protection against slashing and high impact attacks."

	max_integrity = 1000
	point_cost = 100

	icon_state = "ballistic_armor"

	disp_icon = "tank"
	disp_icon_state = "ballistic_armor"

/obj/item/hardpoint/armor/ballistic/broken
	obj_integrity = 0
	buyable = FALSE

/obj/item/hardpoint/armor/ballistic/apply_buff()
	owner.dmg_multipliers["bullet"] = 0.5
	owner.dmg_multipliers["slash"] = 0.75
	owner.dmg_multipliers["blunt"] = 0.75
	owner.dmg_multipliers["all"] = 0.9

/obj/item/hardpoint/armor/ballistic/remove_buff()
	owner.dmg_multipliers["bullet"] = 1
	owner.dmg_multipliers["slash"] = 1
	owner.dmg_multipliers["blunt"] = 1
	owner.dmg_multipliers["all"] = 1

/obj/item/hardpoint/armor/caustic
	name = "Caustic Armor"
	desc = "Protects vehicles from most types of acid. Provides some protection against slashing and high impact attacks."

	max_integrity = 1000
	point_cost = 100

	icon_state = "caustic_armor"

	disp_icon = "tank"
	disp_icon_state = "caustic_armor"

/obj/item/hardpoint/armor/caustic/apply_buff()
	owner.dmg_multipliers["acid"] = 0.5
	owner.dmg_multipliers["slash"] = 0.75
	owner.dmg_multipliers["blunt"] = 0.75
	owner.dmg_multipliers["all"] = 0.9

/obj/item/hardpoint/armor/caustic/remove_buff()
	owner.dmg_multipliers["acid"] = 1
	owner.dmg_multipliers["slash"] = 1
	owner.dmg_multipliers["blunt"] = 1
	owner.dmg_multipliers["all"] = 1

/obj/item/hardpoint/armor/concussive
	name = "Concussive Armor"
	desc = "Protects the vehicle from high-impact weapons. Provides some protection against ballistic and explosive attacks."

	max_integrity = 1000
	point_cost = 100

	icon_state = "concussive_armor"

	disp_icon = "tank"
	disp_icon_state = "concussive_armor"

/obj/item/hardpoint/armor/concussive/apply_buff()
	owner.dmg_multipliers["blunt"] = 0.5
	owner.dmg_multipliers["explosive"] = 0.75
	owner.dmg_multipliers["ballistic"] = 0.75
	owner.dmg_multipliers["all"] = 0.9

/obj/item/hardpoint/armor/concussive/remove_buff()
	owner.dmg_multipliers["blunt"] = 1
	owner.dmg_multipliers["explosive"] = 1
	owner.dmg_multipliers["ballistic"] = 1
	owner.dmg_multipliers["all"] = 1

/obj/item/hardpoint/armor/paladin
	name = "Paladin Armor"
	desc = "Protects the vehicle from large incoming explosive projectiles. Provides some protection against slashing and high impact attacks."

	max_integrity = 1000
	point_cost = 100

	icon_state = "paladin_armor"

	disp_icon = "tank"
	disp_icon_state = "paladin_armor"

/obj/item/hardpoint/armor/paladin/apply_buff()
	owner.dmg_multipliers["explosive"] = 0.5
	owner.dmg_multipliers["blunt"] = 0.75
	owner.dmg_multipliers["slash"] = 0.75
	owner.dmg_multipliers["all"] = 0.9

/obj/item/hardpoint/armor/paladin/remove_buff()
	owner.dmg_multipliers["explosive"] = 1
	owner.dmg_multipliers["blunt"] = 1
	owner.dmg_multipliers["slash"] = 1
	owner.dmg_multipliers["all"] = 1

/obj/item/hardpoint/armor/snowplow
	name = "Snowplow"
	desc = "Clears a path in the snow for friendlies"

	max_integrity = 700
	is_activatable = TRUE
	point_cost = 50

	icon_state = "snowplow"

	disp_icon = "tank"
	disp_icon_state = "snowplow"

/obj/item/hardpoint/armor/snowplow/livingmob_interact(mob/living/M)
	var/turf/targ = get_step(M, owner.dir)
	targ = get_step(M, owner.dir)
	targ = get_step(M, owner.dir)
	M.throw_at(targ, 4, 2, src, 1)
	M.apply_damage(7 + rand(0, 3), BRUTE, blocked = MELEE)

/////////////////
// ARMOR SLOTS // END
/////////////////

/////////////////
// TREAD SLOTS // START
/////////////////

/obj/item/hardpoint/treads/standard
	name = "Treads"
	desc = "Integral to the movement of the vehicle"

	max_integrity = 500
	point_cost = 25

	icon_state = "treads"

	disp_icon = "tank"
	disp_icon_state = "treads"

/obj/item/hardpoint/treads/standard/broken
	obj_integrity = 0
	buyable = FALSE

/obj/item/hardpoint/treads/standard/get_icon_image(x_offset, y_offset, new_dir)
	return null //Handled in update_icon()

/obj/item/hardpoint/treads/standard/apply_buff()
	owner.move_delay = 7

/obj/item/hardpoint/treads/standard/remove_buff()
	owner.move_delay = 30

/////////////////
// TREAD SLOTS // END
/////////////////


///////////////
// AMMO MAGS // START
///////////////

//Special ammo magazines for hardpoint modules. Some aren't here since you can use normal magazines on them
/obj/item/ammo_magazine/tank
	flags_magazine = NONE //No refilling
	var/point_cost = 0

/obj/item/ammo_magazine/tank/ltb_cannon
	name = "LTB Cannon Magazine"
	desc = "A primary armament cannon magazine"
	caliber = CALIBER_86 //Making this unique on purpose
	icon_state = "ltbcannon_4"
	w_class = WEIGHT_CLASS_GIGANTIC
	default_ammo = /datum/ammo/rocket/ltb
	max_rounds = 4
	point_cost = 50

/obj/item/ammo_magazine/tank/ltb_cannon/update_icon()
	icon_state = "ltbcannon_[current_rounds]"


/obj/item/ammo_magazine/tank/ltaaap_minigun
	name = "LTAA-AP Minigun Magazine"
	desc = "A primary armament minigun magazine"
	caliber = CALIBER_762X51 //Correlates to miniguns
	icon_state = "painless"
	w_class = WEIGHT_CLASS_GIGANTIC
	default_ammo = /datum/ammo/bullet/minigun
	max_rounds = 500
	point_cost = 25



/obj/item/ammo_magazine/tank/flamer
	name = "Flamer Magazine"
	desc = "A secondary armament flamethrower magazine"
	caliber = CALIBER_FUEL_THICK //correlates to flamer mags
	icon_state = "flametank_large"
	w_class = WEIGHT_CLASS_GIGANTIC
	default_ammo = /datum/ammo/flamethrower/tank_flamer
	max_rounds = 120
	point_cost = 50



/obj/item/ammo_magazine/tank/towlauncher
	name = "TOW Launcher Magazine"
	desc = "A secondary armament rocket magazine"
	caliber = CALIBER_84MM //correlates to any rocket mags
	icon_state = "quad_rocket"
	w_class = WEIGHT_CLASS_GIGANTIC
	default_ammo = /datum/ammo/rocket/ap //Fun fact, AP rockets seem to be a straight downgrade from normal rockets. Maybe I'm missing something...
	max_rounds = 5
	point_cost = 100

/obj/item/ammo_magazine/tank/tank_glauncher
	name = "Grenade Launcher Magazine"
	desc = "A secondary armament grenade magazine"
	caliber = CALIBER_40MM
	icon_state = "glauncher_2"
	w_class = WEIGHT_CLASS_GIGANTIC
	default_ammo = /datum/ammo/grenade_container
	max_rounds = 10
	point_cost = 25


/obj/item/ammo_magazine/tank/tank_glauncher/update_icon()
	if(current_rounds >= max_rounds)
		icon_state = "glauncher_2"
	else if(current_rounds <= 0)
		icon_state = "glauncher_0"
	else
		icon_state = "glauncher_1"


/obj/item/ammo_magazine/tank/tank_slauncher
	name = "Smoke Launcher Magazine"
	desc = "A support armament grenade magazine"
	caliber = CALIBER_40MM
	icon_state = "slauncher_1"
	w_class = WEIGHT_CLASS_GIGANTIC
	default_ammo = /datum/ammo/grenade_container/smoke
	max_rounds = 6
	point_cost = 5

/obj/item/ammo_magazine/tank/tank_slauncher/update_icon()
	icon_state = "slauncher_[current_rounds <= 0 ? "0" : "1"]"

///////////////
// AMMO MAGS // END
///////////////
