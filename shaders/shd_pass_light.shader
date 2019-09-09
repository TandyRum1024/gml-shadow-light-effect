//
// Light pass shader
//
attribute vec3 in_Position;                  // (x,y,z)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vLightColour;

uniform vec4 uLight; // Colour of light & strength (r, g, b, intensity)

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vLightColour = uLight;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~//
// Simple light fragment shader
// renders a light buffer that is ready to applied with additive blending
//
varying vec2 v_vTexcoord;
varying vec4 v_vLightColour; // light colour

void main()
{
    const vec4 black = vec4(vec3(0.0), 1.0);
    
    // get vector to center point
    vec2 centerDelta = v_vTexcoord - vec2(0.5);
    float centerDist = 1.0 - clamp(length(centerDelta) * 2.0, 0.0, 1.0); // remap to 0..1
    
    // opaque "foreground" part lighting with gradual falloff(?)
    float lightLerp = smoothstep(0.25, 0.75, centerDist);
    vec4 lightFG = mix(black, vec4(v_vLightColour.rgb, 1.0), lightLerp * v_vLightColour.a);
    
    // translucent "background" part lighting
    const float lightBGFactor = 0.3;
    
    lightLerp = smoothstep(0.0, 0.75, centerDist);
    vec4 lightBG = mix(black, vec4(v_vLightColour.rgb * lightBGFactor, 1.0), lightLerp * v_vLightColour.a);
    
    // mix both so only foreground part (aka the parts with alpha) gets foreground lighting and same goes for background
    gl_FragColor = mix(lightBG, lightFG, texture2D( gm_BaseTexture, v_vTexcoord ).a);
}

