/client/verb/toggle_tips()
	set name = "Toggle Examine Tooltips"
	set desc = ""
	set category = "Preferences"
	set hidden = 1
	if(!holder)
		return
	prefs.enable_tips = !prefs.enable_tips
	prefs.save_preferences()
	to_chat(usr, "<span class='danger'>Examine tooltips [prefs.enable_tips ? "en" : "dis"]abled.</span>")

/client/verb/change_tip_delay()
	set name = "Set Examine Tooltip Delay"
	set desc = ""
	set category = "Preferences"
	set hidden = 1
	if(!holder)
		return
	var/indelay = stripped_input(usr, "Enter the tooltip delay in milliseconds (default: 500)", "Enter tooltip delay", "", 10)
	indelay = text2num(indelay)
	if(usr)//is this what you mean?
		prefs.tip_delay = indelay
		prefs.save_preferences()
		to_chat(usr, "<span class='danger'>Tooltip delay set to [indelay] milliseconds.</span>")
