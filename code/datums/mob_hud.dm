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
	MOB_HUD_ORDER = new /datum/mob_hud/order(),
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

//medical hud used by ghosts
/datum/mob_hud/medical/observer
	hud_icons = list(HEALTH_HUD, STATUS_HUD_OBSERVER_INFECTION, STATUS_HUD)


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
	
/datum/mob_hud/order
	hud_icons = list(ORDER_HUD)	




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
		var/amount = round(health * 100 / maxHealth, 10)
		if(!amount)
			amount = 1 //don't want the 'zero health' icon when we still have 4% of our health
		holder.icon_state = "xenohealth[amount]"


/mob/living/carbon/human/med_hud_set_health()
	var/image/holder = hud_list[HEALTH_HUD]
	if(stat == DEAD)
		holder.icon_state = "hudhealth-100"
	else
		var/percentage = round(health*100/species.total_health)
		switch(percentage)
			if(100 to INFINITY) holder.icon_state = "hudhealth100"
			if(90 to 99) holder.icon_state = "hudhealth90"
			if(80 to 89) holder.icon_state = "hudhealth80"
			if(70 to 79) holder.icon_state = "hudhealth70"
			if(60 to 69) holder.icon_state = "hudhealth60"
			if(50 to 59) holder.icon_state = "hudhealth50"
			if(45 to 49) holder.icon_state = "hudhealth45"
			if(40 to 44) holder.icon_state = "hudhealth40"
			if(35 to 39) holder.icon_state = "hudhealth35"
			if(30 to 34) holder.icon_state = "hudhealth30"
			if(25 to 29) holder.icon_state = "hudhealth25"
			if(20 to 24) holder.icon_state = "hudhealth20"
			if(15 to 19) holder.icon_state = "hudhealth15"
			if(10 to 14) holder.icon_state = "hudhealth10"
			if(5 to 9) holder.icon_state = "hudhealth5"
			if(0 to 4) holder.icon_state = "hudhealth0"
			if(-49 to -1) holder.icon_state = "hudhealth-0"
			if(-99 to -50) holder.icon_state = "hudhealth-50"
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
	var/image/holder4 = hud_list[STATUS_HUD_OBSERVER_INFECTION]

	if(species.species_flags & IS_SYNTHETIC)
		holder.icon_state = "hudsynth"
		holder2.icon_state = "hudsynth"
		holder3.icon_state = "hudsynth"
	else
		var/revive_enabled = TRUE
		var/stage = 1
		if(!check_tod() || !is_revivable())
			revive_enabled = FALSE
		else if(!client)
			var/mob/dead/observer/G = get_ghost()
			if(!istype(G))
				revive_enabled = FALSE

		if(stat == DEAD && !undefibbable)
			if((world.time - timeofdeath) > (CONFIG_GET(number/revive_grace_period) * 0.4) && (world.time - timeofdeath) < (CONFIG_GET(number/revive_grace_period) * 0.8))
				stage = 2
			else if((world.time - timeofdeath) > (CONFIG_GET(number/revive_grace_period) * 0.8))
				stage = 3

		var/holder2_set = 0
		if(status_flags & XENO_HOST)
			holder2.icon_state = "hudxeno"//Observer and admin HUD only
			holder2_set = 1
			var/obj/item/alien_embryo/E = locate(/obj/item/alien_embryo) in src
			if(E)
				holder3.icon_state = "infected[E.stage]"
				holder4.icon_state = "infected[E.stage]"
			else if(locate(/mob/living/carbon/Xenomorph/Larva) in src)
				holder.icon_state = "infected5"
				holder4.icon_state = "infected5"
			else
				holder4.icon_state = ""
		else
			holder4.icon_state = ""

		if(stat == DEAD)
			if(revive_enabled)
				holder.icon_state = "huddeaddefib[stage]"
				if(!holder2_set)
					holder2.icon_state = "huddeaddefib[stage]"
					holder3.icon_state = "huddead"
					holder2_set = 1
			else
				holder.icon_state = "huddead"
				holder4.icon_state = ""
				if(!holder2_set || check_tod())
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
	if(!xeno_caste) // usually happens because hud ticks before New() finishes.
		return
	var/image/holder = hud_list[PLASMA_HUD]
	if(stat == DEAD)
		holder.icon_state = "plasma0"
	else
		var/amount = round(plasma_stored * 100 / xeno_caste.plasma_max, 10)
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
			if("Squad Corpsman") marine_rk = "med"
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
	
	
//Order HUD

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
				holder.overlays += image('icons/mob/hud.dmi',src, "hudmoveaura")
			if("hold")
				holder.overlays += image('icons/mob/hud.dmi',src, "hudholdaura")
			if("focus")
				holder.overlays += image('icons/mob/hud.dmi',src, "hudfocusaura")

	hud_list[ORDER_HUD] = holder	
