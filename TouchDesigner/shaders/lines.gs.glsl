layout(points) in;
layout(line_strip, max_vertices=2) out;

void main(void)
{
	gl_Position = gl_in[0].gl_Position;
    EmitVertex();

	vec4 end = gl_in[0].gl_Position;
	end.y = 0.0;
    gl_Position = end;
    EmitVertex();

}