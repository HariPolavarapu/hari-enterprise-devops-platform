# Database Backup Script

#!/bin/bash

set -e

BACKUP_DIR="${1:-./backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
POSTGRES_CONTAINER="hari-postgres"

echo "=========================================="
echo "Database Backup"
echo "=========================================="

mkdir -p "$BACKUP_DIR"

echo "Backing up databases..."

# Backup all databases
docker exec $POSTGRES_CONTAINER pg_dumpall -U postgres | gzip > "$BACKUP_DIR/all_databases_$TIMESTAMP.sql.gz"

echo "✓ All databases backed up to: $BACKUP_DIR/all_databases_$TIMESTAMP.sql.gz"

echo ""
echo "Backup Details:"
ls -lh "$BACKUP_DIR"/*.gz | tail -5

echo ""
echo "=========================================="
