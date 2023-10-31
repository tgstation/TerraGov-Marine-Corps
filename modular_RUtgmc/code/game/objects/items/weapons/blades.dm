/obj/item/weapon/combat_knife
	icon = 'modular_RUtgmc/icons/obj/items/weapons.dmi'
	item_icons = list(
		slot_l_hand_str = 'modular_RUtgmc/icons/mob/inhands/weapons/melee_left.dmi',
		slot_r_hand_str = 'modular_RUtgmc/icons/mob/inhands/weapons/melee_right.dmi',
	)

/obj/item/weapon/combat_knife/nkvd
	name = "\improper Finka NKVD"
	icon_state = "upp_knife"
	item_state = "combat_knife"
	desc = "Legendary Finka NKVD model 1934 with a 10-year warranty and delivery within 2 days."
	force = 40
	throwforce = 50
	throw_speed = 2
	throw_range = 8

/obj/item/attachable/bayonetknife
	icon = 'modular_RUtgmc/icons/obj/items/weapons.dmi'
	item_icons = list(
		slot_l_hand_str = 'modular_RUtgmc/icons/mob/inhands/weapons/melee_left.dmi',
		slot_r_hand_str = 'modular_RUtgmc/icons/mob/inhands/weapons/melee_right.dmi',
	)

/obj/item/weapon/claymore/mercsword/machete
	icon = 'modular_RUtgmc/icons/obj/items/weapons.dmi'

/obj/item/weapon/twohanded/spear/tactical/harvester
	icon = 'modular_RUtgmc/icons/obj/items/weapons.dmi'
	item_icons = list(
		slot_back_str = 'modular_RUtgmc/icons/mob/clothing/back.dmi',
		slot_l_hand_str = 'modular_RUtgmc/icons/mob/inhands/weapons/twohanded_left.dmi',
		slot_r_hand_str = 'modular_RUtgmc/icons/mob/inhands/weapons/twohanded_right.dmi',
	)

/obj/item/weapon/claymore/harvester
	icon = 'modular_RUtgmc/icons/obj/items/weapons.dmi'
	item_icons = list(
		slot_l_hand_str = 'modular_RUtgmc/icons/mob/inhands/weapons/melee_left.dmi',
		slot_r_hand_str = 'modular_RUtgmc/icons/mob/inhands/weapons/melee_right.dmi',
	)

/obj/item/weapon/claymore/mercsword/officersword
	force = 80
	attack_speed = 5
	sharp = IS_SHARP_ITEM_ACCURATE
	resistance_flags = UNACIDABLE
	hitsound = 'modular_RUtgmc/sound/weapons/rapierhit.ogg'
	attack_verb = list("slash", "cut")

/obj/item/weapon/claymore/mercsword/officersword/attack(mob/living/carbon/M, mob/living/user)
	. = ..()
	if(user.skills.getRating("swordplay") == SKILL_SWORDPLAY_DEFAULT)
		attack_speed = 20
		force = 35
		to_chat(user, span_warning("You try to figure out how to wield [src]..."))
		if(prob(40))
			if(CHECK_BITFIELD(flags_item,NODROP))
				TOGGLE_BITFIELD(flags_item, NODROP)
			user.drop_held_item(src)
			to_chat(user, span_warning("[src] slipped out of your hands!"))
			playsound(src.loc, 'sound/misc/slip.ogg', 25, 1)
	if(user.skills.getRating("swordplay") == SKILL_SWORDPLAY_TRAINED)
		attack_speed = initial(attack_speed)
		force = initial(force)

/obj/item/weapon/claymore/mercsword/officersword/equipped(mob/user, slot)
	. = ..()
	toggle_item_bump_attack(user, TRUE)

/obj/item/weapon/claymore/mercsword/officersword/dropped(mob/user)
	. = ..()
	toggle_item_bump_attack(user, FALSE)

/obj/item/weapon/claymore/mercsword/officersword/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/strappable)

/obj/item/weapon/claymore/mercsword/officersword/valirapier
	name = "\improper HP-C Harvester rapier"
	desc = "Extremely expensive looking blade, with a golden handle and engravings, unexpectedly effective in combat, despite its ceremonial looks, compacted with a vali module."
	icon = 'modular_RUtgmc/icons/obj/items/weapons.dmi'
	item_icons = list(
		slot_l_hand_str = 'modular_RUtgmc/icons/mob/inhands/weapons/melee_left.dmi',
		slot_r_hand_str = 'modular_RUtgmc/icons/mob/inhands/weapons/melee_right.dmi',
	)
	icon_state = "rapier"
	item_state = "rapier"
	force = 35
	attack_speed = 5

/obj/item/weapon/claymore/mercsword/officersword/valirapier/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/harvester)
	RemoveElement(/datum/element/strappable)

/obj/item/weapon/claymore/mercsword/officersword/sabre
	name = "\improper ceremonial officer sabre"
	desc = "Gold plated, smoked dark wood handle, your name on it, what else do you need?"
	icon = 'modular_RUtgmc/icons/obj/items/weapons.dmi'
	item_icons = list(
		slot_l_hand_str = 'modular_RUtgmc/icons/mob/inhands/weapons/melee_left.dmi',
		slot_r_hand_str = 'modular_RUtgmc/icons/mob/inhands/weapons/melee_right.dmi',
	)
	icon_state = "saber"
	item_state = "saber"
