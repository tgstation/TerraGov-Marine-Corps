/*
* Data HUDs have been rewritten in a more generic way.
* In short, they now use an observer-listener pattern.
* See code/datum/hud.dm for the generic hud datum.
* Update the HUD icons when needed with the appropriate hook. (see below)
*/

/* DATA HUD DATUMS */

/atom/proc/add_to_all_mob_huds()
	return

/mob/living/carbon/human/add_to_all_mob_huds()
	for(var/h in GLOB.huds)
		if(istype(h, /datum/atom_hud/xeno)) //this one is xeno only
			continue
		var/datum/atom_hud/hud = h
		hud.add_to_hud(src)

/mob/living/carbon/xenomorph/add_to_all_mob_huds()
	for(var/h in GLOB.huds)
		if(!istype(h, /datum/atom_hud/xeno))
			continue
		var/datum/atom_hud/hud = h
		hud.add_to_hud(src)

/atom/proc/remove_from_all_mob_huds()
	return

/mob/living/carbon/human/remove_from_all_mob_huds()
	for(var/h in GLOB.huds)
		if(istype(h, /datum/atom_hud/xeno))
			continue
		var/datum/atom_hud/hud = h
		hud.remove_from_hud(src)

/mob/living/carbon/xenomorph/remove_from_all_mob_huds()
	for(var/h in GLOB.huds)
		if(!istype(h, /datum/atom_hud/xeno))
			continue
		var/datum/atom_hud/hud = h
		hud.remove_from_hud(src)

/datum/atom_hud/simple //Naked-eye observable statuses.
	hud_icons = list(STATUS_HUD_SIMPLE)

/datum/atom_hud/medical
	hud_icons = list(HEALTH_HUD, STATUS_HUD)

//med hud used by silicons, only shows humans with a uniform with sensor mode activated.
/datum/atom_hud/medical/basic

/datum/atom_hud/medical/basic/proc/check_sensors(mob/living/carbon/human/H)
	if(!istype(H))
		return FALSE
	var/obj/item/clothing/under/U = H.w_uniform
	if(!istype(U))
		return FALSE
	if(U.sensor_mode <= 2)
		return FALSE
	return TRUE

/datum/atom_hud/medical/basic/add_to_single_hud(mob/user, mob/target)
	if(check_sensors(user))
		return ..()

/datum/atom_hud/medical/basic/proc/update_suit_sensors(mob/living/carbon/human/H)
	if(check_sensors(H))
		add_to_hud(H)
	else
		remove_from_hud(H)

/mob/living/carbon/human/proc/update_suit_sensors()
	var/datum/atom_hud/medical/basic/B = GLOB.huds[DATA_HUD_MEDICAL_BASIC]
	B.update_suit_sensors(src)

//med hud used by medical hud glasses
/datum/atom_hud/medical/advanced

//HUD used by the synth, separate typepath so it's not accidentally removed.
/datum/atom_hud/medical/advanced/synthetic

//medical hud used by ghosts
/datum/atom_hud/medical/observer
	hud_icons = list(HEALTH_HUD, XENO_EMBRYO_HUD, XENO_REAGENT_HUD, XENO_DEBUFF_HUD, STATUS_HUD, MACHINE_HEALTH_HUD, MACHINE_AMMO_HUD)

/datum/atom_hud/medical/pain
	hud_icons = list(PAIN_HUD)

/mob/proc/med_hud_set_health()
	return

/mob/living/carbon/xenomorph/med_hud_set_health()
	if(hud_used?.healths)
		var/bucket
		if(stat == DEAD)
			bucket = "critical"
		else
			bucket = get_bucket(XENO_HUD_ICON_BUCKETS, maxHealth, health, get_crit_threshold(), list("full", "critical"))
		hud_used.healths.icon_state = "health[bucket]"

	var/image/holder = hud_list[HEALTH_HUD_XENO]
	if(!holder)
		return
	if(stat == DEAD)
		holder.icon = 'icons/mob/hud/xeno_health.dmi'
		holder.icon_state = "health0"
		return

	var/amount = health > 0 ? round(health * 100 / maxHealth, 10) : CEILING(health, 10)
	if(!amount && health < 0)
		amount = -1 //don't want the 'zero health' icon when we are crit
	holder.icon = 'icons/mob/hud/xeno_health.dmi'
	holder.icon_state = "health[amount]"

/mob/living/carbon/human/med_hud_set_health()
	var/image/holder = hud_list[HEALTH_HUD]
	if(stat == DEAD)
		holder.icon = 'icons/mob/hud/human_health.dmi'
		holder.icon_state = "health-100"
		return

	holder.icon = 'icons/mob/hud/human_health.dmi'
	var/percentage = round(health * 100 / maxHealth)
	switch(percentage)
		if(100 to INFINITY)
			holder.icon_state = "health100"
		if(90 to 99)
			holder.icon_state = "health90"
		if(80 to 89)
			holder.icon_state = "health80"
		if(70 to 79)
			holder.icon_state = "health70"
		if(60 to 69)
			holder.icon_state = "health60"
		if(50 to 59)
			holder.icon_state = "health50"
		if(45 to 49)
			holder.icon_state = "health45"
		if(40 to 44)
			holder.icon_state = "health40"
		if(35 to 39)
			holder.icon_state = "health35"
		if(30 to 34)
			holder.icon_state = "health30"
		if(25 to 29)
			holder.icon_state = "health25"
		if(20 to 24)
			holder.icon_state = "health20"
		if(15 to 19)
			holder.icon_state = "health15"
		if(10 to 14)
			holder.icon_state = "health10"
		if(5 to 9)
			holder.icon_state = "health5"
		if(0 to 4)
			holder.icon_state = "health0"
		if(-49 to -1)
			holder.icon_state = "health-0"
		if(-99 to -50)
			holder.icon_state = "health-50"
		else
			holder.icon_state = "health-100"

/mob/proc/med_hud_set_status() //called when mob stat changes, or get a virus/xeno host, etc
	return

/mob/living/carbon/xenomorph/med_hud_set_status()
	hud_set_pheromone()

/mob/living/carbon/human/med_hud_set_status()
	var/image/status_hud = hud_list[STATUS_HUD] //Status for med-hud.
	var/image/infection_hud = hud_list[XENO_EMBRYO_HUD] //State of the xeno embryo.
	var/image/simple_status_hud = hud_list[STATUS_HUD_SIMPLE] //Status for the naked eye.
	var/image/xeno_reagent = hud_list[XENO_REAGENT_HUD] // Displays active xeno reagents
	var/image/xeno_debuff = hud_list[XENO_DEBUFF_HUD] //Displays active xeno specific debuffs
	var/static/image/neurotox_image = image('icons/mob/hud/human.dmi', icon_state = "neurotoxin")
	var/static/image/hemodile_image = image('icons/mob/hud/human.dmi', icon_state = "hemodile")
	var/static/image/transvitox_image = image('icons/mob/hud/human.dmi', icon_state = "transvitox")
	var/static/image/sanguinal_image = image('icons/mob/hud/human.dmi', icon_state = "sanguinal")
	var/static/image/ozelomelyn_image = image('icons/mob/hud/human.dmi', icon_state = "ozelomelyn")
	var/static/image/neurotox_high_image = image('icons/mob/hud/human.dmi', icon_state = "neurotoxin_high")
	var/static/image/hemodile_high_image = image('icons/mob/hud/human.dmi', icon_state = "hemodile_high")
	var/static/image/transvitox_high_image = image('icons/mob/hud/human.dmi', icon_state = "transvitox_high")
	var/static/image/sanguinal_high_image = image('icons/mob/hud/human.dmi', icon_state = "sanguinal_high")
	var/static/image/intoxicated_image = image('icons/mob/hud/intoxicated.dmi', icon_state = "intoxicated")
	var/static/image/intoxicated_amount_image = image('icons/mob/hud/intoxicated.dmi', icon_state = "intoxicated_amount0")
	var/static/image/intoxicated_high_image = image('icons/mob/hud/intoxicated.dmi', icon_state = "intoxicated_high")
	var/static/image/hunter_silence_image = image('icons/mob/hud/human.dmi', icon_state = "silence_debuff")
	var/static/image/dancer_marked_image = image('icons/mob/hud/human.dmi', icon_state = "marked_debuff")
	var/static/image/lifedrain = image('icons/mob/hud/human.dmi', icon_state = "lifedrain")
	var/static/image/hive_target_image = image('icons/mob/hud/human.dmi', icon_state = "hive_target")

	xeno_reagent.overlays.Cut()
	xeno_reagent.icon_state = ""
	if(stat != DEAD)
		var/neurotox_amount = reagents.get_reagent_amount(/datum/reagent/toxin/xeno_neurotoxin)
		var/hemodile_amount = reagents.get_reagent_amount(/datum/reagent/toxin/xeno_hemodile)
		var/transvitox_amount = reagents.get_reagent_amount(/datum/reagent/toxin/xeno_transvitox)
		var/sanguinal_amount = reagents.get_reagent_amount(/datum/reagent/toxin/xeno_sanguinal)
		var/ozelomelyn_amount = reagents.get_reagent_amount(/datum/reagent/toxin/xeno_ozelomelyn)

		if(neurotox_amount > 10) //Blinking image for particularly high concentrations
			xeno_reagent.overlays += neurotox_high_image
		else if(neurotox_amount > 0)
			xeno_reagent.overlays += neurotox_image

		if(ozelomelyn_amount > 0) // Has no effect beyond having it in them, don't need to have a high image.
			xeno_reagent.overlays += ozelomelyn_image

		if(hemodile_amount > 10)
			xeno_reagent.overlays += hemodile_high_image
		else if(hemodile_amount > 0)
			xeno_reagent.overlays += hemodile_image

		if(transvitox_amount > 10)
			xeno_reagent.overlays += transvitox_high_image
		else if(transvitox_amount > 0)
			xeno_reagent.overlays += transvitox_image

		if(sanguinal_amount > 10)
			xeno_reagent.overlays += sanguinal_high_image
		else if(sanguinal_amount > 0)
			xeno_reagent.overlays += sanguinal_image

	hud_list[XENO_REAGENT_HUD] = xeno_reagent

	//Xeno debuff section start
	xeno_debuff.overlays.Cut()
	xeno_debuff.icon_state = ""
	if(stat != DEAD)
		if(IsMute())
			xeno_debuff.overlays += hunter_silence_image

	if(has_status_effect(STATUS_EFFECT_DANCER_TAGGED))
		xeno_debuff.overlays += dancer_marked_image

	if(has_status_effect(STATUS_EFFECT_LIFEDRAIN))
		xeno_debuff.overlays += lifedrain

	if(HAS_TRAIT(src, TRAIT_HIVE_TARGET))
		xeno_debuff.overlays += hive_target_image

	if(has_status_effect(STATUS_EFFECT_INTOXICATED))
		var/datum/status_effect/stacking/intoxicated/debuff = has_status_effect(STATUS_EFFECT_INTOXICATED)
		var/intoxicated_amount = debuff.stacks
		xeno_debuff.overlays += intoxicated_amount_image
		intoxicated_amount_image.icon_state = "intoxicated_amount[intoxicated_amount]"
		if(intoxicated_amount > 15)
			xeno_debuff.overlays += intoxicated_high_image
		else if(intoxicated_amount > 0)
			xeno_debuff.overlays += intoxicated_image

	hud_list[XENO_DEBUFF_HUD] = xeno_debuff

	status_hud.overlays.Cut()
	if(species.species_flags & IS_SYNTHETIC)
		simple_status_hud.icon_state = ""
		if(stat != DEAD)
			status_hud.icon_state = "synth"
			switch(round(health * 100 / maxHealth)) // special health HUD icons for damaged synthetics
				if(-29 to 4) // close to overheating: should appear when health is less than 5
					status_hud.icon_state = "synthsoftcrit"
				if(-INFINITY to -30) // dying
					status_hud.icon_state = "synthhardcrit"
		else if(HAS_TRAIT(src, TRAIT_UNDEFIBBABLE))
			status_hud.icon_state = "synthdnr"
			return TRUE
		else
			if(!mind)
				var/mob/dead/observer/ghost = get_ghost(TRUE)
				if(!ghost)
					status_hud.icon_state = "synthdnr"
					return TRUE
				if(!ghost.client) // DC'd ghost detected
					status_hud.overlays += "dead_noclient"
			if(!client && !get_ghost(TRUE)) // Nobody home, no ghost, must have disconnected while in their body
				status_hud.overlays += "dead_noclient"
			status_hud.icon_state = "synthdead"
			return TRUE
		infection_hud.icon_state = "synth" //Xenos can feel synths are not human.
		return TRUE

	if(species.species_flags & HEALTH_HUD_ALWAYS_DEAD)
		status_hud.icon_state = "dead"
		infection_hud.icon_state = ""
		simple_status_hud.icon_state = ""
		return TRUE

	if(status_flags & XENO_HOST)
		var/obj/item/alien_embryo/E = locate(/obj/item/alien_embryo) in src
		if(E)
			infection_hud.icon = 'icons/mob/hud/infected.dmi'
			if(E.boost_timer)
				infection_hud.icon_state = "infectedmodifier[E.stage]"
			else
				infection_hud.icon_state = "infected[E.stage]"
		else if(locate(/mob/living/carbon/xenomorph/larva) in src)
			infection_hud.icon = 'icons/mob/hud/infected.dmi'
			infection_hud.icon_state = "infected6"
		else
			infection_hud.icon_state = ""
	else
		infection_hud.icon_state = ""
	if(species.species_flags & ROBOTIC_LIMBS)
		simple_status_hud.icon_state = ""
		infection_hud.icon_state = "robot"

	var/is_bot = has_ai()
	switch(stat)
		if(DEAD)
			simple_status_hud.icon_state = ""
			infection_hud.icon_state = "dead"
			if(!HAS_TRAIT(src, TRAIT_PSY_DRAINED))
				infection_hud.icon_state = "psy_drain"
			if(HAS_TRAIT(src, TRAIT_UNDEFIBBABLE ))
				hud_list[HEART_STATUS_HUD].icon_state = "still_heart"
				status_hud.icon_state = "dead"
				return TRUE
			if(!mind && !is_bot)
				var/mob/dead/observer/ghost = get_ghost(TRUE)
				if(!ghost) // No ghost detected. DNR player or NPC
					status_hud.icon_state = "dead_dnr"
					return TRUE
				if(!ghost.client) // DC'd ghost detected
					status_hud.overlays += "dead_noclient"
			if(!client && !get_ghost(TRUE)) // Nobody home, no ghost, must have disconnected while in their body
				status_hud.overlays += "dead_noclient"
			var/stage
			switch(dead_ticks)
				if(0 to 0.4 * TIME_BEFORE_DNR)
					stage = 1
				if(0.4 * TIME_BEFORE_DNR to 0.8 * TIME_BEFORE_DNR)
					stage = 2
				if(0.8 * TIME_BEFORE_DNR to INFINITY)
					stage = 3
			status_hud.icon_state = "dead_defib[stage]"
			return TRUE
		if(UNCONSCIOUS)
			if(!client) //Nobody home.
				if(is_bot)
					simple_status_hud.icon_state = "ai_mob"
					status_hud.icon_state = "ai_mob"
				else
					simple_status_hud.icon_state = "afk"
					status_hud.icon_state = "afk"
				return TRUE
			if(IsUnconscious()) //Should hopefully get out of it soon.
				simple_status_hud.icon_state = "knockout"
				status_hud.icon_state = "knockout"
				return TRUE
			status_hud.icon_state = "sleep" //Regular sleep, else.
			simple_status_hud.icon_state = "sleep"
			return TRUE
		if(CONSCIOUS)
			if(!key) //Nobody home. Shouldn't affect aghosting.
				if(is_bot)
					simple_status_hud.icon_state = "ai_mob"
					status_hud.icon_state = "ai_mob"
				else
					simple_status_hud.icon_state = "afk"
					status_hud.icon_state = "afk"
				return TRUE
			if(IsParalyzed()) //I've fallen and I can't get up.
				simple_status_hud.icon_state = "knockdown"
				status_hud.icon_state = "knockdown"
				return TRUE
			if(IsStun())
				simple_status_hud.icon_state = "stun"
				status_hud.icon_state = "stun"
				return TRUE
			if(IsStaggered())
				simple_status_hud.icon_state = "stagger"
				status_hud.icon_state = "stagger"
				return TRUE
			if(slowdown)
				simple_status_hud.icon_state = "slowdown"
				status_hud.icon_state = "slowdown"
				return TRUE
			else
				if(species.species_flags & ROBOTIC_LIMBS)
					simple_status_hud.icon_state = ""
					status_hud.icon_state = "robot"
					return TRUE
				else
					simple_status_hud.icon_state = ""
					status_hud.icon_state = "healthy"
					return TRUE

#define HEALTH_RATIO_PAIN_HUD 1
#define PAIN_RATIO_PAIN_HUD 0.25
#define STAMINA_RATIO_PAIN_HUD 0.25

/mob/proc/med_pain_set_perceived_health()
	return

/mob/living/carbon/human/med_pain_set_perceived_health()
	if(species?.species_flags & IS_SYNTHETIC)
		return FALSE

	var/image/holder = hud_list[PAIN_HUD]
	if(stat == DEAD)
		holder.icon = 'icons/mob/hud/human_health.dmi'
		holder.icon_state = "health-100"
		return TRUE

	var/perceived_health = health / maxHealth * 100
	if(!(species.species_flags & NO_PAIN))
		perceived_health -= PAIN_RATIO_PAIN_HUD * traumatic_shock
	if(!(species.species_flags & NO_STAMINA) && staminaloss > 0)
		perceived_health -= STAMINA_RATIO_PAIN_HUD * staminaloss

	holder.icon = 'icons/mob/hud/human_health.dmi'
	if(perceived_health >= 100)
		holder.icon_state = "health100"
	else if(perceived_health > 0)
		holder.icon_state = "health[round(perceived_health, 10)]"
	else if(health > (health_threshold_dead * 0.5))
		holder.icon_state = "health-0"
	else
		holder.icon_state = "health-50"

	return TRUE

//infection status that appears on humans and monkeys, viewed by xenos only.
/datum/atom_hud/xeno_infection
	hud_icons = list(XENO_EMBRYO_HUD)

//active reagent hud that apppears only for xenos
/datum/atom_hud/xeno_reagents
	hud_icons = list(XENO_REAGENT_HUD)

///hud component for revealing tactical elements to xenos
/datum/atom_hud/xeno_tactical
	hud_icons = list(XENO_TACTICAL_HUD)

///hud component for revealing xeno specific status effect debuffs to xenos
/datum/atom_hud/xeno_debuff
	hud_icons = list(XENO_DEBUFF_HUD)

//Xeno status hud, for xenos
/datum/atom_hud/xeno
	hud_icons = list(HEALTH_HUD_XENO, PLASMA_HUD, PHEROMONE_HUD, QUEEN_OVERWATCH_HUD, ARMOR_SUNDER_HUD, XENO_FIRE_HUD, XENO_RANK_HUD, XENO_BLESSING_HUD, XENO_EVASION_HUD)

/datum/atom_hud/xeno_heart
	hud_icons = list(HEART_STATUS_HUD)

/mob/living/proc/hud_set_sunder()
	return

/mob/living/carbon/xenomorph/hud_set_sunder()
	var/image/holder = hud_list[ARMOR_SUNDER_HUD]
	if(!holder)
		return

	if(stat == DEAD)
		holder.icon = 'icons/mob/hud/xeno_health.dmi'
		holder.icon_state = "sundering0"
		return

	var/amount = min(round(sunder * 100 / xeno_caste.sunder_max, 10), 100)
	holder.icon = 'icons/mob/hud/xeno_health.dmi'
	holder.icon_state = "sundering[amount]"

///Set fire stacks on the hud
/mob/living/proc/hud_set_firestacks()
	return

/mob/living/carbon/xenomorph/hud_set_firestacks()
	var/image/holder = hud_list[XENO_FIRE_HUD]
	if(!holder)
		return

	if(stat == DEAD)
		holder.icon_state = ""
		return
	switch(fire_stacks)
		if(-INFINITY to 0)
			holder.icon_state = ""
		if(1 to 5)
			holder.icon = 'icons/mob/hud/xeno.dmi'
			holder.icon_state = "firestack1"
		if(6 to 10)
			holder.icon = 'icons/mob/hud/xeno.dmi'
			holder.icon_state = "firestack2"
		if(11 to 15)
			holder.icon = 'icons/mob/hud/xeno.dmi'
			holder.icon_state = "firestack3"
		if(16 to INFINITY)
			holder.icon = 'icons/mob/hud/xeno.dmi'
			holder.icon_state = "firestack4"

/mob/living/carbon/xenomorph/proc/hud_set_plasma()
	if(!xeno_caste) //this is cringe that we need this but currently its called before caste is set on init
		return
	if(hud_used?.alien_plasma_display)
		var/bucket
		if(stat == DEAD)
			bucket = "empty"
		else
			bucket = get_bucket(XENO_HUD_ICON_BUCKETS, xeno_caste.plasma_max, plasma_stored, 0, list("full", "empty"))
		hud_used.alien_plasma_display.icon_state = "power_display_[bucket]"

	var/image/holder = hud_list[PLASMA_HUD]
	if(!holder)
		return
	holder.overlays.Cut()
	if(stat == DEAD)
		return
	holder.icon = 'icons/mob/hud/xeno_health.dmi'
	var/plasma_amount = xeno_caste.plasma_max? round(plasma_stored * 100 / xeno_caste.plasma_max, 10) : 0
	holder.overlays += xeno_caste.plasma_icon_state? "[xeno_caste.plasma_icon_state][plasma_amount]" : null
	var/wrath_amount = xeno_caste.wrath_max? round(wrath_stored * 100 / xeno_caste.wrath_max, 10) : 0
	holder.overlays += "wrath[wrath_amount]"

/mob/living/carbon/xenomorph/proc/hud_set_pheromone()
	var/image/holder = hud_list[PHEROMONE_HUD]
	if(!holder)
		return
	holder.icon_state = ""
	if(stat != DEAD)
		var/tempname = ""
		if(frenzy_aura)
			tempname += AURA_XENO_FRENZY
		if(warding_aura)
			tempname += AURA_XENO_WARDING
		if(recovery_aura)
			tempname += AURA_XENO_RECOVERY
		if(tempname)
			holder.icon = 'icons/mob/hud/aura.dmi'
			holder.icon_state = "[tempname]"

	hud_list[PHEROMONE_HUD] = holder

//Only called when an aura is added or removed
/mob/living/carbon/xenomorph/update_aura_overlay()
	var/image/holder = hud_list[PHEROMONE_HUD]
	if(!holder)
		return
	holder.overlays.Cut()
	if(stat == DEAD)
		return
	for(var/aura_type in GLOB.pheromone_images_list)
		if(emitted_auras.Find(aura_type))
			holder.overlays += image('icons/mob/hud/aura.dmi', src, "[aura_type]_aura")

/mob/living/carbon/xenomorph/proc/hud_set_queen_overwatch()
	var/image/holder = hud_list[QUEEN_OVERWATCH_HUD]
	holder.overlays.Cut()
	holder.icon_state = ""
	if(stat != DEAD)
		if(hive?.living_xeno_ruler)
			if(hive.living_xeno_ruler.observed_xeno == src)
				holder.icon = 'icons/mob/hud/xeno.dmi'
				holder.icon_state = "queen_overwatch"
			if(xeno_flags & XENO_LEADER)
				var/image/I = image('icons/mob/hud/xeno.dmi',src, "leader")
				holder.overlays += I
			if(hive.living_xeno_ruler == src)
				var/image/I = image('icons/mob/hud/xeno.dmi',src, "ruler")
				holder.overlays += I

	hud_list[QUEEN_OVERWATCH_HUD] = holder

/mob/living/carbon/xenomorph/proc/hud_update_rank()
	var/image/holder = hud_list[XENO_RANK_HUD]
	holder.icon_state = ""
	if(stat != DEAD && playtime_as_number() > 0 && client.prefs.show_xeno_rank)
		holder.icon = 'icons/mob/hud/xeno.dmi'
		holder.icon_state = "upgrade_[playtime_as_number()]"

	hud_list[XENO_RANK_HUD] = holder

/datum/atom_hud/security
	hud_icons = list(WANTED_HUD)

/mob/living/carbon/human/proc/sec_hud_set_security_status()
	var/image/holder = hud_list[WANTED_HUD]
	holder.icon_state = ""
	var/perpname = name
	var/obj/item/card/id/I = get_idcard()
	if(istype(I))
		perpname = I.registered_name

	for(var/datum/data/record/E in GLOB.datacore.general) // someone should either delete or fix this
		if(E.fields["name"] == perpname)
			for(var/datum/data/record/R in GLOB.datacore.security)
				if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
					holder.icon_state = "wanted"
					break
				else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Incarcerated"))
					holder.icon_state = "prisoner"
					break
				else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Released"))
					holder.icon_state = "released"
					break

/datum/atom_hud/squad
	hud_icons = list(SQUAD_HUD_TERRAGOV, MACHINE_HEALTH_HUD, MACHINE_AMMO_HUD)

/datum/atom_hud/squad_som
	hud_icons = list(SQUAD_HUD_SOM, MACHINE_HEALTH_HUD, MACHINE_AMMO_HUD)

/mob/proc/hud_set_job(faction = FACTION_TERRAGOV)
	return

/mob/living/carbon/human/hud_set_job(faction = FACTION_TERRAGOV)
	var/hud_type
	switch(faction)
		if(FACTION_TERRAGOV)
			hud_type = SQUAD_HUD_TERRAGOV
		if(FACTION_SOM)
			hud_type = SQUAD_HUD_SOM
		else
			return
	var/image/holder = hud_list[hud_type]
	holder.icon_state = ""
	holder.overlays.Cut()

	if(assigned_squad)
		var/squad_color = assigned_squad.color
		var/rank = job.comm_title
		if(job.job_flags & JOB_FLAG_PROVIDES_SQUAD_HUD)
			var/image/IMG = image('icons/mob/hud/job.dmi', src, "")
			IMG.color = squad_color
			holder.overlays += IMG
			holder.overlays += image('icons/mob/hud/job.dmi', src, "[rank]")
			if(assigned_squad?.squad_leader == src)
				holder.overlays += image('icons/mob/hud/job.dmi', src, "leader_trim")
		var/fireteam = wear_id?.assigned_fireteam
		if(fireteam)
			var/image/IMG2 = image('icons/mob/hud/job.dmi', src, "fireteam_[fireteam]")
			IMG2.color = squad_color
			holder.overlays += IMG2

	else if(job.job_flags & JOB_FLAG_PROVIDES_SQUAD_HUD)
		holder.overlays += image('icons/mob/hud/job.dmi', src, "[job.comm_title]")

	hud_list[hud_type] = holder

/datum/atom_hud/order
	hud_icons = list(ORDER_HUD)

///Updates aura hud icons
/mob/living/carbon/human/proc/hud_set_order()
	var/image/holder = hud_list[ORDER_HUD]
	holder.overlays.Cut()
	if(stat == DEAD)
		return
	var/static/image/mobility_icon = image(icon = 'icons/mob/hud/aura.dmi', icon_state = "move")
	var/static/image/protection_icon = image(icon = 'icons/mob/hud/aura.dmi', icon_state = "hold")
	var/static/image/marksman_icon = image(icon = 'icons/mob/hud/aura.dmi', icon_state = "focus")
	var/static/image/flag_icon = image(icon = 'icons/mob/hud/aura.dmi', icon_state = "flag")
	var/static/image/flag_lost_icon = image(icon = 'icons/mob/hud/aura.dmi', icon_state = "flag_lost")

	if(mobility_aura)
		holder.add_overlay(mobility_icon)
	if(protection_aura)
		holder.add_overlay(protection_icon)
	if(marksman_aura)
		holder.add_overlay(marksman_icon)
	if(flag_aura > 0)
		holder.add_overlay(flag_icon)
	else if(flag_aura < 0)
		holder.add_overlay(flag_lost_icon)

	update_aura_overlay()

//Only called when an aura is added or removed
/mob/living/carbon/human/update_aura_overlay()
	var/image/holder = hud_list[ORDER_HUD]
	var/static/image/mobility_source = image(icon = 'icons/mob/hud/aura.dmi', icon_state = "move_aura")
	var/static/image/protection_source = image(icon = 'icons/mob/hud/aura.dmi', icon_state = "hold_aura")
	var/static/image/marksman_source = image(icon = 'icons/mob/hud/aura.dmi', icon_state = "focus_aura")

	emitted_auras.Find(AURA_HUMAN_MOVE) ? holder.add_overlay(mobility_source) : holder.cut_overlay(mobility_source)
	emitted_auras.Find(AURA_HUMAN_HOLD) ? holder.add_overlay(protection_source) : holder.cut_overlay(protection_source)
	emitted_auras.Find(AURA_HUMAN_FOCUS) ? holder.add_overlay(marksman_source) : holder.cut_overlay(marksman_source)

///Makes sentry health visible
/obj/proc/hud_set_machine_health()
	var/image/holder = hud_list[MACHINE_HEALTH_HUD]

	if(!holder)
		return

	if(obj_integrity < 1)
		holder.icon = 'icons/mob/hud/xeno_health.dmi'
		holder.icon_state = "health0"
		return

	var/amount = round(obj_integrity * 100 / max_integrity, 10)
	if(!amount)
		amount = 1 //don't want the 'zero health' icon when we still have 4% of our health
	holder.icon = 'icons/mob/hud/xeno_health.dmi'
	holder.icon_state = "health[amount]"

///Makes mounted guns ammo visible
/obj/machinery/deployable/mounted/proc/hud_set_gun_ammo()
	var/image/holder = hud_list[MACHINE_AMMO_HUD]

	if(!holder)
		return
	var/obj/item/weapon/gun/internal_gun = internal_item.resolve()
	if(!internal_gun?.rounds)
		holder.icon = 'icons/mob/hud/xeno_health.dmi'
		holder.icon_state = "plasma0"
		return
	var/amount = internal_gun.max_rounds ? round(internal_gun.rounds * 100 / internal_gun.max_rounds, 10) : 0
	holder.icon = 'icons/mob/hud/xeno_health.dmi'
	holder.icon_state = "plasma[amount]"

///Makes unmanned vehicle ammo visible
/obj/vehicle/unmanned/proc/hud_set_uav_ammo()
	var/image/holder = hud_list[MACHINE_AMMO_HUD]

	if(!holder)
		return

	if(!current_rounds)
		holder.icon = 'icons/mob/hud/xeno_health.dmi'
		holder.icon_state = "plasma0"
		return

	var/amount = round(current_rounds * 100 / max_rounds, 10)
	holder.icon = 'icons/mob/hud/xeno_health.dmi'
	holder.icon_state = "plasma[amount]"

///Mecha health hud updates
/obj/vehicle/sealed/mecha/proc/hud_set_mecha_health()
	var/image/holder = hud_list[MACHINE_HEALTH_HUD]

	if(!holder)
		return

	if(obj_integrity < 1)
		holder.icon = 'icons/mob/hud/xeno_health.dmi'
		holder.icon_state = "health0"
		return

	var/amount = round(obj_integrity * 100 / max_integrity, 10)
	if(!amount)
		amount = 1 //don't want the 'zero health' icon when we still have 4% of our health
	holder.icon = 'icons/mob/hud/xeno_health.dmi'
	holder.icon_state = "health[amount]"

///Updates mecha battery
/obj/vehicle/sealed/mecha/proc/hud_set_mecha_battery()
	var/image/holder = hud_list[MACHINE_AMMO_HUD]

	if(!holder)
		return

	if(!cell)
		holder.icon = 'icons/mob/hud/xeno_health.dmi'
		holder.icon_state = "plasma0"
		return

	var/amount = round(cell.charge * 100 / cell.maxcharge, 10)
	holder.icon = 'icons/mob/hud/xeno_health.dmi'
	holder.icon_state = "plasma[amount]"

/obj/vehicle/sealed/mecha/proc/diag_hud_set_mechstat()
	var/image/holder = hud_list[ORDER_HUD]
	if(!holder)
		return
	holder.pixel_y = get_cached_height() - world.icon_size
	if(internal_damage)
		holder.icon_state = "hudwarn"
	holder.icon_state = null

/obj/machinery/deployable/tesla_turret/proc/hud_set_tesla_battery()
	var/image/holder = hud_list[MACHINE_AMMO_HUD]

	if(!holder)
		return

	if(!battery)
		holder.icon = 'icons/mob/hud/xeno_health.dmi'
		holder.icon_state = "plasma0"
		return

	var/amount = round(battery.charge * 100 / battery.maxcharge, 10)
	holder.icon = 'icons/mob/hud/xeno_health.dmi'
	holder.icon_state = "plasma[amount]"
