import test from "node:test";
import assert from "node:assert/strict";
import {CHARACTERS, characterValue, chi4, isPrime, geometric, local, partial, finiteProduct, evaluate} from "../web/eval.mjs";

const near = (z, x, tolerance = 1e-10) => {
  assert.ok(Math.hypot(z[0] - x[0], z[1] - x[1]) < tolerance, [z,x].join(" | "));
};
test("modulo-four character and primes", () => {
  assert.deepEqual([1,2,3,4,5,7].map(chi4), [1,0,-1,0,1,-1]);
  assert.equal(isPrime(2), true);
  assert.equal(isPrime(3), true);
  assert.equal(isPrime(9), false);
});
test("finite geometric N=4 regular at q=1, roots at -1, ±i", () => {
  near(geometric(0, [1,0]), [0,0]);
  near(geometric(1, [1,0]), [1,0]);
  near(geometric(4, [1,0]), [4,0]);
  near(geometric(4, [-1,0]), [0,0]);
  near(geometric(4, [0,1]), [0,0]);
  near(geometric(4, [0,-1]), [0,0]);
  const q = [0.25,0.4], g = geometric(9,q);
  const multiply = (a,b) => [a[0]*b[0]-a[1]*b[1], a[0]*b[1]+a[1]*b[0]];
  const power = Array.from({length:9}).reduce(acc => multiply(acc,q), [1,0]);
  near(multiply([1-q[0],-q[1]],g), [1-power[0],-power[1]]);
});
test("distinct finite chi4 Dirichlet sum, local factor and Euler product", () => {
  near(local(3,[2,0]), [0.9,0]);
  near(local(2,[2,0]), [1,0]);
  near(partial(3,[2,0]), [8/9,0]);
  near(finiteProduct(3,[2,0]), [0.9,0]);
  near(finiteProduct(5,[2,0]), [0.9375,0]);
  assert.ok(Math.abs(partial(127,[2,0])[0] - 0.91596559417721901505) < 1e-4);
  near(evaluate(0,4,3,[1,0]), [4,0]);
  near(evaluate(1,4,3,[2,0]), [0.9,0]);
});
test("fail closed for invalid cutoffs or local composites", () => {
  assert.throws(() => geometric(33,[1,0]), RangeError);
  assert.throws(() => partial(128,[2,0]), RangeError);
  assert.throws(() => finiteProduct(32,[2,0]), RangeError);
  assert.throws(() => local(9,[2,0]), RangeError);
});

test("all character tables: normalization, unit support and multiplication", () => {
  const gcd=(a,b)=>b===0?a:gcd(b,a%b);
  const multiply=(x,y)=>[x[0]*y[0]-x[1]*y[1],x[0]*y[1]+x[1]*y[0]];
  assert.equal(CHARACTERS.length,7);
  for (const [id,{modulus}] of CHARACTERS.entries()) {
    assert.deepEqual(characterValue(id,1),[1,0]);
    for (let a=0;a<modulus;a++) {
      const c=characterValue(id,a);
      assert.deepEqual(c,characterValue(id,a+3*modulus));
      assert.equal(c[0]*c[0]+c[1]*c[1],gcd(a,modulus)===1?1:0);
      for (let b=0;b<modulus;b++)
        assert.deepEqual(characterValue(id,a*b),multiply(c,characterValue(id,b)),
          "character "+id+" residues "+a+", "+b);
    }
  }
});
test("quartic conjugates and distinct principal characters", () => {
  assert.deepEqual(characterValue(2,2),[0,1]);
  assert.deepEqual(characterValue(3,2),[0,-1]);
  assert.deepEqual(characterValue(4,7),[1,0]);
  assert.deepEqual(characterValue(5,3),[1,0]);
  assert.deepEqual(characterValue(6,2),[1,0]);
  near(local(2,[2,0],2),[16/17,4/17]);
  near(partial(3,[2,0],6),[1+1/4+1/9,0]);
  near(evaluate(1,0,2,[2,0],2),[16/17,4/17]);
  assert.throws(()=>characterValue(7,1),RangeError);
  assert.throws(()=>characterValue(0,-1),RangeError);
  assert.throws(()=>partial(0,[2,0],7),RangeError);
  assert.throws(()=>finiteProduct(0,[2,0],7),RangeError);
  assert.throws(()=>local(2,[2,0],7),RangeError);
});
