
/obj/machinery/computer/cryopod
	name = "hypersleep bay console"
	desc = "A large console controlling the ship's hypersleep bay. Mainly used for recovery of items from long-term hypersleeping crew."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "cellconsole"
	screen_overlay = "cellconsole_screen"
	circuit = /obj/item/circuitboard/computer/cryopodcontrol
	resistance_flags = RESIST_ALL

/obj/machinery/computer/cryopod/interact(mob/user)
	. = ..()
	if(.)
		return

	if(!SSticker)
		return

	var/dat = "<i>Welcome, [user.name == "Unknown" ? "John Doe" : user.name].</i><br/><br/><hr/>"

	dat += "<b>Recently stored objects</b><br/><hr/><br/>"
	dat +="<table style='text-align:justify'><tr>"
	dat += "<tr></table>"
	dat += "<center><a href='byond://?src=[text_ref(src)];allitems=TRUE'>Dispense All</a></center><br/>"
	for(var/obj/item/I AS in GLOB.cryoed_item_list)
		if(QDELETED(I))
			GLOB.cryoed_item_list -= I
			continue
		dat += "<p style='text-align:left'><a href='byond://?src=[text_ref(src)];item=[text_ref(I)]'>[I.name]</a></p>"
	dat += "<hr/>"

	var/datum/browser/popup = new(user, "cryopod_console", "<div align='center'>Cryogenics</div>")
	popup.set_content(dat)
	popup.open()


/obj/machinery/computer/cryopod/Topic(href, href_list)
	. =..()
	if(.)
		return

	if(href_list["item"])
		var/obj/item/I = locate(href_list["item"]) in GLOB.cryoed_item_list
		dispense_item(I, usr)

	else if(href_list["allitems"])

		if(!length(GLOB.cryoed_item_list))
			to_chat(usr, span_warning("There is nothing to recover from storage."))
			updateUsrDialog()
			return

		visible_message(span_notice("[src] beeps happily as it disgorges the desired objects."))

		for(var/obj/item/I AS in GLOB.cryoed_item_list)
			dispense_item(I, usr, FALSE)

	updateUsrDialog()


/obj/machinery/computer/cryopod/proc/dispense_item(obj/item/I, mob/user, message = TRUE)
	if(!istype(I) || QDELETED(I))
		GLOB.cryoed_item_list -= I
		CRASH("Deleted or erroneous variable ([I]) called for hypersleep inventory retrivial.")
	if(!(I in GLOB.cryoed_item_list))
		if(message)
			to_chat(user, span_warning("[I] is no longer in storage."))
		return
	if(message)
		visible_message(span_notice("[src] beeps happily as it disgorges [I]."))
	I.forceMove(get_turf(src))
	GLOB.cryoed_item_list -= I

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

/obj/structure/cryofeed/middle
	icon_state = "cryo_rear-m"

/obj/structure/cryofeed/Initialize(mapload)
	. = ..()
	if(orient_right)
		icon_state = "cryo_rear[orient_right ? "-r" : ""]"

//Cryopods themselves.
/obj/machinery/cryopod
	name = "hypersleep chamber"
	desc = "A large automated capsule with LED displays intended to put anyone inside into 'hypersleep', a form of non-cryogenic statis used on most ships, linked to a long-term hypersleep bay on a lower level."
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "body_scanner"
	density = TRUE
	anchored = TRUE
	resistance_flags = RESIST_ALL
	light_range = 0.5
	light_power = 0.5
	light_color = LIGHT_COLOR_BLUE
	dir = EAST
	///Person waiting to be taken by ghosts
	var/mob/living/occupant
	///the radio plugged into this pod
	var/obj/item/radio/radio

/obj/machinery/cryopod/right
	dir = WEST

/obj/machinery/cryopod/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.set_frequency(FREQ_COMMON)
	update_icon()
	RegisterSignal(src, COMSIG_MOVABLE_SHUTTLE_CRUSH, PROC_REF(shuttle_crush))

/obj/machinery/cryopod/update_icon()
	. = ..()
	if((machine_stat & (BROKEN|DISABLED|NOPOWER)) || !occupant)
		set_light(0)
	else
		set_light(initial(light_range))

/obj/machinery/cryopod/update_icon_state()
	if(occupant)
		icon_state = "[initial(icon_state)]_occupied"
	else
		icon_state = initial(icon_state)

/obj/machinery/cryopod/update_overlays()
	. = ..()
	if(machine_stat & (BROKEN|DISABLED|NOPOWER))
		return
	if(!occupant)
		return
	. += emissive_appearance(icon, "[icon_state]_emissive", alpha = src.alpha)
	. += mutable_appearance(icon, "[icon_state]_emissive", alpha = src.alpha)

/obj/machinery/cryopod/proc/shuttle_crush()
	SIGNAL_HANDLER
	if(occupant)
		var/mob/living/L = occupant
		go_out()
		L.gib()

/obj/machinery/cryopod/Destroy()
	QDEL_NULL(radio)
	go_out()
	return ..()

///Despawn the mob, remove its job and store its item
/mob/living/proc/despawn()
	//Handle job slot/tater cleanup.
	if(job in SSjob.active_joinable_occupations)
		job.free_job_positions(1)

	for(var/obj/item/W in src)
		W.store_in_cryo()

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

	GLOB.key_to_time_of_role_death[key] = world.time

	ghostize(FALSE) //We want to make sure they are not kicked to lobby.

	qdel(src)

/mob/living/carbon/human/despawn()
	assigned_squad?.remove_from_squad(src)
	return ..()

/obj/item/proc/store_in_cryo()
	if(is_type_in_typecache(src, GLOB.do_not_preserve) || HAS_TRAIT(src, TRAIT_NODROP) || (flags_item & (ITEM_ABSTRACT|DELONDROP)))
		if(!QDELETED(src))
			qdel(src)
		return
	moveToNullspace()
	GLOB.cryoed_item_list += src

/obj/item/storage/store_in_cryo()
	for(var/obj/item/I AS in src)
		I.store_in_cryo()
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

/obj/machinery/cryopod/proc/move_inside_wrapper(mob/living/target, mob/user)
	if(!ishuman(target) || !ishuman(user) || user.incapacitated(TRUE))
		return

	if(!QDELETED(occupant))
		to_chat(user, span_warning("[src] is occupied."))
		return

	climb_in(target, user)

/obj/machinery/cryopod/MouseDrop_T(mob/M, mob/user)
	. = ..()
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
			return FALSE

		helper.visible_message(span_notice("[helper] starts putting [user] into [src]."),
		span_notice("You start putting [user] into [src]."))
	else
		user.visible_message(span_notice("[user] starts climbing into [src]."),
		span_notice("You start climbing into [src]."))

	var/mob/initiator = helper ? helper : user
	if(!do_after(initiator, 20, NONE, user, BUSY_ICON_GENERIC))
		return FALSE

	if(!QDELETED(occupant))
		to_chat(initiator, span_warning("[src] is occupied."))
		return FALSE

	user.forceMove(src)
	occupant = user
	update_icon()
	return TRUE

/obj/machinery/cryopod/proc/go_out()
	if(QDELETED(occupant))
		return

	//Eject any items that aren't meant to be in the pod.
	var/list/items = contents - radio

	for(var/I in items)
		var/atom/movable/A = I
		A.forceMove(get_turf(src))

	occupant = null
	update_icon()

/obj/machinery/cryopod/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	if(!occupant)
		to_chat(X, span_xenowarning("There is nothing of interest in there."))
		return
	if(X.status_flags & INCORPOREAL || X.do_actions)
		return
	visible_message(span_warning("[X] begins to pry the [src]'s cover!"), 3)
	playsound(src,'sound/effects/metal_creaking.ogg', 25, 1)
	if(!do_after(X, 2 SECONDS))
		return
	playsound(loc, 'sound/effects/metal_creaking.ogg', 25, 1)
	go_out()
