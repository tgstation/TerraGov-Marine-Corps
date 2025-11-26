/mob/proc/get_iff_signal()
	var/obj/item/card/id/id = get_idcard()
	return id?.iff_signal
