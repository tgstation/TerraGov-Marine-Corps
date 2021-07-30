#define CRYOCONSOLE_MOB_LIST 1
#define CRYOCONSOLE_ITEM_LIST 2

/obj/machinery/computer/cryopod
	name = "hypersleep bay console"
	desc = "A large console controlling the ship's hypersleep bay. Mainly used for recovery of items from long-term hypersleeping crew."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "cellconsole"
	circuit = /obj/item/circuitboard/computer/cryopodcontrol
	resistance_flags = RESIST_ALL
	var/cryotypes = list(CRYO_REQ, CRYO_ALPHA, CRYO_BRAVO, CRYO_CHARLIE, CRYO_DELTA)
	var/mode = CRYOCONSOLE_ITEM_LIST
	var/category = CRYO_REQ

/obj/machinery/computer/cryopod/medical
	cryotypes = list(CRYO_MED)
	category = CRYO_MED

/obj/machinery/computer/cryopod/eng
	cryotypes = list(CRYO_ENGI)
	category = CRYO_ENGI

/obj/machinery/computer/cryopod/alpha
	cryotypes = list(CRYO_ALPHA)
	category = CRYO_ALPHA

/obj/machinery/computer/cryopod/bravo
	cryotypes = list(CRYO_BRAVO)
	category = CRYO_BRAVO

/obj/machinery/computer/cryopod/charlie
	cryotypes = list(CRYO_CHARLIE)
	category = CRYO_CHARLIE

/obj/machinery/computer/cryopod/delta
	cryotypes = list(CRYO_DELTA)
	category = CRYO_DELTA


/obj/machinery/computer/cryopod/interact(mob/user)
	. = ..()
	if(.)
		return

	if(!SSticker)
		return

	var/dat = "<hr/><br/><b>Cryogenic Oversight Control for [initial(category)]</b><br/>"
	dat += "<i>Welcome, [user.name == "Unknown" ? "John Doe" : user.name].</i><br/><br/><hr/>"
	var/mob_list = mode != CRYOCONSOLE_MOB_LIST ? "<a href='byond://?src=\ref[src];mode=[CRYOCONSOLE_MOB_LIST]'>Cryosleep Logs</a>" : "<b>Cryosleep Logs</b>"
	var/item_list = mode != CRYOCONSOLE_ITEM_LIST ? "<a href='byond://?src=\ref[src];mode=[CRYOCONSOLE_ITEM_LIST]'>Inventory Storage</a>" : "<b>Inventory Storage</b>"
	dat += "<center><table><tr><td><center>[mob_list]</center><td><td><center>[item_list]</center><td><tr><table></center>"

	switch(mode)
		if(CRYOCONSOLE_MOB_LIST)
			dat += "<hr/><b>Recently stored Crewmembers :</b><br/>"
			dat += {"
			<style>
				.cryo {border-collapse: collapse; color:#ffffff}
				.cryo tr:nth-child(even) {color:#f0f0f0}
				.cryo td, th {border:1px solid #666666; padding: 4px}
				.cryo td {text-align: left}
				.cryo th {text-align:center; font-weight: bold}
			</style>
			<table class='cryo' width='100%'>
			<tr><th><b>Name</b></th><th><b>Rank</b></th><th><b>Time</b></th></tr>
			"}
			for(var/data in GLOB.cryoed_mob_list)
				var/list/infos = GLOB.cryoed_mob_list[data]
				if(!istype(infos))
					continue
				var/who = infos[1]
				var/work = infos[2]
				var/when = infos[3]
				dat += "<tr><td>[who]</td><td>[work]</td><td>[when]</td></tr>"
			dat += "</table>"

		if(CRYOCONSOLE_ITEM_LIST)
			dat += "<b>Recently stored objects</b><br/><hr/><br/>"
			dat +="<table style='text-align:justify'><tr>"
			for(var/dept in cryotypes)
				dat += "<th style='border:2px solid #777777'>"
				dat += category != dept ? "<a href='byond://?src=\ref[src];category=[dept]'>[dept]</a>" : "<b>[dept]</b>"
				dat += "<th>"
			dat += "<tr></table>"
			dat += "<center><a href='byond://?src=\ref[src];allitems=TRUE'>Dispense All</a></center><br/>"
			var/list/stored_items = GLOB.cryoed_item_list[category]
			for(var/A in stored_items)
				var/obj/item/I = A
				if(QDELETED(I))
					stored_items -= I
					continue
				dat += "<p style='text-align:left'><a href='byond://?src=\ref[src];item=\ref[I]'>[I.name]</a></p>"
			dat += "<hr/>"

	var/datum/browser/popup = new(user, "cryopod_console", "<div align='center'>Cryogenics</div>")
	popup.set_content(dat)
	popup.open()


/obj/machinery/computer/cryopod/Topic(href, href_list)
	. =..()
	if(.)
		return

	if(href_list["mode"])
		mode = text2num(href_list["mode"])

	else if(href_list["category"])
		category = href_list["category"]

	else if(href_list["item"])
		var/obj/item/I = locate(href_list["item"]) in GLOB.cryoed_item_list[category]
		dispense_item(I, usr)

	else if(href_list["allitems"])

		if(!length(GLOB.cryoed_item_list[category]))
			to_chat(usr, span_warning("There is nothing to recover from [category] storage."))
			updateUsrDialog()
			return

		visible_message(span_notice("[src] beeps happily as it disgorges the desired objects."))

		for(var/A in GLOB.cryoed_item_list[category])
			var/obj/item/I = A
			dispense_item(I, usr, FALSE)

	updateUsrDialog()


/obj/machinery/computer/cryopod/proc/dispense_item(obj/item/I, mob/user, message = TRUE)
	if(!istype(I) || QDELETED(I))
		GLOB.cryoed_item_list[category] -= I
		CRASH("Deleted or erroneous variable ([I]) called for hypersleep inventory retrivial.")
	if(!(I in GLOB.cryoed_item_list[category]))
		if(message)
			to_chat(user, span_warning("[I] is no longer in storage."))
		return
	if(message)
		visible_message(span_notice("[src] beeps happily as it disgorges [I]."))
	I.forceMove(get_turf(src))
	GLOB.cryoed_item_list[category] -= I

#undef CRYOCONSOLE_MOB_LIST
#undef CRYOCONSOLE_ITEM_LIST

//Decorative structures to go alongside cryopods.
/obj/structure/cryofeed
	name = "hypersleep chamber feed"
	desc = "A bewildering tangle of machinery and pipes linking the hypersleep chambers to the hypersleep bay.."
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "cryo_rear"
	anchored = TRUE

	var/orient_right //Flips the sprite.

/obj/structure/cryofeed/right
	orient_right = TRUE
	icon_state = "cryo_rear-r"

/obj/structure/cryofeed/Initialize()
	. = ..()
	if(orient_right)
		icon_state = "cryo_rear[orient_right ? "-r" : ""]"

//Cryopods themselves.
/obj/machinery/cryopod
	name = "hypersleep chamber"
	desc = "A large automated capsule with LED displays intended to put anyone inside into 'hypersleep', a form of non-cryogenic statis used on most ships, linked to a long-term hypersleep bay on a lower level."
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "body_scanner_0"
	density = TRUE
	anchored = TRUE
	resistance_flags = RESIST_ALL

	var/mob/living/occupant //Person waiting to be despawned.
	var/orient_right = FALSE // Flips the sprite.
	var/obj/item/radio/radio
	/// The frequency of the radio
	var/frequency = FREQ_COMMON

/obj/machinery/cryopod/rebel
	frequency = FREQ_COMMON_REBEL

/obj/machinery/cryopod/right
	orient_right = TRUE
	icon_state = "body_scanner_0-r"

/obj/machinery/cryopod/right/rebel
	frequency = FREQ_COMMON_REBEL

/obj/machinery/cryopod/Initialize()
	. = ..()
	radio = new(src)
	radio.set_frequency(frequency)
	update_icon()
	RegisterSignal(src, COMSIG_MOVABLE_SHUTTLE_CRUSH, .proc/shuttle_crush)

/obj/machinery/cryopod/proc/shuttle_crush()
	SIGNAL_HANDLER
	if(occupant)
		var/mob/living/L = occupant
		go_out()
		L.gib()

/obj/machinery/cryopod/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/machinery/cryopod/update_icon()
	var/occupied = occupant ? TRUE : FALSE
	var/mirror = orient_right ? "-r" : ""
	icon_state = "body_scanner_[occupied][mirror]"


/mob/living/proc/despawn(obj/machinery/cryopod/pod, dept_console = CRYO_REQ)

	//Handle job slot/tater cleanup.
	if(job in SSjob.active_joinable_occupations)
		job.free_job_positions(1)
		if(ismedicaljob(job))
			dept_console = CRYO_MED
		else if(isengineeringjob(job))
			dept_console = CRYO_ENGI

	var/list/stored_items = list()
	for(var/obj/item/W in src)
		stored_items.Add(W.store_in_cryo())
	GLOB.cryoed_item_list[dept_console] += stored_items


	for(var/datum/data/record/R in GLOB.datacore.medical)
		if((R.fields["name"] == real_name))
			GLOB.datacore.medical -= R
			qdel(R)
	for(var/datum/data/record/T in GLOB.datacore.security)
		if((T.fields["name"] == real_name))
			GLOB.datacore.security -= T
			qdel(T)
	for(var/datum/data/record/G in GLOB.datacore.general)
		if((G.fields["name"] == real_name))
			GLOB.datacore.general -= G
			qdel(G)

	GLOB.real_names_joined -= real_name

	ghostize(FALSE) //We want to make sure they are not kicked to lobby.

	//Make an announcement and log the person entering storage.
	var/data = num2text(length(GLOB.cryoed_mob_list))
	GLOB.cryoed_mob_list += data
	GLOB.cryoed_mob_list[data] = list(real_name, job ? job.title : "Unassigned", gameTimestamp())

	if(pod)
		pod.visible_message(span_notice("[pod] hums and hisses as it moves [real_name] into hypersleep storage."))
		pod.occupant = null
		pod.update_icon()
		pod.radio.talk_into(pod, "[real_name] has entered long-term hypersleep storage. Belongings moved to hypersleep inventory.", pod.frequency)

	qdel(src)


/mob/living/carbon/human/despawn(obj/machinery/cryopod/pod, dept_console = CRYO_REQ)
	if(assigned_squad)
		switch(assigned_squad.id)
			if(ALPHA_SQUAD)
				dept_console = CRYO_ALPHA
			if(BRAVO_SQUAD)
				dept_console = CRYO_BRAVO
			if(CHARLIE_SQUAD)
				dept_console = CRYO_CHARLIE
			if(DELTA_SQUAD)
				dept_console = CRYO_DELTA
		assigned_squad.remove_from_squad(src)
	return ..()


/obj/item/proc/store_in_cryo(list/items, nullspace_it = TRUE)

	//bandaid for special cases (mob_holders, intellicards etc.) which are NOT currently handled on their own.
	if(locate(/mob) in src)
		forceMove(src, get_turf(src))
		return

	if(is_type_in_typecache(src, GLOB.do_not_preserve))
		qdel(src)
		return

	LAZYADD(items, src)

	if(flags_item & (ITEM_ABSTRACT|NODROP|DELONDROP) || (is_type_in_typecache(src, GLOB.do_not_preserve_empty) && !length(contents)))
		items -= src
		qdel(src)
	else if(nullspace_it)
		moveToNullspace()
	return items

/obj/item/storage/store_in_cryo(list/items, nullspace_it = TRUE)
	for(var/O in src)
		var/obj/item/I = O
		I.store_in_cryo(items, FALSE)
	return ..()

/obj/item/clothing/suit/storage/store_in_cryo(list/items, nullspace_it = TRUE)
	for(var/O in pockets)
		var/obj/item/I = O
		pockets.remove_from_storage(I, loc)
		items = I.store_in_cryo(items)
	return ..()

/obj/item/clothing/under/store_in_cryo(list/items, nullspace_it = TRUE)
	if(hastie)
		var/obj/item/TIE = hastie
		remove_accessory()
		items = TIE.store_in_cryo(items)
	return ..()

/obj/item/clothing/tie/storage/store_in_cryo(list/items, nullspace_it = TRUE)
	for(var/O in hold)
		var/obj/item/I = O
		hold.remove_from_storage(I, loc)
		items = I.store_in_cryo(items)
	return ..()

/obj/machinery/cryopod/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!istype(I, /obj/item/grab))
		return

	else if(isxeno(user))
		return

	var/obj/item/grab/G = I
	if(!isliving(G.grabbed_thing))
		return

	if(!QDELETED(occupant))
		to_chat(user, span_warning("[src] is occupied."))
		return

	var/mob/living/M = G.grabbed_thing

	if(M.stat == DEAD) //This mob is dead
		to_chat(user, span_warning("[src] immediately rejects [M]. [M.p_they(TRUE)] passed away!"))
		return

	if(!ishuman(M))
		to_chat(user, span_warning("There is no way [src] will accept [M]!"))
		return

	if(M.client)
		if(tgui_alert(M, "Would you like to enter cryosleep?", null, list("Yes", "No")) == "Yes")
			if(QDELETED(M) || !(G?.grabbed_thing == M))
				return
		else
			return

	climb_in(M, user)

/obj/machinery/cryopod/verb/eject()
	set name = "Eject Pod"
	set category = "Object"
	set src in view(0)

	if(usr.incapacitated(TRUE) || usr.loc != src)
		return

	go_out()

/obj/machinery/cryopod/relaymove(mob/user)
	if(user.incapacitated(TRUE))
		return
	go_out()

/obj/machinery/cryopod/proc/move_inside_wrapper(mob/living/M, mob/user)
	if(user.stat != CONSCIOUS || !ishuman(M))
		return

	if(!QDELETED(occupant))
		to_chat(user, span_warning("[src] is occupied."))
		return

	climb_in(M, user)

/obj/machinery/cryopod/MouseDrop_T(mob/M, mob/user)
	if(!isliving(M) || !ishuman(user))
		return
	move_inside_wrapper(M, user)

/obj/machinery/cryopod/verb/move_inside()
	set name = "Enter Pod"
	set category = "Object"
	set src in oview(1)

	move_inside_wrapper(usr, usr)

/obj/machinery/cryopod/proc/climb_in(mob/living/carbon/user, mob/helper)
	if(helper && user != helper)
		if(user.stat == DEAD)
			to_chat(helper, span_notice("[user] is dead!"))
			return

		if(!user.client && user.afk_status == MOB_RECENTLY_DISCONNECTED)
			to_chat(helper, span_notice("You should wait another [round((timeleft(user.afk_timer_id) * 0.1) / 60, 2)] minutes before they are ready to enter cryosleep."))
			return

		helper.visible_message(span_notice("[helper] starts putting [user] into [src]."),
		span_notice("You start putting [user] into [src]."))
	else
		user.visible_message(span_notice("[user] starts climbing into [src]."),
		span_notice("You start climbing into [src]."))


	var/mob/initiator = helper ? helper : user
	if(!do_after(initiator, 20, TRUE, user, BUSY_ICON_GENERIC))
		return

	if(!QDELETED(occupant))
		to_chat(initiator, span_warning("[src] is occupied."))
		return

	user.forceMove(src)

	occupant = user
	update_icon()
	log_game("[key_name(user)] has entered a stasis pod.")
	message_admins("[ADMIN_TPMONTY(user)] has entered a stasis pod.")

	RegisterSignal(user, COMSIG_MOB_DEATH, .proc/go_out)

	if(user.afk_status == MOB_DISCONNECTED)
		addtimer(CALLBACK(src, .proc/despawn_mob, user), 5 SECONDS)
		return

	to_chat(user, span_notice("You feel cool air surround you. You go numb as your senses turn inward."))
	to_chat(user, span_boldnotice("If you ghost, log out or close your client now, your character will shortly be permanently removed from the round."))

	RegisterSignal(user, COMSIG_CARBON_SETAFKSTATUS, .proc/on_user_afk_change)


/obj/machinery/cryopod/proc/despawn_mob(mob/living/carbon/user)
	if(QDELETED(user) || user.loc != src)
		return
	user.despawn(src)


/obj/machinery/cryopod/proc/on_user_afk_change(datum/source, new_status, afk_timer)
	SIGNAL_HANDLER
	if(new_status != MOB_DISCONNECTED)
		return
	UnregisterSignal(source, list(COMSIG_CARBON_SETAFKSTATUS, COMSIG_MOB_DEATH))
	var/mob/living/carbon/user = source
	if(user.loc != src)
		stack_trace("[user] disconnected while linked to [src] but without being inside it")
		return
	user.despawn(src)


/obj/machinery/cryopod/proc/go_out()
	SIGNAL_HANDLER
	if(QDELETED(occupant))
		return

	UnregisterSignal(occupant, list(COMSIG_CARBON_SETAFKSTATUS, COMSIG_MOB_DEATH))

	//Eject any items that aren't meant to be in the pod.
	var/list/items = contents - radio

	for(var/I in items)
		var/atom/movable/A = I
		A.forceMove(get_turf(src))

	occupant = null
	update_icon()
