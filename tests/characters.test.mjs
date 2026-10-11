import test from "node:test";
import assert from "node:assert/strict";
import {
  MAX_MODULUS, characterCount, unitGroup, generateCharacter,
  enumerateCharacters, verifyCharacter, characterValue,
  finiteCharacterSum, finiteCharacterLocal, finiteCharacterProduct
} from "../web/characters.mjs";
import {characterValue as oldValue} from "../web/eval.mjs";

const gcd=(a,b)=>b===0?a:gcd(b,a%b);
const near=(actual,expected,tolerance=1e-10)=>{
  const error=Math.hypot(actual[0]-expected[0],actual[1]-expected[1]);
  assert.ok(error<tolerance,JSON.stringify({actual,expected,error}));
};
const multiply=(a,b)=>[a[0]*b[0]-a[1]*b[1],a[0]*b[1]+a[1]*b[0]];

test("every bounded modulus gives exactly phi(q) distinct genuine characters",()=>{
  assert.equal(characterCount(0),0);
  assert.equal(characterCount(MAX_MODULUS+1),0);
  for (let q=1;q<=MAX_MODULUS;q++) {
    const phi=Array.from({length:q},(_,n)=>n)
      .filter(n=>gcd(n,q)===1).length;
    const group=unitGroup(q);
    assert.equal(group.count,phi);
    assert.equal(group.orders.reduce((a,b)=>a*b,1),phi);
    assert.ok(group.denominator>=1);
    const seen=new Set();
    for (let k=0;k<phi;k++) {
      const c=generateCharacter(q,k);
      assert.ok(verifyCharacter(c),"bad character q="+q+" index="+k);
      assert.equal(c.modulus,q);
      assert.equal(c.index,k);
      assert.equal(q%c.conductor,0);
      assert.equal(c.primitive,c.conductor===q);
      assert.equal(c.phaseDenominator%c.valueOrder,0);
      const signature=c.phases.join(",");
      assert.ok(!seen.has(signature),"duplicate q="+q+" index="+k);
      seen.add(signature);
      if(k===0) {
        assert.equal(c.conductor,1);
        assert.equal(c.valueOrder,1);
        assert.equal(c.parity,0);
      }
    }
    assert.equal(seen.size,phi);
  }
});
test("noncyclic powers of two and CRT decomposition are explicit",()=>{
  assert.deepEqual(unitGroup(8).orders,[2,2]);
  assert.deepEqual(unitGroup(16).orders,[2,4]);
  assert.deepEqual(unitGroup(32).orders,[2,8]);
  assert.deepEqual(unitGroup(12).orders,[2,2]);
  assert.deepEqual(unitGroup(15).orders,[2,4]);
  assert.deepEqual(unitGroup(45).orders,[6,4]);
  assert.deepEqual(unitGroup(105).orders,[2,4,6]);
  assert.equal(unitGroup(127).orders[0],126);
});
test("canonical generated characters reproduce historic exact character values",()=>{
  const cases=[
    [4,1,0],[3,1,1],[5,1,2],[5,3,3],
    [8,2,4],[4,0,5],[1,0,6]
  ];
  for (const [q,k,oldId] of cases) {
    const c=generateCharacter(q,k);
    for (let n=0;n<127;n++)
      near(characterValue(c,n),oldValue(oldId,n),2e-14);
  }
  const chi5plus=generateCharacter(5,1);
  const chi5minus=generateCharacter(5,3);
  const chi8=generateCharacter(8,2);
  near(characterValue(chi5plus,2),[0,1]);
  near(characterValue(chi5minus,2),[0,-1]);
  near(characterValue(chi8,7),[1,0]);
  assert.equal(chi5plus.conductor,5);
  assert.equal(chi5plus.parity,1);
  assert.equal(chi5minus.parity,1);
  assert.equal(chi8.conductor,8);
  assert.equal(chi8.parity,0);
  assert.equal(generateCharacter(8,1).conductor,4);
  assert.equal(generateCharacter(9,3).conductor,3);
  assert.equal(generateCharacter(1,0).conductor,1);
});
test("character orthogonality and inversion hold for cyclic and CRT groups",()=>{
  for (const q of [3,4,5,8,9,12,15,16,24,32,105,128]) {
    const all=enumerateCharacters(q);
    const phi=all.length;
    const values=all.map(c=>Array.from({length:q},(_,n)=>characterValue(c,n)));
    for (let i=0;i<phi;i++) {
      const sum=values[i].reduce((acc,z)=>[acc[0]+z[0],acc[1]+z[1]],[0,0]);
      near(sum,i===0?[phi,0]:[0,0],1e-9);
      for (let j=0;j<phi;j++) {
        let inner=[0,0];
        for (let n=0;n<q;n++) {
          const a=values[i][n],b=values[j][n];
          const z=multiply(a,[b[0],-b[1]]);
          inner=[inner[0]+z[0],inner[1]+z[1]];
        }
        near(inner,i===j?[phi,0]:[0,0],1e-9);
      }
    }
  }
});
test("finite series and local factors respect complex values and bounds",()=>{
  const quartic=generateCharacter(5,1);
  const zeta=generateCharacter(1,0);
  near(finiteCharacterLocal(quartic,2,[2,0]),[16/17,4/17]);
  near(finiteCharacterSum(zeta,3,[2,0]),[1+1/4+1/9,0]);
  near(finiteCharacterProduct(generateCharacter(4,1),5,[2,0]),[0.9375,0]);
  near(finiteCharacterSum(quartic,0,[2,0]),[0,0]);
  near(finiteCharacterProduct(quartic,0,[2,0]),[1,0]);
  assert.throws(()=>finiteCharacterLocal(quartic,9,[2,0]),RangeError);
  assert.throws(()=>finiteCharacterSum(quartic,128,[2,0]),RangeError);
  assert.throws(()=>finiteCharacterProduct(quartic,32,[2,0]),RangeError);
  assert.throws(()=>generateCharacter(4,2),RangeError);
  assert.throws(()=>generateCharacter(129,0),RangeError);
  const corrupt={...quartic,phases:[...quartic.phases]};
  corrupt.phases[1]=1;
  assert.equal(verifyCharacter(corrupt),false);
  assert.throws(()=>finiteCharacterSum(corrupt,3,[2,0]),RangeError);
});
