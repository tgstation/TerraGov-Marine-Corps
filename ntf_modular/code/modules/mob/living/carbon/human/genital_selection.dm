/// Holder for the TGUI genital menu.
/mob/living/carbon/human/var/datum/genital_menu/genital_menu = null

/mob/living/carbon/human/verb/genital_select()
	set category = "IC"
	set name = "Genital Selection"
	set desc = "Fuck 'em"
	set src = usr

	select_genitals(usr, src)

/mob/living/carbon/human/proc/select_genitals(mob/user, mob/target)
	if(!species?.has_genital_selection)
		return

	if(isnull(genital_menu))
		genital_menu = new (src)

	genital_menu.ui_interact(user)

/mob/living/carbon/human/Destroy()
	QDEL_NULL(genital_menu)
	return ..()

/mob/living/carbon/human/Login()
	. = ..()
	if(client)
		update_genitals()
