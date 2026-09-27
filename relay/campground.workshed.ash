// campground.workshed.ash — generic workshed relay override
// The switcher lives on campground.php. This page only augments the
// currently installed workshed UI.
import "relay/don-campground-common.ash";

void main() {
    buffer results = visit_url();
    dc_annotate_dna(results);
    write(results);
}
