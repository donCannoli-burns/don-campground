// Optional TypeScript source for the runtime relay/choice.1485.js file.
// Compile/transpile to KoLmafia-compatible CommonJS if you integrate this into
// a normal Loathers TypeScript toolchain. The checked-in JS remains the runtime artifact.
import { getProperty, write } from "kolmafia";

// Choice-Override's ASH helper is required dynamically at runtime because it is
// an ASH module rather than a TypeScript package.
declare const require: (name: string) => any;

export function decorateTrainsetPage(pageText: string): string {
  if (!pageText || !pageText.includes("Save Train Set Configuration")) return pageText;

  const config = getProperty("trainsetConfiguration") || "unknown";
  const position = Number(getProperty("trainsetPosition") || 0);
  const last = Number(getProperty("lastTrainsetConfiguration") || -40);
  const remaining = Math.max(0, 40 - (position - last));

  const panel = `
<div id="don-campground-train-status" style="max-width:760px;margin:10px auto;padding:10px 12px;border:1px solid #7d5c00;background:#fff9dd;font-family:Arial,sans-serif;font-size:13px">
  <div style="font-weight:bold;margin-bottom:5px">Model Train Set · KoLmafia state</div>
  <div><b>Tracked position:</b> ${position}</div>
  <div><b>Last configuration position:</b> ${last}</div>
  <div><b>Reconfiguration:</b> ${remaining === 0 ? "KoLmafia tracking says available" : `${remaining} train moves remain`}</div>
  <div style="margin-top:5px;word-break:break-word"><b>Configuration:</b> ${config}</div>
</div>`;

  const body = pageText.search(/<body[^>]*>/i);
  if (body >= 0) {
    const end = pageText.indexOf(">", body);
    if (end >= 0) return pageText.slice(0, end + 1) + panel + pageText.slice(end + 1);
  }
  return panel + pageText;
}

export function main(pageTextEncoded: string): void {
  const choiceOverride = require("relay/choice.ash");
  const pageText = choiceOverride.choiceOverrideDecodePageText(pageTextEncoded);
  write(decorateTrainsetPage(pageText));
}
