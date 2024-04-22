/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/stack_objects.dmi'
	amount = 6
	max_amount = 6
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 7
	resistance_flags = FLAMMABLE
	max_integrity = 40
	novariants = FALSE
	item_flags = NOBLUDGEON
	var/self_delay = 50
	var/other_delay = 100
	var/repeating = FALSE

/obj/item/stack/medical/attack(mob/living/M, mob/user)
	. = ..()
	try_heal(M, user)


/obj/item/stack/medical/proc/try_heal(mob/living/M, mob/user, silent = FALSE)
	if(!M.can_inject(user, TRUE))
		return
	if(M == user)
		if(!silent)
			user.visible_message("<span class='notice'>[user] starts to apply \the [src] on [user.p_them()]self...</span>", "<span class='notice'>I begin applying \the [src] on myself...</span>")
		if(!do_mob(user, M, self_delay, extra_checks=CALLBACK(M, TYPE_PROC_REF(/mob/living, can_inject), user, TRUE)))
			return
	else if(other_delay)
		if(!silent)
			user.visible_message("<span class='notice'>[user] starts to apply \the [src] on [M].</span>", "<span class='notice'>I begin applying \the [src] on [M]...</span>")
		if(!do_mob(user, M, other_delay, extra_checks=CALLBACK(M, TYPE_PROC_REF(/mob/living, can_inject), user, TRUE)))
			return

	if(heal(M, user))
		log_combat(user, M, "healed", src.name)
		use(1)
		if(repeating && amount > 0)
			try_heal(M, user, TRUE)

/obj/item/stack/medical/proc/heal(mob/living/M, mob/user)
	return

/obj/item/stack/medical/proc/heal_carbon(mob/living/carbon/C, mob/user, brute, burn)
	var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(user.zone_selected))
	if(!affecting) //Missing limb?
		to_chat(user, "<span class='warning'>[C] doesn't have \a [parse_zone(user.zone_selected)]!</span>")
		return
	if(affecting.status == BODYPART_ORGANIC) //Limb must be organic to be healed - RR
		if(affecting.brute_dam && brute || affecting.burn_dam && burn)
			user.visible_message("<span class='green'>[user] applies \the [src] on [C]'s [affecting.name].</span>", "<span class='green'>I apply \the [src] on [C]'s [affecting.name].</span>")
			if(affecting.heal_damage(brute, burn))
				C.update_damage_overlays()
			return TRUE
		to_chat(user, "<span class='warning'>[C]'s [affecting.name] can not be healed with \the [src]!</span>")
		return
	to_chat(user, "<span class='warning'>\The [src] won't work on a robotic limb!</span>")

/obj/item/stack/medical/bruise_pack
	name = "bruise pack"
	singular_name = "bruise pack"
	desc = ""
	icon_state = "brutepack"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	var/heal_brute = 40
	self_delay = 20
	grind_results = list(/datum/reagent/medicine/C2/libital = 10)

/obj/item/stack/medical/bruise_pack/heal(mob/living/M, mob/user)
	if(M.stat == DEAD)
		to_chat(user, "<span class='warning'>[M] is dead! You can not help [M.p_them()].</span>")
		return
	if(isanimal(M))
		var/mob/living/simple_animal/critter = M
		if (!(critter.healable))
			to_chat(user, "<span class='warning'>I cannot use \the [src] on [M]!</span>")
			return FALSE
		else if (critter.health == critter.maxHealth)
			to_chat(user, "<span class='notice'>[M] is at full health.</span>")
			return FALSE
		user.visible_message("<span class='green'>[user] applies \the [src] on [M].</span>", "<span class='green'>I apply \the [src] on [M].</span>")
		M.heal_bodypart_damage((heal_brute/2))
		return TRUE
	if(iscarbon(M))
		return heal_carbon(M, user, heal_brute, 0)
	to_chat(user, "<span class='warning'>I can't heal [M] with the \the [src]!</span>")

/obj/item/stack/medical/bruise_pack/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is bludgeoning [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/stack/medical/gauze
	name = "bandages"
	desc = ""
	gender = PLURAL
	singular_name = "bandage"
	icon_state = "gauze"
	var/stop_bleeding = 3000
	self_delay = 100
	max_amount = 12
	grind_results = list(/datum/reagent/cellulose = 2)
	//dropshrink = 0.5

/obj/item/stack/medical/gauze/heal(mob/living/M, mob/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!H.bleedsuppress && H.bleed_rate) //so you can't stack bleed suppression
			H.suppress_bloodloss(stop_bleeding)
			to_chat(user, "<span class='notice'>I bandage [M].</span>")
			return TRUE
	to_chat(user, "<span class='warning'>I can not use \the [src] on [M].</span>")
/*
/obj/item/stack/medical/gauze/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WIRECUTTER || I.get_sharpness())
		if(get_amount() < 2)
			to_chat(user, "<span class='warning'>I need at least two gauzes to do this!</span>")
			return
		new /obj/item/stack/sheet/cloth(user.drop_location())
		user.visible_message("<span class='notice'>[user] cuts [src] into pieces of cloth with [I].</span>", \
					 "<span class='notice'>I cut [src] into pieces of cloth with [I].</span>", \
					 "<span class='hear'>I hear cutting.</span>")
		use(2)
	else
		return ..()*/

/obj/item/stack/medical/gauze/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] begins tightening \the [src] around [user.p_their()] neck! It looks like [user.p_they()] forgot how to use medical supplies!</span>")
	return OXYLOSS

/obj/item/stack/medical/gauze/improvised
	name = "improvised gauze"
	singular_name = "improvised gauze"
	desc = ""
	stop_bleeding = 900

/obj/item/stack/medical/gauze/cyborg
	custom_materials = null
	is_cyborg = 1
	cost = 250

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = ""
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	var/heal_burn = 40
	self_delay = 20
	grind_results = list(/datum/reagent/medicine/C2/lenturi = 10)

/obj/item/stack/medical/ointment/heal(mob/living/M, mob/user)
	if(M.stat == DEAD)
		to_chat(user, "<span class='warning'>[M] is dead! You can not help [M.p_them()].</span>")
		return
	if(iscarbon(M))
		return heal_carbon(M, user, 0, heal_burn)
	to_chat(user, "<span class='warning'>I can't heal [M] with the \the [src]!</span>")

/obj/item/stack/medical/ointment/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] is squeezing \the [src] into [user.p_their()] mouth! [user.p_do(TRUE)]n't [user.p_they()] know that stuff is toxic?</span>")
	return TOXLOSS

/obj/item/stack/medical/suture
	name = "suture"
	desc = ""
	gender = PLURAL
	singular_name = "suture"
	icon_state = "suture"
	self_delay = 30
	other_delay = 10
	amount = 15
	max_amount = 15
	repeating = TRUE
	var/heal_brute = 10
	grind_results = list(/datum/reagent/medicine/spaceacillin = 2)

/obj/item/stack/medical/suture/medicated
	name = "medicated suture"
	icon_state = "suture_purp"
	desc = ""
	heal_brute = 15
	grind_results = list(/datum/reagent/medicine/polypyr = 2)

/obj/item/stack/medical/suture/heal(mob/living/M, mob/user)
	. = ..()
	if(M.stat == DEAD)
		to_chat(user, "<span class='warning'>[M] is dead! You can not help [M.p_them()].</span>")
		return
	if(iscarbon(M))
		return heal_carbon(M, user, heal_brute, 0)
	if(isanimal(M))
		var/mob/living/simple_animal/critter = M
		if (!(critter.healable))
			to_chat(user, "<span class='warning'>I cannot use \the [src] on [M]!</span>")
			return FALSE
		else if (critter.health == critter.maxHealth)
			to_chat(user, "<span class='notice'>[M] is at full health.</span>")
			return FALSE
		user.visible_message("<span class='green'>[user] applies \the [src] on [M].</span>", "<span class='green'>I apply \the [src] on [M].</span>")
		M.heal_bodypart_damage(heal_brute)
		return TRUE

	to_chat(user, "<span class='warning'>I can't heal [M] with the \the [src]!</span>")

/obj/item/stack/medical/mesh
	name = "regenerative mesh"
	desc = ""
	gender = PLURAL
	singular_name = "regenerative mesh"
	icon_state = "regen_mesh"
	self_delay = 30
	other_delay = 10
	amount = 15
	max_amount = 15
	repeating = TRUE
	var/heal_burn = 10
	var/is_open = TRUE ///This var determines if the sterile packaging of the mesh has been opened.
	grind_results = list(/datum/reagent/medicine/spaceacillin = 2)

/obj/item/stack/medical/mesh/Initialize()
	..()
	if(amount == max_amount)	 //only seal full mesh packs
		is_open = FALSE
		icon_state = "regen_mesh_closed"


/obj/item/stack/medical/mesh/update_icon()
	if(!is_open)
		return
	. = ..()

/obj/item/stack/medical/mesh/heal(mob/living/M, mob/user)
	. = ..()
	if(M.stat == DEAD)
		to_chat(user, "<span class='warning'>[M] is dead! You can not help [M.p_them()].</span>")
		return
	if(iscarbon(M))
		return heal_carbon(M, user, 0, heal_burn)
	to_chat(user, "<span class='warning'>I can't heal [M] with the \the [src]!</span>")


/obj/item/stack/medical/mesh/try_heal(mob/living/M, mob/user, silent = FALSE)
	if(!is_open)
		to_chat(user, "<span class='warning'>I need to open [src] first.</span>")
		return
	. = ..()

/obj/item/stack/medical/mesh/AltClick(mob/living/user)
	if(!is_open)
		to_chat(user, "<span class='warning'>I need to open [src] first.</span>")
		return
	. = ..()

/obj/item/stack/medical/mesh/attack_hand(mob/user)
	if(!is_open & user.get_inactive_held_item() == src)
		to_chat(user, "<span class='warning'>I need to open [src] first.</span>")
		return
	. = ..()

/obj/item/stack/medical/mesh/attack_self(mob/user)
	if(!is_open)
		is_open = TRUE
		to_chat(user, "<span class='notice'>I open the sterile mesh package.</span>")
		update_icon()
		playsound(src, 'sound/blank.ogg', 20, TRUE)
		return
	. = ..()

	/*
	The idea is for these medical devices to work like a hybrid of the old brute packs and tend wounds,
	they heal a little at a time, have reduced healing density and does not allow for rapid healing while in combat.
	However they provice graunular control of where the healing is directed, this makes them better for curing work-related cuts and scrapes.

	The interesting limb targeting mechanic is retained and i still believe they will be a viable choice, especially when healing others in the field.
	 */

