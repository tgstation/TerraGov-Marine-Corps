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
	hud_icons = list(HEALTH_HUD, XENO_EMBRYO_HUD, XENO_REAGENT_HUD, STATUS_HUD, MACHINE_HEALTH_HUD, SENTRY_AMMO_HUD)


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

	var/amount = round(health * 100 / maxHealth, 10)
	if(!amount)
		amount = 1 //don't want the 'zero health' icon when we still have 4% of our health
	holder.icon_state = "xenohealth[amount]"


/mob/living/carbon/human/med_hud_set_health()
	var/image/holder = hud_list[HEALTH_HUD]
	if(stat == DEAD)
		holder.icon_state = "hudhealth-100"
		return

	var/percentage = round(health * 100 / species.total_health)
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
	var/static/image/neurotox_image = image('icons/mob/hud.dmi', icon_state = "neurotoxin")
	var/static/image/hemodile_image = image('icons/mob/hud.dmi', icon_state = "hemodile")
	var/static/image/transvitox_image = image('icons/mob/hud.dmi', icon_state = "transvitox")
	var/static/image/neurotox_high_image = image('icons/mob/hud.dmi', icon_state = "neurotoxin_high")
	var/static/image/hemodile_high_image = image('icons/mob/hud.dmi', icon_state = "hemodile_high")
	var/static/image/transvitox_high_image = image('icons/mob/hud.dmi', icon_state = "transvitox_high")

	xeno_reagent.overlays.Cut()
	xeno_reagent.icon_state = ""
	if(stat != DEAD)
		var/neurotox_amount = reagents.get_reagent_amount(/datum/reagent/toxin/xeno_neurotoxin) + reagents.get_reagent_amount(/datum/reagent/toxin/xeno_neurotoxin/light)
		var/hemodile_amount = reagents.get_reagent_amount(/datum/reagent/toxin/xeno_hemodile)
		var/transvitox_amount = reagents.get_reagent_amount(/datum/reagent/toxin/xeno_transvitox)

		if(neurotox_amount > 10) //Blinking image for particularly high concentrations
			xeno_reagent.overlays += neurotox_high_image
		else if(neurotox_amount > 0)
			xeno_reagent.overlays += neurotox_image

		if(hemodile_amount > 10)
			xeno_reagent.overlays += hemodile_high_image
		else if(hemodile_amount > 0)
			xeno_reagent.overlays += hemodile_image

		if(transvitox_amount > 10)
			xeno_reagent.overlays += transvitox_high_image
		else if(transvitox_amount > 0)
			xeno_reagent.overlays += transvitox_image

	hud_list[XENO_REAGENT_HUD] = xeno_reagent

	if(species.species_flags & IS_SYNTHETIC)
		simple_status_hud.icon_state = ""
		status_hud.icon_state = "hudsynth"
		infection_hud.icon_state = "hudsynth" //Xenos can feel synths are not human.
		return TRUE

	if(status_flags & XENO_HOST)
		var/obj/item/alien_embryo/E = locate(/obj/item/alien_embryo) in src
		if(E)
			infection_hud.icon_state = "infected[E.stage]"
		else if(locate(/mob/living/carbon/xenomorph/larva) in src)
			infection_hud.icon_state = "infected6"
		else
			infection_hud.icon_state = ""
	else
		infection_hud.icon_state = ""

	switch(stat)
		if(DEAD)
			simple_status_hud.icon_state = ""
			infection_hud.icon_state = "huddead"
			if(!HAS_TRAIT(src, TRAIT_PSY_DRAINED))
				infection_hud.icon_state = "psy_drain"
			if(HAS_TRAIT(src, TRAIT_UNDEFIBBABLE ))
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
			if(stagger || slowdown)
				simple_status_hud.icon_state = "hud_con_stagger"
				status_hud.icon_state = "hud_con_stagger"
				return TRUE
			else
				simple_status_hud.icon_state = ""
				status_hud.icon_state = "hudhealthy"
				return TRUE

#define HEALTH_RATIO_PAIN_HUD 1
#define PAIN_RATIO_PAIN_HUD 0.25
#define STAMINA_RATIO_PAIN_HUD 0.5


/mob/proc/med_pain_set_perceived_health()
	return


/mob/living/carbon/human/med_pain_set_perceived_health()
	if(species && species.species_flags & NO_PAIN)
		return FALSE

	var/image/holder = hud_list[PAIN_HUD]
	if(stat == DEAD)
		holder.icon_state = "hudhealth-100"
		return TRUE

	var/perceived_health = health
	if(!(species.species_flags & NO_PAIN))
		perceived_health -= PAIN_RATIO_PAIN_HUD * traumatic_shock
	if(!(species.species_flags & NO_STAMINA) && staminaloss > 0)
		perceived_health -= STAMINA_RATIO_PAIN_HUD * staminaloss

	switch(perceived_health)
		if(100 to INFINITY)
			holder.icon_state = "hudhealth100"
		if(0 to 100)
			holder.icon_state = "hudhealth[round(perceived_health, 10)]"
		if(-50 to 0)
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

//Xeno status hud, for xenos
/datum/atom_hud/xeno
	hud_icons = list(HEALTH_HUD_XENO, PLASMA_HUD, PHEROMONE_HUD, QUEEN_OVERWATCH_HUD, ARMOR_SUNDER_HUD)

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

/mob/living/carbon/xenomorph/proc/hud_set_plasma()
	if(!xeno_caste) // usually happens because hud ticks before New() finishes.
		return
	var/image/holder = hud_list[PLASMA_HUD]
	if(!holder)
		return
	if(stat == DEAD)
		holder.icon_state = "[xeno_caste.plasma_icon_state]0"
	else
		var/amount = round(plasma_stored * 100 / xeno_caste.plasma_max, 10)
		holder.icon_state = "[xeno_caste.plasma_icon_state][amount]"


/mob/living/carbon/xenomorph/proc/hud_set_pheromone()
	var/image/holder = hud_list[PHEROMONE_HUD]
	if(!holder)
		return
	holder.overlays.Cut()
	holder.icon_state = "hudblank"
	if(stat != DEAD)
		var/tempname = ""
		if(frenzy_aura)
			tempname += "frenzy"
		if(warding_aura)
			tempname += "warding"
		if(recovery_aura)
			tempname += "recovery"
		if(tempname)
			holder.icon_state = "hud[tempname]"

		switch(current_aura)
			if("frenzy")
				holder.overlays += image('icons/mob/hud.dmi', src, "hudaurafrenzy")
			if("recovery")
				holder.overlays += image('icons/mob/hud.dmi', src, "hudaurarecovery")
			if("warding")
				holder.overlays += image('icons/mob/hud.dmi', src, "hudaurawarding")

		switch(leader_current_aura)
			if("frenzy")
				holder.overlays += image('icons/mob/hud.dmi', src, "hudaurafrenzy")
			if("recovery")
				holder.overlays += image('icons/mob/hud.dmi', src, "hudaurarecovery")
			if("warding")
				holder.overlays += image('icons/mob/hud.dmi', src, "hudaurawarding")

	hud_list[PHEROMONE_HUD] = holder


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
		if(upgrade_as_number() > 0) // theres only icons for 1 2 3, not for -1
			var/image/J = image('icons/mob/hud.dmi',src, "hudxenoupgrade[upgrade_as_number()]")
			holder.overlays += J
	hud_list[QUEEN_OVERWATCH_HUD] = holder


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
	hud_icons = list(SQUAD_HUD_TERRAGOV, MACHINE_HEALTH_HUD, SENTRY_AMMO_HUD)

/datum/atom_hud/squad_rebel
	hud_icons = list(SQUAD_HUD_REBEL, MACHINE_HEALTH_HUD, SENTRY_AMMO_HUD)


/mob/proc/hud_set_job(faction = FACTION_TERRAGOV)
	return


/mob/living/carbon/human/hud_set_job(faction = FACTION_TERRAGOV)
	var/hud_type = faction == FACTION_TERRAGOV ? SQUAD_HUD_TERRAGOV : SQUAD_HUD_REBEL
	var/image/holder = hud_list[hud_type]
	holder.icon_state = ""
	holder.overlays.Cut()

	if(assigned_squad)
		var/squad_color = assigned_squad.color
		var/rank = job.title
		if(assigned_squad.squad_leader == src)
			rank = SQUAD_LEADER
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
		holder.overlays += image('icons/mob/hud.dmi', src, "hudmarine [job.title]")

	hud_list[hud_type] = holder


/datum/atom_hud/order
	hud_icons = list(ORDER_HUD)


/mob/living/carbon/human/proc/hud_set_order()
	var/image/holder = hud_list[ORDER_HUD]
	holder.overlays.Cut()
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

		switch(command_aura)
			if("move")
				holder.overlays += image('icons/mob/hud.dmi', src, "hudmoveaura")
			if("hold")
				holder.overlays += image('icons/mob/hud.dmi', src, "hudholdaura")
			if("focus")
				holder.overlays += image('icons/mob/hud.dmi', src, "hudfocusaura")

	hud_list[ORDER_HUD] = holder

///Makes sentry health visible
/obj/machinery/proc/hud_set_machine_health()
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

///Makes sentry ammo visible
/obj/machinery/marine_turret/proc/hud_set_sentry_ammo()
	var/image/holder = hud_list[SENTRY_AMMO_HUD]

	if(!holder)
		return

	if(!rounds)
		holder.icon_state = "plasma0"
		return

	var/amount = round(rounds * 100 / rounds_max, 10)
	holder.icon_state = "plasma[amount]"

///Makes mounted guns ammo visible
/obj/machinery/deployable/mounted/proc/hud_set_gun_ammo()
	var/image/holder = hud_list[SENTRY_AMMO_HUD]

	if(!holder)
		return
	var/obj/item/weapon/gun/gun = internal_item
	if(!gun.current_mag)
		holder.icon_state = "plasma0"
		return
	var/amount = round(gun.current_mag.current_rounds * 100 / gun.current_mag.max_rounds, 10)
	holder.icon_state = "plasma[amount]"
