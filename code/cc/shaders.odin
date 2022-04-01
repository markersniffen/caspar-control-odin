package cc

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