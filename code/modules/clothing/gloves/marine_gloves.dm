


//marine gloves

/obj/item/clothing/gloves/marine
	name = "marine combat gloves"
	desc = "Standard issue marine tactical gloves. It reads: 'knit by Marine Widows Association'."
	icon_state = "gloves_marine_medic"
	item_state = "gloves_marine"
	siemens_coefficient = 0.6
	permeability_coefficient = 0.05
	flags_cold_protection = HANDS
	flags_heat_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	flags_armor_protection = HANDS
	soft_armor = list(MELEE = 25, BULLET = 15, LASER = 10, ENERGY = 15, BOMB = 15, BIO = 5, "rad" = 5, FIRE = 15, ACID = 15)

/obj/item/clothing/gloves/marine/insulated
	name = "insulated marine combat gloves"
	desc = "Insulated marine tactical gloves that protect against electrical shocks."
	siemens_coefficient = 0

/obj/item/clothing/gloves/marine/corpsman
	name = "Advanced medical combat gloves"
	desc = "Advanced medical gloves, these include small electrodes to defibrilate a patiant. No more bulky units!"
	var/obj/item/defibrillator/DF

/obj/item/clothing/gloves/marine/corpsman/Initialize()
	. = ..()
	DF = new()
	DF.ready = TRUE

/obj/item/clothing/gloves/marine/corpsman/equipped(mob/user, slot)
	. = ..()
	RegisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, .proc/try_defib)

/obj/item/clothing/gloves/marine/corpsman/unequipped(mob/unequipper, slot)
	UnregisterSignal(unequipper,COMSIG_HUMAN_MELEE_UNARMED_ATTACK)
	. = ..()

/obj/item/clothing/gloves/marine/corpsman/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(istype(over,/obj/item/storage/backpack/marine/corpsman))
		if(!usr || !over || QDELETED(src))
			return
		if(!Adjacent(usr) || !over.Adjacent(usr))
			return
		over.MouseDrop_T(DF,usr)


/obj/item/clothing/gloves/marine/corpsman/proc/try_defib(mob/self, atom/target)
	if(!istype(loc,/mob/living/carbon/human))
		return
	var/mob/living/carbon/human/user = loc

	if(user.a_intent == INTENT_HELP)
		DF.attack(target,user)

/obj/item/clothing/gloves/marine/officer
	name = "officer gloves"
	desc = "Shiny and impressive. They look expensive."
	icon_state = "black"
	item_state = "bgloves"

/obj/item/clothing/gloves/marine/officer/chief
	name = "chief officer gloves"
	desc = "Blood crusts are attached to its metal studs, which are slightly dented."

/obj/item/clothing/gloves/marine/officer/chief/sa
	name = "spatial agent's gloves"
	desc = "Gloves worn by a Spatial Agent."
	siemens_coefficient = 0
	permeability_coefficient = 0

/obj/item/clothing/gloves/marine/techofficer
	name = "tech officer gloves"
	desc = "Sterile AND insulated! Why is not everyone issued with these?"
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.01

/obj/item/clothing/gloves/marine/techofficer/captain
	name = "captain's gloves"
	desc = "You may like these gloves, but THEY think you are unworthy of them."
	icon_state = "captain"
	item_state = "egloves"

/obj/item/clothing/gloves/marine/specialist
	name = "\improper B18 defensive gauntlets"
	desc = "A pair of heavily armored gloves."
	icon_state = "armored"
	item_state = "bgloves"
	flags_item = SYNTH_RESTRICTED
	soft_armor = list(MELEE = 35, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 25, BIO = 15, "rad" = 15, FIRE = 15, ACID = 20)
	resistance_flags = UNACIDABLE

/obj/item/clothing/gloves/marine/veteran/PMC
	name = "armored gloves"
	desc = "Armored gloves used in special operations. They are also insulated against electrical shock."
	icon_state = "black"
	item_state = "bgloves"
	siemens_coefficient = 0
	flags_item = SYNTH_RESTRICTED
	soft_armor = list(MELEE = 30, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 30, BIO = 20, "rad" = 20, FIRE = 20, ACID = 15)

/obj/item/clothing/gloves/marine/veteran/PMC/commando
	name = "\improper PMC commando gloves"
	desc = "A pair of heavily armored, insulated, acid-resistant gloves."
	icon_state = "brown"
	item_state = "browngloves"
	soft_armor = list(MELEE = 40, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 30, BIO = 20, "rad" = 20, FIRE = 20, ACID = 25)
	resistance_flags = UNACIDABLE

/obj/item/clothing/gloves/marine/som
	name = "\improper SoM gloves"
	desc = "Gloves with origins dating back to the old mining colonies, they look pretty tough."
	icon_state = "som"
	item_state = "som"

/obj/item/clothing/gloves/marine/som/insulated
	name = "\improper Insulated SoM gloves"
	desc = "Gloves with origins dating back to the old mining colonies. These ones appear to have an electrically insulating layer built into them."
	siemens_coefficient = 0

/obj/item/clothing/gloves/marine/som/veteran
	name = "\improper SoM veteran gloves"
	desc = "Gloves with origins dating back to the old mining colonies. These ones seem tougher than normal."
	icon_state = "som_veteran"
	item_state = "som_veteran"
	soft_armor = list(MELEE = 30, BULLET = 20, LASER = 15, ENERGY = 20, BOMB = 15, BIO = 5, "rad" = 5, FIRE = 15, ACID = 15)

/obj/item/clothing/gloves/marine/commissar
	name = "\improper commissar gloves"
	desc = "Gloves worn by commissars of the Imperial Army so that they do not soil their hands with the blood of their men."
	icon_state = "gloves_commissar"
	item_state = "gloves_commissar"
	soft_armor = list(MELEE = 35, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 15, BIO = 10, "rad" = 0, FIRE = 20, ACID = 20)
