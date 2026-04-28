/obj/item/big_ammo_box
	name = "big ammo box (10x24mm)"
	desc = "A large ammo box. It comes with a leather strap."
	w_class = WEIGHT_CLASS_HUGE
	icon = 'icons/obj/items/ammo/box.dmi'
	icon_state = "big"
	base_icon_state = "big"
	worn_icon_state = "big_ammo_box"
	item_state_worn = TRUE
	equip_slot_flags = ITEM_SLOT_BACK
	worn_icon_list = list(
		slot_back_str = 'icons/mob/clothing/back/ammo.dmi',
		slot_l_hand_str = 'icons/mob/inhands/weapons/ammo_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/ammo_right.dmi',
	)
	///Ammunition typepath
	var/datum/ammo/ammo_type = /datum/ammo/bullet/rifle //this is typecast so we can get initial values using ::
	///Current stored rounds
	var/current_rounds = 2400
	///Maximum stored rounds
	var/max_current_rounds = 2400
	///Caliber of the rounds stored
	var/caliber = CALIBER_10X24_CASELESS
	///Whether the box is deployed or not
	var/deployed = FALSE

/obj/item/big_ammo_box/update_icon_state()
	if(!deployed)
		icon_state = base_icon_state
	else if(current_rounds > 0)
		icon_state = "[base_icon_state]_deployed"
	else
		icon_state = "[base_icon_state]_empty"

/obj/item/big_ammo_box/examine(mob/user)
	. = ..()
	if(current_rounds)
		. += "It contains [current_rounds] round\s."
	else
		. += "It's empty."

/obj/item/big_ammo_box/attack_self(mob/user)
	deployed = TRUE
	update_appearance()
	user.dropItemToGround(src)

/obj/item/big_ammo_box/attack_hand(mob/living/user)
	if(loc == user)
		return ..()

	if(!deployed)
		user.put_in_hands(src)
		return

	if(current_rounds < 1)
		to_chat(user, span_warning("[src] is empty."))
		return

	var/obj/item/ammo_magazine/handful/new_handful = new
	var/rounds = min(current_rounds, ammo_type::handful_amount)

	new_handful.generate_handful(ammo_type, caliber, rounds, ammo_type::handful_amount)
	current_rounds -= rounds

	user.put_in_hands(new_handful)
	to_chat(user, span_notice("You grab <b>[rounds]</b> round\s from [src]."))
	update_appearance()

/obj/item/big_ammo_box/attack_hand_alternate(mob/living/user)
	. = ..()
	if(.)
		return
	attempt_undeploy(user)

/obj/item/big_ammo_box/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(!.)
		return

	if(over != usr)
		return
	attempt_undeploy(over)

/obj/item/big_ammo_box/fire_act(burn_level)
	if(!current_rounds)
		return
	explosion(loc, 0, 0, 1, 0, 0, throw_range = FALSE, explosion_cause="ammo box cookoff")
	qdel(src)

/obj/item/big_ammo_box/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return
	if(!istype(I, /obj/item/ammo_magazine))
		return
	if(!deployed)
		to_chat(user, span_warning("[src] must be deployed."))
		return
	if(!isturf(loc)) //how god
		to_chat(user, span_warning("[src] must be on the ground to be used."))
		return

	var/obj/item/ammo_magazine/mag = I
	if((caliber != mag.caliber) || (ammo_type != mag.default_ammo))
		to_chat(user, span_warning("The rounds don't match up. Better not mix them up."))
		return

	if(mag.magazine_flags & MAGAZINE_HANDFUL)
		store_handful(mag, user)

	else if(mag.magazine_flags & MAGAZINE_REFILLABLE)
		load_mag(mag, user)

///Attempts to fill the mag from src
/obj/item/big_ammo_box/proc/load_mag(obj/item/ammo_magazine/mag, mob/user)
	if(mag.current_rounds == mag.max_rounds)
		to_chat(user, span_warning("[mag] is already full."))
		return

	if(!do_after(user, 0.5 SECONDS, NONE, src, BUSY_ICON_GENERIC))
		return

	var/rounds_to_move = min(current_rounds, mag.max_rounds - mag.current_rounds)
	mag.current_rounds += rounds_to_move
	current_rounds -= rounds_to_move

	update_appearance()
	mag.update_appearance()

	if(mag.current_rounds == mag.max_rounds)
		to_chat(user, span_notice("You refill [mag]."))
	else
		to_chat(user, span_notice("You put [rounds_to_move] rounds in [mag]."))

	playsound(loc, 'sound/weapons/guns/interact/revolver_load.ogg', 25, 1)

///Attempts to store the handful into src
/obj/item/big_ammo_box/proc/store_handful(obj/item/ammo_magazine/loose, mob/user)
	if(current_rounds == max_current_rounds)
		to_chat(user, span_warning("[src] is full!"))
		return

	var/rounds_to_move = min(loose.current_rounds, max_current_rounds - current_rounds)
	loose.current_rounds -= rounds_to_move
	current_rounds += rounds_to_move

	update_appearance()
	if(loose.current_rounds <= 0)
		user.temporarilyRemoveItemFromInventory(loose)
		qdel(loose)
	else
		loose.update_appearance()

	to_chat(user, span_notice("You put [rounds_to_move] rounds in [src]."))
	playsound(loc, 'sound/weapons/guns/interact/revolver_load.ogg', 25, 1)

///Tries to undeploy and pick up src
/obj/item/big_ammo_box/proc/attempt_undeploy(mob/living/user)
	if(!deployed)
		return
	if(!ishuman(user))
		return
	if(!Adjacent(user))
		return
	var/mob/living/carbon/human/human = user
	if(human.incapacitated())
		return
	if(!human.put_in_hands(src))
		return

	deployed = FALSE
	update_appearance()


/obj/item/big_ammo_box/ap
	name = "big ammo box (10x24mm AP)"
	icon_state = "big_ap"
	base_icon_state = "big_ap"
	ammo_type = /datum/ammo/bullet/rifle/ap
	current_rounds = 400 //AP is OP
	max_current_rounds = 400

/obj/item/big_ammo_box/smg
	name = "big ammo box (10x20mm)"
	icon_state = "big_m25"
	base_icon_state = "big_m25"
	worn_icon_state = "big_ammo_box_smg"
	ammo_type = /datum/ammo/bullet/smg
	current_rounds = 4500
	max_current_rounds = 4500
	caliber = CALIBER_10X20_CASELESS

/obj/item/big_ammo_box/mg
	name = "big ammo box (10x26mm)"
	icon_state = "big_mg"
	base_icon_state = "big_mg"
	worn_icon_state = "big_ammo_box_mg"
	ammo_type = /datum/ammo/bullet/rifle/machinegun
	caliber = CALIBER_10x26_CASELESS
	current_rounds = 3200 //a backpack holds 8 MG-60 box mags, which is 1600 rounds
	max_current_rounds = 3200

/obj/item/big_ammo_box/clf_heavyrifle
	name = "big ammo box (14.5mm API)"
	icon_state = "145"
	worn_icon_state = "ammobox_145"
	base_icon_state = "145"
	ammo_type = /datum/ammo/bullet/sniper/clf_heavyrifle
	caliber = CALIBER_14X5
	current_rounds = 200
	max_current_rounds = 200

/obj/item/big_ammo_box/shotgun
	name = "Slug Ammo Box"
	icon_state = "slug"
	base_icon_state = "slug"
	worn_icon_state = "ammoboxslug"
	ammo_type = /datum/ammo/bullet/shotgun/slug
	caliber = CALIBER_12G
	current_rounds = 200
	max_current_rounds = 200

/obj/item/big_ammo_box/shotgun/buckshot
	name = "Buckshot Ammo Box"
	icon_state = "buckshot"
	worn_icon_state = "ammoboxbuckshot"
	base_icon_state = "buckshot"
	ammo_type = /datum/ammo/bullet/shotgun/buckshot

/obj/item/big_ammo_box/shotgun/flechette
	name = "Flechette Ammo Box"
	icon_state = "flechette"
	worn_icon_state = "ammoboxflechette"
	base_icon_state = "flechette"
	ammo_type = /datum/ammo/bullet/shotgun/flechette

/obj/item/big_ammo_box/shotgun/tracker
	name = "Tracking Ammo Box"
	icon_state = "tracking"
	worn_icon_state = "ammoboxtracking"
	base_icon_state = "tracking"
	ammo_type = /datum/ammo/bullet/shotgun/tracker

/obj/item/big_ammo_box/shotgun/blank
	name = "blank ammo box"
	icon_state = "blank"
	worn_icon_state = "ammoboxblank"
	base_icon_state = "blank"
	ammo_type = /datum/ammo/bullet/shotgun/blank
