import {evaluate} from "./eval.mjs";

const WEGERT_REVISION = "873d03e86ec2e4a9236bb2d253fee3c8fde83b6c";
const WEGERT_COLOR_URL =
  "https://raw.githubusercontent.com/isomorphismes/wegert/" +
  WEGERT_REVISION + "/code/wegert_color.glsl";

const byId = id => document.getElementById(id);
const canvas = byId("portrait"), modelInput = byId("model");
const cutoffInput = byId("cutoff"), cutoffRow = byId("cutoff-row");
const primeInput = byId("prime"), primeRow = byId("prime-row");
const cutoffLabel = byId("cutoff-label"), cutoffValue = byId("cutoff-value");
const formula = byId("formula"), scope = byId("scope");
const probe = byId("probe"), status = byId("status"), plane = byId("plane");
const gl = canvas.getContext("webgl2", {antialias:false, alpha:false});
let program = null, center = [0,0], halfHeight = 1.6, lastMode = 0;
let drawScheduled = false, gestureMoved = false;
const pointers = new Map(), uniforms = {};
const specs = [
  {min:1,max:32,initial:4,label:"Number of terms N"},
  {min:1,max:32,initial:4,label:""},
  {min:1,max:127,initial:31,label:"Last integer N"},
  {min:2,max:31,initial:13,label:"Last prime bound P"}
];
const model = () => Number(modelInput.value);
const cutoff = () => Number(cutoffInput.value);
const prime = () => Number(primeInput.value);
const clamp = (x,a,b) => Math.min(b,Math.max(a,x));
function formatNumber(x) {
  if (!Number.isFinite(x)) return String(x);
  if (Math.abs(x) < 5e-12) return "0";
  return Number(x.toPrecision(7)).toString();
}
function formatComplex(z) {
  if (!Number.isFinite(z[0]) || !Number.isFinite(z[1])) return "undefined / pole";
  return formatNumber(z[0]) + (z[1] < 0 ? " − " : " + ") +
    formatNumber(Math.abs(z[1])) + "i";
}
function probeAt(z) {
  try {
    const v = evaluate(model(),cutoff(),prime(),z), mag = Math.hypot(v[0],v[1]);
    const extra = Number.isFinite(mag) && mag > 0 ?
      "\narg = " + formatNumber(Math.atan2(v[1],v[0])) +
      " rad · ln|f| = " + formatNumber(Math.log(mag)) : "";
    probe.textContent = (model() === 0 ? "q" : "s") + " = " + formatComplex(z) +
      "\nf = " + formatComplex(v) + extra;
  } catch(e) { probe.textContent = "Probe error: " + e.message; }
}
function updateMathText() {
  const n=cutoff(), p=prime(), m=model();
  if (m===0) {
    formula.textContent="G("+n+",q) = Σ[k=0…"+(n-1)+"] q^k";
    scope.textContent="A finite polynomial. At q=1 its value is "+n+
      ", not a pole. For N=4 its zeros are −1, +i and −i.";
    plane.textContent="q-plane · finite polynomial";
  } else if (m===1) {
    formula.textContent="1/(1 − χ₄("+p+")·"+p+"^(−s))";
    scope.textContent="One meromorphic Euler factor, not the global L-function. "+
      "Denominator zeros are genuine poles of this local factor.";
    plane.textContent="s-plane · one Euler factor";
  } else if (m===2) {
    formula.textContent="S("+n+",s) = Σ[n=1…"+n+"] χ₄(n)n^(−s)";
    scope.textContent="Finite and entire. As N→∞ the χ₄ series tends to L(s,χ₄) "+
      "for Re(s)>0, absolutely for Re(s)>1. A finite portrait is not continuation.";
    plane.textContent="s-plane · finite Dirichlet sum";
  } else {
    formula.textContent="P("+n+",s) = ∏[prime p≤"+n+"] (1−χ₄(p)p^(−s))^(−1)";
    scope.textContent="Finite meromorphic product; its infinite limit equals L(s,χ₄) "+
      "for Re(s)>1. Outside this domain it is NOT continuation or an L-zero portrait.";
    plane.textContent="s-plane · finite Euler product";
  }
}
function resetCamera() {
  if (model()===0) {center=[0,0];halfHeight=1.6;}
  else {center=[1.1,0];halfHeight=2.7;}
  queueDraw();
}
function chooseModel() {
  const m=model(), spec=specs[m];
  cutoffRow.hidden=m===1; primeRow.hidden=m!==1;
  cutoffInput.min=String(spec.min); cutoffInput.max=String(spec.max);
  cutoffInput.value=String(spec.initial);
  cutoffLabel.textContent=spec.label; cutoffValue.textContent=String(spec.initial);
  updateMathText();
  if ((lastMode===0)!==(m===0)) resetCamera();
  lastMode=m; probeAt(m===0?[1,0]:[2,0]); queueDraw();
}
function queueDraw() {
  if (drawScheduled || !program) return;
  drawScheduled=true;
  requestAnimationFrame(()=>{drawScheduled=false;render();});
}
function render() {
  if (!program) return;
  const rect=canvas.getBoundingClientRect(), dpr=Math.min(window.devicePixelRatio||1,1.25);
  const width=Math.max(1,Math.floor(rect.width*dpr));
  const height=Math.max(1,Math.floor(rect.height*dpr));
  if (canvas.width!==width || canvas.height!==height) {canvas.width=width;canvas.height=height;}
  gl.viewport(0,0,width,height); gl.useProgram(program);
  gl.uniform2f(uniforms.center,center[0],center[1]);
  gl.uniform1f(uniforms.halfHeight,halfHeight);
  gl.uniform1f(uniforms.aspect,width/height);
  gl.uniform1i(uniforms.model,model());
  gl.uniform1i(uniforms.cutoff,cutoff());
  gl.uniform1i(uniforms.prime,prime());
  gl.drawArrays(gl.TRIANGLES,0,3);
}
function worldFromScreen(point) {
  const r=canvas.getBoundingClientRect();
  return [center[0]+(2*point[0]/r.width-1)*halfHeight*r.width/r.height,
          center[1]+(1-2*point[1]/r.height)*halfHeight];
}
function screenPoint(e) {
  const r=canvas.getBoundingClientRect();
  return [e.clientX-r.left,e.clientY-r.top];
}
const midpoint=(a,b)=>[(a[0]+b[0])/2,(a[1]+b[1])/2];
const distance=(a,b)=>Math.hypot(a[0]-b[0],a[1]-b[1]);

canvas.addEventListener("pointerdown",e=>{
  e.preventDefault();canvas.setPointerCapture(e.pointerId);
  pointers.set(e.pointerId,screenPoint(e)); gestureMoved=pointers.size>1;
});
canvas.addEventListener("pointermove",e=>{
  if (!pointers.has(e.pointerId)) return;
  e.preventDefault();
  const before=[...pointers.values()], next=screenPoint(e), prev=pointers.get(e.pointerId);
  pointers.set(e.pointerId,next);
  const after=[...pointers.values()];
  if (distance(prev,next)<0.0001) return;
  if (distance(prev,next)>0.5) gestureMoved=true;
  if (after.length===1) {
    const height=canvas.getBoundingClientRect().height;
    center[0]-=2*halfHeight*(next[0]-prev[0])/height;
    center[1]+=2*halfHeight*(next[1]-prev[1])/height;
  } else if (after.length===2) {
    const oldMid=midpoint(before[0],before[1]), oldWorld=worldFromScreen(oldMid);
    const oldDist=distance(before[0],before[1]), newDist=distance(after[0],after[1]);
    if (oldDist>1 && newDist>1) halfHeight=clamp(halfHeight*oldDist/newDist,0.025,80);
    const newWorld=worldFromScreen(midpoint(after[0],after[1]));
    center[0]+=oldWorld[0]-newWorld[0]; center[1]+=oldWorld[1]-newWorld[1];
  }
  queueDraw();
});
canvas.addEventListener("pointerup",e=>{
  if (!pointers.has(e.pointerId)) return;
  if (!gestureMoved && pointers.size===1) probeAt(worldFromScreen(screenPoint(e)));
  pointers.delete(e.pointerId);
});
canvas.addEventListener("pointercancel",e=>pointers.delete(e.pointerId));
canvas.addEventListener("wheel",e=>{
  e.preventDefault();
  const point=screenPoint(e), before=worldFromScreen(point);
  halfHeight=clamp(halfHeight*Math.exp(e.deltaY*0.0015),0.025,80);
  const after=worldFromScreen(point);
  center[0]+=before[0]-after[0]; center[1]+=before[1]-after[1]; queueDraw();
},{passive:false});
canvas.addEventListener("dblclick",e=>{e.preventDefault();resetCamera();});
modelInput.addEventListener("change",chooseModel);
cutoffInput.addEventListener("input",()=>{
  cutoffValue.textContent=cutoffInput.value;updateMathText();queueDraw();
});
primeInput.addEventListener("change",()=>{updateMathText();probeAt([2,0]);queueDraw();});
byId("reset").addEventListener("click",resetCamera);

function compiled(type,source) {
  const shader=gl.createShader(type);
  gl.shaderSource(shader,source);gl.compileShader(shader);
  if (!gl.getShaderParameter(shader,gl.COMPILE_STATUS)) {
    const reason=gl.getShaderInfoLog(shader);gl.deleteShader(shader);
    throw new Error("GLSL compile: "+reason);
  }
  return shader;
}
async function loadText(url) {
  const response=await fetch(url);
  if (!response.ok) throw new Error("Fetch HTTP "+response.status+" from "+url);
  return response.text();
}
async function initialize() {
  if (!gl) {
    status.textContent="WebGL2 unavailable; no rendering fallback selected.";
    return;
  }
  try {
    const [core,template]=await Promise.all([
      loadText(WEGERT_COLOR_URL),loadText(new URL("./dirichlet.frag.in",import.meta.url))
    ]);
    if (!core.includes("vec3 wegert_color_complex") ||
        !template.includes("/*__WEGERT_COLOR_CORE__*/"))
      throw new Error("Pinned upstream Wegert source does not match shader seam");
    const frag=template.replace("/*__WEGERT_COLOR_CORE__*/",core);
    const vert="#version 300 es\nout vec2 v_ndc;\n"+
      "void main(){\nvec2 p=gl_VertexID==0?vec2(-1.0,-1.0):"+
      "(gl_VertexID==1?vec2(3.0,-1.0):vec2(-1.0,3.0));\n"+
      "v_ndc=p;gl_Position=vec4(p,0.0,1.0);\n}\n";
    const vs=compiled(gl.VERTEX_SHADER,vert), fs=compiled(gl.FRAGMENT_SHADER,frag);
    program=gl.createProgram();gl.attachShader(program,vs);gl.attachShader(program,fs);
    gl.linkProgram(program);gl.deleteShader(vs);gl.deleteShader(fs);
    if (!gl.getProgramParameter(program,gl.LINK_STATUS))
      throw new Error("GLSL program link: "+gl.getProgramInfoLog(program));
    gl.bindVertexArray(gl.createVertexArray());
    for (const [key,name] of Object.entries({
      center:"u_center",halfHeight:"u_half_height",aspect:"u_aspect",
      model:"u_model",cutoff:"u_cutoff",prime:"u_prime"
    })) uniforms[key]=gl.getUniformLocation(program,name);
    status.textContent="WebGL2 GLSL linked. Browser renderer: "+gl.getParameter(gl.RENDERER)+
      "; pinned Wegert "+WEGERT_REVISION.slice(0,12)+
      ". No physical-device qualification.";
    queueDraw();
  } catch(e) {program=null;status.textContent="No phase portrait: "+e.message;}
}
if (gl) canvas.addEventListener("webglcontextlost",e=>{
  e.preventDefault();program=null;status.textContent="WebGL2 context lost.";
});
chooseModel();
if (typeof ResizeObserver!=="undefined") new ResizeObserver(queueDraw).observe(canvas);
window.addEventListener("resize",queueDraw);
initialize();
