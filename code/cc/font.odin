package cc

import "core:fmt"
import "core:os"
import "core:strings"
import "core:mem"
import "core:path/filepath"
import "core:math/linalg"

import gl "vendor:OpenGL"
import ttm "../external/ttf2mesh/"

NUM_GLYPHS :: 95;
GLYPH_OFFSET :: 32;
GLYPH_RES :: 2;

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
	xbounds: [2]f32,              
	ybounds: [2]f32,              
	advance: f32,
	lbearing: f32,
	rbearing: f32,
	Verts: []f32,
	Indices: []u32,
}

ImportFont :: proc(Show: ^show, GlyphRes: u8, Path: string) -> uid
{
	using ttm;
	LoadPath := Path;
	if filepath.ext(Path) == "" do LoadPath = strings.concatenate({Path, ".ttf"});
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
		Font := new(superfont)
		Show.Assets.Font = Font
		
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
		
		Font.Filepath = StringToLong(filepath.base(LoadPath));
		P, Name := filepath.split(Path)
		Font.Name = StringToShort(Name);
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
		
		
		
		fmt.println("Font loaded");
		return Font.UID;
	} else {
		fmt.println("Font failed to load");
		return 0;
	}
}