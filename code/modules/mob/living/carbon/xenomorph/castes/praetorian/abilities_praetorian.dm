// ***************************************
// *********** Acid spray
// ***************************************
/mob/living/carbon/Xenomorph/proc/acid_spray_cone(atom/A)

	if (!A || !check_state())
		return

	if (used_acid_spray)
		to_chat(src, "<span class='xenowarning'>You must wait to produce enough acid to spray.</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your muscles fail to respond as you try to shake up the shock!</span>")
		return

	if (!check_plasma(200))
		to_chat(src, "<span class='xenowarning'>You must produce more plasma before doing this.</span>")
		return

	var/turf/target

	if (isturf(A))
		target = A
	else
		target = get_turf(A)

	if (target == loc || !target || action_busy)
		return

	if (used_acid_spray || !check_plasma(200))
		return

	if(!do_after(src, 5, TRUE, 5, BUSY_ICON_HOSTILE))
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>The shock disrupts you!</span>")
		return

	round_statistics.praetorian_acid_sprays++

	used_acid_spray = TRUE
	use_plasma(200)
	playsound(loc, 'sound/effects/refill.ogg', 25, 1)
	visible_message("<span class='xenowarning'>\The [src] spews forth a wide cone of acid!</span>", \
	"<span class='xenowarning'>You spew forth a cone of acid!</span>", null, 5)

	speed += 2
	do_acid_spray_cone(target)
	addtimer(CALLBACK(src, .speed_increase, 2), rand(20,30))
	addtimer(CALLBACK(src, .acid_spray_cooldown_finished), xeno_caste.acid_spray_cooldown)

/mob/living/carbon/Xenomorph/proc/speed_increase(var/amount)
	speed -= amount

/mob/living/carbon/Xenomorph/proc/acid_spray_cooldown_finished()
	used_acid_spray = FALSE
	to_chat(src, "<span class='notice'>You have produced enough acid to spray again.</span>")
