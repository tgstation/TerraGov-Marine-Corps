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
		to_chat(src, text("<span class='notice'> You are now hiding.</span>"))
	else
		layer = MOB_LAYER
		to_chat(src, text("<span class='notice'> You have stopped hiding.</span>"))
