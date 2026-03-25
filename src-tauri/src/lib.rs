// Tauri Library Entry Point
// This file is required for Tauri 2.0 mobile support and library builds

// Re-export all modules
pub mod commands;
pub mod database;
pub mod file_parser;

// Re-export AppState
pub use commands::AppState;
