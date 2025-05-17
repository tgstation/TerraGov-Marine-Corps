/mob/living/MouseWheelOn(atom/A, delta_x, delta_y, params)
	var/list/modifier = params2list(params)
	if(modifier[SHIFT_CLICK])
		if(delta_y > 0)
			look_up()
		else
			look_down()
	if(modifier[CTRL_CLICK])
		if(delta_y > 0)
			up()
		else
			down()
