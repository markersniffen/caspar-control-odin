package cc

// types of shaders?
//- UI shader?
//  - render from one vertex/index buffer
//  - includes [x,y,z,  u,v,  r,g,b,a ]
//  - send 
//  - 
//  - 
//  - 


//- font shader


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
    gl_Position.w = 1;
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
		FragColor = mix(texture(tex, uv_coords), vertex_color, texture_mix);
	}
}
`



//- NOTE UI SHADER 
UI_VS ::
`
#version 330 core
layout(location = 0) in vec2 vertex_position;
layout(location = 1) in vec3 color;
layout(location = 2) in vec2 uv_coords;
out vec4 vertexColor;
out vec2 UV;

void main()
{
	gl_Position = vec4(vertex_position, 0.0, 1.0);
	UV = uv_coords;
	vertexColor = vec4(color, 1);
}
`

UI_FRAG ::
`
#version 330 core
in vec4 vertexColor;
in vec2 UV;
//in float Color;

out vec4 FragColor;
uniform sampler2D myTex;

void main()
{
	float v = texture(myTex, UV)[0];
	if (UV == vec2(-1,-1))
	{
		FragColor = vertexColor;
	} else {
		FragColor = vec4(vertexColor[0],vertexColor[1],vertexColor[2],v);
	}
}
`

//- NOTE FONT SHADER 
FONT_VS ::
`
#version 330 core

layout(location = 0) in vec3 vertex_position;

out vec4 vertexColor;
out float alpha;

uniform vec2 Adv;
uniform mat4 Aspect;
uniform mat4 Transform;
uniform float Alpha;

uniform vec4 color;

void main()
{
	vec3 Adv2 = vec3(Adv, 0);
	gl_Position = vec4(vertex_position + Adv2, 1.0) * Aspect * Transform;
    vertexColor = color;
	alpha = Alpha;
}
`

FONT_FRAG ::
`
#version 330 core

in vec4 vertexColor;
in float alpha;

out vec4 FragColor;

void main()
{
	FragColor = vertexColor * vec4(1,1,1,alpha);;
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