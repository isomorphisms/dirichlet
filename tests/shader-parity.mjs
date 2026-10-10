import {evaluate} from "../web/eval.mjs";
import {numericCases} from "./numeric-cases.mjs";

const report = document.getElementById("report");
const REV = "873d03e86ec2e4a9236bb2d253fee3c8fde83b6c";
const SOURCE_URL = "https://raw.githubusercontent.com/isomorphismes/wegert/" +
  REV + "/code/wegert_color.glsl";
const canvas = document.createElement("canvas");
canvas.width=1;
canvas.height=1;
const gl = canvas.getContext("webgl2", {
  alpha:false,antialias:false,depth:false,preserveDrawingBuffer:true
});

async function getText(url) {
  const response=await fetch(url);
  if (!response.ok) throw new Error("Fetch error HTTP "+response.status+" "+url);
  return response.text();
}
function compile(type,src) {
  const shader=gl.createShader(type);
  gl.shaderSource(shader,src);
  gl.compileShader(shader);
  if (!gl.getShaderParameter(shader,gl.COMPILE_STATUS))
    throw new Error("GLSL compile: "+gl.getShaderInfoLog(shader));
  return shader;
}
function link(vertex,fragment) {
  const program=gl.createProgram();
  gl.attachShader(program,vertex);
  gl.attachShader(program,fragment);
  gl.linkProgram(program);
  if (!gl.getProgramParameter(program,gl.LINK_STATUS))
    throw new Error("GLSL link: "+gl.getProgramInfoLog(program));
  gl.deleteShader(vertex);
  gl.deleteShader(fragment);
  return program;
}
async function verify() {
  if (!gl) throw new Error("WebGL2 unavailable; no CPU fallback accepted");
  const [core,template]=await Promise.all([
    getText(SOURCE_URL),
    getText(new URL("../web/dirichlet.frag.in",import.meta.url))
  ]);
  if (!core.includes("vec3 wegert_color_complex") ||
      !template.startsWith("#version 300 es") ||
      !template.includes("/*__WEGERT_COLOR_CORE__*/") ||
      !template.includes("#ifdef DIRICHLET_NUMERIC_CAPTURE"))
    throw new Error("Wegert GLSL source/adapter missing");
  // Same fragment template and function implementation as the visible
  // phase portrait. Only the final color output changes to raw float bytes.
  const fragment=template
    .replace("/*__WEGERT_COLOR_CORE__*/",core)
    .replace("#version 300 es",
             "#version 300 es\n#define DIRICHLET_NUMERIC_CAPTURE");
  const vertex="#version 300 es\nout vec2 v_ndc;\n"+
    "void main(){vec2 p=gl_VertexID==0?vec2(-1.0,-1.0):"+
    "(gl_VertexID==1?vec2(3.0,-1.0):vec2(-1.0,3.0));"+
    "v_ndc=p;gl_Position=vec4(p,0.0,1.0);}\n";
  const program=link(
    compile(gl.VERTEX_SHADER,vertex),
    compile(gl.FRAGMENT_SHADER,fragment)
  );
  gl.useProgram(program);
  function u(name) {
    const location=gl.getUniformLocation(program,name);
    if (location===null) throw new Error("Missing required uniform "+name);
    return location;
  }
  const uniforms={
    center:u("u_center"),
    halfHeight:u("u_half_height"),
    aspect:u("u_aspect"),
    model:u("u_model"),
    cutoff:u("u_cutoff"),
    prime:u("u_prime"),
    component:u("u_capture_component")
  };
  // An offscreen RGBA8 framebuffer, not the composited browser canvas.
  // With GL_DITHER disabled the output bytes exactly carry float32 bits.
  const texture=gl.createTexture();
  gl.bindTexture(gl.TEXTURE_2D,texture);
  gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST);
  gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST);
  gl.texImage2D(gl.TEXTURE_2D,0,gl.RGBA8,1,1,0,
    gl.RGBA,gl.UNSIGNED_BYTE,null);
  const framebuffer=gl.createFramebuffer();
  gl.bindFramebuffer(gl.FRAMEBUFFER,framebuffer);
  gl.framebufferTexture2D(gl.FRAMEBUFFER,gl.COLOR_ATTACHMENT0,
    gl.TEXTURE_2D,texture,0);
  if (gl.checkFramebufferStatus(gl.FRAMEBUFFER)!==gl.FRAMEBUFFER_COMPLETE)
    throw new Error("RGBA8 framebuffer incomplete");
  gl.bindVertexArray(gl.createVertexArray());
  gl.viewport(0,0,1,1);
  gl.disable(gl.BLEND);
  gl.disable(gl.DITHER);
  gl.disable(gl.SCISSOR_TEST);
  gl.colorMask(true,true,true,true);
  gl.pixelStorei(gl.PACK_ALIGNMENT,1);
  const raw=new Uint8Array(4);
  function sample(component) {
    gl.uniform1i(uniforms.component,component);
    gl.drawArrays(gl.TRIANGLES,0,3);
    gl.readPixels(0,0,1,1,gl.RGBA,gl.UNSIGNED_BYTE,raw);
    const error=gl.getError();
    if (error!==gl.NO_ERROR) throw new Error("GL error "+error);
    // GLSL floatBitsToUint encodes IEEE-754 float32 little-endian
    // in the four unnormalized bytes. This is NOT pixel-color comparison.
    return new DataView(raw.buffer).getFloat32(0,true);
  }
  let worst=0;
  const perMode=[0,0,0,0];
  for (const [index,c] of numericCases.entries()) {
    const expected=evaluate(c.mode,c.cutoff,c.prime,c.point);
    if (!expected.every(Number.isFinite))
      throw new Error("Invalid CPU grid point "+index);
    gl.uniform2f(uniforms.center,c.point[0],c.point[1]);
    gl.uniform1f(uniforms.halfHeight,0.0);
    gl.uniform1f(uniforms.aspect,1.0);
    gl.uniform1i(uniforms.model,c.mode);
    gl.uniform1i(uniforms.cutoff,c.cutoff);
    gl.uniform1i(uniforms.prime,c.prime);
    const actual=[sample(0),sample(1)];
    if (!actual.every(Number.isFinite))
      throw new Error("Nonfinite GPU result "+JSON.stringify({index,c,actual}));
    const error=Math.hypot(actual[0]-expected[0],actual[1]-expected[1]);
    const bound=0.0002+0.0003*Math.hypot(...expected);
    if (error>bound)
      throw new Error("CPU/shader disagreement "+JSON.stringify({
        index,c,actual,expected,error,bound
      }));
    worst=Math.max(worst,error);
    perMode[c.mode]++;
  }
  report.dataset.parityStatus="pass";
  report.dataset.parityPoints=String(numericCases.length);
  report.dataset.parityWorst=String(worst);
  report.textContent="PASS: "+numericCases.length+" GLSL-vs-CPU float32 complex values"+
    "\nCases by mode: "+perMode.join("/")+
    "\nWorst absolute complex difference: "+worst.toExponential(5)+
    "\nBrowser renderer: "+gl.getParameter(gl.RENDERER)+
    "\nPinned Wegert source: "+REV+
    "\nBackend evidence: headless browser software GPU only, not PowerVR.";
}
verify().catch(error=>{
  report.dataset.parityStatus="fail";
  report.textContent="FAIL: "+String(error.stack||error);
});
