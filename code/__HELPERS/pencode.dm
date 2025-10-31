#define PAPER_DEFAULT_FONT "Verdana"
#define PAPER_SIGN_FONT "Times New Roman"
#define PAPER_CRAYON_FONT "Comic Sans MS"

GLOBAL_LIST_INIT(pencode_blocked_tags, list("*", "hr", "small", "/small", "list", "/list", "table", "/table", "row", "cell", "logo"))

/proc/parse_pencode(t, obj/item/tool/pen/P, mob/user, is_crayon = FALSE, apply_font = TRUE, blocked_tags = list())
	var/font = is_crayon ? PAPER_CRAYON_FONT : PAPER_DEFAULT_FONT

	// First if crayon
	if(is_crayon)
		blocked_tags += GLOB.pencode_blocked_tags
		// Remove all the blocked tags.

	for(var/i in GLOB.pencode_blocked_tags)
		t = replacetext(t, "\[[i]\]", "")

	t = replacetext(t, "\n", "<br />") // Lets just always do this one

	t = replacetext(t, "\[br\]", "<br />")
	t = replacetext(t, "\[hr\]", "<hr />")
	t = replacetext(t, "\[center\]", "<center>")
	t = replacetext(t, "\[/center\]", "</center>")
	t = replacetext(t, "\[b\]", "<b>")
	t = replacetext(t, "\[/b\]", "</b>")
	t = replacetext(t, "\[i\]", "<i>")
	t = replacetext(t, "\[/i\]", "</i>")
	t = replacetext(t, "\[u\]", "<u>")
	t = replacetext(t, "\[/u\]", "</u>")

	t = replacetext(t, "\[large\]", "<font size='4'>")
	t = replacetext(t, "\[/large\]", "</font>")
	t = replacetext(t, "\[small\]", "<font size='1'>")
	t = replacetext(t, "\[/small\]", "</font>")
	t = replacetext(t, "\[h1\]", "<h1>")
	t = replacetext(t, "\[/h1\]", "</h1>")
	t = replacetext(t, "\[h2\]", "<h2>")
	t = replacetext(t, "\[/h2\]", "</h2>")
	t = replacetext(t, "\[h3\]", "<h3>")
	t = replacetext(t, "\[/h3\]", "</h3>")

	t = replacetext(t, "\[list\]", "<ul>")
	t = replacetext(t, "\[/list\]", "</ul>")
	t = replacetext(t, "\[*\]", "<li>")
	t = replacetext(t, "\[table\]", "<table border='1' cellspacing='0' cellpadding='3 style='border: 1px solid black;'>")
	t = replacetext(t, "\[/table\]", "</td></tr></table>")
	t = replacetext(t, "\[grid\]", "<table>")
	t = replacetext(t, "\[/grid\]", "</td></tr></table>")
	t = replacetext(t, "\[row\]", "</td><tr>")
	t = replacetext(t, "\[cell\]", "<td>")

	t = replacetext(t, "\[sign\]", "<font face=\"[PAPER_SIGN_FONT]\"><i>[user ? user.real_name : "Anonymous"]</i></font>")
	t = replacetext(t, "\[field\]", "<span class=\"paper_field\"></span>")
	t = replacetext(t, "\[logo\]", "<img src='[SSassets.transport.get_asset_url("tgmclogo.png")]' />")
	t = replacetext(t, "\[ntlogo\]", "<img src='[SSassets.transport.get_asset_url("ntlogo.png")]' />")

	t = replacetext(t, "\[mapname\]", "[SSmapping.configs[GROUND_MAP].map_name]")
	t = replacetext(t, "\[shipname\]", "[SSmapping.configs[SHIP_MAP].map_name]")
	t = replacetext(t, "\[date\]", "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")]")
	t = replacetext(t, "\[time\]", "[worldtime2text()]")

	if(apply_font)
		t = "<font face='[font]' color='[P ? P.colour : "black"]'>[t]</font>"

	return t
