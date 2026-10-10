// Finite CPU probe independent of C11 and GLSL. A complex value is [Re, Im].
export const LIMITS = Object.freeze({geometric:32, series:127, prime:31});

// Complete finite residue tables for selected characters; values are exact
// Gaussian integers. No arbitrary character construction or nebentypus.
export const CHARACTERS = Object.freeze([
  {symbol:"χ₄",label:"χ₄ · primitive modulo 4",modulus:4,principal:false,
    values:[[0,0],[1,0],[0,0],[-1,0]]},
  {symbol:"χ₃",label:"χ₃ · primitive modulo 3",modulus:3,principal:false,
    values:[[0,0],[1,0],[-1,0]]},
  {symbol:"χ₅⁺",label:"χ₅⁺ · quartic modulo 5 (χ(2)=i)",modulus:5,principal:false,
    values:[[0,0],[1,0],[0,1],[0,-1],[-1,0]]},
  {symbol:"χ₅⁻",label:"χ₅⁻ · quartic modulo 5 (χ(2)=−i)",modulus:5,principal:false,
    values:[[0,0],[1,0],[0,-1],[0,1],[-1,0]]},
  {symbol:"χ₈",label:"χ₈ · primitive even modulo 8",modulus:8,principal:false,
    values:[[0,0],[1,0],[0,0],[-1,0],[0,0],[-1,0],[0,0],[1,0]]},
  {symbol:"χ₀,₄",label:"χ₀,₄ · principal modulo 4",modulus:4,principal:true,
    values:[[0,0],[1,0],[0,0],[1,0]]},
  {symbol:"χ₁",label:"χ₁ · principal modulo 1 (ζ)",modulus:1,principal:true,
    values:[[1,0]]}
].map(c=>Object.freeze({...c,values:Object.freeze(c.values.map(z=>Object.freeze(z)))})));

export function characterValue(character,n) {
  if (!Number.isInteger(character) || character < 0 || character >= CHARACTERS.length)
    throw new RangeError("character");
  if (!Number.isSafeInteger(n) || n < 0) throw new RangeError("n");
  const c=CHARACTERS[character];
  return c.values[n%c.modulus];
}
export function chi4(n) {
  if (!Number.isSafeInteger(n) || n < 1) throw new RangeError("n must be positive");
  return characterValue(0,n)[0];
}
export function isPrime(n) {
  if (!Number.isInteger(n) || n < 2) return false;
  for (let d=2;d*d<=n;d++) if (n%d===0) return false;
  return true;
}
const plus=(a,b)=>[a[0]+b[0],a[1]+b[1]];
const times=(a,b)=>[a[0]*b[0]-a[1]*b[1],a[0]*b[1]+a[1]*b[0]];
const inverse=a=>{
  const norm=a[0]*a[0]+a[1]*a[1];
  return norm<1e-28?[Infinity,Infinity]:[a[0]/norm,-a[1]/norm];
};
const nToMinusS=(n,s)=>{
  const logN=Math.log(n), radius=Math.exp(Math.max(-80,Math.min(80,-s[0]*logN)));
  const angle=-s[1]*logN;
  return [radius*Math.cos(angle),radius*Math.sin(angle)];
};
export function geometric(terms,q) {
  if (!Number.isInteger(terms) || terms<0 || terms>LIMITS.geometric)
    throw new RangeError("terms");
  let sum=[0,0],power=[1,0];
  for (let k=0;k<terms;k++) {
    sum=plus(sum,power);
    power=times(power,q);
  }
  return sum;
}
export function local(prime,s,character=0) {
  if (!isPrime(prime) || prime>LIMITS.prime) throw new RangeError("prime");
  const factor=times(characterValue(character,prime),nToMinusS(prime,s));
  return inverse([1-factor[0],-factor[1]]);
}
export function partial(lastN,s,character=0) {
  if (!Number.isInteger(lastN) || lastN<0 || lastN>LIMITS.series)
    throw new RangeError("lastN");
  characterValue(character,1); // validate even for the empty sum
  let sum=[0,0];
  for (let n=1;n<=lastN;n++) {
    const value=characterValue(character,n);
    if (value[0]!==0 || value[1]!==0)
      sum=plus(sum,times(value,nToMinusS(n,s)));
  }
  return sum;
}
export function finiteProduct(lastPrime,s,character=0) {
  if (!Number.isInteger(lastPrime) || lastPrime<0 || lastPrime>LIMITS.prime)
    throw new RangeError("lastPrime");
  characterValue(character,1); // validate even for the empty product
  let product=[1,0];
  for (let p=2;p<=lastPrime;p++)
    if (isPrime(p)) product=times(product,local(p,s,character));
  return product;
}
export function evaluate(model,cutoff,prime,point,character=0) {
  if (model===0) return geometric(cutoff,point);
  if (model===1) return local(prime,point,character);
  if (model===2) return partial(cutoff,point,character);
  if (model===3) return finiteProduct(cutoff,point,character);
  throw new RangeError("model");
}
