

/*
Shotguns always start with an ammo buffer and they work by alternating ammo and ammo_buffer1
in order to fire off projectiles. This is only done to enable burst fire for the shotgun.
Consequently, the shotgun should never fire more than three projectiles on burst as that
can cause issues with ammo types getting mixed up during the burst.
*/

/obj/item/weapon/gun/shotgun
	origin_tech = "combat=4;materials=3"
	w_class = 4
	force = 14.0
	caliber = "12 gauge shotgun shells" //codex
	max_shells = 9 //codex
	load_method = SINGLE_CASING //codex
	fire_sound = 'sound/weapons/gun_shotgun.ogg'
	reload_sound = 'sound/weapons/gun_shotgun_shell_insert.ogg'
	cocked_sound = 'sound/weapons/gun_shotgun_reload.ogg'
	var/opened_sound = 'sound/weapons/gun_shotgun_open2.ogg'
	type_of_casings = "shell"
	accuracy_mult = 1.15
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_AMMO_COUNTER
	aim_slowdown = SLOWDOWN_ADS_SHOTGUN
	wield_delay = WIELD_DELAY_NORMAL //Shotguns are really easy to put up to fire, since they are designed for CQC (at least compared to a rifle)
	gun_skill_category = GUN_SKILL_SHOTGUNS

/obj/item/weapon/gun/shotgun/Initialize()
	. = ..()
	replace_tube(current_mag.current_rounds) //Populate the chamber.
	if(flags_gun_features & GUN_SHOTGUN_CHAMBER)
		load_into_chamber()

/obj/item/weapon/gun/shotgun/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/mhigh_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/low_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/low_hit_accuracy_mult) - CONFIG_GET(number/combat_define/hmed_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)
	recoil = CONFIG_GET(number/combat_define/low_recoil_value)
	recoil_unwielded = CONFIG_GET(number/combat_define/high_recoil_value)

/obj/item/weapon/gun/shotgun/update_icon() //Shotguns do not currently have empty states, as they look exactly the same. Other than double barrel.
	return

/obj/item/weapon/gun/shotgun/proc/replace_tube(number_to_replace)
	current_mag.chamber_contents = list()
	current_mag.chamber_contents.len = current_mag.max_rounds
	var/i
	for(i = 1 to current_mag.max_rounds) //We want to make sure to populate the tube.
		current_mag.chamber_contents[i] = i > number_to_replace ? "empty" : current_mag.default_ammo
	current_mag.chamber_position = current_mag.current_rounds //The position is always in the beginning [1]. It can move from there.

/obj/item/weapon/gun/shotgun/proc/add_to_tube(mob/user,selection) //Shells are added forward.
	current_mag.chamber_position++ //We move the position up when loading ammo. New rounds are always fired next, in order loaded.
	current_mag.chamber_contents[current_mag.chamber_position] = selection //Just moves up one, unless the mag is full.
	if(current_mag.current_rounds == 1 && !in_chamber) //The previous proc in the reload() cycle adds ammo, so the best workaround here,
		update_icon()	//This is not needed for now. Maybe we'll have loaded sprites at some point, but I doubt it. Also doesn't play well with double barrel.
		ready_in_chamber()
		cock_gun(user)
	if(user)
		playsound(user, reload_sound, 25, 1)
	return TRUE

/obj/item/weapon/gun/shotgun/proc/empty_chamber(mob/user)
	if(current_mag.current_rounds <= 0)
		if(in_chamber)
			in_chamber = null
			var/obj/item/ammo_magazine/handful/new_handful = retrieve_shell(ammo.type)
			playsound(user, reload_sound, 25, 1)
			new_handful.forceMove(get_turf(src))
		else if(user)
			to_chat(user, "<span class='warning'>[src] is already empty.</span>")
		return

	unload_shell(user)
	if(!current_mag.current_rounds && !in_chamber) update_icon()

/obj/item/weapon/gun/shotgun/proc/unload_shell(mob/user)
	var/obj/item/ammo_magazine/handful/new_handful = retrieve_shell(current_mag.chamber_contents[current_mag.chamber_position])

	if(user)
		user.put_in_hands(new_handful)
		playsound(user, reload_sound, 25, 1)
	else new_handful.loc = get_turf(src)

	current_mag.current_rounds--
	current_mag.chamber_contents[current_mag.chamber_position] = "empty"
	current_mag.chamber_position--
	return 1

		//While there is a much smaller way to do this,
		//this is the most resource efficient way to do it.
/obj/item/weapon/gun/shotgun/proc/retrieve_shell(selection)
	var/obj/item/ammo_magazine/handful/new_handful = new /obj/item/ammo_magazine/handful()
	new_handful.generate_handful(selection, "12g", 5, 1, /obj/item/weapon/gun/shotgun)
	return new_handful

/obj/item/weapon/gun/shotgun/pump/bolt/retrieve_shell(selection)
	var/obj/item/ammo_magazine/handful/new_handful = new /obj/item/ammo_magazine/handful()
	new_handful.generate_handful(selection, "7.62x54mmR", 5, 1, /obj/item/weapon/gun/shotgun)
	return new_handful

/obj/item/weapon/gun/shotgun/proc/check_chamber_position()
	return 1

/obj/item/weapon/gun/shotgun
	reload(mob/user, var/obj/item/ammo_magazine/magazine)
		if(flags_gun_features & GUN_BURST_FIRING)
			return

		if(!magazine || !istype(magazine,/obj/item/ammo_magazine/handful)) //Can only reload with handfuls.
			to_chat(user, "<span class='warning'>You can't use that to reload!</span>")
			return

		if(!check_chamber_position()) //For the double barrel.
			to_chat(user, "<span class='warning'>[src] has to be open!</span>")
			return

		//From here we know they are using shotgun type ammo and reloading via handful.
		//Makes some of this a lot easier to determine.

		var/mag_caliber = magazine.default_ammo //Handfuls can get deleted, so we need to keep this on hand for later.
		if(current_mag.transfer_ammo(magazine,user,1))
			add_to_tube(user,mag_caliber) //This will check the other conditions.

	unload(mob/user)
		if(flags_gun_features & GUN_BURST_FIRING)
			return
		empty_chamber(user)

/obj/item/weapon/gun/shotgun/proc/ready_shotgun_tube()
	if(current_mag.current_rounds > 0)
		ammo = GLOB.ammo_list[current_mag.chamber_contents[current_mag.chamber_position]]
		in_chamber = create_bullet(ammo)
		current_mag.current_rounds--
		current_mag.chamber_contents[current_mag.chamber_position] = "empty"
		current_mag.chamber_position--
		return in_chamber


/obj/item/weapon/gun/shotgun/ready_in_chamber()
	return ready_shotgun_tube()

/obj/item/weapon/gun/shotgun/reload_into_chamber(mob/user)
	if(active_attachable)
		make_casing(active_attachable.type_of_casings)
	else
		make_casing(type_of_casings)
		in_chamber = null

		//Time to move the tube position.
		ready_in_chamber() //We're going to try and reload. If we don't get anything, icon change.
		if(!current_mag.current_rounds && !in_chamber) //No rounds, nothing chambered.
			update_icon()

	return TRUE

/obj/item/weapon/gun/shotgun/get_ammo_type()
	if(!ammo)
		return list("unknown", "unknown")
	else
		return list(ammo.hud_state, ammo.hud_state_empty)

/obj/item/weapon/gun/shotgun/get_ammo_count()
	if(!current_mag)
		return in_chamber ? 1 : 0
	else
		return in_chamber ? (current_mag.current_rounds + 1) : current_mag.current_rounds

//-------------------------------------------------------
//GENERIC MERC SHOTGUN //Not really based on anything.

/obj/item/weapon/gun/shotgun/merc
	name = "custom built shotgun"
	desc = "A cobbled-together pile of scrap and alien wood. Point end towards things you want to die. Has a burst fire feature, as if it needed it."
	icon_state = "cshotgun"
	item_state = "cshotgun"
	max_shells = 5 //codex
	origin_tech = "combat=4;materials=2"
	fire_sound = 'sound/weapons/gun_shotgun_automatic.ogg'
	current_mag = /obj/item/ammo_magazine/internal/shotgun/merc
	attachable_allowed = list(
						/obj/item/attachable/compensator)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_SHOTGUN_CHAMBER|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 21, "under_x" = 17, "under_y" = 14, "stock_x" = 17, "stock_y" = 14)

/obj/item/weapon/gun/shotgun/merc/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/high_fire_delay) * 2
	burst_amount = CONFIG_GET(number/combat_define/low_burst_value)
	burst_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/med_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/med_hit_accuracy_mult) - CONFIG_GET(number/combat_define/hmed_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)
	recoil = CONFIG_GET(number/combat_define/low_recoil_value)
	recoil_unwielded = CONFIG_GET(number/combat_define/high_recoil_value)


/obj/item/weapon/gun/shotgun/merc/examine_ammo_count(mob/user)
	if(in_chamber)
		to_chat(user, "It has a chambered round.")

//-------------------------------------------------------
//TACTICAL SHOTGUN

/obj/item/weapon/gun/shotgun/combat
	name = "\improper MK221 tactical shotgun"
	desc = "The Nanotrasen MK221 Shotgun, a semi-automatic shotgun with a quick fire rate."
	flags_equip_slot = ITEM_SLOT_BACK
	icon_state = "mk221"
	item_state = "mk221"
	origin_tech = "combat=5;materials=4"
	fire_sound = 'sound/weapons/gun_shotgun_automatic.ogg'
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_SHOTGUN_CHAMBER|GUN_AMMO_COUNTER
	current_mag = /obj/item/ammo_magazine/internal/shotgun/combat
	attachable_allowed = list(
						/obj/item/attachable/bayonet,
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/compensator,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/stock/tactical)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 21, "under_x" = 14, "under_y" = 16, "stock_x" = 14, "stock_y" = 16)
	starting_attachment_types = list(/obj/item/attachable/attached_gun/grenade/unremovable/invisible)

/obj/item/weapon/gun/shotgun/combat/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/tacshottie_fire_delay) //one shot every 1.5 seconds.
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/low_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/max_hit_accuracy_mult) //you need to wield this gun for any kind of accuracy
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult) - CONFIG_GET(number/combat_define/tacshottie_damage_mult)  //normalizing gun for vendors; damage reduced by 25% to compensate for faster fire rate; still higher DPS than M37.
	recoil = CONFIG_GET(number/combat_define/low_recoil_value)
	recoil_unwielded = CONFIG_GET(number/combat_define/high_recoil_value)


/obj/item/weapon/gun/shotgun/combat/examine_ammo_count(mob/user)
	if(in_chamber)
		to_chat(user, "It has a chambered round.")

//-------------------------------------------------------
//DOUBLE SHOTTY

/obj/item/weapon/gun/shotgun/double
	name = "double barrel shotgun"
	desc = "A double barreled shotgun of archaic, but sturdy design. Uses 12 Gauge Special slugs, but can only hold 2 at a time."
	flags_equip_slot = ITEM_SLOT_BACK
	icon_state = "dshotgun"
	item_state = "dshotgun"
	max_shells = 2 //codex
	origin_tech = "combat=4;materials=2"
	current_mag = /obj/item/ammo_magazine/internal/shotgun/double
	fire_sound = 'sound/weapons/gun_shotgun_heavy.ogg'
	cocked_sound = null //We don't want this.
	attachable_allowed = list(
						/obj/item/attachable/bayonet,
						/obj/item/attachable/reddot,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/magnetic_harness)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 21,"rail_x" = 15, "rail_y" = 22, "under_x" = 21, "under_y" = 16, "stock_x" = 21, "stock_y" = 16)

/obj/item/weapon/gun/shotgun/double/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	burst_amount = CONFIG_GET(number/combat_define/low_burst_value)
	burst_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/low_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/low_hit_accuracy_mult) - CONFIG_GET(number/combat_define/hmed_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)
	recoil = CONFIG_GET(number/combat_define/low_recoil_value)
	recoil_unwielded = CONFIG_GET(number/combat_define/high_recoil_value)

/obj/item/weapon/gun/shotgun/double/examine_ammo_count(mob/user)
	if(current_mag.chamber_closed)
		to_chat(user, "It's closed.")
	else
		to_chat(user, "It's open with [current_mag.current_rounds] shell\s loaded.")

/obj/item/weapon/gun/shotgun/double/unique_action(mob/user)
	empty_chamber(user)

//Turns out it has some attachments.
/obj/item/weapon/gun/shotgun/double/update_icon()
	icon_state = current_mag.chamber_closed ? copytext(icon_state,1,-2) : icon_state + "_o"

/obj/item/weapon/gun/shotgun/double/check_chamber_position()
	if(current_mag.chamber_closed)
		return
	return TRUE

/obj/item/weapon/gun/shotgun/double/add_to_tube(mob/user,selection) //Load it on the go, nothing chambered.
	current_mag.chamber_position++
	current_mag.chamber_contents[current_mag.chamber_position] = selection
	playsound(user, reload_sound, 25, 1)
	return TRUE

/obj/item/weapon/gun/shotgun/double/able_to_fire(mob/user)
	. = ..()
	if(. && istype(user))
		if(!current_mag.chamber_closed)
			to_chat(user, "<span class='warning'>Close the chamber!</span>")
			return 0

/obj/item/weapon/gun/shotgun/double/empty_chamber(mob/user)
	if(current_mag.chamber_closed) //Has to be closed.
		if(current_mag.current_rounds) //We want to empty out the bullets.
			var/i
			for(i = 1 to current_mag.current_rounds)
				unload_shell(user)
		make_casing(type_of_casings)

	current_mag.chamber_closed = !current_mag.chamber_closed
	update_icon()
	playsound(user, reload_sound, 25, 1)

/obj/item/weapon/gun/shotgun/double/load_into_chamber()
	//Trimming down the unnecessary stuff.
	//This doesn't chamber, creates a bullet on the go.

	if(current_mag.current_rounds > 0)
		ammo = GLOB.ammo_list[current_mag.chamber_contents[current_mag.chamber_position]]
		in_chamber = create_bullet(ammo)
		current_mag.current_rounds--
		return in_chamber
	//We can't make a projectile without a mag or active attachable.

/obj/item/weapon/gun/shotgun/double/make_casing()
	if(current_mag.used_casings)
		. = ..()
		current_mag.used_casings = 0

/obj/item/weapon/gun/shotgun/double/delete_bullet(obj/item/projectile/projectile_to_fire, refund = 0)
	qdel(projectile_to_fire)
	if(refund)
		current_mag.current_rounds++
	return TRUE

/obj/item/weapon/gun/shotgun/double/reload_into_chamber(mob/user)
	in_chamber = null
	current_mag.chamber_contents[current_mag.chamber_position] = "empty"
	current_mag.chamber_position--
	current_mag.used_casings++
	return TRUE


/obj/item/weapon/gun/shotgun/double/sawn
	name = "sawn-off shotgun"
	desc = "A double barreled shotgun whose barrel has been artificially shortened to reduce range but increase damage and spread."
	icon_state = "sshotgun"
	item_state = "sshotgun"
	flags_equip_slot = ITEM_SLOT_BELT
	attachable_allowed = list()
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 20,"rail_x" = 11, "rail_y" = 22, "under_x" = 18, "under_y" = 16, "stock_x" = 18, "stock_y" = 16)

/obj/item/weapon/gun/shotgun/double/sawn/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/mlow_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/low_hit_accuracy_mult) - CONFIG_GET(number/combat_define/hmed_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/low_hit_accuracy_mult) - CONFIG_GET(number/combat_define/hmed_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult) + CONFIG_GET(number/combat_define/high_hit_damage_mult)
	recoil = CONFIG_GET(number/combat_define/med_recoil_value)
	recoil_unwielded = CONFIG_GET(number/combat_define/max_recoil_value)


//-------------------------------------------------------
//PUMP SHOTGUN
//Shotguns in this category will need to be pumped each shot.

/obj/item/weapon/gun/shotgun/pump
	name = "\improper M37A2 pump shotgun"
	desc = "An Armat Battlefield Systems classic design, the M37A2 combines close-range firepower with long term reliability. Requires a pump, which is a Unique Action."
	flags_equip_slot = ITEM_SLOT_BACK
	icon_state = "m37"
	item_state = "m37"
	current_mag = /obj/item/ammo_magazine/internal/shotgun/pump
	fire_sound = 'sound/weapons/gun_shotgun.ogg'
	max_shells = 9
	var/pump_sound = 'sound/weapons/gun_shotgun_pump.ogg'
	var/pump_delay //Higher means longer delay.
	var/recent_pump //world.time to see when they last pumped it.
	var/recent_notice //world.time to see when they last got a notice.
	var/pump_lock = FALSE //Modern shotguns normally lock after being pumped; this lock is undone by pumping or operating the slide release i.e. unloading a shell manually.
	attachable_allowed = list(
						/obj/item/attachable/bayonet,
						/obj/item/attachable/reddot,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/angledgrip,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/compensator,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/attached_gun/flamer,
						/obj/item/attachable/attached_gun/shotgun,
						/obj/item/attachable/stock/shotgun)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 10, "rail_y" = 21, "under_x" = 20, "under_y" = 14, "stock_x" = 20, "stock_y" = 14)

/obj/item/weapon/gun/shotgun/pump/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/med_fire_delay) * 5
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/low_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/low_hit_accuracy_mult) - CONFIG_GET(number/combat_define/hmed_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)
	recoil = CONFIG_GET(number/combat_define/low_recoil_value)
	recoil_unwielded = CONFIG_GET(number/combat_define/high_recoil_value)
	pump_delay = CONFIG_GET(number/combat_define/max_fire_delay) * 2

/obj/item/weapon/gun/shotgun/pump/unique_action(mob/user)
	pump_shotgun(user)

/obj/item/weapon/gun/shotgun/pump/ready_in_chamber() //If there wasn't a shell loaded through pump, this returns null.
	return

//Same as double barrel. We don't want to do anything else here.
/obj/item/weapon/gun/shotgun/pump/add_to_tube(mob/user, selection) //Load it on the go, nothing chambered.
	current_mag.chamber_position++
	current_mag.chamber_contents[current_mag.chamber_position] = selection
	playsound(user, reload_sound, 25, 1)
	return TRUE
	/*
	Moves the ready_in_chamber to it's own proc.
	If the Fire() cycle doesn't find a chambered round with no active attachable, it will return null.
	Which is what we want, since the gun shouldn't fire unless something was chambered.
	*/

//More or less chambers the round instead of load_into_chamber(). Also ejects used casings.
/obj/item/weapon/gun/shotgun/pump/proc/pump_shotgun(mob/user)	//We can't fire bursts with pumps.
	if(world.time < (recent_pump + pump_delay) ) //Don't spam it.
		return
	if(pump_lock)
		if(world.time > recent_notice + CONFIG_GET(number/combat_define/max_fire_delay))
			playsound(user,'sound/weapons/throwtap.ogg', 25, 1)
			to_chat(user,"<span class='warning'><b>[src] has already been pumped, locking the pump mechanism; fire or unload a shell to unlock it.</b></span>")
			recent_notice = world.time
		return

	if(in_chamber) //eject the chambered round
		in_chamber = null
		var/obj/item/ammo_magazine/handful/new_handful = retrieve_shell(ammo.type)
		new_handful.forceMove(get_turf(src))

	ready_shotgun_tube()


	if(current_mag.used_casings)
		current_mag.used_casings--
		make_casing(type_of_casings)

	to_chat(user, "<span class='notice'><b>You pump [src].</b></span>")
	playsound(user, pump_sound, 25, 1)
	recent_pump = world.time
	if(in_chamber) //Lock only if we have ammo loaded.
		pump_lock = TRUE


/obj/item/weapon/gun/shotgun/pump/reload_into_chamber(mob/user)
	if(active_attachable)
		make_casing(active_attachable.type_of_casings)
	else
		pump_lock = FALSE //fired successfully; unlock the pump
		current_mag.used_casings++ //The shell was fired successfully. Add it to used.
		in_chamber = null
		//Time to move the tube position.
		if(!current_mag.current_rounds && !in_chamber)
			update_icon()//No rounds, nothing chambered.

	return TRUE

/obj/item/weapon/gun/shotgun/pump/unload(mob/user)
	if(pump_lock)
		to_chat(user, "<span class='notice'><b>You disengage [src]'s pump lock with the slide release.</b></span>")
		pump_lock = FALSE //we're operating the slide release to unload, thus unlocking the pump
	return ..()

//-------------------------------------------------------
//Based off of the Benelli M3
/obj/item/weapon/gun/shotgun/pump/cmb
	name = "\improper Paladin-12 pump shotgun"
	desc = "A nine-round pump action shotgun. A sporterized version of a classic shotgun used for hunting, home defence and police work, modified and used by Colonial Marshals"
	icon_state = "pal12"
	item_state = "pal12"
	fire_sound = 'sound/weapons/gun_shotgun_small.ogg'
	current_mag = /obj/item/ammo_magazine/internal/shotgun/pump/CMB
	attachable_allowed = list(
						/obj/item/attachable/reddot,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/compensator,
						/obj/item/attachable/scope/mini,
						/obj/item/attachable/magnetic_harness)
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 16,"rail_x" = 14, "rail_y" = 19, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 17)

/obj/item/weapon/gun/shotgun/pump/cmb/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/med_fire_delay) * 6
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/hmed_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/hmed_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/low_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)
	recoil = CONFIG_GET(number/combat_define/low_recoil_value)
	recoil_unwielded = CONFIG_GET(number/combat_define/high_recoil_value)
	pump_delay = CONFIG_GET(number/combat_define/mhigh_fire_delay) * 2

//-------------------------------------------------------
//Based off of the KSG
/obj/item/weapon/gun/shotgun/pump/ksg
	name = "\improper Kronos pump shotgun"
	desc = "A peculiarly designed pump shotgun, featuring a massive magazine well, a compact bullpup design and military attachment compatablity"
	icon_state = "ksg"
	item_state = "ksg"
	fire_sound = 'sound/weapons/gun_shotgun_small.ogg'
	current_mag = /obj/item/ammo_magazine/internal/shotgun/pump/CMB
	attachable_allowed = list(
						/obj/item/attachable/reddot,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/angledgrip,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/compensator,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/attached_gun/flamer,
						/obj/item/attachable/attached_gun/shotgun)
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 18,"rail_x" = 10, "rail_y" = 20, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 17)

/obj/item/weapon/gun/shotgun/pump/ksg/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/med_fire_delay) * 6
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/hmed_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/low_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)
	recoil = CONFIG_GET(number/combat_define/low_recoil_value)
	recoil_unwielded = CONFIG_GET(number/combat_define/high_recoil_value)
	pump_delay = CONFIG_GET(number/combat_define/mhigh_fire_delay) * 2

//------------------------------------------------------
//A hacky bolt action rifle. in here for the "pump" or bolt working action.

/obj/item/weapon/gun/shotgun/pump/bolt
	name = "\improper Mosin Nagant rifle"
	desc = "A mosin nagant rifle, even just looking at it you can feel the cosmoline already."
	icon_state = "mosin"
	item_state = "mosin" //thank you Alterist
	fire_sound = 'sound/weapons/gun_sniper.ogg'
	caliber = "7.62x54mm Rimmed" //codex
	load_method = SINGLE_CASING //codex
	max_shells = 5 //codex
	current_mag = /obj/item/ammo_magazine/internal/shotgun/pump/bolt
	gun_skill_category = GUN_SKILL_RIFLES
	type_of_casings = "cartridge"
	pump_sound = 'sound/weapons/working_the_bolt.ogg'
	attachable_allowed = list(
						/obj/item/attachable/reddot,
						/obj/item/attachable/scope/mini,
						/obj/item/attachable/scope,
						/obj/item/attachable/bayonet)
	attachable_offset = list("muzzle_x" = 50, "muzzle_y" = 21,"rail_x" = 8, "rail_y" = 21, "under_x" = 37, "under_y" = 16, "stock_x" = 20, "stock_y" = 14)
	starting_attachment_types = list(/obj/item/attachable/scope,
									/obj/item/attachable/mosinbarrel,
									/obj/item/attachable/stock/mosin)

/obj/item/weapon/gun/shotgun/pump/bolt/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/med_fire_delay) * 6
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/hmed_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/hmed_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/low_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)
	recoil = CONFIG_GET(number/combat_define/low_recoil_value)
	recoil_unwielded = CONFIG_GET(number/combat_define/high_recoil_value)
	pump_delay = CONFIG_GET(number/combat_define/mhigh_fire_delay) * 2

/obj/item/weapon/gun/shotgun/pump/bolt/unique_action(mob/user)
	work_the_bolt(user)


/obj/item/weapon/gun/shotgun/pump/proc/work_the_bolt(mob/user)	//We can't fire bursts with pumps.
	if(world.time < (recent_pump + pump_delay) ) //Don't spam it.
		return
	if(pump_lock)
		if(world.time > recent_notice + CONFIG_GET(number/combat_define/max_fire_delay))
			playsound(user,'sound/weapons/throwtap.ogg', 25, 1)
			to_chat(user,"<span class='warning'><b>[src]'s bolt has already been worked, locking the action; fire or unload a cartridge to unlock it.</b></span>")
			recent_notice = world.time
		return

	if(in_chamber) //eject the chambered round
		in_chamber = null
		var/obj/item/ammo_magazine/handful/new_handful = retrieve_shell(ammo.type)
		new_handful.forceMove(get_turf(src))

	ready_shotgun_tube()


	if(current_mag.used_casings)
		current_mag.used_casings--
		make_casing(type_of_casings)

	to_chat(user, "<span class='notice'><b>You work [src]'s action.</b></span>")
	playsound(user, pump_sound, 25, 1)
	recent_pump = world.time
	if(in_chamber) //Lock only if we have ammo loaded.
		pump_lock = TRUE


/obj/item/weapon/gun/shotgun/pump/reload_into_chamber(mob/user)
	if(active_attachable)
		make_casing(active_attachable.type_of_casings)
	else
		pump_lock = FALSE //fired successfully; unlock the pump
		current_mag.used_casings++ //The shell was fired successfully. Add it to used.
		in_chamber = null
		//Time to move the tube position.
		if(!current_mag.current_rounds && !in_chamber)
			update_icon()//No rounds, nothing chambered.

	return TRUE

/obj/item/weapon/gun/shotgun/pump/unload(mob/user)
	if(pump_lock)
		to_chat(user, "<span class='notice'><b>You disengage [src]'s bolt lock with the bolt handle.</b></span>")
		pump_lock = FALSE //we're operating the slide release to unload, thus unlocking the pump
	return ..()
