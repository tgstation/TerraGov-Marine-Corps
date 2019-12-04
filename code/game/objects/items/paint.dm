//NEVER USE THIS IT SUX	-PETETHEGOAT

/obj/item/reagent_containers/glass/paint
	desc = "It's a paint bucket."
	name = "paint bucket"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "paint_neutral"
	item_state = "paintcan"
	materials = list(/datum/material/metal = 200)
	w_class = WEIGHT_CLASS_NORMAL
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10,20,30,50,70)
	volume = 70
	init_reagent_flags = OPENCONTAINER
	var/paint_type = ""

	afterattack(turf/target, mob/user, proximity)
		if(!proximity) return
		if(istype(target) && reagents.total_volume > 5)
			user.visible_message("<span class='warning'> \The [target] has been splashed with something by [user]!</span>")
			spawn(5)
				reagents.reaction(target, TOUCH)
				reagents.remove_any(5)
		else
			return ..()

	New()
		if(paint_type == "remover")
			name = "paint remover bucket"
		else if(paint_type && length(paint_type) > 0)
			name = paint_type + " " + name
		..()
		reagents.add_reagent(text2path("/datum/reagent/paint/[paint_type]"), volume)

	on_reagent_change() //Until we have a generic "paint", this will give new colours to all paints in the can
		var/mixedcolor = mix_color_from_reagents(reagents.reagent_list)
		for(var/datum/reagent/paint/P in reagents.reagent_list)
			P.color = mixedcolor

	red
		icon_state = "paint_red"
		paint_type = "red"

	green
		icon_state = "paint_green"
		paint_type = "green"

	blue
		icon_state = "paint_blue"
		paint_type = "blue"

	yellow
		icon_state = "paint_yellow"
		paint_type = "yellow"

	violet
		icon_state = "paint_violet"
		paint_type = "violet"

	black
		icon_state = "paint_black"
		paint_type = "black"

	white
		icon_state = "paint_white"
		paint_type = "white"

	remover
		paint_type = "remover"

/datum/reagent/paint
	name = "Paint"
	reagent_state = 2
	color = "#808080"
	description = "This paint will only adhere to floor tiles."

/datum/reagent/paint/reaction_turf(turf/T, volume)
	if(!istype(T) || isspaceturf(T))
		return
	T.color = color

/datum/reagent/paint/reaction_obj(obj/O, volume)
	. = ..()
	if(istype(O,/obj/item/light_bulb))
		O.color = color

/datum/reagent/paint/red
	name = "Red Paint"
	color = "#FE191A"

/datum/reagent/paint/green
	name = "Green Paint"
	color = "#18A31A"

/datum/reagent/paint/blue
	name = "Blue Paint"
	color = "#247CFF"

/datum/reagent/paint/yellow
	name = "Yellow Paint"
	color = "#FDFE7D"

/datum/reagent/paint/violet
	name = "Violet Paint"
	color = "#CC0099"

/datum/reagent/paint/black
	name = "Black Paint"
	color = "#333333"

/datum/reagent/paint/white
	name = "White Paint"
	color = "#F0F8FF"

/datum/reagent/paint/remover
	name = "Paint Remover"
	description = "Paint remover is used to remove floor paint from floor tiles."
	reagent_state = 2
	color = "#808080"

/datum/reagent/paint/remover/reaction_turf(turf/T, volume)
	if(istype(T) && T.icon != initial(T.icon))
		T.icon = initial(T.icon)
