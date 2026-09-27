// don-campground-common.ash
// Shared helpers for the modernized campground relay bundle.
// Grounded against current KoLmafia runtime functions and relay dispatch.

buffer dc_span_element(string el) {
    string color;
    switch (el) {
    case "hot": color = "red"; break;
    case "spooky": color = "gray"; break;
    case "sleaze": color = "blueviolet"; break;
    case "stench": color = "green"; break;
    case "cold": color = "blue"; break;
    default: color = "";
    }

    string label = el;
    if (length(label) > 0) {
        string first = char_at(label, 0);
        label = replace_string(label, first, to_upper_case(first));
    }

    buffer span;
    span.append("<span style='font-weight:bold;color:");
    span.append(color);
    span.append("'>");
    span.append(label.entity_encode());
    span.append("</span>");
    return span;
}

string dc_tonic_description(string hybrid) {
    switch (hybrid) {
    case "Beast": return "Weapon Damage +30";
    case "Insect": return "+25% Combat Initiative";
    case "Constellation": return "+50% Meat from Monsters";
    case "Machine": return "Damage Absorption +50<br>Damage Reduction: 5<br>+5 to Familiar Weight";
    case "Demon": return "+20 <span style='color:red'>Hot Damage</span><br>+20 Damage to <span style='color:red'>Hot Spells</span>";
    case "Human": return "Muscle +10<br>Mysticality +10<br>Moxie +10<br>+10% Item Drops from Monsters";
    case "Elemental": return "Serious Hot Resistance (+3)<br>Serious Cold Resistance (+3)<br>Serious Stench Resistance (+3)<br>Serious Spooky Resistance (+3)<br>Serious Sleaze Resistance (+3)";
    case "Elf": return "+50% Candy Drops from Monsters<br>Spell Damage +100%";
    case "Fish": return "+10 to Familiar Weight";
    case "Goblin": return "+50% Food Drops from Monsters<br>+20% Pickpocket Chance";
    case "Hippy": return "Maximum MP +20<br>+1 Stats Per Fight";
    case "Hobo": return "+20 <span style='color:green'>Stench Damage</span><br>+20 Damage to <span style='color:green'>Stench Spells</span>";
    case "Horror": return "+10% chance of Critical Hit<br>+10% chance of Spell Critical Hit";
    case "Humanoid": return "Muscle +10%<br>Mysticality +10%<br>Moxie +10%<br>+20% Meat from Monsters";
    case "Mer-kin": return "+25 to Monster Level";
    case "Orc": return "Maximum HP +40<br>+1 Stats Per Fight";
    case "Penguin": return "+25% Item Drops from Monsters";
    case "Pirate": return "+50% Gear Drops from Monsters<br>+50% Booze Drops from Monsters";
    case "Plant": return "+20 Cold Damage<br>+20 Damage to Cold Spells";
    case "Slime": return "+20 <span style='color:blueviolet'>Sleaze Damage</span><br>+20 Damage to <span style='color:blueviolet'>Sleaze Spells</span>";
    case "Undead": return "+20 <span style='color:gray'>Spooky Damage</span><br>+20 Damage to <span style='color:gray'>Spooky Spells</span>";
    case "Weird Thing": return "+4 Stats Per Fight";
    }
    return "";
}

boolean [item] dc_supported_workshed_items() {
    // Current KoLmafia CampgroundRequest workshed registry (2026 source).
    return $items[
        warbear chemistry lab,
        warbear induction oven,
        warbear LP-ROM burner,
        warbear high-efficiency still,
        warbear auto-anvil,
        warbear jackhammer drill press,
        snow machine,
        spinning wheel,
        Little Geneticist DNA-Splicing Lab,
        portable Mayo Clinic,
        Asdon Martin keyfob (on ring),
        diabolic pizza cube,
        cold medicine cabinet,
        model train set,
        TakerSpace letter of Marque
    ];
}

boolean dc_is_supported_workshed(item candidate) {
    boolean [item] supported = dc_supported_workshed_items();
    return supported contains candidate;
}

buffer dc_workshed_panel(string notice) {
    item current = get_workshed();
    boolean already_swapped = get_property("_workshedItemUsed").to_boolean();
    boolean [item] supported = dc_supported_workshed_items();

    buffer panel;
    panel.append("<div id='don-campground-workshed-panel' style='max-width:760px;margin:10px auto;padding:10px 12px;border:1px solid #4169e1;background:#f7f8ff;font-family:Arial,sans-serif;font-size:13px'>");
    panel.append("<div style='font-weight:bold;margin-bottom:6px'>Workshed switcher</div>");

    if (current == $item[none])
        panel.append("<div>Current workshed: <b>empty</b></div>");
    else
        panel.append("<div>Current workshed: <b>" + current.to_string().entity_encode() + "</b></div>");

    if (notice != "")
        panel.append("<div style='margin-top:6px;color:#174a17'><b>" + notice.entity_encode() + "</b></div>");

    if (already_swapped) {
        panel.append("<div style='margin-top:8px;color:#777'>You have already replaced your workshed item today.</div>");
        panel.append("</div>");
        return panel;
    }

    buffer options;
    foreach it in supported {
        if (it == current) continue;
        if (available_amount(it) <= 0) continue;
        options.append("<option value='");
        options.append(it.to_int());
        options.append("'>");
        options.append(it.to_string().entity_encode());
        options.append(" (available: ");
        options.append(available_amount(it));
        options.append(")</option>");
    }

    if (length(options) == 0) {
        panel.append("<div style='margin-top:8px;color:#777'>No other supported workshed item is currently available to install.</div>");
        panel.append("</div>");
        return panel;
    }

    panel.append("<form method='post' action='campground.php' style='margin-top:8px' onsubmit=\"return confirm('Replace your current workshed item? KoL only allows one replacement per day.');\">");
    panel.append("<label for='doncamp_install'><b>Replace with:</b></label> ");
    panel.append("<select name='doncamp_install' id='doncamp_install'><option value=''>-- choose --</option>");
    panel.append(options);
    panel.append("</select> <input type='submit' value='Install'>");
    panel.append("</form></div>");
    return panel;
}

void dc_insert_after_body(buffer page, buffer fragment) {
    int body = page.index_of("<body");
    if (body < 0) {
        page.insert(0, fragment);
        return;
    }
    int close = page.index_of(">", body);
    if (close < 0) {
        page.insert(0, fragment);
        return;
    }
    page.insert(close + 1, fragment);
}

void dc_insert_before_body_end(buffer page, buffer fragment) {
    int body_end = page.index_of("</body>");
    if (body_end < 0) {
        page.append(fragment);
        return;
    }
    page.insert(body_end, fragment);
}

buffer dc_quick_familiar_panel(buffer familiar_page) {
    buffer options;

    // Only rows with KoL's native newfam radio control are currently selectable.
    // Source order preserves KoL's favorite/non-favorite ordering.
    matcher rows = create_matcher(
        "(?s)<tr class=[\"']frow [^\"']*[\"'][^>]*>.*?name=newfam value=[\"']?([0-9]+)[\"']?.*?<b>(.*?)</b>, the ([^<(]+?) \\(",
        familiar_page
    );

    while (rows.find()) {
        string familiar_id = rows.group(1);
        string nickname = rows.group(2).entity_decode();
        string detail = rows.group(3).entity_decode();

        options.append("<option value='");
        options.append(familiar_id);
        options.append("'>");
        options.append(nickname.entity_encode());
        options.append(" — ");
        options.append(detail.entity_encode());
        options.append("</option>");
    }

    if (length(options) == 0) return "".to_buffer();

    buffer panel;
    panel.append("<div id='don-campground-quick-familiar' style='max-width:760px;margin:10px auto;padding:9px 12px;border:1px solid #6b5aa6;background:#faf8ff;font-family:Arial,sans-serif;font-size:13px'>");
    panel.append("<div style='font-weight:bold;margin-bottom:6px'>Quick familiar</div>");
    panel.append("<div style='margin-bottom:6px'>Current: <b>");
    panel.append(my_familiar().to_string().entity_encode());
    panel.append("</b></div>");
    panel.append("<form name='doncamp_quickfam' method='post' action='familiar.php' style='margin:0'>");
    panel.append("<input type='hidden' name='action' value='newfam'>");
    panel.append("<select name='newfam' onchange=\"if(this.value){this.form.submit();}\">");
    panel.append("<option value='' selected>-- choose familiar --</option>");
    panel.append(options);
    panel.append("</select>");
    panel.append("</form>");
    panel.append("</div>");
    return panel;
}

string dc_process_workshed_install() {
    string raw = form_field("doncamp_install");
    if (raw == "") return "";

    item target = raw.to_int().to_item();
    item before = get_workshed();

    if (!dc_is_supported_workshed(target))
        return "Refused unknown/non-workshed item selection.";
    if (target == before)
        return target + " is already installed.";
    if (get_property("_workshedItemUsed").to_boolean())
        return "KoLmafia reports that today's workshed replacement has already been used.";
    if (available_amount(target) <= 0)
        return "That workshed item is not currently available.";

    boolean ok = use(1, target);
    item after = get_workshed();
    if (ok && after == target)
        return "Installed " + target + ".";
    if (after == target)
        return "Installed " + target + ".";
    return "KoLmafia did not confirm the workshed replacement; no success is being assumed.";
}

void dc_annotate_dna(buffer page) {
    matcher dna = create_matcher("itemimages/dna\\.gif[^;]+;' border=0></td><td>(<b>Human-(.+?) Hybrid</b></td></tr></table>)", page);
    if (!dna.find()) return;

    string description = dc_tonic_description(dna.group(2));
    if (description == "") return;

    page.insert(
        index_of(page, dna.group(1)) + length(dna.group(1)),
        "<div style='border:solid 1px DarkBlue;display:inline-block;margin-top:-18px;padding:7px;color:blue;font-weight:bold;text-align:center;font-size:90%;'>" +
        description +
        "</div>"
    );
}
