#version 140
#define MAX_LIGHT_COUNT 10

// https://github.com/mattdesl/lwjgl-basics/wiki/ShaderLesson6

// attributes from vertex shader
in mediump vec2 var_texcoord0;
in mediump vec2 var_texcoord1;

in highp vec4 var_position;
in highp mat4 var_view;

// our texture samplers
uniform sampler2D diffuse;   // diffuse map
uniform sampler2D normal;    // normal map


out vec4 out_fragColor;

#include "/builtins/materials/lighting.glsl"

void main() {
    // RGBA of our diffuse color
    vec4 diffuse_rgba = texture(diffuse, var_texcoord0);

    // RGB of our normal map
    vec3 normal_rgb = texture(normal, var_texcoord1).rgb;

    // normalize our vectors
    vec3 N = normalize(normal_rgb * 2.0 - 1.0);
    N = normalize((var_view * vec4(N, 0.0)).xyz);

    vec3 diffuse = diffuse_lambert(N, var_position.xyz);
    vec3 ambient = ambient_light();
    
    // the calculation which brings it all together
    vec3 intensity = ambient + diffuse;
    vec3 final_color = diffuse_rgba.rgb * intensity;
    out_fragColor = vec4(final_color, diffuse_rgba.a);
    //out_fragColor = vec4(normal_rgb, diffuse_rgba.a);
    //out_fragColor = vec4(var_texcoord1.x, var_texcoord1.y, 0.0, 1.0);
}