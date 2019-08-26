#define GUN_RIGHT 0
#define GUN_LEFT 1

#define DAMAGE_THRESHOLD_STANDART 15

/////////////////
// Walker
/////////////////

/obj/vehicle/walker
	name = "CW13 \"Megalodon\" Assault Walker"
	desc = "Relatively new combat walker of \"Megalodon\"-series. Unlike its predecessor, \"Carharodon\"-series, slower, but relays on its tough armor and rapid-firing weapons."
	icon = 'RU-TGMC/icons/obj/vehicles/mech-walker.dmi'
	icon_state = "mech"
	layer = ABOVE_LYING_MOB_LAYER
	opacity = TRUE
	can_buckle = FALSE
	move_delay = 6

	var/obj/machinery/camera/camera
	var/lights = FALSE
	var/lights_power = 8
	var/zoom = FALSE
	var/zoom_size = 14

	pixel_x = -18

	obj_integrity = 700
	max_integrity = 700
	var/repair = FALSE

	var/mob/pilot = null

	var/acid_process_cooldown = null
	var/list/damage_threshold = list(
		"face" = 20,
		"faceflank" = 10,
		"flank" = 0,
		"behind" = -15
		)
	var/list/dmg_multipliers = list(
		"all" = 1.0, //for when you want to make it invincible
		"acid" = 0.9,
		"slash" = 0.9,
		"bullet" = 0.2,
		"explosive" = 5.0,
		"blunt" = 0.1,
		"energy" = 1.0,
		"abstract" = 1.0) //abstract for when you just want to hurt it

	var/max_angle = 45
	var/obj/item/walker_hardpoint/gun/left = null
	var/obj/item/walker_hardpoint/gun/right = null
	var/obj/item/walker_hardpoint/armor/armor_module = null
	var/selected = GUN_LEFT

/obj/vehicle/walker/Initialize()
	. = ..()

	camera = new (src)
	camera.network = list("military")
	camera.c_tag = "[name]"
	resistance_flags |= UNACIDABLE

/obj/vehicle/walker/Destroy()
	QDEL_NULL(camera)
	QDEL_NULL(left)
	QDEL_NULL(right)
	QDEL_NULL(armor_module)
	. = ..()

/obj/vehicle/walker/prebuilt/Initialize()
	. = ..()

	left = new /obj/item/walker_gun/smartgun()
	right = new /obj/item/walker_gun/flamer()
	left.ammo = new left.magazine_type()
	right.ammo = new right.magazine_type()
	left.owner = src
	right.owner = src

	update_icon()

/obj/vehicle/walker/update_icon()
	overlays.Cut()

	if(left)
		var/image/left_gun = left.get_icon_image("-l")
		overlays += left_gun
	if(right)
		var/image/right_gun = right.get_icon_image("-r")
		overlays += right_gun

	if(right)
		var/image/armor = armor_module.get_icon_image()
		overlays += armor

	if(pilot)
		var/image/occupied = image(icon, icon_state = "mech-face")
		overlays += occupied

/obj/vehicle/walker/examine(mob/user)
	..()
	var/integrity = round(obj_integrity/max_integrity*100)
	switch(integrity)
		if(85 to 100)
			to_chat(usr, "It's fully intact.")
		if(65 to 85)
			to_chat(usr, "It's slightly damaged.")
		if(45 to 65)
			to_chat(usr, "It's badly damaged.")
		if(25 to 45)
			to_chat(usr, "It's heavily damaged.")
		else
			to_chat(usr, "It's falling apart.")
	to_chat(usr, "[left ? left.name : "Nothing"] is placed on its left hardpoint.")
	to_chat(usr, "[right ? right.name : "Nothing"] is placed on its right hardpoint.")
	to_chat(usr, "[armor_module ? armor_module.name : "Nothing"] is placed on its armor hardpoint.")

/obj/vehicle/walker/ex_act(severity)
	switch(severity)
		if (1)
			if(prob(10))									// "- You have three seconds to run before I stab you in the anus!"@ Walker Pilot to rocket spec.
				obj_integrity = 0
				healthcheck()
				return
			take_damage(20, "explosive")					// 100 damage btw. 2 instance of MT repair. 3-4 minutes standing IDLY near walker.
		if (2)
			take_damage(15, "explosive")
		if (3)
			take_damage(10, "explosive")					// 10 * 5.0 = 50. Maxhealth is 400. Hellova damage

/atom/proc/mech_collision(obj/vehicle/walker/C)
	return

/obj/effect/alien/mech_collision(obj/vehicle/walker/C)
	take_damage(20)

/obj/effect/alien/weed/mech_collision(obj/vehicle/walker/C)
	return

/obj/effect/xenomorph/spray/mech_collision(obj/vehicle/walker/C)
	if(C)
		C.take_damage(rand(10, 20), "acid")

/obj/vehicle/walker/relaymove(mob/user, direction)
	if(user.incapacitated())
		return
	if(world.time > last_move_time + move_delay)
		if(dir != direction)
			last_move_time = world.time
			dir = direction
			pick(playsound(src.loc, 'sound/mecha/powerloader_turn.ogg', 25, 1), playsound(src.loc, 'sound/mecha/powerloader_turn2.ogg', 25, 1))
			. = TRUE
		else
			. = step(src, direction)
			if(.)
				pick(playsound(loc, 'sound/mecha/powerloader_step.ogg', 25), playsound(loc, 'sound/mecha/powerloader_step2.ogg', 25))
				for(var/obj/atoms in loc)
					atoms.mech_collision(src)

/obj/vehicle/walker/Bump(var/atom/obstacle)
	if(istype(obstacle, /obj/machinery/door))
		var/obj/machinery/door/door = obstacle
		if(door.allowed(pilot))
			door.open()
		else
			flick("door_deny", door)

	else if(ishuman(obstacle))
		step_away(obstacle, src, 0)
		return

//Breaking stuff
	else if(istype(obstacle, /obj/structure/fence))
		var/obj/structure/fence/F = obstacle
		F.visible_message("<span class='danger'>[src.name] smashes through [F]!</span>")
		take_damage(5, "abstract")
		F.obj_integrity = 0
		F.healthcheck()
	else if(istype(obstacle, /obj/structure/table))
		var/obj/structure/table/T = obstacle
		T.visible_message("<span class='danger'>[src.name] crushes [T]!</span>")
		take_damage(5, "abstract")
		T.destroy_structure(TRUE)
	else if(istype(obstacle, /obj/structure/showcase))
		var/obj/structure/showcase/S = obstacle
		S.visible_message("<span class='danger'>[src.name] bulldozes over [S]!</span>")
		take_damage(15, "abstract")
		S.destroy_structure(TRUE)
	else if(istype(obstacle, /obj/structure/rack))
		var/obj/structure/rack/R = obstacle
		R.visible_message("<span class='danger'>[src.name] smashes through the [R]!</span>")
		take_damage(5, "abstract")
		R.destroy_structure(TRUE)
	else if(istype(obstacle, /obj/structure/window/framed))
		var/obj/structure/window/framed/W = obstacle
		W.visible_message("<span class='danger'>[src.name] crashes through the [W]!</span>")
		take_damage(20, "abstract")
		W.shatter_window(1)
	else if(istype(obstacle, /obj/structure/window_frame))
		var/obj/structure/window_frame/WF = obstacle
		WF.visible_message("<span class='danger'>[src.name] runs over the [WF]!</span>")
		take_damage(20, "abstract")
		WF.Destroy()
	else
		..()

/obj/vehicle/walker/Bumped(var/atom/A)
	..()

	if(!isxeno(A))
		return
	var/mob/living/carbon/xenomorph/C = A
	if(isxenocrusher(C))

		var/mob/living/carbon/xenomorph/crusher/caste = A

		if(caste.charge_speed < CHARGE_SPEED_MAX/(1.1)) //Arbitrary ratio here, might want to apply a linear transformation instead
			return

		obj_integrity -= caste.charge_speed * CRUSHER_CHARGE_TANK_MULTI * dmg_multipliers["slash"]
		caste.visible_message("<span class='xenodanger'>You crushed into tincan's armor!</span>", "<span class='danger'>[caste] crushed onto [src]</span>")
		healthcheck()

/obj/vehicle/walker/verb/enter_walker()
	set category = "Object"
	set name = "Enter Into Walker"
	set src in oview(1)

	if(usr.mind && usr.mind.cm_skills && usr.mind.cm_skills.powerloader)
		move_in(usr)
	else
		to_chat(usr, "How to operate it?")

/obj/vehicle/walker/proc/move_in(mob/living/carbon/user)
	set waitfor = FALSE
	if(!ishuman(user))
		return
	if(pilot)
		to_chat(user, "There is someone occupying mecha right now.")
		return
	var/mob/living/carbon/human/H = user
	for(var/obj/item/card/id/ID in list(H.get_active_held_item(), H.wear_id, H.belt))
		if(operation_allowed(ID))
			pilot = user
			user.loc = src
			pilot.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
			pilot.set_interaction(src)
			pilot << sound('sound/mecha/powerup.ogg',volume=50)
			update_icon()
			sleep(50)
			pilot << sound('sound/mecha/nominalsyndi.ogg',volume=50)
			return

	to_chat(user, "Access denied.")

/obj/vehicle/walker/proc/operation_allowed(obj/item/card/id/I)
	if(istype(I) && I.access && ACCESS_MARINE_WALKER in I.access)
		return TRUE
	return FALSE

/obj/vehicle/walker/verb/eject()
	set name = "Eject"
	set category = "Walker Interface"
	set src = usr.loc

	move_out()

/obj/vehicle/walker/proc/move_out()
	if(!pilot)
		return FALSE
	if(obj_integrity <= 0)
		to_chat(pilot, "<span class='danger'>ALERT! Chassis integrity failing. Systems shutting down.</span>")
	if(zoom)
		zoom_activate()
	if(pilot.client)
		pilot.client.mouse_pointer_icon = initial(pilot.client.mouse_pointer_icon)
	pilot.unset_interaction()
	pilot.loc = src.loc
	pilot = null
	update_icon()
	return TRUE

/obj/vehicle/walker/verb/lights()
	set name = "Lights on/off"
	set category = "Walker Interface"
	set src = usr.loc

	handle_lights()

/obj/vehicle/walker/proc/handle_lights()
	if(!lights)
		lights = TRUE
		set_light(lights_power, lights_power - 2)
	else
		lights = FALSE
		set_light(0, 1)
	pilot << sound('sound/machines/click.ogg',volume=50)

/obj/vehicle/walker/verb/deploy_magazine()
	set name = "Deploy Magazine"
	set category = "Walker Interface"
	set src = usr.loc

	if(selected)
		if(!left.ammo)
			return
		else
			left.ammo.loc = src.loc
			left.ammo = null
			to_chat(pilot, "<span class='warning'>WARNING! [left.name] ammo magazine deployed.</span>")
			visible_message("[name]'s systems deployed used magazine.","")
	else
		if(!right.ammo)
			return
		else
			right.ammo.loc = src.loc
			right.ammo = null
			to_chat(pilot, "<span class='warning'>WARNING! [right.name] ammo magazine deployed.</span>")
			visible_message("[name]'s systems deployed used magazine.","")

/obj/vehicle/walker/verb/use_armor()
	set name = "Activate Armor Subsystems"
	set category = "Walker Interface"
	set src = usr.loc

	if(!armor_module)
		return
	armor_module.activate_hardpoint()

/obj/vehicle/walker/verb/get_stats()
	set name = "Status Display"
	set category = "Walker Interface"
	set src = usr.loc

	if(usr != pilot)
		return
	ui_interact(pilot)


/obj/vehicle/walker/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/list/data = list()

	data["integrity"] = round(obj_integrity/max_integrity*100)
	data["left_name"] = null
	if(left)
		data["left_name"] = left.name
		data["left_bul_left"] = left.ammo ? left.ammo.current_rounds : 0
		data["left_bul_full"] = left.ammo ? left.ammo.max_rounds : 0
	data["right_name"] = null
	if(left)
		data["right_name"] = right.name
		data["right_bul_left"] = right.ammo ? right.ammo.current_rounds : 0
		data["right_bul_full"] = right.ammo ? right.ammo.max_rounds : 0
	data["armor_name"] = "Standart"
	if(armor_module)
		data["armor_name"] = armor_module.name
	data["armor_acid"] = 1 - dmg_multipliers["acid"]
	data["armor_slash"] = 1 - dmg_mulipliers["slash"]
	data["armor_bullet"] = 1 - dmg_mulipliers["bullet"]
	data["armor_energy"] = 1 - dmg_mulipliers["energy"]

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
		// for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "walker_ui.tmpl", "Walker UI", 520, 410)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		 // open the new ui window
		ui.open()

/obj/vehicle/walker/verb/select_weapon()
	set name = "Select Weapon"
	set category = "Walker Interface"
	set src = usr.loc

	if(selected)
		if(right == null)
			return
		selected = !selected
	else
		if(left == null)
			return
		selected = !selected
	to_chat(usr, "Selected [selected ? "[left]" : "[right]"]")

/obj/vehicle/walker/proc/handle_click(var/atom/A, var/mob/living/user, var/list/mods)
	if(!firing_arc(A))
		return
	if(selected)
		if(!left)
			to_chat(usr, "<span class='warning'>WARNING! Hardpoint is empty.</span>")
			return
		left.active_effect(A)
	else
		if(!right)
			to_chat(usr, "<span class='warning'>WARNING! Hardpoint is empty.</span>")
			return
		right.active_effect(A)

/obj/vehicle/walker/proc/firing_arc(var/atom/A)
	var/turf/T = get_turf(A)
	var/dx = T.x - x
	var/dy = T.y - y
	var/deg = 0
	switch(dir)
		if(EAST) deg = 0
		if(NORTH) deg = -90
		if(WEST) deg = -180
		if(SOUTH) deg = -270

	var/nx = dx * cos(deg) - dy * sin(deg)
	var/ny = dx * sin(deg) + dy * cos(deg)
	if(nx == 0)
		return max_angle >= 180
	var/angle = arctan(ny/nx)
	if(nx < 0)
		angle += 180
	return abs(angle) <= max_angle

/obj/vehicle/walker/verb/zoom()
	set name = "Zoom on/off"
	set category = "Walker Interface"
	set src = usr.loc

	zoom_activate()

/obj/vehicle/walker/proc/zoom_activate()
	if(zoom)
		pilot.client.change_view(world.view)//world.view - default mob view size
		zoom = FALSE
	else
		pilot.client.change_view(world.view)//world.view - default mob view size
		pilot.client.change_view(zoom_size)
		pilot << sound('sound/mecha/imag_enhsyndi.ogg',volume=50)
		zoom = TRUE
	to_chat(pilot, "Notification. Cameras zooming [zoom ? "activated" : "deactivated"].")




/////////////////
// Attackby
/////////////////

/obj/vehicle/walker/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/ammo_magazine/walker))
		var/obj/item/ammo_magazine/walker/mag = W
		rearm(mag, user)

	if(istype(W, /obj/item/mortal_shell/he))
		var/obj/item/mortal_shell/he/SH = W
		rearm_mortar(SH, user)


	else if(istype(W, /obj/item/walker_gun))
		var/obj/item/walker_gun/WG = W
		install_gun(WG, user)

	else if(iswelder(W))
		var/obj/item/tool/weldingtool/weld = W
		repair_walker(weld, user)

	else if(istype(W, /obj/item/walker_armor))
		var/obj/item/walker_armor/AR = W
		install_armor(AR,user)

	else if(iswrench(W))
		var/obj/item/tool/wrench/WR = W
		dismount(WR, user)

	else
		. = ..()

/obj/vehicle/walker/proc/install_armor(obj/item/walker_armor/W, mob/user as mob)
	if(user.mind?.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_MT)
		to_chat(user, "You don't know how to mount armor.")
		return

	if(armor_module)
		to_chat(user, "This hardpoint is full")
		return

	to_chat(user, "You start mounting [W.name] on armor hardpoint.")
	if(do_after(user, 100, TRUE, src, BUSY_ICON_BUILD))
		user.drop_held_item()
		W.loc = src
		armor_module = W
		armor_module.owner = src
		armor_module.apply_effect()
		update_icon()

/obj/vehicle/walker/proc/install_gun(obj/item/walker_gun/W, mob/user as mob)
	if(user.mind?.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_MT)
		to_chat(user, "You don't know how to mount weapon.")
		return
	var/choice = input("On which hardpoint install gun.") in list("Left", "Right", "Cancel")
	switch(choice)
		if("Cancel")
			return

		if("Left")
			if(left)
				to_chat(user, "This hardpoint is full")
				return
			to_chat(user, "You start mounting [W.name] on left hardpoint.")
			if(do_after(user, 100, TRUE, src, BUSY_ICON_BUILD))
				user.drop_held_item()
				W.loc = src
				left = W
				left.owner = src
				to_chat(user, "You mount [W.name] on left hardpoint.")
				update_icon()
				return
			return

		if("Right")
			if(right)
				to_chat(user, "This hardpoint is full")
				return
			to_chat(user, "You start mounting [W.name] on right hardpoint.")
			if(do_after(user, 100, TRUE, src, BUSY_ICON_BUILD))
				user.drop_held_item()
				W.loc = src
				right = W
				right.owner = src
				to_chat(user, "You mount [W] on right hardpoint.")
				update_icon()
				return
			return

/obj/vehicle/walker/proc/rearm(obj/item/ammo_magazine/walker/mag  as obj, mob/user as mob)
	if(istype(mag, left.magazine_type) && left && !left.ammo)
		if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
			to_chat(user, "Your action was interrupted.")
			return
		user.drop_held_item()
		mag.loc = left
		left.ammo = mag
		to_chat(user, "You install magazine in [left.name].")
		return

	else if(istype(mag, right.magazine_type) && right && !right.ammo)
		if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
			to_chat(user, "Your action was interrupted.")
			return
		user.drop_held_item()
		mag.loc = right
		right.ammo = mag
		to_chat(user, "You install magazine in [right.name].")
		return

	else
		to_chat(user, "You cannot fit that magazine in any weapon.")
		return


/obj/vehicle/walker/proc/rearm_mortar(obj/item/mortal_shell/he/shell  as obj, mob/user as mob)
	if(!armor_module)
		to_chat(user, "Mortar module wasn't installed!")
		return

	if(!istype(armor_module, /obj/item/walker_armor/mortar))
		to_chat(user, "Mortar module wasn't installed!")
		return

	var/obj/item/walker_armor/mortar/mr = armor_module
	if(mr.shells == mr.max_shells)
		to_chat(user, "Mortar module is full!")
		return

	if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
		to_chat(user, "Your action was interrupted.")
		return
	mr.shells++
	user.drop_held_item()
	qdel(shell)

/obj/vehicle/walker/proc/dismount(obj/item/tool/wrench/WR  as obj, mob/user as mob)
	if(!left && !right)
		return
	var/choice = input("Which hardpoint should be dismounted.") in list("Left", "Right", "Armor", "Cancel")
	switch(choice)
		if("Cancel")
			return

		if("Left")
			if(!left)
				to_chat(user, "Left hardpoint is empty.")
				return
			to_chat(user, "You start dismounting [left.name] from walker.")
			if(do_after(user, 100, TRUE, src, BUSY_ICON_BUILD))
				left.loc = loc
				left.owner = null
				left = null
				update_icon()
				return
			else
				to_chat(user, "Dismounting has been interrupted.")

		if("Right")
			if(!right)
				to_chat(user, "Right hardpoint is empty.")
				return
			to_chat(user, "You start dismounting [right.name] from walker.")
			if(do_after(user, 100, TRUE, src, BUSY_ICON_BUILD))
				right.loc = loc
				right.owner = null
				right = null
				update_icon()
				return
			else
				to_chat(user, "Dismounting has been interrupted.")

		if("Armor")
			if(!armor_module)
				to_chat(user, "Armor hardpoint is empty.")
				return
			to_chat(user, "You start dismounting [armor_module.name] from walker.")
			if(do_after(user, 100, TRUE, src, BUSY_ICON_BUILD))
				armor_module.loc = loc
				armor_module.remove_effect()
				armor_module.owner = null
				armor_module = null
				update_icon()
				return
			else
				to_chat(user, "Dismounting has been interrupted.")

/obj/vehicle/walker/proc/repair_walker(obj/item/tool/weldingtool/weld  as obj, mob/user as mob)
	if(!weld.isOn())
		return
	if(obj_integrity >= max_integrity)
		to_chat(user, "Armor seems fully intact.")
		return
	if(repair)
		to_chat(user, "Someone already reparing this vehicle.")
		return
	repair = TRUE
	var/repair_time = 1000
	if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer > SKILL_ENGINEER_DEFAULT)		//NO DIVIDING BY ZERO
		/*
		Small explanation
		If engineering skill is default or SKILL_ENGINEER_METAL - 100 seconds
		SKILL_ENGINEER_PLASTEEL - 50 seconds
		SKILL_ENGINEER_ENGI - 33
		SKILL_ENGINEER_MT - 25
		*/
		repair_time = round(repair_time/user.mind.cm_skills.engineer)

	to_chat(user, "You start repairing broken part of [src.name]'s armor...")
	if(do_after(user, repair_time, TRUE, src, BUSY_ICON_BUILD))
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer <= SKILL_ENGINEER_ENGI)
			to_chat(user, "You haphazardly weld together chunks of broken armor.")
			obj_integrity += 25
			healthcheck()
		else
			obj_integrity += 100
			healthcheck()
			to_chat(user, "You repair broken part of the armor.")
		playsound(src.loc, 'sound/items/weldingtool_weld.ogg', 25)
		if(pilot)
			to_chat(pilot, "Notification.Armor partly restored.")
		return
	else
		to_chat(user, "Repair has been interrupted.")
	repair = FALSE


/////////
//Attack_alien
/////////

/obj/vehicle/walker/attack_alien(mob/living/carbon/xenomorph/M)
	if(M.a_intent == INTENT_HARM)
		M.do_attack_animation(src)
		playsound(loc, "alien_claw_metal", 25, 1)
		M.flick_attack_overlay(src, "slash")
		M.visible_message("<span class='danger'>[M] slashes [src].</span>","<span class='danger'>You slash [src].</span>", null, 5)
		take_damage(rand(M.xeno_caste.melee_damage_lower, M.xeno_caste.melee_damage_upper), "slash", M.dir)
	else
		attack_hand(M)

/obj/vehicle/walker/healthcheck()
	if(obj_integrity > max_integrity)
		obj_integrity = max_integrity
		return
	if(obj_integrity <= 0)
		move_out()
		new /obj/structure/walker_wreckage(src.loc)
		playsound(loc, 'sound/effects/metal_crash.ogg', 75)
		qdel(src)

/obj/vehicle/walker/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)
		return

	switch(Proj.ammo.damage_type)
		if(BRUTE)
			if(Proj.ammo.flags_ammo_behavior & AMMO_ROCKET)
				take_damage(Proj.damage, "explosive", Proj.dir)
			else
				take_damage(Proj.damage, "bullet", Proj.dir)
		if(BURN)
			if(Proj.ammo.flags_ammo_behavior & AMMO_XENO_ACID)
				take_damage(Proj.damage, "acid", Proj.dir)
			else
				take_damage(Proj.damage, "energy", Proj.dir)
		if(TOX, OXY, CLONE)
			return

/obj/vehicle/walker/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_ACID))
		take_damage(rand(10,30), "acid")

/obj/vehicle/walker/proc/take_damage(dam, damtype = "blunt", hit_dir=null)
	if(!dam || dam <= 0)
		return
	if(!(damtype in list("explosive", "acid", "energy", "blunt", "slash", "bullet", "all", "abstract")))
		return
	// Applying multiplier and then substract theshold
	// Attacking from behind add damage
	var/damage = dam * max(0, dmg_multipliers[damtype]) - get_damage_threshold(hit_dir)
	if(damage <= 0)
		to_chat(pilot, "<span class='danger'>ALERT! Hostile incursion detected. Deflected.</span>")
		return

	obj_integrity -= damage
	to_chat(pilot, "<span class='danger'>ALERT! Hostile incursion detected. Chassis taking damage.</span>")
	if(pilot && damage >= 50)
		pilot << sound('sound/mecha/critdestrsyndi.ogg',volume=50)
	healthcheck()

/obj/vehicle/walker/proc/get_damage_threshold(hit_dir=null)
	if(!(hit_dir in CARDINAL_ALL_DIRS))
		return DAMAGE_THRESHOLD_STANDART

	if(reverse_direction(dir) == hit_dir)
		return damage_threshold["face"]

	var/list/faceflank
	var/list/flank
	var/list/back

	switch(dir)
		if(NORTH)
			faceflank = list(SOUTHEAST, SOUTHWEST)
			flank = list(WEST,EAST)
			back = list(NORTHEAST, NORTHWEST, NORTH)

		if(SOUTH)
			faceflank = list(NORTHEAST, NORTHWEST)
			flank = list(WEST,EAST)
			back = list(SOUTHEAST, SOUTHWEST, SOUTH)

		if(EAST)
			faceflank = list(NORTHWEST, SOUTHWEST)
			flank = list(NORTH, SOUTH)
			back = list(NORTHEAST, SOUTHEAST, EAST)

		if(WEST)
			faceflank = list(NORTHEAST, SOUTHEAST)
			flank = list(NORTH, SOUTH)
			back = list(NORTHWEST, SOUTHWEST, WEST)

	if(hit_dir in faceflank)
		return damage_threshold["faceflank"]
	if(hit_dir in flank)
		return damage_threshold["flank"]
	if(hit_dir in back)
		return damage_threshold["back"]

#undef GUN_RIGHT
#undef GUN_LEFT

#undef DAMAGE_THRESHOLD_STANDART

/obj/structure/walker_wreckage
	name = "CW13 wreckage"
	desc = "Remains of some unfortunate walker. Completely unrepairable."
	icon = 'RU-TGMC/icons/obj/vehicles/mech-walker.dmi'
	icon_state = "mech-damaged"
	density = TRUE
	anchored = TRUE
	opacity = FALSE
	pixel_x = -18