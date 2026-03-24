use serde::{Deserialize, Serialize};
use tauri::{AppHandle, command};
use std::collections::HashMap;

#[derive(Debug, Serialize, Deserialize)]
pub struct ParsedData {
    pub columns: Vec<String>,
    pub rows: Vec<HashMap<String, String>>,
}

#[command]
pub async fn parse_excel_file(path: String) -> Result<ParsedData, String> {
    crate::file_parser::parse_excel(&path).map_err(|e| e.to_string())
}

#[command]
pub async fn parse_csv_file(path: String) -> Result<ParsedData, String> {
    crate::file_parser::parse_csv(&path).map_err(|e| e.to_string())
}

#[command]
pub async fn save_data(_app: AppHandle, _data: String) -> Result<(), String> {
    Ok(())
}

#[command]
pub async fn get_asin_data(_app: AppHandle) -> Result<Vec<HashMap<String, String>>, String> {
    Ok(vec![])
}

#[command]
pub async fn export_listing_template(_data: String, _path: String) -> Result<(), String> {
    Ok(())
}

#[command]
pub async fn export_advertising_template(_data: String, _path: String) -> Result<(), String> {
    Ok(())
}
