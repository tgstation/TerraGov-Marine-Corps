//Flags for craftable IED
#define IED_SECURED (1<<0)
#define IED_WIRED (1<<1)
#define IED_CONNECTED (1<<2)
#define IED_FINISHED IED_SECURED|IED_WIRED|IED_CONNECTED

/* Improvised explosives - You craft them */
/obj/item/mine/ied
	name = "pipe mine"
	desc = "Cobbled together from a metal pipe, gunpowder, rods, cables, and a proximity sensor. The people's mine."
	icon_state = "pipe"
	detonation_message = "clicks and rattles."
	detonation_sound = 'sound/machines/triple_beep.ogg'
	range = 2
	angle = 360
	detonation_delay = 0.5 SECONDS
	disarm_delay = 1 SECONDS
	undeploy_delay = 2 SECONDS
	deploy_delay = 2 SECONDS
	shrapnel_type = /datum/ammo/bullet/claymore_shrapnel/nail
	shrapnel_range = 4
	//I know they technically are electronic with the proximity sensor but it's probably more fun if not EMP'able since they're practically junk
	mine_features = MINE_INTERRUPTIBLE|MINE_VOLATILE_DAMAGE|MINE_VOLATILE_FIRE|MINE_VOLATILE_EXPLOSION

	///Stages of assembly; see top of file for the flags
	var/assembly_steps_completed = NONE
	///How much gunpowder is needed for the mine to be operational
	var/gunpowder_amount_required = 20
	///How much gunpowder is in the mine
	var/gunpowder_amount = 0
	///How many rods are needed for the mine to be operational
	var/rods_amount_required = 4
	///How many rods have been added to this mine
	var/rods_amount = 0

/obj/item/mine/ied/examine(mob/user)
	. = ..()
	if(gunpowder_amount < gunpowder_amount_required)
		. += "Currently has [span_bold("[gunpowder_amount]")] out of [span_bold("[gunpowder_amount_required]")] gunpowder."
	if(rods_amount < rods_amount_required)
		. += "Currently has [span_bold("[rods_amount]")] out of [span_bold("[rods_amount_required]")] rods."
	if(!CHECK_BITFIELD(assembly_steps_completed, IED_SECURED))
		. += "Needs to be secured with a screwdriver."
	if(CHECK_BITFIELD(assembly_steps_completed, IED_WIRED) && !CHECK_BITFIELD(assembly_steps_completed, IED_CONNECTED))
		. += "The wiring needs to be set up with a wirecutter."

/obj/item/mine/ied/update_overlays()
	. = ..()
	//Only add the wires if not deployed, don't need the overlay for that
	if(CHECK_BITFIELD(assembly_steps_completed, IED_WIRED) && !anchored)
		. += "wires"

/obj/item/mine/ied/setup(mob/living/user)
	if(!CHECK_MULTIPLE_BITFIELDS(assembly_steps_completed, IED_FINISHED) || gunpowder_amount < gunpowder_amount_required || rods_amount < rods_amount_required)
		balloon_alert(user, "Not finished!")
		return FALSE
	return ..()

/obj/item/mine/ied/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(iscablecoil(I))
		if(CHECK_BITFIELD(assembly_steps_completed, IED_WIRED))
			balloon_alert(user, "Already wired!")
			return

		var/obj/item/stack/cable_coil/cables = I
		if(!cables.use(1))
			balloon_alert(user, "Not enough cables!")
			return

		ENABLE_BITFIELD(assembly_steps_completed, IED_WIRED)
		update_icon()
		balloon_alert(user, "Wired!")
		return

	if(istype(I, /obj/item/ammo_magazine/handful))
		//Marines can no longer use chem machines to make gunpowder, so we're going to apply a simple mechanic of recycling bullets
		if(gunpowder_amount >= gunpowder_amount_required)
			balloon_alert(user, "Already full!")
			return

		var/obj/item/ammo_magazine/handful/bullets = I
		if(bullets.current_rounds < 1)
			balloon_alert(user, "Not enough gunpowder!")
			return

		//The gunpowder to bullet ratio is 1:1, so using something like bullets from your rifle are straightforward
		//However, shotgun shells are packed with a lot more so they have a multiplier; 4 gunpowder from each shotgun shell
		var/caliber_bonus = 1
		if(bullets.caliber == CALIBER_12G || bullets.caliber == CALIBER_410)
			caliber_bonus = 4

		var/amount_to_transfer = min(bullets.current_rounds * caliber_bonus, gunpowder_amount_required - gunpowder_amount)
		bullets.current_rounds -= ROUND_UP(amount_to_transfer/caliber_bonus)	//Round up instead of down since you're not summoning gunpowder out of thin air
		gunpowder_amount += amount_to_transfer
		if(!bullets.current_rounds)	//Delete the handful stack if we used it all
			qdel(bullets)
		balloon_alert(user, gunpowder_amount == gunpowder_amount_required ? "Full!" : "[gunpowder_amount]/[gunpowder_amount_required] powder!")
		return

	if(istype(I, /obj/item/stack/rods))
		if(rods_amount >= rods_amount_required)
			balloon_alert(user, "Already full!")
			return

		var/obj/item/stack/rods = I
		var/amount_to_transfer = max(1, min(rods.amount, rods_amount_required - rods_amount))
		if(!rods.use(amount_to_transfer))
			balloon_alert(user, "Not enough rods!")
			return

		rods_amount += amount_to_transfer
		balloon_alert(user, rods_amount == rods_amount_required ? "Full!" : "[rods_amount]/[rods_amount_required] rods!")
		return

/obj/item/mine/ied/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(CHECK_BITFIELD(assembly_steps_completed, IED_SECURED))
		balloon_alert(user, "Already secured!")
		return
	ENABLE_BITFIELD(assembly_steps_completed, IED_SECURED)
	balloon_alert(user, "Secured!")

/obj/item/mine/ied/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	if(!CHECK_BITFIELD(assembly_steps_completed, IED_WIRED))
		balloon_alert(user, "Not wired!")
		return
	if(CHECK_BITFIELD(assembly_steps_completed, IED_CONNECTED))
		balloon_alert(user, "Already connected!")
		return
	ENABLE_BITFIELD(assembly_steps_completed, IED_CONNECTED)
	balloon_alert(user, "Connected!")

/obj/item/mine/ied/assembled
	assembly_steps_completed = IED_FINISHED

/obj/item/mine/ied/assembled/Initialize(mapload)
	. = ..()
	gunpowder_amount = gunpowder_amount_required
	rods_amount = rods_amount_required
	update_icon()
