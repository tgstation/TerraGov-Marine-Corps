/obj/item/clothing/gloves/captain
	desc = "Regal blue gloves, with a nice gold trim. Swanky."
	name = "captain's gloves"
	icon_state = "captain"
	item_state = "egloves"
	flags_cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	flags_heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/gloves/cyborg
	desc = "beep boop borp"
	name = "cyborg gloves"
	icon_state = "black"
	item_state = "r_hands"
	siemens_coefficient = 1.0

/obj/item/clothing/gloves/swat
	desc = "These tactical gloves are somewhat fire and impact-resistant."
	name = "\improper SWAT Gloves"
	icon_state = "black"
	item_state = "swat_gl"
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
	item_state = "swat_gl"
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
	item_state = "swat_gl"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	flags_cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	flags_heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 15, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)

/obj/item/clothing/gloves/latex
	name = "latex gloves"
	desc = "Sterile latex gloves."
	icon_state = "latex"
	item_state = "lgloves"
	siemens_coefficient = 0.30
	permeability_coefficient = 0.01

/obj/item/clothing/gloves/botanic_leather
	desc = "These leather gloves protect against thorns, barbs, prickles, spikes and other harmful objects of floral origin."
	name = "botanist's leather gloves"
	icon_state = "leather"
	item_state = "ggloves"
	permeability_coefficient = 0.9
	siemens_coefficient = 0.9

//Special type of gloves. Alt click and you get some special nodrop gloves
/obj/item/clothing/gloves/heldgloves
	name = "gloves"
	var/obj/item/weapon/heldglove/right_glove = /obj/item/weapon/heldglove
	var/obj/item/weapon/heldglove/left_glove = /obj/item/weapon/heldglove

/obj/item/clothing/gloves/heldgloves/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>Alt-click the gloves when worn to strap them into your hands.")

/obj/item/clothing/gloves/heldgloves/unequipped(mob/unequipper, slot)
	. = ..()
	remove_gloves(unequipper)

//We use alt-click to activate/deactive the gloves in-hand
/obj/item/clothing/gloves/heldgloves/AltClick(mob/user)
	var/mob/living/carbon/human/wearer = user
	if(wearer.gloves != src) //We have to be wearing the gloves first
		return

	if(!remove_gloves(user))
		return

	user.drop_all_held_items() //Gloves require free hands
	create_gloves(user)

/// Creates the held items for user and puts it in their hand
/obj/item/clothing/gloves/heldgloves/proc/create_gloves(mob/user)
	var/obj/item/weapon/heldglove/boxing/rightglove = new right_glove
	user.put_in_r_hand(rightglove, TRUE)

	var/obj/item/weapon/heldglove/boxing/leftglove = new left_glove
	user.put_in_l_hand(leftglove, TRUE)
	return //See heldgloves/boxing for an example of how to use this

/// Removes gloves. Returns false if gloves are not currently worn
/obj/item/clothing/gloves/heldgloves/proc/remove_gloves(mob/user)
	if(istype(user.l_hand, /obj/item/weapon/heldglove))
		qdel(user.l_hand)
		if(istype(user.r_hand, /obj/item/weapon/heldglove))
			qdel(user.r_hand)
			return FALSE
	if(istype(user.r_hand,/obj/item/weapon/heldglove))
		qdel(user.r_hand)
		return FALSE
	return TRUE

/obj/item/weapon/heldglove
	name = "glove"


//Boxing gloves
/obj/item/clothing/gloves/heldgloves/boxing
	name = "boxing gloves"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon_state = "boxing"
	item_state = "boxing"
	left_glove = /obj/item/weapon/heldglove/boxing/hook
	right_glove = /obj/item/weapon/heldglove/boxing/jab

/obj/item/clothing/gloves/heldgloves/boxing/attackby(obj/item/I, mob/user, params)
	if(iswirecutter(I) || istype(I, /obj/item/tool/surgery/scalpel))
		to_chat(user, span_notice("That won't work."))
		return
	return ..()


/obj/item/weapon/heldglove/boxing
	name = "boxing glove"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon = 'icons/obj/clothing/gloves.dmi'
	icon_state = "boxing"
	item_state = "boxing"
	damtype = STAMINA
	force = 10
	flags_item = NODROP //So we can't lose the gloves
	w_class = WEIGHT_CLASS_BULKY
	hitsound = "punch"

/obj/item/weapon/heldglove/boxing/hook
	attack_verb = list("punched")
/obj/item/weapon/heldglove/boxing/jab
	attack_verb = list("jabbed")


/obj/item/clothing/gloves/heldgloves/boxing/green
	icon_state = "boxinggreen"
	item_state = "boxinggreen"
	left_glove = /obj/item/weapon/heldglove/boxing/hook/green
	right_glove = /obj/item/weapon/heldglove/boxing/jab/green

/obj/item/weapon/heldglove/boxing/hook/green
	icon_state = "boxinggreen"
/obj/item/weapon/heldglove/boxing/jab/green
	icon_state = "boxinggreen"

/obj/item/clothing/gloves/heldgloves/boxing/blue
	icon_state = "boxingblue"
	item_state = "boxingblue"
	left_glove = /obj/item/weapon/heldglove/boxing/hook/blue
	right_glove = /obj/item/weapon/heldglove/boxing/jab/blue

/obj/item/weapon/heldglove/boxing/hook/blue
	icon_state = "boxingblue"
/obj/item/weapon/heldglove/boxing/jab/blue
	icon_state = "boxingblue"

/obj/item/clothing/gloves/heldgloves/boxing/yellow
	icon_state = "boxingyellow"
	item_state = "boxingyellow"
	left_glove = /obj/item/weapon/heldglove/boxing/hook/yellow
	right_glove = /obj/item/weapon/heldglove/boxing/jab/yellow

/obj/item/weapon/heldglove/boxing/hook/yellow
	icon_state = "boxingyellow"
/obj/item/weapon/heldglove/boxing/jab/yellow
	icon_state = "boxingyellow"

/obj/item/clothing/gloves/white
	name = "white gloves"
	desc = "These look pretty fancy."
	icon_state = "latex"
	item_state = "lgloves"

/obj/item/clothing/gloves/techpriest
	name = "Techpriest gloves"
	desc = "Praise the Omnissiah!"
	icon_state = "tp_gloves"
	item_state = "tp_gloves"
