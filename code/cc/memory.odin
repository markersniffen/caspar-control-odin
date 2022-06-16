package cc

import "core:fmt"
import "core:mem"

//- NOTE Simple Pool allocator 
// TODO make this growable...
node :: struct
{
	Next: ^node,
}

pool :: struct
{
	Memory: []byte,
	ChunkSize: int,
	ChunkCount: int,
	Head: ^node,
}

PoolInit :: proc(P: ^pool, Size: int, Count: int, Show: ^show)
{
	P.ChunkSize = Size; // set chunksize
	P.ChunkCount = Count; // set count
	Ok:any;
	P.Memory, Ok = mem.alloc_bytes(Size*Count); // allocated the total bytes
	P.Head = nil; // sets the head to null
	
	PFreeAll(P);
}

PFreeAll :: proc(P: ^pool)
{
	mem.zero(&P.Memory[0], P.ChunkCount * P.ChunkSize)
		for C in 0..<P.ChunkCount // loop through number of chunks
	{
		ptr := &P.Memory[C * P.ChunkSize]; // get pointer to the Chunk memory
		Node : ^node = cast(^node)ptr; // create  cast the pointer we just created to a Node object,
		Node.Next = P.Head; // Set the node's "Next" value to the current pool's "Head" (^node)
		P.Head = Node; // set the pool's "Head" to the current node
	}
}

Palloc :: proc (P: ^pool, Show: ^show) -> rawptr
{
	NewAlloc := P.Head;
	if NewAlloc != nil
	{
		P.Head = P.Head.Next;
		mem.zero(NewAlloc, P.ChunkSize);
		
		return NewAlloc;
	}
	return nil;
}

PFree :: proc(P: ^pool, ptr: rawptr) -> bool
{
	Node : ^node;
	
	Start := &P.Memory;
	Length := (P.ChunkSize * P.ChunkCount) - 1;
	End := &P.Memory[Length];
	
	if ptr == nil do return false;
	if !(Start <= ptr && ptr < End) do return false;
	
	// Push free node
	Node = cast(^node)ptr;
	Node.Next = P.Head;
	P.Head = Node;
	return true;
}

PDelete :: proc(P: ^pool)
{
	free(&P.Memory[0])
}