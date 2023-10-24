/obj/machinery/computer/operating
	name = "Operating Computer"
	anchored = TRUE
	density = TRUE
	icon_state = "computer_small"
	screen_overlay = "operating"
	circuit = /obj/item/circuitboard/computer/operating
	var/mob/living/carbon/human/victim = null
	var/obj/machinery/optable/table = null

/obj/machinery/computer/operating/Initialize(mapload)
	. = ..()
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		table = locate(/obj/machinery/optable, get_step(src, dir))
		if (table)
			table.computer = src
			break


/obj/machinery/computer/operating/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat
	if(src.table && (src.table.check_victim()))
		src.victim = src.table.victim
		dat += {"
<B>Patient Information:</B><BR>
<BR>
<B>Name:</B> [src.victim.real_name]<BR>
<B>Age:</B> [src.victim.age]<BR>
<B>Blood Type:</B> [src.victim.b_type]<BR>
<BR>
<B>Health:</B> [src.victim.health]<BR>
<B>Brute Damage:</B> [src.victim.getBruteLoss()]<BR>
<B>Toxins Damage:</B> [src.victim.getToxLoss()]<BR>
<B>Fire Damage:</B> [src.victim.getFireLoss()]<BR>
<B>Suffocation Damage:</B> [src.victim.getOxyLoss()]<BR>
<B>Patient Status:</B> [src.victim.stat ? "Non-Responsive" : "Stable"]<BR>
<B>Heartbeat rate:</B> [victim.get_pulse(GETPULSE_TOOL)]<BR>
"}
	else
		src.victim = null
		dat += {"
<B>Patient Information:</B><BR>
<BR>
<B>No Patient Detected</B>
"}

	var/datum/browser/popup = new(user, "op", "<div align='center'>Operating Computer</div>")
	popup.set_content(dat)
	popup.open()
