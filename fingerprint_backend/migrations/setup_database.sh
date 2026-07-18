#!/bin/bash
# setup_database.sh
# هذا الملف مخصص ليتم تنفيذه مرة واحدة فقط عند إعداد الخادم
# يقوم بإنشاء قاعدة البيانات وتنفيذ الجداول الأساسية

set -e

DB_NAME="fingerprint_db"
DB_USER="postgres"
DB_PASS="postgres"
MIGRATION_FILE="init_tables.sql"

# الانتقال إلى مسار المجلد الحالي (migrations)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$DIR"

echo "Creating database $DB_NAME..."

# استخدام TCP (localhost) بدلاً من Unix socket لتجنب peer auth
export PGPASSWORD="$DB_PASS"

# إنشاء قاعدة البيانات
createdb -h localhost -p 5432 -U "$DB_USER" "$DB_NAME" 2>/dev/null && echo "Database created successfully." || echo "Warning: Database creation failed, it might already exist. Proceeding to table creation..."

echo "Running migrations from $MIGRATION_FILE..."

# تنفيذ ملف إنشاء الجداول
psql -h localhost -p 5432 -U "$DB_USER" -d "$DB_NAME" -f "$MIGRATION_FILE"

if [ $? -eq 0 ]; then
    echo "Setup completed successfully."
else
    echo "Error: Failed to create database tables."
    exit 1
fi
