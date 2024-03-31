#define CREDIT_ROLL_SPEED 125
#define CREDIT_SPAWN_SPEED 50
#define CREDIT_ANIMATE_HEIGHT (14 * world.icon_size)
#define CREDIT_EASE_DURATION 22
#define CREDITS_PATH "icons/fullblack.dmi"

/client/proc/RollCredits()
	set waitfor = FALSE
//	if(!fexists(CREDITS_PATH))
//		return
//	var/icon/credits_icon = new(CREDITS_PATH)
//	verbs += /client/proc/ClearCredits
//	var/static/list/credit_order_for_this_round
//	if(isnull(credit_order_for_this_round))
//		credit_order_for_this_round = list("Thanks for playing!") + (shuffle(icon_states(credits_icon)) - "Thanks for playing!")
//		if(!credits)
//			return
//	sleep(CREDIT_ROLL_SPEED - CREDIT_SPAWN_SPEED)
//	verbs -= /client/proc/ClearCredits
//	qdel(credits_icon)

/client/proc/ClearCredits()
	set name = "Hide Credits"
	set category = "OOC"
	verbs -= /client/proc/ClearCredits
	QDEL_LIST(credits)
	credits = null

/obj/screen/credit
	mouse_opacity = 1
	alpha = 0
	screen_loc = "1,1"
	layer = SPLASHSCREEN_LAYER
	plane = SPLASHSCREEN_PLANE
	var/client/parent
	var/creditee
	var/upvoted

/obj/screen/credit/Click()
	if(upvoted)
		return
	testing("clicdebugk")
	upvoted = TRUE
	var/image/I = new('icons/effects/effects.dmi', "hearty")
	I.pixel_x = rand(-32,32)
	animate(I, pixel_y = 64, alpha = 0, time = 18, flags = ANIMATION_PARALLEL)
	add_overlay(I)
	for(var/client/C in GLOB.clients)
		if(C == parent)
			continue
		for(var/obj/screen/credit/CR in C.screen)
			if(CR.creditee == creditee)
				var/image/IR = new('icons/effects/effects.dmi', "hearty")
				IR.pixel_x = rand(-32,32)
				animate(IR, pixel_y = 64, alpha = 0, time = 18, flags = ANIMATION_PARALLEL)
				CR.add_overlay(IR)

/obj/screen/credit/Initialize(mapload, credited, client/P, icon/I)
	. = ..()
	testing("spawned credit [credited]")
	icon = I
	parent = P
	var/voicecolor = "dc0174"
	if(GLOB.credits_icons[credited])
		if(GLOB.credits_icons[credited]["vc"])
			voicecolor=GLOB.credits_icons[credited]["vc"]
//	icon_state = credited
	maptext = {"<span style='vertical-align:top; text-align:center;
				color: #[voicecolor]; font-size: 100%;
				text-shadow: 1px 1px 2px black, 0 0 1em black, 0 0 0.2em black;
				font-family: "Pterra";'>[credited]</span>"}
	creditee = credited
	maptext_x = -32
	maptext_y = 8
	maptext_width = 150
	var/matrix/M = matrix(transform)
	M.Translate(224, 64)
	transform = M
	M = matrix(transform)
	M.Translate(-288, 0)
	animate(src, transform = M, time = 90)
	animate(src, alpha = 255, time = 10, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(src, .proc/FadeOut), 80)
	QDEL_IN(src, 90)
	P.screen += src

/obj/screen/credit/Destroy()
	var/client/P = parent
	if(!P)
		return ..()
	P.screen -= src
	icon = null
	LAZYREMOVE(P.credits, src)
	parent = null
	return ..()

/obj/screen/credit/proc/FadeOut()
	animate(src, alpha = 0, time = 10,  flags = ANIMATION_PARALLEL)
