//This is the proc for gibbing a mob. Cannot gib ghosts.
//added different sort of gibs and animations. N
/mob/proc/gib(anim = "gibbed-m", do_gibs = 1, f_icon = 'icons/mob/mob.dmi')
	death(1)
	monkeyizing = 1
	canmove = 0
	invisibility = 101
	update_canmove()
	dead_mob_list -= src

	var/atom/movable/overlay/animation = new(get_turf(src))
	animation.icon = f_icon
	animation.master = src
	animation.pixel_x = pixel_x

	flick(anim, animation)
	if(do_gibs) gibs(loc, viruses, dna)

	cdel(animation,,13)
	spawn(15) cdel(src)

//This is the proc for turning a mob into ash. Mostly a copy of gib code (above).
//Originally created for wizard disintegrate. I've removed the virus code since it's irrelevant here.
//Dusting robots does not eject the MMI, so it's a bit more powerful than gib() /N
/mob/proc/dust(anim="dust-m",remains=/obj/effect/decal/cleanable/ash)
	death(1)
	var/atom/movable/overlay/animation = null
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src

	flick(anim, animation)
	new remains(loc)

	dead_mob_list -= src
	spawn(15)
		if(animation)	cdel(animation)
		if(src)			cdel(src)


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
		if(hud_used && hud_used.blind_icon)
			hud_used.blind_icon.plane = 0
		client.view = world.view //just so we never get stuck with a large view somehow

	sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO

	drop_r_hand()
	drop_l_hand()

	if(hud_used && hud_used.healths)
		hud_used.healths.icon_state = "health6"

	timeofdeath = world.time
	if(mind) mind.store_memory("Time of death: [worldtime2text()]", 0)
	living_mob_list -= src
	dead_mob_list |= src

	med_hud_set_health()
	med_hud_set_status()

	updateicon()

//This is an expensive proc, let's not fire it on EVERY death. It already gets checked in gamemodes.
//	if(ticker && ticker.mode)
//		ticker.mode.check_win()


	return 1
