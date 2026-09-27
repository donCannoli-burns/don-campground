// choice.1485.js — Model Train Set Choice-Override handler
// Choice-Override passes URL-encoded page text as this script's first argument.
const kol = require("kolmafia");

function decorateTrainsetPage(pageText) {
  if (!pageText || !pageText.includes("Save Train Set Configuration")) return pageText;

  const config = kol.getProperty("trainsetConfiguration") || "unknown";
  const position = Number(kol.getProperty("trainsetPosition") || 0);
  const last = Number(kol.getProperty("lastTrainsetConfiguration") || -40);
  const turnsSince = position - last;
  const remaining = Math.max(0, 40 - turnsSince);

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

module.exports.main = function (pageTextEncoded) {
  const choice = require("relay/choice.ash");
  const pageText = choice.choiceOverrideDecodePageText(pageTextEncoded);
  kol.write(decorateTrainsetPage(pageText));
};

module.exports.decorateTrainsetPage = decorateTrainsetPage;
