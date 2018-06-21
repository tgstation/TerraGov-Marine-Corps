//---------------------------------------------------

//Generic parent object.
/obj/item/weapon/gun/revolver
	flags_equip_slot = SLOT_WAIST
	w_class = 3
	origin_tech = "combat=3;materials=2"
	matter = list("metal" = 2000)
	fire_sound = 'sound/weapons/gun_44mag.ogg'
	reload_sound = 'sound/weapons/gun_revolver_cocked.ogg'
	cocked_sound = 'sound/weapons/gun_revolver_spun.ogg'
	unload_sound = 'sound/weapons/gun_revolver_unload.ogg'
	var/hand_reload_sound = 'sound/weapons/gun_revolver_load3.ogg'
	var/spin_sound = 'sound/effects/spin.ogg'
	var/thud_sound = 'sound/effects/thud.ogg'
	var/trick_delay = 6
	var/recent_trick //So they're not spamming tricks.
	var/russian_roulette = 0 //God help you if you do this.
	type_of_casings = "bullet"
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG
	wield_delay = WIELD_DELAY_VERY_FAST //If you modify your revolver to be two-handed, it will still be fast to aim
	gun_skill_category = GUN_SKILL_PISTOLS
	movement_acc_penalty_mult = 3

/obj/item/weapon/gun/revolver/New()
	..() //Do all that other stuff.
	replace_cylinder(current_mag.current_rounds)

/obj/item/weapon/gun/revolver/set_gun_config_values()
	fire_delay = config.max_fire_delay
	accuracy_mult = config.base_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult - config.low_hit_accuracy_mult
	scatter = config.med_scatter_value
	scatter_unwielded = config.high_scatter_value
	damage_mult = config.base_hit_damage_mult
	recoil = config.min_recoil_value
	recoil_unwielded = config.med_recoil_value


/obj/item/weapon/gun/revolver/examine(mob/user)
	..()
	user << "[current_mag.chamber_closed? "It's closed.": "It's open with [current_mag.current_rounds] round\s loaded."]"

/obj/item/weapon/gun/revolver/update_icon() //Special snowflake update icon.
	icon_state = current_mag.chamber_closed ? copytext(icon_state,1,-2) : icon_state + "_o"

/obj/item/weapon/gun/revolver/proc/rotate_cylinder(mob/user) //Cylinder moves backward.
	current_mag.chamber_position = current_mag.chamber_position == 1 ? current_mag.max_rounds : current_mag.chamber_position - 1

/obj/item/weapon/gun/revolver/proc/spin_cylinder(mob/user)
	if(current_mag.chamber_closed) //We're not spinning while it's open. Could screw up reloading.
		current_mag.chamber_position = rand(1,current_mag.max_rounds)
		user << "<span class='notice'>You spin the cylinder.</span>"
		playsound(user, cocked_sound, 25, 1)
		russian_roulette = !russian_roulette //Sets to play RR. Resets when the gun is emptied.

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
	if(!current_mag.current_rounds) current_mag.chamber_contents[current_mag.chamber_position] = "bullet"
	else//Failing that, we'll try to replace the next bullet in line.
		if( (current_mag.chamber_position + 1) > current_mag.max_rounds)
			current_mag.chamber_contents[1] = "bullet"
			current_mag.chamber_position = 1
		else
			current_mag.chamber_contents[current_mag.chamber_position + 1] = "bullet"
			current_mag.chamber_position++

	playsound(user, hand_reload_sound, 25, 1)
	return 1

/obj/item/weapon/gun/revolver
	reload(mob/user, obj/item/ammo_magazine/magazine)
		if(flags_gun_features & GUN_BURST_FIRING) return

		if(!magazine || !istype(magazine))
			user << "<span class='warning'>That's not gonna work!</span>"
			return

		if(magazine.current_rounds <= 0)
			user << "<span class='warning'>That [magazine.name] is empty!</span>"
			return

		if(current_mag.chamber_closed)
			user << "<span class='warning'>You can't load anything when the cylinder is closed!</span>"
			return

		if(current_mag.current_rounds == current_mag.max_rounds)
			user << "<span class='warning'>It's already full!</span>"
			return

		if(istype(magazine, /obj/item/ammo_magazine/handful)) //Looks like we're loading via handful.
			if( !current_mag.current_rounds && current_mag.caliber == magazine.caliber) //Make sure nothing's loaded and the calibers match.
				replace_ammo(user, magazine) //We are going to replace the ammo just in case.
				current_mag.match_ammo(magazine)
				current_mag.transfer_ammo(magazine,user,1) //Handful can get deleted, so we can't check through it.
				add_to_cylinder(user)
			//If bullets still remain in the gun, we want to check if the actual ammo matches.
			else if(magazine.default_ammo == current_mag.default_ammo) //Ammo datums match, let's see if they are compatible.
				if(current_mag.transfer_ammo(magazine,user,1))
					add_to_cylinder(user)//If the magazine is deleted, we're still fine.
			else
				user << "[current_mag] is [current_mag.current_rounds ? "already loaded with some other ammo. Better not mix them up." : "not compatible with that ammo."]"//Not the right kind of ammo.
		else //So if it's not a handful, it's an actual speedloader.
			if(!current_mag.current_rounds) //We can't have rounds in the gun if it's a speeloader.
				if(current_mag.gun_type == magazine.gun_type) //Has to be the same gun type.
					if(current_mag.transfer_ammo(magazine,user,magazine.current_rounds))//Make sure we're successful.
						replace_ammo(user, magazine) //We want to replace the ammo ahead of time, but not necessary here.
						current_mag.match_ammo(magazine)
						replace_cylinder(current_mag.current_rounds)
						playsound(user, reload_sound, 25, 1) // Reloading via speedloader.
				else
					user << "<span class='warning'>That [magazine] doesn't fit!</span>"
			else
				user << "<span class='warning'>You can't load a speedloader when there's something in the cylinder!</span>"

	unload(mob/user)
		if(flags_gun_features & GUN_BURST_FIRING) return

		if(current_mag.chamber_closed) //If it's actually closed.
			user << "<span class='notice'>You clear the cylinder of [src].</span>"
			make_casing(type_of_casings)
			empty_cylinder()
			current_mag.create_handful(user)
			current_mag.chamber_closed = !current_mag.chamber_closed
			russian_roulette = !russian_roulette //Resets the RR variable.
		else
			current_mag.chamber_closed = !current_mag.chamber_closed
		playsound(src, unload_sound, 25, 1)
		update_icon()
		return

	make_casing()
		if(current_mag.used_casings)
			. = ..()
			current_mag.used_casings = 0 //Always dump out everything.

	able_to_fire(mob/user)
		. = ..()
		if(. && istype(user))
			if(!current_mag.chamber_closed)
				user << "<span class='warning'>Close the cylinder!</span>"
				return 0

	ready_in_chamber()
		if(current_mag.current_rounds > 0)
			if( current_mag.chamber_contents[current_mag.chamber_position] == "bullet")
				current_mag.current_rounds-- //Subtract the round from the mag.
				in_chamber = create_bullet(ammo)
				return in_chamber

	load_into_chamber(mob/user)
//		if(active_attachable) active_attachable = null
		if(ready_in_chamber())
			return in_chamber
		rotate_cylinder() //If we fail to return to chamber the round, we just move the firing pin some.

	reload_into_chamber(mob/user)
		current_mag.chamber_contents[current_mag.chamber_position] = "blank" //We shot the bullet.
		current_mag.used_casings++ //We add this only if we actually fired the bullet.
		rotate_cylinder()
		return 1

	delete_bullet(obj/item/projectile/projectile_to_fire, refund = 0)
		cdel(projectile_to_fire)
		if(refund) current_mag.current_rounds++
		return 1

	unique_action(mob/user)
		spin_cylinder(user)

/obj/item/weapon/gun/revolver/proc/revolver_basic_spin(mob/living/carbon/human/user, direction = 1, obj/item/weapon/gun/revolver/double)
	set waitfor = 0
	playsound(user, spin_sound, 25, 1)
	if(double)
		user.visible_message("[user] deftly flicks and spins [src] and [double]!","\blue You flick and spin [src] and [double]!")
		animation_wrist_flick(double, 1)
	else user.visible_message("[user] deftly flicks and spins [src]!","\blue You flick and spin [src]!")

	animation_wrist_flick(src, direction)
	sleep(3)
	if(loc && user) playsound(user, thud_sound, 25, 1)

/obj/item/weapon/gun/revolver/proc/revolver_throw_catch(mob/living/carbon/human/user)
	set waitfor = 0
	user.visible_message("[user] deftly flicks [src] and tosses it into the air!","\blue You flick and toss [src] into the air!")
	var/img_layer = MOB_LAYER+0.1
	var/image/trick = image(icon,user,icon_state,img_layer)
	switch(pick(1,2))
		if(1) animation_toss_snatch(trick)
		if(2) animation_toss_flick(trick, pick(1,-1))

	invisibility = 100
	for(var/mob/M in viewers(user))
		M << trick
	sleep(5)
	trick.loc = null
	if(loc && user)
		invisibility = 0
		playsound(user, thud_sound, 25, 1)
		if(user.get_inactive_hand())
			user.visible_message("[user] catches [src] with the same hand!","\blue You catch [src] as it spins in to your hand!")
		else
			user.visible_message("[user] catches [src] with his other hand!","\blue You snatch [src] with your other hand! Awesome!")
			user.temp_drop_inv_item(src)
			user.put_in_inactive_hand(src)
			user.swap_hand()
			user.update_inv_l_hand(0)
			user.update_inv_r_hand()

/obj/item/weapon/gun/revolver/proc/revolver_trick(mob/living/carbon/human/user)
	if(world.time < (recent_trick + trick_delay) ) return //Don't spam it.
	if(!istype(user)) return //Not human.
	var/chance = -5
	chance = user.health < 6 ? 0 : user.health - 5

	//Pain is largely ignored, since it deals its own effects on the mob. We're just concerned with health.
	//And this proc will only deal with humans for now.

	var/obj/item/weapon/gun/revolver/double = user.get_inactive_hand()
	if(prob(chance))
		switch(rand(1,8))
			if(1)
				revolver_basic_spin(user, -1)
			if(2)
				revolver_basic_spin(user, 1)
			if(3)
				revolver_throw_catch(user)
			if(4)
				revolver_basic_spin(user, 1)
			if(5)
				//???????????
			if(6)
				var/arguments[] = istype(double) ? list(user, 1, double) : list(user, -1)
				revolver_basic_spin(arglist(arguments))

			if(7)
				var/arguments[] = istype(double) ? list(user, -1, double) : list(user, 1)
				revolver_basic_spin(arglist(arguments))
			if(8)
				if(istype(double))
					spawn(0)
						double.revolver_throw_catch(user)
					revolver_throw_catch(user)
				else
					revolver_throw_catch(user)
	else
		if(prob(10)) user << "<span class='warning'>You fumble with [src] like an idiot... Uncool.</span>"
		else user.visible_message("<span class='info'><b>[user]</b> fumbles with [src] like a huge idiot!</span>")

	recent_trick = world.time //Turn on the delay for the next trick.

//-------------------------------------------------------
//M44 MAGNUM REVOLVER //Not actually cannon, but close enough.

/obj/item/weapon/gun/revolver/m44
	name = "\improper M44 combat revolver"
	desc = "A bulky revolver, occasionally carried by assault troops and officers in the Colonial Marines, as well civilian law enforcement. Uses .44 Magnum rounds."
	icon_state = "m44"
	item_state = "m44"
	current_mag = /obj/item/ammo_magazine/internal/revolver/m44
	force = 8
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
						/obj/item/attachable/scope/mini)

	New()
		..()
		attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 21,"rail_x" = 17, "rail_y" = 23, "under_x" = 22, "under_y" = 17, "stock_x" = 22, "stock_y" = 19)

//-------------------------------------------------------
//RUSSIAN REVOLVER //Based on the 7.62mm Russian revolvers.

/obj/item/weapon/gun/revolver/upp
	name = "\improper N-Y 7.62mm revolver"
	desc = "The Nagant-Yamasaki 7.62 is an effective killing machine designed by a consortion of shady Not-Americans. It is frequently found in the hands of criminals or mercenaries."
	icon_state = "ny762"
	item_state = "ny762"
	origin_tech = "combat=3;materials=1;syndicate=3"
	fire_sound = 'sound/weapons/gun_pistol_medium.ogg'
	current_mag = /obj/item/ammo_magazine/internal/revolver/upp
	force = 8
	attachable_allowed = list(/obj/item/attachable/compensator)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG

	New()
		..()
		attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 21,"rail_x" = 14, "rail_y" = 23, "under_x" = 24, "under_y" = 19, "stock_x" = 24, "stock_y" = 19)

/obj/item/weapon/gun/revolver/upp/set_gun_config_values()
	fire_delay = config.low_fire_delay
	accuracy_mult = config.base_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult - config.med_hit_accuracy_mult
	scatter = config.med_scatter_value
	scatter_unwielded = config.high_scatter_value
	damage_mult = config.base_hit_damage_mult + config.min_hit_damage_mult
	recoil = 0
	recoil_unwielded = 0


//-------------------------------------------------------
//357 REVOLVER //Based on the generic S&W 357.

/obj/item/weapon/gun/revolver/small
	name = "\improper S&W .357 revolver"
	desc = "A lean .357 made by Smith & Wesson. A timeless classic, from antiquity to the future."
	icon_state = "sw357"
	item_state = "ny762" //PLACEHOLDER
	fire_sound = 'sound/weapons/gun_pistol_medium.ogg'
	current_mag = /obj/item/ammo_magazine/internal/revolver/small
	force = 6
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG

/obj/item/weapon/gun/revolver/small/New()
	..()
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 19,"rail_x" = 12, "rail_y" = 21, "under_x" = 20, "under_y" = 15, "stock_x" = 20, "stock_y" = 15)

/obj/item/weapon/gun/revolver/small/set_gun_config_values()
	fire_delay = config.low_fire_delay
	accuracy_mult = config.base_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult - config.low_hit_accuracy_mult
	scatter = config.med_scatter_value
	scatter_unwielded = config.med_scatter_value
	damage_mult = config.base_hit_damage_mult
	recoil = 0
	recoil_unwielded = 0

/obj/item/weapon/gun/revolver/small/unique_action(mob/user)
	revolver_trick(user)

//-------------------------------------------------------
//BURST REVOLVER //Mateba is pretty well known. The cylinder folds up instead of to the side.

/obj/item/weapon/gun/revolver/mateba
	name = "\improper Mateba autorevolver"
	desc = "The Mateba is a powerful, fast-firing revolver that uses its own recoil to rotate the cylinders. It uses heavy .454 rounds."
	icon_state = "mateba"
	item_state = "mateba"
	origin_tech = "combat=4;materials=3"
	fire_sound = 'sound/weapons/gun_mateba.ogg'
	current_mag = /obj/item/ammo_magazine/internal/revolver/mateba
	force = 15
	attachable_allowed = list(
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/quickfire,
						/obj/item/attachable/compensator)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG

/obj/item/weapon/gun/revolver/mateba/New()
	..()
	attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 21, "under_x" = 22, "under_y" = 15, "stock_x" = 22, "stock_y" = 15)

/obj/item/weapon/gun/revolver/mateba/set_gun_config_values()
	fire_delay = config.max_fire_delay
	burst_amount = config.low_burst_value
	burst_delay = config.med_fire_delay
	accuracy_mult = config.base_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult - config.high_hit_accuracy_mult
	scatter = config.med_scatter_value
	scatter_unwielded = config.med_scatter_value
	damage_mult = config.base_hit_damage_mult + config.min_hit_damage_mult
	recoil = config.min_recoil_value
	recoil_unwielded = config.med_recoil_value



/obj/item/weapon/gun/revolver/mateba/admiral
	name = "\improper Mateba autorevolver custom++"
	desc = "The Mateba is a powerful, fast-firing revolver that uses its own recoil to rotate the cylinders. This version is snubnosed, engraved with gold, tinted black, and highly customized for a high-ranking admiral. It uses heavy .454 rounds."
	icon_state = "amateba"
	item_state = "amateba"

/obj/item/weapon/gun/revolver/mateba/cmateba
	name = "\improper Mateba autorevolver special"
	desc = "The Mateba is a powerful, fast-firing revolver that uses its own recoil to rotate the cylinders. It uses heavy .454 rounds. This version is a limited edition produced for the USCM, and issued in extremely small amounts. Was a mail-order item back in 2172, and is highly sought after by officers across many different battalions. This one is stamped 'Major Ike Saker, 7th 'Falling Falcons' Battalion.'"
	icon_state = "cmateba"
	item_state = "cmateba"
	New()
		..()
		select_gamemode_skin(/obj/item/weapon/gun/revolver/mateba/cmateba)
//-------------------------------------------------------
//MARSHALS REVOLVER //Spearhead exists in Alien cannon.

/obj/item/weapon/gun/revolver/cmb
	name = "\improper CMB Spearhead autorevolver"
	desc = "An automatic revolver chambered in .357. Commonly issued to Colonial Marshals. It has a burst mode."
	icon_state = "spearhead"
	item_state = "spearhead"
	fire_sound = 'sound/weapons/gun_44mag2.ogg'
	current_mag = /obj/item/ammo_magazine/internal/revolver/cmb
	force = 12
	attachable_allowed = list(
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/quickfire,
						/obj/item/attachable/compensator)

/obj/item/weapon/gun/revolver/cmb/New()
	..()
	attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 22,"rail_x" = 11, "rail_y" = 25, "under_x" = 20, "under_y" = 18, "stock_x" = 20, "stock_y" = 18)

/obj/item/weapon/gun/revolver/cmb/set_gun_config_values()
	fire_delay = config.mhigh_fire_delay*2
	burst_amount = config.med_burst_value
	burst_delay = config.high_fire_delay
	accuracy_mult = config.base_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult - config.med_hit_accuracy_mult
	scatter = config.med_scatter_value
	scatter_unwielded = config.med_scatter_value
	damage_mult = config.base_hit_damage_mult + config.min_hit_damage_mult
	recoil = config.min_recoil_value
	recoil_unwielded = config.med_recoil_value
