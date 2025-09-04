/mob/living/carbon/human/examine(mob/user)
	SHOULD_CALL_PARENT(FALSE)
	var/skipgloves = 0
	var/skipsuitstorage = 0
	var/skipjumpsuit = 0
	var/skipshoes = 0
	var/skipmask = 0
	var/skipears = 0
	var/skipeyes = 0
	var/skipface = 0

	//exosuits and helmets obscure our view and stuff.
	if(wear_suit)
		skipgloves = wear_suit.inv_hide_flags & HIDEGLOVES
		skipsuitstorage = wear_suit.inv_hide_flags & HIDESUITSTORAGE
		skipjumpsuit = wear_suit.inv_hide_flags & HIDEJUMPSUIT
		skipshoes = wear_suit.inv_hide_flags & HIDESHOES

	if(head)
		skipmask = head.inv_hide_flags & HIDEMASK
		skipeyes = head.inv_hide_flags & HIDEEYES
		skipears = head.inv_hide_flags & HIDEEARS
		skipface = head.inv_hide_flags & HIDEFACE

	if(wear_mask)
		skipface |= wear_mask.inv_hide_flags & HIDEFACE

	var/t_He = p_they(TRUE) //capitalised for use at the start of each line.
	var/t_he = p_they()
	var/t_his = p_their()
	var/t_him = p_them()
	var/t_has = p_have()
	var/t_is = p_are()

	var/msg = ""

	msg += "<span class='infoplain'>"
	msg += separator_hr("Outfit")

	//uniform
	if(w_uniform && !skipjumpsuit)
		if(w_uniform.blood_overlay)
			msg += "[span_alert("[t_He] [t_is] wearing [icon2html(w_uniform, user)] [w_uniform.gender==PLURAL?"some":"a"] [(w_uniform.blood_color != "#030303") ? "blood" : "oil"]-stained [w_uniform.name]!")]\n"
		else
			msg += "[t_He] [t_is] wearing [icon2html(w_uniform, user)] \a [w_uniform].\n"

	//head
	if(head)
		if(head.blood_overlay)
			msg += "[span_alert("[t_He] [t_is] wearing [icon2html(head, user)] [head.gender==PLURAL?"some":"a"] [(head.blood_color != "#030303") ? "blood" : "oil"]-stained [head.name] on [t_his] head!")]\n"
		else
			msg += "[t_He] [t_is] wearing [icon2html(head, user)] \a [head] on [t_his] head.\n"
		if(istype(head, /obj/item/clothing/head/modular))
			var/head_info
			var/obj/item/clothing/head/modular/wear_head = head
			if(wear_head.attachments_by_slot[ATTACHMENT_SLOT_HEAD_MODULE])
				head_info += "	- [wear_head.attachments_by_slot[ATTACHMENT_SLOT_HEAD_MODULE]].\n"
			if(head_info)
				msg += "	It has the following attachments:\n"
				msg += head_info

	//suit/armour
	if(wear_suit)
		if(wear_suit.blood_overlay)
			msg += "[span_alert("[t_He] [t_is] wearing [icon2html(wear_suit, user)] [wear_suit.gender==PLURAL?"some":"a"] [(wear_suit.blood_color != "#030303") ? "blood" : "oil"]-stained [wear_suit.name]!")]\n"
		else
			msg += "[t_He] [t_is] wearing [icon2html(wear_suit, user)] \a [wear_suit].\n"
		if(istype(wear_suit, /obj/item/clothing/suit/modular))
			var/armor_info
			var/obj/item/clothing/suit/modular/wear_modular_suit = wear_suit
			if(wear_modular_suit.attachments_by_slot[ATTACHMENT_SLOT_CHESTPLATE])
				armor_info += "	- [wear_modular_suit.attachments_by_slot[ATTACHMENT_SLOT_CHESTPLATE]].\n"
			if(wear_modular_suit.attachments_by_slot[ATTACHMENT_SLOT_SHOULDER])
				armor_info += "	- [wear_modular_suit.attachments_by_slot[ATTACHMENT_SLOT_SHOULDER]].\n"
			if(wear_modular_suit.attachments_by_slot[ATTACHMENT_SLOT_KNEE])
				armor_info += "	- [wear_modular_suit.attachments_by_slot[ATTACHMENT_SLOT_KNEE]].\n"
			if(wear_modular_suit.attachments_by_slot[ATTACHMENT_SLOT_STORAGE])
				armor_info += "	- [wear_modular_suit.attachments_by_slot[ATTACHMENT_SLOT_STORAGE]].\n"
			if(wear_modular_suit.attachments_by_slot[ATTACHMENT_SLOT_MODULE])
				armor_info += "	- [wear_modular_suit.attachments_by_slot[ATTACHMENT_SLOT_MODULE]].\n"
			if(armor_info)
				msg += "	It has the following attachments:\n"
				msg += armor_info

		//suit/armour storage
		if(s_store && !skipsuitstorage)
			if(s_store.blood_overlay)
				msg += "[span_alert("[t_He] [t_is] carrying [icon2html(s_store, user)] [s_store.gender==PLURAL?"some":"a"] [(s_store.blood_color != "#030303") ? "blood" : "oil"]-stained [s_store.name] on [t_his] [wear_suit.name]!")]\n"
			else
				msg += "[t_He] [t_is] carrying [icon2html(s_store, user)] \a [s_store] on [t_his] [wear_suit.name].\n"

	//back
	if(back)
		if(back.blood_overlay)
			msg += "[span_alert("[t_He] [t_has] [icon2html(back, user)] [back.gender==PLURAL?"some":"a"] [(back.blood_color != "#030303") ? "blood" : "oil"]-stained [back] on [t_his] back.")]\n"
		else
			msg += "[t_He] [t_has] [icon2html(back, user)] \a [back] on [t_his] back.\n"

	//left hand
	if(l_hand)
		if(l_hand.blood_overlay)
			msg += "[span_alert("[t_He] [t_is] holding [icon2html(l_hand, user)] [l_hand.gender==PLURAL?"some":"a"] [(l_hand.blood_color != "#030303") ? "blood" : "oil"]-stained [l_hand.name] in [t_his] left hand!")]\n"
		else
			msg += "[t_He] [t_is] holding [icon2html(l_hand, user)] \a [l_hand] in [t_his] left hand.\n"

	//right hand
	if(r_hand)
		if(r_hand.blood_overlay)
			msg += "[span_alert("[t_He] [t_is] holding [icon2html(r_hand, user)] [r_hand.gender==PLURAL?"some":"a"] [(r_hand.blood_color != "#030303") ? "blood" : "oil"]-stained [r_hand.name] in [t_his] right hand!")]\n"
		else
			msg += "[t_He] [t_is] holding [icon2html(r_hand, user)] \a [r_hand] in [t_his] right hand.\n"

	//gloves
	if(gloves && !skipgloves)
		if(gloves.blood_overlay)
			msg += "[span_alert("[t_He] [t_has] [icon2html(gloves, user)] [gloves.gender==PLURAL?"some":"a"] [(gloves.blood_color != "#030303") ? "blood" : "oil"]-stained [gloves.name] on [t_his] hands!")]\n"
		else
			msg += "[t_He] [t_has] [icon2html(gloves, user)] \a [gloves] on [t_his] hands.\n"
	else if(blood_color)
		msg += "[span_alert("[t_He] [t_has] [(blood_color != "#030303") ? "blood" : "oil"]-stained hands!")]\n"

	//handcuffed?
	if(handcuffed)
		if(istype(handcuffed, /obj/item/restraints/handcuffs/cable))
			msg += "[span_alert("[t_He] [t_is] [icon2html(handcuffed, user)] restrained with cable!")]\n"
		else
			msg += "[span_alert("[t_He] [t_is] [icon2html(handcuffed, user)] handcuffed!")]\n"

	//belt
	if(belt)
		if(belt.blood_overlay)
			msg += "[span_alert("[t_He] [t_has] [icon2html(belt, user)] [belt.gender==PLURAL?"some":"a"] [(belt.blood_color != "#030303") ? "blood" : "oil"]-stained [belt.name] about [t_his] waist!")]\n"
		else
			msg += "[t_He] [t_has] [icon2html(belt, user)] \a [belt] about [t_his] waist.\n"

	//shoes
	if(shoes && !skipshoes)
		if(shoes.blood_overlay)
			msg += "[span_alert("[t_He] [t_is] wearing [icon2html(shoes, user)] [shoes.gender==PLURAL?"some":"a"] [(shoes.blood_color != "#030303") ? "blood" : "oil"]-stained [shoes.name] on [t_his] feet!")]\n"
		else
			msg += "[t_He] [t_is] wearing [icon2html(shoes, user)] \a [shoes] on [t_his] feet.\n"
	else if(feet_blood_color)
		msg += "[span_alert("[t_He] [t_has] [(feet_blood_color != "#030303") ? "blood" : "oil"]-stained feet!")]\n"

	//mask
	if(wear_mask && !skipmask)
		if(istype(wear_mask, /obj/item/clothing/mask/facehugger))
			if(isxeno(user))
				msg += "[span_xenowarning("[t_He] [t_has] [icon2html(wear_mask, user)] \a little one on [t_his] face!")]\n"
			else
				msg += "[span_boldwarning("[t_He] [t_has] [icon2html(wear_mask, user)] \a [wear_mask] on [t_his] face!")]\n"
		else if(wear_mask.blood_overlay)
			msg += "[span_alert("[t_He] [t_has] [icon2html(wear_mask, user)] [wear_mask.gender==PLURAL?"some":"a"] [(wear_mask.blood_color != "#030303") ? "blood" : "oil"]-stained [wear_mask.name] on [t_his] face!")]\n"
		else
			msg += "[t_He] [t_has] [icon2html(wear_mask, user)] \a [wear_mask] on [t_his] face.\n"

	//eyes
	if(glasses && !skipeyes)
		if(glasses.blood_overlay)
			msg += "[span_alert("[t_He] [t_has] [icon2html(glasses, user)] [glasses.gender==PLURAL?"some":"a"] [(glasses.blood_color != "#030303") ? "blood" : "oil"]-stained [glasses] covering [t_his] eyes!")]\n"
		else
			msg += "[t_He] [t_has] [icon2html(glasses, user)] \a [glasses] covering [t_his] eyes.\n"

	//left ear
	if(wear_ear && !skipears)
		msg += "[t_He] [t_has] [icon2html(wear_ear, user)] \a [wear_ear] on [t_his] ear.\n"

	//ID
	if(wear_id)
		msg += "[t_He] [t_is] wearing [icon2html(wear_id, user)] \a [wear_id].\n"

	msg += separator_hr("Status")

	msg += "[t_He] [t_is] a [species.name].\n"

	//jitters
	if(stat != DEAD)
		if(jitteriness >= 300)
			msg += "[span_boldwarning("<B>[t_He] [t_is] convulsing violently!</B>")]\n"
		else if(jitteriness >= 200)
			msg += "[span_warning("[t_He] [t_is] extremely jittery.")]\n"
		else if(jitteriness >= 100)
			msg += "[span_warning("[t_He] [t_is] twitching ever so slightly.")]\n"

	//splints
	for(var/organ in list("l_leg","r_leg","l_arm","r_arm","l_foot","r_foot","l_hand","r_hand","chest","groin","head"))
		var/datum/limb/o = get_limb(organ)
		if(o)
			if(o.limb_status & LIMB_SPLINTED)
				msg += "[span_warning("[t_He] [t_has] a splint on [t_his] [o.display_name]!")]\n"
			if(o.limb_status & LIMB_STABILIZED)
				msg += "[span_warning("[t_He] [t_has] a suit brace stabilizing [t_his] [o.display_name]!")]\n"
			if(o.limb_status & LIMB_NECROTIZED)
				msg += "[span_deadsay("<b>An infection has rotted [t_his] [o.display_name] into uselessness!</b>")]\n"

	if(holo_card_color)
		msg += "[t_He] [t_has] a [holo_card_color] holo card on [t_his] chest.\n"

	if(suiciding)
		msg += "[span_deadsay("[t_He] appear[p_s()] to have commited suicide... there is no hope of recovery.")]\n"

	if(stat)
		if(stat == UNCONSCIOUS)
			msg += "[span_info("[t_He] [t_is]n't responding to anything around [t_him] and seem[p_s()] to be asleep.")]\n"
		if(stat == DEAD)
			msg += "[span_deadsay("[t_He] [t_is] limp and unresponsive; there are no signs of life")]"
			if(HAS_TRAIT(src, TRAIT_UNDEFIBBABLE))
				msg += "[span_deadsay(" and [t_he] [t_has] degraded beyond revival...")]\n"
			else if(!mind && !get_ghost(FALSE))
				msg += "[span_deadsay(" and [t_his] soul has departed, [t_he] might come back later...")]\n"
			else
				msg += "[span_deadsay("...")]\n"
		if(ishuman(user) && !user.stat && Adjacent(user))
			user.visible_message("<b>[user]</b> checks [src]'s pulse.", "You check [src]'s pulse.", null, 4)
		addtimer(CALLBACK(src, PROC_REF(take_pulse), user), 15)
	msg += "<span class='alert'>"

	if(nutrition < NUTRITION_STARVING)
		msg += "[t_He] [t_is] severely malnourished.\n"
	else if(nutrition >= NUTRITION_OVERFED)
		msg += "[t_He] look[p_s()] a bit stuffed.\n"

	msg += "</span>"

	if(getBrainLoss() >= 60)
		msg += "[t_He] [t_has] a stupid expression on [t_his] face.\n"

	if((!species.has_organ["brain"] || has_brain()) && stat != DEAD)
		if(!key)
			if(!has_ai())
				msg += "[span_deadsay("[t_He] [t_is] totally catatonic. The stresses of life in deep-space must have been too much for [t_him]. Any recovery is unlikely.")]\n"
		else if(!client)
			if(isxeno(user))
				msg += "[span_xenowarning("[t_He] [p_do()]n't seem responsive.")]\n"
			else
				msg += "[span_deadsay("[t_He] [t_is] completely unresponsive to anything and [t_has] fallen asleep, as if affected by Space Sleep Disorder. [t_He] may snap out of it soon.")]\n"

	var/total_brute = getBruteLoss()
	var/total_burn = getFireLoss()
	var/total_clone = getCloneLoss()
	if(total_brute)
		if (total_brute < 25)
			if(species.species_flags & ROBOTIC_LIMBS)
				msg += "[span_warning("[t_He] [t_has] minor denting.")]\n"
			else
				msg += "[span_warning("[t_He] [t_has] minor bruising.")]\n"
		else if (total_brute < 50)
			if(species.species_flags & ROBOTIC_LIMBS)
				msg += "[span_warning("[t_He] [t_has] <b>moderate</b> denting.")]\n"
			else
				msg += "[span_warning("[t_He] [t_has] <b>moderate</b> bruising.")]\n"
		else
			if(species.species_flags & ROBOTIC_LIMBS)
				msg += "[span_warning("<B>[t_He] [t_has] severe denting!</B>")]\n"
			else
				msg += "[span_warning("<B>[t_He] [t_has] severe bruising!</B>")]\n"

	if(total_burn)
		if (total_burn < 25)
			if(species.species_flags & ROBOTIC_LIMBS)
				msg += "[span_warning("[t_He] [t_has] minor scorching.")]\n"
			else
				msg += "[span_warning("[t_He] [t_has] minor burns.")]\n"
		else if (total_burn < 50)
			if(species.species_flags & ROBOTIC_LIMBS)
				msg += "[span_warning("[t_He] [t_has] <b>moderate</b> scorching.")]\n"
			else
				msg += "[span_warning("[t_He] [t_has] <b>moderate</b> burns.")]\n"
		else
			if(species.species_flags & ROBOTIC_LIMBS)
				msg += "[span_warning("<B>[t_He] [t_has] severe scorching!</B>")]\n"
			else
				msg += "[span_warning("<B>[t_He] [t_has] severe burns!</B>")]\n"

	if(total_clone)
		if(total_clone < 25)
			if(isrobot(src))
				msg += "[span_tinydeadsay("<i>[t_He] [t_has] minor structural damage, with some solder visibly frayed...</i>")]\n"
			else
				msg += "[span_tinydeadsay("<i>[t_He] [t_is] slightly disfigured, with light signs of cellular damage...</i>")]\n"
		else if (total_clone < 50)
			if(isrobot(src))
				msg += "[span_deadsay("<i>[t_He] look[p_s()] very shaky, with significant damage to [t_his] overall structure...</i>")]\n"
			else
				msg += "[span_deadsay("<i>[t_He] [t_is] significantly disfigured, with growing clouds of cellular damage...</i>")]\n"
		else
			if(isrobot(src))
				msg += "[span_deadsay("<b><i>[t_He] look[p_s()] barely functional, nearly collapsing with each step!</b></i>")]\n"
			else
				msg += "[span_deadsay("<b><i>[t_He] [t_is] absolutely fucked up, with streaks of sickening, deformed flesh on [t_his] skin!</b></i>")]\n"

	if(fire_stacks > 0)
		msg += "[t_He] [t_is] covered in something flammable.\n"
	if(fire_stacks < 0)
		msg += "[t_He] look[p_s()] a little soaked.\n"
	if(on_fire)
		msg += "[span_boldwarning("[t_He] [t_is] on fire!")]\n"

	var/list/wound_flavor_text = list() //List mapping each limb's display_name to its wound description
	var/list/is_destroyed = list()
	var/list/is_bleeding = list()
	for(var/datum/limb/temp_limb AS in limbs)
		if(temp_limb.limb_status & LIMB_DESTROYED)
			is_destroyed["[temp_limb.display_name]"] = 1
			wound_flavor_text["[temp_limb.display_name]"] = "[span_boldwarning("<b>[t_He] [t_is] missing [t_his] [temp_limb.display_name].</b>")]\n"
			continue
		if(temp_limb.limb_status & LIMB_ROBOT)
			if(!(temp_limb.brute_dam + temp_limb.burn_dam))
				if(!(species.species_flags & IS_SYNTHETIC))
					wound_flavor_text["[temp_limb.display_name]"] = "[span_tinynotice("[t_He] [t_has] a robot [temp_limb.display_name].")]\n"
					continue
			else
				wound_flavor_text["[temp_limb.display_name]"] = "<span class='warning'>[t_He] [t_has] a robot [temp_limb.display_name]. It has"
			if(temp_limb.brute_dam)
				switch(temp_limb.brute_dam)
					if(0 to 20)
						wound_flavor_text["[temp_limb.display_name]"] += " some dents"
					if(21 to INFINITY)
						wound_flavor_text["[temp_limb.display_name]"] += pick(" a lot of dents"," severe denting")
			if(temp_limb.brute_dam && temp_limb.burn_dam)
				wound_flavor_text["[temp_limb.display_name]"] += " and"
			if(temp_limb.burn_dam)
				switch(temp_limb.burn_dam)
					if(0 to 20)
						wound_flavor_text["[temp_limb.display_name]"] += " some burns"
					if(21 to INFINITY)
						wound_flavor_text["[temp_limb.display_name]"] += pick(" a lot of burns"," severe melting")
			if(wound_flavor_text["[temp_limb.display_name]"])
				wound_flavor_text["[temp_limb.display_name]"] += "!</span>\n"
		else
			if(temp_limb.limb_status & LIMB_BLEEDING)
				is_bleeding["[temp_limb.display_name]"] = 1
			var/healthy = TRUE
			var/brute_desc = ""
			switch(temp_limb.brute_dam)
				if(0.01 to 5)
					brute_desc = "minor scrapes"
				if(5 to 20)
					brute_desc = "some cuts"
				if(20 to 50)
					brute_desc = "major lacerations"
				if(50 to INFINITY)
					brute_desc = "gaping wounds"
			if(brute_desc)
				healthy = FALSE
				brute_desc = (temp_limb.limb_wound_status & LIMB_WOUND_BANDAGED ? "bandaged " : "") + brute_desc

			var/burn_desc = ""
			switch(temp_limb.burn_dam)
				if(0.01 to 5)
					brute_desc = "minor burns"
				if(5 to 20)
					brute_desc = "some blisters"
				if(20 to 50)
					brute_desc = "major burns"
				if(50 to INFINITY)
					brute_desc = "charring"
			if(burn_desc)
				healthy = FALSE
				burn_desc = (temp_limb.limb_wound_status & LIMB_WOUND_SALVED ? "salved " : "") + burn_desc

			var/germ_desc = ""
			switch(temp_limb.germ_level)
				if(INFECTION_LEVEL_ONE to INFECTION_LEVEL_TWO - 1)
					germ_desc = "mildly infected "
				if(INFECTION_LEVEL_TWO to INFINITY)
					germ_desc = "heavily infected "
			if(germ_desc)
				healthy = FALSE

			var/overall_desc = ""
			if(!healthy)
				overall_desc = "[t_He] [t_has] a [germ_desc][temp_limb.display_name]"
				if(brute_desc || burn_desc)
					overall_desc += " with [brute_desc]"
					if(brute_desc && burn_desc)
						overall_desc += " and "
					overall_desc += burn_desc
				overall_desc = span_warning(overall_desc + ".")
				wound_flavor_text["[temp_limb.display_name]"] = overall_desc + "\n"

	//Handles the text strings being added to the actual description.
	//If they have something that covers the limb, and it is not missing, put flavortext.  If it is covered but bleeding, add other flavortext.
	var/display_head = 0
	var/display_chest = 0
	var/display_groin = 0
	var/display_arm_left = 0
	var/display_arm_right = 0
	var/display_leg_left = 0
	var/display_leg_right = 0
	var/display_foot_left = 0
	var/display_foot_right = 0
	var/display_hand_left = 0
	var/display_hand_right = 0

	if(wound_flavor_text["head"] && (is_destroyed["head"] || (!skipmask && !(wear_mask && istype(wear_mask, /obj/item/clothing/mask/gas)))))
		msg += wound_flavor_text["head"]
	else if(is_bleeding["head"])
		display_head = 1
	if(wound_flavor_text["chest"] && !w_uniform && !skipjumpsuit) //No need.  A missing chest gibs you.
		msg += wound_flavor_text["chest"]
	else if(is_bleeding["chest"])
		display_chest = 1
	if(wound_flavor_text["left arm"] && (is_destroyed["left arm"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["left arm"]
	else if(is_bleeding["left arm"])
		display_arm_left = 1
	if(wound_flavor_text["left hand"] && (is_destroyed["left hand"] || (!gloves && !skipgloves)))
		msg += wound_flavor_text["left hand"]
	else if(is_bleeding["left hand"])
		display_hand_left = 1
	if(wound_flavor_text["right arm"] && (is_destroyed["right arm"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["right arm"]
	else if(is_bleeding["right arm"])
		display_arm_right = 1
	if(wound_flavor_text["right hand"] && (is_destroyed["right hand"] || (!gloves && !skipgloves)))
		msg += wound_flavor_text["right hand"]
	else if(is_bleeding["right hand"])
		display_hand_right = 1
	if(wound_flavor_text["groin"] && (is_destroyed["groin"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["groin"]
	else if(is_bleeding["groin"])
		display_groin = 1
	if(wound_flavor_text["left leg"] && (is_destroyed["left leg"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["left leg"]
	else if(is_bleeding["left leg"])
		display_leg_left = 1
	if(wound_flavor_text["left foot"] && (is_destroyed["left foot"] || (!shoes && !skipshoes)))
		msg += wound_flavor_text["left foot"]
	else if(is_bleeding["left foot"])
		display_foot_left = 1
	if(wound_flavor_text["right leg"] && (is_destroyed["right leg"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["right leg"]
	else if(is_bleeding["right leg"])
		display_leg_right = 1
	if(wound_flavor_text["right foot"] && (is_destroyed["right foot"] || (!shoes && !skipshoes)))
		msg += wound_flavor_text["right foot"]
	else if(is_bleeding["right foot"])
		display_foot_right = 1

	if (display_head)
		msg += "[span_warning("[t_He] [t_has] blood dripping from [t_his] <b>face!</b>")]\n"

	if (display_chest && display_groin && display_arm_left && display_arm_right && display_hand_left && display_hand_right && display_leg_left && display_leg_right && display_foot_left && display_foot_right)
		msg += "[span_warning("[t_He] [t_has] blood soaking through [t_his] clothes from [t_his] <b>entire body!</b>")]\n"
	else
		if (display_chest && display_arm_left && display_arm_right && display_hand_left && display_hand_right)
			msg += "[span_warning("[t_He] [t_has] blood soaking through [t_his] clothes from [t_his] <b>upper body!</b>")]\n"
		else
			if (display_chest)
				msg += "[span_warning("[t_He] [t_has] blood soaking through [t_his] <b>shirt!</b>")]\n"
			if (display_arm_left && display_arm_right && display_hand_left && display_hand_left)
				msg += "[span_warning("[t_He] [t_has] blood soaking through [t_his] <b>gloves</b> and <b>sleeves!</b>")]\n"
			else
				if (display_arm_left && display_arm_right)
					msg += "[span_warning("[t_He] [t_has] blood soaking through [t_his] <b>sleeves!</b>")]\n"
				else
					if (display_arm_left)
						msg += "[span_warning("[t_He] [t_has] blood soaking through [t_his] <b>left sleeve!</b>")]\n"
					if (display_arm_right)
						msg += "[span_warning("[t_He] [t_has] blood soaking through [t_his] <b>right sleeve!</b>")]\n"
				if (display_hand_left && display_hand_right)
					msg += "[span_warning("[t_He] [t_has] blood running out from under [t_his] <b>gloves!</b>")]\n"
				else
					if (display_hand_left)
						msg += "[span_warning("[t_He] [t_has] blood running out from under [t_his] <b>left glove!</b>")]\n"
					if (display_hand_right)
						msg += "[span_warning("[t_He] [t_has] blood running out from under [t_his] <b>right glove!</b>")]\n"

		if (display_groin && display_leg_left && display_leg_right && display_foot_left && display_foot_right)
			msg += "[span_warning("[t_He] [t_has] blood soaking through [t_his] clothes from [t_his] <b>lower body!</b>")]\n"
		else
			if (display_groin)
				msg += "[span_warning("[t_He] [t_has] blood dripping from [t_his] <b>groin!</b>")]\n"
			if (display_leg_left && display_leg_right && display_foot_left && display_foot_right)
				msg += "[span_warning("[t_He] [t_has] blood soaking through [t_his] <b>pant legs</b> and <b>boots!</b>")]\n"
			else
				if (display_leg_left && display_leg_right)
					msg += "[span_warning("[t_He] [t_has] blood soaking through [t_his] <b>pant legs!</b>")]\n"
				else
					if (display_leg_left)
						msg += "[span_warning("[t_He] [t_has] blood soaking through [t_his] <b>left pant leg!</b>")]\n"
					if (display_leg_right)
						msg += "[span_warning("[t_He] [t_has] blood soaking through [t_his] <b>right pant leg!</b>")]\n"
				if (display_foot_left && display_foot_right)
					msg += "[span_warning("[t_He] [t_has] blood pooling around[t_his] <b>boots!</b>")]\n"
				else
					if (display_foot_left)
						msg += "[span_warning("[t_He] [t_has] blood pooling around [t_his] <b>left boot!</b>")]\n"
					if (display_foot_right)
						msg += "[span_warning("[t_He] [t_has] blood pooling around [t_his] <b>right boot!</b>")]\n"

	if(chestburst == CARBON_CHEST_BURSTED)
		if(isxeno(user))
			msg += "[span_xenowarning("A larva escaped from [t_him]!")]\n"
		else
			msg += "[span_boldwarning("[t_He] [t_has] a giant hole in [t_his] chest!")]\n"

	for(var/i in embedded_objects)
		msg += EXAMINE_SECTION_BREAK
		var/obj/item/embedded = i
		if(!(embedded.embedding.embedded_flags & EMBEDDED_CAN_BE_YANKED_OUT))
			continue
		msg += "[span_boldwarning("[t_He] [t_has] \a [embedded] sticking out of [t_his] flesh!")]\n"

	if(flavor_text)
		msg += separator_hr("Flavor Text")
		msg += flavor_text

	if(hasHUD(user,"security"))
		msg += separator_hr("Security HUD")
		var/perpname = "wot"
		var/criminal = "None"

		var/obj/item/card/id/I = get_idcard()
		if(istype(I))
			perpname = I.registered_name
		else
			perpname = name

		if(perpname)
			for (var/datum/data/record/E in GLOB.datacore.general)
				if(E.fields["name"] == perpname)
					for (var/datum/data/record/R in GLOB.datacore.security)
						if(R.fields["id"] == E.fields["id"])
							criminal = R.fields["criminal"]

			msg += "[span_deptradio("Criminal status:")] <a href='byond://?src=[text_ref(src)];criminal=1'>\[[criminal]\]</a>\n"
			msg += "[span_deptradio("Security records:")] <a href='byond://?src=[text_ref(src)];secrecord=`'>\[View\]</a>  <a href='byond://?src=[text_ref(src)];secrecordadd=`'>\[Add comment\]</a>\n"

	if(hasHUD(user,"medical"))
		msg += separator_hr("Medical HUD")
		var/cardcolor = holo_card_color
		if(!cardcolor)
			cardcolor = "none"
		msg += "[span_deptradio("Triage holo card:")] <a href='byond://?src=[text_ref(src)];medholocard=1'>\[[cardcolor]\]</a> | "

		// scan reports
		var/datum/data/record/medical_record = find_medical_record(src)
		if(!isnull(medical_record?.fields["historic_scan"]))
			msg += "<a href='byond://?src=[text_ref(src)];scanreport=1'>Body scan from [medical_record.fields["historic_scan_time"]]...</a>\n"
		else
			msg += "[span_deptradio("No body scan report on record")]\n"

	if(hasHUD(user,"squadleader"))
		msg += separator_hr("SL Utilities")
		var/mob/living/carbon/human/H = user
		if(assigned_squad) //examined mob is a marine in a squad
			if(assigned_squad == H.assigned_squad) //same squad
				msg += "<a href='byond://?src=[text_ref(src)];squadfireteam=1'>\[Assign to a fireteam.\]</a>\n"

	if(HAS_TRAIT(src, TRAIT_HOLLOW))
		if(isxeno(user))
			msg += "<span style='font-weight: bold; color: purple;'>[t_He] [t_is] hollow. Useless.</span>\n"
		else
			msg += "[span_deadsay("<b>[t_He] [t_is] hollowed out!</b>")]\n"

	if(isxeno(user))
		msg += separator_hr("Xeno Info")
		if(species.species_flags & IS_SYNTHETIC)
			msg += "[span_xenowarning("You sense [t_he] [t_is] not organic.")]\n"
		if(status_flags & XENO_HOST)
			msg += "[t_He] [t_is] impregnated.\n"
		if(reagents.get_reagent_amount(/datum/reagent/toxin/xeno_neurotoxin))
			msg += "Neurotoxin([reagents.get_reagent_amount(/datum/reagent/toxin/xeno_neurotoxin)]u): Causes increasingly intense pain and stamina damage over time, increasing in intensity at the 40 second and the minute and a half mark of metabolism.\n"
		if(reagents.get_reagent_amount(/datum/reagent/toxin/xeno_hemodile))
			msg += "Hemodile([reagents.get_reagent_amount(/datum/reagent/toxin/xeno_hemodile)]u): Slows down the target, doubling in power with each other xeno-based toxin present.\n"
		if(reagents.get_reagent_amount(/datum/reagent/toxin/xeno_transvitox))
			msg += "Transvitox([reagents.get_reagent_amount(/datum/reagent/toxin/xeno_transvitox)]u): Converts burns to toxin over time, as well as causing incoming brute damage to deal additional toxin damage. Both effects intensifying with each xeno-based toxin present. Toxin damage is capped at 180.\n"
		if(reagents.get_reagent_amount(/datum/reagent/toxin/xeno_ozelomelyn))
			msg += "Ozelomelyn([reagents.get_reagent_amount(/datum/reagent/toxin/xeno_ozelomelyn)]u): Rapidly purges all medicine in the body, causes toxin damage capped at 40. Metabolizes very quickly.\n"
		if(reagents.get_reagent_amount(/datum/reagent/toxin/xeno_sanguinal))
			msg += "Sanguinal([reagents.get_reagent_amount(/datum/reagent/toxin/xeno_sanguinal)]u): Causes brute damage and bleeding from the brute damage. Does additional damage types in the presence of other xeno-based toxins. Toxin damage for Neuro, Stamina damage for Hemodile, and Burn damage for Transvitox.\n"

//defiler specific examine info
		if(istype(user, /mob/living/carbon/xenomorph/defiler))
			if(reagents.get_reagent_amount(/datum/reagent/medicine/bicaridine))
				msg += "Bicaridine([reagents.get_reagent_amount(/datum/reagent/medicine/bicaridine)]u): Weak brute medication used by most marines. Heals slowly.\n"
			if(reagents.get_reagent_amount(/datum/reagent/medicine/kelotane))
				msg += "Kelotane([reagents.get_reagent_amount(/datum/reagent/medicine/kelotane)]u): Weak burn medication used by most marines. Heals slowly.\n"
			if(reagents.get_reagent_amount(/datum/reagent/medicine/tricordrazine))
				msg += "Tricordrazine([reagents.get_reagent_amount(/datum/reagent/medicine/tricordrazine)]u): General healing chem, heals all types of common damage by a small ammount.\n"
			if(reagents.get_reagent_amount(/datum/reagent/medicine/meralyne))
				msg += "Meralyne([reagents.get_reagent_amount(/datum/reagent/medicine/meralyne)]u): Strong brute medication used commonly by corpsman.\n"
			if(reagents.get_reagent_amount(/datum/reagent/medicine/dermaline))
				msg += "Dermaline([reagents.get_reagent_amount(/datum/reagent/medicine/dermaline)]u): Strong burn medication used commonly by corpsman.\n"

			if(reagents.get_reagent_amount(/datum/reagent/medicine/tramadol))
				msg += "Tramadol([reagents.get_reagent_amount(/datum/reagent/medicine/tramadol)]u): General use anti-pain medication used by most marines.\n"
			if(reagents.get_reagent_amount(/datum/reagent/medicine/paracetamol))
				msg += "Paracetamol([reagents.get_reagent_amount(/datum/reagent/medicine/paracetamol)]u): Weak anti-pain medication. rarely used.\n"
			if(reagents.get_reagent_amount(/datum/reagent/medicine/oxycodone))
				msg += "Oxycodone([reagents.get_reagent_amount(/datum/reagent/medicine/oxycodone)]u): Very strong anti-pain medication commonly found on corpsman.\n"

			if(reagents.get_reagent_amount(/datum/reagent/medicine/dylovene))
				msg += "Dylovene([reagents.get_reagent_amount(/datum/reagent/medicine/dylovene)]u): Basic toxin removal medication.\n"
			if(reagents.get_reagent_amount(/datum/reagent/medicine/inaprovaline))
				msg += "Inaprovaline([reagents.get_reagent_amount(/datum/reagent/medicine/inaprovaline)]u):  Heals vast ammount of damage after injection in crit and prevents further oxygen damage while present.\n"
			if(reagents.get_reagent_amount(/datum/reagent/medicalnanites))
				msg += "Medical nanites([reagents.get_reagent_amount(/datum/reagent/medicalnanites)]u): Uses marines blood healing moderate ammounts of burn and brute all the time. Cannot be purged by ozelomelyn but can be by defiling.\n"

	if(has_status_effect(STATUS_EFFECT_ADMINSLEEP))
		msg += separator_hr("[span_boldwarning("Admin Slept")]")
		msg += span_userdanger("This player has been slept by staff. Leave them be.\n")

	if(isadmin(user))
		msg += separator_hr("Admin Interactions")
		msg += span_admin("<span class='notice linkify'>[ADMIN_FULLMONTY(src)]</span>")

	msg += "</span>"
	return list(msg)

/mob/living/carbon/human/proc/take_pulse(mob/user)
	if(QDELETED(user) || QDELETED(src) || !Adjacent(user) || user.incapacitated())
		return
	var/pulse_taken = get_pulse(GETPULSE_HAND)
	if(pulse_taken == PULSE_NONE)
		to_chat(user, span_deadsay("[p_they(TRUE)] [p_have()] no pulse..."))
	else
		to_chat(user, span_deadsay("[p_their(TRUE)] pulse is [pulse_taken]."))

//Helper procedure. Called by /mob/living/carbon/human/examine() and /mob/living/carbon/human/Topic() to determine HUD access to security and medical records.
/proc/hasHUD(mob/M, hudtype)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		switch(hudtype)
			if("security")
				//only MPs can use the security HUD glasses's functionalities
				if(H.skills.getRating(SKILL_POLICE) >= SKILL_POLICE_MP)
					return istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(H.glasses, /obj/item/clothing/glasses/sunglasses/sechud)
			if("medical")
				return istype(H.glasses, /obj/item/clothing/glasses/hud/health)
			if("squadleader")
				return H.mind && H.assigned_squad && H.assigned_squad.squad_leader == H && istype(H.wear_ear, /obj/item/radio/headset/mainship)
			else
				return 0
	else
		return 0
