// familiar.ash — quick familiar selector for the native terrarium page
// Builds its options from KoL's own currently-selectable familiar rows and
// submits the same action=newfam/newfam=<id> form the native page uses.
import "relay/don-campground-common.ash";

buffer dc_quick_familiar_panel(buffer page) {
    buffer options;

    // Only usable familiar rows contain the native newfam radio control.
    // Preserving source order also preserves KoL's favorite/non-favorite ordering.
    matcher rows = create_matcher(
        "(?s)<tr class=[\"']frow [^\"']*[\"'][^>]*>.*?name=newfam value=[\"']?([0-9]+)[\"']?.*?<b>(.*?)</b>, the ([^<(]+?) \\(",
        page
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

    string current = my_familiar().to_string();

    buffer panel;
    panel.append("<div id='don-campground-quick-familiar' style='max-width:760px;margin:10px auto;padding:9px 12px;border:1px solid #6b5aa6;background:#faf8ff;font-family:Arial,sans-serif;font-size:13px'>");
    panel.append("<div style='font-weight:bold;margin-bottom:6px'>Quick familiar</div>");
    panel.append("<div style='margin-bottom:6px'>Current: <b>");
    panel.append(current.entity_encode());
    panel.append("</b></div>");
    panel.append("<form name='doncamp_quickfam' method='post' action='familiar.php' style='margin:0'>");
    panel.append("<input type='hidden' name='action' value='newfam'>");
    panel.append("<select name='newfam' onchange=\"if(this.value){this.form.submit();}\">");
    panel.append("<option value='' selected>-- choose familiar --</option>");
    panel.append(options);
    panel.append("</select>");
    panel.append("</form>");
    panel.append("<div style='margin-top:5px;color:#666;font-size:11px'>Uses KoL's native familiar switch action; the list contains only familiars KoL currently exposes as selectable.</div>");
    panel.append("</div>");
    return panel;
}

void main() {
    buffer results = visit_url();

    buffer panel = dc_quick_familiar_panel(results);
    if (length(panel) > 0)
        dc_insert_after_body(results, panel);

    write(results);
}
