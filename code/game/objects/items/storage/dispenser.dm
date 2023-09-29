
/obj/machinery/deployable/dispenser
	name = "TX-9000 provisions dispenser"
	desc = "The TX-9000 also known as \"Dispenser\" is a machine capable of holding a large amount of items on it, while also healing nearby synthetics. Your allies will often ask you to lay down one of these."
	density = TRUE
	anchored = TRUE
	max_integrity = 250
	resistance_flags = XENO_DAMAGEABLE
	allow_pass_flags = PASSABLE
	coverage = 60
	///list of human mobs we're currently affecting in our area.
	var/list/mob/living/carbon/human/affecting_list
	///if the dispenser has finished deploying and is fully active and can be used.
	var/active = FALSE

/obj/machinery/deployable/dispenser/Initialize(mapload, _internal_item, deployer)
	. = ..()
	flick("dispenser_deploy", src)
	playsound(src, 'sound/machines/dispenser/dispenser_deploy.ogg', 50)
	addtimer(CALLBACK(src, PROC_REF(deploy)), 4.2 SECONDS)

///finishes deploying after the deploy timer
/obj/machinery/deployable/dispenser/proc/deploy()
	affecting_list = list()
	for(var/mob/living/carbon/human/human in view(2, src))
		if(!(human.species.species_flags & ROBOTIC_LIMBS)) // can only affect robots
			continue
		RegisterSignal(human, COMSIG_QDELETING, PROC_REF(on_affecting_qdel))
		affecting_list[human] = beam(human, "blood_light", maxdistance = 3)
		RegisterSignal(affecting_list[human], COMSIG_QDELETING, PROC_REF(on_beam_qdel))
		human.playsound_local(get_turf(src), 'sound/machines/dispenser/dispenser_heal.ogg', 50)
	for(var/turf/turfs AS in RANGE_TURFS(2, src))
		RegisterSignal(turfs, COMSIG_ATOM_ENTERED, PROC_REF(entered_tiles))
	active = TRUE
	START_PROCESSING(SSobj, src)

/obj/machinery/deployable/dispenser/process()
	for(var/mob/living/carbon/human/affecting AS in affecting_list)
		if(!line_of_sight(src, affecting, 2))
			qdel(affecting_list[affecting])
			affecting_list -= affecting
			UnregisterSignal(affecting, COMSIG_QDELETING)
			continue
		affecting.heal_overall_damage(2, 2, TRUE, TRUE)

///checks if a mob that moved close is elligible to get heal beamed.
/obj/machinery/deployable/dispenser/proc/entered_tiles(datum/source, mob/living/carbon/human/entering)
	SIGNAL_HANDLER
	if(!ishuman(entering) || !(entering.species.species_flags & ROBOTIC_LIMBS)) // can only affect robots
		return
	if(entering in affecting_list)
		return
	if(!line_of_sight(src, entering))
		return

	RegisterSignal(entering, COMSIG_QDELETING, PROC_REF(on_affecting_qdel))
	entering.playsound_local(get_turf(src), 'sound/machines/dispenser/dispenser_heal.ogg', 50)
	affecting_list[entering] = beam(entering, "blood_light", maxdistance = 3)
	RegisterSignal(affecting_list[entering], COMSIG_QDELETING, PROC_REF(on_beam_qdel))

///cleans human from affecting_list when it gets qdeletted
/obj/machinery/deployable/dispenser/proc/on_affecting_qdel(datum/source)
	SIGNAL_HANDLER
	affecting_list -= source

///cleans human from affecting_list when the beam gets qdeletted
/obj/machinery/deployable/dispenser/proc/on_beam_qdel(datum/source)
	SIGNAL_HANDLER
	var/datum/beam/beam = source
	UnregisterSignal(beam.target, COMSIG_QDELETING)
	affecting_list -= beam.target

/obj/machinery/deployable/dispenser/attack_hand(mob/living/user)
	. = ..()
	var/obj/item/storage/internal_bag = get_internal_item()
	internal_bag?.attack_hand(user)

/obj/machinery/deployable/dispenser/attackby(obj/item/I, mob/user, params)
	var/obj/item/internal_bag = get_internal_item()
	if(internal_bag?.attackby(I, user, params))
		return
	return ..()

/obj/machinery/deployable/dispenser/MouseDrop(obj/over_object)
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr //this is us
	if(over_object != user || !Adjacent(user))
		return
	if(!active)
		return
	active = FALSE
	balloon_alert_to_viewers("Undeploying...")
	for(var/turf/turfs AS in RANGE_TURFS(2, src))
		UnregisterSignal(turfs, COMSIG_ATOM_ENTERED)
	for(var/mob/living/carbon/human/affecting AS in affecting_list)
		qdel(affecting_list[affecting])
		UnregisterSignal(affecting, COMSIG_QDELETING)
	affecting_list = null
	STOP_PROCESSING(SSobj, src)
	flick("dispenser_undeploy", src)
	playsound(src, 'sound/machines/dispenser/dispenser_undeploy.ogg', 50)
	addtimer(CALLBACK(src, PROC_REF(disassemble), user), 4 SECONDS)

/obj/machinery/deployable/dispenser/disassemble(mob/user)
	var/obj/item/storage/internal_bag = get_internal_item()
	for(var/mob/watching in internal_bag?.content_watchers)
		internal_bag.close(watching)
	return ..()

/obj/item/storage/backpack/dispenser
	name = "TX-9000 provisions dispenser"
	desc = "The TX-9000 also known as \"Dispenser\" is a machine capable of holding a big amount of items on it, while also healing nearby synthetics. Your allies will often ask you to lay down one of those."
	icon = 'icons/obj/items/storage/storage_48.dmi'
	icon_state = "dispenser"
	flags_equip_slot = ITEM_SLOT_BACK
	max_storage_space = 48
	max_integrity = 250

/obj/item/storage/backpack/dispenser/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/deployable_item, /obj/machinery/deployable/dispenser, 0, 0)

/obj/item/storage/backpack/dispenser/attack_hand(mob/living/user)
	if(!CHECK_BITFIELD(flags_item, IS_DEPLOYED))
		return ..()
	open(user)

/obj/item/storage/backpack/dispenser/open(mob/user)
	if(CHECK_BITFIELD(flags_item, IS_DEPLOYED))
		return ..()

/obj/item/storage/backpack/dispenser/attempt_draw_object(mob/living/user)
	to_chat(usr, span_notice("You can't grab anything out of [src] while it's not deployed."))

/obj/item/storage/backpack/dispenser/do_quick_equip(mob/user)
	to_chat(usr, span_notice("You can't grab anything out of [src] while it's not deployed."))
