/obj/effect/proc_holder/spell/invoked/shepherd
	name = "Shepherd"
	range = 8
	overlay_state = "psy"
	releasedrain = 50
	chargedrain = 0
	chargetime = 0
	charge_max = 10 SECONDS
	sound = 'sound/magic/swap.ogg'
	associated_skill = /datum/skill/magic/holy
	warnie = "sydwarning"
	movement_interrupt = FALSE
	chargedloop = /datum/looping_sound/invokeholy
	miracle = TRUE
	devotion_cost = -30

/obj/effect/proc_holder/spell/invoked/shepherd/cast(list/targets, mob/living/user)
	..()
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		if(target == user)
			return FALSE
		if(get_dist(user, target) > 7)
			return FALSE
		var/turf/T = get_turf(target)
		var/turf/H = get_turf(user)
		if(T && H)
			playsound(T, 'sound/magic/swap.ogg', 100)
			user.forceMove(T)
			target.forceMove(H)
			return TRUE
	return FALSE

// Cleric Spell Spawner
/datum/devotion/cleric_holder/proc/grant_spells_priest(mob/living/carbon/human/H)
	var/datum/patrongods/A = H.PATRON
	var/spelllist = list(A.t0, A.t1, A.t2, A.t3)
	for(var/C in spelllist)
		H.mind.AddSpell(new C)
	level = CLERIC_T3
	update_devotion(300, 900)

/datum/devotion/cleric_holder/proc/grant_spells(mob/living/carbon/human/H)
	var/datum/patrongods/A = H.PATRON
	var/spelllist = list(A.t0, A.t1)
	level = CLERIC_T1
	for(var/C in spelllist)
		H.mind.AddSpell(new C) 

// General
/obj/effect/proc_holder/spell/invoked/heal/lesser
	name = "Lesser Miracle"
	overlay_state = "lesserheal"
	releasedrain = 30
	chargedrain = 0
	chargetime = 0
	range = 15
	warnie = "sydwarning"
	movement_interrupt = FALSE
	sound = 'sound/magic/heal.ogg'
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	charge_max = 10 SECONDS
	devotion_cost = -25

/obj/effect/proc_holder/spell/invoked/heal/lesser/cast(list/targets, mob/living/user)
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		if(target == user)
			return FALSE
		if(get_dist(user, target) > 7)
			return FALSE
		if(target.mob_biotypes & MOB_UNDEAD) //positive energy harms the undead
			target.visible_message("<span class='danger'>[target] is burned by holy light!</span>", "<span class='userdanger'>I'm burned by holy light!</span>")
			target.adjustFireLoss(50)
			target.Paralyze(30)
			target.fire_act(1,5)
			return TRUE
		target.visible_message("<span class='info'>A wreath of gentle light passes over [target]!</span>", "<span class='notice'>I'm bathed in holy light!</span>")
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(user.zone_selected))
			if(affecting)
				if(affecting.heal_damage(20, 20, 0, null, FALSE))
					C.update_damage_overlays()
				if(affecting.heal_wounds(50))
					C.update_damage_overlays()
		else
			target.adjustBruteLoss(-5)
			target.adjustFireLoss(-5)
		target.adjustToxLoss(-5)
		target.adjustOxyLoss(-5)
		target.blood_volume += 25
		return TRUE
	else
		return FALSE

// Light
/obj/effect/proc_holder/spell/invoked/heal
	name = "Miracle"
	overlay_state = "astrata"
	releasedrain = 30
	chargedrain = 0
	chargetime = 0
	range = 15
	warnie = "sydwarning"
	movement_interrupt = FALSE
//	chargedloop = /datum/looping_sound/invokeholy
	chargedloop = null
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	sound = 'sound/magic/heal.ogg'
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	charge_max = 5 SECONDS
	miracle = TRUE
	devotion_cost = -45

/obj/effect/proc_holder/spell/invoked/heal/cast(list/targets, mob/living/user)
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		if(target == user)
			return FALSE
		if(get_dist(user, target) > 7)
			return FALSE
		if(target.mob_biotypes & MOB_UNDEAD) //positive energy harms the undead
			target.visible_message("<span class='danger'>[target] is burned by holy light!</span>", "<span class='userdanger'>I'm burned by holy light!</span>")
			target.adjustFireLoss(100)
			target.Paralyze(50)
			target.fire_act(1,5)
			return TRUE
		target.visible_message("<span class='info'>A wreath of gentle light passes over [target]!</span>", "<span class='notice'>I'm bathed in holy light!</span>")
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(user.zone_selected))
			if(affecting)
				if(affecting.heal_damage(50, 50, 0, null, FALSE))
					C.update_damage_overlays()
				if(affecting.heal_wounds(50))
					C.update_damage_overlays()
		else
			target.adjustBruteLoss(-50)
			target.adjustFireLoss(-50)
		target.adjustToxLoss(-50)
		target.adjustOxyLoss(-50)
		target.blood_volume += 100
		return TRUE
	else
		return FALSE

/obj/effect/proc_holder/spell/targeted/sacred_flame_rogue
	name = "Sacred Flame"
	overlay_state = "sacredflame"
	releasedrain = 30
	chargedrain = 0
	chargetime = 0
	range = 15
	warnie = "sydwarning"
	movement_interrupt = FALSE
	chargedloop = null
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	sound = 'sound/magic/heal.ogg'
	invocation = "The Sun cleanses!"
	invocation_type = "shout"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	charge_max = 5 SECONDS
	miracle = TRUE
	devotion_cost = -45
	include_user = 0
	max_targets = 1

/obj/effect/proc_holder/spell/targeted/sacred_flame_rogue/cast(list/targets, mob/user = usr)
	for(var/mob/living/L in targets)
		user.visible_message("<font color='yellow'>[user] points at [L]/</font>")
		if(L.anti_magic_check(TRUE, TRUE))
			continue
		L.adjust_fire_stacks(5)
		L.IgniteMob()
		sleep(40)
		L.ExtinguishMob()

/obj/effect/proc_holder/spell/invoked/revive
	name = "Anastasis"
	overlay_state = "revive"
	releasedrain = 90
	chargedrain = 0
	chargetime = 50
	range = 1
	warnie = "sydwarning"
	no_early_release = TRUE
	movement_interrupt = TRUE
	chargedloop = /datum/looping_sound/invokeholy
	sound = 'sound/magic/revive.ogg'
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	charge_max = 1 MINUTES
	miracle = TRUE
	devotion_cost = -100

/obj/effect/proc_holder/spell/invoked/revive/cast(list/targets, mob/living/user)
	..()
	if(isliving(targets[1]))
		testing("revived1")
		var/mob/living/target = targets[1]
		if(target == user)
			return FALSE
		if(!user.Adjacent(target))
			return FALSE
		if(GLOB.tod == "night")
			to_chat(user, "<span class='warning'>Let there be light.</span>")
		for(var/obj/structure/fluff/psycross/S in oview(5, user))
			S.AOE_flash(user, range = 8)
		if(target.mob_biotypes & MOB_UNDEAD) //positive energy harms the undead
			target.visible_message("<span class='danger'>[target] is unmade by holy light!</span>", "<span class='userdanger'>I'm unmade by holy light!</span>")
			target.gib()
		else
			if(target.stat == DEAD)
				if(target.revive(full_heal = FALSE))
					testing("revived2")
					target.grab_ghost(force = TRUE) // even suicides
					target.emote("breathgasp")
					target.Jitter(100)
					to_chat(target, "<span class='notice'>I awake from the void.</span>")
					return TRUE
			target.visible_message("<span class='warning'>Nothing happens.</span>")
			return FALSE
		return TRUE
	else
		return FALSE

/obj/effect/proc_holder/spell/invoked/revive/cast_check(skipcharge = 0,mob/user = usr)
	if(!..())
		return FALSE
	var/found = null
	for(var/obj/structure/fluff/psycross/S in oview(5, user))
		found = S
	if(!found)
		to_chat(user, "<span class='warning'>I need a holy cross.</span>")
		return FALSE
	else
		return TRUE


// Necrite
/obj/effect/proc_holder/spell/targeted/burialrite
	name = "Burial Rites"
	range = 5
	overlay_state = "consecrateburial"
	releasedrain = 30
	charge_max = 300
	max_targets = 0
	cast_without_targets = TRUE
	sound = 'sound/magic/churn.ogg'
	associated_skill = /datum/skill/magic/holy
	invocation = "Undermaiden grant thee passage forth and spare the trials of the forgotten."
	invocation_type = "whisper" //can be none, whisper, emote and shout
	miracle = TRUE
	devotion_cost = -15

/obj/effect/proc_holder/spell/targeted/burialrite/cast(list/targets,mob/user = usr)
	for(var/obj/structure/closet/dirthole/H in view(1))
		if(H.stage != 4)
			continue
		if(!H.contents)
			continue
		for(var/mob/living/carbon/human/A in H.contents)
			A.funeral = TRUE
			if(A.mind && A.mind.has_antag_datum(/datum/antagonist/zombie))
				A.mind.remove_antag_datum(/datum/antagonist/zombie)
			user.visible_message("My funeral rites have been performed!", "[user] consecrates the grave!")
		for(var/obj/structure/closet/crate/coffin/C)
			for(var/mob/living/carbon/human/B in C.contents)
				B.funeral = TRUE

/obj/effect/proc_holder/spell/targeted/churn
	name = "Churn Undead"
	range = 8
	overlay_state = "necra"
	releasedrain = 30
	charge_max = 300
	max_targets = 0
	cast_without_targets = TRUE
	sound = 'sound/magic/churn.ogg'
	associated_skill = /datum/skill/magic/holy
	invocation = "The Undermaiden rubukes!"
	invocation_type = "shout" //can be none, whisper, emote and shout
	miracle = TRUE
	devotion_cost = -60

/obj/effect/proc_holder/spell/targeted/churn/cast(list/targets,mob/living/user = usr)
	var/prob2explode = 100
	if(user && user.mind)
		prob2explode = 0
		for(var/i in 1 to user.mind.get_skill_level(/datum/skill/magic/holy))
			prob2explode += 30
	for(var/mob/living/L in targets)
		var/isvampire = FALSE
		var/iszombie = FALSE
		if(L.stat == DEAD)
			continue
		if(L.mind)
			var/datum/antagonist/vampirelord/lesser/V = L.mind.has_antag_datum(/datum/antagonist/vampirelord/lesser)
			if(V)
				if(!V.disguised)
					isvampire = TRUE
			if(L.mind.has_antag_datum(/datum/antagonist/zombie))
				iszombie = TRUE
			if(L.mind.special_role == "Vampire Lord")
				user.visible_message("<span class='warning'>[L] overpowers being churned!</span>", "<span class='userdanger'>[L] is too strong, I am churned!</span>")
				user.Stun(50)
				user.throw_at(get_ranged_target_turf(user, get_dir(user,L), 7), 7, 1, L, spin = FALSE)
				return
		if((L.mob_biotypes & MOB_UNDEAD) || isvampire || iszombie)
//			L.visible_message("<span class='warning'>[L] is unmade by PSYDON!</span>", "<span class='danger'>I'm unmade by PSYDON!</span>")
			var/vamp_prob = prob2explode
			if(isvampire)
				vamp_prob -= 59
			if(prob(vamp_prob))
				explosion(get_turf(L), light_impact_range = 1, flame_range = 1, smoke = FALSE)
				L.Stun(50)
//				L.throw_at(get_ranged_target_turf(L, get_dir(user,L), 7), 7, 1, L, spin = FALSE)
			else
				L.visible_message("<span class='warning'>[L] resists being churned!</span>", "<span class='userdanger'>I resist being churned!</span>")
	..()
	return TRUE

/obj/effect/proc_holder/spell/targeted/soulspeak
	name = "Speak with Soul"
	range = 5
	overlay_state = "speakwithdead"
	releasedrain = 30
	charge_max = 300
	max_targets = 0
	cast_without_targets = TRUE
	sound = 'sound/magic/churn.ogg'
	associated_skill = /datum/skill/magic/holy
	invocation = "She-Below brooks thee respite, be heard, wanderer."
	invocation_type = "whisper" //can be none, whisper, emote and shout
	miracle = TRUE
	devotion_cost = -100

/obj/effect/proc_holder/spell/targeted/soulspeak/cast(list/targets,mob/user = usr)
	var/mob/living/carbon/spirit/capturedsoul = null
	var/list/souloptions = list()
	var/list/itemstorestore = list()
	for(var/mob/living/carbon/spirit/S in world)
		souloptions += S.livingname
	var/pickedsoul = input(user, "Which soul should I commune with?", "Available Souls") as null|anything in souloptions
	if(!pickedsoul)
		return
	for(var/mob/living/carbon/spirit/P in world)
		if(P.livingname == pickedsoul)
			to_chat(P, "You feel yourself being pulled out of the underworld.")
			sleep(20)
			P.loc = user.loc
			capturedsoul = P
			P.invisibility = INVISIBILITY_OBSERVER
			user.grant_language(/datum/language_holder/abyssal)
			for(var/obj/item/I in P.held_items) // this is big ass, will revisit later
				. |= P.dropItemToGround(I)
				if(istype(I, /obj/item/underworld/coin))
					itemstorestore |= "token"
				if(istype(I, /obj/item/flashlight/lantern/shrunken))
					itemstorestore |= "lamp"
				qdel(I)
			break
		to_chat(P, "[itemstorestore]")
	if(capturedsoul)
		spawn(1200)
			to_chat(user, "The soul returns to the underworld.")
			to_chat(capturedsoul, "You feel yourself being pulled back to the underworld.")
			for(var/obj/effect/landmark/underworld/A in world)
				capturedsoul.loc = A.loc
				capturedsoul.invisibility = initial(capturedsoul.invisibility)
				for(var/I in itemstorestore)
					if(I == "token")
						var/obj/item/underworld/coin/C = new
						capturedsoul.put_in_hands(C)
					if(I == "lamp")
						var/obj/item/flashlight/lantern/shrunken/L = new
						capturedsoul.put_in_hands(L)
			user.remove_language(/datum/language_holder/abyssal)
		to_chat(user, "<font color='blue'>I feel a cold chill run down my spine, a presence has arrived.</font>")	
		capturedsoul.Paralyze(1200)
	else return


// Druid

/obj/effect/proc_holder/spell/targeted/blesscrop
	name = "Bless Crops"
	range = 5
	overlay_state = "blesscrop"
	releasedrain = 30
	charge_max = 300
	max_targets = 0
	cast_without_targets = TRUE
	sound = 'sound/magic/churn.ogg'
	associated_skill = /datum/skill/magic/holy
	invocation = "The Treefather commands thee, be fruitful!"
	invocation_type = "shout" //can be none, whisper, emote and shout
	miracle = TRUE
	devotion_cost = -15

/obj/effect/proc_holder/spell/targeted/blesscrop/cast(list/targets,mob/user = usr)
	visible_message("<FONT COLOR='green'>[usr] blesses the crop with Dendor's Favour!</FONT><BR>")
	for(var/obj/machinery/crop/C in view(5))
		C.growth += 40
		C.update_seed_icon()

/obj/effect/proc_holder/spell/targeted/beasttame
	name = "Tame Beast"
	range = 5
	overlay_state = "tamebeast"
	releasedrain = 30
	charge_max = 300
	max_targets = 0
	cast_without_targets = TRUE
	sound = 'sound/magic/churn.ogg'
	associated_skill = /datum/skill/magic/holy
	invocation = "Be still and calm, brotherbeast."
	invocation_type = "whisper" //can be none, whisper, emote and shout
	miracle = TRUE
	devotion_cost = -60

/obj/effect/proc_holder/spell/targeted/beasttame/cast(list/targets,mob/user = usr)
	visible_message("<FONT COLOR='green'>[usr] soothes the beastblood with Dendor's whisper.</FONT><BR>")
	for(var/mob/living/simple_animal/hostile/retaliate/B in oview(2))
		B.aggressive = 0
