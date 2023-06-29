import zipfile, re, os
import urllib.request
import progressbar

pbar = None

def parseurl(url):
    file = 'downloads/' + re.search(r"\/([^\/]+)$", url).group(1)
    extractfolder = 'downloads/' + re.search(r"\/([^\/\.]+)(\.sql)?\.zip$", url).group(1)
    return file, extractfolder

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

def is_newer_file_available(url):
    file = parseurl(url)[0]
    last_modified_file = file + '.txt'

    if os.path.exists(last_modified_file):
        r = urllib.request.urlopen(url)
        last_modified = r.headers.get('Last-Modified')
        with open(last_modified_file, 'r') as f:
            if f.read() == last_modified:
                return False
    
    return True