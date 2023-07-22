from datetime import datetime
from mysql.connector import Error
from tqdm import tqdm
import os
import connection, db_init

cur, conn = connection.get_connection()

def start_transaction():
    conn.start_transaction()

def commit():
    conn.commit()

def execute_sql(sql, multi=True):
    try:
        cur.execute(sql)
        return cur
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

def close_connection():
    cur.close()
    conn.close()