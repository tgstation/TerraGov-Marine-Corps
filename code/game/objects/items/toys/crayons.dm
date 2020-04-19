/* A red coloured crayon */
/obj/item/toy/crayon/red
	icon_state = "crayonred"
	colour = "#DA0000"
	shadeColour = "#810C0C"
	colourName = "red"

/* An orange coloured crayon */
/obj/item/toy/crayon/orange
	icon_state = "crayonorange"
	colour = "#FF9300"
	shadeColour = "#A55403"
	colourName = "orange"

/* A yellow coloured crayon */
/obj/item/toy/crayon/yellow
	icon_state = "crayonyellow"
	colour = "#FFF200"
	shadeColour = "#886422"
	colourName = "yellow"

/* A green coloured crayon */
/obj/item/toy/crayon/green
	icon_state = "crayongreen"
	colour = "#A8E61D"
	shadeColour = "#61840F"
	colourName = "green"

/* A blue coloured crayon */
/obj/item/toy/crayon/blue
	icon_state = "crayonblue"
	colour = "#00B7EF"
	shadeColour = "#0082A8"
	colourName = "blue"

/* A purple coloured crayon */
/obj/item/toy/crayon/purple
	icon_state = "crayonpurple"
	colour = "#DA00FF"
	shadeColour = "#810CFF"
	colourName = "purple"

/* A special mime crayon */
/obj/item/toy/crayon/mime
	icon_state = "crayonmime"
	desc = "A very sad-looking crayon."
	colour = "#FFFFFF"
	shadeColour = "#000000"
	colourName = "mime"
	uses = 0

/obj/item/toy/crayon/mime/attack_self(mob/living/user as mob) //inversion
	if(colour != "#FFFFFF" && shadeColour != "#000000")
		colour = "#FFFFFF"
		shadeColour = "#000000"
		to_chat(user, "You will now draw in white and black with this crayon.")
	else
		colour = "#000000"
		shadeColour = "#FFFFFF"
		to_chat(user, "You will now draw in black and white with this crayon.")
	return

/* A special rainbow crayon */
/obj/item/toy/crayon/rainbow
	icon_state = "crayonrainbow"
	colour = "#FFF000"
	shadeColour = "#000FFF"
	colourName = "rainbow"
	uses = 0

/obj/item/toy/crayon/rainbow/attack_self(mob/living/user as mob)
	colour = input(user, "Please select the main colour.", "Crayon colour") as color
	shadeColour = input(user, "Please select the shade colour.", "Crayon colour") as color
	return

/obj/item/toy/crayon/afterattack(atom/target, mob/user as mob, proximity)
	if(!proximity) 
		return

	if(!isfloorturf(target))
		return

	if(!CONFIG_GET(flag/fun_allowed))
		return

	var/drawtype = input("Choose what you'd like to draw.", "Crayon scribbles") in list("graffiti","rune","letter")
	if(drawtype == "letter")
		drawtype = input("Choose the letter.", "Crayon scribbles") in list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
	
	user.visible_message("[user] starts drawing something on \the [target.name]")
	if(!instant && !do_after(user, 5 SECONDS, TRUE, target, BUSY_ICON_GENERIC))
		return

	new /obj/effect/decal/cleanable/crayon(target, colour, shadeColour, drawtype)
	uses--
	if(uses <= 0)
		to_chat(user, "<span class='warning'>You used up your crayon!</span>")
		qdel(src)

/obj/item/toy/crayon/attack(mob/living/M, mob/living/user)
	if(M != user)
		return ..()
	
	user.visible_message("[user] took a bite of \the [src] and swallowed it.",
	"You took a bit of \the [src] and swallowed it.")
	uses -= 5
	if(uses <= 0)
		to_chat(user, "<span class='warning'>You ate the whole crayon!</span>")
		qdel(src)

	M.adjustToxLoss(1) // add a little bit of toxic damage
	if(istype(src, /obj/item/toy/crayon/mime))
		M.disabilities |= MUTE
		addtimer(VARSET_CALLBACK(M, disabilities, M.disabilities & ~MUTE), 30 SECONDS)
