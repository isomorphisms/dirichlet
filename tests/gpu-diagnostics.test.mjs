import test from "node:test";
import assert from "node:assert/strict";
import {assessPair, formatGpuReport} from "../web/gpu-diagnostics.mjs";
import {numericCases} from "../web/numeric-cases.mjs";

test("GPU diagnostic threshold rejects mismatches and nonfinite readings",()=>{
  assert.equal(numericCases.length,171);
  assert.deepEqual([0,1,2,3].map(mode=>
    numericCases.filter(c=>c.mode===mode).length),[36,45,45,45]);
  assert.equal(assessPair([0.5,0.25],[0.5,0.25]).ok,true);
  assert.equal(assessPair([0.50001,0.25],[0.5,0.25]).ok,true);
  assert.equal(assessPair([1,0],[0,0]).ok,false);
  assert.equal(assessPair([Infinity,0],[0,0]).ok,false);
  assert.equal(assessPair([NaN,0],[0,0]).ok,false);
  assert.equal(assessPair([0,0],[NaN,0]).ok,false);
});

test("report failure cannot be labeled PASS",()=>{
  const result={
    status:"fail", total:171,tested:171,failed:1,
    casesByMode:[36,45,45,45],worstError:2,
    worstCase:null,failures:[{index:3}],
    elapsedMs:120.1,devicePixelRatio:2,
    gpu:{renderer:"test",unmaskedRenderer:"(unavailable)",
      vendor:"test",unmaskedVendor:"(unavailable)",glVersion:"WebGL 2",
      shadingLanguage:"GLSL ES 3"}
  };
  const report=formatGpuReport(result,"deadbeef");
  assert.match(report,/FAIL: 170\/171/);
  assert.doesNotMatch(report,/PASS/);
  assert.match(report,/deadbeef/);
});
