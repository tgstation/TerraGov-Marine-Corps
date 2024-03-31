
PROCESSING_SUBSYSTEM_DEF(roguemachine)
	name = "roguemachine"
	wait = 20
	flags = SS_NO_INIT
	priority = 1
	var/list/hermailers = list()
	var/list/cameras = list()
	var/list/scomm_machines = list()
	var/list/stock_machines = list()
	var/hermailermaster
	var/list/death_queue = list()
	var/last_death_report
	var/obj/item/crown

/datum/controller/subsystem/processing/roguemachine/fire(resumed = 0)
	. = ..()
	if(death_queue.len)
		if(world.time > last_death_report + 3 SECONDS)
			last_death_report = world.time
			if(SSroguemachine.hermailermaster)
				var/obj/item/roguemachine/mastermail/X = SSroguemachine.hermailermaster
				for(var/I in death_queue)
					var/obj/item/paper/P = new(X.loc)
					P.mailer = "death witness"
					P.mailedto = "steward of roguetown"
					P.update_icon()
					P.info = I
					var/datum/component/storage/STR = X.GetComponent(/datum/component/storage)
					STR.handle_item_insertion(P, prevent_warning=TRUE)
					X.new_mail=TRUE
					X.update_icon()
				playsound(X, 'sound/misc/hiss.ogg', 100, FALSE, -1)
				var/the_track = 'sound/misc/cas1.ogg'
				if(death_queue.len >= 2)
					the_track = 'sound/misc/cas2.ogg'
				if(death_queue.len >= 5)
					the_track = 'sound/misc/cas3.ogg'
				for(var/mob/M in GLOB.player_list)
					if(is_in_roguetown(M))
						M.playsound_local(M.loc, the_track, 100, FALSE)
				death_queue.Cut()

/proc/is_in_roguetown(atom/A)
	if(!A)
		return
	var/turf/T = get_turf(A)
	if(!T)
		return
	var/area/AR = get_area(T)
	var/list/L = list(/area/rogue/outdoors/town,\
/area/rogue/indoors/town,\
/area/rogue/under/town)
	for(var/X in L)
		if(istype(AR, X))
			return TRUE
#ifdef TESTING
/mob/living/verb/maxzcdec()
	set category = "DEBUGTEST"
	set name = "IsInRoguetown"
	set desc = ""
	if(is_in_roguetown(src))
		to_chat(src, "\n<font color='purple'>IS IN</font>")
	else
		to_chat(src, "\n<font color='purple'>IS NOT IN</font>")
#endif