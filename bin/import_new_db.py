import os
import argparse
from datetime import datetime
import download_utils, database_utils, wca_stats_update

wca_dev_succeeded = False

databases = [
    {'db_name': 'wca', 'url': 'https://www.worldcubeassociation.org/export/results/WCA_export.sql.zip'},
    {'db_name': 'wca_dev', 'url': 'https://www.worldcubeassociation.org/export/developer/wca-developer-database-dump.zip'}
]

def parse_arguments():
    parser = argparse.ArgumentParser(description='Import WCA Databases into MySQL.')
    parser.add_argument('--skip-download', action='store_true', help='Force update of databases')
    parser.add_argument('--force-update', action='store_true', help='Force update of databases')
    parser.add_argument('--force-download', action='store_true', help='Skip the download step')
    parser.add_argument('--public-only', action='store_true', help='Only download/update the Public WCA Export')
    parser.add_argument('--developer-only', action='store_true', help='Only download/update the Developer WCA Export')
    parser.add_argument('--force-update-stats', action='store_true', help='Force update the statistics database after import.')
    parser.add_argument('--skip-stats', action='store_true', help='Skip updating the statistics database after import.')

    return parser.parse_args()

def process_single_database(db, force_update, force_download, skip_download):
    db_name = db['db_name']
    url = db['url']
    file, extractfolder = download_utils.parseurl(url)
    extractfile = os.path.join(extractfolder, os.listdir(extractfolder)[0])

    db_updated = download_utils.check_for_new_version(db_name, url, force_update)

    if not db_updated and not force_download:
        return
    
    if skip_download:
        print(f"Download of {db_name} skipped by user. Using existing {db_name} download.")
    else:
        if force_download:
            print(f"Download of {db_name} forced by user.")
        download_utils.download_and_extract_db(file, extractfolder, url, db_name)
    
    if db_name == 'wca_dev':
        global wca_dev_succeeded
        try:
            database_utils.import_database(db_name, extractfile)
            wca_dev_succeeded = True
        except:
            wca_dev_succeeded = False
    else:
        database_utils.import_database(db_name, extractfile)


def process_databases(force_update, force_download, skip_download, public_only, developer_only):
    global databases
    if developer_only and public_only:
        raise argparse.ArgumentTypeError(
            "You can only use ONE of the --public-only and --developer-only flags! I can't do both!")
    
    if skip_download and force_download:
        raise argparse.ArgumentTypeError(
            "You can only use ONE of the --skip-download and --force-download flags! I can't do both!")

    if developer_only:
        databases = [x for x in databases if x['db_name'] == 'wca_dev']

    if public_only:
        databases = [x for x in databases if x['db_name'] == 'wca']

    for db in databases:
        process_single_database(db, force_update, force_download, skip_download)

    database_utils.close_connection()


if __name__ == '__main__':
    from datetime import datetime
    start = datetime.now()
    start_time = start.strftime("%H:%M:%S")
    
    args = parse_arguments()
    force_update = args.force_update
    force_download = args.force_download
    skip_download = args.skip_download
    force_update_stats = args.force_update_stats
    skip_stats = args.skip_stats

    try:
        process_databases(force_update, force_download, skip_download, args.public_only, args.developer_only)
        if (force_update_stats or wca_dev_succeeded) and not skip_stats:
            wca_stats_update.update_stats()
            import gh_pages
    except KeyboardInterrupt:
        print("Keyboard interrupt detected. Closing connection and exiting...")
        database_utils.close_connection()
        print("Database connection closed. Exiting the script.")

    end = datetime.now()
    end_time = end.strftime("%H:%M:%S.%f")
    duration = str(end - start)

    print("Started Import at ", start_time)
    print("Completed Import at ", end_time)
    print("Duration: ", duration)