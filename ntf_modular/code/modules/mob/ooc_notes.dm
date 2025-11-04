/mob
	var/ooc_notes = null
	var/ooc_notes_likes = null
	var/ooc_notes_dislikes = null
	var/ooc_notes_favs = null
	var/ooc_notes_maybes = null
	var/ooc_notes_style = FALSE

/mob/examine(mob/user)
	. = ..()
	if(ooc_notes||ooc_notes_likes||ooc_notes_dislikes||ooc_notes_favs||ooc_notes_maybes)
		. += span_notice("OOC Notes: <a href='?src=\ref[src];ooc_notes=1'>\[View\]</a> - <a href='?src=\ref[src];print_ooc_notes_to_chat=1'>\[Print\]</a>")
	else if(user == src)
		. += "You have not set your OOC Notes yet! <a href='?src=\ref[src];ooc_notes=1'>\[Edit\]</a>"

/mob/verb/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC.Game"
	set src in view()
	ooc_notes_window(usr)
	return

/client/verb/Set_OOC()
	set name = "Set Meta-Info (OOC)"
	set category = "OOC.Game"
	mob.ooc_notes_window(usr)
	return

/mob/proc/set_metainfo_panel(mob/user, reopen = TRUE)
	if(user != src)
		return
	var/new_metadata = tgui_input_text(user, "Enter any information you'd like others to see, such as Roleplay-preferences. This will not be saved permanently unless you click save in the OOC notes panel! Use shift+enter to start a new line.", "Game Preference" , html_decode(ooc_notes), multiline = TRUE, encode = TRUE, timeout = 0)
	if(new_metadata)
		ooc_notes = new_metadata
		client.prefs.metadata = new_metadata
		to_chat(user, span_infoplain("OOC notes updated. Don't forget to save!"))
		if(!isnewplayer(src))
			log_admin("[key_name(user)] updated their OOC notes mid-round.")
		if(reopen)
			ooc_notes_window(user)

/mob/proc/set_metainfo_favs(mob/user, reopen = TRUE)
	if(user != src)
		return
	var/new_metadata = tgui_input_text(user, "Enter any information you'd like others to see relating to your FAVOURITE roleplay preferences. This will not be saved permanently unless you click save in the OOC notes panel! Type \"!clear\" to empty. Use shift+enter to start a new line.", "Game Preference" , html_decode(ooc_notes_favs), multiline = TRUE, encode = TRUE, timeout = 0)
	if(new_metadata)
		if(new_metadata == "!clear")
			new_metadata = ""
		ooc_notes_favs = new_metadata
		client.prefs.metadata_favs = new_metadata
		to_chat(user, span_infoplain("OOC note favs have been updated. Don't forget to save!"))
		if(!isnewplayer(src))
			log_admin("[key_name(user)] updated their OOC note favs mid-round.")
		if(reopen)
			ooc_notes_window(user)

/mob/proc/set_metainfo_likes(mob/user, reopen = TRUE)
	if(user != src)
		return
	var/new_metadata = tgui_input_text(user, "Enter any information you'd like others to see relating to your LIKED roleplay preferences. This will not be saved permanently unless you click save in the OOC notes panel! Type \"!clear\" to empty. Use shift+enter to start a new line.", "Game Preference" , html_decode(ooc_notes_likes), multiline = TRUE, encode = TRUE, timeout = 0)
	if(new_metadata)
		if(new_metadata == "!clear")
			new_metadata = ""
		ooc_notes_likes = new_metadata
		client.prefs.metadata_likes = new_metadata
		to_chat(user, span_infoplain("OOC note likes have been updated. Don't forget to save!"))
		if(!isnewplayer(src))
			log_admin("[key_name(user)] updated their OOC note likes mid-round.")
		if(reopen)
			ooc_notes_window(user)

/mob/proc/set_metainfo_maybes(mob/user, reopen = TRUE)
	if(user != src)
		return
	var/new_metadata = tgui_input_text(user, "Enter any information you'd like others to see relating to your MAYBE roleplay preferences. This will not be saved permanently unless you click save in the OOC notes panel! Type \"!clear\" to empty. Use shift+enter to start a new line.", "Game Preference" , html_decode(ooc_notes_maybes), multiline = TRUE, encode = TRUE, timeout = 0)
	if(new_metadata)
		if(new_metadata == "!clear")
			new_metadata = ""
		ooc_notes_maybes = new_metadata
		client.prefs.metadata_maybes = new_metadata
		to_chat(user, span_infoplain("OOC note maybes have been updated. Don't forget to save!"))
		if(!isnewplayer(src))
			log_admin("[key_name(user)] updated their OOC note maybes mid-round.")
		if(reopen)
			ooc_notes_window(user)

/mob/proc/set_metainfo_dislikes(mob/user, reopen = TRUE)
	if(user != src)
		return
	var/new_metadata = tgui_input_text(user, "Enter any information you'd like others to see relating to your DISLIKED roleplay preferences. This will not be saved permanently unless you click save in the OOC notes panel! Type \"!clear\" to empty. Use shift+enter to start a new line.", "Game Preference" , html_decode(ooc_notes_dislikes), multiline = TRUE, encode = TRUE, timeout = 0)
	if(new_metadata)
		if(new_metadata == "!clear")
			new_metadata = ""
		ooc_notes_dislikes = new_metadata
		client.prefs.metadata_dislikes = new_metadata
		to_chat(user, span_infoplain("OOC note dislikes have been updated. Don't forget to save!"))
		if(!isnewplayer(src))
			log_admin("[key_name(user)] updated their OOC note dislikes mid-round.")
		if(reopen)
			ooc_notes_window(user)

/mob/proc/set_metainfo_ooc_style(mob/user, reopen = TRUE)
	if(user != src)
		return
	ooc_notes_style = !ooc_notes_style
	client.prefs.metadata_ooc_style = !client.prefs.metadata_ooc_style
	if(reopen)
		ooc_notes_window(user)

/mob/proc/save_ooc_panel(mob/user)
	if(user != src)
		return
	if(client.prefs.real_name != real_name && !isxeno(src) && !isnewplayer(src))
		to_chat(user, span_danger("Your selected character slot name is not the same as your character's name. Aborting save. Please select [real_name]'s character slot in character setup before saving."))
		return
	if(client.prefs.save_character())
		to_chat(user, span_infoplain("Character preferences saved."))

/mob/proc/print_ooc_notes_to_chat(mob/user)
	var/msg = ooc_notes
	if(ooc_notes_favs)
		msg += "<br><br><b>[span_blue("FAVOURITES")]</b><br>[ooc_notes_favs]"
	if(ooc_notes_likes)
		msg += "<br><br><b>[span_green("LIKES")]</b><br>[ooc_notes_likes]"
	if(ooc_notes_maybes)
		msg += "<br><br><b>[span_yellow("MAYBES")]</b><br>[ooc_notes_maybes]"
	if(ooc_notes_dislikes)
		msg += "<br><br><b>[span_red("DISLIKES")]</b><br>[ooc_notes_dislikes]"
	to_chat(user, span_infoplain("<b>[src]'s Metainfo:</b><br>[msg]"))

/mob/proc/ooc_notes_window(mob/user)
	var/notes = replacetext(src.ooc_notes, "\n", "<BR>")
	var/favs = replacetext(src.ooc_notes_favs, "\n", "<BR>")
	var/likes = replacetext(src.ooc_notes_likes, "\n", "<BR>")
	var/maybes = replacetext(src.ooc_notes_maybes, "\n", "<BR>")
	var/dislikes = replacetext(src.ooc_notes_dislikes, "\n", "<BR>")
	var/style = src.ooc_notes_style
	var/dat = {"
	<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
	<html>
		<head>
			<style>
				* {
				box-sizing: border-box;
				}
				.collapsible {
					background-color: #1a1e3f;
					color: white;
					width: 100%;
					text-align: left;
					font-size: 20px;
				}
				.collapsible_a {
					background-color: #263d20;
					color: white;
					width: 100%;
					text-align: left;
					font-size: 20px;
				}
				.collapsible_b {
					background-color: #3e3f1a;
					color: white;
					width: 100%;
					text-align: left;
					font-size: 20px;
				}
				.collapsible_c {
					background-color: #3f1a1a;
					color: white;
					width: 100%;
					text-align: left;
					font-size: 20px;
				}
				.content {
					padding: 5;
					width: 100%;
					background-color: #363636;
				}
				.column {
					verflow-wrap: break-word;
					float: left;
					width: 25%;
				}

				.row:after {
					content: "";
					display: table;
					clear: both;
				}

				</style>
			</head>"}

	dat += {"<body><table>"}
	if(user == src)
		dat += {"
			<td class="button">
				<a href='byond://?src=\ref[src];save_ooc_panel=1' class='button'>Save Character Preferences</a>
			</td>
			"}
	dat += {"
			<td class="button">
				<a href='byond://?src=\ref[src];print_ooc_notes_to_chat=1' class='button'>Print to chat</a>
			</td>
			"}
	if(user == src)
		if(style)
			dat += {"
				<td class="button">
					<a href='byond://?src=\ref[src];set_metainfo_ooc_style=1' class='button'>Rows</a>
				</td>
				"}
		else
			dat += {"
				<td class="button">
					<a href='byond://?src=\ref[src];set_metainfo_ooc_style=1' class='button'>Columns</a>
				</td>
				"}
	dat += {"</table>"}

	if(user == src)
		dat += {"
				<br>
				<table>
					<td class="button">
						<a href='byond://?src=\ref[src];edit_ooc_notes=1' class='button'>Edit</a>
					</td>
				</table>
				"}

	dat += {"
		<br>
			<div class="content">
				<p>[notes]</p>
			</div>
		<br>
		<head>
		<meta name="viewport" content="width=device-width, initial-scale=1">"}
	if(style)
		dat += {"<div class='row'><div class='column'>"}
	if(favs || user == src)
		dat += "<div class=\"collapsible\">" + span_bold("<center>Favourites</center>") + "</div>"
	if(user == src)
		dat += {"
				<table>
					<td class="button">
						<a href='byond://?src=\ref[src];edit_ooc_note_favs=1' class='button'>Edit</a>
					</td>
				</table>
				"}

	if(favs)
		dat += {"
			<div class="content">
			<p>[favs]</p>
			</div>"}

	if(style)
		dat += {"</div>"}
		dat += {"<div class='column'>"}
	if(likes || user == src)
		dat += "<div class=\"collapsible_a\">" + span_bold("<center>Likes</center>") + "</div>"
	if(user == src)
		dat += {"
				<table>
					<td class="button">
						<a href='byond://?src=\ref[src];edit_ooc_note_likes=1' class='button'>Edit</a>
					</td>
				</table>
				"}

	if(likes)
		dat += {"
			<div class="content">
				<p>[likes]</p>
			</div>"}

	if(style)
		dat += {"</div>"}
		dat += {"<div class='column'>"}
	if(maybes || user == src)
		dat += "<div class=\"collapsible_b\">" + span_bold("<center>Maybes</center>") + "</div>"
	if(user == src)
		dat += {"
				<table>
					<td class="button">
						<a href='byond://?src=\ref[src];edit_ooc_note_maybes=1' class='button'>Edit</a>
					</td>
				</table>
				"}

	if(maybes)
		dat += {"
			<div class="content">
				<p>[maybes]</p>
			</div>
			"}


	if(style)
		dat += {"</div>"}
		dat += {"<div class='column'>"}
	if(dislikes || user == src)
		dat += "<div class=\"collapsible_c\">" + span_bold("<center>Dislikes</center>") + "</div>"
	if(user == src)
		dat += {"
				<table>
					<td class="button">
						<a href='byond://?src=\ref[src];edit_ooc_note_dislikes=1' class='button'>Edit</a>
					</td>
				</table>
				"}

	if(dislikes)
		dat += {"
			<div class="content">
				<p>[dislikes]</p>
			</div>
			"}
	if(style)
		dat += {"</div></div>"}
	dat+= {"	</body>
			</html>"}

	var/key = "ooc_notes[isnewplayer(src) ? (client?.prefs?.real_name) : src.real_name]"	//Generate a unique key so we can make unique clones of windows, that way we can have more than one
	if(src.ckey)
		key = "[key][src.ckey]"				//Add a ckey if they have one, in case their name is the same

	winclone(user, "ooc_notes", key)		//Allows us to have more than one OOC notes panel open

	winshow(user, key, TRUE)				//Register our window
	var/datum/browser/popup = new(user, key, "OOC Notes: [isnewplayer(src) ? (client?.prefs?.real_name) : src.name]", 500, 600)		//Create the window
	popup.set_content(dat)	//Populate window contents
	popup.open(FALSE) // Skip registring onclose on the browser pane
	onclose(user, key, src) // We want to register on the window itself

/mob/Topic(href, href_list)
	if(href_list["ooc_notes"])
		ooc_notes_window(usr)
	if(href_list["edit_ooc_notes"])
		if(usr == src)
			set_metainfo_panel(usr)
	if(href_list["edit_ooc_note_likes"])
		if(usr == src)
			set_metainfo_likes(usr)
	if(href_list["edit_ooc_note_dislikes"])
		if(usr == src)
			set_metainfo_dislikes(usr)
	if(href_list["save_ooc_panel"])
		if(usr == src)
			save_ooc_panel(usr)
	if(href_list["print_ooc_notes_to_chat"])
		print_ooc_notes_to_chat(usr)
	if(href_list["edit_ooc_note_favs"])
		if(usr == src)
			set_metainfo_favs(usr)
	if(href_list["edit_ooc_note_maybes"])
		if(usr == src)
			set_metainfo_maybes(usr)
	if(href_list["set_metainfo_ooc_style"])
		if(usr == src)
			set_metainfo_ooc_style(usr)
	return ..()
