// Presentation adapter. The mathematical character generator is independent
// of WebGL, and the original seven-character reference remains compatible.
import {evaluate} from "./eval.mjs";
import {
  MAX_MODULUS, generateCharacter,
  finiteCharacterSum, finiteCharacterLocal, finiteCharacterProduct
} from "./characters.mjs";

export const GENERATED_CHARACTER_ID = 7;

export function evaluateSelected(model,cutoff,prime,point,selection=0) {
  if (typeof selection === "number")
    return evaluate(model,cutoff,prime,point,selection);
  if (!selection || !Array.isArray(selection.phases))
    throw new RangeError("character selection");
  if (model===0) return evaluate(0,cutoff,prime,point,0);
  if (model===1) return finiteCharacterLocal(selection,prime,point);
  if (model===2) return finiteCharacterSum(selection,cutoff,point);
  if (model===3) return finiteCharacterProduct(selection,cutoff,point);
  throw new RangeError("model");
}

export function selectGeneratedCharacter(modulus,index) {
  return generateCharacter(modulus,index);
}

export function shaderCharacterPayload(selection) {
  const phases=new Int32Array(MAX_MODULUS);
  phases.fill(-1);
  if (typeof selection==="number") {
    if (!Number.isInteger(selection) || selection<0 || selection>=GENERATED_CHARACTER_ID)
      throw new RangeError("catalogue character");
    return {generated:0,character:selection,modulus:1,denominator:1,phases};
  }
  if (!selection || !Array.isArray(selection.phases) ||
      selection.modulus<1 || selection.modulus>MAX_MODULUS ||
      selection.phases.length!==selection.modulus)
    throw new RangeError("generated character");
  phases.set(selection.phases);
  return {
    generated:1,character:0,modulus:selection.modulus,
    denominator:selection.phaseDenominator,phases
  };
}
