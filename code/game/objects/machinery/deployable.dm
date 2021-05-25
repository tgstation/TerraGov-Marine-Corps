/obj/machinery/deployable
	var/default_icon
	var/obj/item/internal_item
	var/deploy_flags = NONE




/obj/machinery/deployable/proc/deploy(obj/item/deploying, direction)

	internal_item = deploying
	deploying.forceMove(src)

	deploy_flags = deploying.deploy_flags
	obj_integrity = deploying.deploy_integrity
	max_integrity = deploying.deploy_max_integrity

	name = deploying.name

	desc = deploying.desc

	icon = deploying.deploy_icon ? deploying.deploy_icon : deploying.icon

	default_icon = icon

	setDir(direction)

/obj/machinery/deployable/proc/disassemble(mob/user)
	if(deploy_flags & DEPLOYED_NO_PICKUP)
		to_chat(user, "<span class='notice'>The [src] is anchored in place and cannot be disassembled.</span>")
		return
	SEND_SIGNAL(internal_item, COMSIG_ITEM_UNDEPLOY)

	internal_item = null
	

/obj/machinery/deployable/Destroy()
	if(internal_item)
		internal_item = null
		qdel(internal_item)
	operator?.unset_interaction()
	. = ..()

/obj/machinery/deployable/examine(mob/user)
	. = ..()
	internal_item.examine(user)

/obj/machinery/deployable/MouseDrop(over_object, src_location, over_location) 
	if(!ishuman(usr))
		return

	var/mob/living/carbon/human/user = usr //this is us
	if(over_object == user && in_range(src, user))
		disassemble(user)

/obj/machinery/deployable/barrier
	name = "deployable barrier"
	desc = "A deployable barrier. Swipe your ID card to lock/unlock it."
	icon = 'icons/obj/objects.dmi'
	anchored = FALSE
	density = TRUE
	icon_state = "barrier0"
	max_integrity = 100
