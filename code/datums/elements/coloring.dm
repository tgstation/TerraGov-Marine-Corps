


/datum/element/color


/datum/element/color/Attach(datum/target)
	if(!isobj(target))
		return ELEMENT_INCOMPATIBLE
	. = ..()
	RegisterSignal(target, COMSIG_PARENT_ATTACKBY, .proc/_attackby)

/datum/element/color/Detach(datum/source, force)
	UnregisterSignal(source, list(
		COMSIG_PARENT_ATTACKBY
	))
	return ..()

/datum/element/color/proc/_attackby(obj/source, obj/item/attacked_by, mob/attacker, params)
	SIGNAL_HANDLER
	if(!istype(attacked_by, /obj/item/facepaint))
		return

	var/colors = source.color_list
	var/obj/item/facepaint/paint = attacked_by
	if(paint.uses < 1)
		to_chat(attacker, "<span class='warning'>\the [paint] is out of color!</span>")
		return
	
	INVOKE_ASYNC(src, .proc/attackby, source, paint, attacker, colors, params)
	return COMPONENT_NO_AFTERATTACK

/datum/element/color/proc/attackby(obj/source, obj/item/attacked_by, mob/attacker, var/colors, params) 

	var/obj/item/facepaint/paint = attacked_by
	var/new_color = tgui_input_list(attacker, "Pick a color", "Pick color", colors)
	if(!new_color)
		return
	if(!do_after(attacker, 1 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
		return
	
	var/default_icon = initial(source.icon_state)
	source.icon_state = "[default_icon]_[new_color]"
	paint.uses--



