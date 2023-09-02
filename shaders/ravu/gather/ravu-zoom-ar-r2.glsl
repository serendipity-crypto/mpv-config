// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

//!DESC RAVU-Zoom-AR (luma, r2)
//!HOOK LUMA
//!BIND HOOKED
//!BIND ravu_zoom_lut2
//!BIND ravu_zoom_lut2_ar
//!WIDTH OUTPUT.w
//!HEIGHT OUTPUT.h
//!OFFSET ALIGN
//!WHEN HOOKED.w OUTPUT.w < HOOKED.h OUTPUT.h < *
#define LUTPOS(x, lut_size) mix(0.5 / (lut_size), 1.0 - 0.5 / (lut_size), (x))
vec4 hook() {
vec2 pos = HOOKED_pos * HOOKED_size;
vec2 subpix = fract(pos - 0.5);
pos -= subpix;
subpix = LUTPOS(subpix, vec2(9.0));
vec2 subpix_inv = 1.0 - subpix;
subpix /= vec2(2.0, 288.0);
subpix_inv /= vec2(2.0, 288.0);
vec4 gather0 = HOOKED_mul * textureGatherOffset(HOOKED_raw, pos * HOOKED_pt, ivec2(-1, -1), 0);
vec4 gather2 = HOOKED_mul * textureGatherOffset(HOOKED_raw, pos * HOOKED_pt, ivec2(-1, 1), 0);
vec4 gather8 = HOOKED_mul * textureGatherOffset(HOOKED_raw, pos * HOOKED_pt, ivec2(1, -1), 0);
vec4 gather10 = HOOKED_mul * textureGatherOffset(HOOKED_raw, pos * HOOKED_pt, ivec2(1, 1), 0);
vec3 abd = vec3(0.0);
float gx, gy;
gx = (gather0.z-gather0.w);
gy = (gather0.x-gather0.w);
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.04792235409415088;
gx = (gather0.y-gather0.x);
gy = (gather2.w-gather0.w)/2.0;
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.06153352068439959;
gx = (gather2.z-gather2.w);
gy = (gather2.x-gather0.x)/2.0;
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.06153352068439959;
gx = (gather2.y-gather2.x);
gy = (gather2.x-gather2.w);
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.04792235409415088;
gx = (gather8.w-gather0.w)/2.0;
gy = (gather0.y-gather0.z);
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.06153352068439959;
gx = (gather8.x-gather0.x)/2.0;
gy = (gather2.z-gather0.z)/2.0;
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.07901060453704994;
gx = (gather10.w-gather2.w)/2.0;
gy = (gather2.y-gather0.y)/2.0;
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.07901060453704994;
gx = (gather10.x-gather2.x)/2.0;
gy = (gather2.y-gather2.z);
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.06153352068439959;
gx = (gather8.z-gather0.z)/2.0;
gy = (gather8.x-gather8.w);
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.06153352068439959;
gx = (gather8.y-gather0.y)/2.0;
gy = (gather10.w-gather8.w)/2.0;
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.07901060453704994;
gx = (gather10.z-gather2.z)/2.0;
gy = (gather10.x-gather8.x)/2.0;
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.07901060453704994;
gx = (gather10.y-gather2.y)/2.0;
gy = (gather10.x-gather10.w);
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.06153352068439959;
gx = (gather8.z-gather8.w);
gy = (gather8.y-gather8.z);
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.04792235409415088;
gx = (gather8.y-gather8.x);
gy = (gather10.z-gather8.z)/2.0;
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.06153352068439959;
gx = (gather10.z-gather10.w);
gy = (gather10.y-gather8.y)/2.0;
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.06153352068439959;
gx = (gather10.y-gather10.x);
gy = (gather10.y-gather10.z);
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.04792235409415088;
float a = abd.x, b = abd.y, d = abd.z;
float T = a + d, D = a * d - b * b;
float delta = sqrt(max(T * T / 4.0 - D, 0.0));
float L1 = T / 2.0 + delta, L2 = T / 2.0 - delta;
float sqrtL1 = sqrt(L1), sqrtL2 = sqrt(L2);
float theta = mix(mod(atan(L1 - a, b) + 3.141592653589793, 3.141592653589793), 0.0, abs(b) < 1.192092896e-7);
float lambda = sqrtL1;
float mu = mix((sqrtL1 - sqrtL2) / (sqrtL1 + sqrtL2), 0.0, sqrtL1 + sqrtL2 < 1.192092896e-7);
float angle = floor(theta * 24.0 / 3.141592653589793);
float strength = mix(mix(0.0, 1.0, lambda >= 0.004), mix(2.0, 3.0, lambda >= 0.05), lambda >= 0.016);
float coherence = mix(mix(0.0, 1.0, mu >= 0.25), 2.0, mu >= 0.5);
float coord_y = ((angle * 4.0 + strength) * 3.0 + coherence) / 288.0;
float res = 0.0;
vec4 w;
vec4 cg, cg1;
float lo = 0.0, hi = 0.0;
float lo2 = 0.0, hi2 = 0.0;
w = texture(ravu_zoom_lut2, vec2(0.0, coord_y) + subpix);
res += gather0.w * w[0];
res += gather0.x * w[1];
res += gather2.w * w[2];
res += gather2.x * w[3];
w = texture(ravu_zoom_lut2, vec2(0.5, coord_y) + subpix);
res += gather0.z * w[0];
res += gather0.y * w[1];
res += gather2.z * w[2];
res += gather2.y * w[3];
w = texture(ravu_zoom_lut2, vec2(0.0, coord_y) + subpix_inv);
res += gather10.y * w[0];
res += gather10.z * w[1];
res += gather8.y * w[2];
res += gather8.z * w[3];
w = texture(ravu_zoom_lut2, vec2(0.5, coord_y) + subpix_inv);
res += gather10.x * w[0];
res += gather10.w * w[1];
res += gather8.x * w[2];
res += gather8.w * w[3];
w = texture(ravu_zoom_lut2_ar, vec2(0.0, coord_y) + subpix);
cg = vec4(0.5 + gather0.w, 1.5 - gather0.w, 0.5 + gather0.x, 1.5 - gather0.x);
cg1 = cg;
cg *= cg;cg *= cg;cg *= cg;cg *= cg;cg *= cg;
hi += cg[0] * w[0] + cg[2] * w[1];
lo += cg[1] * w[0] + cg[3] * w[1];
cg *= cg1;
hi2 += cg[0] * w[0] + cg[2] * w[1];
lo2 += cg[1] * w[0] + cg[3] * w[1];
cg = vec4(0.5 + gather2.w, 1.5 - gather2.w, 0.5 + gather2.x, 1.5 - gather2.x);
cg1 = cg;
cg *= cg;cg *= cg;cg *= cg;cg *= cg;cg *= cg;
hi += cg[0] * w[2] + cg[2] * w[3];
lo += cg[1] * w[2] + cg[3] * w[3];
cg *= cg1;
hi2 += cg[0] * w[2] + cg[2] * w[3];
lo2 += cg[1] * w[2] + cg[3] * w[3];
w = texture(ravu_zoom_lut2_ar, vec2(0.5, coord_y) + subpix);
cg = vec4(0.5 + gather0.z, 1.5 - gather0.z, 0.5 + gather0.y, 1.5 - gather0.y);
cg1 = cg;
cg *= cg;cg *= cg;cg *= cg;cg *= cg;cg *= cg;
hi += cg[0] * w[0] + cg[2] * w[1];
lo += cg[1] * w[0] + cg[3] * w[1];
cg *= cg1;
hi2 += cg[0] * w[0] + cg[2] * w[1];
lo2 += cg[1] * w[0] + cg[3] * w[1];
cg = vec4(0.5 + gather2.z, 1.5 - gather2.z, 0.5 + gather2.y, 1.5 - gather2.y);
cg1 = cg;
cg *= cg;cg *= cg;cg *= cg;cg *= cg;cg *= cg;
hi += cg[0] * w[2] + cg[2] * w[3];
lo += cg[1] * w[2] + cg[3] * w[3];
cg *= cg1;
hi2 += cg[0] * w[2] + cg[2] * w[3];
lo2 += cg[1] * w[2] + cg[3] * w[3];
w = texture(ravu_zoom_lut2_ar, vec2(0.0, coord_y) + subpix_inv);
cg = vec4(0.5 + gather10.y, 1.5 - gather10.y, 0.5 + gather10.z, 1.5 - gather10.z);
cg1 = cg;
cg *= cg;cg *= cg;cg *= cg;cg *= cg;cg *= cg;
hi += cg[0] * w[0] + cg[2] * w[1];
lo += cg[1] * w[0] + cg[3] * w[1];
cg *= cg1;
hi2 += cg[0] * w[0] + cg[2] * w[1];
lo2 += cg[1] * w[0] + cg[3] * w[1];
cg = vec4(0.5 + gather8.y, 1.5 - gather8.y, 0.5 + gather8.z, 1.5 - gather8.z);
cg1 = cg;
cg *= cg;cg *= cg;cg *= cg;cg *= cg;cg *= cg;
hi += cg[0] * w[2] + cg[2] * w[3];
lo += cg[1] * w[2] + cg[3] * w[3];
cg *= cg1;
hi2 += cg[0] * w[2] + cg[2] * w[3];
lo2 += cg[1] * w[2] + cg[3] * w[3];
w = texture(ravu_zoom_lut2_ar, vec2(0.5, coord_y) + subpix_inv);
cg = vec4(0.5 + gather10.x, 1.5 - gather10.x, 0.5 + gather10.w, 1.5 - gather10.w);
cg1 = cg;
cg *= cg;cg *= cg;cg *= cg;cg *= cg;cg *= cg;
hi += cg[0] * w[0] + cg[2] * w[1];
lo += cg[1] * w[0] + cg[3] * w[1];
cg *= cg1;
hi2 += cg[0] * w[0] + cg[2] * w[1];
lo2 += cg[1] * w[0] + cg[3] * w[1];
cg = vec4(0.5 + gather8.x, 1.5 - gather8.x, 0.5 + gather8.w, 1.5 - gather8.w);
cg1 = cg;
cg *= cg;cg *= cg;cg *= cg;cg *= cg;cg *= cg;
hi += cg[0] * w[2] + cg[2] * w[3];
lo += cg[1] * w[2] + cg[3] * w[3];
cg *= cg1;
hi2 += cg[0] * w[2] + cg[2] * w[3];
lo2 += cg[1] * w[2] + cg[3] * w[3];
hi = hi2 / hi - 0.5;
lo = 1.5 - lo2 / lo;
res = mix(res, clamp(res, lo, hi), 0.800000);
return vec4(res, 0.0, 0.0, 0.0);
}
//!TEXTURE ravu_zoom_lut2
//!SIZE 18 2592
//!FORMAT rgba16f
//!FILTER LINEAR
//!TEXTURE ravu_zoom_lut2_ar
//!SIZE 18 2592
//!FORMAT rgba16f
//!FILTER LINEAR