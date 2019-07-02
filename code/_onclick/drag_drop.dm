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


/client/MouseDown(object, location, control, params)
	if(mouse_down_icon)
		mouse_pointer_icon = mouse_down_icon


/client/MouseUp(object, location, control, params)
	if(mouse_up_icon)
		mouse_pointer_icon = mouse_up_icon


/client/MouseDrag(src_object,atom/over_object,src_location,over_location,src_control,over_control,params)
	var/list/L = params2list(params)
	if(L["middle"])
		if(src_object && src_location != over_location)
			middragtime = world.time
			middragatom = src_object
		else
			middragtime = 0
			middragatom = null