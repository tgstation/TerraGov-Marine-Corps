/datum/event/radiation_storm
	announceWhen	= 1
	oneShot			= 1


/datum/event/radiation_storm/announce()
	// Don't do anything, we want to pack the announcement with the actual event

/datum/event/radiation_storm/start()
	spawn()
		command_announcement.Announce("High levels of radiation have been detected. Report to the Medical Bay if you begin to feel symptoms such as disorientation, nausea, or halucinations.", "Anomaly Alert", new_sound = 'sound/AI/radiation.ogg')
		make_maint_all_access()


		sleep(600)


		command_announcement.Announce("The [station_name()] has entered the radiation belt. Please remain in a sheltered area until it has passed.", "Anomaly Alert")

		for(var/i = 0, i < 10, i++)
			for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
				var/turf/T = get_turf(H)
				if(!T)
					continue
				if(T.z != 3 || T.z != 4)
					continue
				if(istype(T.loc, /area/sulaco/maintenance))
					continue

				if(istype(H,/mob/living/carbon/human))
					H.apply_effect((rand(15,35)),IRRADIATE,0)
					if(prob(5))
						H.apply_effect((rand(40,70)),IRRADIATE,0)
						if (prob(75))
							randmutb(H) // Applies bad mutation
							domutcheck(H,null,MUTCHK_FORCED)
						else
							randmutg(H) // Applies good mutation
							domutcheck(H,null,MUTCHK_FORCED)


			for(var/mob/living/carbon/monkey/M in GLOB.alive_mob_list)
				var/turf/T = get_turf(M)
				if(!T)
					continue
				if(T.z != 3 || T.z != 4)
					continue
				M.apply_effect((rand(5,25)),IRRADIATE,0)
			sleep(100)


		command_announcement.Announce("The [station_name()] has passed the radiation belt. Please report to medbay if you experience any unusual symptoms. Maintenance will lose all access again shortly.", "Anomaly Alert")


		sleep(600) // Want to give them time to get out of maintenance.


		revoke_maint_all_access()
