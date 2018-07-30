

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
	fire_sound = 'sound/weapons/gun_shotgun.ogg'
	reload_sound = 'sound/weapons/gun_shotgun_shell_insert.ogg'
	cocked_sound = 'sound/weapons/gun_shotgun_reload.ogg'
	var/opened_sound = 'sound/weapons/gun_shotgun_open2.ogg'
	type_of_casings = "shell"
	accuracy_mult = 1.15
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG
	aim_slowdown = SLOWDOWN_ADS_SHOTGUN
	wield_delay = WIELD_DELAY_FAST //Shotguns are really easy to put up to fire, since they are designed for CQC (at least compared to a rifle)
	gun_skill_category = GUN_SKILL_SHOTGUNS

/obj/item/weapon/gun/shotgun/New()
	..()
	replace_tube(current_mag.current_rounds) //Populate the chamber.

/obj/item/weapon/gun/shotgun/set_gun_config_values()
	fire_delay = config.mhigh_fire_delay
	accuracy_mult = config.base_hit_accuracy_mult + config.low_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult + config.low_hit_accuracy_mult - config.hmed_hit_accuracy_mult
	scatter = config.med_scatter_value
	scatter_unwielded = config.max_scatter_value
	damage_mult = config.base_hit_damage_mult
	recoil = config.low_recoil_value
	recoil_unwielded = config.high_recoil_value

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
	if(user) playsound(user, reload_sound, 25, 1)
	return 1

/obj/item/weapon/gun/shotgun/proc/empty_chamber(mob/user)
	if(current_mag.current_rounds <= 0)
		if(in_chamber)
			in_chamber = null
			var/obj/item/ammo_magazine/handful/new_handful = retrieve_shell(ammo.type)
			playsound(user, reload_sound, 25, 1)
			new_handful.forceMove(get_turf(src))
		else
			if(user) user << "<span class='warning'>[src] is already empty.</span>"
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
	var/obj/item/ammo_magazine/handful/new_handful = rnew(/obj/item/ammo_magazine/handful)
	new_handful.generate_handful(selection, "12g", 5, 1, /obj/item/weapon/gun/shotgun)
	return new_handful

/obj/item/weapon/gun/shotgun/proc/check_chamber_position()
	return 1

/obj/item/weapon/gun/shotgun
	reload(mob/user, var/obj/item/ammo_magazine/magazine)
		if(flags_gun_features & GUN_BURST_FIRING) return

		if(!magazine || !istype(magazine,/obj/item/ammo_magazine/handful)) //Can only reload with handfuls.
			user << "<span class='warning'>You can't use that to reload!</span>"
			return

		if(!check_chamber_position()) //For the double barrel.
			user << "<span class='warning'>[src] has to be open!</span>"
			return

		//From here we know they are using shotgun type ammo and reloading via handful.
		//Makes some of this a lot easier to determine.

		var/mag_caliber = magazine.default_ammo //Handfuls can get deleted, so we need to keep this on hand for later.
		if(current_mag.transfer_ammo(magazine,user,1))
			add_to_tube(user,mag_caliber) //This will check the other conditions.

	unload(mob/user)
		if(flags_gun_features & GUN_BURST_FIRING) return
		empty_chamber(user)

/obj/item/weapon/gun/shotgun/proc/ready_shotgun_tube()
	if(current_mag.current_rounds > 0)
		ammo = ammo_list[current_mag.chamber_contents[current_mag.chamber_position]]
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

	return 1


/obj/item/weapon/gun/shotgun/able_to_fire(mob/living/user)
	. = ..()
	if (. && istype(user)) //Let's check all that other stuff first.
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.spec_weapons == SKILL_SPEC_SCOUT)
			user << "<span class='warning'>Scout specialists can't use shotguns...</span>"
			return 0


//-------------------------------------------------------
//GENERIC MERC SHOTGUN //Not really based on anything.

/obj/item/weapon/gun/shotgun/merc
	name = "custom built shotgun"
	desc = "A cobbled-together pile of scrap and alien wood. Point end towards things you want to die. Has a burst fire feature, as if it needed it."
	icon_state = "cshotgun"
	item_state = "cshotgun"
	origin_tech = "combat=4;materials=2"
	fire_sound = 'sound/weapons/gun_shotgun_automatic.ogg'
	current_mag = /obj/item/ammo_magazine/internal/shotgun/merc
	attachable_allowed = list(
						/obj/item/attachable/compensator)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG

/obj/item/weapon/gun/shotgun/merc/New()
	..()
	attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 21, "under_x" = 17, "under_y" = 14, "stock_x" = 17, "stock_y" = 14)
	if(current_mag && current_mag.current_rounds > 0) load_into_chamber()

/obj/item/weapon/gun/shotgun/merc/set_gun_config_values()
	fire_delay = config.high_fire_delay*2
	burst_amount = config.low_burst_value
	burst_delay = config.mlow_fire_delay
	accuracy_mult = config.base_hit_accuracy_mult - config.med_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult - config.med_hit_accuracy_mult - config.hmed_hit_accuracy_mult
	scatter = config.med_scatter_value
	scatter_unwielded = config.max_scatter_value
	damage_mult = config.base_hit_damage_mult
	recoil = config.low_recoil_value
	recoil_unwielded = config.high_recoil_value


/obj/item/weapon/gun/shotgun/merc/examine(mob/user)
	..()
	if(in_chamber) user << "It has a chambered round."

//-------------------------------------------------------
//TACTICAL SHOTGUN

/obj/item/weapon/gun/shotgun/combat
	name = "\improper MK221 tactical shotgun"
	desc = "The Weyland-Yutani MK221 Shotgun, a semi-automatic shotgun with a quick fire rate."
	icon_state = "mk221"
	item_state = "mk221"
	origin_tech = "combat=5;materials=4"
	fire_sound = 'sound/weapons/gun_shotgun_automatic.ogg'
	current_mag = /obj/item/ammo_magazine/internal/shotgun/combat
	attachable_allowed = list(
						/obj/item/attachable/bayonet,
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/compensator,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/stock/tactical)

/obj/item/weapon/gun/shotgun/combat/New()
	..()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 21, "under_x" = 14, "under_y" = 16, "stock_x" = 14, "stock_y" = 16)
	var/obj/item/attachable/attached_gun/grenade/G = new(src)
	G.flags_attach_features &= ~ATTACH_REMOVABLE
	G.attach_icon = "" //gun already has a better one
	G.icon_state = ""
	G.Attach(src)
	update_attachable(G.slot)
	G.icon_state = initial(G.icon_state)
	if(current_mag && current_mag.current_rounds > 0) load_into_chamber()


/obj/item/weapon/gun/shotgun/combat/set_gun_config_values()
	fire_delay = config.mhigh_fire_delay*2
	accuracy_mult = config.base_hit_accuracy_mult + config.low_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult + config.low_hit_accuracy_mult - config.hmed_hit_accuracy_mult
	scatter = config.med_scatter_value
	scatter_unwielded = config.max_scatter_value
	damage_mult = config.base_hit_damage_mult
	recoil = config.low_recoil_value
	recoil_unwielded = config.high_recoil_value


/obj/item/weapon/gun/shotgun/combat/examine(mob/user)
	..()
	if(in_chamber) user << "It has a chambered round."

//-------------------------------------------------------
//DOUBLE SHOTTY

/obj/item/weapon/gun/shotgun/double
	name = "double barrel shotgun"
	desc = "A double barreled shotgun of archaic, but sturdy design. Uses 12 Gauge Special slugs, but can only hold 2 at a time."
	icon_state = "dshotgun"
	item_state = "dshotgun"
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

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG

/obj/item/weapon/gun/shotgun/double/New()
	..()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 21,"rail_x" = 15, "rail_y" = 22, "under_x" = 21, "under_y" = 16, "stock_x" = 21, "stock_y" = 16)

/obj/item/weapon/gun/shotgun/double/set_gun_config_values()
	fire_delay = config.mlow_fire_delay
	accuracy_mult = config.base_hit_accuracy_mult + config.low_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult + config.low_hit_accuracy_mult - config.hmed_hit_accuracy_mult
	scatter = config.med_scatter_value
	scatter_unwielded = config.max_scatter_value
	damage_mult = config.base_hit_damage_mult
	recoil = config.low_recoil_value
	recoil_unwielded = config.high_recoil_value

/obj/item/weapon/gun/shotgun/double/examine(mob/user)
	..()
	if(current_mag.chamber_closed) user << "It's closed."
	else user << "It's open with [current_mag.current_rounds] shell\s loaded."

/obj/item/weapon/gun/shotgun/double/unique_action(mob/user)
	empty_chamber(user)

//Turns out it has some attachments.
/obj/item/weapon/gun/shotgun/double/update_icon()
	icon_state = current_mag.chamber_closed ? copytext(icon_state,1,-2) : icon_state + "_o"

/obj/item/weapon/gun/shotgun/double/check_chamber_position()
	if(current_mag.chamber_closed) return
	return 1

/obj/item/weapon/gun/shotgun/double/add_to_tube(mob/user,selection) //Load it on the go, nothing chambered.
	current_mag.chamber_position++
	current_mag.chamber_contents[current_mag.chamber_position] = selection
	playsound(user, reload_sound, 25, 1)
	return 1

/obj/item/weapon/gun/shotgun/double/able_to_fire(mob/user)
	. = ..()
	if(. && istype(user))
		if(!current_mag.chamber_closed)
			user << "\red Close the chamber!"
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
		ammo = ammo_list[current_mag.chamber_contents[current_mag.chamber_position]]
		in_chamber = create_bullet(ammo)
		current_mag.current_rounds--
		return in_chamber
	//We can't make a projectile without a mag or active attachable.

/obj/item/weapon/gun/shotgun/double/make_casing()
	if(current_mag.used_casings)
		..()
		current_mag.used_casings = 0

/obj/item/weapon/gun/shotgun/double/delete_bullet(obj/item/projectile/projectile_to_fire, refund = 0)
	cdel(projectile_to_fire)
	if(refund) current_mag.current_rounds++
	return 1

/obj/item/weapon/gun/shotgun/double/reload_into_chamber(mob/user)
	in_chamber = null
	current_mag.chamber_contents[current_mag.chamber_position] = "empty"
	current_mag.chamber_position--
	current_mag.used_casings++
	return 1


/obj/item/weapon/gun/shotgun/double/sawn
	name = "sawn-off shotgun"
	desc = "A double barreled shotgun whose barrel has been artificially shortened to reduce range but increase damage and spread."
	icon_state = "sshotgun"
	item_state = "sshotgun"
	flags_equip_slot = SLOT_WAIST
	attachable_allowed = list()
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG

/obj/item/weapon/gun/shotgun/double/sawn/New()
	..()
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 20,"rail_x" = 11, "rail_y" = 22, "under_x" = 18, "under_y" = 16, "stock_x" = 18, "stock_y" = 16)

/obj/item/weapon/gun/shotgun/double/sawn/set_gun_config_values()
	fire_delay = config.mlow_fire_delay
	accuracy_mult = config.base_hit_accuracy_mult + config.low_hit_accuracy_mult - config.hmed_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult + config.low_hit_accuracy_mult - config.hmed_hit_accuracy_mult
	scatter = config.med_scatter_value
	scatter_unwielded = config.max_scatter_value
	damage_mult = config.base_hit_damage_mult + config.high_hit_damage_mult
	recoil = config.med_recoil_value
	recoil_unwielded = config.max_recoil_value


//-------------------------------------------------------
//PUMP SHOTGUN
//Shotguns in this category will need to be pumped each shot.

/obj/item/weapon/gun/shotgun/pump
	name = "\improper M37A2 pump shotgun"
	desc = "An Armat Battlefield Systems classic design, the M37A2 combines close-range firepower with long term reliability. Requires a pump, which is a Unique Action."
	icon_state = "m37"
	item_state = "m37"
	current_mag = /obj/item/ammo_magazine/internal/shotgun/pump
	fire_sound = 'sound/weapons/gun_shotgun.ogg'
	var/pump_sound = 'sound/weapons/gun_shotgun_pump.ogg'
	var/pump_delay //Higher means longer delay.
	var/recent_pump //world.time to see when they last pumped it.
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
						/obj/item/attachable/stock/shotgun)

/obj/item/weapon/gun/shotgun/pump/New()
	select_gamemode_skin(/obj/item/weapon/gun/shotgun/pump)
	..()
	pump_delay = config.max_fire_delay*2
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 10, "rail_y" = 21, "under_x" = 20, "under_y" = 14, "stock_x" = 20, "stock_y" = 14)

/obj/item/weapon/gun/shotgun/pump/set_gun_config_values()
	fire_delay = config.med_fire_delay*5
	accuracy_mult = config.base_hit_accuracy_mult + config.low_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult + config.low_hit_accuracy_mult - config.hmed_hit_accuracy_mult
	scatter = config.med_scatter_value
	scatter_unwielded = config.max_scatter_value
	damage_mult = config.base_hit_damage_mult
	recoil = config.low_recoil_value
	recoil_unwielded = config.high_recoil_value

/obj/item/weapon/gun/shotgun/pump/unique_action(mob/user)
	pump_shotgun(user)

/obj/item/weapon/gun/shotgun/pump/ready_in_chamber() //If there wasn't a shell loaded through pump, this returns null.
	return

//Same as double barrel. We don't want to do anything else here.
/obj/item/weapon/gun/shotgun/pump/add_to_tube(mob/user, selection) //Load it on the go, nothing chambered.
	current_mag.chamber_position++
	current_mag.chamber_contents[current_mag.chamber_position] = selection
	playsound(user, reload_sound, 25, 1)
	return 1
	/*
	Moves the ready_in_chamber to it's own proc.
	If the Fire() cycle doesn't find a chambered round with no active attachable, it will return null.
	Which is what we want, since the gun shouldn't fire unless something was chambered.
	*/

//More or less chambers the round instead of load_into_chamber(). Also ejects used casings.
/obj/item/weapon/gun/shotgun/pump/proc/pump_shotgun(mob/user)	//We can't fire bursts with pumps.
	if(world.time < (recent_pump + pump_delay) ) return //Don't spam it.

	if(in_chamber) //eject the chambered round
		in_chamber = null
		var/obj/item/ammo_magazine/handful/new_handful = retrieve_shell(ammo.type)
		new_handful.forceMove(get_turf(src))

	ready_shotgun_tube()

	if(current_mag.used_casings)
		current_mag.used_casings--
		make_casing(type_of_casings)

	playsound(user, pump_sound, 25, 1)
	recent_pump = world.time


/obj/item/weapon/gun/shotgun/pump/reload_into_chamber(mob/user)
	if(active_attachable)
		make_casing(active_attachable.type_of_casings)
	else
		current_mag.used_casings++ //The shell was fired successfully. Add it to used.
		in_chamber = null
		//Time to move the tube position.
		if(!current_mag.current_rounds && !in_chamber)
			update_icon()//No rounds, nothing chambered.

	return 1


//-------------------------------------------------------
//SHOTGUN FROM ISOLATION

/obj/item/weapon/gun/shotgun/pump/cmb
	name = "\improper HG 37-12 pump shotgun"
	desc = "A nine-round pump action shotgun with internal tube magazine allowing for quick reloading and highly accurate fire. Used exclusively by Colonial Marshals."
	icon_state = "hg3712"
	item_state = "hg3712"
	fire_sound = 'sound/weapons/gun_shotgun_small.ogg'
	current_mag = /obj/item/ammo_magazine/internal/shotgun/pump/CMB
	attachable_allowed = list(
						/obj/item/attachable/reddot,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/compensator,
						/obj/item/attachable/scope/mini,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/attached_gun/flamer)


/obj/item/weapon/gun/shotgun/pump/cmb/New()
	..()
	pump_delay = config.mhigh_fire_delay*2
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 20,"rail_x" = 10, "rail_y" = 23, "under_x" = 19, "under_y" = 17, "stock_x" = 19, "stock_y" = 17)

/obj/item/weapon/gun/shotgun/pump/cmb/set_gun_config_values()
	fire_delay = config.med_fire_delay*4
	accuracy_mult = config.base_hit_accuracy_mult + config.low_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult + config.low_hit_accuracy_mult - config.hmed_hit_accuracy_mult
	scatter = config.med_scatter_value
	scatter_unwielded = config.max_scatter_value
	damage_mult = config.base_hit_damage_mult
	recoil = config.low_recoil_value
	recoil_unwielded = config.high_recoil_value


//-------------------------------------------------------
