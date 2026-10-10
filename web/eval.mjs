// Host-side probe and reference evaluator, independent of the GLSL implementation.
// A point is [real, imaginary]. This evaluates FINITE expressions only.
export const LIMITS = Object.freeze({geometric: 32, series: 127, prime: 31});

export function characterWeight(modulus, n) {
  if (![1, 3, 4].includes(modulus)) throw new RangeError("character modulus");
  if (!Number.isInteger(n) || n < 1) throw new RangeError("n must be positive");
  if (modulus === 1) return 1;
  if (modulus === 3) return n % 3 === 0 ? 0 : (n % 3 === 1 ? 1 : -1);
  return n % 2 === 0 ? 0 : (n % 4 === 1 ? 1 : -1);
}
export const chi4 = n => characterWeight(4, n);
const requireCharacter = modulus => {
  if (![1, 3, 4].includes(modulus)) throw new RangeError("character modulus");
};
export function isPrime(n) {
  if (!Number.isInteger(n) || n < 2) return false;
  for (let d = 2; d * d <= n; d++) if (n % d === 0) return false;
  return true;
}
const plus = (a, b) => [a[0] + b[0], a[1] + b[1]];
const times = (a, b) =>
  [a[0] * b[0] - a[1] * b[1], a[0] * b[1] + a[1] * b[0]];
const inverse = a => {
  const norm = a[0] * a[0] + a[1] * a[1];
  return norm < 1e-28 ? [Infinity, Infinity] : [a[0] / norm, -a[1] / norm];
};
const nToMinusS = (n, s) => {
  const logN = Math.log(n);
  const radius = Math.exp(Math.max(-80, Math.min(80, -s[0] * logN)));
  const angle = -s[1] * logN;
  return [radius * Math.cos(angle), radius * Math.sin(angle)];
};
export function geometric(terms, q) {
  if (!Number.isInteger(terms) || terms < 0 || terms > LIMITS.geometric) throw new RangeError("terms");
  let sum = [0, 0], power = [1, 0];
  for (let k = 0; k < terms; k++) {
    sum = plus(sum, power);
    power = times(power, q);
  }
  return sum;
}
export function local(prime, s, modulus = 4) {
  requireCharacter(modulus);
  if (!isPrime(prime) || prime > LIMITS.prime) throw new RangeError("prime");
  const t = nToMinusS(prime, s);
  const c = characterWeight(modulus, prime);
  return inverse([1 - c * t[0], -c * t[1]]);
}
export function partial(lastN, s, modulus = 4) {
  requireCharacter(modulus);
  if (!Number.isInteger(lastN) || lastN < 0 || lastN > LIMITS.series) throw new RangeError("lastN");
  let sum = [0, 0];
  for (let n = 1; n <= lastN; n++) {
    const c = characterWeight(modulus, n);
    if (c) {
      const t = nToMinusS(n, s);
      sum = plus(sum, [c * t[0], c * t[1]]);
    }
  }
  return sum;
}
export function finiteProduct(lastPrime, s, modulus = 4) {
  requireCharacter(modulus);
  if (!Number.isInteger(lastPrime) || lastPrime < 0 || lastPrime > LIMITS.prime) throw new RangeError("lastPrime");
  let product = [1, 0];
  for (let p = 2; p <= lastPrime; p++) {
    if (isPrime(p)) product = times(product, local(p, s, modulus));
  }
  return product;
}
export function evaluate(model, cutoff, prime, point, modulus = 4) {
  if (model === 0) return geometric(cutoff, point);
  if (model === 1) return local(prime, point, modulus);
  if (model === 2) return partial(cutoff, point, modulus);
  if (model === 3) return finiteProduct(cutoff, point, modulus);
  throw new RangeError("model");
}
