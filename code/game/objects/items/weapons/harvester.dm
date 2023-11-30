//All the harvester weapons go in here

//Vali Sword
/obj/item/weapon/claymore/harvester
	name = "\improper HP-S Harvester blade"
	desc = "TerraGov Marine Corps' experimental High Point-Singularity 'Harvester' blade. An advanced weapon that trades sheer force for the ability to apply a variety of debilitating effects when loaded with certain reagents. Activate after loading to prime a single use of an effect. It also harvests substances from alien lifeforms it strikes when connected to the Vali system."
	icon = 'icons/obj/items/vali.dmi'
	icon_state = "vali_sword"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/vali_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/vali_right.dmi',
	)
	item_state = "vali_sword"
	force = 60
	attack_speed = 12
	w_class = WEIGHT_CLASS_BULKY

/obj/item/weapon/claymore/harvester/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/harvester)

/obj/item/weapon/claymore/harvester/equipped(mob/user, slot)
	. = ..()
	toggle_item_bump_attack(user, TRUE)

/obj/item/weapon/claymore/harvester/dropped(mob/user)
	. = ..()
	toggle_item_bump_attack(user, FALSE)

//Vali Knife
/obj/item/weapon/combat_knife/harvester
	name = "\improper HP-S Harvester knife"
	desc = "TerraGov Marine Corps' experimental High Point-Singularity 'Harvester' knife. An advanced version of the HP-S Harvester blade, shrunken down to the size of the standard issue boot knife. It trades the harvester blades size and power for a smaller form, with the side effect of a miniscule chemical storage, yet it still keeps its ability to apply debilitating effects to its targets. Activate after loading to prime a single use of an effect. It also harvests substances from alien lifeforms it strikes when connected to the Vali system."
	icon = 'icons/obj/items/vali.dmi'
	icon_state = "vali_knife"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/vali_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/vali_right.dmi',
	)
	item_state = "vali_knife"
	w_class = WEIGHT_CLASS_SMALL
	force = 25
	throwforce = 15
	throw_speed = 3
	throw_range = 6
	attack_speed = 8
	sharp = IS_SHARP_ITEM_ACCURATE
	hitsound = 'sound/weapons/slash.ogg'

/obj/item/weapon/combat_knife/harvester/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/harvester, 5)

/obj/item/weapon/combat_knife/harvester/equipped(mob/user, slot)
	. = ..()
	toggle_item_bump_attack(user, TRUE)

/obj/item/weapon/combat_knife/harvester/dropped(mob/user)
	. = ..()
	toggle_item_bump_attack(user, FALSE)

//Vali Claymore (That thing was too big to be called a sword. Too big, too thick, too heavy, and too rough, it was more like a large hunk of iron.)
/obj/item/weapon/twohanded/glaive/harvester
	name = "\improper HP-S Harvester claymore"
	desc = "TerraGov Marine Corps' experimental High Point-Singularity 'Harvester' blade. An advanced weapon that trades sheer force for the ability to apply a variety of debilitating effects when loaded with certain reagents. Activate after loading to prime a single use of an effect. It also harvests substances from alien lifeforms it strikes when connected to the Vali system. This specific version is enlarged to fit the design of an old world claymore. Simply squeeze the hilt to activate."
	icon = 'icons/obj/items/vali.dmi'
	icon_state = "vali_claymore"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/vali_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/vali_right.dmi',
	)
	item_state = "vali_claymore"
	attack_speed = 24
	resistance_flags = NONE

/obj/item/weapon/twohanded/glaive/harvester/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/harvester, 60, TRUE)

/obj/item/weapon/twohanded/glaive/harvester/wield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_item_bump_attack(user, TRUE)

/obj/item/weapon/twohanded/glaive/harvester/unwield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_item_bump_attack(user, FALSE)
