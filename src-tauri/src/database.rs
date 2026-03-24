use tauri::AppHandle;
use rusqlite::{Connection, Result};
use std::sync::Mutex;

pub struct Database {
    conn: Mutex<Connection>,
}

pub async fn init_database(_app: &AppHandle) -> Result<(), String> {
    Ok(())
}
