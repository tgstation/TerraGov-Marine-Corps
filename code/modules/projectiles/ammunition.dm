/obj/item/ammo_magazine
	name = "generic ammo"
	desc = "A box of ammo."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = null
	item_state = "ammo_mag" //PLACEHOLDER. This ensures the mag doesn't use the icon state instead.
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/ammo_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/ammo_right.dmi',
		)
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	throwforce = 2
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 2
	throw_range = 6
	///Icon state in ammo.dmi to an overlay to add to the gun, for extended mags, box mags, and so on
	var/bonus_overlay = null
	///This is a typepath for the type of bullet the magazine holds, it is cast so that it can draw the variable handful_amount from default_ammo in create_handful()
	var/datum/ammo/bullet/default_ammo = /datum/ammo/bullet
	///Generally used for energy weapons
	var/datum/ammo/bullet/overcharge_ammo = /datum/ammo/bullet
	///This is used for matching handfuls to each other or whatever the mag is. The #Defines can be found in __DEFINES/calibers.dm
	var/caliber = null
	///Set this to something else for it not to start with different initial counts.
	var/current_rounds = -1
	///How many rounds it can hold.
	var/max_rounds = 7
	///Set a timer for reloading mags. Higher is slower.
	var/reload_delay = 0 SECONDS
	///Delay for filling this magazine with another one.
	var/fill_delay = 0 SECONDS
	///Just an easier way to track how many shells to eject later.
	var/used_casings = 0
	///flags specifically for magazines.
	var/flags_magazine = MAGAZINE_REFILLABLE
	///the default mag icon state.
	var/base_mag_icon

	//Stats to modify on the gun, just like the attachments do, only has used ones add more as you need.
	var/scatter_mod = 0
	///Increases or decreases scatter chance but for onehanded firing.
	var/scatter_unwielded_mod = 0
	///Changes the slowdown amount when wielding a weapon by this value.
	var/aim_speed_mod = 0
	///How long ADS takes (time before firing)
	var/wield_delay_mod = 0

/obj/item/ammo_magazine/Initialize(mapload, spawn_empty)
	. = ..()
	base_mag_icon = icon_state
	current_rounds = spawn_empty ? 0 : max_rounds
	update_icon()

/obj/item/ammo_magazine/update_icon_state()
	if(CHECK_BITFIELD(flags_magazine, MAGAZINE_HANDFUL))
		setDir(current_rounds + round(current_rounds/3))
		return
	if(current_rounds <= 0)
		icon_state = base_mag_icon + "_e"
		return
	icon_state = base_mag_icon

/obj/item/ammo_magazine/examine(mob/user)
	. = ..()
	. += "[src] has <b>[current_rounds]</b> rounds out of <b>[max_rounds]</b>."


/obj/item/ammo_magazine/attack_hand(mob/living/user)
	if(user.get_inactive_held_item() != src || !CHECK_BITFIELD(flags_magazine, MAGAZINE_REFILLABLE))
		return ..()
	if(current_rounds <= 0)
		to_chat(user, span_notice("[src] is empty. There is nothing to grab."))
		return
	create_handful(user)

/obj/item/ammo_magazine/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!istype(I, /obj/item/ammo_magazine))
		if(!CHECK_BITFIELD(flags_magazine, MAGAZINE_WORN) || !istype(I, /obj/item/weapon/gun) || loc != user)
			return ..()
		var/obj/item/weapon/gun/gun = I
		if(!CHECK_BITFIELD(gun.reciever_flags, AMMO_RECIEVER_MAGAZINES))
			return ..()
		gun.reload(src, user)
		return

	if(!CHECK_BITFIELD(flags_magazine, MAGAZINE_REFILLABLE)) //and a refillable magazine
		return

	if(src != user.get_inactive_held_item() && !CHECK_BITFIELD(flags_magazine, MAGAZINE_HANDFUL)) //It has to be held.
		to_chat(user, span_notice("Try holding [src] before you attempt to restock it."))
		return

	var/obj/item/ammo_magazine/mag = I
	if(default_ammo != mag.default_ammo)
		to_chat(user, span_notice("Those aren't the same rounds. Better not mix them up."))
		return

	var/amount_to_transfer = mag.current_rounds
	transfer_ammo(mag, user, amount_to_transfer)


/obj/item/ammo_magazine/attackby_alternate(obj/item/I, mob/user, params)
	. = ..()
	if(!isgun(I))
		return
	var/obj/item/weapon/gun/gun = I
	if(!gun.active_attachable)
		return
	attackby(gun.active_attachable, user, params)

/obj/item/ammo_magazine/proc/on_inserted(obj/item/weapon/gun/master_gun)
	master_gun.scatter						+= scatter_mod
	master_gun.scatter_unwielded			+= scatter_unwielded_mod
	master_gun.aim_slowdown					+= aim_speed_mod
	master_gun.wield_delay					+= wield_delay_mod


/obj/item/ammo_magazine/proc/on_removed(obj/item/weapon/gun/master_gun)
	master_gun.scatter						-= scatter_mod
	master_gun.scatter_unwielded			-= scatter_unwielded_mod
	master_gun.aim_slowdown					-= aim_speed_mod
	master_gun.wield_delay					-= wield_delay_mod

//Generic proc to transfer ammo between ammo mags. Can work for anything, mags, handfuls, etc.
/obj/item/ammo_magazine/proc/transfer_ammo(obj/item/ammo_magazine/source, mob/user, transfer_amount = 1)
	if(current_rounds >= max_rounds) //Does the mag actually need reloading?
		to_chat(user, span_notice("[src] is already full."))
		return

	if(source.caliber != caliber) //Are they the same caliber?
		to_chat(user, span_notice("The rounds don't match up. Better not mix them up."))
		return

	if(!source.current_rounds)
		to_chat(user, span_warning("\The [source] is empty."))
		return

	//using handfuls; and filling internal mags has no delay.
	if(fill_delay)
		to_chat(user, span_notice("You start refilling [src] with [source]."))
		if(!do_after(user, fill_delay, NONE, src, BUSY_ICON_GENERIC))
			return

	to_chat(user, span_notice("You refill [src] with [source]."))

	var/amount_difference = clamp(min(transfer_amount, max_rounds - current_rounds), 0, source.current_rounds)
	source.current_rounds -= amount_difference
	current_rounds += amount_difference

	if(source.current_rounds <= 0 && CHECK_BITFIELD(source.flags_magazine, MAGAZINE_HANDFUL)) //We want to delete it if it's a handful.
		user?.temporarilyRemoveItemFromInventory(source)
		QDEL_NULL(source) //Dangerous. Can mean future procs break if they reference the source. Have to account for this.
	else
		source.update_icon()

	update_icon()

///This will attempt to place the ammo in the user's hand if possible.
/obj/item/ammo_magazine/proc/create_handful(mob/user, transfer_amount)
	if(current_rounds <= 0)
		return
	var/obj/item/ammo_magazine/handful/new_handful = new /obj/item/ammo_magazine/handful()
	var/rounds = transfer_amount ? min(current_rounds, transfer_amount) : min(current_rounds, initial(default_ammo.handful_amount))
	new_handful.generate_handful(default_ammo, caliber, rounds)
	current_rounds -= rounds

	if(user)
		user.put_in_hands(new_handful)
		to_chat(user, span_notice("You grab <b>[rounds]</b> round\s from [src]."))
		update_icon() //Update the other one.
		if(current_rounds <= 0 && CHECK_BITFIELD(flags_magazine, MAGAZINE_HANDFUL))
			user.temporarilyRemoveItemFromInventory(src)
			qdel(src)
		return rounds //Give the number created.
	else
		update_icon()
		if(current_rounds <= 0 && CHECK_BITFIELD(flags_magazine, MAGAZINE_HANDFUL))
			qdel(src)
		return new_handful

///Called on a /ammo_magazine that wishes to be a handful. It generates all the data required for the handful.
/obj/item/ammo_magazine/proc/generate_handful(new_ammo, new_caliber, new_rounds, maximum_rounds)
	var/datum/ammo/ammo = ispath(new_ammo) ? GLOB.ammo_list[new_ammo] : new_ammo
	var/ammo_name = ammo.name

	///sets greyscale for the handful if it has been specified by the ammo datum
	if (ammo.handful_greyscale_config && ammo.handful_greyscale_colors)
		set_greyscale_config(ammo.handful_greyscale_config)
		set_greyscale_colors(ammo.handful_greyscale_colors)

	name = "handful of [ammo_name + " ([new_caliber])"]"
	icon_state = ammo.handful_icon_state

	default_ammo = new_ammo
	caliber = new_caliber
	if(maximum_rounds)
		max_rounds = maximum_rounds
	else
		max_rounds = ammo.handful_amount
	current_rounds = new_rounds
	update_icon()


//our magazine inherits ammo info from a source magazine
/obj/item/ammo_magazine/proc/match_ammo(obj/item/ammo_magazine/source)
	caliber = source.caliber
	default_ammo = source.default_ammo

/obj/item/ammo_magazine/flamer_fire_act(burnlevel)
	if(!current_rounds)
		return
	explosion(loc, 0, 0, 0, 1, 1, throw_range = FALSE)
	qdel(src)

//Helper proc, to allow us to see a percentage of how full the magazine is.
/obj/item/ammo_magazine/proc/get_ammo_percent()		// return % charge of cell
	return 100.0*current_rounds/max_rounds

/obj/item/ammo_magazine/handful
	name = "generic handful of bullets or shells"
	desc = "A handful of rounds to reload on the go."
	flags_equip_slot = null // It only fits into pockets and such.
	w_class = WEIGHT_CLASS_SMALL
	current_rounds = 1 // So it doesn't get autofilled for no reason.
	max_rounds = 5 // For shotguns, though this will be determined by the handful type when generated.
	flags_atom = CONDUCT|DIRLOCK
	flags_magazine = MAGAZINE_HANDFUL|MAGAZINE_REFILLABLE
	attack_speed = 3 // should make reloading less painful
	icon_state_mini = "bullets"

/obj/item/ammo_magazine/handful/buckshot
	name = "handful of shotgun buckshot shells (12g)"
	icon_state = "shotgun buckshot shell"
	current_rounds = 5
	default_ammo = /datum/ammo/bullet/shotgun/buckshot
	caliber = CALIBER_12G

/obj/item/ammo_magazine/handful/flechette
	name = "handful of shotgun flechette shells (12g)"
	icon_state = "shotgun flechette shell"
	current_rounds = 5
	default_ammo = /datum/ammo/bullet/shotgun/flechette
	caliber = CALIBER_12G

/obj/item/ammo_magazine/handful/incendiary
	name = "handful of shotgun incendiary shells (12g)"
	icon_state = "incendiary slug"
	current_rounds = 5
	default_ammo = /datum/ammo/bullet/shotgun/incendiary
	caliber = CALIBER_12G

/obj/item/ammo_magazine/handful/micro_grenade
	name = "handful of airburst micro grenades (10g)"
	icon_state = "micro_grenade_airburst"
	icon_state_mini = "40mm_cyan"
	current_rounds = 3
	max_rounds = 3
	default_ammo = /datum/ammo/bullet/micro_rail/airburst
	caliber = CALIBER_10G_RAIL

/obj/item/ammo_magazine/handful/micro_grenade/dragonbreath
	name = "handful of dragon's breath micro grenades (10g)"
	icon_state = "micro_grenade_incendiary"
	icon_state_mini = "40mm_orange"
	default_ammo = /datum/ammo/bullet/micro_rail/dragonbreath

/obj/item/ammo_magazine/handful/micro_grenade/cluster
	name = "handful of clustermunition micro grenades (10g)"
	icon_state = "micro_grenade_cluster"
	icon_state_mini = "40mm_red"
	default_ammo = /datum/ammo/bullet/micro_rail/cluster

/obj/item/ammo_magazine/handful/micro_grenade/smoke_burst
	name = "handful of smoke burst micro grenades (10g)"
	icon_state = "micro_grenade_smoke"
	icon_state_mini = "40mm_blue"
	default_ammo = /datum/ammo/bullet/micro_rail/smoke_burst

//----------------------------------------------------------------//

/*
Doesn't do anything or hold anything anymore.
Generated per the various mags, and then changed based on the number of
casings. .dir is the main thing that controls the icon. It modifies
the icon_state to look like more casings are hitting the ground.
There are 8 directions, 8 bullets are possible so after that it tries to grab the next
icon_state while reseting the direction. After 16 casings, it just ignores new
ones. At that point there are too many anyway. Shells and bullets leave different
items, so they do not intersect. This is far more efficient than using Blend() or
Turn() or Shift() as there is virtually no overhead. ~N
*/
/obj/item/ammo_casing
	name = "spent casing"
	desc = "Empty and useless now."
	icon = 'icons/obj/items/casings.dmi'
	icon_state = "casing_"
	throwforce = 1
	w_class = WEIGHT_CLASS_TINY
	layer = LOWER_ITEM_LAYER //Below other objects
	dir = 1 //Always north when it spawns.
	flags_atom = CONDUCT|DIRLOCK
	var/current_casings = 1 //This is manipulated in the procs that use these.
	var/max_casings = 16
	var/current_icon = 0
	var/number_of_states = 10 //How many variations of this item there are.
	var/initial_icon_state = "cartridge_" //holder for icon_state so we can do random variations without effecting mapper visibility

/obj/item/ammo_casing/Initialize(mapload)
	. = ..()
	pixel_x = rand(-2, 2) //Want to move them just a tad.
	pixel_y = rand(-2, 2)
	icon_state = initial_icon_state += "[rand(1, number_of_states)]" //Set the icon to it.

//This does most of the heavy lifting. It updates the icon and name if needed, then changes .dir to simulate new casings.
/obj/item/ammo_casing/update_icon()
	if(max_casings >= current_casings)
		if(current_casings == 2) name += "s" //In case there is more than one.
		if(round((current_casings-1)/8) > current_icon)
			current_icon++
			icon_state += "_[current_icon]"

		var/base_direction = current_casings - (current_icon * 8)
		setDir(base_direction + round(base_direction)/3)
		switch(current_casings)
			if(3 to 5) w_class = WEIGHT_CLASS_SMALL //Slightly heavier.
			if(9 to 10) w_class = WEIGHT_CLASS_NORMAL //Can't put it in your pockets and stuff.


//Making child objects so that locate() and istype() doesn't screw up.
/obj/item/ammo_casing/bullet

/obj/item/ammo_casing/cartridge
	name = "spent cartridge"
	icon_state = "cartridge"

/obj/item/ammo_casing/shell
	name = "spent shell"
	initial_icon_state = "shell_"
	icon_state = "shell"




//Big ammo boxes

/obj/item/big_ammo_box
	name = "big ammo box (10x24mm)"
	desc = "A large ammo box. It comes with a leather strap."
	w_class = WEIGHT_CLASS_HUGE
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "big_ammo_box"
	item_state = "big_ammo_box"
	flags_equip_slot = ITEM_SLOT_BACK
	base_icon_state = "big_ammo_box"
	var/default_ammo = /datum/ammo/bullet/rifle
	var/bullet_amount = 2400
	var/max_bullet_amount = 2400
	var/caliber = CALIBER_10X24_CASELESS

/obj/item/big_ammo_box/update_icon_state()
	if(bullet_amount)
		icon_state = base_icon_state
		return
	icon_state = "[base_icon_state]_e"

/obj/item/big_ammo_box/examine(mob/user)
	. = ..()
	if(bullet_amount)
		. += "It contains [bullet_amount] round\s."
	else
		. += "It's empty."

/obj/item/big_ammo_box/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/AM = I
		if(!isturf(loc))
			to_chat(user, span_warning("[src] must be on the ground to be used."))
			return
		if(AM.flags_magazine & MAGAZINE_REFILLABLE)
			if(default_ammo != AM.default_ammo)
				to_chat(user, span_warning("Those aren't the same rounds. Better not mix them up."))
				return
			if(caliber != AM.caliber)
				to_chat(user, span_warning("The rounds don't match up. Better not mix them up."))
				return
			if(AM.current_rounds == AM.max_rounds)
				to_chat(user, span_warning("[AM] is already full."))
				return

			if(!do_after(user, 15, NONE, src, BUSY_ICON_GENERIC))
				return

			playsound(loc, 'sound/weapons/guns/interact/revolver_load.ogg', 25, 1)
			var/S = min(bullet_amount, AM.max_rounds - AM.current_rounds)
			AM.current_rounds += S
			bullet_amount -= S
			AM.update_icon(S)
			update_icon()
			if(AM.current_rounds == AM.max_rounds)
				to_chat(user, span_notice("You refill [AM]."))
			else
				to_chat(user, span_notice("You put [S] rounds in [AM]."))
		else if(AM.flags_magazine & MAGAZINE_HANDFUL)
			if(caliber != AM.caliber)
				to_chat(user, span_warning("The rounds don't match up. Better not mix them up."))
				return
			if(bullet_amount == max_bullet_amount)
				to_chat(user, span_warning("[src] is full!"))
				return
			playsound(loc, 'sound/weapons/guns/interact/revolver_load.ogg', 25, 1)
			var/S = min(AM.current_rounds, max_bullet_amount - bullet_amount)
			AM.current_rounds -= S
			bullet_amount += S
			AM.update_icon()
			to_chat(user, span_notice("You put [S] rounds in [src]."))
			if(AM.current_rounds <= 0)
				user.temporarilyRemoveItemFromInventory(AM)
				qdel(AM)

//explosion when using flamer procs.
/obj/item/big_ammo_box/flamer_fire_act(burnlevel)
	if(!bullet_amount)
		return
	explosion(loc, 0, 0, 1, 0, 2, throw_range = FALSE) //blow it up.
	qdel(src)

//Deployable shotgun ammo box
/obj/item/shotgunbox
	name = "Slug Ammo Box"
	desc = "A large, deployable ammo box."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "ammoboxslug"
	item_state = "ammoboxslug"
	base_icon_state = "ammoboxslug"
	w_class = WEIGHT_CLASS_HUGE
	flags_equip_slot = ITEM_SLOT_BACK
	///Current stored rounds
	var/current_rounds = 200
	///Maximum stored rounds
	var/max_rounds = 200
	///Ammunition type
	var/datum/ammo/ammo_type = /datum/ammo/bullet/shotgun/slug
	///Whether the box is deployed or not.
	var/deployed = FALSE
	///Caliber of the rounds stored.
	var/caliber = CALIBER_12G


/obj/item/shotgunbox/update_icon()
	if(!deployed)
		icon_state = "[initial(icon_state)]"
	else if(current_rounds > 0)
		icon_state = "[initial(icon_state)]_deployed"
	else
		icon_state = "[initial(icon_state)]_empty"


/obj/item/shotgunbox/attack_self(mob/user)
	deployed = TRUE
	update_icon()
	user.dropItemToGround(src)


/obj/item/shotgunbox/MouseDrop(atom/over_object)
	if(!deployed)
		return

	if(!ishuman(over_object))
		return

	var/mob/living/carbon/human/H = over_object
	if(H == usr && !H.incapacitated() && Adjacent(H) && H.put_in_hands(src))
		deployed = FALSE
		update_icon()


/obj/item/shotgunbox/examine(mob/user)
	. = ..()
	. += "It contains [current_rounds] out of [max_rounds] shotgun shells."


/obj/item/shotgunbox/attack_hand(mob/living/user)
	if(loc == user)
		return ..()

	if(!deployed)
		user.put_in_hands(src)
		return

	if(current_rounds < 1)
		to_chat(user, "<span class='warning'>The [src] is empty.")
		return

	var/obj/item/ammo_magazine/handful/H = new
	var/rounds = min(current_rounds, 5)

	H.generate_handful(ammo_type, caliber, rounds, initial(ammo_type.handful_amount))
	current_rounds -= rounds

	user.put_in_hands(H)
	to_chat(user, span_notice("You grab <b>[rounds]</b> round\s from [src]."))
	update_icon()


/obj/item/shotgunbox/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!istype(I, /obj/item/ammo_magazine/handful))
		return

	var/obj/item/ammo_magazine/handful/H = I

	if(!deployed)
		to_chat(user, span_warning("[src] must be deployed on the ground to be refilled."))
		return

	if(H.default_ammo != ammo_type)
		to_chat(user, span_warning("That's not the right kind of ammo."))
		return

	if(current_rounds == max_rounds)
		to_chat(user, "<span class='warning'>The [src] is already full.")
		return

	current_rounds = min(current_rounds + H.current_rounds, max_rounds)
	qdel(H)
	update_icon()


/obj/item/big_ammo_box/ap
	name = "big ammo box (10x24mm AP)"
	icon_state = "big_ammo_box_ap"
	base_icon_state = "big_ammo_box_ap"
	default_ammo = /datum/ammo/bullet/rifle/ap
	bullet_amount = 400 //AP is OP
	max_bullet_amount = 400

/obj/item/big_ammo_box/smg
	name = "big ammo box (10x20mm)"
	caliber = CALIBER_10X20
	icon_state = "big_ammo_box_m25"
	base_icon_state = "big_ammo_box_m25"
	default_ammo = /datum/ammo/bullet/smg
	bullet_amount = 4500
	max_bullet_amount = 4500
	caliber = CALIBER_10X20_CASELESS

/obj/item/shotgunbox/buckshot
	name = "Buckshot Ammo Box"
	icon_state = "ammoboxbuckshot"
	item_state = "ammoboxbuckshot"
	base_icon_state = "ammoboxbuckshot"
	ammo_type = /datum/ammo/bullet/shotgun/buckshot

/obj/item/shotgunbox/flechette
	name = "Flechette Ammo Box"
	icon_state = "ammoboxflechette"
	item_state = "ammoboxflechette"
	base_icon_state = "ammoboxflechette"
	ammo_type = /datum/ammo/bullet/shotgun/flechette

/obj/item/shotgunbox/clf_heavyrifle
	name = "big ammo box (14.5mm API)"
	caliber = CALIBER_14X5
	icon_state = "ammobox_145"
	item_state = "ammobox_145"
	base_icon_state = "ammobox_145"
	ammo_type = /datum/ammo/bullet/sniper/clf_heavyrifle

/obj/item/shotgunbox/tracker
	name = "Tracking Ammo Box"
	icon_state = "ammoboxtracking"
	item_state = "ammoboxtracking"
	base_icon_state = "ammoboxtracking"
	ammo_type = /datum/ammo/bullet/shotgun/tracker

/obj/item/big_ammo_box/mg
	name = "big ammo box (10x26mm)"
	default_ammo = /datum/ammo/bullet/rifle/machinegun
	caliber = CALIBER_10x26_CASELESS
	bullet_amount = 3200 //a backpack holds 8 MG-60 box mags, which is 1600 rounds
	max_bullet_amount = 3200
