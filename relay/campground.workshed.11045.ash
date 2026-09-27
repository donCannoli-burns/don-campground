// campground.workshed.11045.ash
// Model Train Set-specific workshed override.
// KoLmafia dispatches this before campground.workshed.ash, so this file
// provides train-specific status only; the switcher lives on campground.php.
import "relay/don-campground-common.ash";

buffer dc_train_status_panel() {
    int position = get_property("trainsetPosition").to_int();
    int last = get_property("lastTrainsetConfiguration").to_int();
    int remaining = 40 - (position - last);
    if (remaining < 0) remaining = 0;

    string config = get_property("trainsetConfiguration");
    if (config == "") config = "unknown";

    buffer panel;
    panel.append("<div id='don-campground-train-status' style='max-width:760px;margin:10px auto;padding:10px 12px;border:1px solid #7d5c00;background:#fff9dd;font-family:Arial,sans-serif;font-size:13px'>");
    panel.append("<div style='font-weight:bold;margin-bottom:5px'>Model Train Set · KoLmafia state</div>");
    panel.append("<div><b>Tracked position:</b> " + position + "</div>");
    panel.append("<div><b>Last configuration position:</b> " + last + "</div>");
    if (remaining == 0)
        panel.append("<div><b>Reconfiguration:</b> KoLmafia tracking says available</div>");
    else
        panel.append("<div><b>Reconfiguration:</b> " + remaining + " train moves remain</div>");
    panel.append("<div style='margin-top:5px;word-break:break-word'><b>Configuration:</b> " + config.entity_encode() + "</div>");
    panel.append("</div>");
    return panel;
}

void main() {
    buffer results = visit_url();

    // The Model Train Set redirects the workshed request into choice 1485.
    // Preserve the native train controls and add status only.
    if (results.contains_text("Save Train Set Configuration"))
        dc_insert_after_body(results, dc_train_status_panel());

    write(results);
}
