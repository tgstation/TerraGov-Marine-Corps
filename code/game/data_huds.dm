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
	for(var/datum/atom_hud/hud in GLOB.huds)
		if(istype(hud, /datum/atom_hud/xeno)) //this one is xeno only
			continue
		hud.add_to_hud(src)


/mob/living/carbon/monkey/add_to_all_mob_huds()
	for(var/datum/atom_hud/hud in GLOB.huds)
		hud.add_to_hud(src)


/mob/living/carbon/xenomorph/add_to_all_mob_huds()
	for(var/datum/atom_hud/hud in GLOB.huds)
		if(!istype(hud, /datum/atom_hud/xeno))
			continue
		hud.add_to_hud(src)


/atom/proc/remove_from_all_mob_huds()
	return


/mob/living/carbon/human/remove_from_all_mob_huds()
	for(var/datum/atom_hud/hud in GLOB.huds)
		if(istype(hud, /datum/atom_hud/xeno))
			continue
		hud.remove_from_hud(src)


/mob/living/carbon/monkey/remove_from_all_mob_huds()
	for(var/datum/atom_hud/hud in GLOB.huds)
		hud.add_to_hud(src)


/mob/living/carbon/xenomorph/remove_from_all_mob_huds()
	for(var/datum/atom_hud/hud in GLOB.huds)
		if(!istype(hud, /datum/atom_hud/xeno))
			continue
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


//medical hud used by ghosts
/datum/atom_hud/medical/observer
	hud_icons = list(HEALTH_HUD, XENO_EMBRYO_HUD, STATUS_HUD)


/datum/atom_hud/medical/pain
	hud_icons = list(PAIN_HUD)


/mob/proc/med_hud_set_health()
	return


/mob/living/carbon/xenomorph/med_hud_set_health()
	var/image/holder = hud_list[HEALTH_HUD_XENO]
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


/mob/living/carbon/monkey/med_hud_set_status()
	var/image/holder = hud_list[XENO_EMBRYO_HUD]
	if(status_flags & XENO_HOST)
		var/obj/item/alien_embryo/E = locate(/obj/item/alien_embryo) in src
		if(E)
			holder.icon_state = "infected[E.stage]"
		else if(locate(/mob/living/carbon/xenomorph/larva) in src)
			holder.icon_state = "infected5"
	else if(stat == DEAD)
		holder.icon_state = "huddead"
	else
		holder.icon_state = ""


/mob/living/carbon/human/med_hud_set_status()
	var/image/status_hud = hud_list[STATUS_HUD] //Status for med-hud.
	var/image/infection_hud = hud_list[XENO_EMBRYO_HUD] //State of the xeno embryo.
	var/image/simple_status_hud = hud_list[STATUS_HUD_SIMPLE] //Status for the naked eye.

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
			infection_hud.icon_state = "huddead" //Xenos sense dead hosts, and no longer their larvas inside, which fall into stasis and no longer grow.
			if(undefibbable || (!client && !get_ghost()))
				status_hud.icon_state = "huddead"
				return TRUE
			var/stage = 1
			if((world.time - timeofdeath) > (CONFIG_GET(number/revive_grace_period) * 0.4) && (world.time - timeofdeath) < (CONFIG_GET(number/revive_grace_period) * 0.8))
				stage = 2
			else if((world.time - timeofdeath) > (CONFIG_GET(number/revive_grace_period) * 0.8))
				stage = 3
			status_hud.icon_state = "huddeaddefib[stage]"
			return TRUE
		if(UNCONSCIOUS)
			if(!client) //Nobody home.
				simple_status_hud.icon_state = "hud_uncon_afk"
				status_hud.icon_state = "hud_uncon_afk"
				return TRUE
			if(knocked_out) //Should hopefully get out of it soon.
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
			if(knocked_down) //I've fallen and I can't get up.
				simple_status_hud.icon_state = "hud_con_kd"
				status_hud.icon_state = "hud_con_kd"
				return TRUE
			if(stunned)
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


/mob/proc/med_pain_set_perceived_health()
	return


/mob/living/carbon/human/med_pain_set_perceived_health()
	if(species && species.species_flags & NO_PAIN)
		return FALSE

	var/image/holder = hud_list[PAIN_HUD]
	if(stat == DEAD)
		holder.icon_state = "hudhealth-100"
		return TRUE

	var/perceived_health = health - traumatic_shock

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


//Xeno status hud, for xenos
/datum/atom_hud/xeno
	hud_icons = list(HEALTH_HUD_XENO, PLASMA_HUD, PHEROMONE_HUD, QUEEN_OVERWATCH_HUD)


/mob/living/carbon/xenomorph/proc/hud_set_plasma()
	if(!xeno_caste) // usually happens because hud ticks before New() finishes.
		return
	var/image/holder = hud_list[PLASMA_HUD]
	if(stat == DEAD)
		holder.icon_state = "plasma0"
	else
		var/amount = round(plasma_stored * 100 / xeno_caste.plasma_max, 10)
		holder.icon_state = "plasma[amount]"


/mob/living/carbon/xenomorph/proc/hud_set_pheromone()
	var/image/holder = hud_list[PHEROMONE_HUD]
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
	hud_icons = list(ID_HUD)


/mob/living/carbon/proc/sec_hud_set_ID()
	return


/mob/living/carbon/human/sec_hud_set_ID()
	var/image/holder = hud_list[ID_HUD]
	holder.icon_state = "hudunknown"
	if(wear_id)
		var/obj/item/card/id/I = wear_id.GetID()
		if(I)
			holder.icon_state = "hud[ckey(I.GetJobName())]"


/datum/atom_hud/security/advanced
	hud_icons = list(ID_HUD, IMPTRACK_HUD, IMPLOYAL_HUD, IMPCHEM_HUD, WANTED_HUD)


/mob/proc/sec_hud_set_implants()
	return


/mob/living/carbon/human/sec_hud_set_implants()
	var/image/holder1 = hud_list[IMPTRACK_HUD]
	var/image/holder2 = hud_list[IMPLOYAL_HUD]
	var/image/holder3 = hud_list[IMPCHEM_HUD]

	holder1.icon_state = "hudblank"
	holder2.icon_state = "hudblank"
	holder3.icon_state = "hudblank"

	for(var/obj/item/implant/I in src)
		if(I.implanted)
			if(istype(I, /obj/item/implant/tracking))
				holder1.icon_state = "hud_imp_tracking"
			if(istype(I, /obj/item/implant/loyalty))
				holder2.icon_state = "hud_imp_loyal"
			if(istype(I, /obj/item/implant/chem))
				holder3.icon_state = "hud_imp_chem"


/mob/living/carbon/human/proc/sec_hud_set_security_status()
	var/image/holder = hud_list[WANTED_HUD]
	holder.icon_state = "hudblank"
	var/perpname = name
	if(wear_id)
		var/obj/item/card/id/I = wear_id.GetID()
		if(I)
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
	hud_icons = list(SQUAD_HUD)


/mob/proc/hud_set_squad()
	return


#define SQUAD_HUD_SUPPORTED_SQUAD_JOBS "Squad Leader", "Squad Engineer", "Squad Specialist", "Squad Corpsman", "Squad Smartgunner", "Squad Marine"
#define SQUAD_HUD_SUPPORTED_OTHER_JOBS "Captain", "Executive Officer", "Field Commander", "Intelligence Officer", "Pilot Officer", "Chief Ship Engineer", "Corporate Liaison", "Chief Medical Officer", "Requisitions Officer", "Command Master at Arms", "Tank Crewman", "Medical Officer", "Ship Engineer", "Synthetic", "Master at Arms", "Cargo Technician", "Medical Researcher"

/mob/living/carbon/human/hud_set_squad()
	var/image/holder = hud_list[SQUAD_HUD]
	holder.icon_state = ""
	holder.overlays.Cut()
	
	if(assigned_squad)
		var/squad_color = assigned_squad.color
		var/rank = job
		if(assigned_squad.squad_leader == src)
			rank = "Squad Leader"
		switch(rank)
			if(SQUAD_HUD_SUPPORTED_SQUAD_JOBS)
				var/image/IMG = image('icons/mob/hud.dmi', src, "hudmarine")
				IMG.color = squad_color
				holder.overlays += IMG
				holder.overlays += image('icons/mob/hud.dmi', src, "hudmarine [rank]")
		var/fireteam = wear_id?.assigned_fireteam
		if(fireteam)
			var/image/IMG2 = image('icons/mob/hud.dmi', src, "hudmarinesquadft[fireteam]")
			IMG2.color = squad_color
			holder.overlays += IMG2
	
	else
		switch(job)
			if(SQUAD_HUD_SUPPORTED_OTHER_JOBS)
				holder.icon_state = "hudmarine [job]"
	
	hud_list[SQUAD_HUD] = holder

#undef SQUAD_HUD_SUPPORTED_SQUAD_JOBS
#undef SQUAD_HUD_SUPPORTED_OTHER_JOBS


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


/datum/atom_hud/ai_detector
	hud_icons = list(AI_DETECT_HUD)


/datum/atom_hud/ai_detector/add_hud_to(mob/M)
	. = ..()
	if(M && (length(hudusers) == 1))
		for(var/V in GLOB.aiEyes)
			var/mob/camera/aiEye/E = V
			E.update_ai_detect_hud()