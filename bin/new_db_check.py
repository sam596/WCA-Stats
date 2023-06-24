import zipfile, re, os
import urllib.request

def parseurl(url):
    file = 'downloads/' + re.search(r"\/([^\/]+)$", url).group(1)
    extractfolder = 'downloads/' + re.search(r"\/([^\/\.]+)(\.sql)?\.zip$", url).group(1)
    return file, extractfolder

def download_db(url):
    file, extractfolder = parseurl(url)
    last_modified_file = file + '.txt'
    
    os.makedirs(os.path.dirname(file), exist_ok=True)
    r = urllib.request.urlopen(url)
    last_modified = r.headers.get('Last-Modified')

    with open(last_modified_file, 'w') as f:
        f.write(last_modified)

    urllib.request.urlretrieve(url, file)

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