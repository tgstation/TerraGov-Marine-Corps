//Refer to life.dm for caller

/*
 * Called by life(), instead of having the individual hud items update icons each tick and check for status changes
 * we only set those statuses and icons upon changes.  Then those HUD items will simply add those pre-made images.
 * This proc below is only called when those HUD elements need to change as determined by the mobs hud_updateflag.
 */

/mob/living/carbon/human/proc/handle_hud_list()
	if(hud_updateflag & 1 << HEALTH_HUD)
		var/image/holder = hud_list[HEALTH_HUD]
		if(stat == DEAD)
			holder.icon_state = "hudhealth-100"
		else
			var/percentage_health = RoundHealth(((0 + health)/species.total_health) * 100)
			holder.icon_state = "hud[percentage_health]"
		hud_list[HEALTH_HUD] = holder

	if(hud_updateflag & 1 << STATUS_HUD)
		var/foundVirus = 0
		for(var/datum/disease/D in viruses)
			if(!D.hidden[SCANNER])
				foundVirus++
		for(var/ID in virus2)
			if(ID in virusDB)
				foundVirus = 1
				break

		var/datum/organ/external/head = get_organ("head")
		var/datum/organ/internal/heart/heart = internal_organs_by_name["heart"]
		var/revive_enabled = 1
		if(world.time - timeofdeath > revive_grace_period)
			revive_enabled = 0
		else
			if(suiciding || !head || !head.is_usable() || !heart || heart.is_broken() || !has_brain() || chestburst || (HUSK in mutations) || !mind)
				revive_enabled = 0

		var/image/holder = hud_list[STATUS_HUD]
		var/image/holder2 = hud_list[STATUS_HUD_OOC]
		if(stat == DEAD)
			if(revive_enabled)
				holder.icon_state = "huddeaddefib"
				holder2.icon_state = "huddeaddefib"
			else
				holder.icon_state = "huddead"
				holder2.icon_state = "huddead"
		else if(status_flags & XENO_HOST)
			holder2.icon_state = "hudxeno" //Observer and admin HUD only
		else if(foundVirus)
			holder.icon_state = "hudill"
		else
			holder.icon_state = "hudhealthy"
			if(virus2.len)
				holder2.icon_state = "hudill"
			else
				holder2.icon_state = "hudhealthy"

		hud_list[STATUS_HUD] = holder
		hud_list[STATUS_HUD_OOC] = holder2

	if(hud_updateflag & 1 << ID_HUD)
		var/image/holder = hud_list[ID_HUD]
		if(wear_id)
			var/obj/item/weapon/card/id/I = wear_id.GetID()
			if(I)
				holder.icon_state = "hud[ckey(I.GetJobName())]"
			else
				holder.icon_state = "hudunknown"
		else
			holder.icon_state = "hudunknown"

		hud_list[ID_HUD] = holder

	if(hud_updateflag & 1 << WANTED_HUD)
		var/image/holder = hud_list[WANTED_HUD]
		holder.icon_state = "hudblank"
		var/perpname = name
		if(wear_id)
			var/obj/item/weapon/card/id/I = wear_id.GetID()
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
					else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Parolled"))
						holder.icon_state = "hudparolled"
						break
					else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Released"))
						holder.icon_state = "hudreleased"
						break
		hud_list[WANTED_HUD] = holder

	if(hud_updateflag & 1 << IMPLOYAL_HUD || hud_updateflag & 1 << IMPCHEM_HUD || hud_updateflag & 1 << IMPTRACK_HUD)
		var/image/holder1 = hud_list[IMPTRACK_HUD]
		var/image/holder2 = hud_list[IMPLOYAL_HUD]
		var/image/holder3 = hud_list[IMPCHEM_HUD]

		holder1.icon_state = "hudblank"
		holder2.icon_state = "hudblank"
		holder3.icon_state = "hudblank"

		for(var/obj/item/weapon/implant/I in src)
			if(I.implanted)
				if(istype(I,/obj/item/weapon/implant/tracking))
					holder1.icon_state = "hud_imp_tracking"
				if(istype(I,/obj/item/weapon/implant/loyalty))
					holder2.icon_state = "hud_imp_loyal"
				if(istype(I,/obj/item/weapon/implant/chem))
					holder3.icon_state = "hud_imp_chem"

		hud_list[IMPTRACK_HUD] = holder1
		hud_list[IMPLOYAL_HUD] = holder2
		hud_list[IMPCHEM_HUD] = holder3

	if(hud_updateflag & 1 << SPECIALROLE_HUD)
		var/image/holder = hud_list[SPECIALROLE_HUD]
		holder.icon_state = "hudblank"

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

			hud_list[SPECIALROLE_HUD] = holder
	hud_updateflag = 0

//Handle flicking the defib icon on dead mobs
//This needs to account for revive time. If we're past that, stop updating FOREVER
/mob/living/carbon/human/proc/handle_defib_flick()

	//One last update, this one is straightforward
	var/image/holder = hud_list[STATUS_HUD]
	var/image/holder2 = hud_list[STATUS_HUD_OOC]
	holder.icon_state = "huddead"
	holder2.icon_state = "huddead"
	hud_list[STATUS_HUD] = holder
	hud_list[STATUS_HUD_OOC] = holder2

	defib_icon_flick = 0 //No more from there on
