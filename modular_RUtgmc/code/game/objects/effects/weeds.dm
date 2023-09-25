/obj/alien/weeds
	icon = 'modular_RUtgmc/icons/Xeno/weeds.dmi'

/obj/alien/weeds/weedwall
	icon = 'modular_RUtgmc/icons/obj/smooth_objects/weedwall.dmi'

/obj/alien/weeds/weedwall/update_icon_state()
	var/turf/closed/wall/W = loc
	if(!istype(W))
		icon_state = initial(icon_state)
	else
		icon_state = W.smoothing_junction ? "weedwall-[W.smoothing_junction]" : initial(icon_state)
	if(color_variant == STICKY_COLOR)
		icon = 'modular_RUtgmc/icons/obj/smooth_objects/weedwallsticky.dmi'
	else if(color_variant == RESTING_COLOR)
		icon = 'modular_RUtgmc/icons/obj/smooth_objects/weedwallrest.dmi'

/obj/alien/weeds/weedwall/window/update_icon_state()
	var/obj/structure/window/framed/F = locate() in loc
	icon_state = F?.smoothing_junction ? "weedwall-[F.smoothing_junction]" : initial(icon_state)
	if(color_variant == STICKY_COLOR)
		icon = 'modular_RUtgmc/icons/obj/smooth_objects/weedwallsticky.dmi'
	if(color_variant == RESTING_COLOR)
		icon = 'modular_RUtgmc/icons/obj/smooth_objects/weedwallrest.dmi'
