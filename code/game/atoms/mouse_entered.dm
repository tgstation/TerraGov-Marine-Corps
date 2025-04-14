/atom/MouseEntered(location, control, params)
	SSmouse_entered.hovers[usr.client] = src
	return

// /// Fired whenever this atom is the most recent to be hovered over in the tick.
// /// Preferred over MouseEntered if you do not need information such as the position of the mouse.
// /// Especially because this is deferred over a tick, do not trust that `client` is not null.
/atom/proc/on_mouse_enter(client/client)
	SHOULD_NOT_SLEEP(TRUE)

	var/mob/user = client?.mob
	if (isnull(user))
		return

	SEND_SIGNAL(user, COMSIG_ATOM_MOUSE_ENTERED, src)
