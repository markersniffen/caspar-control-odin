package ttf2mesh

import "core:fmt"
import "core:os"
import "core:strings"
import "core:mem"

foreign import ttm "./external/ttf2mesh.lib"

//bindings
@(default_calling_convention="c", link_prefix="ttf_")
foreign ttm {
	load_from_file :: proc(filename: cstring, output: ^^ttf_file, headers_only: bool) ---;
	load_from_mem :: proc(data: [^]byte, size: int,  output: ^^ttf_file, headers_only: bool) ---;
	find_glyph :: proc(ttf: ^ttf_file, character: u16) -> int ---;
	glyph2mesh :: proc(glyph: ^ttf_glyph, output: ^^ttf_mesh, quality: u8, features: int) -> int ---;
	
	//free_outline :: proc(outline: ^ttf_outline) ---;
	free_mesh :: proc(mesh: ^ttf_mesh) ---;
	//free_mesh3d :: proc(meshL: ^ttf_mesh3d) ---;
	free :: proc(ttf: ^ttf_file) ---;
	
}

main :: proc()
{
	//FileMemory, Ok := os.read_entire_file("C:/windows/fonts/arial.ttf");
	//Len :u32= len(FileMemory);
	
	TTF: ^ttf_file = cast(^ttf_file)mem.alloc(size_of(ttf_file));
	defer free(TTF);
	
	
	String: cstring = "C:/windows/fonts/arial.ttf";
	load_from_file(String, &TTF, false);
	//load_from_mem(&FileMemory[0], Len, &TTF, false);
	Gnum := find_glyph(TTF, 'A');
	
	Glyph := &TTF.glyphs[Gnum];
	Mesh : ^ttf_mesh;
	fmt.println(TTF);
	glyph2mesh(Glyph, &Mesh, 0, 0); 
	
	fmt.println(Mesh);
	for i in 0..<Mesh.nvert
	{
		fmt.println(Mesh.vert[i]);
	}
	
	for i in 0..<Mesh.nfaces
	{
		fmt.println(Mesh.faces[i]);
	}
	
	fmt.println(strings.clone_from_cstring(cast(cstring)TTF.filename));
	
}

ttf_file :: struct
{
	nchars: u32,                   /* number of the font characters */
	nglyphs: u32,              /* number of glyphs (usually less than nchars) */
    chars: [^]u16,              /* utf16 codes array with nchars length */
    char2glyph: [^]u16,         /* glyph indeces array with nchars length */
    glyphs: [^]ttf_glyph,          /* array of the font glyphs with nglyphs length */
    filename: cstring, // const chart* ;         /* full path and file name of the font */
	glyf_csum: u32,           /* 'glyf' table checksum (used by ttf_list_fonts) */
    ubranges: [6]u32,         /* bit map of presented utf16 ranges in font. LSB of word 0 means that font has a symbols in unicode range #0. All ranges are listed in global variable ubranges[] */
	
    /* unpacked fields of "head" table */
    head: head,
	os2: os2,
	names: names,
	hhea: hhea,
}

head :: struct
{
	/* https://docs.microsoft.com/ru-ru/typography/opentype/spec/head */
	rev: f32,                /* Font revision, set by manufacturer */
	macStyle: macStyle,
} 

macStyle :: struct
{
	bold: u8, // 1;      /* this font is a bold */
	italic: u8, // 1;    /* this font is a italic */
	underline: u8, // 1; /* this font is a underline */
	outline: u8, // 1;   /* Outline */
	shadow: u8, // 1;    /* Shadow */
	condensed: u8, // 1; /* Condensed */
	extended: u8, // 1;  /* Extended */
}


/* unpacked fields of "OS/2" table (OS/2 and Windows Metrics Table) */
/* https://docs.microsoft.com/en-us/typography/opentype/spec/os2 */
os2 :: struct
{
	xAvgCharWidth: f32,        /* Average weighted escapement */
	usWeightClass: u16,     /* Weight class, see TTF_WEIGHT_XXX */
	usWidthClass: u16,      /* 1 Ultra-condensed; 2 Extra-condensed; Condensed; Semi-condensed; Medium (normal); Semi-expanded; Expanded; Extra-expanded; Ultra-expanded */
	yStrikeoutSize: f32,       /* Thickness of the strikeout stroke */
	yStrikeoutPos: f32,        /* The position of the top of the strikeout stroke relative to the baseline */
	sFamilyClass: u16,       /* Font-family class and subclass. Classification of font-family design. https://docs.microsoft.com/en-us/typography/opentype/spec/ibmfc */
	panose: [10]u8,         /* PANOSE classification number, https://monotype.github.io/panose/ */
	
	fsSelection: selection,              /* Font selection flags */
	sTypoAscender: f32,        /* The typographic ascender for this font */
	sTypoDescender: f32,       /* The typographic descender for this font */
	sTypoLineGap: f32,         /* The typographic line gap for this font */
	usWinAscent: f32,          /* The “Windows ascender” metric. This should be used to specify the height above the baseline for a clipping region */
	usWinDescent: f32,         /* The “Windows descender” metric. This should be used to specify the vertical extent below the baseline for a clipping region */
}

selection :: struct
{
	italic: u16, // : 1;    /* Font contains italic or oblique glyphs, otherwise they are upright */
	underscore: u16, //: 1; /* glyphs are underscored */
	negative: u16, // : 1;  /* glyphs have their foreground and background reversed */
	outlined: u16, // : 1;  /* Outline (hollow) glyphs, otherwise they are solid */
	strikeout: u16, //: 1;  /* glyphs are overstruck */
	bold: u16, //: 1;       /* glyphs are emboldened */
	regular: u16, //: 1;    /* glyphs are in the standard weight/style for the font */
	utm: u16, //: 1;        /* USE_TYPO_METRICS, If set, it is strongly recommended to use OS/2.sTypoAscender - OS/2.sTypoDescender + OS/2.sTypoLineGap as the default line spacing */
	oblique: u16, //: 1;    /* Font contains oblique glyphs */
}

names :: struct
{
	/* unpacked fields of "name" table */
	/* https://docs.microsoft.com/ru-ru/typography/opentype/spec/name */
	copyright: cstring,    /* Copyright notice */
	family: cstring,       /* Font Family name */
	subfamily: cstring,     /* Font Subfamily name */
	unique_id: cstring,     /* Unique font identifier */
	full_name: cstring,     /* Full font name */
	version: cstring,       /* Version string */
	ps_name: cstring,       /* PostScript name for the font */
	trademark: cstring,     /* Trademark */
	manufacturer: cstring,  /* Manufacturer Name */
	designer: cstring,      /* Designer */
	description: cstring,   /* Description */
	url_vendor: ^cstring,    /* URL Vendor */
	url_designer: ^cstring,  /* URL Designer */
	license_desc: ^cstring,  /* License Description */
	locense_url: ^cstring,   /* License Info URL */
	sample_text: ^cstring,   /* Sample text */
}

hhea :: struct
{
	ascender: f32,           /* Typographic ascent (Distance from baseline of highest ascender) */
	descender: f32,          /* Typographic descent (Distance from baseline of lowest descender) */
	lineGap: f32,            /* Typographic line gap (Distance from line1 descender to line2 ascender) */
	advanceWidthMax: f32,    /* Maximum advance width value */
	minLSideBearing: f32,    /* Minimum left sidebearing value */
	minRSideBearing: f32,    /* Minimum right sidebearing value; calculated as Min(aw - lsb - (xMax - xMin)). */
	xMaxExtent: f32,         /* Max(lsb + (xMax - xMin)) */
	caretSlope: f32,  
}

ttf_mesh :: struct
{
	nvert: u32,                    /* length of vert array */
    nfaces: u32,                   /* length of faces array */
    vert: [^]vertice,
	faces: [^]face,
    outline: ^ttf_outline,       /* see ttf_linear_outline() */
}


ttf_glyph :: struct
{
    /* general fields */
	
	index: u32,                    /* glyph index in font */
	symbol: u32,                   /* utf-16 symbol */
	npoints: u32,                  /* total points within all contours */
	ncontours: u32,                /* number of contours in outline */
	composite: u32,// : 1;       /* it is composite glyph */
    // ???? NOTE uint32_t : 31;                /* reserved flags */
	
    /* horizontal glyph metrics */
    /* see https://docs.microsoft.com/en-us/typography/opentype/spec/hmtx */
	
	xbounds: [2]f32,              /* min/max values ​​along the x coordinate */
	ybounds: [2]f32,              /* min/max values ​​along the y coordinate */
	advance: f32,                 /* advance width */
	lbearing: f32,                /* left side bearing */
	rbearing: f32,                /* right side bearing = aw - (lsb + xMax - xMin) */
	
    /* glyph outline */
	
    outline: ^ttf_outline,       /* original outline of the glyph or NULL */
};


vertice :: struct
{
	x: f32,
	y: f32,
}

face :: struct
{
	v1: u32,                   /* index of vertex #1 of triangle */
	v2: u32,              /* index of vertex #2 of triangle */
	v3: u32,                   /* index of vertex #3 of triangle */
}


ttf_outline :: struct
{
	total_points: u32,             /* total points within all contours */
	ncontours: u32,                /* number of contours in outline */
	cont: [1]contour,
}

contour :: struct
{
	length: u32, 
	subglyph_id: u32,
	subglyph_order: u32,
	pt: ^ttf_point,
}

ttf_point :: struct
{
	x: f32,                      /* point x coordinate in EM */
    y: f32,                      /* point y coordinate in EM */
	spl :u32, //1;             /* point of spliting process */
	onc :u32, //1;             /* point on curve */
	res :u32, //30;   
}