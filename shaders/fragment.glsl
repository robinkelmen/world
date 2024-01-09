


/* 
* SMOOTH MOD
* - authored by @charstiles -
* based on https://math.stackexchange.com/questions/2491494/does-there-exist-a-smooth-approximation-of-x-bmod-y
* (axis) input axis to modify
* (amp) amplitude of each edge/tip
* (rad) radius of each edge/tip
* returns => smooth edges
*/

#define PI 3.1415926535897932384626433832795




varying vec3 vPosition;

uniform sampler2D uTexture;
uniform float uTime;
 uniform bool seamlessU;
  uniform bool seamlessV;

varying vec2 vUv;
varying vec3 vNormal;
varying float vDisplacement;
varying vec2 uv0; /* one way */
varying vec2 uv1; /* other way */
varying float u0;
varying float u1;
varying float v0;
varying float v1;
varying float u;
varying float v;

// Description : Array and textureless GLSL 2D/3D/4D simplex 
//               noise functions.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : stegu
//     Lastmod : 20201014 (stegu)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//               https://github.com/stegu/webgl-noise
// 
vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
     return mod289(((x*34.0)+10.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

float snoise(vec3 v)
  { 
  const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
  const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

// First corner
  vec3 i  = floor(v + dot(v, C.yyy) );
  vec3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min( g.xyz, l.zxy );
  vec3 i2 = max( g.xyz, l.zxy );

  //   x0 = x0 - 0.0 + 0.0 * C.xxx;
  //   x1 = x0 - i1  + 1.0 * C.xxx;
  //   x2 = x0 - i2  + 2.0 * C.xxx;
  //   x3 = x0 - 1.0 + 3.0 * C.xxx;
  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
  vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

// Permutations
  i = mod289(i); 
  vec4 p = permute( permute( permute( 
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

// Gradients: 7x7 points over a square, mapped onto an octahedron.
// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
  float n_ = 0.142857142857; // 1.0/7.0
  vec3  ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4( x.xy, y.xy );
  vec4 b1 = vec4( x.zw, y.zw );

  //vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
  //vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
  vec4 s0 = floor(b0)*2.0 + 1.0;
  vec4 s1 = floor(b1)*2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  vec3 p0 = vec3(a0.xy,h.x);
  vec3 p1 = vec3(a0.zw,h.y);
  vec3 p2 = vec3(a1.xy,h.z);
  vec3 p3 = vec3(a1.zw,h.w);

//Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  vec4 m = max(0.5 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 105.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), 
                                dot(p2,x2), dot(p3,x3) ) );
  }

float fbm4(vec3 p, float theta, float f, float lac, float r)
{
    mat3 mtx = mat3(
        cos(theta), -sin(theta), 0.0,
        sin(theta), cos(theta), 0.0,
        0.0, 0.0, 1.0);

    float frequency = f;
    float lacunarity = lac;
    float roughness = r;
    float amp = 1.0;
    float total_amp = 0.0;

    float accum = 0.0;
    vec3 X = p * frequency;
    for(int i = 0; i < 4; i++)
    {
        accum += amp * snoise(X);
        X *= (lacunarity + (snoise(X) + 0.1) * 0.006);
        X = mtx * X;

        total_amp += amp;
        amp *= roughness;
    }

    return accum / total_amp;
}

float fbm8(vec3 p, float theta, float f, float lac, float r)
{
    mat3 mtx = mat3(
        cos(theta), -sin(theta), 0.0,
        sin(theta), cos(theta), 0.0,
        0.0, 0.0, 1.0);

    float frequency = f;
    float lacunarity = lac;
    float roughness = r;
    float amp = 1.0;
    float total_amp = 0.0;

    float accum = 0.0;
    vec3 X = p * frequency;
    for(int i = 0; i < 8; i++)
    {
        accum += amp * snoise(X);
        X *= (lacunarity + (snoise(X) + 0.1) * 0.006);
        X = mtx * X;

        total_amp += amp;
        amp *= roughness;
    }

    return accum / total_amp;
}

float turbulence(float val)
{
    float n = 1.0 - abs(val);
    return n * n;
}

float pattern(in vec3 p, inout vec3 q, inout vec3 r)
{
    q.x = fbm4( p + 0.0, 0.0, 1.0, 2.0, 0.33 );
    q.y = fbm4( p + 6.0, 0.0, 1.0, 2.0, 0.33 );

    r.x = fbm8( p + q - 2.4, 0.0, 1.0, 3.0, 0.5 );
    r.y = fbm8( p + q + 8.2, 0.0, 1.0, 3.0, 0.5 );

    q.x = turbulence( q.x );
    q.y = turbulence( q.y );

    float f = fbm4( p + (1.0 * r), 0.0, 1.0, 2.0, 0.5);

    return f;
}




float smoothMod(float axis, float amp, float rad){
    float top = cos(PI * (axis / amp)) * sin(PI * (axis / amp));
    float bottom = pow(sin(PI * (axis / amp)), 2.0) + pow(rad, 2.0);
    float at = atan(top / bottom);
    return amp * (1.0 / 2.0) - (1.0 / PI) * at;
}

float fit(float unscaled, float originalMin, float originalMax, float minAllowed, float maxAllowed){
    return (maxAllowed - minAllowed) * (unscaled - originalMin) / (originalMax - originalMin) + minAllowed;
}

float wave(vec3 position){
    return  fit(smoothMod(position.y * 15.0, 1.0, 1.5), 0.35, 0.6, 0.0, 1.0);
}

float color(vec3 xyz) { return snoise(xyz); }
void main(){

vec2 uv = vUv;
float t = uTime ;

    vec3 spectrum[4];
    spectrum[0] = vec3(1.00, 1.00, 0.00);
    spectrum[1] = vec3(0.50, 0.00, 0.00);
    spectrum[2] = vec3(1.00, 0.40, 0.20);
    spectrum[3] = vec3(1.00, 0.60, 0.00);

    
   

    uv -= 0.5;
    uv *= 30.;

    vec2 uvT;
      if (seamlessU && seamlessV) {
        uvT.x = (fwidth(uv0.x) < fwidth(uv1.x) - 0.001) ? uv0.x : uv1.x;
        uvT.y = (fwidth(uv0.y) < fwidth(uv1.y) - 0.001) ? uv0.y : uv1.y;
    } else if (seamlessU) {
        uvT.x = (fwidth(u0) < fwidth(u1) - 0.001) ? u0 : u1;
        uvT.y = v;
    } else if (seamlessV) {
        uvT.x = u;
        uvT.y = (fwidth(v0) < fwidth(v1) - 0.001) ? v0 : v1;
    }
   // gl_FragColor.rgb = texture2D(mySampler, uvT).rgb * diffuse;

    uv = uvT;
  

    vec3 p = vec3(uv.x, uv.y, t);
    vec3 q = vec3(0.0);
    vec3 r = vec3(0.0);
	vec3 brigth_q = vec3(0.0);
    vec3 brigth_r = vec3(0.0);
	vec3 black_q = vec3(0.0);
    vec3 black_r = vec3(0.0);
	vec3 p2=vec3(p.xy*0.02,p.z*0.1);
    
    float black= pattern(p2 ,black_q ,black_r );
    black = smoothstep(0.9,0.1,length(black_q*black));
           
    float brigth= pattern( p2*2.,brigth_q ,brigth_r );
    brigth = smoothstep(0.0,0.8,brigth*length(brigth_q));

    p+=min(length(brigth_q) ,length(black_q)  )*5.;

    float f = pattern(p, q, r);

    vec3 color = vec3(0.0);
    color = mix(spectrum[1], spectrum[3], pow(length(q), 2.0));
    color = mix(color, spectrum[3], pow(length(r), 1.4));

    color = pow(color, vec3(2.0));



gl_FragColor = vec4( pow(black,2.)*(color +  spectrum[2]*brigth*5.), 1.0);;
}