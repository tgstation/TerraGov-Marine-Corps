/*
 * Cryogenic refrigeration unit. Basically a despawner.
 * Stealing a lot of concepts/code from sleepers due to massive laziness.
 * The despawn tick will only fire if it's been more than time_till_despawned ticks
 * since time_entered, which is world.time when the occupant moves in.
 * ~ Zuhayr
 */

//Main cryopod console.

/obj/machinery/computer/cryopod
	name = "hypersleep bay console"
	desc = "A large console controlling the ship's hypersleep bay. Most of the options are disabled and locked, although it allows recovery of items from long-term hypersleeping crew."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "cellconsole"
	circuit = /obj/item/circuitboard/computer/cryopodcontrol
	exproof = TRUE
	unacidable = TRUE
	var/cryotype = "REQ"
	var/mode = null

/obj/machinery/computer/cryopod/medical
	cryotype = "Med"

/obj/machinery/computer/cryopod/brig
	cryotype = "MP"

/obj/machinery/computer/cryopod/eng
	cryotype = "Eng"

/obj/machinery/computer/cryopod/alpha
	cryotype = "Alpha"

/obj/machinery/computer/cryopod/bravo
	cryotype = "Bravo"

/obj/machinery/computer/cryopod/charlie
	cryotype = "Charlie"

/obj/machinery/computer/cryopod/delta
	cryotype = "Delta"

/obj/machinery/computer/cryopod/attack_paw()
	attack_hand()

/obj/machinery/computer/cryopod/attack_ai()
	attack_hand()

/obj/machinery/computer/cryopod/attack_hand(mob/user = usr)
	if(machine_stat & (NOPOWER|BROKEN))
		return

	user.set_interaction(src)
	src.add_fingerprint(usr)

	var/dat

	if(!(SSticker))
		return

	dat += "<hr/><br/><b>Cryogenic Oversight Control for [cryotype]</b><br/>"
	dat += "<i>Welcome, [user.real_name].</i><br/><br/><hr/>"
	dat += "<a href='?src=\ref[src];log=1'>View storage log</a>.<br>"
	dat += "<a href='?src=\ref[src];view=1'>View objects</a>.<br>"
	dat += "<a href='?src=\ref[src];item=1'>Recover object</a>.<br>"
	dat += "<a href='?src=\ref[src];allitems=1'>Recover all objects</a>.<br>"

	var/datum/browser/popup = new(user, "cryopod_console", "<div align='center'>Cryogenics</div>")
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "cryopod_console")


/obj/machinery/computer/cryopod/Topic(href, href_list)

	//if(..())
	//	return

	var/mob/user = usr
	var/list/stored_items = GLOB.cryoed_item_list[cryotype]
	for(var/obj/item/I in stored_items)
		if(QDELETED(I))
			stored_items -= I

	add_fingerprint(user)

	if(href_list["log"])

		var/dat = "<b>Recently stored crewmembers</b><br/><hr/><br/>"
		for(var/person in GLOB.cryoed_mob_list)
			dat += "[person]<br/>"
		dat += "<hr/>"

		user << browse(dat, "window=cryolog")

	if(href_list["view"])

		var/dat = "<b>Recently stored objects</b><br/><hr/><br/>"
		for(var/obj/item/I in stored_items)
			dat += "[I.name]<br/>"
		dat += "<hr/>"

		user << browse(dat, "window=cryoitems")

	else if(href_list["item"])

		if(!length(stored_items))
			to_chat(user, "<span class='warning'>There is nothing to recover from storage.</span>")
			return

		var/obj/item/I = input(usr, "Please choose which object to retrieve.", "Object recovery",null) as null|anything in stored_items

		dispense_item(I)

	else if(href_list["allitems"])

		if(!length(stored_items))
			to_chat(user, "<span class='warning'>There is nothing to recover from storage.</span>")
			return

		visible_message("<span class='notice'>[src] beeps happily as it disgorges the desired objects.</span>")

		for(var/obj/item/I in stored_items)
			dispense_item(user, I, FALSE)

	updateUsrDialog()
	return

/obj/machinery/computer/cryopod/proc/dispense_item(mob/user, obj/item/I, message = TRUE)
	if(QDELETED(I))
		GLOB.cryoed_item_list[cryotype] -= I
		return
	if(!(I in GLOB.cryoed_item_list[cryotype]))
		if(message)
			to_chat(user, "<span class='warning'>[I] is no longer in storage.</span>")
		return
	if(message)
		visible_message("<span class='notice'>[src] beeps happily as it disgorges [I].</span>")
	I.forceMove(get_turf(src))

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

/obj/machinery/cryopod/New()
	announce = new(src)
	update_icon()
	return ..()

/obj/machinery/cryopod/update_icon()
	var/occupied = occupant ? TRUE : FALSE
	var/mirror = orient_right ? "-r" : ""
	icon_state = "body_scanner_[occupied][mirror]"

//Lifted from Unity stasis.dm and refactored. ~Zuhayr
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

	if(occupant.despawn(src))
		QDEL_NULL(occupant)
	stop_processing()
	update_icon()

/mob/proc/despawn(obj/machinery/cryopod/pod, list/dept_console = GLOB.cryoed_item_list["REQ"])
	var/list/stored_items = list()

	for(var/obj/item/W in contents)
		stored_items.Add(W.store_in_cryo())

	dept_console += stored_items

	SSticker.mode.latejoin_tally-- //Cryoing someone out removes someone from the Marines, blocking further larva spawns until accounted for

	//Handle job slot/tater cleanup.
	var/datum/job/J = job
	J?.current_positions--

	//Delete them from datacore.
	if(length(PDA_Manifest))
		PDA_Manifest.Cut()
	for(var/datum/data/record/R in data_core.medical)
		if((R.fields["name"] == real_name))
			data_core.medical -= R
			qdel(R)
	for(var/datum/data/record/T in data_core.security)
		if((T.fields["name"] == real_name))
			data_core.security -= T
			qdel(T)
	for(var/datum/data/record/G in data_core.general)
		if((G.fields["name"] == real_name))
			data_core.general -= G
			qdel(G)


	ghostize(FALSE) //We want to make sure they are not kicked to lobby.
	//TODO: Check objectives/mode, update new targets if this mob is the target, spawn new antags?

	//Make an announcement and log the person entering storage.
	GLOB.cryoed_mob_list += "[real_name]"

	pod.announce.autosay("[real_name] has entered long-term hypersleep storage. Belongings moved to hypersleep inventory.", "Hypersleep Storage System")
	pod.visible_message("<span class='notice'>[pod] hums and hisses as it moves [real_name] into hypersleep storage.</span>")

	return TRUE //Delete the mob.

/mob/living/carbon/human/despawn(obj/machinery/cryopod/pod, list/dept_console = GLOB.cryoed_item_list["REQ"])
	switch(job)
		if("Master at Arms","Command Master at Arms")
			dept_console = GLOB.cryoed_item_list["MP"]
		if("Medical Officer","Medical Researcher","Chief Medical Officer")
			dept_console = GLOB.cryoed_item_list["Med"]
		if("Ship Engineer","Chief Ship Engineer")
			dept_console = GLOB.cryoed_item_list["Eng"]
		else if(assigned_squad)
			switch(assigned_squad.id)
				if(ALPHA_SQUAD)
					dept_console = GLOB.cryoed_item_list["Alpha"]
				if(BRAVO_SQUAD)
					dept_console = GLOB.cryoed_item_list["Bravo"]
				if(CHARLIE_SQUAD)
					dept_console = GLOB.cryoed_item_list["Charlie"]
				if(DELTA_SQUAD)
					dept_console = GLOB.cryoed_item_list["Delta"]
	if(assigned_squad)
		var/datum/squad/S = assigned_squad
		if(mind)
			switch(mind.assigned_role)
				if("Squad Engineer")
					S.num_engineers--
				if("Squad Corpsman")
					S.num_medics--
				if("Squad Specialist")
					S.num_specialists--
					if(specset && !available_specialist_sets.Find(specset))
						available_specialist_sets += specset //we make the set this specialist took if any available again
				if("Squad Smartgunner")
					S.num_smartgun--
				if("Squad Leader")
					S.num_leaders--
			S.count--
		S.clean_marine_from_squad(src, TRUE) //Remove from squad recods, if any.

	return ..()

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

	usr.visible_message("<span class='notice'>[usr] starts climbing into [src].</span>",
	"<span class='notice'>You start climbing into [src].</span>")

	if(do_after(usr, 20, FALSE, 5, BUSY_ICON_GENERIC))

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
