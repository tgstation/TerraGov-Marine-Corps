
/mob/living
	var/list/simple_wounds = list()

//living wound: adds limbs to above list
/mob/living/proc/add_wound(datum/wound/W, skipcheck)
	if(!W || !HAS_TRAIT(src, TRAIT_SIMPLE_WOUNDS))
		return
/*	for(var/datum/wound/D in simple_wounds)
		if(istype(D,W) || D.smaller_wound == W)
			if(prob(10) && D.bigger_wound) //small chance to 'upgrade' the existing wound instead of making a new one
				W = D.bigger_wound
				simple_wounds -= D
				qdel(D)
				skipcheck = TRUE
				next_attack_msg += " <span class='warning'>The wound gushes with blood!</span>"
				break*/
//	if((simple_wounds.len < 13) || !skipcheck)
	var/datum/wound/NW = new W(src)
	simple_wounds += NW

/mob/living/proc/has_wound(path)
	if(!path)
		return
	for(var/datum/wound/W in simple_wounds)
		if(istype(W,path))
			return W

/mob/living/proc/heal_wounds(amt) //wounds that are large always have large hp, but they can be sewn to bleed less/be healed
	for(var/datum/wound/W in simple_wounds)
		W.whp = W.whp - amt
		if(W.whp <= 0)
			simple_wounds -= W
			qdel(W)

//carbon wound: adds wounds to the bodyparts
//accepts lists (checks list of targets in order) ex: stepping on glass with 1 leg vs crawling across
/mob/living/carbon/add_wound(datum/wound/W, limb, skipcheck)
	if(!W)
		return
	if(!limb)
		limb = BODY_ZONE_CHEST
	var/obj/item/bodypart/affecting
	if(islist(limb))
		var/temp
		for(var/X in limb)
			temp = check_zone(limb)
			affecting = get_bodypart(temp)
			if(affecting)
				break
	else
		limb = check_zone(limb)
		affecting = get_bodypart(limb)
	if(affecting)
		affecting.add_wound(W, skipcheck)

/mob/living/proc/woundcritroll(bclass, dam, mob/living/user, zone_precise)
	if(!bclass)
		return FALSE
	if(user)
		if(user.goodluck(2))
			dam += 10
		if(!istype(user.rmb_intent, /datum/rmb_intent/weak))
			if(try_crit(bclass, dam, user, zone_precise))
				return TRUE
	else
		if(try_crit(bclass, dam, user, zone_precise))
			return TRUE
	switch(bclass) //do stuff but only when we are a blade that adds wounds
		if(BCLASS_CHOP || BCLASS_CUT)
			switch(dam)
				if(1 to 5)
					add_wound(/datum/wound/cut/small)
				if(6 to 15)
					add_wound(/datum/wound/cut)
				if(16 to INFINITY)
					add_wound(/datum/wound/cut/large)
		if(BCLASS_SMASH || BCLASS_BLUNT)
			switch(dam)
				if(1 to 5)
					add_wound(/datum/wound/bruise/small)
				if(6 to 15)
					add_wound(/datum/wound/bruise)
				if(16 to INFINITY)
					add_wound(/datum/wound/bruise/large)
		if(BCLASS_STAB || BCLASS_PICK)
			switch(dam)
				if(1 to 5)
					add_wound(/datum/wound/stab/small)
				if(6 to 15)
					add_wound(/datum/wound/stab)
				if(16 to INFINITY)
					add_wound(/datum/wound/stab/large)
		if(BCLASS_BITE)
			if(dam > 8)
				add_wound(/datum/wound/bite/bleeding)
			else
				add_wound(/datum/wound/bite)

/mob/living/proc/try_crit(bclass,dam,mob/living/user,zone_precise)
	if(!dam)
		return
	if(zone_precise == "head")
		if(bclass == BCLASS_BLUNT || bclass == BCLASS_SMASH || bclass == BCLASS_PICK)
			var/used = round((health / maxHealth)*20 + (dam / 3), 1)
			if(user)
				if(istype(user.rmb_intent, /datum/rmb_intent/strong))
					used += 10
			if(prob(used))
				for(var/datum/wound/fracture/W in simple_wounds)
					return FALSE
				var/list/phrases = list("The skull shatters in a gruesome way!", "The head is smashed!", "The skull is broken!", "The skull caves in!")
				src.next_attack_msg += " <span class='crit'><b>Critical hit!</b> [pick(phrases)]</span>"
				add_wound(/datum/wound/fracture)
				if(prob(3))
					playsound(src, 'sound/combat/tf2crit.ogg', 100, FALSE)
				playsound(src, "headcrush", 100, FALSE)
				death()
				return FALSE
	if(bclass == BCLASS_STAB || bclass == BCLASS_PICK || bclass == BCLASS_CUT || bclass == BCLASS_CHOP || bclass == BCLASS_BITE)
		if(bclass == BCLASS_CHOP || bclass == BCLASS_PICK)
			if(user)
				if(istype(user.rmb_intent, /datum/rmb_intent/strong))
					dam += 30
		else
			if(user)
				if(istype(user.rmb_intent, /datum/rmb_intent/aimed))
					dam += 30
		if(prob(round(max(dam / 3, 1), 1)))
			for(var/datum/wound/artery/A in simple_wounds)
//				if(bclass == BCLASS_STAB || bclass == BCLASS_PICK)
//					death()
//					return TRUE
				return FALSE
			if(prob(3))
				playsound(src, 'sound/combat/tf2crit.ogg', 100, FALSE)
			else
				playsound(src, pick('sound/combat/crit.ogg'), 100, FALSE)
			src.emote("death", forced =TRUE)
			src.next_attack_msg += " <span class='crit'><b>Critical hit!</b> Blood sprays from [src]!</span>"
			add_wound(/datum/wound/artery)
//			if(bclass == BCLASS_STAB || bclass == BCLASS_PICK)
//				death()
//				return TRUE

/datum/wound
	var/name = "wound"
	var/bleed_rate = 0.2
	var/can_sew = TRUE
	var/time = 3
	var/whp = 60
	var/obj/item/bodypart/master_bodypart
	var/woundpain = 0
	var/mob_overlay = "w1"
	var/sewn_overlay = ""
	var/bigger_wound
	var/smaller_wound
	var/progress
	var/passive_heal = FALSE


/datum/wound/proc/sewn()
	bleed_rate = 0.01
	woundpain = max(woundpain-10, 0)
	can_sew = FALSE
	return

/datum/wound/cut
	name = "cut"
	bleed_rate = 0.4
	can_sew = TRUE
	whp = 50
	woundpain = 0
	mob_overlay = "cut"

/datum/wound/cut/small
	name = "small cut"
	bleed_rate = 0.2

/datum/wound/cut/large
	name = "gruesome cut"
	bleed_rate = 1

/datum/wound/bruise
	name = "hematoma"
	bleed_rate = 0
	can_sew = FALSE
	whp = 40
	woundpain = 10

/datum/wound/bruise/small
	name = "bruise"
	bleed_rate = 0
	woundpain = 5

/datum/wound/bruise/large
	name = "massive hematoma"
	bleed_rate = 1
	woundpain = 25

/datum/wound/artery
	name = "severed blood tunnel"
	bleed_rate = 30
	can_sew = TRUE
	whp = 100
	woundpain = 100
	mob_overlay = "s1"
	time = 10

/datum/wound/artery/throat
	name = "sliced throat"
	mob_overlay = "s1_throat"
	bleed_rate = 50

/datum/wound/stab
	name = "puncture wound"
	bleed_rate = 0.4
	can_sew = TRUE
	whp = 50
	woundpain = 0
	mob_overlay = "cut"

/datum/wound/stab/small
	name = "small puncture wound"
	bleed_rate = 0.2

/datum/wound/stab/large
	name = "gaping wound"
	bleed_rate = 1

/datum/wound/dismemberment
	name = "bleeding stump"
	bleed_rate = 50
	can_sew = TRUE
	whp = 100
	woundpain = 100
	time = 10
	mob_overlay = "dis_head"

/datum/wound/dismemberment/r_arm
	mob_overlay = "dis_ra"
/datum/wound/dismemberment/l_arm
	mob_overlay = "dis_la"
/datum/wound/dismemberment/r_leg
	mob_overlay = "dis_rl"
/datum/wound/dismemberment/l_leg
	mob_overlay = "dis_ll"

/datum/wound/arrow
	name = "arrow wound"
	bleed_rate = 1
	can_sew = TRUE
	whp = 30
	woundpain = 30

/datum/wound/fracture
	name = "fracture"
	bleed_rate = 0
	can_sew = TRUE
	whp = 40
	woundpain = 100
	mob_overlay = "frac"

/datum/wound/necksnap
	name = "broken neck"
	bleed_rate = 0
	can_sew = 0
	whp = 60
	woundpain = 100

/datum/wound/bite
	name = "bite mark"
	bleed_rate = 0
	can_sew = 0
	whp = 8
	woundpain = 1
	passive_heal = TRUE

/datum/wound/bite/bleeding
	name = "bleeding bite mark"
	bleed_rate = 0.2
	can_sew = 1
	whp = 30
	woundpain = 5
	passive_heal = FALSE
