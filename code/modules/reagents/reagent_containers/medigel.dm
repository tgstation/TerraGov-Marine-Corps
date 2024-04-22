/obj/item/reagent_containers/medigel
	name = "medical gel"
	desc = ""
	icon = 'icons/obj/chemical.dmi'
	icon_state = "medigel"
	item_state = "spraycan"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	item_flags = NOBLUDGEON
	obj_flags = UNIQUE_RENAME
	reagent_flags = OPENCONTAINER
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	amount_per_transfer_from_this = 10
	volume = 60
	var/can_fill_from_container = TRUE
	var/apply_type = PATCH
	var/apply_method = "spray" //the thick gel is sprayed and then dries into patch like film.
	var/self_delay = 30
	var/squirt_mode = 0
	var/squirt_amount = 5
	custom_price = 40

/obj/item/reagent_containers/medigel/attack_self(mob/user)
	squirt_mode = !squirt_mode
	if(squirt_mode)
		amount_per_transfer_from_this = squirt_amount
	else
		amount_per_transfer_from_this = initial(amount_per_transfer_from_this)
	to_chat(user, "<span class='notice'>I will now apply the medigel's contents in [squirt_mode ? "short bursts":"extended sprays"]. You'll now use [amount_per_transfer_from_this] units per use.</span>")

/obj/item/reagent_containers/medigel/attack(mob/M, mob/user, def_zone)
	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return

	if(M == user)
		M.visible_message("<span class='notice'>[user] attempts to [apply_method] [src] on [user.p_them()]self.</span>")
		if(self_delay)
			if(!do_mob(user, M, self_delay))
				return
			if(!reagents || !reagents.total_volume)
				return
		to_chat(M, "<span class='notice'>I [apply_method] myself with [src].</span>")

	else
		log_combat(user, M, "attempted to apply", src, reagents.log_list())
		M.visible_message("<span class='danger'>[user] attempts to [apply_method] [src] on [M].</span>", \
							"<span class='danger'>[user] attempts to [apply_method] [src] on you.</span>")
		if(!do_mob(user, M))
			return
		if(!reagents || !reagents.total_volume)
			return
		M.visible_message("<span class='danger'>[user] [apply_method]s [M] down with [src].</span>", \
							"<span class='danger'>[user] [apply_method]s you down with [src].</span>")

	if(!reagents || !reagents.total_volume)
		return

	else
		log_combat(user, M, "applied", src, reagents.log_list())
		playsound(src, 'sound/blank.ogg', 30, TRUE, -6)
		reagents.trans_to(M, amount_per_transfer_from_this, transfered_by = user, method = apply_type)
	return

/obj/item/reagent_containers/medigel/libital
	name = "medical gel (libital)"
	desc = ""
	icon_state = "brutegel"
	list_reagents = list(/datum/reagent/medicine/C2/libital = 20, /datum/reagent/medicine/granibitaluri = 40)

/obj/item/reagent_containers/medigel/aiuri
	name = "medical gel (aiuri)"
	desc = ""
	icon_state = "burngel"
	list_reagents = list(/datum/reagent/medicine/C2/aiuri = 20, /datum/reagent/medicine/granibitaluri = 40)

/obj/item/reagent_containers/medigel/instabitaluri
	name = "medical gel (instabitaluri)"
	desc = ""
	icon_state = "synthgel"
	list_reagents = list(/datum/reagent/medicine/C2/instabitaluri = 60)
	custom_price = 80

/obj/item/reagent_containers/medigel/sterilizine
	name = "sterilizer gel"
	desc = ""
	list_reagents = list(/datum/reagent/space_cleaner/sterilizine = 60)
