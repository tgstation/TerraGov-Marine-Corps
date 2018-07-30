/mob/living/carbon/human/examine(mob/user)
	if( user.sdisabilities & BLIND || user.blinded || user.stat==UNCONSCIOUS )
		user << "<span class='notice'>Something is there but you can't see it.</span>"
		return

	if (isXeno(user))
		var/msg = "<span class='info'>*---------*\nThis is "

		if(icon)
			msg += "\icon[icon] "
		msg += "<EM>[src.name]</EM>!\n"

		if(species.flags & IS_SYNTHETIC)
			msg += "<span style='font-weight: bold; color: purple;'>You sense this creature is not organic.</span>\n"

		if(status_flags & XENO_HOST)
			msg += "This creature is impregnated.\n"
		else if(chestburst == 2)
			msg += "A larva escaped from this creature.\n"
		if(istype(wear_mask, /obj/item/clothing/mask/facehugger))
			msg += "It has a little one on its face.\n"
		if(on_fire)
			msg += "It is on fire!\n"
		if(stat == DEAD)
			msg += "<span style='font-weight: bold; color: purple;'>You sense this creature is dead.</span>\n"
		else if(stat || !client)
			msg += "<span class='xenowarning'>It doesn't seem responsive.</span>\n"
		msg += "*---------*</span>"
		user << msg
		return

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

	// crappy hacks because you can't do \his[src] etc. I'm sorry this proc is so unreadable, blame the text macros :<
	var/t_He = "It" //capitalised for use at the start of each line.
	var/t_his = "its"
	var/t_him = "it"
	var/t_has = "has"
	var/t_is = "is"

	var/msg = "<span class='info'>*---------*\nThis is "

	if( skipjumpsuit && skipface ) //big suits/masks/helmets make it hard to tell their gender
		t_He = "They"
		t_his = "their"
		t_him = "them"
		t_has = "have"
		t_is = "are"
	else
		if(icon)
			msg += "\icon[icon] " //fucking BYOND: this should stop dreamseeker crashing if we -somehow- examine somebody before their icon is generated
		switch(gender)
			if(MALE)
				t_He = "He"
				t_his = "his"
				t_him = "him"
			if(FEMALE)
				t_He = "She"
				t_his = "her"
				t_him = "her"

	msg += "<EM>[src.name]</EM>!\n"

	//uniform
	if(w_uniform && !skipjumpsuit)
		//Ties
		var/tie_msg
		if(istype(w_uniform,/obj/item/clothing/under))
			var/obj/item/clothing/under/U = w_uniform
			if(U.hastie)
				tie_msg += " with \icon[U.hastie] \a [U.hastie]"

		if(w_uniform.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_is] wearing \icon[w_uniform] [w_uniform.gender==PLURAL?"some":"a"] [(w_uniform.blood_color != "#030303") ? "blood" : "oil"]-stained [w_uniform.name][tie_msg]!</span>\n"
		else
			msg += "[t_He] [t_is] wearing \icon[w_uniform] \a [w_uniform][tie_msg].\n"

	//head
	if(head)
		if(head.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_is] wearing \icon[head] [head.gender==PLURAL?"some":"a"] [(head.blood_color != "#030303") ? "blood" : "oil"]-stained [head.name] on [t_his] head!</span>\n"
		else
			msg += "[t_He] [t_is] wearing \icon[head] \a [head] on [t_his] head.\n"

	//suit/armour
	if(wear_suit)
		if(wear_suit.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_is] wearing \icon[wear_suit] [wear_suit.gender==PLURAL?"some":"a"] [(wear_suit.blood_color != "#030303") ? "blood" : "oil"]-stained [wear_suit.name]!</span>\n"
		else
			msg += "[t_He] [t_is] wearing \icon[wear_suit] \a [wear_suit].\n"

		//suit/armour storage
		if(s_store && !skipsuitstorage)
			if(s_store.blood_DNA)
				msg += "<span class='warning'>[t_He] [t_is] carrying \icon[s_store] [s_store.gender==PLURAL?"some":"a"] [(s_store.blood_color != "#030303") ? "blood" : "oil"]-stained [s_store.name] on [t_his] [wear_suit.name]!</span>\n"
			else
				msg += "[t_He] [t_is] carrying \icon[s_store] \a [s_store] on [t_his] [wear_suit.name].\n"

	//back
	if(back)
		if(back.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_has] \icon[back] [back.gender==PLURAL?"some":"a"] [(back.blood_color != "#030303") ? "blood" : "oil"]-stained [back] on [t_his] back.</span>\n"
		else
			msg += "[t_He] [t_has] \icon[back] \a [back] on [t_his] back.\n"

	//left hand
	if(l_hand)
		if(l_hand.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_is] holding \icon[l_hand] [l_hand.gender==PLURAL?"some":"a"] [(l_hand.blood_color != "#030303") ? "blood" : "oil"]-stained [l_hand.name] in [t_his] left hand!</span>\n"
		else
			msg += "[t_He] [t_is] holding \icon[l_hand] \a [l_hand] in [t_his] left hand.\n"

	//right hand
	if(r_hand)
		if(r_hand.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_is] holding \icon[r_hand] [r_hand.gender==PLURAL?"some":"a"] [(r_hand.blood_color != "#030303") ? "blood" : "oil"]-stained [r_hand.name] in [t_his] right hand!</span>\n"
		else
			msg += "[t_He] [t_is] holding \icon[r_hand] \a [r_hand] in [t_his] right hand.\n"

	//gloves
	if(gloves && !skipgloves)
		if(gloves.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_has] \icon[gloves] [gloves.gender==PLURAL?"some":"a"] [(gloves.blood_color != "#030303") ? "blood" : "oil"]-stained [gloves.name] on [t_his] hands!</span>\n"
		else
			msg += "[t_He] [t_has] \icon[gloves] \a [gloves] on [t_his] hands.\n"
	else if(blood_DNA)
		msg += "<span class='warning'>[t_He] [t_has] [(blood_color != "#030303") ? "blood" : "oil"]-stained hands!</span>\n"

	//handcuffed?

	//handcuffed?
	if(handcuffed)
		if(istype(handcuffed, /obj/item/handcuffs/cable))
			msg += "<span class='warning'>[t_He] [t_is] \icon[handcuffed] restrained with cable!</span>\n"
		else
			msg += "<span class='warning'>[t_He] [t_is] \icon[handcuffed] handcuffed!</span>\n"

	//belt
	if(belt)
		if(belt.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_has] \icon[belt] [belt.gender==PLURAL?"some":"a"] [(belt.blood_color != "#030303") ? "blood" : "oil"]-stained [belt.name] about [t_his] waist!</span>\n"
		else
			msg += "[t_He] [t_has] \icon[belt] \a [belt] about [t_his] waist.\n"

	//shoes
	if(shoes && !skipshoes)
		if(shoes.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_is] wearing \icon[shoes] [shoes.gender==PLURAL?"some":"a"] [(shoes.blood_color != "#030303") ? "blood" : "oil"]-stained [shoes.name] on [t_his] feet!</span>\n"
		else
			msg += "[t_He] [t_is] wearing \icon[shoes] \a [shoes] on [t_his] feet.\n"
	else if(feet_blood_DNA)
		msg += "<span class='warning'>[t_He] [t_has] [(feet_blood_color != "#030303") ? "blood" : "oil"]-stained feet!</span>\n"

	//mask
	if(wear_mask && !skipmask)
		if(wear_mask.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_has] \icon[wear_mask] [wear_mask.gender==PLURAL?"some":"a"] [(wear_mask.blood_color != "#030303") ? "blood" : "oil"]-stained [wear_mask.name] on [t_his] face!</span>\n"
		else
			msg += "[t_He] [t_has] \icon[wear_mask] \a [wear_mask] on [t_his] face.\n"

	//eyes
	if(glasses && !skipeyes)
		if(glasses.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_has] \icon[glasses] [glasses.gender==PLURAL?"some":"a"] [(glasses.blood_color != "#030303") ? "blood" : "oil"]-stained [glasses] covering [t_his] eyes!</span>\n"
		else
			msg += "[t_He] [t_has] \icon[glasses] \a [glasses] covering [t_his] eyes.\n"

	//left ear
	if(wear_ear && !skipears)
		msg += "[t_He] [t_has] \icon[wear_ear] \a [wear_ear] on [t_his] ear.\n"

	//ID
	if(wear_id)
		/*var/id
		if(istype(wear_id, /obj/item/device/pda))
			var/obj/item/device/pda/pda = wear_id
			id = pda.owner
		else if(istype(wear_id, /obj/item/card/id)) //just in case something other than a PDA/ID card somehow gets in the ID slot :[
			var/obj/item/card/id/idcard = wear_id
			id = idcard.registered_name
		if(id && (id != real_name) && (get_dist(src, user) <= 1) && prob(10))
			msg += "<span class='warning'>[t_He] [t_is] wearing \icon[wear_id] \a [wear_id] yet something doesn't seem right...</span>\n"
		else*/
		msg += "[t_He] [t_is] wearing \icon[wear_id] \a [wear_id].\n"

	//Jitters
	if(is_jittery)
		if(jitteriness >= 300)
			msg += "<span class='warning'><B>[t_He] [t_is] convulsing violently!</B></span>\n"
		else if(jitteriness >= 200)
			msg += "<span class='warning'>[t_He] [t_is] extremely jittery.</span>\n"
		else if(jitteriness >= 100)
			msg += "<span class='warning'>[t_He] [t_is] twitching ever so slightly.</span>\n"

	//splints
	for(var/organ in list("l_leg","r_leg","l_arm","r_arm","l_foot","r_foot","l_hand","r_hand","chest","groin","head"))
		var/datum/limb/o = get_limb(organ)
		if(o && o.status & LIMB_SPLINTED)
			msg += "<span class='warning'>[t_He] [t_has] a splint on [t_his] [o.display_name]!</span>\n"

	if(holo_card_color)
		msg += "[t_He] has a [holo_card_color] holo card on [t_his] chest.\n"

	if(suiciding)
		msg += "<span class='warning'>[t_He] appears to have commited suicide... there is no hope of recovery.</span>\n"

	if(mSmallsize in mutations)
		msg += "[t_He] [t_is] small halfling!\n"

	var/distance = get_dist(user,src)
	if(istype(user, /mob/dead/observer) || user.stat == DEAD) // ghosts can see anything
		distance = 1
	if (stat)
		msg += "<span class='warning'>[t_He] [t_is]n't responding to anything around [t_him] and seems to be asleep.</span>\n"
		if((stat == 2 || src.health < config.health_threshold_crit) && distance <= 3)
			msg += "<span class='warning'>[t_He] does not appear to be breathing.</span>\n"
		if(ishuman(user) && !user.stat && Adjacent(user))
			user.visible_message("<b>[user]</b> checks [src]'s pulse.", "You check [src]'s pulse.", null, 4)
		spawn(15)
			if(user && src && distance <= 1 && user.stat != 1)
				if(pulse == PULSE_NONE)
					user << "<span class='deadsay'>[t_He] has no pulse[src.client ? "" : " and [t_his] soul has departed"]...</span>"
				else
					user << "<span class='deadsay'>[t_He] has a pulse!</span>"

	msg += "<span class='warning'>"

	if(nutrition < 100)
		msg += "[t_He] [t_is] severely malnourished.\n"
	else if(nutrition >= 500)
		/*if(user.nutrition < 100)
			msg += "[t_He] [t_is] plump and delicious looking - Like a fat little piggy. A tasty piggy.\n"
		else*/
		msg += "[t_He] [t_is] quite chubby.\n"

	msg += "</span>"

	if(getBrainLoss() >= 60)
		msg += "[t_He] [t_has] a stupid expression on [t_his] face.\n"

	if((!species.has_organ["brain"] || has_brain()) && stat != DEAD)
		if(!key)
			msg += "<span class='deadsay'>[t_He] [t_is] fast asleep. It doesn't look like they are waking up anytime soon.</span>\n"
		else if(!client)
			msg += "[t_He] [t_has] suddenly fallen asleep.\n"

	if(fire_stacks > 0)
		msg += "[t_He] [t_is] covered in something flammable.\n"
	if(fire_stacks < 0)
		msg += "[t_He] looks a little soaked.\n"
	if(on_fire)
		msg += "<span class='warning'>[t_He] [t_is] on fire!</span>\n"

	var/list/wound_flavor_text = list()
	var/list/is_destroyed = list()
	var/list/is_bleeding = list()
	for(var/datum/limb/temp in limbs)
		if(temp)
			if(temp.status & LIMB_DESTROYED)
				is_destroyed["[temp.display_name]"] = 1
				wound_flavor_text["[temp.display_name]"] = "<span class='warning'><b>[t_He] is missing [t_his] [temp.display_name].</b></span>\n"
				continue
			if(temp.status & LIMB_ROBOT)
				if(!(temp.brute_dam + temp.burn_dam))
					if(!(species.flags & IS_SYNTHETIC))
						wound_flavor_text["[temp.display_name]"] = "<span class='warning'>[t_He] has a robot [temp.display_name]!</span>\n"
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
			else if(temp.wounds.len > 0)
				var/list/wound_descriptors = list()
				for(var/datum/wound/W in temp.wounds)
					if(W.internal && !temp.surgery_open_stage) continue // can't see internal wounds
					var/this_wound_desc = W.desc
					if(W.damage_type == BURN && W.salved) this_wound_desc = "salved [this_wound_desc]"
					if(W.bleeding()) this_wound_desc = "bleeding [this_wound_desc]"
					else if(W.bandaged) this_wound_desc = "bandaged [this_wound_desc]"
					if(W.germ_level > 190) this_wound_desc = "badly infected [this_wound_desc]"
					else if(W.germ_level > 100) this_wound_desc = "lightly infected [this_wound_desc]"
					if(this_wound_desc in wound_descriptors)
						wound_descriptors[this_wound_desc] += W.amount
						continue
					wound_descriptors[this_wound_desc] = W.amount
				if(wound_descriptors.len)
					var/list/flavor_text = list()
					var/list/no_exclude = list("gaping wound", "big gaping wound", "massive wound", "large bruise",\
					"huge bruise", "massive bruise", "severe burn", "large burn", "deep burn", "carbonised area")
					for(var/wound in wound_descriptors)
						switch(wound_descriptors[wound])
							if(1)
								if(!flavor_text.len)
									flavor_text += "<span class='warning'>[t_He] has[prob(10) && !(wound in no_exclude)  ? " what might be" : ""] a [wound]"
								else
									flavor_text += "[prob(10) && !(wound in no_exclude) ? " what might be" : ""] a [wound]"
							if(2)
								if(!flavor_text.len)
									flavor_text += "<span class='warning'>[t_He] has[prob(10) && !(wound in no_exclude) ? " what might be" : ""] a pair of [wound]s"
								else
									flavor_text += "[prob(10) && !(wound in no_exclude) ? " what might be" : ""] a pair of [wound]s"
							if(3 to 5)
								if(!flavor_text.len)
									flavor_text += "<span class='warning'>[t_He] has several [wound]s"
								else
									flavor_text += " several [wound]s"
							if(6 to INFINITY)
								if(!flavor_text.len)
									flavor_text += "<span class='warning'>[t_He] has a bunch of [wound]s"
								else
									flavor_text += " a ton of [wound]\s"
					var/flavor_text_string = ""
					for(var/text = 1, text <= flavor_text.len, text++)
						if(text == flavor_text.len && flavor_text.len > 1)
							flavor_text_string += ", and"
						else if(flavor_text.len > 1 && text > 1)
							flavor_text_string += ","
						flavor_text_string += flavor_text[text]
					flavor_text_string += " on [t_his] [temp.display_name].</span><br>"
					wound_flavor_text["[temp.display_name]"] = flavor_text_string
				else
					wound_flavor_text["[temp.display_name]"] = ""
				if(temp.status & LIMB_BLEEDING)
					is_bleeding["[temp.display_name]"] = 1
			else
				wound_flavor_text["[temp.display_name]"] = ""

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
		msg += "<span class='warning'>[t_He] has blood dripping from [t_his] <b>face</b>!</span>\n"

	if (display_chest && display_groin && display_arm_left && display_arm_right && display_hand_left && display_hand_right && display_leg_left && display_leg_right && display_foot_left && display_foot_right)
		msg += "<span class='warning'>[t_He] has blood soaking through [t_his] clothes from [t_his] <b>entire body</b>!</span>\n"
	else
		if (display_chest && display_arm_left && display_arm_right && display_hand_left && display_hand_right)
			msg += "<span class='warning'>[t_He] has blood soaking through [t_his] clothes from [t_his] <b>upper body</b>!</span>\n"
		else
			if (display_chest)
				msg += "<span class='warning'>[t_He] has blood soaking through [t_his] <b>shirt</b>!</span>\n"
			if (display_arm_left && display_arm_right && display_hand_left && display_hand_left)
				msg += "<span class='warning'>[t_He] has blood soaking through [t_his] <b>gloves</b> and <b>sleeves</b>!</span>\n"
			else
				if (display_arm_left && display_arm_right)
					msg += "<span class='warning'>[t_He] has blood soaking through [t_his] <b>sleeves</b>!</span>\n"
				else
					if (display_arm_left)
						msg += "<span class='warning'>[t_He] has soaking through [t_his] <b>left sleeve</b>!</span>\n"
					if (display_arm_right)
						msg += "<span class='warning'>[t_He] has soaking through [t_his] <b>right sleeve</b>!</span>\n"
				if (display_hand_left && display_hand_right)
					msg += "<span class='warning'>[t_He] has blood running out from under [t_his] <b>gloves</b>!</span>\n"
				else
					if (display_hand_left)
						msg += "<span class='warning'>[t_He] has blood running out from under [t_his] <b>left glove</b>!</span>\n"
					if (display_hand_right)
						msg += "<span class='warning'>[t_He] has blood running out from under [t_his] <b>right glove</b>!</span>\n"

		if (display_groin && display_leg_left && display_leg_right && display_foot_left && display_foot_right)
			msg += "<span class='warning'>[t_He] has blood soaking through [t_his] clothes from [t_his] <b>lower body!</b></span>\n"
		else
			if (display_groin)
				msg += "<span class='warning'>[t_He] has blood dripping from [t_his] <b>groin</b>!</span>\n"
			if (display_leg_left && display_leg_right && display_foot_left && display_foot_right)
				msg += "<span class='warning'>[t_He] has blood soaking through [t_his] <b>pant legs</b> and <b>boots</b>!</span>\n"
			else
				if (display_leg_left && display_leg_right)
					msg += "<span class='warning'>[t_He] has blood soaking through [t_his] <b>pant legs</b>!</span>\n"
				else
					if (display_leg_left)
						msg += "<span class='warning'>[t_He] has blood soaking through [t_his] <b>left pant leg</b>!</span>\n"
					if (display_leg_right)
						msg += "<span class='warning'>[t_He] has blood soaking through [t_his] <b>right pant leg</b>!</span>\n"
				if (display_foot_left && display_foot_right)
					msg += "<span class='warning'>[t_He] has blood pooling around[t_his] <b>boots</b>!</span>\n"
				else
					if (display_foot_left)
						msg += "<span class='warning'>[t_He] has blood pooling around [t_his] <b>left boot</b>!</span>\n"
					if (display_foot_right)
						msg += "<span class='warning'>[t_He] has blood pooling around [t_his] <b>right boot</b>!</span>\n"

	if(chestburst == 2)
		msg += "<span class='warning'><b>[t_He] has a giant hole in [t_his] chest!</b></span>\n"

	for(var/implant in get_visible_implants(0))
		msg += "<span class='warning'><b>[t_He] has \a [implant] sticking out of [t_his] flesh!</span>\n"
	if(digitalcamo)
		msg += "[t_He] [t_is] repulsively uncanny!\n"


	if(hasHUD(user,"security"))
		var/perpname = "wot"
		var/criminal = "None"

		if(wear_id)
			var/obj/item/card/id/I = wear_id.GetID()
			if(I)
				perpname = I.registered_name
			else
				perpname = name
		else
			perpname = name

		if(perpname)
			for (var/datum/data/record/E in data_core.general)
				if(E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.security)
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
			else if(istype(wear_id,/obj/item/device/pda))
				var/obj/item/device/pda/tempPda = wear_id
				perpname = tempPda.owner
		else
			perpname = src.name

		for (var/datum/data/record/E in data_core.general)
			if (E.fields["name"] == perpname)
				for (var/datum/data/record/R in data_core.general)
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
		for(var/datum/data/record/R in data_core.medical)
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


	if(print_flavor_text()) msg += "[print_flavor_text()]\n"

	msg += "*---------*</span>"
	if (pose)
		if( findtext(pose,".",lentext(pose)) == 0 && findtext(pose,"!",lentext(pose)) == 0 && findtext(pose,"?",lentext(pose)) == 0 )
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		msg += "\n[t_He] is [pose]"

	user << msg

//Helper procedure. Called by /mob/living/carbon/human/examine() and /mob/living/carbon/human/Topic() to determine HUD access to security and medical records.
/proc/hasHUD(mob/M, hudtype)
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		switch(hudtype)
			if("security")
				//only MPs can use the security HUD glasses's functionalities
				if(H.mind && (!H.mind.cm_skills || H.mind.cm_skills.police >= SKILL_POLICE_MP))
					return istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(H.glasses, /obj/item/clothing/glasses/sunglasses/sechud)
			if("medical")
				if(H.mind && H.mind.cm_skills && H.mind.cm_skills.medical >= SKILL_MEDICAL_MEDIC)
					return istype(H.glasses, /obj/item/clothing/glasses/hud/health)
			if("squadleader")
				return H.mind && H.assigned_squad && H.assigned_squad.squad_leader == H && istype(H.wear_ear, /obj/item/device/radio/headset/almayer/marine)
			else
				return 0
	else if(istype(M, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = M
		switch(hudtype)
			if("security")
				return istype(R.module_state_1, /obj/item/robot/sight/hud/sec) || istype(R.module_state_2, /obj/item/robot/sight/hud/sec) || istype(R.module_state_3, /obj/item/robot/sight/hud/sec)
			if("medical")
				return istype(R.module_state_1, /obj/item/robot/sight/hud/med) || istype(R.module_state_2, /obj/item/robot/sight/hud/med) || istype(R.module_state_3, /obj/item/robot/sight/hud/med)
			else
				return 0
	else
		return 0
