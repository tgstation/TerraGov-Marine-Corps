//This is the proc for gibbing a mob. Cannot gib ghosts.
//added different sort of gibs and animations. N
/mob/proc/gib()
	death(1)
	gib_animation()
	spawn_gibs()
	cdel(src)


/mob/proc/gib_animation()
	return

/mob/proc/spawn_gibs()
	hgibs(loc, viruses, dna)





//This is the proc for turning a mob into ash. Mostly a copy of gib code (above).
//Originally created for wizard disintegrate. I've removed the virus code since it's irrelevant here.
//Dusting robots does not eject the MMI, so it's a bit more powerful than gib() /N
/mob/proc/dust()
	death(1)
	dust_animation()
	spawn_dust_remains()
	cdel(src)


/mob/proc/spawn_dust_remains()
	new /obj/effect/decal/cleanable/ash(loc)

/mob/proc/dust_animation()
	return



/mob/proc/death(gibbed,deathmessage="seizes up and falls limp...")

	if(stat == DEAD)
		return 0

	if(!gibbed)
		src.visible_message("<b>\The [src.name]</b> [deathmessage]")

	stat = DEAD

	update_canmove()

	dizziness = 0
	jitteriness = 0

	if(client)
		client.change_view(world.view) //just so we never get stuck with a large view somehow

	hide_fullscreens()

	update_sight()

	drop_r_hand()
	drop_l_hand()

	if(hud_used && hud_used.healths)
		hud_used.healths.icon_state = "health7"

	timeofdeath = world.time
	if(mind) mind.store_memory("Time of death: [worldtime2text()]", 0)
	living_mob_list -= src
	dead_mob_list |= src

	med_hud_set_health()
	med_hud_set_status()

	update_icons()

//This is an expensive proc, let's not fire it on EVERY death. It already gets checked in gamemodes.
//	if(ticker && ticker.mode)
//		ticker.mode.check_win()


	return 1
