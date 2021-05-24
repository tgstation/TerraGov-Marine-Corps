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

	name = deploying.deploy_name ? deploying.deploy_name : deploying.name

	desc = deploying.deploy_desc ? deploying.deploy_desc : deploying.desc

	icon = deploying.deploy_icon ? deploying.deploy_icon : deploying.icon

	default_icon = deploying.deploy_icon_state ? deploying.deploy_icon_state : deploying.icon_state

	setDir(direction)

/obj/machinery/deployable/proc/disassemble(mob/user)
	if(deploy_flags & DEPLOYED_NO_PICKUP)
		to_chat(user, "<span class='notice'>The [src] is anchored in place and cannot be disassembled.</span>")
		return
	to_chat(user, "<span class='notice'>You begin disassembling [src].</span>")
	if(!do_after(user, internal_item.deploy_time, TRUE, src, BUSY_ICON_BUILD))
		return
	user.visible_message("<span class='notice'> [user] disassembles [src]! </span>","<span class='notice'> You disassemble [src]!</span>")

	user.unset_interaction()

	internal_item.deploy_integrity = obj_integrity

	user.put_in_active_hand(internal_item)
	internal_item = null

	qdel(src)

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
