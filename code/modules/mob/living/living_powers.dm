/mob/living/proc/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Abilities"
	handle_ventcrawl()


/mob/living/proc/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Abilities"

	if (layer != ANIMAL_HIDING_LAYER)
		layer = ANIMAL_HIDING_LAYER
		balloon_alert(src, "You are now hiding")
		return
	layer = MOB_LAYER
	balloon_alert(src, "You have stopped hiding")
