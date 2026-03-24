#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod commands;
mod file_parser;
mod database;

use tauri::Manager;

fn main() {
    tauri::Builder::default()
        .setup(|app| {
            let app_handle = app.handle();
            tauri::async_runtime::spawn(async move {
                let _ = database::init_database(&app_handle).await;
            });
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            commands::parse_excel_file,
            commands::parse_csv_file,
            commands::save_data,
            commands::get_asin_data,
            commands::export_listing_template,
            commands::export_advertising_template,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
