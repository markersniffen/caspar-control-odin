package cc

UIMAIN_VS ::
`
#version 330 core
layout(location = 0) in vec3 position;
layout(location = 1) in vec2 uv;
layout(location = 2) in vec4 color;
layout(location = 3) in float mix_texture;

out vec4 vertex_color;
out vec2 uv_coords;
out float texture_mix;

void main()
{
	uv_coords = uv;
	vertex_color = color;
	texture_mix = mix_texture;
	gl_Position.xyz = position;
    //gl_Position.w = 1;
}
`

UIMAIN_FRAG ::
`
#version 330 core
in vec4 vertex_color;
in vec2 uv_coords;
in float texture_mix;

out vec4 FragColor;

uniform sampler2D tex;

void main()
{
	vec4 Mul = vec4((vertex_color.xyz * vertex_color.aaa), vertex_color.a);

	if (texture_mix == 0)
	{
		FragColor = vertex_color;
	} else {
		vec4 texs = texture(tex, uv_coords);
		FragColor = vec4(vertex_color.rgb, texs.a);
	}
}
`
//- NOTE FONT SHADER 
FONT_VS ::
`
#version 330 core
layout(location = 0) in vec3 vtx;

uniform vec4 color;
uniform mat4 scale;
uniform vec2 transform;
out vec4 vertexColor;

void main()
{
	vec4 Scaled = vec4(vtx, 1) * scale;
	vec2 Normalized = (Scaled.xy * 2) - 1;
	vec2 Trans = Normalized.xy + (transform);
	gl_Position.xy = Trans;   //vec4(vtx + vec3(transform, 0), 1) * scale;
    gl_Position.z = 0;
    gl_Position.w = 1;
    vertexColor = color;
}
`
FONT_FRAG ::
`
#version 330 core
in vec4 vertexColor;
out vec4 FragColor;

void main()
{
	FragColor = vertexColor.rgba;
}
`






//- NOTE TEXTURE SHADER 
TEXTURE_VS ::
`
#version 330 core
layout(location = 0) in vec3 position;
layout(location = 1) in vec2 UV;

out vec2 uv_coords;

void main()
{
	uv_coords = UV;
    gl_Position.xyz = position;
    gl_Position.w = 1;
}
`

TEXTURE_FRAG ::
`
#version 330 core
out vec4 FragColor;

in vec2 uv_coords;

uniform sampler2D tex;

void main()
{
	FragColor = texture(tex, uv_coords);
}
`