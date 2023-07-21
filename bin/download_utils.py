import os
import urllib.request
import progressbar
import re
import zipfile
from datetime import datetime

pbar = None

def dl_progress_bar(block_num, block_size, total_size):
    global pbar
    if pbar is None:
        pbar = progressbar.ProgressBar(maxval=total_size)
        pbar.start()

    downloaded = block_num * block_size
    if downloaded < total_size:
        pbar.update(downloaded)
    else:
        pbar.finish()
        pbar = None

def parseurl(url='https://www.worldcubeassociation.org/export/developer/wca-developer-database-dump.zip'):
    file = 'downloads/' + re.search(r"\/([^\/]+)$", url).group(1)
    extractfolder = 'downloads/' + re.search(r"\/([^\/\.]+)(\.sql)?\.zip$", url).group(1)
    return file, extractfolder

def download_db(url):
    file, extractfolder = parseurl(url)
    last_modified_file = file + '.txt'
    
    print(f'Downloading to {file}')
    
    os.makedirs(os.path.dirname(file), exist_ok=True)
    r = urllib.request.urlopen(url)
    last_modified = r.headers.get('Last-Modified')

    with open(last_modified_file, 'w') as f:
        f.write(last_modified)

    urllib.request.urlretrieve(url, file, dl_progress_bar)

    print(f"Extracting {file}")

    with zipfile.ZipFile(file) as zf:
        sql_files = []
        for f in zf.namelist():
            if f.endswith('.sql'):
                sql_files.append(f)
        zf.extractall(extractfolder, members=sql_files)

def get_last_modified(last_modified_file):
    with open(last_modified_file, 'r') as f:
        return f.read()

def is_newer_file_available(url):
    file = parseurl(url)[0]
    last_modified_file = file + '.txt'

    if os.path.exists(last_modified_file):
        r = urllib.request.urlopen(url)
        last_modified = r.headers.get('Last-Modified')
        last_modified_time = datetime.strptime(last_modified, '%a, %d %b %Y %H:%M:%S %Z')
        if get_last_modified(last_modified_file) == last_modified:
            return False, last_modified_time
    
    return True, last_modified_time

def check_for_new_version(db_name, url, force_update):
    if force_update:
        print(f'Update of {db_name} forced by user.')
    else:
        print(f'Checking {db_name} database for new version')
        is_new, last_modified = is_newer_file_available(url)
        if not is_new:
            print(f'No newer version available. {db_name} is up-to-date! Last modified: {last_modified}')
            return False
        else:
            print(f'New {db_name} database dump found! Last modified: {last_modified}')
    return True

def download_and_extract_db(file, extractfolder, url, db_name):
    download_db(url)
    print(f'Ready to import ' + db_name)