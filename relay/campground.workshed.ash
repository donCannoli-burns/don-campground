// campground.workshed.ash — generic workshed relay override
// KoLmafia dispatches item-specific campground.workshed.<item-id> scripts first.
import "relay/don-campground-common.ash";

void main() {
    string notice = dc_process_workshed_install();

    // Use an explicit canonical workshed GET after a replacement; otherwise
    // preserve the browser's original campground request.
    buffer results = notice == ""
        ? visit_url()
        : visit_url("campground.php?action=workshed");

    dc_annotate_dna(results);
    dc_insert_after_body(results, dc_workshed_panel(notice));
    write(results);
}
