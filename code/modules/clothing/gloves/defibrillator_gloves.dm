/obj/item/clothing/gloves/defibrillator
	name = "advanced medical combat gloves"
	desc = "Advanced medical gauntlets with small but powerful electrodes to resuscitate incapacitated patients. No more bulky units!"
	icon_state = "defib_out"
	worn_icon_state = "defib_gloves"
	soft_armor = list(MELEE = 25, BULLET = 15, LASER = 10, ENERGY = 15, BOMB = 15, BIO = 5, FIRE = 15, ACID = 15)
	cold_protection_flags = HANDS
	heat_protection_flags = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	///The internal defib item
	var/obj/item/defibrillator/internal/internal_defib

/obj/item/clothing/gloves/defibrillator/Initialize(mapload)
	. = ..()
	internal_defib = new(src, src)
	update_icon()

/obj/item/clothing/gloves/defibrillator/Destroy()
	internal_defib = null
	return ..()

/obj/item/clothing/gloves/defibrillator/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(user.gloves == src)
		RegisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))
	else
		UnregisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK)

/obj/item/clothing/gloves/defibrillator/unequipped(mob/living/carbon/human/user, slot)
	. = ..()
	UnregisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK) //Unregisters in the case of getting delimbed

/obj/item/clothing/gloves/defibrillator/examine(mob/user)
	. = ..()
	. += internal_defib.charge_information()

/obj/item/clothing/gloves/defibrillator/update_overlays()
	. = ..()
	if(!internal_defib?.dcell?.charge) // this should never happen except on init or something
		. += "_empty"
		return
	switch(round(internal_defib.dcell.charge * 100 / internal_defib.dcell.maxcharge))
		if(67 to INFINITY)
			. += "_full"
		if(34 to 66)
			. += "_half"
		if(3 to 33)
			. += "_low"
		if(-INFINITY to 3)
			. += "_empty"

//when you are wearing these gloves, this will call the normal attack code to begin defibing the target
/obj/item/clothing/gloves/defibrillator/proc/on_unarmed_attack(mob/living/carbon/human/user, mob/living/carbon/human/target)
	SIGNAL_HANDLER
	if(user.a_intent != INTENT_HELP)
		return
	if(istype(user) && istype(target))
		INVOKE_ASYNC(internal_defib, TYPE_PROC_REF(/obj/item/defibrillator, defibrillate), target, user)
