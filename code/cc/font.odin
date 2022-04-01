package cc

import "core:fmt"
import "core:os"
import "core:strings"
import "core:mem"
import "core:path"

import ttm "../external/ttf2mesh/"

NUM_GLYPHS :: 95;
GLYPH_OFFSET :: 32;
GLYPH_RES :: 50;

UI_FONT_TEXTURE_RES :: 2560

GlyphToIndex :: proc(G: int) -> int
{
	return G - GLYPH_OFFSET;
}

IndexToGlyph :: proc(I: int) -> int
{
	return I + GLYPH_OFFSET;
}

superfont :: struct
{
	UID: uid,
	Name: short_string,
	Filename: short_string,
	Filepath: long_string,
	Glyphs: [NUM_GLYPHS]glyph, 
	VertMemory: []f32,
	IndiceMemory: []u32,
	BaseHeight: f32,
}

glyph :: struct
{
	xbounds: v2,              
	ybounds: v2,              
	advance: f32,
	lbearing: f32,
	rbearing: f32,
	Verts: []f32,
	Indices: []u32,
}

// TODO implement this
// DeleteFont :: proc(Font: ^superfont, Show: ^show)
// {
// 	Ptr:= Show.Assets.Fonts[Font.UID];
	
// 	// delete inner-memory
// 	delete(Font.VertMemory);
// 	delete(Font.IndiceMemory);
	
// 	// delete from Map
// 	delete_key(&Show.Assets.Fonts, Font.UID);
	
// 	// free pool memory 
// 	PFree(&Show.Assets.SuperFontPool, Ptr);
// }

ImportFont :: proc(Show: ^show, GlyphRes: u8, Path: string) -> uid
{
	using ttm;
	LoadPath := Path;
	if path.ext(Path) == "" do LoadPath = strings.concatenate({Path, ".ttf"});
	fmt.println("About to try and load font:", LoadPath);
	
	//- NOTE ALLOC TODO is this right? 
	TTF: ^ttf_file = new(ttf_file, context.temp_allocator);
	//TTF: ^ttf_file = cast(^ttf_file)mem.alloc(size_of(ttf_file));
	//defer mem.free(TTF);
	
	String: cstring = strings.unsafe_string_to_cstring(LoadPath);
	
	//- NOTE ALLOC inside ttf2mesh TODO free me 
	load_from_file(String, &TTF, false);
	defer ttm.free(TTF);
	
	if TTF != nil
	{
		Meshes :[NUM_GLYPHS]^ttf_mesh;
		defer for M, i in Meshes do free_mesh(Meshes[i]);
		
		// NOTE Palloc
		Font := cast(^superfont)Palloc(&Show.Assets.SuperFontPool, Show);
		Font.UID = GetNewUID(Show);
		Show.Assets.Fonts[Font.UID] = Font;
		
		NumVerts :u32= 0;
		NumIndices :u32= 0;
		for i in 0..<NUM_GLYPHS
		{
			Gnum := find_glyph(TTF, cast(u16)IndexToGlyph(i));
			G := &TTF.glyphs[Gnum];
			if i != 0 
			{
				glyph2mesh(G, &Meshes[i], GlyphRes, 0);
				NumVerts += Meshes[i].nvert*3;
				NumIndices += Meshes[i].nfaces*3;
			}
			H := G.ybounds[1] - G.ybounds[0];
			Font.BaseHeight = max(Font.BaseHeight, H);
			
			Font.Glyphs[i].xbounds = G.xbounds;
			Font.Glyphs[i].ybounds = G.ybounds;
			Font.Glyphs[i].advance = G.advance;
			Font.Glyphs[i].lbearing = G.lbearing;
			Font.Glyphs[i].rbearing = G.rbearing;
		}
		
		Font.Filepath = StringToLong(path.base(LoadPath));
		Font.Name = StringToShort(path.name(Path));
		Font.Filename = Font.Name;
		Font.VertMemory = make_slice([]f32, int(NumVerts));
		Font.IndiceMemory = make_slice([]u32, int(NumIndices));
		
		VertMemIndex: u32 = 0;
		IndiceMemIndex: u32 = 0;
		for M, CharIndex in Meshes
		{
			if CharIndex == 0 {
				
			} else {
				Font.Glyphs[CharIndex].Verts = Font.VertMemory[VertMemIndex:VertMemIndex + M.nvert*3];
				Font.Glyphs[CharIndex].Indices = Font.IndiceMemory[IndiceMemIndex:IndiceMemIndex + M.nfaces*3];
				
				VertMemIndex += M.nvert*3;
				IndiceMemIndex += M.nfaces*3;
				
				index := 0;
				for i in 0..<M.nvert
				{
					Font.Glyphs[CharIndex].Verts[index] = M.vert[i].x;
					index += 1;
					Font.Glyphs[CharIndex].Verts[index]= M.vert[i].y;
					index += 1;
					Font.Glyphs[CharIndex].Verts[index]= 0;
					index +=1;
				}
				
				index = 0;
				for i in 0..<M.nfaces
				{
					Font.Glyphs[CharIndex].Indices[index] = M.faces[i].v1;
					index += 1;
					Font.Glyphs[CharIndex].Indices[index] = M.faces[i].v2;
					index += 1;
					Font.Glyphs[CharIndex].Indices[index] = M.faces[i].v3;
					index += 1;
				}
			}
		}
		
		if len(Show.Slides) > 0
		{
			if Show.State.CurrentElement in Show.Slides[Show.State.CurrentSlide].Elements
			{
				Show.Slides[Show.State.CurrentSlide].Elements[Show.State.CurrentElement].Font = Font.UID;
			}
		}
		
		fmt.println("Font loaded");
		return Font.UID;
	} else {
		fmt.println("Font failed to load");
		return 0;
	}
}

OpenglGenerateUIFont :: proc(Show: ^show, Font: ^superfont)
{
	fmt.println("Generating UI font.....");
	glState := Show.State.glState;
	//- NOTE Render to Font Framebuffer 
	gl.Viewport(0, 0, i32(UI_FONT_TEXTURE_RES), i32(UI_FONT_TEXTURE_RES));
	gl.BindFramebuffer(gl.FRAMEBUFFER, glState.FontFramebuffer);
	gl.ClearColor( 0, 0, 0, 1);
	gl.Clear(gl.COLOR_BUFFER_BIT);
	OpenglDrawFilledRect({0,0}, {500,500}, {1,1,0,1}, true, Show.State.WindowRes, Show);
	gl.UseProgram(glState.font_shader);
	
	Dim :f32= UI_FONT_TEXTURE_RES/10;
	AspectMat: linalg.Matrix4x4f32 = {
		{0.1,      0,         0,        -1      },  //c 2/(1-0)
		{0,      0.1,         0,        -1      },         //c 2/(1-0)
		{0,      0,         1,        0       },
		{0,      0,         0,        1       },
	};
	
	for G, i in Font.Glyphs
	{
		Show.State.UIFontOffset[i].y = G.ybounds[0];
		Show.State.UIFontOffset[i].x = G.advance;
		if i > 0
		{
			Row    := i/10;
			Column := i - (Row * 10);
			//fmt.println(Row, Column);
			// NOTE render glyph
			
			//fmt.println(G.advance, G.xbounds, G.ybounds, G.lbearing, G.rbearing);
			
			Transform : linalg.Matrix4x4f32 = {
				{ 1, 0, 0,   f32(Column)/5},
				{ 0, 1, 0,   f32(Row)/5 - (G.ybounds[0]/10)},
				{ 0, 0, 1,   0}, 
				{ 0, 0, 0,   1},
			};
			
			Pos :v2= {Dim*f32(Column), Dim*f32(Row)};
			Size :v2= Pos + {Dim, Dim};
			
			// NOTE calculates the offset matrices for each glyph
			glAspect:= gl.GetUniformLocation(glState.font_shader, "Aspect");
			glColor := gl.GetUniformLocation(glState.font_shader, "color");
			glTransform:= gl.GetUniformLocation(glState.font_shader, "Transform");
			glAlpha := gl.GetUniformLocation(glState.font_shader, "Alpha");
			glAdv := gl.GetUniformLocation(glState.font_shader, "Adv");
			
			gl.UniformMatrix4fv(glAspect, 1, gl.FALSE, &AspectMat[0][0]);
			gl.Uniform4f(glColor, 1, 1, 1, 1);
			gl.Uniform1f(glAlpha, 1);
			gl.UniformMatrix4fv(glTransform, 1, gl.FALSE, &Transform[0][0]);
			gl.Uniform2f(glAdv, 0, 0);
			
			gl.BindBuffer(gl.ARRAY_BUFFER, glState.VertexBuffer);
			gl.BufferData(gl.ARRAY_BUFFER, len(G.Verts)*size_of(f32), &G.Verts[0], gl.STATIC_DRAW);
			
			gl.EnableVertexAttribArray(0);
			gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 0, nil);
			
			gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, glState.IndexBuffer);
			gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(G.Indices)*size_of(u32), &G.Indices[0], gl.STATIC_DRAW);
			
			gl.DrawElements(gl.TRIANGLES, i32(len(G.Indices)), gl.UNSIGNED_INT, nil);
		}
	}
	
	gl.BindFramebuffer(gl.READ_FRAMEBUFFER, glState.FontFramebuffer);
	gl.BindFramebuffer(gl.DRAW_FRAMEBUFFER, glState.IntermediateFontFrameBuffer);
	gl.BlitFramebuffer(0, 0, i32(UI_FONT_TEXTURE_RES), i32(UI_FONT_TEXTURE_RES), 0, 0, i32(UI_FONT_TEXTURE_RES), i32(UI_FONT_TEXTURE_RES), gl.COLOR_BUFFER_BIT, gl.NEAREST);
}