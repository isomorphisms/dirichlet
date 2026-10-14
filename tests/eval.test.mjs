import test from "node:test";
import assert from "node:assert/strict";
import {characterWeight, chi4, isPrime, geometric, local, partial, finiteProduct, evaluate} from "../web/eval.mjs";

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

test("weighted series and Euler factors for primitive chi3 and modulus-1 zeta", () => {
  assert.deepEqual([1,2,3,4,5,6,7].map(n => characterWeight(3,n)),
    [1,-1,0,1,-1,0,1]);
  assert.deepEqual([1,2,3,4].map(n => characterWeight(1,n)),
    [1,1,1,1]);
  near(local(3,[2,0],3), [1,0]); // chi3 vanishes at ramified prime
  near(local(2,[2,0],3), [0.8,0]);
  near(partial(2,[2,0],3), [0.75,0]);
  near(local(2,[2,0],1), [4/3,0]);
  near(partial(3,[2,0],1), [49/36,0]);
  near(finiteProduct(3,[2,0],1), [1.5,0]);
  near(evaluate(2,2,3,[2,0],3), [0.75,0]);
  near(evaluate(2,3,3,[2,0]), partial(3,[2,0],4));
  assert.throws(() => characterWeight(2,1), RangeError);
  assert.throws(() => characterWeight(3,0), RangeError);
  assert.throws(() => local(3,[2,0],2), RangeError);
  assert.throws(() => partial(0,[2,0],2), RangeError);
  assert.throws(() => finiteProduct(0,[2,0],2), RangeError);
});
