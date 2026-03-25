use serde::{Deserialize, Serialize};
use tauri::State;
use std::sync::Mutex;
use crate::file_parser::FileParser;

// 文件解析相关命令
#[derive(Debug, Serialize, Deserialize)]
pub struct ParseResult {
    pub success: bool,
    pub data: Option<Vec<serde_json::Value>>,
    pub errors: Option<Vec<String>>,
    pub row_count: usize,
}

#[tauri::command]
pub async fn parse_excel_file(file_path: String, sheet_name: Option<String>) -> Result<ParseResult, String> {
    match FileParser::parse_excel(&file_path, sheet_name.as_deref()) {
        Ok(data) => {
            let row_count = data.len();
            let json_data: Vec<serde_json::Value> = data.into_iter()
                .map(|m| serde_json::to_value(m).unwrap_or(serde_json::Value::Null))
                .collect();
            Ok(ParseResult {
                success: true,
                data: Some(json_data),
                errors: None,
                row_count,
            })
        }
        Err(e) => Ok(ParseResult {
            success: false,
            data: None,
            errors: Some(vec![e]),
            row_count: 0,
        })
    }
}

#[tauri::command]
pub async fn parse_csv_file(file_path: String) -> Result<ParseResult, String> {
    match FileParser::parse_csv(&file_path) {
        Ok(data) => {
            let row_count = data.len();
            let json_data: Vec<serde_json::Value> = data.into_iter()
                .map(|m| serde_json::to_value(m).unwrap_or(serde_json::Value::Null))
                .collect();
            Ok(ParseResult {
                success: true,
                data: Some(json_data),
                errors: None,
                row_count,
            })
        }
        Err(e) => Ok(ParseResult {
            success: false,
            data: None,
            errors: Some(vec![e]),
            row_count: 0,
        })
    }
}

// API配置相关命令
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct ApiConfig {
    pub base_url: String,
    pub api_key: String,
    pub model: String,
}

pub struct AppState {
    pub api_config: Mutex<Option<ApiConfig>>,
}

impl Default for AppState {
    fn default() -> Self {
        Self {
            api_config: Mutex::new(None),
        }
    }
}

#[tauri::command]
pub async fn save_api_config(config: ApiConfig, state: State<'_, AppState>) -> Result<(), String> {
    let mut api_config = state.api_config.lock().map_err(|e| e.to_string())?;
    *api_config = Some(config);
    Ok(())
}

#[tauri::command]
pub async fn get_api_config(state: State<'_, AppState>) -> Result<Option<ApiConfig>, String> {
    let api_config = state.api_config.lock().map_err(|e| e.to_string())?;
    Ok(api_config.clone())
}

// AI分析命令
#[derive(Debug, Serialize, Deserialize)]
pub struct AnalysisRequest {
    pub asin: String,
    pub data: serde_json::Value,
    pub analysis_type: String,
}

#[tauri::command]
pub async fn analyze_with_ai(request: AnalysisRequest, state: State<'_, AppState>) -> Result<serde_json::Value, String> {
    let api_config = state.api_config.lock().map_err(|e| e.to_string())?;
    let _config = api_config.as_ref().ok_or("API配置未设置")?;
    
    // TODO: 实现实际的AI调用
    // 这里返回模拟数据
    Ok(serde_json::json!({
        "status": "success",
        "asin": request.asin,
        "analysis_type": request.analysis_type,
        "result": {
            "diagnosis": {
                "overall_health": "健康",
                "score": 75,
                "primary_issue": "曝光量偏低",
                "root_cause": "广告竞价偏低"
            },
            "optimization": {
                "listing": {
                    "keywords_to_add": ["portable charger", "power bank"],
                    "optimized_title": "优化后的标题..."
                },
                "advertising": {
                    "bid_adjustment": { "current": 0.8, "recommended": 1.2 }
                }
            }
        }
    }))
}
