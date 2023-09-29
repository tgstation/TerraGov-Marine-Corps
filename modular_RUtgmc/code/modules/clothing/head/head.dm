/obj/item/clothing/head/squadhb
	name = "\improper Alpha squad headband"
	desc = "Headband made from ultra-thin special cloth. Cloth thickness provides more than just a stylish fluttering of headband. You can tie around headband onto a helmet. This squad version of a headband has secret unique features created by the cloth coloring component. "
	icon = 'modular_RUtgmc/icons/obj/clothing/headwear/hats.dmi'
	item_icons = list(
		slot_head_str = 'modular_RUtgmc/icons/mob/clothing/headwear/marine_hats.dmi')
	icon_state = "asquadhb"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	slowdown = -0.1
	w_class = WEIGHT_CLASS_TINY
	species_exception = list(/datum/species/robot, /datum/species/synthetic, /datum/species/human, /datum/species/early_synthetic, /datum/species/zombie)

/obj/item/clothing/head/squadhb/b
	name = "\improper Bravo squad headband"
	icon_state = "bsquadhb"

/obj/item/clothing/head/squadhb/c
	name = "\improper Charlie squad headband"
	icon_state = "csquadhb"

/obj/item/clothing/head/squadhb/d
	name = "\improper Delta squad headband"
	icon_state = "dsquadhb"

/obj/item/clothing/head/tgmcberet/squad
	name = "\improper Charlie squad beret"
	icon_state = "csberet"
	desc = "Military beret with TGMC marine squad insignia. This one belongs to the Charlie Squad."
	icon = 'modular_RUtgmc/icons/obj/clothing/headwear/hats.dmi'
	item_icons = list(
		slot_head_str = 'modular_RUtgmc/icons/mob/clothing/headwear/marine_hats.dmi')

/obj/item/clothing/head/tgmcberet/squad/delta
	name = "\improper Delta Squad beret"
	desc = "Military beret with TGMC marine squad insignia. This one belongs to the Delta Squad."
	icon_state = "dsberet"

/obj/item/clothing/head/tgmcberet/squad/alpha
	name = "\improper Alpha Squad beret"
	desc = "Military beret with TGMC marine squad insignia. This one belongs to the Alpha Squad."
	icon_state = "asberet"

/obj/item/clothing/head/tgmcberet/squad/bravo
	name = "\improper Bravo Squad beret"
	desc = "Military beret with TGMC marine squad insignia. This one belongs to the Bravo Squad."
	icon_state = "bsberet"

/obj/item/clothing/head/tgmcberet/commando
	name = "\improper Marines Commando beret"
	desc = "Dark Green beret with an old TGMC insignia on it."
	icon_state = "marcommandoberet"
	icon = 'modular_RUtgmc/icons/obj/clothing/headwear/hats.dmi'
	item_icons = list(
		slot_head_str = 'modular_RUtgmc/icons/mob/clothing/headwear/marine_hats.dmi')

/obj/item/clothing/head/tgmcberet/vdv
	name = "\improper Airborne beret"
	desc = "Blue badged beret that smells like ethanol and fountain water for some reason."
	icon_state = "russobluecamohat"
	icon = 'modular_RUtgmc/icons/obj/clothing/headwear/hats.dmi'
	item_icons = list(
		slot_head_str = 'modular_RUtgmc/icons/mob/clothing/headwear/marine_hats.dmi')

/obj/item/clothing/head/tgmcberet/medical
	name = "\improper Medical beret"
	desc = "A white beret with a green cross finely threaded into it. It has that sterile smell about it."
	icon_state = "medberet"
	icon = 'modular_RUtgmc/icons/obj/clothing/headwear/hats.dmi'
	item_icons = list(
		slot_head_str = 'modular_RUtgmc/icons/mob/clothing/headwear/marine_hats.dmi')

/obj/item/clothing/head/tgmcberet/hijab
	name = "\improper Black hijab"
	desc = "Encompassing cloth headwear worn by some human cultures and religions."
	icon = 'modular_RUtgmc/icons/obj/clothing/headwear/hats.dmi'
	item_icons = list(
		slot_head_str = 'modular_RUtgmc/icons/mob/clothing/headwear/marine_hats.dmi')
	icon_state = "hijab_black"
	flags_inv_hide = HIDEEARS|HIDETOPHAIR

/obj/item/clothing/head/tgmcberet/hijab/grey
	name = "\improper Grey hijab"
	icon_state = "hijab_grey"

/obj/item/clothing/head/tgmcberet/hijab/red
	name = "\improper Red hijab"
	icon_state = "hijab_red"

/obj/item/clothing/head/tgmcberet/hijab/blue
	name = "\improper Blue hijab"
	icon_state = "hijab_blue"

/obj/item/clothing/head/tgmcberet/hijab/brown
	name = "\improper Brown hijab"
	icon_state = "hijab_brown"

/obj/item/clothing/head/tgmcberet/hijab/white
	name = "\improper White hijab"
	icon_state = "hijab_white"

/obj/item/clothing/head/tgmcberet/hijab/turban
	name = "\improper White turban"
	desc = "A sturdy cloth, worn around the head."
	icon_state = "turban_black"

/obj/item/clothing/head/tgmcberet/hijab/turban/white
	name = "\improper White turban"
	icon_state = "turban_white"

/obj/item/clothing/head/tgmcberet/hijab/turban/red
	name = "\improper Red turban"
	icon_state = "turban_red"

/obj/item/clothing/head/tgmcberet/hijab/turban/blue
	name = "\improper Blue turban"
	icon_state = "turban_blue"

/obj/item/clothing/head/hachimaki
	name = "\improper Ancient pilot headband and scarf kit"
	desc = "Ancient pilot kit of scarf that protects neck from cold wind and headband that protects face from sweat"
	icon = 'modular_RUtgmc/icons/obj/clothing/headwear/hats.dmi'
	item_icons = list(
		slot_head_str = 'modular_RUtgmc/icons/mob/clothing/headwear/head_0.dmi')
	icon_state = "Banzai"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	w_class = WEIGHT_CLASS_SMALL

	actions_types = list(/datum/action/item_action/toggle)
	flags_armor_features = ARMOR_LAMP_OVERLAY|ARMOR_NO_DECAP
	flags_item = SYNTH_RESTRICTED

/obj/item/clothing/head/hachimaki/attack_self(mob/user)
	var/mob/living/carbon/human/activator = user
	if(TIMER_COOLDOWN_CHECK(user, "Banzai"))
		user.balloon_alert(user, "You used that emote too recently")
		return
	TIMER_COOLDOWN_START(user, "Banzai", 60 SECONDS)
	if(user.gender == FEMALE)
		user.balloon_alert(user, "Women can't use that")
	else
		activator.say("Tenno Heika Banzai!!")
		//playsound(get_turf(user), 'sound/voice/banzai1.ogg', 30)

/obj/item/clothing/head/tgmcberet/squad/black
	name = "\improper Alpha squad black beret"
	icon_state = "alpha_black_beret"
	desc = "Black stylish beret with TGMC marine squad insignia. This one belongs to the Alpha Squad."
	icon = 'modular_RUtgmc/icons/obj/clothing/headwear/hats.dmi'
	item_icons = list(
		slot_head_str = 'modular_RUtgmc/icons/mob/clothing/headwear/marine_hats.dmi')

/obj/item/clothing/head/tgmcberet/squad/black/bravo
	name = "\improper Bravo squad black beret"
	icon_state = "bravo_black_beret"
	desc = "Black stylish beret with TGMC marine squad insignia. This one belongs to the Bravo Squad."

/obj/item/clothing/head/tgmcberet/squad/black/delta
	name = "\improper Delta squad black beret"
	icon_state = "delta_black_beret"
	desc = "Black stylish beret with TGMC marine squad insignia. This one belongs to the Delta Squad."

/obj/item/clothing/head/tgmcberet/squad/black/charlie
	name = "\improper Charlie squad black beret"
	icon_state = "charlie_black_beret"
	desc = "Black stylish beret with TGMC marine squad insignia. This one belongs to the Charlie Squad."

/obj/item/clothing/head/beret/marine
	item_icons = list(
		slot_head_str = 'modular_RUtgmc/icons/mob/clothing/headwear/marine_hats.dmi')

/obj/item/clothing/head/beret/sec/warden
	item_icons = list(
		slot_head_str = 'modular_RUtgmc/icons/mob/clothing/headwear/marine_hats.dmi')

/obj/item/clothing/head/beret/sec
	item_icons = list(
		slot_head_str = 'modular_RUtgmc/icons/mob/clothing/headwear/marine_hats.dmi')

/obj/item/clothing/head/beret/eng
	item_icons = list(
		slot_head_str = 'modular_RUtgmc/icons/mob/clothing/headwear/marine_hats.dmi')

/obj/item/clothing/head/beret/marine/techofficer
	item_icons = list(
		slot_head_str = 'modular_RUtgmc/icons/mob/clothing/headwear/marine_hats.dmi')
