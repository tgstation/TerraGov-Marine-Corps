/*
	MouseDrop:

	Called on the atom you're dragging.  In a lot of circumstances we want to use the
	recieving object instead, so that's the default action.  This allows you to drag
	almost anything into a trash can.
*/
/atom/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	if(!usr || !over || QDELETED(src))
		return
	if(!Adjacent(usr) || !over.Adjacent(usr))
		return // should stop you from dragging through windows

	over.MouseDrop_T(src,usr)


// recieve a mousedrop
/atom/proc/MouseDrop_T(atom/dropping, mob/user)
	if (dropping.flags_atom & NOINTERACT)
		return


/client/MouseDown(atom/object, turf/location, control, params)
	if(!control)
		return
	SEND_SIGNAL(src, COMSIG_CLIENT_MOUSEDOWN, object, location, control, params)
	if(mouse_down_icon)
		mouse_pointer_icon = mouse_down_icon


/client/MouseUp(atom/object, turf/location, control, params)
	if(!control)
		return
	if(SEND_SIGNAL(src, COMSIG_CLIENT_MOUSEUP, object, location, control, params) & COMPONENT_CLIENT_MOUSEUP_INTERCEPT)
		click_intercepted = world.time
	if(mouse_up_icon)
		mouse_pointer_icon = mouse_up_icon


/client/MouseDrag(atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params) //The order seems to be wrong in the reference.
	var/list/L = params2list(params)
	if(L["middle"])
		if(src_object && src_location != over_location)
			middragtime = world.time
			middragatom = src_object
		else
			middragtime = 0
			middragatom = null
	SEND_SIGNAL(src, COMSIG_CLIENT_MOUSEDRAG, src_object, over_object, src_location, over_location, src_control, over_control, params)
