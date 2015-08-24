/mob/living/carbon/Xenomorph/Boiler
	caste = "Boiler"
	name = "Boiler"
	desc = "A huge, grotesque xenomorph covered in glowing, oozing acid slime."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Boiler Walking"
	melee_damage_lower = 10
	melee_damage_upper = 15
	tacklemin = 2
	tacklemax = 3
	tackle_chance = 50
	health = 190
	maxHealth = 190
	storedplasma = 350
	plasma_gain = 20
	maxplasma = 700
	jellyMax = 0
	spit_delay = 65
	speed = 3.1
	adjust_pixel_x = -16
//	adjust_pixel_y = -6
//	adjust_size_x = 0.9
//	adjust_size_y = 0.85
	caste_desc = "Gross!"
	evolves_to = list()
	spit_projectile = /obj/item/projectile/energy/neuro/strongest

	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/proc/corrosive_acid,
		/mob/living/carbon/Xenomorph/proc/tail_attack,
		/mob/living/carbon/Xenomorph/proc/shift_spits,
		/mob/living/carbon/Xenomorph/proc/neurotoxin //Stronger version
		)

/mob/living/carbon/Xenomorph/Boiler/proc/longrange()
	set name = "Toggle Long Range Sight (50)"
	set desc = "Examines terrain at a distance."
	set category = "Alien"

	if(!check_state()) return

	if(is_zoomed)
		zoom_out()
		visible_message("\blue [src] stops looking in the distance.","\blue You stop peering into the distance.")
		return

	if(!check_plasma(50)) return

	visible_message("\blue [src] begins looking off into the distance.","\blue You start looking off into the distance.. Hold still!")
	if(do_after(src,20))
		zoom_in()
		return
	else
		storedplasma += 50 //Since we stole some already.
	return

/mob/living/carbon/Xenomorph/Boiler/proc/bombard(var/turf/T)
	set name = "Bombard"
	set desc = "Bombard an area. Use 'Toggle bombard types' to change the effect. Use middle mouse button for best results."
	set category = "Alien"

	if(!check_state()) return

	if(!istype(T)) return

