import assert from 'node:assert/strict';
import {
  multiplyCoefficients, eisensteinCoefficients, discriminantCoefficients,
  heckePrimeCoefficients,
} from './modular-coefficients.mjs';

// Published constant-term-one normalization; independent low-order fixtures.
assert.deepEqual(eisensteinCoefficients(4, 3), [1n, 240n, 2160n, 6720n]);
assert.deepEqual(eisensteinCoefficients(6, 3), [1n, -504n, -16632n, -122976n]);
assert.deepEqual(discriminantCoefficients(10),
  [0n, 1n, -24n, 252n, -1472n, 4830n, -6048n, -16744n, 84480n, -113643n, -115920n]);

for (const order of [0, 1, 3, 10, 32]) {
  const fourth = eisensteinCoefficients(4, order);
  const sixth = eisensteinCoefficients(6, order);
  const fourthCubed = multiplyCoefficients(multiplyCoefficients(fourth, fourth, order), fourth, order);
  const sixthSquared = multiplyCoefficients(sixth, sixth, order);
  const productDelta = discriminantCoefficients(order);
  assert.deepEqual(fourthCubed.map((coefficient, degree) => coefficient - sixthSquared[degree]),
    productDelta.map(coefficient => 1728n * coefficient));
}

// Independent divisor enumeration contrasts with the production divisor sieve.
for (const weight of [4, 6]) {
  const coefficients = eisensteinCoefficients(weight, 96);
  for (let degree = 1; degree <= 96; degree += 1) {
    let reference = 0n;
    for (let divisor = 1; divisor <= degree; divisor += 1) {
      if (degree % divisor === 0) reference += BigInt(divisor) ** BigInt(weight - 1);
    }
    assert.equal(coefficients[degree], reference * (weight === 4 ? 240n : -504n));
  }
  for (const prime of [2, 3]) {
    const transformed = heckePrimeCoefficients(coefficients, weight, prime, 32);
    const eigenvalue = 1n + BigInt(prime) ** BigInt(weight - 1);
    assert.deepEqual(transformed, coefficients.slice(0, 33).map(value => eigenvalue * value));
  }
}

const delta = discriminantCoefficients(96);
for (const prime of [2, 3]) {
  assert.deepEqual(heckePrimeCoefficients(delta, 12, prime, 32),
    delta.slice(0, 33).map(value => delta[prime] * value));
}
assert.equal(delta[6], delta[2] * delta[3]);
assert.equal(delta[4], delta[2] ** 2n - 2n ** 11n);
assert.equal(delta[0], 0n);
assert.equal(heckePrimeCoefficients([1n], 4, 2, 0)[0], 9n);

// Rejection cases protect finite precision, type, and mathematical boundaries.
assert.throws(() => heckePrimeCoefficients(delta.slice(0, 33), 12, 2, 32), RangeError);
for (const prime of [0, 1, 4, 2.5, NaN]) {
  assert.throws(() => heckePrimeCoefficients(delta, 12, prime, 2), RangeError);
}
for (const order of [-1, 0.5, NaN, Infinity, 4097]) {
  assert.throws(() => discriminantCoefficients(order), RangeError);
}
assert.throws(() => eisensteinCoefficients(2, 8), RangeError);
assert.throws(() => multiplyCoefficients([1], [1n], 0), TypeError);
assert.throws(() => multiplyCoefficients(Array(2), [1n, 1n], 1), TypeError);
assert.throws(() => multiplyCoefficients([1n], [1n], 1), RangeError);
const damaged = delta.slice();
damaged[2] += 1n;
assert.notDeepEqual(heckePrimeCoefficients(damaged, 12, 2, 32),
  damaged.slice(0, 33).map(value => -24n * value));

console.log('PASS exact E4/E6/Delta identity through q^32; T2/T3 through q^32; independent fixtures and rejection cases');
