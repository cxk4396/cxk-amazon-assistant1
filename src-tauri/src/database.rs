use tauri::AppHandle;
use tauri_plugin_sql::{Migration, MigrationKind};

pub const MIGRATIONS: [&Migration
; 1] = [
    &Migration {
        version: 1,
        description: "create_initial_tables",
        sql: r#"
            -- 产品主表
            CREATE TABLE IF NOT EXISTS products (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                asin TEXT UNIQUE NOT NULL,
                sku TEXT,
                category TEXT,
                current_price DECIMAL(10,2),
                target_margin DECIMAL(5,2),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );

            -- 销售数据表
            CREATE TABLE IF NOT EXISTS sales_data (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                asin TEXT NOT NULL,
                report_date DATE,
                impressions INTEGER,
                clicks INTEGER,
                orders INTEGER,
                sales_amount DECIMAL(12,2),
                conversion_rate DECIMAL(5,4),
                ctr DECIMAL(5,4),
                FOREIGN KEY (asin) REFERENCES products(asin)
            );

            -- 文案数据表
            CREATE TABLE IF NOT EXISTS listing_content (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                asin TEXT NOT NULL,
                title TEXT,
                description TEXT,
                bullet_1 TEXT,
                bullet_2 TEXT,
                bullet_3 TEXT,
                bullet_4 TEXT,
                bullet_5 TEXT,
                search_terms TEXT,
                FOREIGN KEY (asin) REFERENCES products(asin)
            );

            -- 广告数据表
            CREATE TABLE IF NOT EXISTS advertising_data (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                asin TEXT NOT NULL,
                ad_spend DECIMAL(10,2),
                ad_sales DECIMAL(12,2),
                acos DECIMAL(5,4),
                ad_impressions INTEGER,
                ad_clicks INTEGER,
                current_bid DECIMAL(6,3),
                report_date DATE,
                FOREIGN KEY (asin) REFERENCES products(asin)
            );

            -- 竞品数据表
            CREATE TABLE IF NOT EXISTS competitor_data (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                asin TEXT NOT NULL,
                competitor_asin TEXT,
                competitor_price DECIMAL(10,2),
                competitor_keywords TEXT,
                category_rank INTEGER,
                estimated_sales INTEGER,
                captured_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );

            -- AI分析结果表
            CREATE TABLE IF NOT EXISTS ai_analysis (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                asin TEXT NOT NULL,
                analysis_type TEXT,
                model_used TEXT,
                input_data_hash TEXT,
                result_json TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (asin) REFERENCES products(asin)
            );

            -- 用户配置表
            CREATE TABLE IF NOT EXISTS user_settings (
                key TEXT PRIMARY KEY,
                value TEXT,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );

            -- 列选择模板表
            CREATE TABLE IF NOT EXISTS column_templates (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                template_name TEXT NOT NULL,
                template_description TEXT,
                file_pattern TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                is_default BOOLEAN DEFAULT 0
            );

            -- 模板列映射详情
            CREATE TABLE IF NOT EXISTS template_column_mappings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                template_id INTEGER NOT NULL,
                column_key TEXT NOT NULL,
                column_aliases TEXT,
                is_required BOOLEAN DEFAULT 0,
                ai_prompt_role TEXT,
                FOREIGN KEY (template_id) REFERENCES column_templates(id) ON DELETE CASCADE
            );

            -- 文件解析配置表
            CREATE TABLE IF NOT EXISTS file_parse_configs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                file_name TEXT NOT NULL,
                file_hash TEXT,
                sheet_name TEXT,
                template_id INTEGER,
                selected_columns TEXT,
                column_mapping TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (template_id) REFERENCES column_templates(id)
            );
        "#,
        kind: MigrationKind::Up,
    },
];
