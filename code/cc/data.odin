package cc

import "core:fmt"
import "core:encoding/csv"
import "core:os"
import "core:strings"

LoadCSV :: proc(Name: string)
{
	fmt.println("Loading CSV file")
	rdr : csv.Reader
	data, err := os.read_entire_file_from_filename(Name)
	defer delete(data)
 	
 	csvstring := string(data)
	csv.reader_init_with_string(&rdr, csvstring)
	
	Page : page
	rstate : search
	rpage := 0
	for {
		using csv
		record, rerr := csv.read(&rdr)
		if is_io_error(rerr, .EOF) {
			fmt.println("End of file!")
			break
		}
		if rerr != nil {
			fmt.println("Error:", rerr)
			break
		}


		if record[0] == "#page"
		{
			fmt.println("found a page!")
			if rpage > 0
			{
				append(&Show.Data.Pages, Page)
			}

			Page = {}
			rpage += 1
			rstate = .FIND_TABLE
		}

		if rstate == .FIND_TABLE
		{
			if len(record[0]) >= 5
			{
				if record[0][:5] == "Table"
				{
					fmt.println("Found table:", record[0])
					Page.Table = record[0]
					rstate = .FIND_CATEGORIES
				}
			}
		}

		if rstate == .FIND_CATEGORIES
		{
			if len(record[1]) > 0
			{
				rstate = .FIND_DATA
			}
		}

		if rstate == .FIND_DATA
		{
			if len(record[0]) > 0
			{
				rstate = .READ_DATA
			}
		}

		if rstate == .READ_DATA
		{
			append(&Page.RawData, record)
		}

	}
	
	fmt.println("END!")
}

search :: enum
{
	DEFAULT,
	FIND_TABLE,
	FIND_CATEGORIES,
	FIND_DATA,
	READ_DATA,
}

page :: struct
{
	Name: string,
	Table: string,
	Question: string,
	RawData: [dynamic][]string,
	Points: [dynamic]point,
}

point :: struct
{
	RowName: string,
	Letter: rune,
	Value: f64,
	Suffix: rune,
	Sig: string,

}