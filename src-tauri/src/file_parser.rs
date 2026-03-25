use std::collections::HashMap;
use calamine::{Reader, Xlsx, open_workbook};
use std::fs::File;
use csv::ReaderBuilder;

pub fn parse_excel(path: &str) -> Result<crate::commands::ParsedData, Box<dyn std::error::Error>> {
    let mut workbook: Xlsx<_> = open_workbook(path)?;
    let sheet_name = workbook.sheet_names().first().cloned().unwrap_or_default();
    
    let mut columns = vec![];
    let mut rows = vec![];
    
    if let Ok(range) = workbook.worksheet_range(&sheet_name) {
        for (i, row) in range.rows().enumerate() {
            if i == 0 {
                for cell in row {
                    columns.push(cell.to_string());
                }
            } else {
                let mut row_map = HashMap::new();
                for (j, cell) in row.iter().enumerate() {
                    if let Some(col_name) = columns.get(j) {
                        row_map.insert(col_name.clone(), cell.to_string());
                    }
                }
                rows.push(row_map);
            }
        }
    }
    
    Ok(crate::commands::ParsedData { columns, rows })
}

pub fn parse_csv(path: &str) -> Result<crate::commands::ParsedData, Box<dyn std::error::Error>> {
    let file = File::open(path)?;
    let mut rdr = ReaderBuilder::new().has_headers(true).from_reader(file);
    
    let headers = rdr.headers()?.iter().map(|s| s.to_string()).collect::<Vec<_>>();
    let columns = headers.clone();
    let mut rows = vec![];
    
    for result in rdr.records() {
        let record = result?;
        let mut row_map = HashMap::new();
        for (i, value) in record.iter().enumerate() {
            if let Some(col_name) = headers.get(i) {
                row_map.insert(col_name.clone(), value.to_string());
            }
        }
        rows.push(row_map);
    }
    
    Ok(crate::commands::ParsedData { columns, rows })
}
