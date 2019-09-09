//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~//
// Very simple blur effect, With strength of the blur increases as it gets closer to the screen's edge.
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 uBlurDir; // direction of blur; (1, 0) = horizontal, (0, 1) = vertical
uniform vec2 uPixelSize; // size of single texel; calculated with (1 / texture_width, 1 / texture_height)

uniform sampler2D uTexNoise; // noise texture, blue noise is recommended.

#define DITHER

void main()
{
    // set up some for loop value
    const float halfSteps = 3.0;
    
    #ifdef DITHER
        const float beginStep = -halfSteps + 1.0;
        const float endStep = halfSteps - 1.0;
        const float invSteps = 1.0 / (halfSteps * 2.0 - 1.0);
    #else
        const float beginStep = -halfSteps;
        const float endStep = halfSteps;
        const float invSteps = 1.0 / (halfSteps * 2.0 + 1.0);
    #endif
    
    // get vector to center point
    vec2 centerDelta = v_vTexcoord - vec2(0.5);
    float centerDist = length(centerDelta) * 2.0; // remap to 0..1
    
    // zoom UV
    float zoomStrength = 0.1;
    float zoomFactor = 1.0 / (1.05 + centerDist * zoomStrength);
    vec2 zoomUV = (v_vTexcoord - 0.5) * zoomFactor + 0.5;
    
    // calculate blur factor
    float blurFactor = smoothstep(0.25, 1.0, centerDist) * 5.0;
    
    // calculate uv-space noise
    const float textile = 20.0; // repeat texture 20 times on x axis
    vec2 texratio = uPixelSize / vec2(uPixelSize.x);
    float noise = texture2D(uTexNoise, fract(v_vTexcoord * textile / texratio)).r * 2.0 - 1.0;
    
    // blur em'
    vec4 final = vec4(0.0);
    for (float i=beginStep; i<=endStep; i+=1.0)
    {
        #ifdef DITHER
            // the value from the noise will "dither" between previous and next i value...
            float currentStep = i + noise;
        #else
            // no dither
            float currentStep = i;
        #endif
        
        // using that, we can calculate the offset UV for blur
        vec2 offsetUV = uPixelSize * uBlurDir * blurFactor * currentStep;
        
        final += v_vColour * texture2D( gm_BaseTexture, zoomUV + offsetUV ) * invSteps;
    }
    
    gl_FragColor = final;
}

