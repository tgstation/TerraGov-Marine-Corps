#define STATE_GUN 0
#define STATE_AMMO 1
#define STATE_EXPLOSIVE 2
#define STATE_MELEE 4
#define STATE_CLOTHING 5
#define STATE_FOOD 6
#define STATE_DRUGS 7
#define STATE_CONTAINERS 8
#define STATE_OTHER 9

/obj/machinery/computer/cryopod
	name = "hypersleep bay console"
	desc = "A large console controlling the ship's hypersleep bay. Mainly used for recovery of items from long-term hypersleeping crew."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "cellconsole"
	screen_overlay = "cellconsole_screen"
	circuit = /obj/item/circuitboard/computer/cryopodcontrol
	resistance_flags = RESIST_ALL
	var/state = STATE_GUN

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
	dat += "<a href='byond://?src=[text_ref(src)];operation=gun'>Guns</a><br>"
	dat += "<a href='byond://?src=[text_ref(src)];operation=ammo'>Ammo</a><br>"
	dat += "<a href='byond://?src=[text_ref(src)];operation=explosive'>Explosives</a><br>"
	dat += "<a href='byond://?src=[text_ref(src)];operation=melee'>Melee</a><br>"
	dat += "<a href='byond://?src=[text_ref(src)];operation=clothing'>Clothing</a><br>"
	dat += "<a href='byond://?src=[text_ref(src)];operation=food'>Food</a><br>"
	dat += "<a href='byond://?src=[text_ref(src)];operation=drug'>Drugs</a><br>"
	dat += "<a href='byond://?src=[text_ref(src)];operation=container'>Containers</a><br>"
	dat += "<a href='byond://?src=[text_ref(src)];operation=other'>Other</a><br>"
	dat += "<hr/>"

	switch(state)
		if(STATE_GUN)
			dat += "<center>Guns</center><br/>"
			for(var/obj/item/I in GLOB.cryoed_item_list_gun)
				if(QDELETED(I))
					GLOB.cryoed_item_list_gun -= I
					continue
				dat += "<p style='text-align:left'><a href='byond://?src=[text_ref(src)];item=[text_ref(I)]'>[I.name]</a></p>"
		if(STATE_AMMO)
			dat += "<center>Ammo</center><br/>"
			for(var/obj/item/I in GLOB.cryoed_item_list_ammo)
				if(QDELETED(I))
					GLOB.cryoed_item_list_ammo -= I
					continue
				dat += "<p style='text-align:left'><a href='byond://?src=[text_ref(src)];item=[text_ref(I)]'>[I.name]</a></p>"
		if(STATE_EXPLOSIVE)
			dat += "<center>Explosives</center><br/>"
			for(var/obj/item/I in GLOB.cryoed_item_list_explosive)
				if(QDELETED(I))
					GLOB.cryoed_item_list_explosive -= I
					continue
				dat += "<p style='text-align:left'><a href='byond://?src=[text_ref(src)];item=[text_ref(I)]'>[I.name]</a></p>"
		if(STATE_MELEE)
			dat += "<center>Melee</center><br/>"
			for(var/obj/item/I in GLOB.cryoed_item_list_melee)
				if(QDELETED(I))
					GLOB.cryoed_item_list_melee -= I
					continue
				dat += "<p style='text-align:left'><a href='byond://?src=[text_ref(src)];item=[text_ref(I)]'>[I.name]</a></p>"
		if(STATE_CLOTHING)
			dat += "<center>Clothing</center><br/>"
			for(var/obj/item/I in GLOB.cryoed_item_list_clothing)
				if(QDELETED(I))
					GLOB.cryoed_item_list_clothing -= I
					continue
				dat += "<p style='text-align:left'><a href='byond://?src=[text_ref(src)];item=[text_ref(I)]'>[I.name]</a></p>"
		if(STATE_FOOD)
			dat += "<center>Food</center><br/>"
			for(var/obj/item/I in GLOB.cryoed_item_list_food)
				if(QDELETED(I))
					GLOB.cryoed_item_list_food -= I
					continue
				dat += "<p style='text-align:left'><a href='byond://?src=[text_ref(src)];item=[text_ref(I)]'>[I.name]</a></p>"
		if(STATE_DRUGS)
			dat += "<center>Drugs</center><br/>"
			for(var/obj/item/I in GLOB.cryoed_item_list_drugs)
				if(QDELETED(I))
					GLOB.cryoed_item_list_drugs -= I
					continue
				dat += "<p style='text-align:left'><a href='byond://?src=[text_ref(src)];item=[text_ref(I)]'>[I.name]</a></p>"
		if(STATE_CONTAINERS)
			dat += "<center>Containers</center><br/>"
			for(var/obj/item/I in GLOB.cryoed_item_list_containers)
				if(QDELETED(I))
					GLOB.cryoed_item_list_containers -= I
					continue
				dat += "<p style='text-align:left'><a href='byond://?src=[text_ref(src)];item=[text_ref(I)]'>[I.name]</a></p>"
		if(STATE_OTHER)
			dat += "<center>Other</center><br/>"
			for(var/obj/item/I in GLOB.cryoed_item_list_other)
				if(QDELETED(I))
					GLOB.cryoed_item_list_other -= I
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

	switch(href_list["operation"])
		if("gun")
			state = STATE_GUN
		if("ammo")
			state = STATE_AMMO
		if("explosive")
			state = STATE_EXPLOSIVE
		if("melee")
			state = STATE_MELEE
		if("clothing")
			state = STATE_CLOTHING
		if("food")
			state = STATE_FOOD
		if("drug")
			state = STATE_DRUGS
		if("container")
			state = STATE_CONTAINERS
		if("other")
			state = STATE_OTHER
	updateUsrDialog()

	if(href_list["item"])
		var/obj/item/I
		switch(state)
			if(STATE_GUN)
				I = locate(href_list["item"]) in GLOB.cryoed_item_list_gun
			if(STATE_AMMO)
				I = locate(href_list["item"]) in GLOB.cryoed_item_list_ammo
			if(STATE_EXPLOSIVE)
				I = locate(href_list["item"]) in GLOB.cryoed_item_list_explosive
			if(STATE_MELEE)
				I = locate(href_list["item"]) in GLOB.cryoed_item_list_melee
			if(STATE_CLOTHING)
				I = locate(href_list["item"]) in GLOB.cryoed_item_list_clothing
			if(STATE_FOOD)
				I = locate(href_list["item"]) in GLOB.cryoed_item_list_food
			if(STATE_DRUGS)
				I = locate(href_list["item"]) in GLOB.cryoed_item_list_drugs
			if(STATE_CONTAINERS)
				I = locate(href_list["item"]) in GLOB.cryoed_item_list_containers
			if(STATE_OTHER)
				I = locate(href_list["item"]) in GLOB.cryoed_item_list_other
		dispense_item(I, usr)

	else if(href_list["allitems"])

		if(!length(GLOB.cryoed_item_list_gun) && !length(GLOB.cryoed_item_list_ammo) && !length(GLOB.cryoed_item_list_explosive) && !length(GLOB.cryoed_item_list_melee) && !length(GLOB.cryoed_item_list_clothing) && !length(GLOB.cryoed_item_list_food) && !length(GLOB.cryoed_item_list_drugs) && !length(GLOB.cryoed_item_list_containers) && !length(GLOB.cryoed_item_list_other))
			to_chat(usr, span_warning("There is nothing to recover from storage."))
			updateUsrDialog()
			return

		visible_message(span_notice("[src] beeps happily as it disgorges the desired objects."))

		var/list/combined_list
		switch(state)
			if(STATE_GUN)
				combined_list = GLOB.cryoed_item_list_gun
			if(STATE_AMMO)
				combined_list = GLOB.cryoed_item_list_ammo
			if(STATE_EXPLOSIVE)
				combined_list = GLOB.cryoed_item_list_explosive
			if(STATE_MELEE)
				combined_list = GLOB.cryoed_item_list_melee
			if(STATE_CLOTHING)
				combined_list = GLOB.cryoed_item_list_clothing
			if(STATE_FOOD)
				combined_list = GLOB.cryoed_item_list_food
			if(STATE_DRUGS)
				combined_list = GLOB.cryoed_item_list_drugs
			if(STATE_CONTAINERS)
				combined_list = GLOB.cryoed_item_list_containers
			if(STATE_OTHER)
				combined_list = GLOB.cryoed_item_list_other
		for(var/obj/item/I in combined_list)
			dispense_item(I, usr, FALSE)

	updateUsrDialog()


/obj/machinery/computer/cryopod/proc/dispense_item(obj/item/I, mob/user, message = TRUE)
	if(!istype(I) || QDELETED(I))
		GLOB.cryoed_item_list_gun -= I;
		GLOB.cryoed_item_list_ammo -= I;
		GLOB.cryoed_item_list_explosive -= I;
		GLOB.cryoed_item_list_melee -= I;
		GLOB.cryoed_item_list_clothing -= I;
		GLOB.cryoed_item_list_food -= I;
		GLOB.cryoed_item_list_drugs -= I;
		GLOB.cryoed_item_list_containers -= I;
		GLOB.cryoed_item_list_other -= I;
		CRASH("Deleted or erroneous variable ([I]) called for hypersleep inventory retrivial.")
	if((!I) in (GLOB.cryoed_item_list_gun || GLOB.cryoed_item_list_ammo || GLOB.cryoed_item_list_explosive || GLOB.cryoed_item_list_melee || GLOB.cryoed_item_list_clothing || GLOB.cryoed_item_list_food || GLOB.cryoed_item_list_drugs || GLOB.cryoed_item_list_containers || GLOB.cryoed_item_list_other))
		if(message)
			to_chat(user, span_warning("[I] is no longer in storage."))
		return
	if(message)
		visible_message(span_notice("[src] beeps happily as it disgorges [I]."))
	I.forceMove(get_turf(src))
	// For when we have south and north facing sprites.
	// I.forceMove(get_step(loc, dir))

	GLOB.cryoed_item_list_gun -= I;
	GLOB.cryoed_item_list_ammo -= I;
	GLOB.cryoed_item_list_explosive -= I;
	GLOB.cryoed_item_list_melee -= I;
	GLOB.cryoed_item_list_clothing -= I;
	GLOB.cryoed_item_list_food -= I;
	GLOB.cryoed_item_list_drugs -= I;
	GLOB.cryoed_item_list_containers -= I;
	GLOB.cryoed_item_list_other -= I;

//Decorative structures to go alongside cryopods.
/obj/structure/cryofeed
	name = "hypersleep chamber feed"
	desc = "A bewildering tangle of machinery and pipes linking the hypersleep chambers to the hypersleep bay.."
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "cryo_rear"
	layer = LOW_OBJ_LAYER
	plane = FLOOR_PLANE
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
	. = ..()
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
	. += emissive_appearance(icon, "[icon_state]_emissive", src, alpha = src.alpha)
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
	if(is_type_in_typecache(src, GLOB.do_not_preserve) || HAS_TRAIT(src, TRAIT_NODROP) || (item_flags & (ITEM_ABSTRACT|DELONDROP)))
		if(!QDELETED(src))
			qdel(src)
		return
	if(storage_datum)
		for(var/obj/item/item_in_storage AS in src)
			storage_datum.remove_from_storage(item_in_storage)
			item_in_storage.store_in_cryo()
	moveToNullspace()
	if(istype(src, /obj/item/weapon/gun))
		GLOB.cryoed_item_list_gun += src
	else if(istype(src, /obj/item/ammo_magazine))
		GLOB.cryoed_item_list_ammo += src
	else if(istype(src, /obj/item/explosive))
		GLOB.cryoed_item_list_explosive += src
	else if(istype(src, /obj/item/weapon))
		GLOB.cryoed_item_list_melee += src
	else if(istype(src, /obj/item/clothing))
		GLOB.cryoed_item_list_clothing += src
	else if(isfood(src))
		GLOB.cryoed_item_list_food += src
	else if(istype(src, /obj/item/reagent_containers/hypospray) || istype(src, /obj/item/reagent_containers/syringe) || istype(src, /obj/item/reagent_containers/pill))
		GLOB.cryoed_item_list_drugs += src
	else if(istype(src, /obj/item/storage))
		GLOB.cryoed_item_list_containers += src
	else
		GLOB.cryoed_item_list_other += src

/obj/machinery/cryopod/grab_interact(obj/item/grab/grab, mob/user, base_damage = BASE_OBJ_SLAM_DAMAGE, is_sharp = FALSE)
	. = ..()
	if(.)
		return
	if(isxeno(user))
		return
	var/mob/living/carbon/human/grabbed_mob = grab.grabbed_thing
	if(!ishuman(grabbed_mob))
		to_chat(user, span_warning("There is no way [src] will accept [grabbed_mob]!"))
		return

	if(grabbed_mob.client)
		if(tgui_alert(grabbed_mob, "Would you like to enter cryosleep?", null, list("Yes", "No")) == "Yes")
			if(QDELETED(grabbed_mob) || !(grab?.grabbed_thing == grabbed_mob))
				return
		else
			return

	climb_in(grabbed_mob, user)

	return TRUE

/obj/machinery/cryopod/verb/eject()
	set name = "Eject Pod"
	set category = "IC.Object"
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
	set category = "IC.Object"
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

/obj/machinery/cryopod/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(!occupant)
		to_chat(xeno_attacker, span_xenowarning("There is nothing of interest in there."))
		return
	if(xeno_attacker.status_flags & INCORPOREAL || xeno_attacker.do_actions)
		return
	visible_message(span_warning("[xeno_attacker] begins to pry the [src]'s cover!"), 3)
	playsound(src,'sound/effects/metal_creaking.ogg', 25, 1)
	if(!do_after(xeno_attacker, 2 SECONDS))
		return
	playsound(loc, 'sound/effects/metal_creaking.ogg', 25, 1)
	go_out()

#undef STATE_GUN
#undef STATE_AMMO
#undef STATE_EXPLOSIVE
#undef STATE_MELEE
#undef STATE_CLOTHING
#undef STATE_FOOD
#undef STATE_DRUGS
#undef STATE_CONTAINERS
#undef STATE_OTHER
