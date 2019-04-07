#define CLIENT_VIEW_INDEX "view"
#define CLIENT_PIXEL_X_INDEX "pixel_x"
#define CLIENT_PIXEL_Y_INDEX "pixel_y"
#define CLIENT_CLICK_INTERCEPT_INDEX "click_intercept"
#define CLIENT_PERSPECTIVE_INDEX "perspective"
#define CLIENT_EYE_INDEX "eye"

#define TILESIZE 32


/mob/proc/reset_client_sight()
    see_in_dark = initial(see_in_dark) + see_in_dark_modifier
    see_invisible = see_in_dark > 2 ? SEE_INVISIBLE_LEVEL_ONE : SEE_INVISIBLE_LIVING
    if(!client)
        reset_client_sight_no_client() //Preserve the values in case they return.
        return
    client.change_view(world.view)
    client.pixel_x = 0
    client.pixel_y = 0
    client.click_intercept = null
    client_vars.Remove(CLIENT_VIEW_INDEX, CLIENT_PIXEL_X_INDEX, CLIENT_PIXEL_Y_INDEX, CLIENT_CLICK_INTERCEPT_INDEX) //No need to store the info in the mob anymore.


/mob/proc/reset_client_sight_no_client()
    client_vars[CLIENT_VIEW_INDEX] = world.view
    client_vars[CLIENT_PIXEL_X_INDEX] = 0
    client_vars[CLIENT_PIXEL_Y_INDEX] = 0
    client_vars[CLIENT_CLICK_INTERCEPT_INDEX] = null


/mob/proc/regenerate_client_sight()
    for(var/i in client_vars)
        switch(i)
            if(CLIENT_VIEW_INDEX)
                client.view = client_vars[CLIENT_VIEW_INDEX]
            if(CLIENT_PIXEL_X_INDEX)
                client.pixel_x = client_vars[CLIENT_PIXEL_X_INDEX]
            if(CLIENT_PIXEL_Y_INDEX)
                client.pixel_y = client_vars[CLIENT_PIXEL_Y_INDEX]
            if(CLIENT_CLICK_INTERCEPT_INDEX)
                client.click_intercept = client_vars[CLIENT_CLICK_INTERCEPT_INDEX]


/mob/proc/set_client_sight(viewsize, tileoffset, darkvision)
    if(darkvision)
        see_in_dark = max(viewsize + tileoffset + 1, see_in_dark + see_in_dark_modifier) //That extra one so they can see the edge of the screen.
        see_invisible = min(see_invisible, SEE_INVISIBLE_OBSERVER_NOLIGHTING)
    if(!client)
        set_client_sight_no_client(viewsize, tileoffset)
        return
    client.change_view(viewsize)
    var/viewoffset = TILESIZE * tileoffset
    switch(dir)
        if(NORTH)
            client.pixel_x = 0
            client.pixel_y = viewoffset
        if(SOUTH)
            client.pixel_x = 0
            client.pixel_y = -viewoffset
        if(EAST)
            client.pixel_x = viewoffset
            client.pixel_y = 0
        if(WEST)
            client.pixel_x = -viewoffset
            client.pixel_y = 0


/mob/proc/set_client_sight_no_client(viewsize, tileoffset)
    client_vars[CLIENT_VIEW_INDEX] = viewsize
    var/viewoffset = TILESIZE * tileoffset
    switch(dir)
        if(NORTH)
            client_vars[CLIENT_PIXEL_X_INDEX] = 0
            client_vars[CLIENT_PIXEL_Y_INDEX] = viewoffset
        if(SOUTH)
            client_vars[CLIENT_PIXEL_X_INDEX] = 0
            client_vars[CLIENT_PIXEL_Y_INDEX] = -viewoffset
        if(EAST)
            client_vars[CLIENT_PIXEL_X_INDEX] = viewoffset
            client_vars[CLIENT_PIXEL_Y_INDEX] = 0
        if(WEST)
            client_vars[CLIENT_PIXEL_X_INDEX] = -viewoffset
            client_vars[CLIENT_PIXEL_Y_INDEX] = 0


/mob/proc/regenerate_client_view()
    if(client_vars[CLIENT_PERSPECTIVE_INDEX] && client_vars[CLIENT_EYE_INDEX]) //Check if we've saved a view to load from.
        client.perspective = client_vars[CLIENT_PERSPECTIVE_INDEX]
        client.eye = client_vars[CLIENT_EYE_INDEX]
        return
    reset_view(loc) //If we haven't, reset to normal.


/mob/living/carbon/Xenomorph/Queen/regenerate_client_view()
    reset_view(loc) //Queens have their own handling, with observed_xeno and all.


/mob/proc/reset_view(atom/A)
    if(!client)
        reset_view_no_client(A)
        return
    if(ismovableatom(A))
        client.perspective = EYE_PERSPECTIVE
        client.eye = A
    else if(isturf(loc))
        client.perspective = MOB_PERSPECTIVE
        client.eye = client.mob
    else
        client.perspective = EYE_PERSPECTIVE
        client.eye = loc
    client_vars.Remove(CLIENT_PERSPECTIVE_INDEX, CLIENT_EYE_INDEX) //Clean saved client vars, as we are resetting.


/mob/living/carbon/Xenomorph/Queen/reset_view(atom/A)
	if(!client)
		reset_view_no_client(A)
	if(ovipositor && observed_xeno && !stat)
		client.perspective = EYE_PERSPECTIVE
		client.eye = observed_xeno
	else
		return ..()


/mob/proc/reset_view_no_client(atom/A)
    if(ismovableatom(A))
        client_vars[CLIENT_PERSPECTIVE_INDEX] = EYE_PERSPECTIVE
        client_vars[CLIENT_EYE_INDEX] = A
    else if(isturf(loc))
        client_vars[CLIENT_PERSPECTIVE_INDEX] = MOB_PERSPECTIVE
        client_vars[CLIENT_EYE_INDEX] = src
    else
        client_vars[CLIENT_PERSPECTIVE_INDEX] = EYE_PERSPECTIVE
        client_vars[CLIENT_EYE_INDEX] = loc


/mob/living/carbon/Xenomorph/Queen/reset_view_no_client(atom/A)
	if(ovipositor && observed_xeno && !stat)
		client_vars[CLIENT_PERSPECTIVE_INDEX] = EYE_PERSPECTIVE
		client_vars[CLIENT_EYE_INDEX] = observed_xeno
	else
		return ..()


/mob/proc/add_see_invisible(see_invisible_change)
	see_invisible_modifiers.Add(see_invisible_change)
	for(var/i in see_invisible_modifiers)
		if(i < see_invisible)
			see_invisible = i


/mob/proc/remove_see_invisible(see_invisible_change)
	see_invisible_modifiers.Remove(see_invisible_change)
	see_invisible = initial(see_invisible)
	for(var/i in see_invisible_modifiers)
		if(i < see_invisible)
			see_invisible = i


//==//==//

/mob/proc/save_client_sight()
    client_vars[CLIENT_VIEW_INDEX] = client.view
    client_vars[CLIENT_PIXEL_X_INDEX] = client.pixel_x
    client_vars[CLIENT_PIXEL_Y_INDEX] = client.pixel_y
    client_vars[CLIENT_CLICK_INTERCEPT_INDEX] = client.click_intercept


/mob/proc/load_client_sight()
    for(var/i in client_vars)
        switch(i)
            if(CLIENT_VIEW_INDEX)
                client.view = client_vars[CLIENT_VIEW_INDEX]
            if(CLIENT_PIXEL_X_INDEX)
                client.pixel_x = client_vars[CLIENT_PIXEL_X_INDEX]
            if(CLIENT_PIXEL_Y_INDEX)
                client.pixel_y = client_vars[CLIENT_PIXEL_Y_INDEX]
            if(CLIENT_CLICK_INTERCEPT_INDEX)
                client.click_intercept = client_vars[CLIENT_CLICK_INTERCEPT_INDEX]


//==//==//


/mob/proc/update_sight()
	return


#undef CLIENT_VIEW_INDEX
#undef CLIENT_PIXEL_X_INDEX
#undef CLIENT_PIXEL_Y_INDEX
#undef CLIENT_CLICK_INTERCEPT_INDEX