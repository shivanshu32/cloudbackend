"""
Fix voting_logs.csv format - migrate from old to new format
"""
import os
import csv

old_csv = 'voting_logs.csv'
backup_csv = 'voting_logs_backup.csv'

# Check if old CSV exists
if os.path.exists(old_csv):
    print(f"Found {old_csv}")
    
    # Read the first line to check format
    with open(old_csv, 'r', encoding='utf-8') as f:
        first_line = f.readline().strip()
        print(f"Current header: {first_line}")
    
    # Check if it's the old format
    if first_line == 'timestamp,instance_id,ip,status,message,vote_count':
        print("Old format detected!")
        
        # Backup the old file
        if os.path.exists(backup_csv):
            os.remove(backup_csv)
        os.rename(old_csv, backup_csv)
        print(f"Backed up to {backup_csv}")
        
        # Create new file with correct format
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
        
        with open(old_csv, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=new_fieldnames)
            writer.writeheader()
        
        print(f"Created new {old_csv} with correct format")
        print("New format is ready for use!")
    else:
        print("CSV already has new format or is empty")
else:
    print(f"{old_csv} not found")
