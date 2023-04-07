
/obj/machinery/deployable/dispenser
	name = "TX-9000 provisions dispenser"
	desc = "The TX-9000 also known as \"Dispenser\" is a machine capable of holding a large amount of items on it, while also healing nearby synthetics. Your allies will often ask you to lay down one of these."
	density = TRUE
	anchored = TRUE
	max_integrity = 250
	resistance_flags = XENO_DAMAGEABLE
	flags_pass = PASSABLE
	coverage = 60
	///if the dispenser has finished deploying and is fully active and can be used.
	var/active = FALSE

/obj/machinery/deployable/dispenser/Initialize(mapload, _internal_item, deployer)
	. = ..()
	flick("dispenser_deploy", src)
	playsound(src, 'sound/machines/dispenser/dispenser_deploy.ogg', 50)
	addtimer(CALLBACK(src, PROC_REF(deploy)), 4.2 SECONDS)

///finishes deploying after the deploy timer
/obj/machinery/deployable/dispenser/proc/deploy()
	active = TRUE

/obj/machinery/deployable/dispenser/attack_hand(mob/living/user)
	. = ..()
	var/obj/item/storage/internal_bag = internal_item
	internal_bag.attack_hand(user)

/obj/machinery/deployable/dispenser/attackby(obj/item/I, mob/user, params)
	if(internal_item.attackby(I, user, params))
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
	flick("dispenser_undeploy", src)
	playsound(src, 'sound/machines/dispenser/dispenser_undeploy.ogg', 50)
	addtimer(CALLBACK(src, PROC_REF(disassemble), user), 4 SECONDS)

/obj/machinery/deployable/dispenser/disassemble(mob/user)
	var/obj/item/storage/internal_bag = internal_item
	for(var/mob/watching in internal_bag.content_watchers)
		internal_bag.close(watching)
	return ..()

/obj/item/storage/backpack/dispenser
	name = "TX-9000 provisions dispenser"
	desc = "The TX-9000 also known as \"Dispenser\" is a machine capable of holding a big amount of items on it."
	icon = 'icons/obj/items/storage/storage_48.dmi'
	icon_state = "dispenser"
	flags_equip_slot = ITEM_SLOT_BACK
	max_storage_space = 72
	max_integrity = 250

/obj/item/storage/backpack/dispenser/Initialize(mapload, ...)
	. = ..()
	AddElement(/datum/element/deployable_item, /obj/machinery/deployable/dispenser, 0, 0)

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
