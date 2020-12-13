//
//  shader.metal
//  Weather
//
//  Created by Sylvie on 25.09.20.
//  Copyright © 2020 SylvieLiu. All rights reserved.
//

#include <metal_stdlib>
#include <CoreImage/CoreImage.h>
using namespace metal;

extern "C" {
    namespace coreimage {
        
        float2 warp(float2 size, float2 direction1, float2 direction2, float2 direction3, float2 direction4, float intensity, destination dest)
        {
            
            float2 newCoord = dest.coord();
            
            intensity = intensity*1.5;
            
            float edgeY = (0.5 - abs(newCoord.y/size[1]-0.5))*2;
            float edgeX = (0.5 - abs(newCoord.x/size[0]-0.5))*2;
            
            
            float radius1 = size.y*0.45;
            
            float2 location1 = size*float2(0.33, 0.33);
            float2 location2 = size*float2(0.67, 0.33);
            float2 location3 = size*float2(0.33, 0.67);
            float2 location4 = size*float2(0.67, 0.67);
            
            float dist1 = distance(location1, newCoord);
            //float dist2 = distance(location2, newCoord);
            //float dist3 = distance(location3, newCoord);
            //float dist4 = distance(location4, newCoord);
            
            float maxDistortionX = 0.34;
            float maxDistortionY = 0.34;
            
            float noramlizedImpact = (cos(dist1/radius1 * 3.14*intensity)+1)*intensity*0.5;
            float2 offset = size*float2(maxDistortionX, maxDistortionY)*direction1*noramlizedImpact;
            newCoord = newCoord +float2(offset[0]*edgeX, offset[1]*edgeY);
            
            
            float dist2 = distance(location2, newCoord);
            float noramlizedImpact2 = (cos(dist2/radius1 * 3.14) + 1)*intensity*0.5;
            offset = size*float2(maxDistortionX, maxDistortionY)*direction2*noramlizedImpact2*min(edgeY,edgeX);
            newCoord = newCoord +float2(offset[0]*edgeX, offset[1]*edgeY);
            
            float dist3 = distance(location3, newCoord);
            float noramlizedImpact3 = (cos(dist3/radius1 * 3.14) + 1)*intensity*0.5;
            offset =  size*float2(maxDistortionX, maxDistortionY)*direction3*noramlizedImpact3*min(edgeY,edgeX);
            newCoord = newCoord +float2(offset[0]*edgeX, offset[1]*edgeY);
            
            float dist4 = distance(location4, newCoord);
            float noramlizedImpact4 = (cos(dist4/radius1 * 3.14) + 1)*intensity*0.5;
            offset = size*float2(maxDistortionX, maxDistortionY)*direction4*noramlizedImpact4*min(edgeY,edgeX);
            newCoord = newCoord +float2(offset[0]*edgeX, offset[1]*edgeY);
            
            return newCoord;
        }
        
        
        float3 rgb2hsl(float3 rgb) {
            
            float maxC = max(rgb.x, max(rgb.y,rgb.z));
            float minC = min(rgb.x, min(rgb.y,rgb.z));
            
            float l = (maxC + minC)/2.0;
            
            float h = 0;
            float s = 0;
            
            if (maxC != minC) {
                float d = maxC - minC;
                s = l > 0.5 ? d / (2.0 - maxC - minC) : d / (maxC + minC);
                
                if (maxC == rgb.x) {
                    h =  (rgb.y - rgb.z) / d + (rgb.y < rgb.z ? 6.0 : 0);
                } else if (maxC == rgb.y) {
                    h = (rgb.z - rgb.x) / d + 2.0;
                }
                else {
                    h = (rgb.x - rgb.y) / d + 4.0;
                }
                
                h /= 6.0;
            }
            
            return float3(h,s,l);
        }
        
        float hue2rgb(float f1, float f2, float hue) {
            if (hue < 0) {
                hue += 1.0;
            }
            else if (hue > 1) {
                hue -= 1.0;
            }
            
            float res;
            if (6*hue<1) {
                res = f1 + (f2 - f1) * 6 * hue;
            }
            else if (2*hue<1) {
                res = f2;
            }
            else if (3*hue<2) {
                res = f1 + (f2 - f1) * (2.0/3.0 - hue) * 6;
            }
            else {
                res = f1;
            }
            return res;
        }
        
        float3 hsl2rgb(float3 hsl) {
            float3 rgb;
            if (hsl.y == 0) {
                rgb = float3(hsl.z,hsl.z,hsl.z);
            }
            else {
                float f2;
                if (hsl.z < 0.5) {
                    f2 = hsl.z * (1.0 + hsl.y);
                }
                else {
                    f2 = hsl.z + hsl.y - hsl.y * hsl.z;
                }
                
                float f1 = 2 * hsl.z - f2;
                
                float r = hue2rgb(f1, f2, hsl.x + 1.0/3.0);
                float g = hue2rgb(f1, f2, hsl.x);
                float b = hue2rgb(f1, f2, hsl.x - 1.0/3.0);
                
                rgb = float3(r,g,b);
            }
            return rgb;
        }
        
        float4 colorRGB(sample_t sample, float temperature){
            float r = sample.r;
            float g = sample.g;
            float b = sample.b;
            
            float3 hsl = rgb2hsl((float3(r,g,b)));
            float4 newColor = sample;
            
            float newH = hsl[0];
            //change green
            
            if (hsl[0]>0.55 && hsl[0]<0.7){
                newH = hsl[0]-0.035*(temperature-0.5);
                
            }
            
            
            float3 newRGB = hsl2rgb(float3(newH,hsl[1], hsl[2]));
            newColor = float4(newRGB[0],newRGB[1], newRGB[2], 1.0);
            
            
            return newColor;
        }
    }
}



