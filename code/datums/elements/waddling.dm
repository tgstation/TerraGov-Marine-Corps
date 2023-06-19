/datum/element/waddling

/datum/element/waddling/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	if(isliving(target))
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(LivingWaddle))
	else
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(Waddle))

/datum/element/waddling/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)

/datum/element/waddling/proc/LivingWaddle(mob/living/target)
	if(target.incapacitated())
		return
	Waddle(target)

/datum/element/waddling/proc/Waddle(atom/movable/target)
	animate(target, pixel_z = 4, time = 0)
	var/prev_trans = matrix(target.transform)
	animate(pixel_z = 0, transform = turn(target.transform, pick(-12, 0, 12)), time = 2)
	animate(pixel_z = 0, transform = prev_trans, time = 0)

/obj/item/clothing/shoes/clown_shoes/equipped(mob/user, slot)
	. = ..()
	if(slot == SLOT_SHOES && enabled_waddle)
		user.AddElement(/datum/element/waddling)

/obj/item/clothing/shoes/clown_shoes/unequipped(mob/user)
	. = ..()
	if(enabled_waddle)
		user.RemoveElement(/datum/element/waddling)
