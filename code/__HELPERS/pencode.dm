#define PAPER_DEFAULT_FONT "Verdana"
#define PAPER_SIGN_FONT "Times New Roman"
#define PAPER_CRAYON_FONT "Comic Sans MS"

/proc/parse_pencode(t, obj/item/tool/pen/P, mob/user as mob, is_crayon = FALSE)
	var/font = is_crayon ? PAPER_DEFAULT_FONT : PAPER_CRAYON_FONT

	// First if crayon, removed things not allowed
	if(is_crayon)
		t = oldreplacetext(t, "\[*\]", "")
		t = oldreplacetext(t, "\[hr\]", "")
		t = oldreplacetext(t, "\[small\]", "")
		t = oldreplacetext(t, "\[/small\]", "")
		t = oldreplacetext(t, "\[list\]", "")
		t = oldreplacetext(t, "\[/list\]", "")
		t = oldreplacetext(t, "\[table\]", "")
		t = oldreplacetext(t, "\[/table\]", "")
		t = oldreplacetext(t, "\[row\]", "")
		t = oldreplacetext(t, "\[cell\]", "")
		t = oldreplacetext(t, "\[logo\]", "")

	t = oldreplacetext(t, "\n", "<br />") // Lets just always do this one

	t = oldreplacetext(t, "\[center\]", "<center>")
	t = oldreplacetext(t, "\[/center\]", "</center>")
	t = oldreplacetext(t, "\[br\]", "<br />")
	t = oldreplacetext(t, "\[b\]", "<b>")
	t = oldreplacetext(t, "\[/b\]", "</b>")
	t = oldreplacetext(t, "\[i\]", "<i>")
	t = oldreplacetext(t, "\[/i\]", "</i>")
	t = oldreplacetext(t, "\[u\]", "<u>")
	t = oldreplacetext(t, "\[/u\]", "</u>")
	t = oldreplacetext(t, "\[large\]", "<font size=\"4\">")
	t = oldreplacetext(t, "\[/large\]", "</font>")
	t = oldreplacetext(t, "\[sign\]", "<font face=\"[PAPER_SIGN_FONT]\"><i>[user ? user.real_name : "Anonymous"]</i></font>")
	t = oldreplacetext(t, "\[field\]", "<span class=\"paper_field\"></span>")

	t = oldreplacetext(t, "\[h1\]", "<h1>")
	t = oldreplacetext(t, "\[/h1\]", "</h1>")
	t = oldreplacetext(t, "\[h2\]", "<h2>")
	t = oldreplacetext(t, "\[/h2\]", "</h2>")
	t = oldreplacetext(t, "\[h3\]", "<h3>")
	t = oldreplacetext(t, "\[/h3\]", "</h3>")

	t = oldreplacetext(t, "\[*\]", "<li>")
	t = oldreplacetext(t, "\[hr\]", "<HR>")
	t = oldreplacetext(t, "\[small\]", "<font size = \"1\">")
	t = oldreplacetext(t, "\[/small\]", "</font>")
	t = oldreplacetext(t, "\[list\]", "<ul>")
	t = oldreplacetext(t, "\[/list\]", "</ul>")
	t = oldreplacetext(t, "\[table\]", "<table border=1 cellspacing=0 cellpadding=3 style='border: 1px solid black;'>")
	t = oldreplacetext(t, "\[/table\]", "</td></tr></table>")
	t = oldreplacetext(t, "\[grid\]", "<table>")
	t = oldreplacetext(t, "\[/grid\]", "</td></tr></table>")
	t = oldreplacetext(t, "\[row\]", "</td><tr>")
	t = oldreplacetext(t, "\[cell\]", "<td>")
	t = oldreplacetext(t, "\[logo\]", "<img src='ntlogo.png' />")
	t = oldreplacetext(t, "\[date\]", "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")]")

	t = "<font face=\"[font]\" color=[P ? P.colour : "black"]><b>[t]</b></font>"

	return t
