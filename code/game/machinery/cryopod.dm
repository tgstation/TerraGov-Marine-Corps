/*
 * Cryogenic refrigeration unit. Basically a despawner.
 * Stealing a lot of concepts/code from sleepers due to massive laziness.
 * The despawn tick will only fire if it's been more than time_till_despawned ticks
 * since time_entered, which is world.time when the occupant moves in.
 * ~ Zuhayr
 */

//Used for logging people entering cryosleep and important items they are carrying.
var/global/list/frozen_crew = list()
var/global/list/frozen_items = list("Alpha"=list(),"Bravo"=list(),"Charlie"=list(),"Delta"=list(),"MP"=list(),"REQ"=list(),"Eng"=list(),"Med"=list())

//Main cryopod console.

/obj/machinery/computer/cryopod
	name = "hypersleep bay console"
	desc = "A large console controlling the ship's hypersleep bay. Most of the options are disabled and locked, although it allows recovery of items from long-term hypersleeping crew."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "cellconsole"
	circuit = "/obj/item/circuitboard/computer/cryopodcontrol"
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
	src.attack_hand()

/obj/machinery/computer/cryopod/attack_ai()
	src.attack_hand()

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
	var/list/frozen_items_for_type = frozen_items[cryotype]

	src.add_fingerprint(user)

	if(href_list["log"])

		var/dat = "<b>Recently stored crewmembers</b><br/><hr/><br/>"
		for(var/person in frozen_crew)
			dat += "[person]<br/>"
		dat += "<hr/>"

		user << browse(dat, "window=cryolog")

	if(href_list["view"])

		var/dat = "<b>Recently stored objects</b><br/><hr/><br/>"
		for(var/obj/item/I in frozen_items_for_type)
			dat += "[I.name]<br/>"
		dat += "<hr/>"

		user << browse(dat, "window=cryoitems")

	else if(href_list["item"])

		if(frozen_items_for_type.len == 0)
			to_chat(user, "<span class='warning'>There is nothing to recover from storage.</span>")
			return

		var/obj/item/I = input(usr, "Please choose which object to retrieve.", "Object recovery",null) as null|anything in frozen_items_for_type
		if(!I)
			return

		if(!(I in frozen_items_for_type))
			to_chat(user, "<span class='warning'>[I] is no longer in storage.</span>")
			return

		visible_message("<span class='notice'>[src] beeps happily as it disgorges [I].</span>")

		I.loc = get_turf(src)
		frozen_items_for_type -= I

	else if(href_list["allitems"])

		if(frozen_items_for_type.len == 0)
			to_chat(user, "<span class='warning'>There is nothing to recover from storage.</span>")
			return

		visible_message("<span class='notice'>[src] beeps happily as it disgorges the desired objects.</span>")

		for(var/obj/item/I in frozen_items_for_type)
			I.loc = get_turf(src)
			frozen_items_for_type -= I

	src.updateUsrDialog()
	return


//Decorative structures to go alongside cryopods.
/obj/structure/cryofeed

	name = "hypersleep chamber feed"
	desc = "A bewildering tangle of machinery and pipes linking the hypersleep chambers to the hypersleep bay.."
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "cryo_rear"
	anchored = 1

	var/orient_right = null //Flips the sprite.

/obj/structure/cryofeed/right
	orient_right = 1
	icon_state = "cryo_rear-r"

/obj/structure/cryofeed/New()

	if(orient_right)
		icon_state = "cryo_rear-r"
	else
		icon_state = "cryo_rear"
	..()

//Cryopods themselves.
/obj/machinery/cryopod
	name = "hypersleep chamber"
	desc = "A large automated capsule with LED displays intended to put anyone inside into 'hypersleep', a form of non-cryogenic statis used on most ships, linked to a long-term hypersleep bay on a lower level."
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "body_scanner_0"
	density = 1
	anchored = 1

	var/mob/living/occupant = null //Person waiting to be despawned.
	var/orient_right = null // Flips the sprite.
	var/time_till_despawn = 6000 //10 minutes-ish safe period before being despawned.
	var/time_entered = 0 //Used to keep track of the safe period.
	var/obj/item/device/radio/intercom/announce //Intercom for cryo announcements

/obj/machinery/cryopod/right
	orient_right = 1
	icon_state = "body_scanner_0-r"

/obj/machinery/cryopod/New()

	announce = new /obj/item/device/radio/intercom(src)

	if(orient_right)
		icon_state = "body_scanner_0-r"
	else
		icon_state = "body_scanner_0"
	..()

//Lifted from Unity stasis.dm and refactored. ~Zuhayr
/obj/machinery/cryopod/process()
	if(occupant)
		//Allow a ten minute gap between entering the pod and actually despawning.
		if(world.time - time_entered < time_till_despawn)
			return

		if(occupant.stat != DEAD) //Occupant is living and has no client.

			//Drop all items into the pod.
			for(var/obj/item/W in occupant)
				occupant.transferItemToLoc(W, src)

			//Delete all items not on the preservation list.

			var/list/items = contents.Copy()
			items -= occupant //Don't delete the occupant
			items -= announce //or the autosay radio.

			var/list/dept_console = frozen_items["REQ"]
			if(ishuman(occupant))
				var/mob/living/carbon/human/H = occupant
				switch(H.job)
					if("Master at Arms","Command Master at Arms")
						dept_console = frozen_items["MP"]
					if("Medical Officer","Medical Researcher","Chief Medical Officer")
						dept_console = frozen_items["Med"]
					if("Ship Engineer","Chief Ship Engineer")
						dept_console = frozen_items["Eng"]

			var/list/deleteempty = list(/obj/item/storage/backpack/marine/satchel)

			var/list/deleteall = list(/obj/item/clothing/mask/cigarette, \
			/obj/item/clothing/glasses/sunglasses, \
			/obj/item/device/pda, \
			/obj/item/clothing/glasses/mgoggles, \
			/obj/item/clothing/head/tgmcberet/red, \
			/obj/item/clothing/gloves/black, \
			/obj/item/weapon/baton, \
			/obj/item/weapon/gun/energy/taser, \
			/obj/item/clothing/glasses/sunglasses/sechud, \
			/obj/item/device/radio/headset/almayer, \
			/obj/item/card/id, \
			/obj/item/clothing/under/marine, \
			/obj/item/clothing/shoes/marine, \
			/obj/item/clothing/head/tgmccap)

			var/list/strippeditems = list()

			item_loop:
				for(var/obj/item/W in items)
					if(W.flags_item & NODROP) //We don't keep undroppable/unremovable items
						if(istype(W, /obj/item/clothing/suit/storage))
							var/obj/item/clothing/suit/storage/SS = W
							for(var/obj/item/I in SS.pockets) //But we keep stuff inside them
								SS.pockets.remove_from_storage(I, loc)
								strippeditems += I
								I.loc = null
						if(istype(W, /obj/item/storage))
							var/obj/item/storage/S = W
							for(var/obj/item/I in S)
								S.remove_from_storage(I, loc)
								strippeditems += I
								I.loc = null
						qdel(W)
						continue


					//special items that store stuff in a nonstandard way, we properly remove those items

					if(istype(W, /obj/item/clothing/suit/storage))
						var/obj/item/clothing/suit/storage/SS = W
						for(var/obj/item/I in SS.pockets)
							SS.pockets.remove_from_storage(I, loc)
							strippeditems += I
							I.loc = null

					if(istype(W, /obj/item/clothing/under))
						var/obj/item/clothing/under/UN = W
						if(UN.hastie)
							var/obj/item/TIE = UN.hastie
							UN.remove_accessory()
							strippeditems += TIE
							TIE.loc = null

					if(istype(W, /obj/item/clothing/shoes/marine))
						var/obj/item/clothing/shoes/marine/MS = W
						if(MS.knife)
							strippeditems += MS.knife
							MS.knife.loc = null
							MS.knife = null



					for(var/TT in deleteempty)
						if(istype(W, TT))
							if(length(W.contents) == 0)
								qdel(W) // delete all the empty satchels
								continue item_loop
							break // not empty, don't delete

					for(var/DA in deleteall)
						if(istype(W, DA))
							qdel(W)
							continue item_loop



					dept_console += W
					W.loc = null

			stripped_items:
				for(var/obj/item/A in strippeditems)
					for(var/DAA in deleteall)
						if(istype(A, DAA))
							qdel(A)
							continue stripped_items

					dept_console += A
					A.loc = null

			if(ishuman(occupant))
				var/mob/living/carbon/human/H = occupant
				if(H.mind && H.assigned_squad)
					var/datum/squad/S = H.assigned_squad
					switch(H.mind.assigned_role)
						if("Squad Engineer")
							S.num_engineers--
						if("Squad Corpsman")
							S.num_medics--
						if("Squad Specialist")
							S.num_specialists--
							if(H.specset && !available_specialist_sets.Find(H.specset))
								available_specialist_sets += H.specset //we make the set this specialist took if any available again

						if("Squad Smartgunner")
							S.num_smartgun--
						if("Squad Leader")
							S.num_leaders--
					S.count--
				H.assigned_squad?.clean_marine_from_squad(H,TRUE) //Remove from squad recods, if any.

			SSticker.mode.latejoin_tally-- //Cryoing someone out removes someone from the Marines, blocking further larva spawns until accounted for

			//Handle job slot/tater cleanup.
			if(occupant.mind?.assigned_role)
				var/datum/job/J = SSjob.name_occupations[occupant.mind.assigned_role]
				J.current_positions--

			//Delete them from datacore.
			if(PDA_Manifest.len)
				PDA_Manifest.Cut()
			for(var/datum/data/record/R in data_core.medical)
				if((R.fields["name"] == occupant.real_name))
					data_core.medical -= R
					qdel(R)
			for(var/datum/data/record/T in data_core.security)
				if((T.fields["name"] == occupant.real_name))
					data_core.security -= T
					qdel(T)
			for(var/datum/data/record/G in data_core.general)
				if((G.fields["name"] == occupant.real_name))
					data_core.general -= G
					qdel(G)

			if(orient_right)
				icon_state = "body_scanner_0-r"
			else
				icon_state = "body_scanner_0"


			occupant.ghostize(0) //We want to make sure they are not kicked to lobby.
			//TODO: Check objectives/mode, update new targets if this mob is the target, spawn new antags?

			//Make an announcement and log the person entering storage.
			frozen_crew += "[occupant.real_name]"

			announce.autosay("[occupant.real_name] has entered long-term hypersleep storage. Belongings moved to hypersleep inventory.", "Hypersleep Storage System")
			visible_message("<span class='notice'>[src] hums and hisses as it moves [occupant.real_name] into hypersleep storage.</span>")

			//Delete the mob.

			qdel(occupant)
			occupant = null
			STOP_PROCESSING(SSmachines, src)


/obj/machinery/cryopod/attackby(obj/item/W, mob/living/user)

	if(istype(W, /obj/item/grab))
		if(isxeno(user)) return
		var/obj/item/grab/G = W
		if(occupant)
			to_chat(user, "<span class='warning'>[src] is occupied.</span>")
			return

		if(!isliving(G.grabbed_thing))
			return

		var/willing = null //We don't want to allow people to be forced into despawning.
		var/mob/living/M = G.grabbed_thing

		if(M.stat == DEAD) //This mob is dead
			to_chat(user, "<span class='warning'>[src] immediately rejects [M]. \He passed away!</span>")
			return

		if(isxeno(M))
			to_chat(user, "<span class='warning'>There is no way [src] will accept [M]!</span>")
			return

		if(M.client)
			if(alert(M,"Would you like to enter cryosleep?", , "Yes", "No") == "Yes")
				if(!M || !G || !G.grabbed_thing) return
				willing = 1
		else
			willing = 1

		if(willing)

			visible_message("<span class='notice'>[user] starts putting [M] into [src].</span>",
			"<span class='notice'>You start putting [M] into [src].</span>")

			if(!do_after(user, 20, TRUE, 5, BUSY_ICON_GENERIC)) return
			if(!M || !G || !G.grabbed_thing) return
			if(occupant)
				to_chat(user, "<span class='warning'>[src] is occupied.</span>")
				return
			M.forceMove(src)
			if(orient_right)
				icon_state = "body_scanner_1-r"
			else
				icon_state = "body_scanner_1"

			to_chat(M, "<span class='notice'>You feel cool air surround you. You go numb as your senses turn inward.</span>")
			to_chat(M, "<span class='boldnotice'>If you ghost, log out or close your client now, your character will shortly be permanently removed from the round.</span>")
			occupant = M
			START_PROCESSING(SSmachines, src)
			time_entered = world.time

			log_admin("[key_name(M)] has entered a stasis pod.")
			message_admins("[ADMIN_TPMONTY(M)] has entered a stasis pod.")

			//Despawning occurs when process() is called with an occupant without a client.
			add_fingerprint(M)

/obj/machinery/cryopod/verb/eject()

	set name = "Eject Pod"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0)
		return

	if(occupant != usr)
		to_chat(usr, "<span class='warning'>You can't drag people out of hypersleep!</span>")
		return

	if(orient_right)
		icon_state = "body_scanner_0-r"
	else
		icon_state = "body_scanner_0"

	//Eject any items that aren't meant to be in the pod.
	var/list/items = src.contents
	if(occupant) items -= occupant
	if(announce) items -= announce

	for(var/obj/item/W in items)
		W.loc = get_turf(src)

	go_out()
	add_fingerprint(usr)
	return

/obj/machinery/cryopod/verb/move_inside()
	set name = "Enter Pod"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != 0 || !(ishuman(usr) || ismonkey(usr)))
		return

	if(occupant)
		to_chat(usr, "<span class='warning'>[src] is occupied.</span>")
		return

	if(isxeno(usr))
		to_chat(usr, "<span class='warning'>There is no way [src] will accept you!</span>")
		return

	usr.visible_message("<span class='notice'>[usr] starts climbing into [src].</span>",
	"<span class='notice'>You start climbing into [src].</span>")

	if(do_after(usr, 20, FALSE, 5, BUSY_ICON_GENERIC))

		if(!usr || !usr.client)
			return

		if(occupant)
			to_chat(usr, "<span class='warning'>[src] is occupied.</span>")
			return

		usr.forceMove(src)
		occupant = usr

		if(orient_right)
			icon_state = "body_scanner_1-r"
		else
			icon_state = "body_scanner_1"

		to_chat(usr, "<span class='notice'>You feel cool air surround you. You go numb as your senses turn inward.</span>")
		to_chat(usr, "<span class='boldnotice'>If you ghost, log out or close your client now, your character will shortly be permanently removed from the round.</span>")
		time_entered = world.time
		START_PROCESSING(SSmachines, src)

		add_fingerprint(usr)

	return

/obj/machinery/cryopod/proc/go_out()

	if(!occupant)
		return

	occupant.forceMove(get_turf(src))
	occupant = null
	STOP_PROCESSING(SSmachines, src)

	if(orient_right)
		icon_state = "body_scanner_0-r"
	else
		icon_state = "body_scanner_0"
