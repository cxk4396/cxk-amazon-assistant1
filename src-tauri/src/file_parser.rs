use calamine::{Reader, Xlsx, open_workbook, Data};
use csv::ReaderBuilder;
use serde_json::{Value, json};
use std::collections::HashMap;

pub struct FileParser;

impl FileParser {
    pub fn parse_excel(file_path: &str, sheet_name: Option<&str>) -> Result<Vec<HashMap<String, Value>>, String> {
        let mut workbook: Xlsx<std::io::BufReader<std::fs::File>> = 
            open_workbook(file_path).map_err(|e| format!("打开Excel文件失败: {}", e))?;
        
        let sheet = if let Some(name) = sheet_name {
            workbook.worksheet_range(name)
                .ok_or_else(|| format!("工作表 '{}' 不存在", name))?
                .map_err(|e| format!("读取工作表失败: {}", e))?
        } else {
            let first_sheet = workbook.sheet_names().first()
                .ok_or("Excel文件没有工作表")?
                .clone();
            workbook.worksheet_range(&first_sheet)
                .ok_or_else(|| format!("无法读取第一个工作表"))?
                .map_err(|e| format!("读取工作表失败: {}", e))?
        };

        let mut headers: Vec<String> = Vec::new();
        let mut data: Vec<HashMap<String, Value>> = Vec::new();

        for (row_idx, row) in sheet.rows().enumerate() {
            if row_idx == 0 {
                // 第一行是表头
                for cell in row {
                    headers.push(cell.to_string());
                }
            } else {
                // 数据行
                let mut record: HashMap<String, Value> = HashMap::new();
                for (col_idx, cell) in row.iter().enumerate() {
                    if let Some(header) = headers.get(col_idx) {
                        let value = match cell {
                            Data::Int(i) => json!(i),
                            Data::Float(f) => json!(f),
                            Data::String(s) => json!(s),
                            Data::Bool(b) => json!(b),
                            Data::DateTime(d) => json!(d.as_f64()),
                            _ => json!(null),
                        };
                        record.insert(header.clone(), value);
                    }
                }
                if !record.is_empty() {
                    data.push(record);
                }
            }
        }

        Ok(data)
    }

    pub fn parse_csv(file_path: &str) -> Result<Vec<HashMap<String, Value>>, String> {
        let file = std::fs::File::open(file_path)
            .map_err(|e| format!("打开CSV文件失败: {}", e))?;
        
        let mut reader = ReaderBuilder::new()
            .has_headers(true)
            .from_reader(file);

        let headers = reader.headers()
            .map_err(|e| format!("读取CSV表头失败: {}", e))?
            .iter()
            .map(|s| s.to_string())
            .collect::<Vec<_>();

        let mut data: Vec<HashMap<String, Value>> = Vec::new();

        for result in reader.records() {
            let record = result.map_err(|e| format!("读取CSV行失败: {}", e))?;
            let mut row: HashMap<String, Value> = HashMap::new();
            
            for (idx, field) in record.iter().enumerate() {
                if let Some(header) = headers.get(idx) {
                    row.insert(header.clone(), json!(field));
                }
            }
            
            if !row.is_empty() {
                data.push(row);
            }
        }

        Ok(data)
    }

    pub fn detect_file_type(file_path: &str) -> &'static str {
        if file_path.ends_with(".csv") {
            "csv"
        } else if file_path.ends_with(".xlsx") || file_path.ends_with(".xls") {
            "excel"
        } else {
            "unknown"
        }
    }
}
