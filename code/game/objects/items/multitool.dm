/**
* Multitool -- A multitool is used for hacking electronic devices.
* TO-DO -- Using it as a power measurement tool for cables etc. Nannek.
*
*/

/obj/item/tool/multitool
	name = "multitool"
	desc = "You can use this on airlocks or APCs to try to hack them without cutting wires."
	icon_state = "multitool"
	atom_flags = CONDUCT
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 5
	throw_range = 15
	throw_speed = 3
	tool_behaviour = TOOL_MULTITOOL

	var/obj/machinery/telecomms/buffer // simple machine buffer for device linkage

/obj/item/tool/multitool/attack_self(mob/user)
	. = ..()

	if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_LOCATE_APC) || !ishuman(user) || user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_METAL || !user.client)
		return

	var/area/current_area = get_area(src)
	var/atom/area_apc = current_area ? current_area.get_apc() : null
	if(!area_apc)
		to_chat(user, span_warning("ERROR: Could not locate local APC."))
		user.balloon_alert(user, "could not locate!")
		return

	var/dist = get_dist(src, area_apc)
	var/direction = angle_to_dir(Get_Angle(get_turf(src), get_turf(area_apc)))
	to_chat(user, span_notice("The local APC is located at [span_bold("[dist] units [dir2text(direction)]")]."))
	user.balloon_alert(user, "[dist] units [dir2text(direction)]")

	//Create the appearance so we have something to apply the filter to.
	var/mutable_appearance/apc_appearance = new(area_apc)
	apc_appearance.filters += list("type" = "outline", "size" = 1, "color" = COLOR_GREEN)
	//Make it an image we can give to the client
	var/image/final_image = image(apc_appearance)

	final_image.layer = WALL_OBJ_LAYER
	SET_PLANE_EXPLICIT(final_image, GAME_PLANE, area_apc)
	final_image.loc = get_turf(area_apc)
	final_image.dir = apc_appearance.dir
	final_image.alpha = 225
	user.client.images += final_image

	TIMER_COOLDOWN_START(src, COOLDOWN_LOCATE_APC, 1.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(remove_apc_highlight), user.client, final_image), 1.4 SECONDS)

/// Removes the highlight from the APC.
/obj/item/tool/multitool/proc/remove_apc_highlight(client/user_client, image/highlight_image)
	if(!user_client)
		return
	user_client.images -= highlight_image
