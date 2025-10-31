//thanks to sandpoot for this.
/client/var/spin_generation_cooldown

/client/verb/get_spinmage()
	set name = "Download Image (Spinning)"
	set desc = "Download the looks of your character, while spinning clockwise."
	set category = "OOC"

	if(QDELETED(mob))
		return
	if(!isliving(mob))
		to_chat(src, span_warning("You aren't the right sort to do this right now."))
		return
	if(!CLIENT_COOLDOWN_FINISHED(src, spin_generation_cooldown))
		to_chat(src, span_warning("Wait [CLIENT_COOLDOWN_TIMELEFT(src, spin_generation_cooldown)], you're in cooldown."))
		return
	CLIENT_COOLDOWN_START(src, spin_generation_cooldown, 1 MINUTES)

	var/icon/icon = new()
	var/init_dir = mob.dir
	var/frame = 1
	for(var/direction in list(SOUTH, WEST, NORTH, EAST))
		mob.dir = direction
		icon.Insert(getFlatIcon(mob, direction, no_anim=TRUE), frame = frame)
		frame++
	mob.dir = init_dir
	DIRECT_OUTPUT(src, ftp(icon, "[mob.name].dmi"))
