// Exact, bounded Dirichlet-character generation for a mathematical CPU host.
// This is independent of the seven historical hard-coded Wegert presets.
// The 128-residue limit is an explicit resource bound, not a mathematical
// restriction on character groups or a claim of analytic continuation.

export const MAX_MODULUS = 128;
const PI = Math.PI;

const gcd = (a,b) => {
  while (b!==0) [a,b]=[b,a%b];
  return a;
};
const lcm = (a,b) => a/gcd(a,b)*b;
const powMod = (base,exponent,modulus) => {
  let value=1%modulus;
  while (exponent!==0) {
    if (exponent%2) value=value*base%modulus;
    base=base*base%modulus;
    exponent=Math.floor(exponent/2);
  }
  return value;
};
function primePowers(modulus) {
  let left=modulus;
  const result=[];
  for (let prime=2;prime<=left/prime;prime++) {
    if (left%prime!==0) continue;
    let power=1;
    do {power*=prime;left/=prime;} while (left%prime===0);
    result.push({prime,power});
  }
  if (left>1) result.push({prime:left,power:left});
  return result;
}
export function characterCount(modulus) {
  if (!Number.isInteger(modulus) || modulus<1 || modulus>MAX_MODULUS)
    return 0;
  let result=modulus;
  for (const {prime} of primePowers(modulus)) result-=result/prime;
  return result;
}
function primitiveRoot(modulus,order) {
  const divisors=primePowers(order).map(({prime})=>prime);
  for (let candidate=2;candidate<modulus;candidate++) {
    if (gcd(candidate,modulus)!==1) continue;
    if (divisors.every(prime=>powMod(candidate,order/prime,modulus)!==1))
      return candidate;
  }
  throw new Error("No primitive root for odd prime power "+modulus);
}
function localBasis({prime,power}) {
  // Discrete logarithm entries are exact tuples in the group generators.
  const logarithms=Array(power).fill(null);
  if (power===2) {
    logarithms[1]=[];
    return {modulus:power,generators:[],orders:[],logarithms};
  }
  if (prime===2 && power>=8) {
    const secondOrder=power/4;
    for (let sign=0;sign<2;sign++)
      for (let exponent=0;exponent<secondOrder;exponent++) {
        const powerOfFive=powMod(5,exponent,power);
        const residue=(sign===0?powerOfFive:(power-powerOfFive))%power;
        if (logarithms[residue]!==null) throw new Error("Duplicate 2-power log");
        logarithms[residue]=[sign,exponent];
      }
    return {modulus:power,generators:[power-1,5],orders:[2,secondOrder],logarithms};
  }
  const order=power-power/prime;
  const generator=prime===2?3:primitiveRoot(power,order);
  for (let exponent=0;exponent<order;exponent++) {
    const residue=powMod(generator,exponent,power);
    if (logarithms[residue]!==null) throw new Error("Repeated cyclic log");
    logarithms[residue]=[exponent];
  }
  return {modulus:power,generators:[generator],orders:[order],logarithms};
}
export function unitGroup(modulus) {
  const count=characterCount(modulus);
  if (!count) throw new RangeError("modulus");
  const factors=primePowers(modulus).map(localBasis);
  const orders=factors.flatMap(f=>f.orders);
  const generators=factors.flatMap(f=>f.generators.map((generator,i)=>({
    localModulus:f.modulus,generator,order:f.orders[i]
  })));
  const denominator=orders.reduce(lcm,1);
  if (orders.reduce((a,b)=>a*b,1)!==count)
    throw new Error("CRT generator orders disagree with Euler totient");
  // Each local logarithm is unique on all units of its prime-power ring.
  for (const factor of factors)
    for (let residue=0;residue<factor.modulus;residue++)
      if ((factor.logarithms[residue]!==null)!==(gcd(residue,factor.modulus)===1))
        throw new Error("Unit-group log table incomplete");
  return {modulus,count,denominator,orders,generators,factors};
}
function conductorFor(modulus,phases) {
  // Reduction U(q) -> U(d) is surjective for every d|q.
  // chi factors through d iff it is trivial on its reduction kernel.
  for (let d=1;d<=modulus;d++) {
    if (modulus%d!==0) continue;
    const identity=1%d;
    let trivialOnKernel=true;
    for (let residue=0;residue<modulus;residue++)
      if (gcd(residue,modulus)===1 &&
          residue%d===identity && phases[residue]!==0) {
        trivialOnKernel=false;
        break;
      }
    if (trivialOnKernel) return d;
  }
  throw new Error("A character did not factor through its own modulus");
}
export function generateCharacter(modulus,index) {
  const group=unitGroup(modulus);
  if (!Number.isInteger(index) || index<0 || index>=group.count)
    throw new RangeError("character index");
  let remaining=index;
  const coordinates=group.orders.map(order=>{
    const digit=remaining%order;
    remaining=Math.floor(remaining/order);
    return digit;
  });
  const phases=[];
  for (let residue=0;residue<modulus;residue++) {
    if (gcd(residue,modulus)!==1) {phases.push(-1);continue;}
    let phase=0, coordinate=0;
    for (const f of group.factors) {
      const logs=f.logarithms[residue%f.modulus];
      if (logs===null) throw new Error("Missing CRT discrete logarithm");
      for (let j=0;j<f.orders.length;j++) {
        phase+=coordinates[coordinate]*logs[j]*(group.denominator/f.orders[j]);
        coordinate++;
      }
    }
    phases.push(phase%group.denominator);
  }
  let divisor=group.denominator;
  for (const phase of phases) if (phase>=0) divisor=gcd(divisor,phase);
  const valueOrder=group.denominator/divisor;
  const minusOnePhase=phases[(modulus-1)%modulus];
  if (minusOnePhase!==0 && 2*minusOnePhase!==group.denominator)
    throw new Error("chi(-1) is not +1 or -1");
  const conductor=conductorFor(modulus,phases);
  return Object.freeze({
    modulus,index,phaseDenominator:group.denominator,
    valueOrder,conductor,primitive:conductor===modulus,
    parity:minusOnePhase===0?0:1,
    phases:Object.freeze(phases)
  });
}
export function enumerateCharacters(modulus) {
  return Array.from({length:characterCount(modulus)},(_,index)=>
    generateCharacter(modulus,index));
}
export function verifyCharacter(c) {
  if (!c || !Number.isInteger(c.modulus) || !Array.isArray(c.phases) ||
      c.phases.length!==c.modulus || c.modulus<1 ||
      c.modulus>MAX_MODULUS || characterCount(c.modulus)<=c.index ||
      !Number.isInteger(c.phaseDenominator) || c.phaseDenominator<1 ||
      c.phaseDenominator>MAX_MODULUS || c.parity!==0 && c.parity!==1)
    return false;
  const q=c.modulus, d=c.phaseDenominator;
  if (c.phases[1%q]!==0) return false;
  for (let a=0;a<q;a++) {
    const exp=c.phases[a], unit=gcd(a,q)===1;
    if (!unit && exp!==-1 || unit && !(exp>=0 && exp<d)) return false;
    for (let b=0;b<q;b++) {
      const next=c.phases[a*b%q];
      if (unit && gcd(b,q)===1) {
        if (next!==(exp+c.phases[b])%d) return false;
      } else if (next!==-1) return false;
    }
  }
  let gcdExponents=d;
  for (const exp of c.phases) if (exp>=0) gcdExponents=gcd(gcdExponents,exp);
  if (c.valueOrder!==d/gcdExponents ||
      c.conductor!==conductorFor(q,c.phases) ||
      c.primitive!==(c.conductor===q)) return false;
  const minus=c.phases[(q-1)%q];
  return c.parity===(minus===0?0:1) &&
    (minus===0 || minus*2===d);
}

export function characterValue(c,n) {
  if (!c || !Number.isSafeInteger(n) || n<0 ||
      !Number.isInteger(c.modulus) || c.modulus<1 || c.modulus>MAX_MODULUS ||
      !Array.isArray(c.phases) || c.phases.length!==c.modulus ||
      !Number.isInteger(c.phaseDenominator) || c.phaseDenominator<1)
    throw new RangeError("character or n");
  const phase=c.phases[n%c.modulus];
  if (phase===-1) return [0,0];
  if (!Number.isInteger(phase) || phase<0 || phase>=c.phaseDenominator)
    throw new RangeError("character phase");
  if (phase===0) return [1,0];
  const angle=2*PI*phase/c.phaseDenominator;
  return [Math.cos(angle),Math.sin(angle)];
}
const add=(a,b)=>[a[0]+b[0],a[1]+b[1]];
const multiply=(a,b)=>[a[0]*b[0]-a[1]*b[1],a[0]*b[1]+a[1]*b[0]];
const nToMinusS=(n,s)=>{
  const l=Math.log(n);
  const r=Math.exp(-s[0]*l),a=-s[1]*l;
  return [r*Math.cos(a),r*Math.sin(a)];
};
const inverse=z=>{
  const squared=z[0]*z[0]+z[1]*z[1];
  return [z[0]/squared,-z[1]/squared];
};
const prime=n=>{
  if (n<2) return false;
  for(let d=2;d*d<=n;d++) if(n%d===0)return false;
  return true;
};
export function finiteCharacterSum(c,lastN,s) {
  if (!verifyCharacter(c) || !Number.isInteger(lastN) || lastN<0 || lastN>127)
    throw new RangeError("character or sum cutoff");
  let total=[0,0];
  for (let n=1;n<=lastN;n++)
    total=add(total,multiply(characterValue(c,n),nToMinusS(n,s)));
  return total;
}
export function finiteCharacterLocal(c,p,s) {
  if (!verifyCharacter(c) || !prime(p) || p>31)
    throw new RangeError("character or prime");
  const x=multiply(characterValue(c,p),nToMinusS(p,s));
  return inverse([1-x[0],-x[1]]);
}
export function finiteCharacterProduct(c,lastPrime,s) {
  if (!verifyCharacter(c) || !Number.isInteger(lastPrime) ||
      lastPrime<0 || lastPrime>31)
    throw new RangeError("character or prime cutoff");
  let value=[1,0];
  for (let p=2;p<=lastPrime;p++)
    if (prime(p)) {
      const x=multiply(characterValue(c,p),nToMinusS(p,s));
      value=multiply(value,inverse([1-x[0],-x[1]]));
    }
  return value;
}
