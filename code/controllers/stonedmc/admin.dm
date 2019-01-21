// Clickable stat() button.
/obj/effect/statclick
	name = "Initializing..."
	var/target

INITIALIZE_IMMEDIATE(/obj/effect/statclick)

/obj/effect/statclick/Initialize(mapload, text, target) //Don't port this to Initialize it's too critical
	. = ..()
	name = text
	src.target = target

/obj/effect/statclick/proc/update(text)
	name = text
	return src

/obj/effect/statclick/debug
	var/class

/obj/effect/statclick/debug/Click()
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

	usr.client.holderdebug_variables(target)
	message_admins("Admin [key_name_admin(usr)] is debugging the [target] [class].")