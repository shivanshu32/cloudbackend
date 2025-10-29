"""
Fix voting_logs.csv header to match new format
"""
import os
import csv
import shutil
from datetime import datetime

# File paths
csv_file = 'voting_logs.csv'
backup_file = f'voting_logs_backup_{datetime.now().strftime("%Y%m%d_%H%M%S")}.csv'

print("=" * 60)
print("Fix voting_logs.csv Header")
print("=" * 60)
print()

# Check if file exists
if not os.path.exists(csv_file):
    print(f"✓ {csv_file} doesn't exist - will be created with correct format")
    exit(0)

# Backup the old file
print(f"1. Creating backup: {backup_file}")
shutil.copy2(csv_file, backup_file)
print(f"   ✓ Backup created")
print()

# Read all data from old file
print("2. Reading existing data...")
old_data = []
with open(csv_file, 'r', encoding='utf-8') as f:
    reader = csv.reader(f)
    header = next(reader)  # Skip old header
    print(f"   Old header: {header}")
    for row in reader:
        if row:  # Skip empty rows
            old_data.append(row)

print(f"   ✓ Read {len(old_data)} data rows")
print()

# New correct fieldnames
new_fieldnames = [
    'timestamp',
    'instance_id', 
    'instance_name',
    'time_of_click',
    'status',
    'voting_url',
    'cooldown_message',
    'failure_type',
    'failure_reason',
    'initial_vote_count',
    'final_vote_count',
    'vote_count_change',
    'proxy_ip',
    'session_id',
    'click_attempts',
    'error_message',
    'browser_closed'
]

# Write new file with correct header
print("3. Writing new file with correct header...")
with open(csv_file, 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(new_fieldnames)
    
    # Write existing data rows (they already have correct format)
    for row in old_data:
        writer.writerow(row)

print(f"   ✓ Wrote {len(old_data)} data rows with new header")
print()

# Verify
print("4. Verifying new file...")
with open(csv_file, 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    print(f"   New header columns: {len(reader.fieldnames)}")
    print(f"   First few columns: {reader.fieldnames[:5]}")
    
    # Read first row to verify
    first_row = next(reader, None)
    if first_row:
        print(f"   ✓ First row status: {first_row.get('status', 'N/A')}")
        print(f"   ✓ First row instance: {first_row.get('instance_name', 'N/A')}")

print()
print("=" * 60)
print("✓ CSV header fixed successfully!")
print("=" * 60)
print()
print(f"Backup saved to: {backup_file}")
print("You can now refresh the Statistics tab to see correct data")
