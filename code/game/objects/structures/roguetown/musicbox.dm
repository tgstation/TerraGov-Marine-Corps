#define MUSIC_TAV list("Song 3" = 'sound/music/jukeboxes/tav3.ogg')

/datum/looping_sound/musloop
	mid_sounds = list()
	mid_length = 99999
	volume = 50
	extra_range = 5
	persistent_loop = TRUE
	var/stress2give = /datum/stressevent/music

/datum/looping_sound/musloop/on_hear_sound(mob/M)
	. = ..()
	if(stress2give)
		if(isliving(M))
			var/mob/living/L = M
			L.add_stress(stress2give)

/client/AllowUpload(filename, filelength)
	if(filelength >= 6485760)
		src << "[filename] TOO BIG. 6 MEGS OR LESS!"
		return 0
	return 1

/obj/structure/roguemachine/musicbox
	name = "wax music device"
	desc = "A marvelous device invented to record sermons. By feeding it the right kind of insects, it now brings us strange music from another realm."
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "music0"
	density = FALSE
	max_integrity = 0
	anchored = TRUE
	var/datum/looping_sound/musloop/soundloop
	var/curfile
	var/playing = FALSE
	var/curvol = 70
	var/list/music_tracks

/obj/structure/roguemachine/musicbox/Initialize()
	soundloop = new(list(src), FALSE)
	music_tracks = MUSIC_TAV
	. = ..()

/obj/structure/roguemachine/musicbox/update_icon()
	icon_state = "music[playing]"

/obj/structure/roguemachine/musicbox/attack_right(mob/user)
	. = ..()
	if(.)
		return
	if(!user.ckey)
		return
	if(playing)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	var/selection = input(user, "Select a song.", "Wax Device") as null|anything in music_tracks
	if(!selection)
		return
	if(!Adjacent(user))
		return
	playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
	playing = FALSE
	soundloop.stop()
	curfile = music_tracks[selection]
	update_icon()


/obj/structure/roguemachine/musicbox/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
	if(!playing)
		if(curfile)
			playing = TRUE
			soundloop.mid_sounds = list(curfile)
			soundloop.cursound = null
			soundloop.volume = curvol
			soundloop.start()
	else
		playing = FALSE
		soundloop.stop()
	update_icon()