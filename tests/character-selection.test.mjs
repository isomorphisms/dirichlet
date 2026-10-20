import test from "node:test";
import assert from "node:assert/strict";
import {
  MAX_MODULUS, characterCount, generateCharacter, verifyCharacter,
  finiteCharacterSum, finiteCharacterLocal, finiteCharacterProduct
} from "../web/characters.mjs";
import {shaderCharacterPayload} from "../web/character-selection.mjs";

const copy = character => ({...character,phases:[...character.phases]});
function rejectDescriptor(character,label) {
  assert.equal(verifyCharacter(character),false,label+": verifier");
  assert.throws(()=>shaderCharacterPayload(character),RangeError,label+": shader payload");
  assert.throws(()=>finiteCharacterSum(character,3,[2,0]),RangeError,label+": finite sum");
  assert.throws(()=>finiteCharacterLocal(character,3,[2,0]),RangeError,label+": local factor");
  assert.throws(()=>finiteCharacterProduct(character,5,[2,0]),RangeError,label+": finite product");
}

test("descriptor indices must be bounded nonnegative integers",()=>{
  const character=generateCharacter(5,1);
  for (const index of [-1,0.5,NaN,undefined,null,"1",1n,Infinity,characterCount(5)])
    rejectDescriptor({...character,index},"index "+String(index));
});

test("metadata must keep its exact integer and boolean representation",()=>{
  const character=generateCharacter(5,1);
  const invalid={
    modulus:[0,0.5,129,NaN,"5"],
    phaseDenominator:[0,0.5,129,NaN,undefined,"4"],
    valueOrder:[0,0.5,3,NaN,undefined,"4"],
    conductor:[0,0.5,2,NaN,undefined,"5"],
    parity:[-1,2,0.5,NaN,undefined,"1"],
    primitive:[undefined,0,1,"true"]
  };
  for (const [field,values] of Object.entries(invalid))
    for (const value of values)
      rejectDescriptor({...character,[field]:value},field+" "+String(value));
  rejectDescriptor({...character,conductor:1,primitive:false},"wrong exact conductor");
  rejectDescriptor({...character,parity:0},"wrong exact parity");
  rejectDescriptor({...character,valueOrder:2},"wrong exact value order");
});

test("integer phase contract rejects fractional homomorphism encoding",()=>{
  // These fractional phases satisfy the old modulo-addition and metadata
  // checks, but are not the integer root-of-unity representation of the ABI.
  rejectDescriptor({
    modulus:3,index:1,phaseDenominator:1,valueOrder:2,
    conductor:3,parity:1,primitive:true,phases:[-1,0,0.5]
  },"fractional phase witness");
  const character=generateCharacter(5,1);
  for (const phase of [0.5,NaN,Infinity,undefined,"1",1n,Symbol("phase"),-2,4]) {
    const corrupt=copy(character);
    corrupt.phases[2]=phase;
    rejectDescriptor(corrupt,"phase "+String(phase));
  }
  const sparse=copy(character);
  delete sparse.phases[2];
  rejectDescriptor(sparse,"sparse phase table");
});

test("shader ingestion verifies support, multiplication and metadata",()=>{
  const character=generateCharacter(5,1);
  const badSupport=copy(character);
  badSupport.phases[0]=0;
  rejectDescriptor(badSupport,"nonunit given a root of unity");
  const badUnit=copy(character);
  badUnit.phases[2]=-1;
  rejectDescriptor(badUnit,"unit given zero");
  const badMultiplication=copy(character);
  badMultiplication.phases[2]=0;
  rejectDescriptor(badMultiplication,"well-shaped nonmultiplicative phase table");
  rejectDescriptor({...character,phaseDenominator:0},"zero shader denominator");
});

test("all valid generated tables retain exact shader payloads",()=>{
  let checked=0;
  for (let modulus=1;modulus<=MAX_MODULUS;modulus++) {
    for (let index=0;index<characterCount(modulus);index++) {
      const character=generateCharacter(modulus,index);
      assert.equal(verifyCharacter(character),true);
      const payload=shaderCharacterPayload(character);
      assert.equal(payload.generated,1);
      assert.equal(payload.character,0);
      assert.equal(payload.modulus,modulus);
      assert.equal(payload.denominator,character.phaseDenominator);
      assert.ok(payload.phases instanceof Int32Array);
      assert.equal(payload.phases.length,MAX_MODULUS);
      assert.deepEqual([...payload.phases.slice(0,modulus)],character.phases);
      assert.ok(payload.phases.slice(modulus).every(phase=>phase===-1));
      checked++;
    }
  }
  assert.ok(checked>0);
});

test("historical presets retain their payload and input bounds",()=>{
  for (let character=0;character<7;character++) {
    const payload=shaderCharacterPayload(character);
    assert.equal(payload.generated,0);
    assert.equal(payload.character,character);
    assert.equal(payload.modulus,1);
    assert.equal(payload.denominator,1);
    assert.ok(payload.phases.every(phase=>phase===-1));
  }
  for (const character of [-1,0.5,7,NaN,Infinity])
    assert.throws(()=>shaderCharacterPayload(character),RangeError);
});
