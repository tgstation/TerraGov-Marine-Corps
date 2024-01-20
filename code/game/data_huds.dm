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
	var/image/holder = hud_list[HEALTH_HUD_XENO]
	if(!holder)
		return
	if(stat == DEAD)
		holder.icon_state = "xenohealth0"
		return

	var/amount = health > 0 ? round(health * 100 / maxHealth, 10) : CEILING(health, 10)
	if(!amount && health < 0)
		amount = -1 //don't want the 'zero health' icon when we are crit
	holder.icon_state = "xenohealth[amount]"


/mob/living/carbon/human/med_hud_set_health()
	var/image/holder = hud_list[HEALTH_HUD]
	if(stat == DEAD)
		holder.icon_state = "hudhealth-100"
		return

	var/percentage = round(health * 100 / maxHealth)
	switch(percentage)
		if(100 to INFINITY)
			holder.icon_state = "hudhealth100"
		if(90 to 99)
			holder.icon_state = "hudhealth90"
		if(80 to 89)
			holder.icon_state = "hudhealth80"
		if(70 to 79)
			holder.icon_state = "hudhealth70"
		if(60 to 69)
			holder.icon_state = "hudhealth60"
		if(50 to 59)
			holder.icon_state = "hudhealth50"
		if(45 to 49)
			holder.icon_state = "hudhealth45"
		if(40 to 44)
			holder.icon_state = "hudhealth40"
		if(35 to 39)
			holder.icon_state = "hudhealth35"
		if(30 to 34)
			holder.icon_state = "hudhealth30"
		if(25 to 29)
			holder.icon_state = "hudhealth25"
		if(20 to 24)
			holder.icon_state = "hudhealth20"
		if(15 to 19)
			holder.icon_state = "hudhealth15"
		if(10 to 14)
			holder.icon_state = "hudhealth10"
		if(5 to 9)
			holder.icon_state = "hudhealth5"
		if(0 to 4)
			holder.icon_state = "hudhealth0"
		if(-49 to -1)
			holder.icon_state = "hudhealth-0"
		if(-99 to -50)
			holder.icon_state = "hudhealth-50"
		else
			holder.icon_state = "hudhealth-100"


/mob/proc/med_hud_set_status() //called when mob stat changes, or get a virus/xeno host, etc
	return


/mob/living/carbon/xenomorph/med_hud_set_status()
	hud_set_plasma()
	hud_set_pheromone()


/mob/living/carbon/human/med_hud_set_status()
	var/image/status_hud = hud_list[STATUS_HUD] //Status for med-hud.
	var/image/infection_hud = hud_list[XENO_EMBRYO_HUD] //State of the xeno embryo.
	var/image/simple_status_hud = hud_list[STATUS_HUD_SIMPLE] //Status for the naked eye.
	var/image/xeno_reagent = hud_list[XENO_REAGENT_HUD] // Displays active xeno reagents
	var/image/xeno_debuff = hud_list[XENO_DEBUFF_HUD] //Displays active xeno specific debuffs
	var/static/image/neurotox_image = image('icons/mob/hud.dmi', icon_state = "neurotoxin")
	var/static/image/hemodile_image = image('icons/mob/hud.dmi', icon_state = "hemodile")
	var/static/image/transvitox_image = image('icons/mob/hud.dmi', icon_state = "transvitox")
	var/static/image/sanguinal_image = image('icons/mob/hud.dmi', icon_state = "sanguinal")
	var/static/image/ozelomelyn_image = image('icons/mob/hud.dmi', icon_state = "ozelomelyn")
	var/static/image/intoxicated_image = image('icons/mob/hud.dmi', icon_state = "intoxicated")
	var/static/image/intoxicated_amount_image = image('icons/mob/hud.dmi', icon_state = "intoxicated_amount0")
	var/static/image/neurotox_high_image = image('icons/mob/hud.dmi', icon_state = "neurotoxin_high")
	var/static/image/hemodile_high_image = image('icons/mob/hud.dmi', icon_state = "hemodile_high")
	var/static/image/transvitox_high_image = image('icons/mob/hud.dmi', icon_state = "transvitox_high")
	var/static/image/hunter_silence_image = image('icons/mob/hud.dmi', icon_state = "silence_debuff")
	var/static/image/sanguinal_high_image = image('icons/mob/hud.dmi', icon_state = "sanguinal_high")
	var/static/image/intoxicated_high_image = image('icons/mob/hud.dmi', icon_state = "intoxicated_high")
	var/static/image/hive_target_image = image('icons/mob/hud.dmi', icon_state = "hive_target")

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

	if(species.species_flags & IS_SYNTHETIC)
		simple_status_hud.icon_state = ""
		if(stat != DEAD)
			status_hud.icon_state = "hudsynth"
		else
			if(!client)
				var/mob/dead/observer/G = get_ghost(FALSE, TRUE)
				if(!G)
					status_hud.icon_state = "hudsynthdnr"
				else
					status_hud.icon_state = "hudsynthdead"
			return
		infection_hud.icon_state = "hudsynth" //Xenos can feel synths are not human.
		return TRUE

	if(species.species_flags & HEALTH_HUD_ALWAYS_DEAD)
		status_hud.icon_state = "huddead"
		infection_hud.icon_state = ""
		simple_status_hud.icon_state = ""
		return TRUE

	if(status_flags & XENO_HOST)
		var/obj/item/alien_embryo/E = locate(/obj/item/alien_embryo) in src
		if(E)
			if(E.boost_timer)
				infection_hud.icon_state = "infectedmodifier[E.stage]"
			else
				infection_hud.icon_state = "infected[E.stage]"
		else if(locate(/mob/living/carbon/xenomorph/larva) in src)
			infection_hud.icon_state = "infected6"
		else
			infection_hud.icon_state = ""
	else
		infection_hud.icon_state = ""
	if(species.species_flags & ROBOTIC_LIMBS)
		simple_status_hud.icon_state = ""
		infection_hud.icon_state = "hudrobot"

	switch(stat)
		if(DEAD)
			simple_status_hud.icon_state = ""
			infection_hud.icon_state = "huddead"
			if(!HAS_TRAIT(src, TRAIT_PSY_DRAINED))
				infection_hud.icon_state = "psy_drain"
			if(HAS_TRAIT(src, TRAIT_UNDEFIBBABLE ))
				hud_list[HEART_STATUS_HUD].icon_state = "still_heart"
				status_hud.icon_state = "huddead"
				return TRUE
			if(!client)
				var/mob/dead/observer/ghost = get_ghost()
				if(!ghost?.can_reenter_corpse)
					status_hud.icon_state = "huddead"
					return TRUE
			var/stage
			switch(dead_ticks)
				if(0 to 0.4 * TIME_BEFORE_DNR)
					stage = 1
				if(0.4 * TIME_BEFORE_DNR to 0.8 * TIME_BEFORE_DNR)
					stage = 2
				if(0.8 * TIME_BEFORE_DNR to INFINITY)
					stage = 3
			status_hud.icon_state = "huddeaddefib[stage]"
			return TRUE
		if(UNCONSCIOUS)
			if(!client) //Nobody home.
				simple_status_hud.icon_state = "hud_uncon_afk"
				status_hud.icon_state = "hud_uncon_afk"
				return TRUE
			if(IsUnconscious()) //Should hopefully get out of it soon.
				simple_status_hud.icon_state = "hud_uncon_ko"
				status_hud.icon_state = "hud_uncon_ko"
				return TRUE
			status_hud.icon_state = "hud_uncon_sleep" //Regular sleep, else.
			simple_status_hud.icon_state = "hud_uncon_sleep"
			return TRUE
		if(CONSCIOUS)
			if(!key) //Nobody home. Shouldn't affect aghosting.
				simple_status_hud.icon_state = "hud_uncon_afk"
				status_hud.icon_state = "hud_uncon_afk"
				return TRUE
			if(IsParalyzed()) //I've fallen and I can't get up.
				simple_status_hud.icon_state = "hud_con_kd"
				status_hud.icon_state = "hud_con_kd"
				return TRUE
			if(IsStun())
				simple_status_hud.icon_state = "hud_con_stun"
				status_hud.icon_state = "hud_con_stun"
				return TRUE
			if(IsStaggered())
				simple_status_hud.icon_state = "hud_con_stagger"
				status_hud.icon_state = "hud_con_stagger"
				return TRUE
			if(slowdown)
				simple_status_hud.icon_state = "hud_con_slowdown"
				status_hud.icon_state = "hud_con_slowdown"
				return TRUE
			else
				if(species.species_flags & ROBOTIC_LIMBS)
					simple_status_hud.icon_state = ""
					status_hud.icon_state = "hudrobot"
					return TRUE
				else
					simple_status_hud.icon_state = ""
					status_hud.icon_state = "hudhealthy"
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
		holder.icon_state = "hudhealth-100"
		return TRUE

	var/perceived_health = health / maxHealth * 100
	if(!(species.species_flags & NO_PAIN))
		perceived_health -= PAIN_RATIO_PAIN_HUD * traumatic_shock
	if(!(species.species_flags & NO_STAMINA) && staminaloss > 0)
		perceived_health -= STAMINA_RATIO_PAIN_HUD * staminaloss

	if(perceived_health >= 100)
		holder.icon_state = "hudhealth100"
	else if(perceived_health > 0)
		holder.icon_state = "hudhealth[round(perceived_health, 10)]"
	else if(health > (health_threshold_dead * 0.5))
		holder.icon_state = "hudhealth-0"
	else
		holder.icon_state = "hudhealth-50"

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
		holder.icon_state = "sundering0"
		return

	var/amount = min(round(sunder * 100 / xeno_caste.sunder_max, 10), 100)
	holder.icon_state = "sundering[amount]"

///Set fire stacks on the hud
/mob/living/proc/hud_set_firestacks()
	return

/mob/living/carbon/xenomorph/hud_set_firestacks()
	var/image/holder = hud_list[XENO_FIRE_HUD]
	if(!holder)
		return

	if(stat == DEAD)
		holder.icon_state = "firestack0"
		return
	switch(fire_stacks)
		if(-INFINITY to 0)
			holder.icon_state = "firestack0"
		if(1 to 5)
			holder.icon_state = "firestack1"
		if(6 to 10)
			holder.icon_state = "firestack2"
		if(11 to 15)
			holder.icon_state = "firestack3"
		if(16 to INFINITY)
			holder.icon_state = "firestack4"


/mob/living/carbon/xenomorph/proc/hud_set_plasma()
	if(!xeno_caste) // usually happens because hud ticks before New() finishes.
		return
	var/image/holder = hud_list[PLASMA_HUD]
	if(!holder)
		return
	holder.overlays.Cut()
	if(stat == DEAD)
		return
	var/plasma_amount = xeno_caste.plasma_max? round(plasma_stored * 100 / xeno_caste.plasma_max, 10) : 0
	holder.overlays += xeno_caste.plasma_icon_state? "[xeno_caste.plasma_icon_state][plasma_amount]" : null
	var/wrath_amount = xeno_caste.wrath_max? round(wrath_stored * 100 / xeno_caste.wrath_max, 10) : 0
	holder.overlays += "wrath[wrath_amount]"


/mob/living/carbon/xenomorph/proc/hud_set_pheromone()
	var/image/holder = hud_list[PHEROMONE_HUD]
	if(!holder)
		return
	holder.icon_state = "hudblank"
	if(stat != DEAD)
		var/tempname = ""
		if(frenzy_aura)
			tempname += AURA_XENO_FRENZY
		if(warding_aura)
			tempname += AURA_XENO_WARDING
		if(recovery_aura)
			tempname += AURA_XENO_RECOVERY
		if(tempname)
			holder.icon_state = "hud[tempname]"

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
			holder.overlays += image('icons/mob/hud.dmi', src, "hudaura[aura_type]")

/mob/living/carbon/xenomorph/proc/hud_set_queen_overwatch()
	var/image/holder = hud_list[QUEEN_OVERWATCH_HUD]
	holder.overlays.Cut()
	holder.icon_state = "hudblank"
	if(stat != DEAD)
		if(hive?.living_xeno_queen)
			if(hive.living_xeno_queen.observed_xeno == src)
				holder.icon_state = "queen_overwatch"
			if(queen_chosen_lead)
				var/image/I = image('icons/mob/hud.dmi',src, "hudxenoleader")
				holder.overlays += I
	hud_list[QUEEN_OVERWATCH_HUD] = holder

/mob/living/carbon/xenomorph/proc/hud_update_rank()
	var/image/holder = hud_list[XENO_RANK_HUD]
	holder.icon_state = "hudblank"
	if(stat != DEAD && playtime_as_number() > 0)
		holder.icon_state = "hudxenoupgrade[playtime_as_number()]"

	hud_list[XENO_RANK_HUD] = holder

/datum/atom_hud/security
	hud_icons = list(WANTED_HUD)


/mob/living/carbon/human/proc/sec_hud_set_security_status()
	var/image/holder = hud_list[WANTED_HUD]
	holder.icon_state = "hudblank"
	var/perpname = name
	var/obj/item/card/id/I = get_idcard()
	if(istype(I))
		perpname = I.registered_name

	for(var/datum/data/record/E in GLOB.datacore.general)
		if(E.fields["name"] == perpname)
			for(var/datum/data/record/R in GLOB.datacore.security)
				if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
					holder.icon_state = "hudwanted"
					break
				else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Incarcerated"))
					holder.icon_state = "hudprisoner"
					break
				else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Released"))
					holder.icon_state = "hudreleased"
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
		if(assigned_squad.squad_leader == src)
			rank = JOB_COMM_TITLE_SQUAD_LEADER
		if(job.job_flags & JOB_FLAG_PROVIDES_SQUAD_HUD)
			var/image/IMG = image('icons/mob/hud.dmi', src, "hudmarine")
			IMG.color = squad_color
			holder.overlays += IMG
			holder.overlays += image('icons/mob/hud.dmi', src, "hudmarine [rank]")
		var/fireteam = wear_id?.assigned_fireteam
		if(fireteam)
			var/image/IMG2 = image('icons/mob/hud.dmi', src, "hudmarinesquadft[fireteam]")
			IMG2.color = squad_color
			holder.overlays += IMG2

	else if(job.job_flags & JOB_FLAG_PROVIDES_SQUAD_HUD)
		holder.overlays += image('icons/mob/hud.dmi', src, "hudmarine [job.comm_title]")

	hud_list[hud_type] = holder


/datum/atom_hud/order
	hud_icons = list(ORDER_HUD)


/mob/living/carbon/human/proc/hud_set_order()
	var/image/holder = hud_list[ORDER_HUD]
	holder.icon_state = "hudblank"
	if(stat != DEAD)
		var/tempname = ""
		if(mobility_aura)
			tempname += "move"
		if(protection_aura)
			tempname += "hold"
		if(marksman_aura)
			tempname += "focus"
		if(tempname)
			holder.icon_state = "hud[tempname]"


	hud_list[ORDER_HUD] = holder

//Only called when an aura is added or removed
/mob/living/carbon/human/update_aura_overlay()
	var/image/holder = hud_list[ORDER_HUD]
	holder.overlays.Cut()
	for(var/aura_type in command_aura_allowed)
		if(emitted_auras.Find(aura_type))
			holder.overlays += image('icons/mob/hud.dmi', src, "hud[aura_type]aura")

///Makes sentry health visible
/obj/proc/hud_set_machine_health()
	var/image/holder = hud_list[MACHINE_HEALTH_HUD]

	if(!holder)
		return

	if(obj_integrity < 1)
		holder.icon_state = "xenohealth0"
		return

	var/amount = round(obj_integrity * 100 / max_integrity, 10)
	if(!amount)
		amount = 1 //don't want the 'zero health' icon when we still have 4% of our health
	holder.icon_state = "xenohealth[amount]"

///Makes mounted guns ammo visible
/obj/machinery/deployable/mounted/proc/hud_set_gun_ammo()
	var/image/holder = hud_list[MACHINE_AMMO_HUD]

	if(!holder)
		return
	var/obj/item/weapon/gun/internal_gun = internal_item.resolve()
	if(!internal_gun?.rounds)
		holder.icon_state = "plasma0"
		return
	var/amount = internal_gun.max_rounds ? round(internal_gun.rounds * 100 / internal_gun.max_rounds, 10) : 0
	holder.icon_state = "plasma[amount]"

///Makes unmanned vehicle ammo visible
/obj/vehicle/unmanned/proc/hud_set_uav_ammo()
	var/image/holder = hud_list[MACHINE_AMMO_HUD]

	if(!holder)
		return

	if(!current_rounds)
		holder.icon_state = "plasma0"
		return

	var/amount = round(current_rounds * 100 / max_rounds, 10)
	holder.icon_state = "plasma[amount]"

///Mecha health hud updates
/obj/vehicle/sealed/mecha/proc/hud_set_mecha_health()
	var/image/holder = hud_list[MACHINE_HEALTH_HUD]

	if(!holder)
		return

	if(obj_integrity < 1)
		holder.icon_state = "xenohealth0"
		return

	var/amount = round(obj_integrity * 100 / max_integrity, 10)
	if(!amount)
		amount = 1 //don't want the 'zero health' icon when we still have 4% of our health
	holder.icon_state = "xenohealth[amount]"

///Updates mecha battery
/obj/vehicle/sealed/mecha/proc/hud_set_mecha_battery()
	var/image/holder = hud_list[MACHINE_AMMO_HUD]

	if(!holder)
		return

	if(!cell)
		holder.icon_state = "plasma0"
		return

	var/amount = round(cell.charge * 100 / cell.maxcharge, 10)
	holder.icon_state = "plasma[amount]"

/obj/vehicle/sealed/mecha/proc/diag_hud_set_mechstat()
	var/image/holder = hud_list[ORDER_HUD]
	if(!holder)
		return
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	if(internal_damage)
		holder.icon_state = "hudwarn"
	holder.icon_state = null
