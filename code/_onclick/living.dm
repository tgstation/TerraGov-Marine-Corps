/mob/living/MouseWheelOn(atom/A, delta_x, delta_y, params)
	var/list/modifier = params2list(params)
	if(modifier[SHIFT_CLICK])
		var/direction = delta_y > 0 ? UP : DOWN
		if(SEND_SIGNAL(src, COMSIG_LIVING_SCROLL_LOOK, direction) & COMPONENT_SCROLL_LOOK_HANDLED)
			return
		if(direction == UP)
			look_up()
		else
			look_down()
	if(modifier[CTRL_CLICK])
		if(delta_y > 0)
			up()
		else
			down()
