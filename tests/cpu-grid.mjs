import {spawnSync} from "node:child_process";
import assert from "node:assert/strict";
import {numericCases} from "./numeric-cases.mjs";
import {evaluate} from "../web/eval.mjs";

const binary = process.argv[2];
if (!binary) throw new Error("usage: node tests/cpu-grid.mjs /path/to/compiled-cli");
const input = numericCases.map(c =>
  [c.mode,c.cutoff,c.prime,c.point[0],c.point[1]].join(" ")
).join("\n") + "\n";
const run = spawnSync(binary,[],{input,encoding:"utf8"});
assert.equal(run.status,0,run.stderr || "C numerical reference exited nonzero");
const lines = run.stdout.trim().split("\n");
assert.equal(lines.length,numericCases.length,"C result count");
let worstScaled = 0;
numericCases.forEach((c,i) => {
  const actual = lines[i].trim().split(/\s+/).map(Number);
  assert.equal(actual.length,2,"C output columns for row "+i);
  assert.ok(actual.every(Number.isFinite),"C output nonfinite at row "+i);
  const expected = evaluate(c.mode,c.cutoff,c.prime,c.point);
  const scale = Math.max(1,Math.hypot(...expected));
  const error = Math.hypot(actual[0]-expected[0],actual[1]-expected[1]) / scale;
  worstScaled = Math.max(worstScaled,error);
  assert.ok(error < 2e-11,"C11/JS difference in case "+i+
    " "+JSON.stringify({c,expected,actual,error}));
});
console.log(numericCases.length+" C11/JS complex comparisons passed; worst scaled "+
  worstScaled.toExponential(3));
