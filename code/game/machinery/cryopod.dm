/*
 * Cryogenic refrigeration unit. Basically a despawner.
 * Stealing a lot of concepts/code from sleepers due to massive laziness.
 * The despawn tick will only fire if it's been more than time_till_despawned ticks
 * since time_entered, which is world.time when the occupant moves in.
 * ~ Zuhayr
 */

//Main cryopod console.

#define CRYOCONSOLE_MOB_LIST 1
#define CRYOCONSOLE_ITEM_LIST 2

/obj/machinery/computer/cryopod
	name = "hypersleep bay console"
	desc = "A large console controlling the ship's hypersleep bay. Mainly used for recovery of items from long-term hypersleeping crew."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "cellconsole"
	circuit = /obj/item/circuitboard/computer/cryopodcontrol
	exproof = TRUE
	unacidable = TRUE
	var/cryotypes = list(CRYO_REQ, CRYO_ALPHA, CRYO_BRAVO, CRYO_CHARLIE, CRYO_DELTA)
	var/mode = CRYOCONSOLE_ITEM_LIST
	var/category = CRYO_REQ

/obj/machinery/computer/cryopod/medical
	cryotypes = list(CRYO_MED)
	category = CRYO_MED

/obj/machinery/computer/cryopod/brig
	cryotypes = list(CRYO_SEC)
	category = CRYO_SEC

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

/obj/machinery/computer/cryopod/attack_paw()
	attack_hand()

/obj/machinery/computer/cryopod/attack_ai()
	attack_hand()

/obj/machinery/computer/cryopod/attack_hand(mob/user = usr)
	if(machine_stat & (NOPOWER|BROKEN))
		return

	user.set_interaction(src)
	src.add_fingerprint(usr)

	if(!(SSticker))
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
	popup.open(FALSE)
	onclose(user, "cryopod_console")


/obj/machinery/computer/cryopod/Topic(href, href_list)

	. =..()
	if(.)
		return

	usr.set_interaction(src)
	add_fingerprint(usr)

	if(href_list["mode"])
		mode = text2num(href_list["mode"])

	else if(href_list["category"])
		category = href_list["category"]

	else if(href_list["item"])
		var/obj/item/I = locate(href_list["item"]) in GLOB.cryoed_item_list[category]
		dispense_item(I, usr)

	else if(href_list["allitems"])

		if(!length(GLOB.cryoed_item_list[category]))
			to_chat(usr, "<span class='warning'>There is nothing to recover from [category] storage.</span>")
			updateUsrDialog()
			return

		visible_message("<span class='notice'>[src] beeps happily as it disgorges the desired objects.</span>")

		for(var/A in GLOB.cryoed_item_list[category])
			var/obj/item/I = A
			dispense_item(I, usr, FALSE)

	updateUsrDialog()
	return

/obj/machinery/computer/cryopod/proc/dispense_item(obj/item/I, mob/user, message = TRUE)
	if(!istype(I) || QDELETED(I))
		GLOB.cryoed_item_list[category] -= I
		CRASH("Deleted or erroneous variable ([I]) called for hypersleep inventory retrivial.")
	if(!(I in GLOB.cryoed_item_list[category]))
		if(message)
			to_chat(user, "<span class='warning'>[I] is no longer in storage.</span>")
		return
	if(message)
		visible_message("<span class='notice'>[src] beeps happily as it disgorges [I].</span>")
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

/obj/structure/cryofeed/New()
	if(orient_right)
		icon_state = "cryo_rear[orient_right ? "-r" : ""]"
	return ..()

//Cryopods themselves.
/obj/machinery/cryopod
	name = "hypersleep chamber"
	desc = "A large automated capsule with LED displays intended to put anyone inside into 'hypersleep', a form of non-cryogenic statis used on most ships, linked to a long-term hypersleep bay on a lower level."
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "body_scanner_0"
	density = TRUE
	anchored = TRUE

	var/mob/living/occupant //Person waiting to be despawned.
	var/orient_right = FALSE // Flips the sprite.
	var/time_till_despawn = 10 MINUTES
	var/time_entered
	var/obj/item/device/radio/intercom/announce //Intercom for cryo announcements

/obj/machinery/cryopod/right
	orient_right = TRUE
	icon_state = "body_scanner_0-r"

/obj/machinery/cryopod/Initialize()
	. = ..()
	announce = new(src)
	update_icon()

/obj/machinery/cryopod/update_icon()
	var/occupied = occupant ? TRUE : FALSE
	var/mirror = orient_right ? "-r" : ""
	icon_state = "body_scanner_[occupied][mirror]"

/obj/machinery/cryopod/process()
	if(!occupant)
		stop_processing()
		update_icon()
		return

	if(occupant.stat == DEAD) //Occupant is dead, abort.
		go_out()
		return

	//Allow a ten minute gap between entering the pod and actually despawning.
	if(world.time - time_entered < time_till_despawn)
		return

	occupant.despawn(src)
	stop_processing()
	update_icon()

/mob/proc/despawn(obj/machinery/cryopod/pod, dept_console = CRYO_REQ)

	//Handle job slot/tater cleanup.
	if(job)
		var/datum/job/J = SSjob.name_occupations[job]
		J.current_positions--
		if(J.title in JOBS_REGULAR_ALL)
			SSticker.mode.latejoin_tally-- //Cryoing someone removes a player from the round, blocking further larva spawns until accounted for
		if(J.title in JOBS_POLICE)
			dept_console = CRYO_SEC
		else if(J.title in JOBS_MEDICAL)
			dept_console = CRYO_MED
		else if(J.title in JOBS_ENGINEERING)
			dept_console = CRYO_ENGI

	var/list/stored_items = list()
	for(var/obj/item/W in src)
		stored_items.Add(W.store_in_cryo())
	GLOB.cryoed_item_list[dept_console].Add(stored_items)


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

	ghostize(FALSE) //We want to make sure they are not kicked to lobby.

	//Make an announcement and log the person entering storage.
	var/data = num2text(length(GLOB.cryoed_mob_list))
	GLOB.cryoed_mob_list += data
	GLOB.cryoed_mob_list[data] = list(real_name, job ? job : "Unassigned", gameTimestamp())

	pod.announce.autosay("[real_name] has entered long-term hypersleep storage. Belongings moved to hypersleep inventory.", "Hypersleep Storage System")
	pod.visible_message("<span class='notice'>[pod] hums and hisses as it moves [real_name] into hypersleep storage.</span>")
	pod.occupant = null
	qdel(src)

/mob/living/carbon/human/despawn(obj/machinery/cryopod/pod, dept_console = CRYO_REQ)
	if(assigned_squad)
		var/datum/squad/S = assigned_squad
		switch(S.id)
			if(ALPHA_SQUAD)
				dept_console = CRYO_ALPHA
			if(BRAVO_SQUAD)
				dept_console = CRYO_BRAVO
			if(CHARLIE_SQUAD)
				dept_console = CRYO_CHARLIE
			if(DELTA_SQUAD)
				dept_console = CRYO_DELTA
		if(job)
			var/datum/job/J = SSjob.name_occupations[job]
			if(J.flag & SQUAD_ENGINEER)
				S.num_engineers--
			if(J.flag & SQUAD_CORPSMAN)
				S.num_medics--
			if(J.flag & SQUAD_SPECIALIST)
				S.num_specialists--
				if(specset && !available_specialist_sets.Find(specset))
					available_specialist_sets += specset //we make the set this specialist took if any available again
			if(J.flag & SQUAD_SMARTGUNNER)
				S.num_smartgun--
			if(J.flag & SQUAD_LEADER)
				S.num_leaders--
		S.count--
		S.clean_marine_from_squad(src, TRUE) //Remove from squad recods, if any.

	. = ..()

/obj/item/proc/store_in_cryo(list/items)

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
	else
		loc = null
	return items

/obj/item/storage/store_in_cryo(list/items)
	for(var/obj/item/I in src)
		remove_from_storage(I, loc)
		items = I.store_in_cryo(items)
	return ..()

/obj/item/clothing/suit/storage/store_in_cryo(list/items)
	for(var/obj/item/I in pockets)
		pockets.remove_from_storage(I, loc)
		items = I.store_in_cryo(items)
	return ..()

/obj/item/clothing/under/store_in_cryo(list/items)
	if(hastie)
		var/obj/item/TIE = hastie
		remove_accessory()
		items = TIE.store_in_cryo(items)
	return ..()

/obj/item/clothing/shoes/marine/store_in_cryo(list/items)
	if(knife)
		items = knife.store_in_cryo(items)
		knife = null
		update_icon()
	return ..()

/obj/item/clothing/tie/storage/store_in_cryo(list/items)
	for(var/obj/item/I in hold)
		hold.remove_from_storage(I, loc)
		items = I.store_in_cryo(items)
	return ..()

/obj/item/clothing/tie/holster/store_in_cryo(list/items)
	if(holstered)
		items = holstered.store_in_cryo(items)
		holstered = null
		update_icon()

/obj/machinery/cryopod/attackby(obj/item/W, mob/living/user)

	if(istype(W, /obj/item/grab))
		if(isxeno(user))
			return
		var/obj/item/grab/G = W
		if(occupant)
			to_chat(user, "<span class='warning'>[src] is occupied.</span>")
			return

		if(!isliving(G.grabbed_thing))
			return

		var/willing = FALSE //We don't want to allow people to be forced into despawning.
		var/mob/living/M = G.grabbed_thing

		if(M.stat == DEAD) //This mob is dead
			to_chat(user, "<span class='warning'>[src] immediately rejects [M]. \He passed away!</span>")
			return

		if(!(ishuman(M) || ismonkey(M)))
			to_chat(user, "<span class='warning'>There is no way [src] will accept [M]!</span>")
			return

		if(M.client)
			if(alert(M,"Would you like to enter cryosleep?", , "Yes", "No") == "Yes")
				if(!M || !G?.grabbed_thing)
					return
				willing = TRUE
		else
			willing = TRUE

		if(willing)

			visible_message("<span class='notice'>[user] starts putting [M] into [src].</span>",
			"<span class='notice'>You start putting [M] into [src].</span>")

			if(!do_after(user, 20, TRUE, 5, BUSY_ICON_GENERIC))
				return
			if(!M || !G?.grabbed_thing)
				return
			if(occupant)
				to_chat(user, "<span class='warning'>[src] is occupied.</span>")
				return
			M.forceMove(src)
			occupant = M
			update_icon()

			to_chat(M, "<span class='notice'>You feel cool air surround you. You go numb as your senses turn inward.</span>")
			to_chat(M, "<span class='boldnotice'>If you ghost, log out or close your client now, your character will shortly be permanently removed from the round.</span>")
			start_processing()
			time_entered = world.time

			log_admin("[key_name(M)] has entered a stasis pod.")
			message_admins("[ADMIN_TPMONTY(M)] has entered a stasis pod.")

			//Despawning occurs when process() is called with an occupant without a client.
			add_fingerprint(M)

/obj/machinery/cryopod/verb/eject()

	set name = "Eject Pod"
	set category = "Object"
	set src in view(0)

	if(usr.stat != CONSCIOUS || usr.loc != src)
		return

	go_out()
	add_fingerprint(usr)
	return

/obj/machinery/cryopod/verb/move_inside()
	set name = "Enter Pod"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != CONSCIOUS || !(ishuman(usr) || ismonkey(usr)))
		return

	if(occupant)
		to_chat(usr, "<span class='warning'>[src] is occupied.</span>")
		return

	climb_in(usr)

/obj/machinery/cryopod/proc/climb_in(mob/user)
	usr.visible_message("<span class='notice'>[usr] starts climbing into [src].</span>",
	"<span class='notice'>You start climbing into [src].</span>")

	if(!do_after(usr, 20, FALSE, 5, BUSY_ICON_GENERIC))
		return

	if(!usr?.client)
		return

	if(occupant)
		to_chat(usr, "<span class='warning'>[src] is occupied.</span>")
		return

	usr.forceMove(src)
	occupant = usr
	update_icon()

	to_chat(usr, "<span class='notice'>You feel cool air surround you. You go numb as your senses turn inward.</span>")
	to_chat(usr, "<span class='boldnotice'>If you ghost, log out or close your client now, your character will shortly be permanently removed from the round.</span>")
	time_entered = world.time
	start_processing()
	add_fingerprint(usr)

/obj/machinery/cryopod/proc/go_out()

	if(!occupant)
		return

	//Eject any items that aren't meant to be in the pod.
	var/list/items = contents - announce

	for(var/atom/movable/A in items)
		occupant.forceMove(get_turf(src))

	occupant = null
	stop_processing()
	update_icon()

/obj/machinery/cryopod/admin //Invisible admin magic.
	name = "inconspicious bluespace hypersleep chamber."
	desc = "A large automated capsule capable of putting anyone inside into 'hypersleep'. Enough said."
	density = FALSE
	time_till_despawn = 0 SECONDS
	alpha = 0

/obj/machinery/cryopod/admin/Initialize(mapload, mob/victim)
	. = ..()
	if(victim)
		victim.forceMove(src)
		occupant = victim
		victim.despawn(src)
		return INITIALIZE_HINT_QDEL