/datum/anvil_recipe
	var/name
	var/list/additional_items = list()
	var/appro_skill = /datum/skill/craft/blacksmithing
	var/req_bar
	var/created_item

	var/needed_item
	var/needed_item_text
	var/quality_mod = 0
	var/progress

	var/datum/parent

/datum/anvil_recipe/New(datum/P, ...)
	parent = P
	. = ..()

/datum/anvil_recipe/proc/advance(mob/user)
	if(progress == 100)
		to_chat(user, "<span class='info'>It's ready.</span>")
		user.visible_message("<span class='warning'>[user] strikes the bar!</span>")
		return FALSE
	if(needed_item)
		to_chat(user, "<span class='info'>Now it's time to add a [needed_item_text].</span>")
		user.visible_message("<span class='warning'>[user] strikes the bar!</span>")
		return FALSE
	var/moveup = 1
	var/proab = 3
	if(user.mind)
		moveup = moveup + (user.mind.get_skill_level(appro_skill) * 6)
		if(!user.mind.get_skill_level(appro_skill))
			proab = 23
	if(prob(proab))
		moveup = 0
	progress = min(progress + moveup, 100)
	if(progress == 100)
		if(additional_items.len)
			needed_item = pick(additional_items)
			var/obj/item/I = new needed_item()
			needed_item_text = I.name
			qdel(I)
			additional_items -= needed_item
			progress = 0
	if(!moveup)
		if(prob(round(proab/2)))
			user.visible_message("<span class='warning'>[user] spoils the bar!</span>")
			if(parent)
				var/obj/item/P = parent
				qdel(P)
			return FALSE
		else
			user.visible_message("<span class='warning'>[user] strikes the bar!</span>")
			return FALSE
	else
		if(user.mind)
			if(isliving(user))
				var/mob/living/L = user
				var/amt2raise = L.STAINT/2
				if(amt2raise > 0)
					user.mind.adjust_experience(appro_skill, amt2raise, FALSE)
		user.visible_message("<span class='info'>[user] strikes the bar!</span>")
		return TRUE

/datum/anvil_recipe/proc/item_added(mob/user)
	needed_item = null
	user.visible_message("<span class='info'>[user] adds [needed_item_text]</span>")
	needed_item_text = null