// Bounded, non-singular grid shared by independent C11, JS and WebGL2 evaluators.
// All values use finite, moderate-size inputs suitable for float32 shader tests.
const cases = [];
const add = (mode,cutoff,prime,point,character=0) => {
  cases.push(Object.freeze({mode,cutoff,prime,character,point:Object.freeze([...point])}));
};
for (const n of [0,1,2,4,9,32])
  for (const q of [[1,0],[-1,0],[0,1],[0,-1],[0.2,0.3],[-0.65,0.1]])
    add(0,n,3,q);
for (const p of [2,3,5,7,31])
  for (const s of [[2,0],[1.5,0.75],[0.65,-0.8]])
    add(1,1,p,s);
for (const n of [1,3,4,31,127])
  for (const s of [[2,0],[1.3,0.9],[0.6,-1.1]])
    add(2,n,3,s);
for (const p of [1,3,5,13,31])
  for (const s of [[2,0],[1.4,0.8],[0.85,-0.6]])
    add(3,p,3,s);
// Preserve all 81 original χ₄ cases. Additional cases exercise every
// character, including imaginary χ₅ coefficients and principal characters.
for (const character of [1,2,3,4,5,6]) {
  for (const p of [2,3,5,7]) add(1,1,p,[2,0],character);
  for (const n of [3,31,127]) add(2,n,3,[1.3,0.9],character);
  for (const p of [3,13,31]) add(3,p,3,[1.4,0.8],character);
}
export const numericCases = Object.freeze(cases);
