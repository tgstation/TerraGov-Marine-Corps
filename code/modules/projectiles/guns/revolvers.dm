//Generic parent object.
//---------------------------------------------------

/obj/item/weapon/gun/revolver
	flags_equip_slot = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	fire_sound = 'sound/weapons/guns/fire/44mag.ogg'
	reload_sound = 'sound/weapons/guns/interact/revolver_cocked.ogg'
	cocked_sound = 'sound/weapons/guns/interact/revolver_spun.ogg'
	unload_sound = 'sound/weapons/guns/interact/revolver_unload.ogg'
	muzzleflash_iconstate = "muzzle_flash_medium"
	///Sound played when reloading by hand.
	var/hand_reload_sound = 'sound/weapons/guns/interact/revolver_load.ogg'
	///Sound played when revolvers chamber is spun.
	var/spin_sound = 'sound/effects/spin.ogg'
	///Sound played when thud?
	var/thud_sound = 'sound/effects/thud.ogg'
	///Delay between gun tricks
	var/trick_delay = 6
	///Time of last trick
	var/recent_trick //So they're not spamming tricks.
	///If the gun is able to play Russian Roulette
	var/russian_roulette = FALSE //God help you if you do this.
	///Whether the chamber can be spun for Russian Roulette. If False the chamber can be spun.
	var/catchworking = TRUE
	load_method = SINGLE_CASING|SPEEDLOADER //codex
	type_of_casings = "bullet"
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_AMMO_COUNTER
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_speed_modifier = 0.75
	aim_fire_delay = 0.25 SECONDS
	wield_delay = 0.2 SECONDS //If you modify your revolver to be two-handed, it will still be fast to aim
	gun_skill_category = GUN_SKILL_PISTOLS

	movement_acc_penalty_mult = 2
	fire_delay = 2
	accuracy_mult_unwielded = 0.85
	scatter_unwielded = 25
	recoil = 2
	recoil_unwielded = 3


/obj/item/weapon/gun/revolver/Initialize()
	. = ..()
	replace_cylinder(current_mag.current_rounds)

/obj/item/weapon/gun/revolver/examine_ammo_count(mob/user)
	if(!current_mag)
		return
	to_chat(user, "[current_mag.chamber_closed ? "It's closed." : "It's open with [current_mag.current_rounds] round\s loaded."]")

/obj/item/weapon/gun/revolver/update_icon() //Special snowflake update icon.
	icon_state = current_mag.chamber_closed ? initial(icon_state) : initial(icon_state) + "_o"

/obj/item/weapon/gun/revolver/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isscrewdriver(I))
		to_chat(user, "[catchworking ? "You adjust the cylinder lock to allow the cylinder to be spun." : "You adjust the cylinder lock to the correct depth."]")
		catchworking = !catchworking

/obj/item/weapon/gun/revolver/proc/rotate_cylinder(mob/user) //Cylinder moves backward.
	current_mag.chamber_position = current_mag.chamber_position == 1 ? current_mag.max_rounds : current_mag.chamber_position - 1

/obj/item/weapon/gun/revolver/proc/replace_cylinder(number_to_replace)
	current_mag.chamber_contents = list()
	current_mag.chamber_contents.len = current_mag.max_rounds
	var/i
	for(i = 1 to current_mag.max_rounds) //We want to make sure to populate the cylinder.
		current_mag.chamber_contents[i] = i > number_to_replace ? "empty" : "bullet"
	current_mag.chamber_position = max(1,number_to_replace)

/obj/item/weapon/gun/revolver/proc/empty_cylinder()
	var/i
	for(i = 1 to current_mag.max_rounds)
		current_mag.chamber_contents[i] = "empty"

//The cylinder is always emptied out before a reload takes place.
/obj/item/weapon/gun/revolver/proc/add_to_cylinder(mob/user) //Bullets are added forward.
	//First we're going to try and replace the current bullet.
	if(!current_mag.current_rounds)
		current_mag.chamber_contents[current_mag.chamber_position] = "bullet"
	else//Failing that, we'll try to replace the next bullet in line.
		if( (current_mag.chamber_position + 1) > current_mag.max_rounds)
			current_mag.chamber_contents[1] = "bullet"
			current_mag.chamber_position = 1
		else
			current_mag.chamber_contents[current_mag.chamber_position + 1] = "bullet"
			current_mag.chamber_position++

	playsound(user, hand_reload_sound, 25, 1)
	return TRUE

/obj/item/weapon/gun/revolver/reload(mob/user, obj/item/ammo_magazine/magazine)
	if(flags_gun_features & GUN_BURST_FIRING)
		return

	if(!magazine || !istype(magazine))
		to_chat(user, span_warning("That's not gonna work!"))
		return

	if(magazine.current_rounds <= 0)
		to_chat(user, span_warning("That [magazine.name] is empty!"))
		return

	if(current_mag.chamber_closed)
		to_chat(user, span_warning("You can't load anything when the cylinder is closed!"))
		return

	if(current_mag.current_rounds == current_mag.max_rounds)
		to_chat(user, span_warning("It's already full!"))
		return

	// speedloaders go fast
	if(istype(magazine, /obj/item/ammo_magazine/revolver))
		if(!current_mag.current_rounds) //We can't have rounds in the gun if it's a speeloader.
			if(current_mag.gun_type == magazine.gun_type) //Has to be the same gun type.
				if(current_mag.transfer_ammo(magazine,user,magazine.current_rounds))//Make sure we're successful.
					replace_ammo(user, magazine) //We want to replace the ammo ahead of time, but not necessary here.
					current_mag.match_ammo(magazine)
					replace_cylinder(current_mag.current_rounds)
					playsound(user, reload_sound, 25, 1) // Reloading via speedloader.
			else
				to_chat(user, span_warning("\The [magazine] doesn't fit!"))
		else
			to_chat(user, span_warning("You can't load a speedloader when there's something in the cylinder!"))
		return

	// the rest go slow: handfuls, boxes, etc..
	if(!current_mag.current_rounds && current_mag.caliber == magazine.caliber) //Make sure nothing's loaded and the calibers match.
		replace_ammo(user, magazine) //We are going to replace the ammo just in case.
		current_mag.match_ammo(magazine)
		current_mag.transfer_ammo(magazine,user,1) //Handful can get deleted, so we can't check through it.
		add_to_cylinder(user)
		return
	//If bullets still remain in the gun, we want to check if the actual ammo matches.
	if(magazine.default_ammo == current_mag.default_ammo) //Ammo datums match, let's see if they are compatible.
		if(current_mag.transfer_ammo(magazine,user,1))
			add_to_cylinder(user)//If the magazine is deleted, we're still fine.
		return
	to_chat(user, "[current_mag] is [current_mag.current_rounds ? "already loaded with some other ammo. Better not mix them up." : "not compatible with that ammo."]")


/obj/item/weapon/gun/revolver/unload(mob/user)
	if(flags_gun_features & GUN_BURST_FIRING)
		return FALSE

	if(current_mag.chamber_closed) //If it's actually closed.
		to_chat(user, span_notice("You clear the cylinder of [src]."))
		make_casing(type_of_casings)
		empty_cylinder()
		current_mag.create_handful(user)
		current_mag.chamber_closed = !current_mag.chamber_closed
		russian_roulette = !russian_roulette //Resets the RR variable.
	else
		current_mag.chamber_closed = !current_mag.chamber_closed
	playsound(src, unload_sound, 25, 1)
	update_icon()

	return TRUE


/obj/item/weapon/gun/revolver/make_casing()
	if(current_mag.used_casings)
		. = ..()
		current_mag.used_casings = 0 //Always dump out everything.

/obj/item/weapon/gun/revolver/able_to_fire(mob/user)
	. = ..()
	if(. && istype(user))
		if(!current_mag.chamber_closed)
			to_chat(user, span_warning("Close the cylinder!"))
			return FALSE

/obj/item/weapon/gun/revolver/ready_in_chamber()
	if(current_mag.current_rounds > 0)
		if( current_mag.chamber_contents[current_mag.chamber_position] == "bullet")
			current_mag.current_rounds-- //Subtract the round from the mag.
			in_chamber = create_bullet(ammo)
			return in_chamber

/obj/item/weapon/gun/revolver/load_into_chamber(mob/user)
	if(ready_in_chamber())
		return in_chamber
	rotate_cylinder() //If we fail to return to chamber the round, we just move the firing pin some.

/obj/item/weapon/gun/revolver/reload_into_chamber(mob/user)
	current_mag.chamber_contents[current_mag.chamber_position] = "blank" //We shot the bullet.
	current_mag.used_casings++ //We add this only if we actually fired the bullet.
	rotate_cylinder()
	return TRUE

/obj/item/weapon/gun/revolver/delete_bullet(obj/projectile/projectile_to_fire, refund = 0)
	qdel(projectile_to_fire)
	if(refund) current_mag.current_rounds++
	return TRUE

/obj/item/weapon/gun/revolver/cock(mob/user)
	if(catchworking)
		return unload(user)
	if(!current_mag.chamber_closed) //We're not spinning while it's open. Could screw up reloading.
		return
	current_mag.chamber_position = rand(1,current_mag.max_rounds)
	to_chat(user, span_notice("You spin the cylinder."))
	playsound(user, cocked_sound, 25, 1)
	russian_roulette = !russian_roulette //Sets to play RR. Resets when the gun is emptied.

/obj/item/weapon/gun/revolver/proc/revolver_basic_spin(mob/living/carbon/human/user, direction = 1, obj/item/weapon/gun/revolver/double)
	set waitfor = 0
	playsound(user, spin_sound, 25, 1)
	if(double)
		user.visible_message("[user] deftly flicks and spins [src] and [double]!",span_notice(" You flick and spin [src] and [double]!"))
		animation_wrist_flick(double, 1)
	else user.visible_message("[user] deftly flicks and spins [src]!",span_notice(" You flick and spin [src]!"))

	animation_wrist_flick(src, direction)
	sleep(3)
	if(loc && user) playsound(user, thud_sound, 25, 1)

/obj/item/weapon/gun/revolver/verb/revolvertrick()
	set category = "Weapons"
	set name = "Do a revolver trick"
	set desc = "Show off to all your friends!"


	var/obj/item/weapon/gun/revolver/G = get_active_firearm(usr)

	if(!G)
		return

	if(!istype(G))
		return

	if(usr.do_actions)
		return

	if(zoom)
		to_chat(usr, span_warning("You cannot conceviably do that while looking down \the [src]'s scope!"))
		return

	revolver_trick(usr)

/obj/item/weapon/gun/revolver/proc/revolver_throw_catch(mob/living/carbon/human/user)
	set waitfor = 0
	user.visible_message("[user] deftly flicks [src] and tosses it into the air!",span_notice(" You flick and toss [src] into the air!"))
	var/img_layer = MOB_LAYER+0.1
	var/image/trick = image(icon,user,icon_state,img_layer)
	switch(pick(1,2))
		if(1) animation_toss_snatch(trick)
		if(2) animation_toss_flick(trick, pick(1,-1))

	invisibility = 100
	for(var/mob/M in viewers(user))
		SEND_IMAGE(M, trick)
	sleep(5)
	trick.loc = null
	if(loc && user)
		invisibility = 0
		playsound(user, thud_sound, 25, 1)
		if(user.get_inactive_held_item())
			user.visible_message("[user] catches [src] with the same hand!",span_notice(" You catch [src] as it spins in to your hand!"))
		else
			user.visible_message("[user] catches [src] with his other hand!",span_notice(" You snatch [src] with your other hand! Awesome!"))
			user.temporarilyRemoveItemFromInventory(src)
			user.put_in_inactive_hand(src)
			user.swap_hand()
			user.update_inv_l_hand(0)
			user.update_inv_r_hand()

/obj/item/weapon/gun/revolver/proc/revolver_trick(mob/living/carbon/human/user)
	if(world.time < (recent_trick + trick_delay) )
		return FALSE //Don't spam it.
	if(!istype(user))
		return FALSE //Not human.
	var/chance = -5
	chance = user.health < 6 ? 0 : user.health - 5

	//Pain is largely ignored, since it deals its own effects on the mob. We're just concerned with health.
	//And this proc will only deal with humans for now.

	var/obj/item/weapon/gun/revolver/double = user.get_inactive_held_item()
	if(prob(chance))
		switch(rand(1,7))
			if(1)
				revolver_basic_spin(user, -1)
			if(2)
				revolver_basic_spin(user, 1)
			if(3)
				revolver_throw_catch(user)
			if(4)
				revolver_basic_spin(user, 1)
			if(5)
				var/arguments[] = istype(double) ? list(user, 1, double) : list(user, -1)
				revolver_basic_spin(arglist(arguments))
			if(6)
				var/arguments[] = istype(double) ? list(user, -1, double) : list(user, 1)
				revolver_basic_spin(arglist(arguments))
			if(7)
				if(istype(double))
					spawn(0)
						double.revolver_throw_catch(user)
					revolver_throw_catch(user)
				else
					revolver_throw_catch(user)
	else
		if(prob(10))
			to_chat(user, span_warning("You fumble with [src] like an idiot... Uncool."))
		else
			user.visible_message(span_info("<b>[user]</b> fumbles with [src] like a huge idiot!"))

	recent_trick = world.time //Turn on the delay for the next trick.

	return TRUE


/obj/item/weapon/gun/revolver/get_ammo_type()
	if(!ammo)
		return list("unknown", "unknown")
	else
		return list(ammo.hud_state, ammo.hud_state_empty)

/obj/item/weapon/gun/revolver/get_ammo_count()
	return current_mag ? current_mag.current_rounds : 0

// revolvers do not make any sense when they have a rattle sound, so this is ignored.
/obj/item/weapon/gun/revolver/play_fire_sound(mob/user)
	if(flags_gun_features & GUN_SILENCED)
		playsound(user, fire_sound, 25)
		return
	playsound(user, fire_sound, 60)

//-------------------------------------------------------
//TP-44 COMBAT REVOLVER

/obj/item/weapon/gun/revolver/standard_revolver
	name = "\improper TP-44 combat revolver"
	desc = "The TP-44 standard combat revolver, produced by Terran Armories. A sturdy and hard hitting firearm that loads .44 Magnum rounds. Holds 7 rounds in the cylinder. Due to the nature of the weapon, its rate of fire doesn’t quite match the output of other guns, but does hit much harder."
	icon_state = "tp44"
	item_state = "tp44"
	caliber =  CALIBER_44 //codex
	max_shells = 7 //codex
	current_mag = /obj/item/ammo_magazine/internal/revolver/standard_revolver
	force = 8
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/gyro,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/lace,
	)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 13, "rail_y" = 23, "under_x" = 22, "under_y" = 14, "stock_x" = 22, "stock_y" = 19)
	fire_delay = 0.15 SECONDS
	accuracy_mult_unwielded = 0.85
	accuracy_mult = 1
	scatter_unwielded = 15
	scatter = 2.5
	recoil = 0
	recoil_unwielded = 0.75

//-------------------------------------------------------
//M-44, based off the SAA.

/obj/item/weapon/gun/revolver/m44
	name = "\improper M-44 SAA revolver"
	desc = "A uncommon revolver occasionally carried by civilian law enforcement that's very clearly based off a modernized Single Action Army. Uses .44 Magnum rounds."
	icon_state = "m44"
	item_state = "m44"
	caliber = CALIBER_44 //codex
	max_shells = 6 //codex
	current_mag = /obj/item/ammo_magazine/internal/revolver/m44
	force = 8
	w_class = WEIGHT_CLASS_BULKY //perhaps give snub-nose treatment later?
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/quickfire,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/stock/revolver,
		/obj/item/attachable/scope,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/lace,
	)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 22,"rail_x" = 17, "rail_y" = 22, "under_x" = 22, "under_y" = 17, "stock_x" = 22, "stock_y" = 19)

//-------------------------------------------------------
//RUSSIAN REVOLVER //Based on the 7.62mm Russian revolvers.

/obj/item/weapon/gun/revolver/upp
	name = "\improper N-Y 7.62mm revolver"
	desc = "The Nagant-Yamasaki 7.62 is an effective killing machine designed by a consortion of shady Not-Americans. It is frequently found in the hands of criminals or mercenaries."
	icon_state = "ny762"
	item_state = "ny762"
	caliber = CALIBER_762X38 //codex
	max_shells = 7 //codex
	fire_sound = 'sound/weapons/guns/fire/ny.ogg'
	current_mag = /obj/item/ammo_magazine/internal/revolver/upp
	force = 8
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/compensator,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/lace,
	)
	attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 21,"rail_x" = 14, "rail_y" = 23, "under_x" = 24, "under_y" = 19, "stock_x" = 24, "stock_y" = 19)

	damage_mult = 1.05
	recoil = 0
	recoil_unwielded = 0


//-------------------------------------------------------
//A generic 357 revolver. With a twist.

/obj/item/weapon/gun/revolver/small
	name = "\improper FFA 'Rebota' revolver"
	desc = "A lean .357 made by Falffearmeria. A timeless design, from antiquity to the future. This one is well known for it's strange ammo, which ricochets off walls constantly. Which went from being a defect to a feature."
	icon_state = "rebota"
	item_state = "sw357"
	caliber = CALIBER_357 //codex
	max_shells = 6 //codex
	fire_sound = 'sound/weapons/guns/fire/revolver.ogg'
	current_mag = /obj/item/ammo_magazine/internal/revolver/small
	force = 6
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/scope,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/lace,
	)
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 19,"rail_x" = 12, "rail_y" = 21, "under_x" = 20, "under_y" = 15, "stock_x" = 20, "stock_y" = 15)

	scatter_unwielded = 20
	recoil = 0
	recoil_unwielded = 0


//-------------------------------------------------------
//Mateba is pretty well known. The cylinder folds up instead of to the side. This has a non-marine version and a marine version.

/obj/item/weapon/gun/revolver/mateba
	name = "\improper TL-24 autorevolver"
	desc = "The TL-24 is the rather rare autorevolver used by the TGMC issued in rather small numbers to backline personnel and officers it uses recoil to spin the cylinder. Uses heavy .454 rounds."
	icon_state = "mateba"
	item_state = "mateba"
	fire_animation = "mateba_fire"
	muzzleflash_iconstate = "muzzle_flash"
	caliber = CALIBER_454 //codex
	max_shells = 6 //codex
	fire_sound = 'sound/weapons/guns/fire/mateba.ogg'
	current_mag = /obj/item/ammo_magazine/internal/revolver/mateba
	force = 15
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/lace,
		/obj/item/attachable/mateba_longbarrel,
	)
	starting_attachment_types = list(
		/obj/item/attachable/mateba_longbarrel,
	)
	attachable_offset = list("muzzle_x" = 20, "muzzle_y" = 18,"rail_x" = 16, "rail_y" = 21, "under_x" = 22, "under_y" = 15, "stock_x" = 22, "stock_y" = 15)

	damage_mult = 0.80
	damage_falloff_mult = 1.5
	fire_delay = 0.2 SECONDS
	aim_fire_delay = 0.3 SECONDS
	recoil = 0
	accuracy_mult = 1.1
	scatter = 10
	accuracy_mult_unwielded = 0.6
	scatter_unwielded = 20

/obj/item/weapon/gun/revolver/mateba/notmarine
	name = "\improper Mateba autorevolver"
	desc = "The Mateba is a powerful, fast-firing revolver that uses its own recoil to rotate the cylinders. Uses .454 rounds."


/obj/item/weapon/gun/revolver/mateba/captain
	name = "\improper TL-24 autorevolver special"
	desc = "The Mateba is a powerful, fast-firing revolver that uses its own recoil to rotate the cylinders. This one appears to have had more love and care put into it. Uses .454 rounds."
	icon_state = "mateba"
	item_state = "mateba"

//-------------------------------------------------------
//MARSHALS REVOLVER

/obj/item/weapon/gun/revolver/cmb
	name = "\improper CMB autorevolver"
	desc = "An automatic revolver chambered in .357 magnum. Commonly issued to Nanotrasen security. It has a burst mode. Currently in trial with other revolvers across Terra and other colonies."
	icon_state = "cmb"
	item_state = "cmb"
	caliber = CALIBER_357 //codex
	max_shells = 6 //codex
	fire_sound = 'sound/weapons/guns/fire/revolver_light.ogg'
	current_mag = /obj/item/ammo_magazine/internal/revolver/cmb
	force = 12
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/quickfire,
		/obj/item/attachable/compensator,
		/obj/item/attachable/lace,
	)
	attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 22,"rail_x" = 11, "rail_y" = 25, "under_x" = 20, "under_y" = 18, "stock_x" = 20, "stock_y" = 18)

	fire_delay = 0.15 SECONDS
	burst_amount = 3
	burst_delay = 0.1 SECONDS
	scatter_unwielded = 20
	damage_mult = 1.05

/obj/item/weapon/gun/revolver/single_action //This town aint big enuf fer the two of us
	name = "single action revolver"
	desc = "you should not be seeing this."
	current_mag = /obj/item/ammo_magazine/internal/revolver/m44

/obj/item/weapon/gun/revolver/single_action/update_icon_state()
	. = ..()
	if(in_chamber)
		return
	icon_state = icon_state + "_unprimed"

/obj/item/weapon/gun/revolver/single_action/examine(mob/user)
	. = ..()
	to_chat(user, "[in_chamber ? "It's primed and ready to fire." : "It is not primed."]")

/obj/item/weapon/gun/revolver/single_action/Fire()
	. = ..()
	update_icon()

/obj/item/weapon/gun/revolver/single_action/cock(mob/user)
	if(!in_chamber && current_mag.current_rounds && current_mag.chamber_closed)
		rotate_cylinder(user)
		ready_in_chamber(user)
		to_chat(user, span_notice("You prime the [src]"))
		playsound(user, reload_sound, 25, 1)
		update_icon()
		return TRUE
	if(catchworking)
		unload(user)
		return TRUE
	if(!current_mag.chamber_closed)
		return FALSE
	current_mag.chamber_position = rand(1,current_mag.max_rounds)
	to_chat(user, span_notice("You spin the cylinder."))
	playsound(user, cocked_sound, 25, 1)
	russian_roulette = !russian_roulette //Sets to play RR. Resets when the gun is emptied.
	return TRUE

/obj/item/weapon/gun/revolver/single_action/ready_in_chamber()
	if(current_mag.current_rounds <= 0 || current_mag.chamber_contents[current_mag.chamber_position] != "bullet")
		return
	current_mag.current_rounds-- //Subtract the round from the mag.
	in_chamber = create_bullet(ammo)
	update_icon()
	return in_chamber

/obj/item/weapon/gun/revolver/single_action/load_into_chamber(mob/user)
	return in_chamber

/obj/item/weapon/gun/revolver/single_action/reload_into_chamber(mob/user)
	current_mag.chamber_contents[current_mag.chamber_position] = "blank" //We shot the bullet.
	current_mag.used_casings++ //We add this only if we actually fired the bullet.
	return TRUE
