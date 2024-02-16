/obj/item/clothing/gloves/captain
	desc = "Regal blue gloves, with a nice gold trim. Swanky."
	name = "captain's gloves"
	icon_state = "captain"
	flags_cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	flags_heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/gloves/swat
	desc = "These tactical gloves are somewhat fire and impact-resistant."
	name = "\improper SWAT Gloves"
	icon_state = "black"
	siemens_coefficient = 0.6
	permeability_coefficient = 0.05

	flags_cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	flags_heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/gloves/combat //Combined effect of SWAT gloves and insulated gloves
	desc = "These tactical gloves are somewhat fire and impact resistant."
	name = "combat gloves"
	icon_state = "black"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	flags_cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	flags_heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/gloves/ruggedgloves
	desc = "A pair of gloves used by workers in dangerous environments."
	name = "rugged gloves"
	icon_state = "black"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	flags_cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	flags_heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 15, ENERGY = 10, BOMB = 10, BIO = 10, FIRE = 10, ACID = 10)

/obj/item/clothing/gloves/latex
	name = "latex gloves"
	desc = "Sterile latex gloves."
	icon_state = "latex"
	siemens_coefficient = 0.30
	permeability_coefficient = 0.01

/obj/item/clothing/gloves/latex/blue
	icon_state = "bluelatex"

/obj/item/clothing/gloves/botanic_leather
	desc = "These leather gloves protect against thorns, barbs, prickles, spikes and other harmful objects of floral origin."
	name = "botanist's leather gloves"
	icon_state = "leather"
	permeability_coefficient = 0.9
	siemens_coefficient = 0.9

//Special type of gloves. Alt click and you get some special nodrop gloves
/obj/item/clothing/gloves/heldgloves
	name = "gloves"
	/// What type of glove we use for the right hand
	var/rightglove_path
	/// What type of glove we use for the left hand
	var/leftglove_path
	/// The glove we're currently using in the right hand
	var/obj/item/weapon/heldglove/rightglove
	/// The glove we're currently using in the left hand
	var/obj/item/weapon/heldglove/leftglove

/obj/item/clothing/gloves/heldgloves/Destroy()
	QDEL_NULL(rightglove)
	QDEL_NULL(leftglove)
	return ..()

/obj/item/clothing/gloves/heldgloves/examine(mob/user)
	. = ..()
	. += "Alt-click the gloves when worn to strap them into your hands."

/obj/item/clothing/gloves/heldgloves/unequipped(mob/unequipper, slot)
	. = ..()
	remove_gloves(unequipper)
	REMOVE_TRAIT(src, TRAIT_NODROP, HELDGLOVE_TRAIT)

//We use alt-click to activate/deactive the gloves in-hand
/obj/item/clothing/gloves/heldgloves/AltClick(mob/user)
	var/mob/living/carbon/human/wearer = user
	if(wearer.gloves != src) //We have to be wearing the gloves first
		return

	if(remove_gloves(user))
		REMOVE_TRAIT(src, TRAIT_NODROP, HELDGLOVE_TRAIT)
		return

	user.drop_all_held_items() //Gloves require free hands
	if(create_gloves(user))
		ADD_TRAIT(src, TRAIT_NODROP, HELDGLOVE_TRAIT) //Make sure the gloves aren't able to be taken off

/// Creates the held items for user and puts it in their hand
/obj/item/clothing/gloves/heldgloves/proc/create_gloves(mob/user)
	if(user.l_hand || user.r_hand)
		return FALSE

	rightglove = new rightglove_path()
	leftglove = new leftglove_path()

	if(user.put_in_r_hand(rightglove, TRUE) && user.put_in_l_hand(leftglove, TRUE))
		return TRUE

/// Removes gloves. Returns false if gloves are not currently worn
/obj/item/clothing/gloves/heldgloves/proc/remove_gloves(mob/user)
	var/removed = FALSE
	if(leftglove)
		QDEL_NULL(leftglove)
		removed = TRUE
	if(rightglove)
		QDEL_NULL(rightglove)
		removed = TRUE
	return removed

/obj/item/weapon/heldglove
	name = "glove"

/obj/item/weapon/heldglove/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HELDGLOVE_TRAIT)

//Boxing gloves
/obj/item/clothing/gloves/heldgloves/boxing
	name = "boxing gloves"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon = 'icons/obj/clothing/boxing.dmi'
	icon_state = "boxing"
	rightglove_path = /obj/item/weapon/heldglove/boxing/hook
	leftglove_path = /obj/item/weapon/heldglove/boxing/jab

/obj/item/clothing/gloves/heldgloves/boxing/attackby(obj/item/I, mob/user, params)
	if(iswirecutter(I) || istype(I, /obj/item/tool/surgery/scalpel))
		to_chat(user, span_notice("That won't work."))
		return
	return ..()


/obj/item/weapon/heldglove/boxing
	name = "boxing glove"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon = 'icons/obj/clothing/boxing.dmi'
	icon_state = "boxing"
	damtype = STAMINA
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	hitsound = "punch"

/obj/item/weapon/heldglove/boxing/attack(mob/living/M, mob/living/user)
	. = ..()
	if(!ishuman(M))
		return

	var/mob/living/carbon/human/target = M
	if(!(target.getStaminaLoss() > 10 && (target.stat != UNCONSCIOUS)))
		return

	playsound(loc, 'sound/effects/knockout.ogg', 25, FALSE)
	target.balloon_alert_to_viewers("[target] collapses to the ground in exhaustion! K.O!", "You give up and collapse! K.O!")
	target.Sleeping(10 SECONDS)

/obj/item/weapon/heldglove/boxing/hook
	icon_state = "boxing_p"
	attack_verb = list("punched")

/obj/item/weapon/heldglove/boxing/jab
	icon_state = "boxing_j"
	attack_verb = list("jabbed")


/obj/item/clothing/gloves/heldgloves/boxing/green
	icon_state = "boxinggreen"
	rightglove_path = /obj/item/weapon/heldglove/boxing/hook/green
	leftglove_path = /obj/item/weapon/heldglove/boxing/jab/green

/obj/item/weapon/heldglove/boxing/hook/green
	icon_state = "boxing_p_g"

/obj/item/weapon/heldglove/boxing/jab/green
	icon_state = "boxing_j_g"

/obj/item/clothing/gloves/heldgloves/boxing/blue
	icon_state = "boxingblue"
	rightglove_path = /obj/item/weapon/heldglove/boxing/hook/blue
	leftglove_path = /obj/item/weapon/heldglove/boxing/jab/blue

/obj/item/weapon/heldglove/boxing/hook/blue
	icon_state = "boxing_p_b"

/obj/item/weapon/heldglove/boxing/jab/blue
	icon_state = "boxing_j_b"

/obj/item/clothing/gloves/heldgloves/boxing/yellow
	icon_state = "boxingyellow"
	rightglove_path = /obj/item/weapon/heldglove/boxing/hook/yellow
	leftglove_path = /obj/item/weapon/heldglove/boxing/jab/yellow

/obj/item/weapon/heldglove/boxing/hook/yellow
	icon_state = "boxing_p_y"

/obj/item/weapon/heldglove/boxing/jab/yellow
	icon_state = "boxing_j_y"

//Punching bag. Both punches and attacking with weapons causes it to
/obj/structure/punching_bag
	name = "punching bag"
	desc = "A Nanotrasen punching bag. A common sight this far from Sol.\nCheap and flimsy, might break if hit by something too heavy."
	max_integrity = 750 //This is going to get hit, a lot
	icon = 'icons/obj/clothing/boxing.dmi'
	icon_state = "punchingbag"

/obj/structure/punching_bag/attackby(obj/item/I, mob/user, params)
	. = ..()
	flick("[icon_state]-punch", src)

/obj/item/clothing/gloves/white
	name = "white gloves"
	desc = "These look pretty fancy."
	icon_state = "white"

/obj/item/clothing/gloves/techpriest
	name = "Techpriest gloves"
	desc = "Praise the Omnissiah!"
	icon_state = "tp_gloves"
