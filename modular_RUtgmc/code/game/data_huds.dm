/mob/living/carbon/human/med_hud_set_status()
	var/image/status_hud = hud_list[STATUS_HUD] //Status for med-hud.
	var/image/infection_hud = hud_list[XENO_EMBRYO_HUD] //State of the xeno embryo.
	var/image/simple_status_hud = hud_list[STATUS_HUD_SIMPLE] //Status for the naked eye.
	var/image/xeno_reagent = hud_list[XENO_REAGENT_HUD] // Displays active xeno reagents
	var/image/xeno_debuff = hud_list[XENO_DEBUFF_HUD] //Displays active xeno specific debuffs
	var/static/image/medicalnanites_high_image = image('icons/mob/hud.dmi', icon_state = "nanites")
	var/static/image/medicalnanites_medium_image = image('icons/mob/hud.dmi', icon_state = "nanites_medium")
	var/static/image/medicalnanites_low_image = image('icons/mob/hud.dmi', icon_state = "nanites_low")
	var/obj/item/radio/headset/mainship/headset = wear_ear

	if(stat != DEAD)
		var/medicalnanites_amount = reagents.get_reagent_amount(/datum/reagent/medicine/research/medicalnanites)
		if(medicalnanites_amount > 25)
			xeno_reagent.overlays += medicalnanites_high_image
		else if(medicalnanites_amount > 15)
			xeno_reagent.overlays += medicalnanites_medium_image
		else if(medicalnanites_amount > 0)
			xeno_reagent.overlays += medicalnanites_low_image

	if(species.species_flags & IS_SYNTHETIC)
		simple_status_hud.icon_state = ""
		if(stat != DEAD)
			status_hud.icon_state = "hudsynth"
		else
			if(!client)
				var/mob/dead/observer/G = get_ghost(FALSE, TRUE)
				if(!G)
					status_hud.icon_state = "hudsynthdnr"
					if(istype(wear_ear, /obj/item/radio/headset/mainship))
						headset.update_minimap_icon()
				else
					status_hud.icon_state = "hudsynthdead"
					if(istype(wear_ear, /obj/item/radio/headset/mainship))
						headset.update_minimap_icon()
			return
		infection_hud.icon_state = "hudsynth" //Xenos can feel synths are not human.
		return TRUE

	if(species.species_flags & ROBOTIC_LIMBS)
		simple_status_hud.icon_state = ""
		if(stat != DEAD)
			status_hud.icon_state = "hudrobot"
		else
			if(!client) //роботы бесконечно дефибаббл
				var/mob/dead/observer/G = get_ghost(FALSE, TRUE)
				if(!G)
					status_hud.icon_state = "hudrobotdnr"
					if(istype(wear_ear, /obj/item/radio/headset/mainship))
						headset.update_minimap_icon()
				else
					status_hud.icon_state = "hudrobotdead"
					if(istype(wear_ear, /obj/item/radio/headset/mainship))
						headset.update_minimap_icon()
			return
		infection_hud.icon_state = "hudrobot"
		return TRUE

	if(species.species_flags & HEALTH_HUD_ALWAYS_DEAD)
		status_hud.icon_state = "huddeaddefib4"
		infection_hud.icon_state = ""
		simple_status_hud.icon_state = ""
		return TRUE

	switch(stat)
		if(DEAD)
			simple_status_hud.icon_state = ""
			infection_hud.icon_state = "huddeaddefib4"
			if(istype(wear_ear, /obj/item/radio/headset/mainship))
				headset.update_minimap_icon()
			if(!HAS_TRAIT(src, TRAIT_PSY_DRAINED))
				infection_hud.icon_state = "psy_drain"
			if(HAS_TRAIT(src, TRAIT_UNDEFIBBABLE ))
				hud_list[HEART_STATUS_HUD].icon_state = "still_heart"
				status_hud.icon_state = "huddeaddefib4"
				if(istype(wear_ear, /obj/item/radio/headset/mainship))
					headset.update_minimap_icon()
				return TRUE
			if(!client)
				var/mob/dead/observer/ghost = get_ghost()
				if(!ghost?.can_reenter_corpse)
					status_hud.icon_state = "huddeaddefib4"
					if(istype(wear_ear, /obj/item/radio/headset/mainship))
						headset.update_minimap_icon()
					return TRUE
			var/stage
			switch(dead_ticks)
				if(0 to 0.4 * TIME_BEFORE_DNR)
					stage = 1
					if(istype(wear_ear, /obj/item/radio/headset/mainship))
						headset.update_minimap_icon()
				if(0.4 * TIME_BEFORE_DNR to 0.8 * TIME_BEFORE_DNR)
					stage = 2
					if(istype(wear_ear, /obj/item/radio/headset/mainship))
						headset.update_minimap_icon()
				if(0.8 * TIME_BEFORE_DNR to INFINITY)
					stage = 3
					if(istype(wear_ear, /obj/item/radio/headset/mainship))
						headset.update_minimap_icon()
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
				simple_status_hud.icon_state = ""
				status_hud.icon_state = "hudhealthy"
				return TRUE

//medical hud used by ghosts
/datum/atom_hud/medical/observer
	hud_icons = list(HEALTH_HUD, XENO_EMBRYO_HUD, XENO_REAGENT_HUD, XENO_DEBUFF_HUD, STATUS_HUD, MACHINE_HEALTH_HUD, MACHINE_AMMO_HUD, XENO_BANISHED_HUD)

//Xeno status hud, for xenos
/datum/atom_hud/xeno
	hud_icons = list(HEALTH_HUD_XENO, PLASMA_HUD, PHEROMONE_HUD, QUEEN_OVERWATCH_HUD, ARMOR_SUNDER_HUD, XENO_FIRE_HUD, XENO_BANISHED_HUD)

/mob/living/carbon/xenomorph/proc/hud_set_banished()
	var/image/holder = hud_list[XENO_BANISHED_HUD]
	holder.overlays.Cut()
	holder.icon_state = "hudblank"
	if (stat != DEAD && HAS_TRAIT(src, TRAIT_BANISHED))
		holder.icon_state = "xeno_banished"
	holder.pixel_x = -4
	holder.pixel_y = -6
