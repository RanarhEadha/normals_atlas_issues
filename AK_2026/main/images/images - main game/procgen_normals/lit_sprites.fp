#version 140

in highp vec4 var_position;
in mediump vec2 var_texcoord0;
in mediump vec2 var_texcoord1;
in highp mat4 var_view;

out vec4 out_fragColor;

uniform mediump sampler2D texture_sampler;
uniform mediump sampler2D normal_sampler;

#define MAX_LIGHT_COUNT 10
#include "/builtins/materials/lighting.glsl"

uniform fragment_inputs
{
	vec4 ambient_color;
};

void main()
{
	vec4 color = texture(texture_sampler, var_texcoord0);

	vec3 normal = texture(normal_sampler, var_texcoord1).rgb;
	normal = normalize(normal * 2.0 - 1.0);
	normal = normalize((var_view * vec4(normal, 0.0)).xyz);

	vec3 lighting = ambient_color.rgb
	+ diffuse_lambert(normal, var_position.xyz);

	out_fragColor = vec4(color.rgb * lighting, color.a);
}