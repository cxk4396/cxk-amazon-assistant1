// Prevents additional console window on Windows in release
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use tauri::Manager;

mod commands;
mod database;
mod file_parser;

use commands::AppState;

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .plugin(tauri_plugin_dialog::init())
        .plugin(tauri_plugin_fs::init())
        .plugin(tauri_plugin_sql::Builder::default().build())
        .manage(AppState::default())
        .setup(|app| {
            // 初始化数据库
            let db_path = app.path().app_data_dir()?.join("cxk.db");
            println!("Database path: {:?}", db_path);
            
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            commands::parse_excel_file,
            commands::parse_csv_file,
            commands::save_api_config,
            commands::get_api_config,
            commands::analyze_with_ai,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
