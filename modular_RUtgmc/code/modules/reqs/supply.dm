/datum/supply_ui/ui_data(mob/living/user)
	. = ..()
	.["personalpoints"] = round(SSpoints.personal_supply_points[user.ckey])

/datum/supply_ui/requests/ui_data(mob/living/user)
	. = ..()
	.["personalpoints"] = round(SSpoints.personal_supply_points[user.ckey])
