/datum/buildmode_mode/outfit
	key = "outfit"
	var/datum/outfit/dressuptime

/datum/buildmode_mode/outfit/Destroy()
	dressuptime = null
	return ..()

/datum/buildmode_mode/outfit/show_help(client/c)
	to_chat(c, "<span class='notice'>***********************************************************\n\
		Right Mouse Button on buildmode button = Select outfit to equip.\n\
		Left Mouse Button on mob/living/carbon/human = Equip the selected outfit.\n\
		Shift + Left Mouse Button on mob/living/carbon/human = Copy thier outfit.\n\
		Right Mouse Button on mob/living/carbon/human = Strip and delete current outfit.\n\
		***********************************************************</span>")

/datum/buildmode_mode/outfit/Reset()
	. = ..()
	dressuptime = null

/datum/buildmode_mode/outfit/change_settings(client/c)
	var/list/job_paths = subtypesof(/datum/outfit/job)
	var/list/job_outfits = list()
	for(var/path in job_paths)
		var/datum/outfit/O = path
		if(initial(O.can_be_admin_equipped))
			job_outfits[initial(O.name)] = path

	var/list/picker = sortList(job_outfits)
	picker.Insert(1, "{Custom}", "{Naked}")

	var/dresscode = input("Select job equipment", "Select Equipment") as null|anything in picker
	if(!dresscode)
		return
	var/outfit_path = job_outfits[dresscode]
	dressuptime = new outfit_path


/datum/buildmode_mode/outfit/handle_click(client/c, params, object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")
	var/shift_click = pa.Find("shift")

	if(!ishuman(object))
		return
	var/mob/living/carbon/human/dollie = object

	if(left_click && shift_click)
		dressuptime = new
		dressuptime.from_mob(dollie)
		to_chat(c, "<span class='notice'>New outfit copied from [dollie].</span>")
		return

	if(left_click)
		if(isnull(dressuptime))
			to_chat(c, "<span class='warning'>Pick an outfit first.</span>")
			return

		dollie.delete_equipment()
		if(dressuptime != "{Naked}")
			dollie.equipOutfit(dressuptime)

	if(right_click)
		dollie.delete_equipment()
