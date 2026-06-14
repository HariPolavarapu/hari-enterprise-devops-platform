# Database Backup Script

#!/bin/bash

set -e

BACKUP_DIR="${1:-./backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
echo "=========================================="
echo "Database Backup"
echo "=========================================="

mkdir -p "$BACKUP_DIR"

echo "Backing up databases..."

# Backup all databases
docker compose exec -T postgres pg_dumpall -U "${DB_USER:-app_user}" | gzip > "$BACKUP_DIR/all_databases_$TIMESTAMP.sql.gz"

echo "✓ All databases backed up to: $BACKUP_DIR/all_databases_$TIMESTAMP.sql.gz"

echo ""
echo "Backup Details:"
ls -lh "$BACKUP_DIR"/*.gz | tail -5

echo ""
echo "=========================================="
