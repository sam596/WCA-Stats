import mysql.connector

def get_connection():
    conn = mysql.connector.connect(
        option_files='bin/.connectors.cnf',
        connect_timeout=3600
    )
    cur = conn.cursor()
    return cur, conn

if __name__ == '__main__':
    get_connection()