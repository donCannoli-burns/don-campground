// campground.ash — modernized base campground relay override
import "relay/don-campground-common.ash";

void dc_telescope(buffer results) {
    if (results.contains_text("You point your telescope toward the Naughty Sorceress' Tower and look through it")) {
        int i1 = results.index_of("You see a group of people");
        if (i1 < 0) return;

        int tail = results.index_of("</td></tr></table>", i1);
        if (tail > i1) results.delete(i1, tail);

        if (get_property("lastTelescopeReset") != get_property("knownAscensions"))
            cli_execute("telescope");

        switch (get_property("telescopeUpgrades").to_int()) {
        case 7: case 6: case 5:
            results.insert(i1, "<p>Third Maze trap tests " + dc_span_element(get_property("nsChallenge5")) + " resistance.");
        case 4:
            results.insert(i1, "<p>Second Maze trap tests " + dc_span_element(get_property("nsChallenge4")) + " resistance.");
        case 3:
            results.insert(i1, "<p>First Maze trap tests " + dc_span_element(get_property("nsChallenge3")) + " resistance.");
        case 2:
            results.insert(i1, "<p>Third crowd is testing for most weapon and spell " + dc_span_element(get_property("nsChallenge2")) + " damage.");
        case 1:
            results.insert(i1, "<p>Second crowd is testing to find the adventurer with the highest <b>" + get_property("nsChallenge1").entity_encode() + "</b>.");
            results.insert(i1, "<p>First crowd is testing to find the adventurer with the highest Initiative.");
        }
    } else if (
        get_property("telescopeUpgrades").to_int() != 0 &&
        !in_bad_moon() &&
        my_path() != $path[Nuclear Autumn]
    ) {
        results.replace_string(
            "<body>\n<centeR>",
            "<body>\n<centeR><a target=mainpane href='campground.php?action=telescopelow'>Peer at Sorceress' Lair</a>"
        );
    }
}

void dc_bookshelf(buffer results) {
    string style = "<span style='font-weight:bold;color:#0073e5'>";

    if (can_interact()) {
        results.replace_string("You have a Tome of Snowcone Summoning.", "You have a Tome of Snowcone Summoning (" + style + get_property("_snowconeSummons") + "/3</span>)");
        results.replace_string("You have a Tome of Sticker Summoning.", "You have a Tome of Sticker Summoning (" + style + get_property("_stickerSummons") + "/3</span>)");
        results.replace_string("You have a Tome of Sugar Shummoning.", "You have a Tome of Sugar Shummoning (" + style + get_property("_sugarSummons") + "/3</span>)");
        results.replace_string("You have a Tome of Clip Art.", "You have a Tome of Clip Art (" + style + get_property("_clipartSummons") + "/3</span>)");
        results.replace_string("You have a Tome of Rad Libs", "You have a Tome of Rad Libs (" + style + get_property("_radlibSummons") + "/3</span>)");
        results.replace_string("You have a copy of The Smith's Tome", "You have a copy of The Smith's Tome (" + style + get_property("_smithsnessSummons") + "/3</span>)");
    } else {
        results.replace_string("<p><b>Tomes:</b> ", "<p><b>Tomes</b> (" + style + get_property("tomeSummons") + "/3</span>)<b>:</b>");
    }

    results.replace_string("<p><b>Librams:</b>", "<p><b>Librams</b> (" + style + get_property("libramSummons") + " / &infin;</span>)<b>:</b>");
}

buffer dc_trendy(buffer results) {
    buffer rebuild;
    matcher old = create_matcher("You have (?:a )?([^.]+).<p>But, that item is too old to be used on this path.", results);
    while (old.find())
        old.append_replacement(rebuild, "Your " + old.group(1) + " is too old to use.<p>");
    old.append_tail(rebuild);
    return rebuild;
}

boolean [item] dc_garden_seed_items() {
    return $items[
        packet of pumpkin seeds,
        Peppermint Pip Packet,
        packet of dragon's teeth,
        packet of beer seeds,
        packet of winter seeds,
        packet of thanksgarden seeds,
        packet of tall grass seeds,
        packet of mushroom spores,
        packet of rock seeds
    ];
}

string dc_process_garden_install() {
    string raw = form_field("doncamp_garden");
    if (raw == "") return "";

    item target = raw.to_int().to_item();
    boolean [item] supported = dc_garden_seed_items();
    if (!(supported contains target)) return "Refused unknown garden seed selection.";
    if (available_amount(target) <= 0) return "That garden seed packet is not currently available.";

    boolean ok = use(1, target);
    return ok ? "Planted " + target + "." : "KoLmafia did not confirm the garden replacement.";
}

buffer dc_garden_panel(string notice) {
    boolean [item] seeds = dc_garden_seed_items();
    buffer options;
    foreach it in seeds {
        if (available_amount(it) <= 0) continue;
        options.append("<option value='");
        options.append(it.to_int());
        options.append("'>");
        options.append(it.to_string().entity_encode());
        options.append("</option>");
    }

    if (length(options) == 0 && notice == "") return "".to_buffer();

    buffer panel;
    panel.append("<div id='don-campground-garden-panel' style='max-width:760px;margin:10px auto;padding:8px 12px;border:1px solid #6a8d39;background:#f7fff0;font-family:Arial,sans-serif;font-size:13px'>");
    panel.append("<b>Garden switcher</b>");
    if (notice != "") panel.append("<div style='margin-top:5px;color:#174a17'><b>" + notice.entity_encode() + "</b></div>");
    if (length(options) > 0) {
        panel.append("<form method='post' action='campground.php' style='margin-top:6px' onsubmit=\"return confirm('Replace your current garden?');\">");
        panel.append("<select name='doncamp_garden'><option value=''>-- plant a different garden --</option>");
        panel.append(options);
        panel.append("</select> <input type='submit' value='Plant'></form>");
    }
    panel.append("</div>");
    return panel;
}

void main() {
    if (my_path() == $path[Actually Ed the Undying]) {
        write(visit_url("place.php?whichplace=edbase"));
        return;
    }

    string familiar_notice = dc_process_familiar_switch();
    string garden_notice = dc_process_garden_install();
    string workshed_notice = dc_process_workshed_install();

    // After one of our local forms mutates state, fetch a clean canonical
    // campground page rather than forwarding private form fields to KoL.
    buffer results = (familiar_notice != "" || garden_notice != "" || workshed_notice != "")
        ? visit_url("campground.php")
        : visit_url();
    string action = form_field("action");

    dc_telescope(results);
    if (action == "bookshelf") dc_bookshelf(results);
    results = dc_trendy(results);

    // Campground layout:
    //   top    -> quick familiar
    //   bottom -> garden + workshed controls in otherwise-unused pane space
    if (action == "") {
        // Read the terrarium server-side only to discover KoL's currently
        // selectable familiars. The browser itself never leaves campground.php.
        buffer familiar_page = visit_url("familiar.php");
        buffer familiar_panel = dc_quick_familiar_panel(familiar_page, familiar_notice);
        if (length(familiar_panel) > 0)
            dc_insert_after_body(results, familiar_panel);

        buffer bottom_controls;
        buffer garden = dc_garden_panel(garden_notice);
        buffer workshed = dc_workshed_panel(workshed_notice);
        if (length(garden) > 0) bottom_controls.append(garden);
        if (length(workshed) > 0) bottom_controls.append(workshed);
        if (length(bottom_controls) > 0)
            dc_insert_before_body_end(results, bottom_controls);
    }

    write(results);
}
