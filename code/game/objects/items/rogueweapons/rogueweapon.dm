

/obj/item/rogueweapon
	name = ""
	desc = ""
	icon_state = "sabre"
	item_state = "sabre"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	block_chance = 0
	armor_penetration = 0
	sharpness = IS_SHARP
	custom_materials = null
	possible_item_intents = list(SWORD_CUT, SWORD_THRUST)
	can_parry = TRUE
	var/initial_sl
	wlength = 45
	sellprice = 1
	has_inspect_verb = TRUE
	parrysound = list('sound/combat/parry/parrygen.ogg')
	anvilrepair = /datum/skill/craft/weaponsmithing
	obj_flags = CAN_BE_HIT
	blade_dulling = DULLING_BASH
	max_integrity = 200
	wdefense = 3
	var/list/possible_enhancements
	var/renamed_name
	experimental_onhip = TRUE
	experimental_onback = TRUE
	embedding = list("embedded_pain_multiplier" = 1, "embed_chance" = 20, "embedded_fall_chance" = 0)

/obj/item/rogueweapon/New()
	. = ..()

	var/yea = pick("[src] is broken!", "[src] is useless!", "[src] is destroyed!")
	destroy_message = "<span class='warning'>[yea]</span>"

/obj/item/rogueweapon/get_dismemberment_chance(obj/item/bodypart/affecting)
	if(affecting.can_dismember(src) && isliving(loc))
		var/mob/living/L = loc
		var/nuforce = get_complex_damage(src, L)
		if(istype(L.rmb_intent, /datum/rmb_intent/strong))
			nuforce = nuforce * 1.1
		if(istype(L.rmb_intent, /datum/rmb_intent/weak))
			nuforce = 0
		if(L.used_intent.blade_class == BCLASS_CHOP) //chopping attacks are 10% better at dismembering
			nuforce = nuforce * 1.1 //used to be 1*1 but whatever
		else
			if(L.used_intent.blade_class == BCLASS_CUT)
				if(affecting.get_damage() < affecting.max_damage)
					return 0
			else
				return 0
		if(nuforce >= 10)
			var/probmod = (affecting.get_damage() / affecting.max_damage)
			if(probmod >= 1) //limb is at max damage, easy to dismember
				return 100
			. = nuforce * (probmod)
