//
// Shadow pass shader
//
attribute vec3 in_Position;                  // (x,y,z)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vShadowColour;

uniform vec4 uShadow; // Colour of shadow & strength : (r, g, b, strength)

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vShadowColour = uShadow;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~//
// Simple tint & vignette shadow shader
// renders a shadow buffer that is ready to applied with multiplicative blending
//
varying vec2 v_vTexcoord;
varying vec4 v_vShadowColour;

void main()
{
    vec4 shadow = vec4(1.0);

    // calculate shadow colour
    shadow = vec4(mix(vec3(1.0), v_vShadowColour.rgb, v_vShadowColour.a * texture2D( gm_BaseTexture, v_vTexcoord ).a), 1.0);
    
    // get vector to center point for vignette
    vec2 centerDelta = v_vTexcoord - vec2(0.5);
    float centerDist = clamp(length(centerDelta), 0.0, 1.0);
    
    // calculate vignette
    float vignettelerp = smoothstep(0.25, 1.0, centerDist * v_vShadowColour.a);
    vec4 vignette = vec4(mix(shadow.rgb, v_vShadowColour.rgb, vignettelerp), 1.0);
    
    gl_FragColor = vignette;
}

