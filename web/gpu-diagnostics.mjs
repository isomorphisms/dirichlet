// Opt-in WebGL2 numeric readback on the real running browser/Android host.
// This reuses the exact visible fragment source with its capture macro enabled.
// No precomputed colors, CPU-only fallback, or synthetic PASS result.
import {evaluate} from "./eval.mjs";
import {numericCases} from "./numeric-cases.mjs";

const vertexSource = [
  "#version 300 es",
  "out vec2 v_ndc;",
  "void main() {",
  "vec2 p = gl_VertexID == 0 ? vec2(-1.0,-1.0) :",
  "  (gl_VertexID == 1 ? vec2(3.0,-1.0) : vec2(-1.0,3.0));",
  "v_ndc = p;",
  "gl_Position = vec4(p,0.0,1.0);",
  "}"
].join("\n");

export function assessPair(actual, expected) {
  if (!Array.isArray(actual) || actual.length !== 2 ||
      !actual.every(Number.isFinite) ||
      !Array.isArray(expected) || expected.length !== 2 ||
      !expected.every(Number.isFinite))
    return {ok:false, error:Infinity, bound:0};
  const error = Math.hypot(actual[0]-expected[0],actual[1]-expected[1]);
  const bound = 0.0002 + 0.0003*Math.hypot(expected[0], expected[1]);
  return {ok:error <= bound, error, bound};
}

function compile(gl, type, source) {
  const shader=gl.createShader(type);
  if (shader===null) throw new Error("Cannot create GLSL shader");
  gl.shaderSource(shader,source);
  gl.compileShader(shader);
  if (gl.getShaderParameter(shader,gl.COMPILE_STATUS)) return shader;
  const message=gl.getShaderInfoLog(shader)||"unknown compilation error";
  gl.deleteShader(shader);
  throw new Error("Numeric GLSL compilation failed: "+message);
}

function requireUniform(gl, program, name) {
  const location=gl.getUniformLocation(program,name);
  if (location===null) throw new Error("Missing GLSL uniform "+name);
  return location;
}

function rendererInfo(gl) {
  const ext=gl.getExtension("WEBGL_debug_renderer_info");
  return {
    renderer:String(gl.getParameter(gl.RENDERER)),
    vendor:String(gl.getParameter(gl.VENDOR)),
    unmaskedRenderer:ext ? String(gl.getParameter(ext.UNMASKED_RENDERER_WEBGL)) : "(unavailable)",
    unmaskedVendor:ext ? String(gl.getParameter(ext.UNMASKED_VENDOR_WEBGL)) : "(unavailable)",
    glVersion:String(gl.getParameter(gl.VERSION)),
    shadingLanguage:String(gl.getParameter(gl.SHADING_LANGUAGE_VERSION))
  };
}

export async function runGpuDiagnostics(visibleFragment, onProgress=()=>{}) {
  if (!visibleFragment.startsWith("#version 300 es\n") ||
      !visibleFragment.includes("vec3 wegert_color_complex") ||
      !visibleFragment.includes("#ifdef DIRICHLET_NUMERIC_CAPTURE") ||
      visibleFragment.includes("/*__WEGERT_COLOR_CORE__*/"))
    throw new Error("Cannot capture: visible shader source incomplete");
  if (numericCases.length!==171)
    throw new Error("Expected exactly 171 certified reference grid cases");

  const canvas=document.createElement("canvas");
  canvas.width=1; canvas.height=1;
  const gl=canvas.getContext("webgl2",{
    alpha:false,antialias:false,depth:false,stencil:false,
    preserveDrawingBuffer:true
  });
  if (!gl) throw new Error("WebGL2 missing; CPU fallback is prohibited");
  const gpu=rendererInfo(gl);
  const start=performance.now();
  let program=null,texture=null,framebuffer=null,vao=null;
  try {
    const fragment=visibleFragment.replace("#version 300 es\n",
      "#version 300 es\n#define DIRICHLET_NUMERIC_CAPTURE\n");
    const vs=compile(gl,gl.VERTEX_SHADER,vertexSource);
    let fs;
    try { fs=compile(gl,gl.FRAGMENT_SHADER,fragment); }
    catch(e) { gl.deleteShader(vs); throw e; }
    program=gl.createProgram();
    if (!program) throw new Error("GL program allocation failed");
    gl.attachShader(program,vs); gl.attachShader(program,fs);
    gl.linkProgram(program);
    gl.deleteShader(vs); gl.deleteShader(fs);
    if (!gl.getProgramParameter(program,gl.LINK_STATUS))
      throw new Error("Numeric GLSL program link failed: "+gl.getProgramInfoLog(program));
    gl.useProgram(program);
    const u={
      center:requireUniform(gl,program,"u_center"),
      halfHeight:requireUniform(gl,program,"u_half_height"),
      aspect:requireUniform(gl,program,"u_aspect"),
      model:requireUniform(gl,program,"u_model"),
      cutoff:requireUniform(gl,program,"u_cutoff"),
      prime:requireUniform(gl,program,"u_prime"),
      character:requireUniform(gl,program,"u_character"),
      component:requireUniform(gl,program,"u_capture_component")
    };
    texture=gl.createTexture();
    if (!texture) throw new Error("RGBA8 texture allocation failed");
    gl.bindTexture(gl.TEXTURE_2D,texture);
    gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_WRAP_S,gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_WRAP_T,gl.CLAMP_TO_EDGE);
    gl.texImage2D(gl.TEXTURE_2D,0,gl.RGBA8,1,1,0,
      gl.RGBA,gl.UNSIGNED_BYTE,null);
    framebuffer=gl.createFramebuffer();
    if (!framebuffer) throw new Error("RGBA8 framebuffer allocation failed");
    gl.bindFramebuffer(gl.FRAMEBUFFER,framebuffer);
    gl.framebufferTexture2D(gl.FRAMEBUFFER,gl.COLOR_ATTACHMENT0,
      gl.TEXTURE_2D,texture,0);
    if (gl.checkFramebufferStatus(gl.FRAMEBUFFER)!==gl.FRAMEBUFFER_COMPLETE)
      throw new Error("RGBA8 numeric framebuffer incomplete");
    vao=gl.createVertexArray();
    if (!vao) throw new Error("GL vertex-array allocation failed");
    gl.bindVertexArray(vao);
    gl.viewport(0,0,1,1);
    gl.disable(gl.BLEND);
    gl.disable(gl.DITHER);
    gl.disable(gl.SCISSOR_TEST);
    gl.colorMask(true,true,true,true);
    gl.pixelStorei(gl.PACK_ALIGNMENT,1);
    const raw=new Uint8Array(4);
    const dv=new DataView(raw.buffer);
    function sample(component) {
      gl.uniform1i(u.component,component);
      gl.drawArrays(gl.TRIANGLES,0,3);
      gl.readPixels(0,0,1,1,gl.RGBA,gl.UNSIGNED_BYTE,raw);
      const code=gl.getError();
      if (code!==gl.NO_ERROR || gl.isContextLost())
        throw new Error("WebGL2 numerical readback failed (GL error "+code+")");
      return dv.getFloat32(0,true);
    }

    let worstError=0,worstCase=null,failed=0,tested=0;
    const casesByMode=[0,0,0,0], failures=[];
    for (const [index,c] of numericCases.entries()) {
      const expected=evaluate(c.mode,c.cutoff,c.prime,c.point,c.character);
      if (!expected.every(Number.isFinite))
        throw new Error("Nonfinite JavaScript reference at sample "+index);
      gl.uniform2f(u.center,c.point[0],c.point[1]);
      gl.uniform1f(u.halfHeight,0.0);
      gl.uniform1f(u.aspect,1.0);
      gl.uniform1i(u.model,c.mode);
      gl.uniform1i(u.cutoff,c.cutoff);
      gl.uniform1i(u.prime,c.prime);
      gl.uniform1i(u.character,c.character);
      const actual=[sample(0),sample(1)];
      const comparison=assessPair(actual,expected);
      tested++;
      casesByMode[c.mode]++;
      if (comparison.error>worstError) {
        worstError=comparison.error;
        worstCase={index,mode:c.mode,character:c.character,
          point:c.point,actual,expected,
          error:comparison.error,bound:comparison.bound};
      }
      if (!comparison.ok) {
        failed++;
        if (failures.length<5) failures.push({
          index,mode:c.mode,character:c.character,point:c.point,
          actual,expected,error:comparison.error,bound:comparison.bound
        });
      }
      // The 171 real readbacks finish in one bounded run. Waiting for
      // animation frames can strand headless/browser smoke at partial grids.
      if (tested%32===0) onProgress(tested,numericCases.length);
    }
    gl.finish();
    return {
      status:failed===0?"pass":"fail", total:numericCases.length,
      tested, failed, casesByMode, worstError, worstCase,
      failures, elapsedMs:performance.now()-start,
      gpu, devicePixelRatio:window.devicePixelRatio||1
    };
  } finally {
    gl.bindFramebuffer(gl.FRAMEBUFFER,null);
    if (framebuffer) gl.deleteFramebuffer(framebuffer);
    if (texture) gl.deleteTexture(texture);
    if (vao) gl.deleteVertexArray(vao);
    if (program) gl.deleteProgram(program);
    gl.getExtension("WEBGL_lose_context")?.loseContext();
  }
}

export function formatGpuReport(result, gitSha="browser/no APK source receipt") {
  const fields=[
    (result.status==="pass"?"PASS":"FAIL")+
      ": "+(result.tested-result.failed)+"/"+result.total+
      " GLSL-vs-JavaScript complex samples",
    "Failures: "+result.failed,
    "Cases by mode (geometric/local/sum/product): "+result.casesByMode.join("/"),
    "Worst absolute complex error: "+result.worstError.toExponential(6),
    "Time incl. GPU readbacks: "+result.elapsedMs.toFixed(1)+" ms",
    "Source commit: "+gitSha,
    "WebGL renderer: "+result.gpu.renderer,
    "Unmasked renderer: "+result.gpu.unmaskedRenderer,
    "WebGL vendor: "+result.gpu.vendor,
    "Unmasked vendor: "+result.gpu.unmaskedVendor,
    "GL version: "+result.gpu.glVersion,
    "GLSL version: "+result.gpu.shadingLanguage,
    "Device pixel ratio: "+result.devicePixelRatio,
    "Numerical check only; not proof of all screen pixels or published device acceptance."
  ];
  if (result.worstCase)
    fields.push("Worst-case detail: "+JSON.stringify(result.worstCase));
  if (result.failures.length)
    fields.push("First discrepancies: "+JSON.stringify(result.failures));
  return fields.join("\n");
}
