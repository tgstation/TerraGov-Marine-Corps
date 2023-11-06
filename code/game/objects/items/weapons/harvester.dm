//All the harvester weapons go in here

#define VALI_CODEX "<b>Reagent info:</b><BR>\
	All chems will do 60% armor-piercing damage, and also:<BR>\
	Bicaridine - Heals brute and stamina. Channel the heal for a larger heal, works better with medical skill.<BR>\
	Kelotane - Set your target aflame and sunder their armor<BR>\
	Tramadol - Slow your target for 1 second<BR>\
	Tricordrazine - Shatter your targets armor for 3 seconds<BR>\
	<BR>\
	<b>Tips:</b><BR>\
	> Needs to be connected to the Vali system to collect green blood. You can connect it though the Vali system's configurations menu.<BR>\
	> Filled by liquid reagent containers or pills. Emptied by using an empty liquid reagent container.<BR>\
	> Press your unique action key (SPACE by default) to load a single-use of the reagent effect after the blade has been filled up."

//Vali weapon base
/obj/item/weapon/harvester
	name = "generic vali weapon"
	desc = "just your everyday harvester weapon."
	icon = 'icons/obj/items/vali.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/vali_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/vali_right.dmi',
	)
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	force = 10
	throwforce = 10
	sharp = IS_SHARP_ITEM_BIG
	edge = 1
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

	var/codex_info = VALI_CODEX

/obj/item/weapon/harvester/get_mechanics_info()
	. = ..()
	. += jointext(codex_info, "<br>")

//Vali Sword
/obj/item/weapon/harvester/sword
	name = "\improper HP-S Harvester blade"
	desc = "TerraGov Marine Corps' experimental High Point-Singularity 'Harvester' blade. An advanced weapon that trades sheer force for the ability to apply a variety of debilitating effects when loaded with certain reagents. Activate after loading to prime a single use of an effect. It also harvests substances from alien lifeforms it strikes when connected to the Vali system."
	icon_state = "vali_sword"
	//item_state = "vali_sword"
	force = 60
	attack_speed = 12

/obj/item/weapon/harvester/sword/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/harvester)

/obj/item/weapon/harvester/sword/equipped(mob/user, slot)
	. = ..()
	toggle_item_bump_attack(user, TRUE)

/obj/item/weapon/harvester/sword/dropped(mob/user)
	. = ..()
	toggle_item_bump_attack(user, FALSE)

//Vali Knife
/obj/item/weapon/harvester/knife
	name = "\improper HP-S Harvester knife"
	desc = "TerraGov Marine Corps' experimental High Point-Singularity 'Harvester' knife. An advanced version of the HP-S Harvester blade, shrunken down to the size of the standard issue boot knife. It trades the harvester blades size and power for a smaller form, with the side effect of a miniscule chemical storage, yet it still keeps its ability to apply debilitating effects to its targets. Activate after loading to prime a single use of an effect. It also harvests substances from alien lifeforms it strikes when connected to the Vali system."
	icon_state = "vali_knife"
	//item_state = "vali_knife"
	w_class = WEIGHT_CLASS_SMALL
	force = 25
	throwforce = 15
	throw_speed = 3
	throw_range = 6
	attack_speed = 8
	sharp = IS_SHARP_ITEM_ACCURATE
	hitsound = 'sound/weapons/slash.ogg'

/obj/item/weapon/harvester/knife/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/harvester, 5)

/obj/item/weapon/harvester/knife/equipped(mob/user, slot)
	. = ..()
	toggle_item_bump_attack(user, FALSE)

/obj/item/weapon/harvester/knife/dropped(mob/user)
	. = ..()
	toggle_item_bump_attack(user, FALSE)

//Two-handed Vali weapon base
/obj/item/weapon/twohanded/harvester
	name = "generic 2-handed vali weapon"
	desc = "just your everyday 2-handed harvester weapon."
	icon = 'icons/obj/items/vali.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/vali_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/vali_right.dmi',
	)
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	force = 10
	force_wielded = 20
	throwforce = 10
	sharp = IS_SHARP_ITEM_BIG
	edge = 1
	w_class = WEIGHT_CLASS_BULKY
	flags_item = TWOHANDED
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

	var/codex_info = VALI_CODEX

/obj/item/weapon/twohanded/harvester/get_mechanics_info()
	. = ..()
	. += jointext(codex_info, "<br>")

//Vali Spear
/obj/item/weapon/twohanded/harvester/spear
	name = "\improper HP-S Harvester spear"
	desc = "TerraGov Marine Corps' experimental High Point-Singularity 'Harvester' spear. An advanced weapon that trades sheer force for the ability to apply a variety of debilitating effects when loaded with certain reagents. Activate after loading to prime a single use of an effect. It also harvests substances from alien lifeforms it strikes when connected to the Vali system."
	icon_state = "vali_spear"
	item_state = "vali_spear"
	force = 32
	force_wielded = 60
	throwforce = 60
	throw_speed = 3
	reach = 2
	flags_equip_slot = ITEM_SLOT_BACK
	sharp = IS_SHARP_ITEM_SIMPLE
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "stabbed", "jabbed", "torn", "gored")
	///Based on what direction the tip of the spear is pointed at in the sprite; maybe someone makes a spear that points northwest
	var/current_angle = 45

/obj/item/weapon/twohanded/harvester/spear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/harvester)

//throw_at() and pickup() are copypasted from /spear, since we are no longer a spear subtype anymore
/obj/item/weapon/twohanded/harvester/spear/throw_at(atom/target, range, speed, thrower, spin, flying = FALSE, targetted_throw = TRUE)
	spin = FALSE
	//Find the angle the spear is to be thrown at, then rotate it based on that angle
	var/rotation_value = Get_Angle(thrower, get_turf(target)) - current_angle
	current_angle += rotation_value
	var/matrix/rotate_me = matrix()
	rotate_me.Turn(rotation_value)
	transform = rotate_me
	return ..()

/obj/item/weapon/twohanded/harvester/spear/pickup(mob/user)
	. = ..()
	if(initial(current_angle) == current_angle)
		return
	//Reset the angle of the spear when picked up off the ground so it doesn't stay lopsided
	var/matrix/rotate_me = matrix()
	rotate_me.Turn(initial(current_angle) - current_angle)
	//Rotate the object in the opposite direction because for some unfathomable reason, the above Turn() is applied twice; it just works
	rotate_me.Turn(-(initial(current_angle) - current_angle))
	transform = rotate_me
	current_angle = initial(current_angle)	//Reset the angle

//Vali Claymore (That thing was too big to be called a sword. Too big, too thick, too heavy, and too rough, it was more like a large hunk of iron.)
/obj/item/weapon/twohanded/harvester/claymore
	name = "\improper HP-S Harvester claymore"
	desc = "TerraGov Marine Corps' experimental High Point-Singularity 'Harvester' blade. An advanced weapon that trades sheer force for the ability to apply a variety of debilitating effects when loaded with certain reagents. Activate after loading to prime a single use of an effect. It also harvests substances from alien lifeforms it strikes when connected to the Vali system. This specific version is enlarged to fit the design of an old world claymore. Simply squeeze the hilt to activate."
	icon = 'icons/obj/items/vali.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/vali_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/vali_right.dmi',
	)
	icon_state = "vali_claymore"
	item_state = "vali_claymore"
	force = 28
	force_wielded = 90
	throwforce = 65
	throw_speed = 3
	edge = 1
	attack_speed = 24
	sharp = IS_SHARP_ITEM_BIG
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	flags_item = TWOHANDED
	resistance_flags = NONE
	hitsound = 'sound/weapons/bladeslice.ogg'
	resistance_flags = UNACIDABLE
	attack_verb = list("sliced", "slashed", "jabbed", "torn", "gored")

/obj/item/weapon/twohanded/harvester/claymore/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/harvester, 60, TRUE)

/obj/item/weapon/twohanded/harvester/claymore/wield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_item_bump_attack(user, TRUE)

/obj/item/weapon/twohanded/harvester/claymore/unwield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_item_bump_attack(user, FALSE)

/obj/item/weapon/twohanded/harvester/claymore/update_overlays()
	. = ..()
	mutable_appearance()

#undef VALI_CODEX
