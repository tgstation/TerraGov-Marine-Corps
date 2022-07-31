// Clickable stat() button.
/atom/movable/effect/statclick
	name = "Initializing..."
	var/target

INITIALIZE_IMMEDIATE(/atom/movable/effect/statclick)

/atom/movable/effect/statclick/Initialize(mapload, text, target) //Don't port this to Initialize it's too critical
	. = ..()
	name = text
	src.target = target

/atom/movable/effect/statclick/proc/update(text)
	name = text
	return src

/atom/movable/effect/statclick/debug
	var/class

/atom/movable/effect/statclick/debug/Click()
	if(!usr.client.holder || !target)
		return
	if(!class)
		if(istype(target, /datum/controller/subsystem))
			class = "subsystem"
		else if(istype(target, /datum/controller))
			class = "controller"
		else if(istype(target, /datum))
			class = "datum"
		else
			class = "unknown"

	usr.client.debug_variables(target)

	log_admin("[key_name(usr)] is debugging the [target] [class].")
	message_admins("[ADMIN_TPMONTY(usr)] is debugging the [target] [class].")
