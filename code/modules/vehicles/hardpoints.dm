/*
All of the hardpoints, for the tank or other
Currently only has the tank hardpoints
*/


/obj/item/hardpoint

	var/slot //What slot do we attach to?
	var/obj/vehicle/multitile/root/cm_armored/owner //Who do we work for?

	icon = 'icons/obj/hardpoint_modules.dmi'
	icon_state = "tires" //Placeholder

	health = 100
	w_class = 15

	//If we use ammo, put it here
	var/obj/item/ammo_magazine/ammo = null

	//Strings, used to get the overlay for the armored vic
	var/disp_icon //This also differentiates tank vs apc vs other
	var/disp_icon_state

	var/next_use = 0
	var/is_activatable = 0
	var/max_angle = 180

	var/list/backup_clips = list()
	var/max_clips = 1 //1 so they can reload their backups and actually reload once

//Called on attaching, for weapons sets the actual cooldowns
/obj/item/hardpoint/proc/apply_buff()
	return

//Called when removing, resets cooldown lengths, move delay, etc
/obj/item/hardpoint/proc/remove_buff()
	return

//Called when you want to activate the hardpoint, such as a gun
//This can also be used for some type of temporary buff, up to you
/obj/item/hardpoint/proc/active_effect(var/turf/T)
	return

/obj/item/hardpoint/proc/deactivate()
	return

/obj/item/hardpoint/proc/livingmob_interact(var/mob/living/M)
	return

//If our cooldown has elapsed
/obj/item/hardpoint/proc/is_ready()
	if(owner.z == 2 || owner.z == 3)
		usr << "<span class='warning'>Don't fire here, you'll blow a hole in the ship!</span>"
		return 0
	return 1

/obj/item/hardpoint/proc/try_add_clip(var/obj/item/ammo_magazine/A, var/mob/user)

	if(max_clips == 0)
		user << "<span class='warning'>This module does not have room for additional ammo.</span>"
		return 0
	else if(backup_clips.len >= max_clips)
		user << "<span class='warning'>The reloader is full.</span>"
		return 0
	else if(!istype(A, ammo.type))
		user << "<span class='warning'>That is the wrong ammo type.</span>"
		return 0

	user << "<span class='notice'>Installing \the [A] in \the [owner].</span>"

	if(!do_after(user, 10))
		user << "<span class='warning'>Something interrupted you while reloading [owner].</span>"
		return 0

	user.temp_drop_inv_item(A, 0)
	user << "<span class='notice'>You install \the [A] in \the [owner].</span>"
	backup_clips += A
	return 1

//Returns the image object to overlay onto the root object
/obj/item/hardpoint/proc/get_icon_image(var/x_offset, var/y_offset, var/new_dir)

	var/icon_suffix = "NS"
	var/icon_state_suffix = "0"

	if(new_dir in list(NORTH, SOUTH))
		icon_suffix = "NS"
	else if(new_dir in list(EAST, WEST))
		icon_suffix = "EW"

	if(health <= 0)
		icon_state_suffix = "1"

	return image(icon = "[disp_icon]_[icon_suffix]", icon_state = "[disp_icon_state]_[icon_state_suffix]", pixel_x = x_offset, pixel_y = y_offset)

/obj/item/hardpoint/proc/firing_arc(var/atom/A)
	var/turf/T = get_turf(A)
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
	if(nx == 0) return max_angle >= 90
	var/angle = arctan(ny/nx)
	if(nx < 0) angle += 180
	return abs(angle) <= max_angle

//Delineating between slots
/obj/item/hardpoint/primary
	slot = HDPT_PRIMARY
	is_activatable = 1

/obj/item/hardpoint/secondary
	slot = HDPT_SECDGUN
	is_activatable = 1

/obj/item/hardpoint/support
	slot = HDPT_SUPPORT

/obj/item/hardpoint/armor
	slot = HDPT_ARMOR

/obj/item/hardpoint/treads
	slot = HDPT_TREADS

////////////////////
// PRIMARY SLOTS // START
////////////////////

/obj/item/hardpoint/primary/cannon
	name = "LTB Cannon"
	desc = "A primary cannon for tanks that shoots explosive rounds"

	health = 500

	icon_state = "ltb_cannon"

	disp_icon = "tank"
	disp_icon_state = "ltb_cannon"

	ammo = new /obj/item/ammo_magazine/tank/ltb_cannon
	max_clips = 3
	max_angle = 45

	apply_buff()
		owner.cooldowns["primary"] = 200
		owner.accuracies["primary"] = 0.97

	is_ready()
		if(world.time < next_use)
			usr << "<span class='warning'>This module is not ready to be used yet.</span>"
			return 0
		if(health <= 0)
			usr << "<span class='warning'>This module is too broken to be used.</span>"
			return 0
		return 1

	active_effect(var/turf/T)

		if(ammo.current_rounds <= 0)
			usr << "<span class='warning'>This module does not have any ammo.</span>"
			return

		next_use = world.time + owner.cooldowns["primary"] * owner.misc_ratios["prim_cool"]
		if(!prob(owner.accuracies["primary"] * 100 * owner.misc_ratios["prim_acc"]))
			T = get_step(T, pick(cardinal))
		var/obj/item/projectile/P = new
		P.generate_bullet(new ammo.default_ammo)
		P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
		playsound(get_turf(src), pick('sound/weapons/tank_cannon_fire1.ogg', 'sound/weapons/tank_cannon_fire2.ogg'), 60, 1)
		ammo.current_rounds--

/obj/item/hardpoint/primary/minigun
	name = "LTAA-AP Minigun"
	desc = "A primary weapon for tanks that spews bullets"

	health = 350

	icon_state = "ltaaap_minigun"

	disp_icon = "tank"
	disp_icon_state = "ltaaap_minigun"

	ammo = new /obj/item/ammo_magazine/tank/ltaaap_minigun
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

	apply_buff()
		owner.cooldowns["primary"] = 2 //will be overridden, please ignore
		owner.accuracies["primary"] = 0.33

	is_ready()
		if(world.time < next_use)
			usr << "<span class='warning'>This module is not ready to be used yet.</span>"
			return 0
		if(health <= 0)
			usr << "<span class='warning'>This module is too broken to be used.</span>"
			return 0
		return 1

	active_effect(var/turf/T)

		if(ammo.current_rounds <= 0)
			usr << "<span class='warning'>This module does not have any ammo.</span>"
			return

		var/S = 'sound/weapons/tank_minigun_start.ogg'
		if(world.time - next_use <= 5)
			chained++ //minigun spins up, minigun spins down
			S = 'sound/weapons/tank_minigun_loop.ogg'
		else if(world.time - next_use >= 15) //Too long of a delay, they restart the chain
			chained = 1
		else //In between 5 and 15 it slows down but doesn't stop
			chained--
			S = 'sound/weapons/tank_minigun_stop.ogg'
		if(chained <= 0) chained = 1

		next_use = world.time + (chained > chain_delays.len ? 0.5 : chain_delays[chained]) * owner.misc_ratios["prim_cool"]
		if(!prob(owner.accuracies["primary"] * 100 * owner.misc_ratios["prim_acc"]))
			T = get_step(T, pick(cardinal))
		var/obj/item/projectile/P = new
		P.generate_bullet(new ammo.default_ammo)
		P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)

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

	health = 300

	icon_state = "flamer"

	disp_icon = "tank"
	disp_icon_state = "flamer"

	ammo = new /obj/item/ammo_magazine/tank/flamer
	max_angle = 90

	apply_buff()
		owner.cooldowns["secondary"] = 20
		owner.accuracies["secondary"] = 0.5

	is_ready()
		if(world.time < next_use)
			usr << "<span class='warning'>This module is not ready to be used yet.</span>"
			return 0
		if(health <= 0)
			usr << "<span class='warning'>This module is too broken to be used.</span>"
			return 0
		return 1

	active_effect(var/turf/T)

		if(ammo.current_rounds <= 0)
			usr << "<span class='warning'>This module does not have any ammo.</span>"
			return

		next_use = world.time + owner.cooldowns["secondary"] * owner.misc_ratios["secd_cool"]
		if(!prob(owner.accuracies["secondary"] * 100 * owner.misc_ratios["secd_acc"]))
			T = get_step(T, pick(cardinal))
		var/obj/item/projectile/P = new
		P.generate_bullet(new ammo.default_ammo)
		P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
		playsound(get_turf(src), 'sound/weapons/tank_flamethrower.ogg', 60, 1)
		ammo.current_rounds--

/obj/item/hardpoint/secondary/towlauncher
	name = "TOW Launcher"
	desc = "A secondary weapon for tanks that shoots rockets"

	health = 500

	icon_state = "tow_launcher"

	disp_icon = "tank"
	disp_icon_state = "towlauncher"

	ammo = new /obj/item/ammo_magazine/tank/towlauncher
	max_clips = 1
	max_angle = 90

	apply_buff()
		owner.cooldowns["secondary"] = 150
		owner.accuracies["secondary"] = 0.8

	is_ready()
		if(world.time < next_use)
			usr << "<span class='warning'>This module is not ready to be used yet.</span>"
			return 0
		if(health <= 0)
			usr << "<span class='warning'>This module is too broken to be used.</span>"
			return 0
		return 1

	active_effect(var/turf/T)

		if(ammo.current_rounds <= 0)
			usr << "<span class='warning'>This module does not have any ammo.</span>"
			return

		next_use = world.time + owner.cooldowns["secondary"] * owner.misc_ratios["secd_cool"]
		if(!prob(owner.accuracies["secondary"] * 100 * owner.misc_ratios["secd_acc"]))
			T = get_step(T, pick(cardinal))
		var/obj/item/projectile/P = new
		P.generate_bullet(new ammo.default_ammo)
		P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
		ammo.current_rounds--

/obj/item/hardpoint/secondary/m56cupola
	name = "M56 Cupola"
	desc = "A secondary weapon for tanks that shoots bullets"

	health = 350

	icon_state = "m56_cupola"

	disp_icon = "tank"
	disp_icon_state = "m56cupola"

	ammo = new /obj/item/ammo_magazine/tank/m56_cupola
	max_clips = 1
	max_angle = 90

	apply_buff()
		owner.cooldowns["secondary"] = 5
		owner.accuracies["secondary"] = 0.7

	is_ready()
		if(world.time < next_use)
			usr << "<span class='warning'>This module is not ready to be used yet.</span>"
			return 0
		if(health <= 0)
			usr << "<span class='warning'>This module is too broken to be used.</span>"
			return 0
		return 1

	active_effect(var/turf/T)

		if(ammo.current_rounds <= 0)
			usr << "<span class='warning'>This module does not have any ammo.</span>"
			return

		next_use = world.time + owner.cooldowns["secondary"] * owner.misc_ratios["secd_cool"]
		if(!prob(owner.accuracies["secondary"] * 100 * owner.misc_ratios["secd_acc"]))
			T = get_step(T, pick(cardinal))
		var/obj/item/projectile/P = new
		P.generate_bullet(new ammo.default_ammo)
		P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
		playsound(get_turf(src), pick(list('sound/weapons/gun_smartgun1.ogg', 'sound/weapons/gun_smartgun2.ogg', 'sound/weapons/gun_smartgun3.ogg')), 60, 1)
		ammo.current_rounds--

/obj/item/hardpoint/secondary/grenade_launcher
	name = "Grenade Launcher"
	desc = "A secondary weapon for tanks that shoots grenades"

	health = 500

	icon_state = "glauncher"

	disp_icon = "tank"
	disp_icon_state = "glauncher"

	ammo = new /obj/item/ammo_magazine/tank/tank_glauncher
	max_clips = 3
	max_angle = 90

	apply_buff()
		owner.cooldowns["secondary"] = 30
		owner.accuracies["secondary"] = 0.4

	is_ready()
		if(world.time < next_use)
			usr << "<span class='warning'>This module is not ready to be used yet.</span>"
			return 0
		if(health <= 0)
			usr << "<span class='warning'>This module is too broken to be used.</span>"
			return 0
		return 1

	active_effect(var/turf/T)

		if(ammo.current_rounds <= 0)
			usr << "<span class='warning'>This module does not have any ammo.</span>"
			return

		next_use = world.time + owner.cooldowns["secondary"] * owner.misc_ratios["secd_cool"]
		if(!prob(owner.accuracies["secondary"] * 100 * owner.misc_ratios["secd_acc"]))
			T = get_step(T, pick(cardinal))
		var/obj/item/projectile/P = new
		P.generate_bullet(new ammo.default_ammo)
		P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
		playsound(get_turf(src), 'sound/weapons/gun_m92_attachable.ogg', 60, 1)
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

	health = 300

	icon_state = "slauncher_0"

	disp_icon = "tank"
	disp_icon_state = "slauncher"

	ammo = new /obj/item/ammo_magazine/tank/tank_slauncher
	max_clips = 4
	is_activatable = 1

	apply_buff()
		owner.cooldowns["support"] = 30
		owner.accuracies["support"] = 0.8

	is_ready()
		if(world.time < next_use)
			usr << "<span class='warning'>This module is not ready to be used yet.</span>"
			return 0
		if(health <= 0)
			usr << "<span class='warning'>This module is too broken to be used.</span>"
			return 0
		return 1

	active_effect(var/turf/T)

		if(ammo.current_rounds <= 0)
			usr << "<span class='warning'>This module does not have any ammo.</span>"
			return

		next_use = world.time + owner.cooldowns["support"] * owner.misc_ratios["supp_cool"]
		if(!prob(owner.accuracies["support"] * 100 * owner.misc_ratios["supp_acc"]))
			T = get_step(T, pick(cardinal))
		var/obj/item/projectile/P = new
		P.generate_bullet(new ammo.default_ammo)
		P.fire_at(T, owner, src, P.ammo.max_range, P.ammo.shell_speed)
		playsound(get_turf(src), 'sound/weapons/tank_smokelauncher_fire.ogg', 60, 1)
		ammo.current_rounds--

	get_icon_image(var/x_offset, var/y_offset, var/new_dir)

		var/icon_suffix = "NS"
		var/icon_state_suffix = "0"

		if(new_dir in list(NORTH, SOUTH))
			icon_suffix = "NS"
		else if(new_dir in list(EAST, WEST))
			icon_suffix = "EW"

		if(health <= 0) icon_state_suffix = "1"
		else if(ammo.current_rounds <= 0) icon_state_suffix = "2"

		return image(icon = "[disp_icon]_[icon_suffix]", icon_state = "[disp_icon_state]_[icon_state_suffix]", pixel_x = x_offset, pixel_y = y_offset)

/obj/item/hardpoint/support/weapons_sensor
	name = "Integrated Weapons Sensor Array"
	desc = "Improves the accuracy and fire rate of all onboard weapons"

	health = 250

	icon_state = "warray"

	disp_icon = "tank"
	disp_icon_state = "warray"

	apply_buff()
		owner.misc_ratios["prim_cool"] = 0.67
		owner.misc_ratios["secd_cool"] = 0.67
		owner.misc_ratios["supp_cool"] = 0.67

		owner.misc_ratios["prim_acc"] = 1.67
		owner.misc_ratios["secd_acc"] = 1.67
		owner.misc_ratios["supp_acc"] = 1.67

	remove_buff()
		owner.misc_ratios["prim_cool"] = 1.0
		owner.misc_ratios["secd_cool"] = 1.0
		owner.misc_ratios["supp_cool"] = 1.0

		owner.misc_ratios["prim_acc"] = 1.0
		owner.misc_ratios["secd_acc"] = 1.0
		owner.misc_ratios["supp_acc"] = 1.0

/obj/item/hardpoint/support/overdrive_enhancer
	name = "Overdrive Enhancer"
	desc = "Increases the movement speed of the vehicle it's atached to"

	health = 250

	icon_state = "odrive_enhancer"

	disp_icon = "tank"
	disp_icon_state = "odrive_enhancer"

	apply_buff()
		owner.misc_ratios["move"] = 0.5

	remove_buff()
		owner.misc_ratios["move"] = 1.0

/obj/item/hardpoint/support/artillery_module
	name = "Artillery Module"
	desc = "Allows the gunner to look far into the distance."

	health = 250
	is_activatable = 1
	var/is_active = 0

	var/view_buff = 12 //This way you can VV for more or less fun
	var/view_tile_offset = 5

	icon_state = "artillery"

	disp_icon = "tank"
	disp_icon_state = "artillerymod"

	active_effect(var/turf/T)
		var/obj/vehicle/multitile/root/cm_armored/tank/C = owner
		if(!C.gunner) return
		var/mob/M = C.gunner
		if(!M.client) return
		if(is_active)
			M.client.change_view(7)
			M.client.pixel_x = 0
			M.client.pixel_y = 0
			is_active = 0
			return
		M.client.change_view(view_buff)
		is_active = 1
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

	deactivate()
		var/obj/vehicle/multitile/root/cm_armored/tank/C = owner
		if(!C.gunner) return
		var/mob/M = C.gunner
		if(!M.client) return
		is_active = 0
		M.client.change_view(7)
		M.client.pixel_x = 0
		M.client.pixel_y = 0

	remove_buff()
		deactivate()

	is_ready()
		return 1

///////////////////
// SUPPORT SLOTS // END
///////////////////

/////////////////
// ARMOR SLOTS // START
/////////////////

/obj/item/hardpoint/armor/ballistic
	name = "Ballistic Armor"
	desc = "Protects the vehicle from high-penetration weapons"

	health = 1000

	icon_state = "ballistic_armor"

	disp_icon = "tank"
	disp_icon_state = "ballistic_armor"

	apply_buff()
		owner.dmg_multipliers["bullet"] = 0.67
		owner.dmg_multipliers["slash"] = 0.67
		owner.dmg_multipliers["all"] = 0.9

	remove_buff()
		owner.dmg_multipliers["bullet"] = 1.0
		owner.dmg_multipliers["slash"] = 1.0
		owner.dmg_multipliers["all"] = 1.0

/obj/item/hardpoint/armor/caustic
	name = "Caustic Armor"
	desc = "Protects vehicles from most types of acid"

	health = 1000

	icon_state = "caustic_armor"

	disp_icon = "tank"
	disp_icon_state = "caustic_armor"

	apply_buff()
		owner.dmg_multipliers["acid"] = 0.67
		owner.dmg_multipliers["all"] = 0.9

	remove_buff()
		owner.dmg_multipliers["acid"] = 1.0
		owner.dmg_multipliers["all"] = 1.0

/obj/item/hardpoint/armor/concussive
	name = "Concussive Armor"
	desc = "Protects the vehicle from high-impact weapons"

	health = 1000

	icon_state = "concussive_armor"

	disp_icon = "tank"
	disp_icon_state = "concussive_armor"

	apply_buff()
		owner.dmg_multipliers["blunt"] = 0.67
		owner.dmg_multipliers["all"] = 0.9

	remove_buff()
		owner.dmg_multipliers["blunt"] = 1.0
		owner.dmg_multipliers["all"] = 1.0

/obj/item/hardpoint/armor/paladin
	name = "Paladin Armor"
	desc = "Protects the vehicle from large incoming explosive projectiles"

	health = 1000

	icon_state = "paladin_armor"

	disp_icon = "tank"
	disp_icon_state = "paladin_armor"

	apply_buff()
		owner.dmg_multipliers["explosive"] = 0.67
		owner.dmg_multipliers["all"] = 0.9

	remove_buff()
		owner.dmg_multipliers["explosive"] = 1.0
		owner.dmg_multipliers["all"] = 1.0

/obj/item/hardpoint/armor/snowplow
	name = "Snowplow"
	desc = "Clears a path in the snow for friendlies"

	health = 600
	is_activatable = 1

	icon_state = "snowplow"

	disp_icon = "tank"
	disp_icon_state = "snowplow"

	livingmob_interact(var/mob/living/M)
		var/turf/targ = get_step(M, owner.dir)
		targ = get_step(M, owner.dir)
		targ = get_step(M, owner.dir)
		M.throw_at(targ, 4, 2, src, 1)
		M.apply_damage(7 + rand(0, 3), BRUTE)

/////////////////
// ARMOR SLOTS // END
/////////////////

/////////////////
// TREAD SLOTS // START
/////////////////

/obj/item/hardpoint/treads/standard
	name = "Treads"
	desc = "Integral to the movement of the vehicle"

	health = 500

	icon_state = "treads"

	disp_icon = "tank"
	disp_icon_state = "treads"

	get_icon_image(var/x_offset, var/y_offset, var/new_dir)
		return null //Handled in update_icon()

	apply_buff()
		owner.move_delay = 7

	remove_buff()
		owner.move_delay = 30

/////////////////
// TREAD SLOTS // END
/////////////////


///////////////
// AMMO MAGS // START
///////////////

//Special ammo magazines for hardpoint modules. Some aren't here since you can use normal magazines on them
/obj/item/ammo_magazine/tank
	flags_magazine = 0 //No refilling

/obj/item/ammo_magazine/tank/ltb_cannon
	name = "LTB Cannon Magazine"
	desc = "A primary armament cannon magazine"
	caliber = "86mm" //Making this unique on purpose
	icon_state = "ltbcannon_4"
	w_class = 15 //Heavy fucker
	default_ammo = /datum/ammo/rocket/ltb
	max_rounds = 4
	gun_type = /obj/item/hardpoint/primary/cannon

	update_icon()
		icon_state = "ltbcannon_[current_rounds]"


/obj/item/ammo_magazine/tank/ltaaap_minigun
	name = "LTAA-AP Minigun Magazine"
	desc = "A primary armament minigun magazine"
	caliber = "7.62x51mm" //Correlates to miniguns
	icon_state = "painless"
	default_ammo = /datum/ammo/bullet/minigun
	max_rounds = 300
	gun_type = /obj/item/hardpoint/primary/minigun


/obj/item/ammo_magazine/tank/flamer
	name = "Flamer Magazine"
	desc = "A secondary armament flamethrower magazine"
	caliber = "UT-Napthal Fuel" //correlates to flamer mags
	icon_state = "flametank_large"
	w_class = 12
	default_ammo = /datum/ammo/flamethrower/tank_flamer
	max_rounds = 120
	gun_type = /obj/item/hardpoint/secondary/flamer


/obj/item/ammo_magazine/tank/towlauncher
	name = "TOW Launcher Magazine"
	desc = "A secondary armament rocket magazine"
	caliber = "rocket" //correlates to any rocket mags
	icon_state = "quad_rocket"
	w_class = 10
	default_ammo = /datum/ammo/rocket/ap //Fun fact, AP rockets seem to be a straight downgrade from normal rockets. Maybe I'm missing something...
	max_rounds = 5
	gun_type = /obj/item/hardpoint/secondary/towlauncher


/obj/item/ammo_magazine/tank/m56_cupola
	name = "M56 Cupola Magazine"
	desc = "A secondary armament MG magazine"
	caliber = "10x28mm" //Correlates to smartguns
	icon_state = "big_ammo_box"
	w_class = 12
	default_ammo = /datum/ammo/bullet/smartgun
	max_rounds = 500
	gun_type = /obj/item/hardpoint/secondary/m56cupola


/obj/item/ammo_magazine/tank/tank_glauncher
	name = "Grenade Launcher Magazine"
	desc = "A secondary armament grenade magazine"
	caliber = "grenade"
	icon_state = "glauncher_2"
	w_class = 9
	default_ammo = /datum/ammo/grenade_container
	max_rounds = 10
	gun_type = /obj/item/hardpoint/secondary/grenade_launcher

	update_icon()
		if(current_rounds >= max_rounds)
			icon_state = "glauncher_2"
		else if(current_rounds <= 0)
			icon_state = "glauncher_0"
		else
			icon_state = "glauncher_1"


/obj/item/ammo_magazine/tank/tank_slauncher
	name = "Smoke Launcher Magazine"
	desc = "A support armament grenade magazine"
	caliber = "grenade"
	icon_state = "slauncher_1"
	w_class = 12
	default_ammo = /datum/ammo/grenade_container/smoke
	max_rounds = 6
	gun_type = /obj/item/hardpoint/support/smoke_launcher

	update_icon()
		icon_state = "slauncher_[current_rounds <= 0 ? "0" : "1"]"

///////////////
// AMMO MAGS // END
///////////////