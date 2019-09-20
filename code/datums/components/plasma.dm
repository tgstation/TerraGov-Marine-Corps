/datum/component/plasma
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/plasma_stored
	var/plasma_max

/datum/component/plasma/Initialize(plasma_max, plasma_stored)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	src.plasma_max = plasma_max
	if(isnull(plasma_stored))
		src.plasma_stored = plasma_max
	else
		src.plasma_stored = CLAMP(plasma_stored, 0, src.plasma_max)

/datum/component/plasma/InheritComponent(datum/component/C, i_am_original, list/args)
	src.plasma_max = args[1]

	if(LAZYLEN(args) > 1 && !isnull(args[2]))
		src.plasma_stored = CLAMP(plasma_stored, 0, src.plasma_max)
	else
		src.plasma_stored = src.plasma_max

/datum/component/plasma/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMPONENT_CHECK_PLASMA_AMOUNT, .proc/check_plasma_amount)
	RegisterSignal(parent, COMPONENT_ADD_PLASMA_AMOUNT, .proc/add_plasma_amount)
	RegisterSignal(parent, COMPONENT_REMOVE_PLASMA_AMOUNT, .proc/remove_plasma_amount)
	RegisterSignal(parent, COMPONENT_TRANSFER_PLASMA_FROM, .proc/transfer_plasma_from)

/datum/component/plasma/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMPONENT_CHECK_PLASMA_AMOUNT,
		COMPONENT_ADD_PLASMA_AMOUNT,
		COMPONENT_REMOVE_PLASMA_AMOUNT,
		COMPONENT_TRANSFER_PLASMA_FROM
	))
	
/datum/component/plasma/proc/check_plasma_amount(datum/source, amount)
	if(plasma_stored >= amount)
		return COMPONENT_PLASMA_SUFFICIENT
	return COMPONENT_PLASMA_INSUFFICIENT

/datum/component/plasma/proc/add_plasma_amount(datum/source, amount)
	if(plasma_stored + amount > plasma_max)
		plasma_stored = plasma_max
		return COMPONENT_PLASMA_OVERFLOW
	plasma_stored += amount
	return COMPONENT_PLASMA_ADDED

/datum/component/plasma/proc/remove_plasma_amount(datum/source, amount)
	if(plasma_stored - amount < 0)
		plasma_stored = 0
		return COMPONENT_PLASMA_ZEROED
	plasma_stored -= amount
	return COMPONENT_PLASMA_REMOVED

/datum/component/plasma/proc/take_all_plasma()
	. = plasma_stored
	plasma_stored = 0

/datum/component/plasma/proc/transfer_plasma_from(datum/source, amount, mob/target)
	if(plasma_stored + amount > plasma_max)
		amount = plasma_max - plasma_stored
	var/ret = SEND_SIGNAL(target, COMPONENT_CHECK_PLASMA_AMOUNT, amount)
	switch(ret)
		if(COMPONENT_PLASMA_SUFFICIENT)
			SEND_SIGNAL(target, COMPONENT_REMOVE_PLASMA_AMOUNT, amount)
			plasma_stored += amount
		if(COMPONENT_PLASMA_INSUFFICIENT)
			var/datum/component/plasma/P = target.GetComponent(/datum/component/plasma)
			plasma_stored += P.take_all_plasma()
		else
			return COMPONENT_TARGET_PLASMALESS
	return COMPONENT_PLASMA_TRANSFERRED
	
