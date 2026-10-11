import {spawnSync} from "node:child_process";
import assert from "node:assert/strict";
import {
  characterCount, generateCharacter, characterValue,
  finiteCharacterSum, finiteCharacterLocal, finiteCharacterProduct
} from "../web/characters.mjs";

const executable=process.argv[2];
if (!executable) throw new Error("usage: node tests/characters-cpu-grid.mjs /path/to/c-cli");
const cases=[];
function add(q,index,mode,cutoff,prime,s) {
  cases.push({q,index,mode,cutoff,prime,s});
}
for (const q of [1,2,3,4,5,7,8,9,12,15,16,21,24,27,32,45,64,81,96,105,120,127,128]) {
  const count=characterCount(q);
  for (const index of new Set([0,1,Math.floor(count/2),count-1].filter(k=>k<count))) {
    for (const n of new Set([0,1,2,q-1,q,q+1,127]))
      add(q,index,0,n,2,[2,0]);
    for (const n of [0,3,31,127])
      for (const s of [[2,0],[1.2,0.3],[0.75,-0.2]])
        add(q,index,1,n,2,s);
    for (const p of [2,3,5,7,31])
      for (const s of [[2,0],[1.3,0.4]])
        add(q,index,2,0,p,s);
    for (const lastPrime of [0,3,13,31])
      for (const s of [[2,0],[1.4,0.2]])
        add(q,index,3,lastPrime,2,s);
  }
}
const input=cases.map(c=>[
  c.q,c.index,c.mode,c.cutoff,c.prime,c.s[0],c.s[1]
].join(" ")).join("\n")+"\n";
const run=spawnSync(executable,[],{input,encoding:"utf8",maxBuffer:8*1024*1024});
assert.equal(run.status,0,run.stderr||"generated C oracle failed");
const rows=run.stdout.trim().split("\n");
assert.equal(rows.length,cases.length,"C row count");
let worst=0;
for (let i=0;i<cases.length;i++) {
  const c=cases[i];
  const d=generateCharacter(c.q,c.index);
  const expected=c.mode===0?characterValue(d,c.cutoff):
    c.mode===1?finiteCharacterSum(d,c.cutoff,c.s):
    c.mode===2?finiteCharacterLocal(d,c.prime,c.s):
    finiteCharacterProduct(d,c.cutoff,c.s);
  const actual=rows[i].split(/\s+/).map(Number);
  assert.equal(actual.length,6,"output columns at "+i);
  assert.deepEqual(actual.slice(0,4),[
    d.phaseDenominator,d.valueOrder,d.conductor,d.parity
  ],"integer metadata at "+i);
  const observed=actual.slice(4);
  assert.ok(observed.every(Number.isFinite),"nonfinite C output at "+i);
  const scale=Math.max(1,Math.hypot(...expected));
  const relative=Math.hypot(observed[0]-expected[0],observed[1]-expected[1])/scale;
  worst=Math.max(worst,relative);
  assert.ok(relative<2e-11,
    "C/JS generated-character parity "+JSON.stringify({i,c,observed,expected,relative}));
}
console.log(cases.length+" generated C11/JS comparisons passed; worst scaled "+
  worst.toExponential(3));
