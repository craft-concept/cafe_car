// Render the CafeCar OG social card (docs/og/card.html) to a 1200x630 PNG.
//
// Usage:
//   node docs/og/render.mjs [output.png]
//
// Defaults to docs/og/card.png. Renders at deviceScaleFactor 2 (2400x1260)
// for crisp text on retina/social crops. Waits for web fonts to load before
// capturing so the Inter wordmark never falls back to a system serif.
//
// Requires Playwright's Chromium (npx playwright install chromium).

import { fileURLToPath, pathToFileURL } from "node:url";
import { dirname, resolve } from "node:path";
import { createRequire } from "node:module";
import { execSync } from "node:child_process";

// Playwright is usually a global install here, not a repo dependency. Resolve
// it from the local node_modules first, then fall back to the global root so
// the script runs without a package.json.
function loadPlaywright() {
  const require = createRequire(import.meta.url);
  const roots = [];
  try { roots.push(execSync("npm root -g", { encoding: "utf8" }).trim()); } catch {}
  for (const paths of [undefined, roots]) {
    try {
      return require(require.resolve("playwright", paths ? { paths } : undefined));
    } catch { /* try next */ }
  }
  throw new Error("Cannot find playwright. Install it: npm i -g playwright && npx playwright install chromium");
}
const { chromium } = loadPlaywright();

const here = dirname(fileURLToPath(import.meta.url));
const htmlPath = resolve(here, "card.html");
const outPath = resolve(process.cwd(), process.argv[2] ?? resolve(here, "card.png"));

const WIDTH = 1200;
const HEIGHT = 630;

const browser = await chromium.launch();
const page = await browser.newPage({
  viewport: { width: WIDTH, height: HEIGHT },
  deviceScaleFactor: 2,
});

await page.goto(`file://${htmlPath}`, { waitUntil: "networkidle" });
// Web fonts load async; without this the wordmark can rasterize as a fallback.
await page.evaluate(() => document.fonts.ready);
await page.waitForTimeout(150);

await page.screenshot({ path: outPath, clip: { x: 0, y: 0, width: WIDTH, height: HEIGHT } });
await browser.close();

console.log(`Wrote ${outPath}`);
