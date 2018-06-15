/* HUD DATUMS */

//GLOBAL HUD LIST
var/datum/mob_hud/huds = list(
	MOB_HUD_SECURITY_BASIC = new /datum/mob_hud/security/basic(),
	MOB_HUD_SECURITY_ADVANCED = new /datum/mob_hud/security/advanced(),
	MOB_HUD_MEDICAL_BASIC = new /datum/mob_hud/medical/basic(),
	MOB_HUD_MEDICAL_ADVANCED = new /datum/mob_hud/medical/advanced(),
	MOB_HUD_MEDICAL_OBSERVER = new /datum/mob_hud/medical/observer(),
	MOB_HUD_XENO_INFECTION = new /datum/mob_hud/xeno_infection(), \
	MOB_HUD_XENO_STATUS = new /datum/mob_hud/xeno(),
	MOB_HUD_SQUAD = new /datum/mob_hud/squad(),
	)

/datum/mob_hud
	var/list/mob/hudmobs = list() //list of all mobs which display this hud
	var/list/mob/hudusers = list() //list with all mobs who can see the hud
	var/list/hud_icons = list() //these will be the indexes for the atom's hud_list

/datum/mob_hud/proc/remove_hud_from(mob/user)
	for(var/mob/target in hudmobs)
		remove_from_single_hud(user, target)
	hudusers -= user

/datum/mob_hud/proc/remove_from_hud(mob/target)
	for(var/mob/user in hudusers)
		remove_from_single_hud(user, target)
	hudmobs -= target

/datum/mob_hud/proc/remove_from_single_hud(mob/user, mob/target)
	if(!user.client)
		return
	for(var/i in hud_icons)
		user.client.images -= target.hud_list[i]

/datum/mob_hud/proc/add_hud_to(mob/user)
	hudusers |= user
	for(var/mob/target in hudmobs)
		add_to_single_hud(user, target)

/datum/mob_hud/proc/add_to_hud(mob/target)
	hudmobs |= target
	for(var/mob/user in hudusers)
		add_to_single_hud(user, target)

/datum/mob_hud/proc/add_to_single_hud(mob/user, mob/target)
	if(!user.client)
		return
	for(var/i in hud_icons)
		user.client.images |= target.hud_list[i]




/////// MOB HUD TYPES //////////////////////////////////:


//Medical

/datum/mob_hud/medical
	hud_icons = list(HEALTH_HUD, STATUS_HUD)

//med hud used by silicons, only shows humans with a uniform with sensor mode activated.
/datum/mob_hud/medical/basic

/datum/mob_hud/medical/basic/proc/check_sensors(mob/living/carbon/human/H)
	if(!istype(H)) return 0
	var/obj/item/clothing/under/U = H.w_uniform
	if(!istype(U)) return 0
	if(U.sensor_mode <= 2) return 0
	return 1

/datum/mob_hud/medical/basic/add_to_single_hud(mob/user, mob/target)
	if(check_sensors(user))
		..()

/datum/mob_hud/medical/basic/proc/update_suit_sensors(mob/living/carbon/human/H)
	if(check_sensors(H))
		add_to_hud(H)
	else
		remove_from_hud(H)


//med hud used by medical hud glasses
/datum/mob_hud/medical/advanced

/datum/mob_hud/medical/advanced/add_to_single_hud(mob/user, mob/living/carbon/human/target)
	if(istype(target))
		if(target.species && target.species.name == "Yautja") //so you can't tell a pred's health with hud glasses.
			return
	..()

//medical hud used by ghosts
/datum/mob_hud/medical/observer
	hud_icons = list(HEALTH_HUD, STATUS_HUD_OOC)


//infection status that appears on humans, viewed by xenos only.
/datum/mob_hud/xeno_infection
	hud_icons = list(STATUS_HUD_XENO_INFECTION)



//Xeno status hud, for xenos
/datum/mob_hud/xeno
	hud_icons = list(HEALTH_HUD_XENO, PLASMA_HUD, PHEROMONE_HUD, QUEEN_OVERWATCH_HUD)



//Security

/datum/mob_hud/security

/datum/mob_hud/security/basic
	hud_icons = list(ID_HUD)

/datum/mob_hud/security/advanced
	hud_icons = list(ID_HUD, IMPTRACK_HUD, IMPLOYAL_HUD, IMPCHEM_HUD, WANTED_HUD)


/datum/mob_hud/squad
	hud_icons = list(SQUAD_HUD)




///////// MOB PROCS //////////////////////////////:


/mob/proc/add_to_all_mob_huds()
	return

/mob/living/carbon/human/add_to_all_mob_huds()
	for(var/datum/mob_hud/hud in huds)
		if(istype(hud, /datum/mob_hud/xeno)) //this one is xeno only
			continue
		hud.add_to_hud(src)

/mob/living/carbon/monkey/add_to_all_mob_huds()
	for(var/datum/mob_hud/hud in huds)
		if(!istype(hud, /datum/mob_hud/xeno_infection)) //monkey only appear on this hud
			continue
		hud.add_to_hud(src)

/mob/living/carbon/Xenomorph/add_to_all_mob_huds()
	for(var/datum/mob_hud/hud in huds)
		if(!istype(hud, /datum/mob_hud/xeno))
			continue
		hud.add_to_hud(src)


/mob/proc/remove_from_all_mob_huds()
	return

/mob/living/carbon/human/remove_from_all_mob_huds()
	for(var/datum/mob_hud/hud in huds)
		if(istype(hud, /datum/mob_hud/xeno))
			continue
		hud.remove_from_hud(src)

/mob/living/carbon/monkey/remove_from_all_mob_huds()
	for(var/datum/mob_hud/hud in huds)
		if(!istype(hud, /datum/mob_hud/xeno_infection))
			continue
		hud.add_to_hud(src)

/mob/living/carbon/Xenomorph/remove_from_all_mob_huds()
	for(var/datum/mob_hud/hud in huds)
		if(!istype(hud, /datum/mob_hud/xeno))
			continue
		hud.remove_from_hud(src)




/mob/proc/refresh_huds(mob/source_mob)
	var/mob/M = source_mob ? source_mob : src
	for(var/datum/mob_hud/hud in huds)
		if(M in hud.hudusers)
			readd_hud(hud)

/mob/proc/readd_hud(datum/mob_hud/hud)
	hud.add_hud_to(src)




 //Medical HUDs

//called when a human changes suit sensors
/mob/living/carbon/human/proc/update_suit_sensors()
	var/datum/mob_hud/medical/basic/B = huds[MOB_HUD_MEDICAL_BASIC]
	B.update_suit_sensors(src)

//called when a human changes health
/mob/proc/med_hud_set_health()
	return

/mob/living/carbon/Xenomorph/med_hud_set_health()
	var/image/holder = hud_list[HEALTH_HUD_XENO]
	if(stat == DEAD)
		holder.icon_state = "xenohealth0"
	else
		var/amount = round(health*100/maxHealth, 10)
		if(!amount) amount = 1 //don't want the 'zero health' icon when we still have 4% of our health
		holder.icon_state = "xenohealth[amount]"


/mob/living/carbon/human/med_hud_set_health()
	var/image/holder = hud_list[HEALTH_HUD]
	if(stat == DEAD)
		holder.icon_state = "hudhealth-100"
	else
		var/percentage = round(health*100/species.total_health)
		switch(percentage)
			if(100 to INFINITY) holder.icon_state = "hudhealth100"
			if(85 to 100) holder.icon_state = "hudhealth90"
			if(75 to 85) holder.icon_state = "hudhealth80"
			if(67 to 75) holder.icon_state = "hudhealth70"
			if(63 to 67) holder.icon_state = "hudhealth65"
			if(55 to 63) holder.icon_state = "hudhealth60"
			if(47 to 55) holder.icon_state = "hudhealth50"
			if(43 to 47) holder.icon_state = "hudhealth45"
			if(35 to 43) holder.icon_state = "hudhealth40"
			if(25 to 35) holder.icon_state = "hudhealth30"
			if(17 to 25) holder.icon_state = "hudhealth20"
			if(13 to 17) holder.icon_state = "hudhealth15"
			if(3 to 13) holder.icon_state = "hudhealth10"
			if(0 to 3) holder.icon_state = "hudhealth0"
			if(-99 to 0) holder.icon_state = "hudhealth-0"
			else holder.icon_state = "hudhealth-100"



/mob/proc/med_hud_set_status() //called when mob stat changes, or get a virus/xeno host, etc
	return

/mob/living/carbon/Xenomorph/med_hud_set_status()
	hud_set_plasma()
	hud_set_pheromone()

/mob/living/carbon/monkey/med_hud_set_status()
	var/image/holder = hud_list[STATUS_HUD_XENO_INFECTION]
	if(status_flags & XENO_HOST)
		var/obj/item/alien_embryo/E = locate(/obj/item/alien_embryo) in src
		if(E)
			holder.icon_state = "infected[E.stage]"
		else if(locate(/mob/living/carbon/Xenomorph/Larva) in src)
			holder.icon_state = "infected5"
	else if(stat == DEAD)
		holder.icon_state = "huddead"
	else
		holder.icon_state = ""

/mob/living/carbon/human/med_hud_set_status()
	var/image/holder = hud_list[STATUS_HUD]
	var/image/holder2 = hud_list[STATUS_HUD_OOC]
	var/image/holder3 = hud_list[STATUS_HUD_XENO_INFECTION]

	if(species.flags & IS_SYNTHETIC)
		holder.icon_state = "hudsynth"
		holder2.icon_state = "hudsynth"
		holder3.icon_state = "hudsynth"
	else
		var/datum/limb/head = get_limb("head")
		var/datum/internal_organ/heart/heart = internal_organs_by_name["heart"]
		var/revive_enabled = 1
		if(world.time - timeofdeath > revive_grace_period || undefibbable)
			revive_enabled = 0
		else
			if(suiciding || !head || !head.is_usable() || !heart || heart.is_broken() || !has_brain() || chestburst || (HUSK in mutations) || !mind)
				revive_enabled = 0

		var/holder2_set = 0
		if(status_flags & XENO_HOST)
			holder2.icon_state = "hudxeno"//Observer and admin HUD only
			holder2_set = 1
			var/obj/item/alien_embryo/E = locate(/obj/item/alien_embryo) in src
			if(E)
				holder3.icon_state = "infected[E.stage]"
			else if(locate(/mob/living/carbon/Xenomorph/Larva) in src)
				holder.icon_state = "infected5"

		if(stat == DEAD)
			if(revive_enabled)
				holder.icon_state = "huddeaddefib"
				if(!holder2_set)
					holder2.icon_state = "huddeaddefib"
					holder3.icon_state = "huddead"
					holder2_set = 1
			else
				holder.icon_state = "huddead"
				if(!holder2_set || world.time - timeofdeath > revive_grace_period || undefibbable)
					holder2.icon_state = "huddead"
					holder3.icon_state = "huddead"
					holder2_set = 1

			return


		for(var/datum/disease/D in viruses)
			if(!D.hidden[SCANNER])
				holder.icon_state = "hudill"
				if(!holder2_set)
					holder2.icon_state = "hudill"
				return
		holder.icon_state = "hudhealthy"
		if(!holder2_set)
			holder2.icon_state = "hudhealthy"
			holder3.icon_state = ""




//xeno status HUD

/mob/living/carbon/Xenomorph/proc/hud_set_plasma()
	var/image/holder = hud_list[PLASMA_HUD]
	if(stat == DEAD)
		holder.icon_state = "plasma0"
	else
		var/amount = round(plasma_stored * 100 / plasma_max, 10)
		holder.icon_state = "plasma[amount]"


/mob/living/carbon/Xenomorph/proc/hud_set_pheromone()
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
				holder.overlays += image('icons/mob/hud.dmi',src, "hudaurafrenzy")
			if("recovery")
				holder.overlays += image('icons/mob/hud.dmi',src, "hudaurarecovery")
			if("warding")
				holder.overlays += image('icons/mob/hud.dmi',src, "hudaurawarding")

		switch(leader_current_aura)
			if("frenzy")
				holder.overlays += image('icons/mob/hud.dmi',src, "hudaurafrenzy")
			if("recovery")
				holder.overlays += image('icons/mob/hud.dmi',src, "hudaurarecovery")
			if("warding")
				holder.overlays += image('icons/mob/hud.dmi',src, "hudaurawarding")

	hud_list[PHEROMONE_HUD] = holder


/mob/living/carbon/Xenomorph/proc/hud_set_queen_overwatch()
	var/image/holder = hud_list[QUEEN_OVERWATCH_HUD]
	holder.overlays.Cut()
	holder.icon_state = "hudblank"
	if(stat != DEAD)
		if(hivenumber && hivenumber <= hive_datum.len)
			var/datum/hive_status/hive = hive_datum[hivenumber]
			if(hive.living_xeno_queen)
				if(hive.living_xeno_queen.observed_xeno == src)
					holder.icon_state = "queen_overwatch"
				if(queen_chosen_lead)
					var/image/I = image('icons/mob/hud.dmi',src, "hudxenoleader")
					holder.overlays += I
		if(upgrade)
			var/image/J = image('icons/mob/hud.dmi',src, "hudxenoupgrade[upgrade]")
			holder.overlays += J
	hud_list[QUEEN_OVERWATCH_HUD] = holder



//Sec HUDs

/mob/living/carbon/proc/sec_hud_set_ID()
	return

/mob/living/carbon/human/sec_hud_set_ID()
	var/image/holder = hud_list[ID_HUD]
	holder.icon_state = "hudunknown"
	if(wear_id)
		var/obj/item/card/id/I = wear_id.GetID()
		if(I)
			holder.icon_state = "hud[ckey(I.GetJobName())]"



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
			if(istype(I,/obj/item/implant/tracking))
				holder1.icon_state = "hud_imp_tracking"
			if(istype(I,/obj/item/implant/loyalty))
				holder2.icon_state = "hud_imp_loyal"
			if(istype(I,/obj/item/implant/chem))
				holder3.icon_state = "hud_imp_chem"

/mob/living/carbon/human/proc/sec_hud_set_security_status()
	var/image/holder = hud_list[WANTED_HUD]
	holder.icon_state = "hudblank"
	var/perpname = name
	if(wear_id)
		var/obj/item/card/id/I = wear_id.GetID()
		if(I)
			perpname = I.registered_name

	for(var/datum/data/record/E in data_core.general)
		if(E.fields["name"] == perpname)
			for(var/datum/data/record/R in data_core.security)
				if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
					holder.icon_state = "hudwanted"
					break
				else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Incarcerated"))
					holder.icon_state = "hudprisoner"
					break
				else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Released"))
					holder.icon_state = "hudreleased"
					break



//Special role HUD

/mob/proc/hud_set_special_role()
	return

/mob/living/carbon/human/hud_set_special_role()
	var/image/holder = hud_list[SPECIALROLE_HUD]
	holder.icon_state = ""

	if(mind)
		switch(mind.special_role)
			if("traitor", "Syndicate")
				holder.icon_state = "hudsyndicate"
			if("Revolutionary")
				holder.icon_state = "hudrevolutionary"
			if("Head Revolutionary")
				holder.icon_state = "hudheadrevolutionary"
			if("Cultist")
				holder.icon_state = "hudcultist"
			if("Changeling")
				holder.icon_state = "hudchangeling"
			if("Wizard", "Fake Wizard")
				holder.icon_state = "hudwizard"
			if("Death Commando")
				holder.icon_state = "huddeathsquad"
			if("Ninja")
				holder.icon_state = "hudninja"
			if("head_loyalist")
				holder.icon_state = "hudloyalist"
			if("loyalist")
				holder.icon_state = "hudloyalist"
			if("head_mutineer")
				holder.icon_state = "hudmutineer"
			if("mutineer")
				holder.icon_state = "hudmutineer"





//Squad HUD

/mob/proc/hud_set_squad()
	return

/mob/living/carbon/human/hud_set_squad()
	var/image/holder = hud_list[SQUAD_HUD]
	holder.icon_state = "hudblank"
	holder.overlays.Cut()
	if(assigned_squad)
		var/squad_clr = squad_colors[assigned_squad.color]
		var/marine_rk
		var/obj/item/card/id/I = get_idcard()
		var/_role
		if(mind)
			_role = mind.assigned_role
		else if(I)
			_role = I.rank
		switch(_role)
			if("Squad Engineer") marine_rk = "engi"
			if("Squad Specialist") marine_rk = "spec"
			if("Squad Medic") marine_rk = "med"
			if("Squad Smartgunner") marine_rk = "gun"
		if(assigned_squad.squad_leader == src)
			marine_rk = "leader"
		if(marine_rk)
			var/image/IMG = image('icons/mob/hud.dmi',src, "hudmarinesquad")
			IMG.color = squad_clr
			holder.overlays += IMG
			holder.overlays += image('icons/mob/hud.dmi',src, "hudmarinesquad[marine_rk]")
		if(I && I.assigned_fireteam)
			var/image/IMG2 = image('icons/mob/hud.dmi',src, "hudmarinesquadft[I.assigned_fireteam]")
			IMG2.color = squad_clr
			holder.overlays += IMG2
	hud_list[SQUAD_HUD] = holder
