//Generic parent object.
//---------------------------------------------------

/obj/item/weapon/gun/revolver
	flags_equip_slot = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	fire_sound = 'sound/weapons/guns/fire/44mag.ogg'
	reload_sound = 'sound/weapons/guns/interact/revolver_spun.ogg'
	cocked_sound = 'sound/weapons/guns/interact/revolver_cocked.ogg'
	unload_sound = 'sound/weapons/guns/interact/revolver_unload.ogg'
	muzzleflash_iconstate = "muzzle_flash_medium"
	hand_reload_sound = 'sound/weapons/guns/interact/revolver_load.ogg'
	type_of_casings = "bullet"
	load_method = SINGLE_CASING|SPEEDLOADER //codex
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_NO_PITCH_SHIFT_NEAR_EMPTY
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_speed_modifier = 0.75
	aim_fire_delay = 0.25 SECONDS
	wield_delay = 0.2 SECONDS //If you modify your revolver to be two-handed, it will still be fast to aim
	gun_skill_category = GUN_SKILL_PISTOLS

	reciever_flags = AMMO_RECIEVER_HANDFULS|AMMO_RECIEVER_ROTATES_CHAMBER|AMMO_RECIEVER_TOGGLES_OPEN|AMMO_RECIEVER_TOGGLES_OPEN_EJECTS
	max_chamber_items = 7
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver)

	movement_acc_penalty_mult = 3
	fire_delay = 2
	accuracy_mult_unwielded = 0.85
	scatter_unwielded = 25
	recoil = 2
	recoil_unwielded = 3

	placed_overlay_iconstate = "revolver"

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


/obj/item/weapon/gun/revolver/verb/revolvertrick()
	set category = "Weapons"
	set name = "Do a revolver trick"
	set desc = "Show off to all your friends!"
	var/obj/item/weapon/gun/revolver/gun = get_active_firearm(usr)
	if(!gun)
		return
	if(!istype(gun))
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
	if(!loc || !user)
		return
	invisibility = 0
	playsound(user, thud_sound, 25, 1)

	if(user.get_active_held_item() != src)
		return

	if(user.get_inactive_held_item())
		user.visible_message("[user] catches [src] with the same hand!",span_notice(" You catch [src] as it spins in to your hand!"))
		return
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

/obj/item/weapon/gun/revolver/proc/revolver_basic_spin(mob/living/carbon/human/user, direction = 1, obj/item/weapon/gun/revolver/double)
	set waitfor = 0
	playsound(user, spin_sound, 25, 1)
	if(double)
		user.visible_message("[user] deftly flicks and spins [src] and [double]!",span_notice(" You flick and spin [src] and [double]!"))
		animation_wrist_flick(double, 1)
	else
		user.visible_message("[user] deftly flicks and spins [src]!",span_notice(" You flick and spin [src]!"))
	animation_wrist_flick(src, direction)
	sleep(3)
	if(loc && user) playsound(user, thud_sound, 25, 1)

//-------------------------------------------------------
//R-44 COMBAT REVOLVER

/obj/item/weapon/gun/revolver/standard_revolver
	name = "\improper R-44 combat revolver"
	desc = "The R-44 standard combat revolver, produced by Terran Armories. A sturdy and hard hitting firearm that loads .44 Magnum rounds. Holds 7 rounds in the cylinder. Due to an error in the cylinder rotation system the fire rate of the gun is much faster than intended, it ended up being billed as a feature of the system."
	icon_state = "tp44"
	item_state = "tp44"
	caliber =  CALIBER_44 //codex
	max_chamber_items = 7 //codex
	default_ammo_type = /obj/item/ammo_magazine/revolver/standard_revolver
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver/standard_revolver)
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
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
	)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 13, "rail_y" = 23, "under_x" = 22, "under_y" = 14, "stock_x" = 22, "stock_y" = 19)
	fire_delay = 0.15 SECONDS
	akimbo_additional_delay = 0.6 // Ends up as 0.249, so it'll get moved up to 0.25.
	accuracy_mult_unwielded = 0.85
	accuracy_mult = 1
	scatter_unwielded = 15
	scatter = -1
	recoil = 0
	recoil_unwielded = 0.75

/obj/item/weapon/gun/revolver/standard_revolver/Initialize(mapload, spawn_empty)
	. = ..()
	if(round(rand(1, 10), 1) != 1)
		return
	base_gun_icon = "tp44cool"
	update_icon()

//-------------------------------------------------------
//RUSSIAN REVOLVER //Based on the 7.62mm Russian revolvers.

/obj/item/weapon/gun/revolver/upp
	name = "\improper N-Y 7.62mm revolver"
	desc = "The Nagant-Yamasaki 7.62 is an effective killing machine designed by a consortion of shady Not-Americans. It is frequently found in the hands of criminals or mercenaries."
	icon_state = "ny762"
	item_state = "ny762"
	caliber = CALIBER_762X38 //codex
	max_chamber_items = 7 //codex
	fire_sound = 'sound/weapons/guns/fire/ny.ogg'
	default_ammo_type = /obj/item/ammo_magazine/revolver/upp
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver/upp)
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
	max_chamber_items = 6 //codex
	fire_sound = 'sound/weapons/guns/fire/revolver.ogg'
	default_ammo_type = /obj/item/ammo_magazine/revolver/small
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver/small)
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
	name = "\improper R-24 autorevolver"
	desc = "The R-24 is the rather rare autorevolver used by the TGMC issued in rather small numbers to backline personnel and officers it uses recoil to spin the cylinder. Uses heavy .454 rounds."
	icon_state = "mateba"
	item_state = "mateba"
	fire_animation = "mateba_fire"
	muzzleflash_iconstate = "muzzle_flash"
	caliber = CALIBER_454 //codex
	max_chamber_items = 6 //codex
	fire_sound = 'sound/weapons/guns/fire/mateba.ogg'
	default_ammo_type = /obj/item/ammo_magazine/revolver/mateba
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver/mateba)
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
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
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
	scatter = 5
	accuracy_mult_unwielded = 0.6
	scatter_unwielded = 20

/obj/item/weapon/gun/revolver/mateba/notmarine
	name = "\improper Mateba autorevolver"
	desc = "The Mateba is a powerful, fast-firing revolver that uses its own recoil to rotate the cylinders. Uses .454 rounds."


/obj/item/weapon/gun/revolver/mateba/custom
	name = "\improper R-24 autorevolver special"
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
	max_chamber_items = 6 //codex
	fire_sound = 'sound/weapons/guns/fire/revolver_light.ogg'
	default_ammo_type = /obj/item/ammo_magazine/revolver/cmb
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver/cmb)
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

//-------------------------------------------------------
//The Judge, a shotgun and revolver in one

/obj/item/weapon/gun/revolver/judge
	name = "\improper 'Judge' revolver"
	desc = "An incredibly uncommon revolver utilizing a oversized chamber to be able to both fire 45 Long at the cost of firing speed. Normal rounds have no falloff, and next to no scatter. Due to the short barrel, buckshot out of it has high spread."
	icon_state = "judge"
	item_state = "m44"
	fire_animation = "judge_fire"
	caliber = CALIBER_45L //codex
	max_chamber_items = 5 //codex
	default_ammo_type = /obj/item/ammo_magazine/revolver/judge
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/revolver/judge,
		/obj/item/ammo_magazine/revolver/judge/buckshot,
	)
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
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/lace,
	)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 22,"rail_x" = 17, "rail_y" = 22, "under_x" = 22, "under_y" = 17, "stock_x" = 22, "stock_y" = 19)

	fire_delay = 0.35 SECONDS
	recoil = 0
	scatter = 8 // Only affects buckshot considering marksman has -15 scatter.
	damage_falloff_mult = 1.2


//Single action revolvers below
//---------------------------------------------------

/obj/item/weapon/gun/revolver/single_action //This town aint big enuf fer the two of us
	name = "single action revolver"
	desc = "you should not be seeing this."
	reload_sound = 'sound/weapons/guns/interact/revolver_cocked.ogg'
	cocked_sound = 'sound/weapons/guns/interact/revolver_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/revolver/standard_revolver
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver/standard_revolver)
	reciever_flags = AMMO_RECIEVER_HANDFULS|AMMO_RECIEVER_ROTATES_CHAMBER|AMMO_RECIEVER_TOGGLES_OPEN|AMMO_RECIEVER_TOGGLES_OPEN_EJECTS|AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION|AMMO_RECIEVER_UNIQUE_ACTION_LOCKS
	cocked_message = "You prime the hammer."
	cock_delay = 0



//-------------------------------------------------------
//R-44, based off the SAA.

/obj/item/weapon/gun/revolver/single_action/m44
	name = "\improper R-44 SAA revolver"
	desc = "A uncommon revolver occasionally carried by civilian law enforcement that's very clearly based off a modernized Single Action Army. Has to be manully primed with each shot. Uses .44 Magnum rounds."
	icon_state = "m44"
	item_state = "m44"
	caliber = CALIBER_44 //codex
	max_chamber_items = 6
	default_ammo_type = /obj/item/ammo_magazine/revolver
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver)
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
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/lace,
	)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 22,"rail_x" = 17, "rail_y" = 22, "under_x" = 22, "under_y" = 17, "stock_x" = 22, "stock_y" = 19)

	fire_delay = 0.15 SECONDS
