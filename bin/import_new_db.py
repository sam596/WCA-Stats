import os
from tqdm import tqdm
from mysql.connector import Error
import argparse

from new_db_check import is_newer_file_available, download_db, parseurl
import db_init, connection

cur, conn = connection.get_connection()

databases = [
    {'db_name': 'wca', 'url': 'https://www.worldcubeassociation.org/export/results/WCA_export.sql.zip'},
    {'db_name': 'wca_dev', 'url': 'https://www.worldcubeassociation.org/export/developer/wca-developer-database-dump.zip'}
]


def execute_sql(sql, multi=True):
    try:
        cur.execute(sql)
    except Error as err:
        # Handle the specific error that occurred
        if err.errno == 2013:  # MySQL error code for lost connection
            # Reconnect to the MySQL server and retry the query
            print('Lost connection. Reconnecting...')
            cur.reconnect(attempts=3, delay=2)
            execute_sql(sql)  # Retry the query
        else:
            # Handle other types of errors
            print(f"Error occurred: {err}")
    except Exception as e:
        # Handle any other exceptions that may occur
        print(f'Exception occurred: {e}')
        return cur


def is_end_of_query(line):
    return line.strip().endswith(';')

def check_for_new_version(db_name, url, force_update):
    if force_update:
        print(f'Update of {db_name} forced by user.')
    else:
        print(f'Checking {db_name} database for new version')
        if not is_newer_file_available(url):
            print(f'No newer version available. {db_name} is up-to-date!')
            return False
        else:
            print(f'New {db_name} database dump found!')
    return True


def download_and_extract_db(file, extractfolder, url, db_name):
    download_db(url)
    print(f'Ready to import ' + db_name)


def import_database(db_name, extractfile):
    cur.execute("USE " + db_name)

    conn.start_transaction()

    with open(extractfile, 'r', encoding='utf8', errors='ignore') as f:
        query = ""
        progress_bar = None
        line_count = 0
        section_ends = []
        for line in f:
            line_count += 1
            if line.startswith('-- Dumping') or line.startswith('-- Table structure'):
                section_ends.append(line_count)
        section_ends.append(line_count)
        line_count = 0
        f.seek(0)
        rows = None
        for line in f:
            line_count += 1
            line = line.strip()

            if line.startswith('--'):
                if line_count in section_ends:
                    if progress_bar:
                        progress_bar.close()
                        progress_bar = None
                if line.startswith('-- Dumping'):
                    print(line.replace('-- Dumping', 'Importing'))
                elif line.startswith('-- Table structure'):
                    print(line.replace('-- Table structure for ', 'Initialising '))
                if line_count in section_ends:
                    index = section_ends.index(line_count)
                    try:
                        rows = section_ends[index + 1] - section_ends[index]
                        progress_bar = tqdm(total=rows, unit='queries')
                    except IndexError:
                        progress_bar = None
                        pass

                if progress_bar:
                    progress_bar.update(1)
                continue

            if line:
                query += line
                if is_end_of_query(line):
                    execute_sql(query)
                    query = ""

            if progress_bar:
                progress_bar.update(1)

    conn.commit()


def parse_arguments():
    parser = argparse.ArgumentParser(description='Import WCA Databases into MySQL.')
    parser.add_argument('--skip-download', action='store_true', help='Force update of databases')
    parser.add_argument('--force-update', action='store_true', help='Force update of databases')
    parser.add_argument('--force-download', action='store_true', help='Skip the download step')
    parser.add_argument('--public-only', action='store_true', help='Only download/update the Public WCA Export')
    parser.add_argument('--developer-only', action='store_true', help='Only download/update the Developer WCA Export')
    parser.add_argument('--update-stats', action='store_true', help='Update the statistics database after import.')

    return parser.parse_args()


def process_databases(force_update, force_download, skip_download, public_only, developer_only):
    global databases
    if developer_only and public_only:
        raise argparse.ArgumentTypeError(
            "You can only use ONE of the --public-only and --developer-only flags! I can't do both!")

    if developer_only:
        databases = [x for x in databases if x['db_name'] == 'wca_dev']

    if public_only:
        databases = [x for x in databases if x['db_name'] == 'wca']

    for db in databases:
        db_name = db['db_name']
        url = db['url']
        file, extractfolder = parseurl(url)
        extractfile = os.path.join(extractfolder, os.listdir(extractfolder)[0])

        db_updated = check_for_new_version(db_name, url, force_update)

        if db_updated:
            pass
        elif force_download:
            pass
        else:
            continue

        if skip_download:
            print(f"Download of {db_name} skipped by user. Using existing {db_name} download.")
            pass
        else:
            if force_download:
                print(f"Download of {db_name} forced by user.")
            download_and_extract_db(file, extractfolder, url, db_name)

        import_database(db_name, extractfile)

    cur.close()
    conn.close()


if __name__ == '__main__':
    from datetime import datetime
    start = datetime.now()
    start_time = start.strftime("%H:%M:%S")
    
    args = parse_arguments()
    force_update = args.force_update
    force_download = args.force_download
    skip_download = args.skip_download
    update_stats = args.update_stats

    if update_stats:
        print("I will update the statistics database after importing the new databases.")

    process_databases(force_update, force_download, skip_download, args.public_only, args.developer_only)

    if update_stats:
        import parse_tables
        import gh_pages

    end = datetime.now()
    end_time = end.strftime("%H:%M:%S")
    duration = (end - start)

    print("Started Import at ", start_time)
    print("Completed Import at ", end_time)
    print("Duration: ", duration)