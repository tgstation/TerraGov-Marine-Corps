/obj/item/teleporter_kit/premade
	item_flags = IS_DEPLOYABLE|DEPLOY_ON_INITIALIZE|DEPLOYED_NO_PICKUP

/obj/item/teleporter_kit/premade/Initialize(mapload)
	.=..()
	if(item_flags & IS_DEPLOYED)
		loc.name = name

GLOBAL_LIST_INIT(remotely_linked_teleporter_pairs, list())

/obj/effect/remote_teleporter_linker
	name = "Remote Teleporter Pair Linker"
	var/id = "Teleporter Pair"

/obj/effect/remote_teleporter_linker/Initialize(mapload)
	..()
	. = INITIALIZE_HINT_QDEL
	var/obj/item/teleporter_kit/kit = locate() in loc

	if(!kit)
		var/obj/machinery/deployable/teleporter/teleporter = locate() in loc
		kit = teleporter?.get_internal_item()

	if(!kit)
		qdel(src)
		CRASH("remote_teleporter_linker at [logdetails(src)] with id [id] has no teleporter kit in its loc!")

	switch(LAZYLEN(GLOB.remotely_linked_teleporter_pairs[id]))
		if(0)
			GLOB.remotely_linked_teleporter_pairs[id] = list(kit)
		if(1)
			var/obj/item/teleporter_kit/premade/to_link = GLOB.remotely_linked_teleporter_pairs[id][1]
			to_link.set_linked_teleporter(kit)
			kit.set_linked_teleporter(to_link)
			GLOB.remotely_linked_teleporter_pairs[id] += kit
		else
			GLOB.remotely_linked_teleporter_pairs[id] += kit
			var/crash_message = "Teleporter pair with id [id] has three or more elements! ("
			var/list/bad_kit_messages = list()
			for(var/bad_kit in GLOB.remotely_linked_teleporter_pairs[id])
				bad_kit_messages += "\[[logdetails(bad_kit)]\]"
			crash_message += bad_kit_messages.Join(",")
			crash_message += ")"
			qdel(src)
			CRASH(crash_message)

/obj/effect/remote_teleporter_linker/pair1
	name = "Remote Teleporter Pair Linker - Pair 1"
	id = "Teleporter Pair 1"

/obj/effect/remote_teleporter_linker/pair2
	name = "Remote Teleporter Pair Linker - Pair 2"
	id = "Teleporter Pair 2"

/obj/effect/remote_teleporter_linker/pair3
	name = "Remote Teleporter Pair Linker - Pair 3"
	id = "Teleporter Pair 3"

/obj/effect/remote_teleporter_linker/pair4
	name = "Remote Teleporter Pair Linker - Pair 4"
	id = "Teleporter Pair 4"