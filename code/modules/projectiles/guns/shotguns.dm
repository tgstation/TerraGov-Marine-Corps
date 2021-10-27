

/*
Shotguns always start with an ammo buffer and they work by alternating ammo and ammo_buffer1
in order to fire off projectiles. This is only done to enable burst fire for the shotgun.
Consequently, the shotgun should never fire more than three projectiles on burst as that
can cause issues with ammo types getting mixed up during the burst.
*/

/obj/item/weapon/gun/shotgun
	w_class = WEIGHT_CLASS_BULKY
	force = 14.0
	caliber = CALIBER_12G //codex
	max_shells = 9 //codex
	load_method = SINGLE_CASING //codex
	fire_sound = 'sound/weapons/guns/fire/shotgun.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/shotgun_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/shotgun_shell_insert.ogg'
	cocked_sound = 'sound/weapons/guns/interact/shotgun_reload.ogg'
	var/opened_sound = 'sound/weapons/guns/interact/shotgun_open.ogg'
	type_of_casings = "shell"
	accuracy_mult = 1.15
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY
	aim_slowdown = 0.35
	wield_delay = 0.6 SECONDS //Shotguns are really easy to put up to fire, since they are designed for CQC (at least compared to a rifle)
	gun_skill_category = GUN_SKILL_SHOTGUNS
	flags_item_map_variant = NONE

	fire_delay = 6
	accuracy_mult = 1.15
	accuracy_mult_unwielded = 0.85
	scatter = 20
	scatter_unwielded = 40
	recoil = 2
	recoil_unwielded = 4

	placed_overlay_iconstate = "shotgun"


/obj/item/weapon/gun/shotgun/Initialize()
	. = ..()
	replace_tube(current_mag.current_rounds) //Populate the chamber.
	if(flags_gun_features & GUN_SHOTGUN_CHAMBER)
		load_into_chamber()


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
		user.hud_used.update_ammo_hud(user, src)
	return TRUE

/obj/item/weapon/gun/shotgun/proc/empty_chamber(mob/user)
	if(current_mag.current_rounds > 0)
		unload_shell(user)
		if(!current_mag.current_rounds && !in_chamber)
			update_icon()
		return TRUE
	if(!in_chamber)
		to_chat(user, span_warning("[src] is already empty."))
		return TRUE
	QDEL_NULL(in_chamber)
	var/obj/item/ammo_magazine/handful/new_handful = retrieve_shell(ammo.type)
	playsound(user, reload_sound, 25, 1)
	new_handful.forceMove(get_turf(src))
	user.hud_used.update_ammo_hud(user, src)
	return TRUE


/obj/item/weapon/gun/shotgun/proc/unload_shell(mob/user)
	var/obj/item/ammo_magazine/handful/new_handful = retrieve_shell(current_mag.chamber_contents[current_mag.chamber_position])

	if(user)
		user.put_in_hands(new_handful)
		playsound(user, reload_sound, 25, 1)
	else new_handful.loc = get_turf(src)

	current_mag.current_rounds--
	current_mag.chamber_contents[current_mag.chamber_position] = "empty"
	current_mag.chamber_position--
	user.hud_used.update_ammo_hud(user, src)
	return 1

///Generates a handful of 1 bullet from the gun.
/obj/item/weapon/gun/shotgun/proc/retrieve_shell(selection)
	var/obj/item/ammo_magazine/handful/new_handful = new()
	new_handful.generate_handful(selection, caliber, 1, /obj/item/weapon/gun/shotgun)
	return new_handful

/obj/item/weapon/gun/shotgun/proc/check_chamber_position()
	return 1


/obj/item/weapon/gun/shotgun/reload(mob/user, obj/item/ammo_magazine/handful/magazine)
	if(HAS_TRAIT(src, TRAIT_GUN_BURST_FIRING))
		return FALSE

	if(!istype(magazine)) //Can only reload with handfuls.
		to_chat(user, span_warning("You can't use that to reload!"))
		return FALSE

	if(!check_chamber_position()) //For the double barrel.
		to_chat(user, span_warning("[src] has to be open!"))
		return FALSE

	//From here we know they are using shotgun type ammo and reloading via handful.
	//Makes some of this a lot easier to determine.

	var/mag_caliber = magazine.default_ammo //Handfuls can get deleted, so we need to keep this on hand for later.
	if(current_mag.transfer_ammo(magazine,user,1))
		add_to_tube(user,mag_caliber) //This will check the other conditions.
		user.hud_used.update_ammo_hud(user, src)

/obj/item/weapon/gun/shotgun/unload(mob/user)
	if(HAS_TRAIT(src, TRAIT_GUN_BURST_FIRING))
		return FALSE
	return empty_chamber(user)


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
	make_casing(type_of_casings)
	if(in_chamber)
		QDEL_NULL(in_chamber)

	//Time to move the tube position.
	ready_in_chamber() //We're going to try and reload. If we don't get anything, icon change.
	if(!current_mag.current_rounds && !in_chamber) //No rounds, nothing chambered.
		update_icon()

	return TRUE

/obj/item/weapon/gun/shotgun/get_ammo_type()
	if(in_chamber)
		return list(in_chamber.ammo.hud_state, in_chamber.ammo.hud_state_empty)
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
//TACTICAL SHOTGUN

/obj/item/weapon/gun/shotgun/combat
	name = "\improper MK221 tactical shotgun"
	desc = "The Nanotrasen MK221 Shotgun, a quick-firing semi-automatic shotgun based on the centuries old Benelli M4 shotgun. Only issued to the TGMC in small numbers."
	flags_equip_slot = ITEM_SLOT_BACK
	icon_state = "mk221"
	item_state = "mk221"
	fire_sound = 'sound/weapons/guns/fire/shotgun_automatic.ogg'
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_SHOTGUN_CHAMBER|GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY
	current_mag = /obj/item/ammo_magazine/internal/shotgun/combat
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/stock/tactical,
		/obj/item/weapon/gun/grenade_launcher/underslung/invisible,
	)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 21, "under_x" = 14, "under_y" = 16, "stock_x" = 14, "stock_y" = 16)
	starting_attachment_types = list(/obj/item/weapon/gun/grenade_launcher/underslung/invisible)

	fire_delay = 15 //one shot every 1.5 seconds.
	accuracy_mult = 1.15
	accuracy_mult_unwielded = 0.5 //you need to wield this gun for any kind of accuracy
	scatter = 20
	scatter_unwielded = 40
	damage_mult = 0.75  //normalizing gun for vendors; damage reduced by 25% to compensate for faster fire rate; still higher DPS than T-32.
	recoil = 2
	recoil_unwielded = 4
	aim_slowdown = 0.4


/obj/item/weapon/gun/shotgun/combat/examine_ammo_count(mob/user)
	if(in_chamber)
		to_chat(user, "It has a chambered round.")

//-------------------------------------------------------
//T-39 semi automatic shotgun. Used by marines.

/obj/item/weapon/gun/shotgun/combat/standardmarine
	name = "\improper T-39 combat shotgun"
	desc = "The Terran Armories T-39 combat shotgun is a semi automatic shotgun used by breachers and pointmen within the TGMC squads. Uses 12 gauge shells."
	force = 20 //Has a stock already
	flags_equip_slot = ITEM_SLOT_BACK
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "t39"
	item_state = "t39"
	fire_sound = 'sound/weapons/guns/fire/shotgun_automatic.ogg'
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_SHOTGUN_CHAMBER|GUN_AMMO_COUNTER
	current_mag = /obj/item/ammo_magazine/internal/shotgun/combat
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/magnetic_harness,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/stock/t39stock,
	)

	attachable_offset = list("muzzle_x" = 41, "muzzle_y" = 20,"rail_x" = 18, "rail_y" = 20, "under_x" = 23, "under_y" = 12, "stock_x" = 13, "stock_y" = 14)
	starting_attachment_types = list(/obj/item/attachable/stock/t39stock)

	fire_delay = 14 //one shot every 1.4 seconds.
	accuracy_mult = 1.20
	accuracy_mult_unwielded = 0.65
	scatter = 10
	scatter_unwielded = 30
	damage_mult = 0.7  //30% less damage. Faster firerate.
	recoil = 0 //It has a stock on the sprite.
	recoil_unwielded = 2
	wield_delay = 1 SECONDS

/obj/item/weapon/gun/shotgun/combat/masterkey
	name = "masterkey shotgun"
	desc = "A weapon-mounted, three-shot shotgun. Reloadable with buckshot. The short barrel reduces the ammo's effectiveness, but allows it to be fired one handed."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "masterkey"
	attachable_allowed = list()
	slot = ATTACHMENT_SLOT_UNDER
	attach_delay = 3 SECONDS
	detach_delay = 3 SECONDS
	flags_gun_features = GUN_IS_ATTACHMENT|GUN_INTERNAL_MAG|GUN_SHOTGUN_CHAMBER|GUN_AMMO_COUNTER|GUN_ATTACHMENT_FIRE_ONLY|GUN_WIELDED_STABLE_FIRING_ONLY|GUN_CAN_POINTBLANK
	current_mag = /obj/item/ammo_magazine/internal/shotgun/masterkey
	recoil = 0
	pixel_shift_x = 14
	pixel_shift_y = 18

//-------------------------------------------------------
//DOUBLE SHOTTY

/obj/item/weapon/gun/shotgun/double
	name = "double barrel shotgun"
	desc = "A double barreled over and under shotgun of archaic, but sturdy design. Uses 12 gauge shells, but can only hold 2 at a time."
	flags_equip_slot = ITEM_SLOT_BACK
	icon_state = "dshotgun"
	item_state = "dshotgun"
	max_shells = 2 //codex
	current_mag = /obj/item/ammo_magazine/internal/shotgun/double
	fire_sound = 'sound/weapons/guns/fire/shotgun_heavy.ogg'
	reload_sound = 'sound/weapons/guns/interact/shotgun_db_insert.ogg'
	cocked_sound = null //We don't want this.
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/reddot,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_PUMP_REQUIRED
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 21,"rail_x" = 15, "rail_y" = 22, "under_x" = 21, "under_y" = 16, "stock_x" = 21, "stock_y" = 16)

	fire_delay = 2
	burst_delay = 2
	accuracy_mult = 1.15
	accuracy_mult_unwielded = 0.85
	scatter = 20
	scatter_unwielded = 40
	recoil = 2
	recoil_unwielded = 4
	aim_slowdown = 0.6

	///Animation that plays when you eject SPENT shells
	var/shell_eject_animation = null

/obj/item/weapon/gun/shotgun/double/examine_ammo_count(mob/user)
	if(current_mag.chamber_closed)
		to_chat(user, "It's closed.")
	else
		to_chat(user, "It's open with [current_mag.current_rounds] shell\s loaded.")

//Turns out it has some attachments.
/obj/item/weapon/gun/shotgun/double/update_icon()
	icon_state = "[base_gun_icon][current_mag.chamber_closed ? "" : "_o"]"

/obj/item/weapon/gun/shotgun/double/check_chamber_position()
	if(current_mag.chamber_closed)
		return
	return TRUE

/obj/item/weapon/gun/shotgun/double/unload(mob/user)
	if(HAS_TRAIT(src, TRAIT_GUN_BURST_FIRING))
		return FALSE
	return cock(user)

/obj/item/weapon/gun/shotgun/double/add_to_tube(mob/user,selection) //Load it on the go, nothing chambered.
	current_mag.chamber_position++
	current_mag.chamber_contents[current_mag.chamber_position] = selection
	playsound(user, reload_sound, 25, 1)
	return TRUE

/obj/item/weapon/gun/shotgun/double/able_to_fire(mob/user)
	. = ..()
	if(. && istype(user))
		if(!current_mag.chamber_closed)
			to_chat(user, span_warning("Close the chamber!"))
			return 0

/obj/item/weapon/gun/shotgun/double/cock(mob/user)
	if(current_mag.chamber_closed) //Has to be closed.
		if(current_mag.current_rounds) //We want to empty out the bullets.
			var/i
			for(i = 1 to current_mag.current_rounds)
				unload_shell(user)
		make_casing(type_of_casings)

	current_mag.chamber_closed = !current_mag.chamber_closed
	update_icon()
	playsound(user, opened_sound, 25, 1)
	return TRUE


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
		if(shell_eject_animation)
			flick("[shell_eject_animation]", src)

/obj/item/weapon/gun/shotgun/double/delete_bullet(obj/projectile/projectile_to_fire, refund = 0)
	qdel(projectile_to_fire)
	if(refund)
		current_mag.current_rounds++
	return TRUE

/obj/item/weapon/gun/shotgun/double/reload_into_chamber(mob/user)
	if(in_chamber)
		QDEL_NULL(in_chamber)
	current_mag.chamber_contents[current_mag.chamber_position] = "empty"
	current_mag.chamber_position--
	current_mag.used_casings++
	return TRUE


/obj/item/weapon/gun/shotgun/double/sawn
	name = "sawn-off shotgun"
	desc = "A double barreled shotgun whose barrel has been artificially shortened to reduce range for further CQC potiential."
	icon_state = "sshotgun"
	item_state = "sshotgun"
	flags_equip_slot = ITEM_SLOT_BELT
	attachable_allowed = list()
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 20,"rail_x" = 11, "rail_y" = 22, "under_x" = 18, "under_y" = 16, "stock_x" = 18, "stock_y" = 16)

	fire_delay = 2
	accuracy_mult = 0.85
	accuracy_mult_unwielded = 0.85
	scatter = 20
	scatter_unwielded = 40
	recoil = 3
	recoil_unwielded = 5

//-------------------------------------------------------
//MARINE DOUBLE SHOTTY

/obj/item/weapon/gun/shotgun/double/marine
	name = "\improper TS-34 double barrel shotgun"
	desc = "A double barreled shotgun of archaic, but sturdy design used by the TGMC. Due to reports of barrel bursting, the abiility to fire both barrels has been disabled. Uses 12 gauge shells, but can only hold 2 at a time."
	flags_equip_slot = ITEM_SLOT_BACK
	icon_state = "ts34"
	item_state = "ts34"
	max_shells = 2 //codex
	current_mag = /obj/item/ammo_magazine/internal/shotgun/double
	fire_sound = 'sound/weapons/guns/fire/shotgun_heavy.ogg'
	reload_sound = 'sound/weapons/guns/interact/shotgun_db_insert.ogg'
	cocked_sound = null //We don't want this.
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/reddot,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 17,"rail_x" = 15, "rail_y" = 19, "under_x" = 21, "under_y" = 13, "stock_x" = 13, "stock_y" = 16)

	fire_delay = 5
	burst_amount = 1
	accuracy_mult = 1.15
	accuracy_mult_unwielded = 0.85
	scatter = 10
	scatter_unwielded = 40
	recoil = 2
	recoil_unwielded = 4


//-------------------------------------------------------
//PUMP SHOTGUN
//Shotguns in this category will need to be pumped each shot.

/obj/item/weapon/gun/shotgun/pump
	name = "\improper V10 pump shotgun"
	desc = "A classic design, using the outdated shotgun frame. The V10 combines close-range firepower with long term reliability.\n<b>Requires a pump, which is the Unique Action key.</b>"
	flags_equip_slot = ITEM_SLOT_BACK
	icon_state = "v10"
	item_state = "v10"
	current_mag = /obj/item/ammo_magazine/internal/shotgun/pump
	fire_sound = 'sound/weapons/guns/fire/shotgun.ogg'
	max_shells = 9
	var/pump_sound = 'sound/weapons/guns/interact/shotgun_pump.ogg'
	var/pump_delay //Higher means longer delay.
	var/recent_pump //world.time to see when they last pumped it.
	var/recent_notice //world.time to see when they last got a notice.
	var/pump_lock = FALSE //Modern shotguns normally lock after being pumped; this lock is undone by pumping or operating the slide release i.e. unloading a shell manually.
	var/pump_animation = null
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/stock/shotgun,
		/obj/item/weapon/gun/pistol/plasma_pistol,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_PUMP_REQUIRED

	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 10, "rail_y" = 21, "under_x" = 20, "under_y" = 14, "stock_x" = 20, "stock_y" = 14)

	fire_delay = 20
	accuracy_mult = 1.15
	accuracy_mult_unwielded = 0.85
	scatter = 20
	scatter_unwielded = 40
	recoil = 2
	recoil_unwielded = 4
	pump_delay = 14
	aim_slowdown = 0.45

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
/obj/item/weapon/gun/shotgun/pump/cock(mob/user)	//We can't fire bursts with pumps.
	if(world.time < (recent_pump + pump_delay) ) //Don't spam it.
		return FALSE
	if(pump_lock)
		if(world.time > recent_notice + 7)
			pump_fail_notice(user)
		return TRUE

	if(in_chamber) //eject the chambered round
		QDEL_NULL(in_chamber)
		var/obj/item/ammo_magazine/handful/new_handful = retrieve_shell(ammo.type)
		new_handful.forceMove(get_turf(src))

	ready_shotgun_tube()


	if(current_mag.used_casings)
		current_mag.used_casings--
		make_casing(type_of_casings)

	pump_notice(user)
	if(pump_animation)
		flick("[pump_animation]", src)
	playsound(src, pump_sound, 25, 1)
	recent_pump = world.time
	if(in_chamber) //Lock only if we have ammo loaded.
		user.hud_used.update_ammo_hud(user, src)
		pump_lock = TRUE

	return TRUE

/obj/item/weapon/gun/shotgun/pump/proc/pump_fail_notice(mob/user)
	playsound(user,'sound/weapons/throwtap.ogg', 25, 1)
	to_chat(user,span_warning("<b>[src] has already been pumped, locking the pump mechanism; fire or unload a shell to unlock it.</b>"))
	recent_notice = world.time

/obj/item/weapon/gun/shotgun/pump/proc/pump_notice(mob/user)
	to_chat(user, span_notice("<b>You pump [src].</b>"))

/obj/item/weapon/gun/shotgun/pump/reload_into_chamber(mob/user)
	pump_lock = FALSE //fired successfully; unlock the pump
	current_mag.used_casings++ //The shell was fired successfully. Add it to used.
	if(in_chamber)
		QDEL_NULL(in_chamber)
	//Time to move the tube position.
	if(!current_mag.current_rounds)
		update_icon()//No rounds, nothing chambered.

	return TRUE

/obj/item/weapon/gun/shotgun/pump/unload(mob/user)
	if(pump_lock)
		to_chat(user, span_notice("<b>You disengage [src]'s pump lock with the slide release.</b>"))
		pump_lock = FALSE //we're operating the slide release to unload, thus unlocking the pump
	return ..()

//-------------------------------------------------------
//A shotgun, how quaint.
/obj/item/weapon/gun/shotgun/pump/cmb
	name = "\improper Paladin-12 pump shotgun"
	desc = "A nine-round pump action shotgun. A shotgun used for hunting, home defence and police work, many versions of it exist and are used by just about anyone."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "pal12"
	item_state = "pal12"
	fire_sound = 'sound/weapons/guns/fire/shotgun_cmb.ogg'
	reload_sound = 'sound/weapons/guns/interact/shotgun_cmb_insert.ogg'
	pump_sound = 'sound/weapons/guns/interact/shotgun_cmb_pump.ogg'
	current_mag = /obj/item/ammo_magazine/internal/shotgun/pump/CMB
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/compensator,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/stock/irremoveable/pal12,
	)
	flags_item_map_variant = NONE
	attachable_offset = list("muzzle_x" = 38, "muzzle_y" = 19,"rail_x" = 14, "rail_y" = 19, "under_x" = 37, "under_y" = 16, "stock_x" = 15, "stock_y" = 14)
	starting_attachment_types = list(
		/obj/item/attachable/stock/irremoveable/pal12,
	)

	fire_delay = 15
	damage_mult = 0.75
	accuracy_mult = 1.25
	accuracy_mult_unwielded = 1
	scatter = 5
	scatter_unwielded = 35
	recoil = 0 // It has a stock. It's on the sprite.
	recoil_unwielded = 0
	pump_delay = 12
	aim_slowdown = 0.4

//------------------------------------------------------
//A hacky bolt action rifle. in here for the "pump" or bolt working action.

/obj/item/weapon/gun/shotgun/pump/bolt
	name = "\improper Mosin Nagant rifle"
	desc = "A mosin nagant rifle, even just looking at it you can feel the cosmoline already. Commonly known by its slang, \"Moist Nugget\", by downbrained colonists and outlaws."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "mosin"
	item_state = "mosin"
	fire_sound = 'sound/weapons/guns/fire/mosin.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/mosin_reload.ogg'
	caliber = CALIBER_762X54 //codex
	load_method = SINGLE_CASING //codex
	max_shells = 5 //codex
	current_mag = /obj/item/ammo_magazine/internal/shotgun/pump/bolt
	gun_skill_category = GUN_SKILL_RIFLES
	type_of_casings = "cartridge"
	pump_sound = 'sound/weapons/guns/interact/working_the_bolt.ogg'
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/mosin,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/stock/mosin,
	)
	flags_item_map_variant = NONE
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_AMMO_COUNTER|GUN_PUMP_REQUIRED
	attachable_offset = list("muzzle_x" = 37, "muzzle_y" = 18,"rail_x" = 14, "rail_y" = 19, "under_x" = 19, "under_y" = 14, "stock_x" = 15, "stock_y" = 12)
	starting_attachment_types = list(
		/obj/item/attachable/scope/mosin,
		/obj/item/attachable/stock/mosin,
	)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.75 SECONDS
	aim_speed_modifier = 0.8

	fire_delay = 1.75 SECONDS
	accuracy_mult = 1.45
	accuracy_mult_unwielded = 0.7
	scatter = -25
	scatter_unwielded = 40
	recoil = 0
	recoil_unwielded = 4
	pump_delay = 12
	aim_slowdown = 1
	wield_delay = 1 SECONDS

	placed_overlay_iconstate = "wood"

/obj/item/weapon/gun/shotgun/pump/bolt/pump_fail_notice(mob/user)
	playsound(user,'sound/weapons/throwtap.ogg', 25, 1)
	to_chat(user,span_warning("<b>[src] bolt has already been worked, locking the bolt; fire or unload a round to unlock it.</b>"))
	recent_notice = world.time

/obj/item/weapon/gun/shotgun/pump/bolt/pump_notice(mob/user)
	to_chat(user, span_notice("<b>You work [src] bolt.</b>"))

/obj/item/weapon/gun/shotgun/pump/bolt/unload(mob/user)
	if(pump_lock)
		to_chat(user, span_notice("<b>You open [src]'s breechloader, ejecting the cartridge.</b>"))
		pump_lock = FALSE //we're operating the slide release to unload, thus unlocking the pump
	return ..()

//***********************************************************
// Martini Henry

/obj/item/weapon/gun/shotgun/double/martini
	name = "\improper Martini Henry lever action rifle"
	desc = "A lever action with room for a single round of .557/440 ball. Perfect for any kind of hunt, be it elephant or xeno."
	flags_equip_slot = ITEM_SLOT_BACK
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "martini"
	item_state = "martini"
	shell_eject_animation = "martini_flick"
	caliber = CALIBER_557 //codex
	muzzle_flash_lum = 7
	max_shells = 1 //codex
	ammo = /datum/ammo/bullet/sniper/martini
	current_mag = /obj/item/ammo_magazine/internal/shotgun/martini
	gun_skill_category = GUN_SKILL_RIFLES
	type_of_casings = "cartridge"
	fire_sound = 'sound/weapons/guns/fire/martini.ogg'
	reload_sound = 'sound/weapons/guns/interact/martini_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/martini_cocked.ogg'
	opened_sound = 'sound/weapons/guns/interact/martini_open.ogg'
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_AMMO_COUNTER|GUN_PUMP_REQUIRED
	attachable_offset = list("muzzle_x" = 45, "muzzle_y" = 23,"rail_x" = 17, "rail_y" = 25, "under_x" = 19, "under_y" = 14, "stock_x" = 15, "stock_y" = 12)

	fire_delay = 1 SECONDS
	accuracy_mult = 1.45

	scatter = -25
	scatter_unwielded = 30

	recoil = 2
	recoil_unwielded = 4

	aim_slowdown = 1
	wield_delay = 1 SECONDS

	placed_overlay_iconstate = "wood"

//***********************************************************
// Derringer

/obj/item/weapon/gun/shotgun/double/derringer
	name = "R-2395 Derringer"
	desc = "The R-2395 Derringer has been a classic for centuries. This latest iteration combines plasma propulsion powder with the classic design to make an assasination weapon that will leave little to chance."
	icon_state = "derringer"
	item_state = "tp17"
	gun_skill_category = GUN_SKILL_PISTOLS
	w_class = WEIGHT_CLASS_TINY
	type_of_casings = "cartridge"
	caliber = CALIBER_41RIM //codex
	muzzle_flash_lum = 5
	max_shells = 2 //codex
	ammo = /datum/ammo/bullet/pistol/superheavy/derringer
	current_mag = /obj/item/ammo_magazine/internal/shotgun/derringer
	fire_sound = 'sound/weapons/guns/fire/mateba.ogg'
	reload_sound = 'sound/weapons/guns/interact/shotgun_db_insert.ogg'
	cocked_sound = 'sound/weapons/guns/interact/martini_cocked.ogg'
	opened_sound = 'sound/weapons/guns/interact/martini_open.ogg'
	attachable_allowed = list()
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_AMMO_COUNTER

	fire_delay = 0.5 SECONDS
	scatter = 30
	recoil = 1
	recoil_unwielded = 1
	aim_slowdown = 0
	wield_delay = 0.5 SECONDS

/obj/item/weapon/gun/shotgun/double/derringer/Initialize()
	. = ..()
	if(round(rand(1, 10), 1) != 1)
		return
	base_gun_icon = "derringerw"
	update_icon()

//***********************************************************
// Yee Haw it's a cowboy lever action gun!

/obj/item/weapon/gun/shotgun/pump/lever
	name = "lever action rifle"
	desc = "A .44 magnum lever action rifle with side loading port. It has a low fire rate, but it packs quite a punch in hunting."
	icon_state = "mares_leg"
	item_state = "mbx900"
	fire_sound = 'sound/weapons/guns/fire/leveraction.ogg'//I like how this one sounds.
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/mosin_reload.ogg'
	caliber = CALIBER_44 //codex
	load_method = SINGLE_CASING //codex
	max_shells = 10 //codex
	current_mag = /obj/item/ammo_magazine/internal/shotgun/pump/lever
	gun_skill_category = GUN_SKILL_RIFLES
	type_of_casings = "cartridge"
	pump_sound = 'sound/weapons/guns/interact/ak47_cocked.ogg'//good enough for now.
	flags_item_map_variant = NONE
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/scope,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bayonet,
	)
	attachable_offset = list("muzzle_x" = 50, "muzzle_y" = 21,"rail_x" = 8, "rail_y" = 21, "under_x" = 37, "under_y" = 16, "stock_x" = 20, "stock_y" = 14)
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_AMMO_COUNTER

	fire_delay = 8
	accuracy_mult = 1.30
	accuracy_mult_unwielded = 0.7
	scatter = 15
	scatter_unwielded = 40
	recoil = 2
	recoil_unwielded = 4
	pump_delay = 6

/obj/item/weapon/gun/shotgun/pump/lever/pump_fail_notice(mob/user)
	playsound(user,'sound/weapons/throwtap.ogg', 25, 1)
	to_chat(user,span_warning("<b>[src] lever has already been worked, locking the lever; fire or unload a round to unlock it.</b>"))
	recent_notice = world.time

/obj/item/weapon/gun/shotgun/pump/lever/pump_notice(mob/user)
	to_chat(user, span_notice("<b>You work [src] lever.</b>"))

/obj/item/weapon/gun/shotgun/pump/lever/unload(mob/user)
	if(pump_lock)
		to_chat(user, span_notice("<b>You pull [src]'s lever downward, ejecting the cartridge.</b>"))
		pump_lock = FALSE //we're operating the slide release to unload, thus unlocking the pump
	return ..()
// ***********************************************
// Leicester Rifle. The gun that won the west.

/obj/item/weapon/gun/shotgun/pump/lever/repeater
	name = "Leicester Repeater"
	desc = "The gun that won the west or so they say. But space is a very different kind of frontier all together, chambered for .44 magnum."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "leicrepeater"
	item_state = "leicrepeater"
	fire_sound = 'sound/weapons/guns/fire/leveraction.ogg'//I like how this one sounds.
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/mosin_reload.ogg'
	caliber = CALIBER_44 //codex
	load_method = SINGLE_CASING //codex
	max_shells = 14 //codex
	current_mag = /obj/item/ammo_magazine/internal/shotgun/pump/lever/repeater
	gun_skill_category = GUN_SKILL_RIFLES
	type_of_casings = "cartridge"
	pump_sound = 'sound/weapons/guns/interact/ak47_cocked.ogg'//good enough for now.
	flags_item_map_variant = NONE
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/scope,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/motiondetector,
	)
	attachable_offset = list ("muzzle_x" = 45, "muzzle_y" = 23,"rail_x" = 21, "rail_y" = 23, "under_x" = 19, "under_y" = 14, "stock_x" = 15, "stock_y" = 12)
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_AMMO_COUNTER
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.3 SECONDS
	aim_speed_modifier = 2

	fire_delay = 10
	accuracy_mult = 1.20
	accuracy_mult_unwielded = 0.8
	damage_mult = 1.5
	damage_falloff_mult = 0.5
	scatter = -5
	scatter_unwielded = 15
	recoil = 0
	recoil_unwielded = 2
	pump_delay = 2
	aim_slowdown = 0.6

//------------------------------------------------------
//MBX900 Lever Action Shotgun
/obj/item/weapon/gun/shotgun/pump/lever/mbx900
	name = "\improper MBX-900 lever action shotgun"
	desc = "A .410 bore lever action shotgun that fires nearly as fast as you can operate the lever. Renowed due to its devastating and extremely reliable design."
	icon_state = "mbx900"
	item_state = "mbx900"
	fire_sound = 'sound/weapons/guns/fire/shotgun_light.ogg'//I like how this one sounds.
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/mosin_reload.ogg'
	caliber = CALIBER_410
	load_method = SINGLE_CASING
	max_shells = 10
	current_mag = /obj/item/ammo_magazine/internal/shotgun/pump/lever/mbx900
	gun_skill_category = GUN_SKILL_SHOTGUNS
	type_of_casings = "cartridge"
	pump_sound = 'sound/weapons/guns/interact/ak47_cocked.ogg'

	attachable_allowed = list(
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bipod,
		/obj/item/attachable/compensator,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/reddot,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/verticalgrip,
		/obj/item/weapon/gun/pistol/plasma_pistol,
	)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 17,"rail_x" = 12, "rail_y" = 19, "under_x" = 27, "under_y" = 16, "stock_x" = 0, "stock_y" = 0)

	flags_item_map_variant = NONE

	fire_delay = 0.6 SECONDS
	accuracy_mult = 1.4
	pump_delay = 0.2 SECONDS

//------------------------------------------------------
//T-35 Pump shotgun
/obj/item/weapon/gun/shotgun/pump/t35
	name = "\improper T-35 pump shotgun"
	desc = "The Terran Armories T-35 is the shotgun used by the TerraGov Marine Corps. It's used as a close quarters tool when someone wants something more suited for close range than most people, or as an odd sidearm on your back for emergencies. Uses 12 gauge shells.\n<b>Requires a pump, which is the Unique Action key.</b>"
	flags_equip_slot = ITEM_SLOT_BACK
	icon_state = "t35"
	item_state = "t35"
	pump_animation = "t35_pump"
	current_mag = /obj/item/ammo_magazine/internal/shotgun/pump
	fire_sound = 'sound/weapons/guns/fire/t35.ogg'
	max_shells = 9
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/stock/t35stock,
		/obj/item/attachable/motiondetector,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/attachable/buildasentry,
	)

	attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 18,"rail_x" = 10, "rail_y" = 20, "under_x" = 21, "under_y" = 12, "stock_x" = 20, "stock_y" = 16)

	flags_item_map_variant = NONE

	fire_delay = 20
	accuracy_mult = 1.15
	accuracy_mult_unwielded = 0.85
	scatter = 20
	scatter_unwielded = 40
	recoil = 2
	recoil_unwielded = 4
	aim_slowdown = 0.45
	pump_delay = 14

	placed_overlay_iconstate = "t35"

//buckshot variants
/obj/item/weapon/gun/shotgun/pump/t35/pointman
	current_mag = /obj/item/ammo_magazine/internal/shotgun/pump/buckshot

/obj/item/weapon/gun/shotgun/pump/t35/nonstandard
	current_mag = /obj/item/ammo_magazine/internal/shotgun/pump/buckshot
	starting_attachment_types = list(/obj/item/attachable/stock/t35stock, /obj/item/attachable/angledgrip, /obj/item/attachable/magnetic_harness)

//-------------------------------------------------------
//THE MYTH, THE GUN, THE LEGEND, THE DEATH, THE ZX

/obj/item/weapon/gun/shotgun/zx76
	name = "\improper ZX-76 assault shotgun"
	desc = "The ZX-76 Assault Shotgun, a incredibly rare, double barreled semi-automatic combat shotgun with a twin shot mode. Possibly the unrivaled master of CQC. Has a 9 round internal magazine."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "zx-76"
	item_state = "zx-76"
	flags_equip_slot = ITEM_SLOT_BACK
	max_shells = 10 //codex
	caliber = CALIBER_12G //codex
	load_method = SINGLE_CASING //codex
	fire_sound = 'sound/weapons/guns/fire/shotgun_light.ogg'
	current_mag = /obj/item/ammo_magazine/internal/shotgun/scout
	aim_slowdown = 0.45
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/lasersight,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/grenade_launcher/underslung,
	)

	attachable_offset = list("muzzle_x" = 40, "muzzle_y" = 17,"rail_x" = 12, "rail_y" = 23, "under_x" = 29, "under_y" = 12, "stock_x" = 13, "stock_y" = 15)

	fire_delay = 1.75 SECONDS
	damage_mult = 0.9
	wield_delay = 0.75 SECONDS
	burst_amount = 2
	burst_delay = 0.01 SECONDS //basically instantaneous two shots
	extra_delay = 0.5 SECONDS
	scatter = 2
	burst_scatter_mult = 4 // 2x4=8
	accuracy_mult = 1
