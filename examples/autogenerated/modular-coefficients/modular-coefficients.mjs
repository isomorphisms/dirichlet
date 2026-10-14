// Finite exact coefficient data. No analytic continuation or infinite-limit API.
// Arrays include degree zero and retain coefficients through the given order.

function requireOrder(order) {
  if (!Number.isSafeInteger(order) || order < 0 || order > 4096) {
    throw new RangeError('order must be an integer from 0 through 4096');
  }
}

function requireCoefficients(coefficients) {
  if (!Array.isArray(coefficients) || coefficients.length === 0 ||
      coefficients.some(coefficient => typeof coefficient !== 'bigint')) {
    throw new TypeError('coefficients must be a nonempty dense BigInt array');
  }
  for (let degree = 0; degree < coefficients.length; degree += 1) {
    if (!(degree in coefficients)) throw new TypeError('sparse coefficient array');
  }
}

export function multiplyCoefficients(first, second, order) {
  requireOrder(order);
  requireCoefficients(first);
  requireCoefficients(second);
  if (first.length <= order || second.length <= order) {
    throw new RangeError('input coefficients do not cover requested order');
  }
  const result = Array(order + 1).fill(0n);
  for (let firstDegree = 0; firstDegree <= order; firstDegree += 1) {
    for (let secondDegree = 0; secondDegree <= order - firstDegree; secondDegree += 1) {
      result[firstDegree + secondDegree] += first[firstDegree] * second[secondDegree];
    }
  }
  return result;
}

export function eisensteinCoefficients(weight, order) {
  requireOrder(order);
  if (weight !== 4 && weight !== 6) throw new RangeError('supported weights are 4 and 6');
  const coefficients = Array(order + 1).fill(0n);
  coefficients[0] = 1n;
  const scale = weight === 4 ? 240n : -504n;
  for (let divisor = 1; divisor <= order; divisor += 1) {
    const contribution = scale * BigInt(divisor) ** BigInt(weight - 1);
    for (let multiple = divisor; multiple <= order; multiple += divisor) {
      coefficients[multiple] += contribution;
    }
  }
  return coefficients;
}

export function discriminantCoefficients(order) {
  requireOrder(order);
  const coefficients = Array(order + 1).fill(0n);
  if (order === 0) return coefficients;
  coefficients[1] = 1n;
  // Exact truncated product q∏(1−qⁿ)²⁴. Descending updates use the
  // previous polynomial, so each pass multiplies by precisely one factor.
  for (let factorDegree = 1; factorDegree < order; factorDegree += 1) {
    for (let repetition = 0; repetition < 24; repetition += 1) {
      for (let degree = order; degree >= factorDegree; degree -= 1) {
        coefficients[degree] -= coefficients[degree - factorDegree];
      }
    }
  }
  return coefficients;
}

function requirePrime(prime) {
  if (!Number.isSafeInteger(prime) || prime < 2 || prime > 4096) {
    throw new RangeError('prime must be an integer from 2 through 4096');
  }
  for (let divisor = 2; divisor * divisor <= prime; divisor += 1) {
    if (prime % divisor === 0) throw new RangeError('Hecke index must be prime');
  }
}

// Level one, trivial character, arithmetic normalization.
// The caller supplies known modular-form coefficients; this function does not
// certify that arbitrary finite input data is a modular form of the stated weight.
export function heckePrimeCoefficients(coefficients, weight, prime, order) {
  requireOrder(order);
  requireCoefficients(coefficients);
  requirePrime(prime);
  if (!Number.isSafeInteger(weight) || weight < 2 || weight > 4096 || weight % 2 !== 0) {
    throw new RangeError('weight must be an even integer from 2 through 4096');
  }
  if (coefficients.length <= prime * order) {
    throw new RangeError('Hecke output needs input through prime times output order');
  }
  const scale = BigInt(prime) ** BigInt(weight - 1);
  return Array.from({length: order + 1}, (_, degree) =>
    coefficients[prime * degree] + (degree % prime === 0 ? scale * coefficients[degree / prime] : 0n));
}
