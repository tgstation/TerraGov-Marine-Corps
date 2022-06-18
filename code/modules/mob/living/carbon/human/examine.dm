/mob/living/carbon/human/examine(mob/user)
	SHOULD_CALL_PARENT(FALSE)
	if (isxeno(user))
		var/msg = "<span class='info'>*---------*\nThis is "
		if(icon)
			msg += "[icon2html(icon, user)] "
		msg += "<b>[name]</b>!\n"

		if(species.species_flags & IS_SYNTHETIC)
			msg += "<span style='font-weight: bold; color: purple;'>You sense this creature is not organic.</span>\n"
		if(status_flags & XENO_HOST)
			msg += "This creature is impregnated. \n"
		else if(chestburst == 2)
			msg += "A larva escaped from this creature.\n"
		if (headbitten)
			msg += "This creature has been purged of vital organs in the head.\n"
		if(istype(wear_mask, /obj/item/clothing/mask/facehugger))
			msg += "It has a little one on its face.\n"
		if(on_fire)
			msg += "It is on fire!\n"
		if(stat == DEAD)
			msg += "<span style='font-weight: bold; color: purple;'>You sense this creature is dead.</span>\n"
		else if(stat || !client)
			msg += "[span_xenowarning("It doesn't seem responsive.")]\n"
		if(reagents.get_reagent_amount(/datum/reagent/toxin/xeno_transvitox))
			msg += "Transvitox: 40% brute/burn injuries received are converted to toxin\n"
		if(reagents.get_reagent_amount(/datum/reagent/toxin/xeno_hemodile))
			msg += "Hemodile: 20% stamina damage received, when damaged, and slowed by 25% (inject neurotoxin for 50% slow)\n"
		msg += "*---------*</span>"
		return list(msg)

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
		skipgloves = wear_suit.flags_inv_hide & HIDEGLOVES
		skipsuitstorage = wear_suit.flags_inv_hide & HIDESUITSTORAGE
		skipjumpsuit = wear_suit.flags_inv_hide & HIDEJUMPSUIT
		skipshoes = wear_suit.flags_inv_hide & HIDESHOES

	if(head)
		skipmask = head.flags_inv_hide & HIDEMASK
		skipeyes = head.flags_inv_hide & HIDEEYES
		skipears = head.flags_inv_hide & HIDEEARS
		skipface = head.flags_inv_hide & HIDEFACE

	if(wear_mask)
		skipface |= wear_mask.flags_inv_hide & HIDEFACE

	var/t_He = p_they(TRUE) //capitalised for use at the start of each line.
	var/t_his = p_their()
	var/t_him = p_them()
	var/t_has = p_have()
	var/t_is = p_are()

	var/msg = "<span class='info'>*---------*\nThis is "

	if(icon)
		msg += "[icon2html(icon, user)] " //fucking BYOND: this should stop dreamseeker crashing if we -somehow- examine somebody before their icon is generated

	msg += "<EM>[src.name]</EM>!\n"

	//uniform
	if(w_uniform && !skipjumpsuit)
		if(w_uniform.blood_overlay)
			msg += "[span_warning("[t_He] [t_is] wearing [icon2html(w_uniform, user)] [w_uniform.gender==PLURAL?"some":"a"] [(w_uniform.blood_color != "#030303") ? "blood" : "oil"]-stained [w_uniform.name]!")]\n"
		else
			msg += "[t_He] [t_is] wearing [icon2html(w_uniform, user)] \a [w_uniform].\n"

	//head
	if(head)
		if(head.blood_overlay)
			msg += "[span_warning("[t_He] [t_is] wearing [icon2html(head, user)] [head.gender==PLURAL?"some":"a"] [(head.blood_color != "#030303") ? "blood" : "oil"]-stained [head.name] on [t_his] head!")]\n"
		else
			msg += "[t_He] [t_is] wearing [icon2html(head, user)] \a [head] on [t_his] head.\n"

	//suit/armour
	if(wear_suit)
		if(wear_suit.blood_overlay)
			msg += "[span_warning("[t_He] [t_is] wearing [icon2html(wear_suit, user)] [wear_suit.gender==PLURAL?"some":"a"] [(wear_suit.blood_color != "#030303") ? "blood" : "oil"]-stained [wear_suit.name]!")]\n"
		else
			msg += "[t_He] [t_is] wearing [icon2html(wear_suit, user)] \a [wear_suit].\n"

		//suit/armour storage
		if(s_store && !skipsuitstorage)
			if(s_store.blood_overlay)
				msg += "[span_warning("[t_He] [t_is] carrying [icon2html(s_store, user)] [s_store.gender==PLURAL?"some":"a"] [(s_store.blood_color != "#030303") ? "blood" : "oil"]-stained [s_store.name] on [t_his] [wear_suit.name]!")]\n"
			else
				msg += "[t_He] [t_is] carrying [icon2html(s_store, user)] \a [s_store] on [t_his] [wear_suit.name].\n"

	//back
	if(back)
		if(back.blood_overlay)
			msg += "[span_warning("[t_He] [t_has] [icon2html(back, user)] [back.gender==PLURAL?"some":"a"] [(back.blood_color != "#030303") ? "blood" : "oil"]-stained [back] on [t_his] back.")]\n"
		else
			msg += "[t_He] [t_has] [icon2html(back, user)] \a [back] on [t_his] back.\n"

	//left hand
	if(l_hand)
		if(l_hand.blood_overlay)
			msg += "[span_warning("[t_He] [t_is] holding [icon2html(l_hand, user)] [l_hand.gender==PLURAL?"some":"a"] [(l_hand.blood_color != "#030303") ? "blood" : "oil"]-stained [l_hand.name] in [t_his] left hand!")]\n"
		else
			msg += "[t_He] [t_is] holding [icon2html(l_hand, user)] \a [l_hand] in [t_his] left hand.\n"

	//right hand
	if(r_hand)
		if(r_hand.blood_overlay)
			msg += "[span_warning("[t_He] [t_is] holding [icon2html(r_hand, user)] [r_hand.gender==PLURAL?"some":"a"] [(r_hand.blood_color != "#030303") ? "blood" : "oil"]-stained [r_hand.name] in [t_his] right hand!")]\n"
		else
			msg += "[t_He] [t_is] holding [icon2html(r_hand, user)] \a [r_hand] in [t_his] right hand.\n"

	//gloves
	if(gloves && !skipgloves)
		if(gloves.blood_overlay)
			msg += "[span_warning("[t_He] [t_has] [icon2html(gloves, user)] [gloves.gender==PLURAL?"some":"a"] [(gloves.blood_color != "#030303") ? "blood" : "oil"]-stained [gloves.name] on [t_his] hands!")]\n"
		else
			msg += "[t_He] [t_has] [icon2html(gloves, user)] \a [gloves] on [t_his] hands.\n"
	else if(blood_color)
		msg += "[span_warning("[t_He] [t_has] [(blood_color != "#030303") ? "blood" : "oil"]-stained hands!")]\n"

	//handcuffed?

	//handcuffed?
	if(handcuffed)
		if(istype(handcuffed, /obj/item/restraints/handcuffs/cable))
			msg += "[span_warning("[t_He] [t_is] [icon2html(handcuffed, user)] restrained with cable!")]\n"
		else
			msg += "[span_warning("[t_He] [t_is] [icon2html(handcuffed, user)] handcuffed!")]\n"

	//belt
	if(belt)
		if(belt.blood_overlay)
			msg += "[span_warning("[t_He] [t_has] [icon2html(belt, user)] [belt.gender==PLURAL?"some":"a"] [(belt.blood_color != "#030303") ? "blood" : "oil"]-stained [belt.name] about [t_his] waist!")]\n"
		else
			msg += "[t_He] [t_has] [icon2html(belt, user)] \a [belt] about [t_his] waist.\n"

	//shoes
	if(shoes && !skipshoes)
		if(shoes.blood_overlay)
			msg += "[span_warning("[t_He] [t_is] wearing [icon2html(shoes, user)] [shoes.gender==PLURAL?"some":"a"] [(shoes.blood_color != "#030303") ? "blood" : "oil"]-stained [shoes.name] on [t_his] feet!")]\n"
		else
			msg += "[t_He] [t_is] wearing [icon2html(shoes, user)] \a [shoes] on [t_his] feet.\n"
	else if(feet_blood_color)
		msg += "[span_warning("[t_He] [t_has] [(feet_blood_color != "#030303") ? "blood" : "oil"]-stained feet!")]\n"

	//mask
	if(wear_mask && !skipmask)
		if(wear_mask.blood_overlay)
			msg += "[span_warning("[t_He] [t_has] [icon2html(wear_mask, user)] [wear_mask.gender==PLURAL?"some":"a"] [(wear_mask.blood_color != "#030303") ? "blood" : "oil"]-stained [wear_mask.name] on [t_his] face!")]\n"
		else
			msg += "[t_He] [t_has] [icon2html(wear_mask, user)] \a [wear_mask] on [t_his] face.\n"

	//eyes
	if(glasses && !skipeyes)
		if(glasses.blood_overlay)
			msg += "[span_warning("[t_He] [t_has] [icon2html(glasses, user)] [glasses.gender==PLURAL?"some":"a"] [(glasses.blood_color != "#030303") ? "blood" : "oil"]-stained [glasses] covering [t_his] eyes!")]\n"
		else
			msg += "[t_He] [t_has] [icon2html(glasses, user)] \a [glasses] covering [t_his] eyes.\n"

	//left ear
	if(wear_ear && !skipears)
		msg += "[t_He] [t_has] [icon2html(wear_ear, user)] \a [wear_ear] on [t_his] ear.\n"

	//ID
	if(wear_id)
		/*var/id
		if(istype(wear_id, /obj/item/pda))
			var/obj/item/pda/pda = wear_id
			id = pda.owner
		else if(istype(wear_id, /obj/item/card/id)) //just in case something other than a PDA/ID card somehow gets in the ID slot :[
			var/obj/item/card/id/idcard = wear_id
			id = idcard.registered_name
		if(id && (id != real_name) && (get_dist(src, user) <= 1) && prob(10))
			msg += "[span_warning("[t_He] [t_is] wearing \icon[wear_id] \a [wear_id] yet something doesn't seem right...")]\n"
		else*/
		msg += "[t_He] [t_is] wearing [icon2html(wear_id, user)] \a [wear_id].\n"

	//jitters
	if(stat != DEAD)
		if(jitteriness >= 300)
			msg += "[span_warning("<B>[t_He] [t_is] convulsing violently!</B>")]\n"
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
				msg += "[span_warning("An infection has rotted [t_his] [o.display_name] into uselessness!")]\n"

	if(holo_card_color)
		msg += "[t_He] has a [holo_card_color] holo card on [t_his] chest.\n"

	if(suiciding)
		msg += "[span_warning("[t_He] appears to have commited suicide... there is no hope of recovery.")]\n"

	var/distance = get_dist(user,src)
	if(isobserver(user) || user.stat == DEAD) // ghosts can see anything
		distance = 1
	if(stat)
		msg += "[span_warning("[t_He] [t_is]n't responding to anything around [t_him] and seems to be asleep.")]\n"
		if((stat == DEAD || health < get_crit_threshold()) && distance <= 3)
			msg += "[span_warning("[t_He] does not appear to be breathing.")]\n"
			if(HAS_TRAIT(src, TRAIT_UNDEFIBBABLE) && distance <= 1)
				msg += "[span_deadsay("[t_He] [t_has] gone cold.")]\n"
		if(ishuman(user) && !user.stat && Adjacent(user))
			user.visible_message("<b>[user]</b> checks [src]'s pulse.", "You check [src]'s pulse.", null, 4)
		addtimer(CALLBACK(src, .proc/take_pulse, user), 15)

	msg += "<span class='warning'>"

	if(nutrition < NUTRITION_STARVING)
		msg += "[t_He] [t_is] severely malnourished.\n"
	else if(nutrition >= NUTRITION_OVERFED)
		msg += "[t_He] looks a bit stuffed.\n"

	msg += "</span>"

	if(getBrainLoss() >= 60)
		msg += "[t_He] [t_has] a stupid expression on [t_his] face.\n"

	if((!species.has_organ["brain"] || has_brain()) && stat != DEAD)
		if(!key)
			if(species.is_sentient)
				msg += "[span_deadsay("[t_He] [t_is] fast asleep. It doesn't look like they are waking up anytime soon.")]\n"
		else if(!client)
			msg += "[t_He] [t_has] suddenly fallen asleep.\n"

	if(fire_stacks > 0)
		msg += "[t_He] [t_is] covered in something flammable.\n"
	if(fire_stacks < 0)
		msg += "[t_He] looks a little soaked.\n"
	if(on_fire)
		msg += "[span_warning("[t_He] [t_is] on fire!")]\n"

	var/list/wound_flavor_text = list() //List mapping each limb's display_name to its wound description
	var/list/is_destroyed = list()
	var/list/is_bleeding = list()
	for(var/datum/limb/temp AS in limbs)
		if(temp.limb_status & LIMB_DESTROYED)
			is_destroyed["[temp.display_name]"] = 1
			wound_flavor_text["[temp.display_name]"] = "[span_warning("<b>[t_He] is missing [t_his] [temp.display_name].</b>")]\n"
			continue
		if(temp.limb_status & LIMB_ROBOT)
			if(!(temp.brute_dam + temp.burn_dam))
				if(!(species.species_flags & IS_SYNTHETIC))
					wound_flavor_text["[temp.display_name]"] = "[span_warning("[t_He] has a robot [temp.display_name]!")]\n"
					continue
			else
				wound_flavor_text["[temp.display_name]"] = "<span class='warning'>[t_He] has a robot [temp.display_name]. It has"
			if(temp.brute_dam) switch(temp.brute_dam)
				if(0 to 20)
					wound_flavor_text["[temp.display_name]"] += " some dents"
				if(21 to INFINITY)
					wound_flavor_text["[temp.display_name]"] += pick(" a lot of dents"," severe denting")
			if(temp.brute_dam && temp.burn_dam)
				wound_flavor_text["[temp.display_name]"] += " and"
			if(temp.burn_dam) switch(temp.burn_dam)
				if(0 to 20)
					wound_flavor_text["[temp.display_name]"] += " some burns"
				if(21 to INFINITY)
					wound_flavor_text["[temp.display_name]"] += pick(" a lot of burns"," severe melting")
			if(wound_flavor_text["[temp.display_name]"])
				wound_flavor_text["[temp.display_name]"] += "!</span>\n"
		else
			if(temp.limb_status & LIMB_BLEEDING)
				is_bleeding["[temp.display_name]"] = 1
			var/healthy = TRUE
			var/brute_desc = ""
			switch(temp.brute_dam)
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
				brute_desc = (temp.limb_wound_status & LIMB_WOUND_BANDAGED ? "bandaged " : "") + brute_desc

			var/burn_desc = ""
			switch(temp.burn_dam)
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
				burn_desc = (temp.limb_wound_status & LIMB_WOUND_SALVED ? "salved " : "") + burn_desc

			var/germ_desc = ""
			switch(temp.germ_level)
				if(INFECTION_LEVEL_ONE to INFECTION_LEVEL_TWO - 1)
					germ_desc = "mildly infected "
				if(INFECTION_LEVEL_TWO to INFINITY)
					germ_desc = "heavily infected "
			if(germ_desc)
				healthy = FALSE

			var/overall_desc = ""
			if(healthy)
				overall_desc = span_notice("[t_He] has a healthy [temp.display_name].")
			else
				overall_desc = "[t_He] has a [germ_desc][temp.display_name]"
				if(brute_desc || burn_desc)
					overall_desc += " with [brute_desc]"
					if(brute_desc && burn_desc)
						overall_desc += " and "
					overall_desc += burn_desc
				overall_desc = span_warning(overall_desc + ".")
			wound_flavor_text["[temp.display_name]"] = overall_desc + "\n"

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
	if(wound_flavor_text["left foot"]&& (is_destroyed["left foot"] || (!shoes && !skipshoes)))
		msg += wound_flavor_text["left foot"]
	else if(is_bleeding["left foot"])
		display_foot_left = 1
	if(wound_flavor_text["right leg"] && (is_destroyed["right leg"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["right leg"]
	else if(is_bleeding["right leg"])
		display_leg_right = 1
	if(wound_flavor_text["right foot"]&& (is_destroyed["right foot"] || (!shoes  && !skipshoes)))
		msg += wound_flavor_text["right foot"]
	else if(is_bleeding["right foot"])
		display_foot_right = 1

	if (display_head)
		msg += "[span_warning("[t_He] has blood dripping from [t_his] <b>face</b>!")]\n"

	if (display_chest && display_groin && display_arm_left && display_arm_right && display_hand_left && display_hand_right && display_leg_left && display_leg_right && display_foot_left && display_foot_right)
		msg += "[span_warning("[t_He] has blood soaking through [t_his] clothes from [t_his] <b>entire body</b>!")]\n"
	else
		if (display_chest && display_arm_left && display_arm_right && display_hand_left && display_hand_right)
			msg += "[span_warning("[t_He] has blood soaking through [t_his] clothes from [t_his] <b>upper body</b>!")]\n"
		else
			if (display_chest)
				msg += "[span_warning("[t_He] has blood soaking through [t_his] <b>shirt</b>!")]\n"
			if (display_arm_left && display_arm_right && display_hand_left && display_hand_left)
				msg += "[span_warning("[t_He] has blood soaking through [t_his] <b>gloves</b> and <b>sleeves</b>!")]\n"
			else
				if (display_arm_left && display_arm_right)
					msg += "[span_warning("[t_He] has blood soaking through [t_his] <b>sleeves</b>!")]\n"
				else
					if (display_arm_left)
						msg += "[span_warning("[t_He] has soaking through [t_his] <b>left sleeve</b>!")]\n"
					if (display_arm_right)
						msg += "[span_warning("[t_He] has soaking through [t_his] <b>right sleeve</b>!")]\n"
				if (display_hand_left && display_hand_right)
					msg += "[span_warning("[t_He] has blood running out from under [t_his] <b>gloves</b>!")]\n"
				else
					if (display_hand_left)
						msg += "[span_warning("[t_He] has blood running out from under [t_his] <b>left glove</b>!")]\n"
					if (display_hand_right)
						msg += "[span_warning("[t_He] has blood running out from under [t_his] <b>right glove</b>!")]\n"

		if (display_groin && display_leg_left && display_leg_right && display_foot_left && display_foot_right)
			msg += "[span_warning("[t_He] has blood soaking through [t_his] clothes from [t_his] <b>lower body!</b>")]\n"
		else
			if (display_groin)
				msg += "[span_warning("[t_He] has blood dripping from [t_his] <b>groin</b>!")]\n"
			if (display_leg_left && display_leg_right && display_foot_left && display_foot_right)
				msg += "[span_warning("[t_He] has blood soaking through [t_his] <b>pant legs</b> and <b>boots</b>!")]\n"
			else
				if (display_leg_left && display_leg_right)
					msg += "[span_warning("[t_He] has blood soaking through [t_his] <b>pant legs</b>!")]\n"
				else
					if (display_leg_left)
						msg += "[span_warning("[t_He] has blood soaking through [t_his] <b>left pant leg</b>!")]\n"
					if (display_leg_right)
						msg += "[span_warning("[t_He] has blood soaking through [t_his] <b>right pant leg</b>!")]\n"
				if (display_foot_left && display_foot_right)
					msg += "[span_warning("[t_He] has blood pooling around[t_his] <b>boots</b>!")]\n"
				else
					if (display_foot_left)
						msg += "[span_warning("[t_He] has blood pooling around [t_his] <b>left boot</b>!")]\n"
					if (display_foot_right)
						msg += "[span_warning("[t_He] has blood pooling around [t_his] <b>right boot</b>!")]\n"

	if(chestburst == 2)
		msg += "[span_warning("<b>[t_He] has a giant hole in [t_his] chest!</b>")]\n"

	if(headbitten)
		msg += "[span_warning("<b>[t_He] has a giant hole in [t_his] head!</b>")]\n"


	for(var/i in embedded_objects)
		var/obj/item/embedded = i
		if(!(embedded.embedding.embedded_flags & EMBEDDED_CAN_BE_YANKED_OUT))
			continue
		msg += "[span_warning("<b>[t_He] has \a [embedded] sticking out of [t_his] flesh!")]\n"

	if(hasHUD(user,"security"))
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

			msg += "<span class = 'deptradio'>Criminal status:</span> <a href='?src=\ref[src];criminal=1'>\[[criminal]\]</a>\n"
			msg += "<span class = 'deptradio'>Security records:</span> <a href='?src=\ref[src];secrecord=`'>\[View\]</a>  <a href='?src=\ref[src];secrecordadd=`'>\[Add comment\]</a>\n"

	if(hasHUD(user,"medical"))
/*
		var/perpname = "wot"
		var/medical = "None"

		if(wear_id)
			if(istype(wear_id,/obj/item/card/id))
				perpname = wear_id:registered_name
			else if(istype(wear_id,/obj/item/pda))
				var/obj/item/pda/tempPda = wear_id
				perpname = tempPda.owner
		else
			perpname = src.name

		for (var/datum/data/record/E in GLOB.datacore.general)
			if (E.fields["name"] == perpname)
				for (var/datum/data/record/R in GLOB.datacore.general)
					if (R.fields["id"] == E.fields["id"])
						medical = R.fields["p_stat"]
		msg += "<span class = 'deptradio'>Physical status:</span> <a href='?src=\ref[src];medical=1'>\[[medical]\]</a>\n"
		msg += "<span class = 'deptradio'>Medical records:</span> <a href='?src=\ref[src];medrecord=`'>\[View\]</a> <a href='?src=\ref[src];medrecordadd=`'>\[Add comment\]</a>\n"
*/
		var/cardcolor = holo_card_color
		if(!cardcolor) cardcolor = "none"
		msg += "<span class = 'deptradio'>Triage holo card:</span> <a href='?src=\ref[src];medholocard=1'>\[[cardcolor]\]</a> - "

		// scan reports
		var/datum/data/record/N = null
		for(var/datum/data/record/R in GLOB.datacore.medical)
			if (R.fields["name"] == real_name)
				N = R
				break
		if(!isnull(N))
			if(!(N.fields["last_scan_time"]))
				msg += "<span class = 'deptradio'>No scan report on record</span>\n"
			else
				msg += "<span class = 'deptradio'><a href='?src=\ref[src];scanreport=1'>Scan from [N.fields["last_scan_time"]]</a></span>\n"


	if(hasHUD(user,"squadleader"))
		var/mob/living/carbon/human/H = user
		if(assigned_squad) //examined mob is a marine in a squad
			if(assigned_squad == H.assigned_squad) //same squad
				msg += "<a href='?src=\ref[src];squadfireteam=1'>\[Assign to a fireteam.\]</a>\n"


	msg += "[flavor_text]<br>"

	if(has_status_effect(STATUS_EFFECT_ADMINSLEEP))
		msg += span_highdanger("<B>This player has been slept by staff.</B>\n")

	msg += "*---------*</span>"

	return list(msg)

/mob/living/carbon/human/proc/take_pulse(mob/user)
	if(QDELETED(user) || QDELETED(src) || !Adjacent(user) || user.incapacitated())
		return
	var/pulse_taken = get_pulse(GETPULSE_HAND)
	if(pulse_taken == PULSE_NONE)
		to_chat(user, span_deadsay("[p_they(TRUE)] has no pulse[client ? "" : " and [p_their()] soul has departed, although they may be revivable"]..."))
	else
		to_chat(user, span_deadsay("[p_their(TRUE)] pulse is [pulse_taken]."))

//Helper procedure. Called by /mob/living/carbon/human/examine() and /mob/living/carbon/human/Topic() to determine HUD access to security and medical records.
/proc/hasHUD(mob/M, hudtype)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		switch(hudtype)
			if("security")
				//only MPs can use the security HUD glasses's functionalities
				if(H.skills.getRating("police") >= SKILL_POLICE_MP)
					return istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(H.glasses, /obj/item/clothing/glasses/sunglasses/sechud)
			if("medical")
				return istype(H.glasses, /obj/item/clothing/glasses/hud/health)
			if("squadleader")
				return H.mind && H.assigned_squad && H.assigned_squad.squad_leader == H && istype(H.wear_ear, /obj/item/radio/headset/mainship/marine)
			else
				return 0
	else
		return 0
