import mysql.connector
import os

connector_blank = """[client]
host=
user=
password="""

def create_connectors():
    with open('bin/.connectors.cnf','w') as f:
            f.write(connector_blank)

def get_connection():
    if (os.path.exists('bin/.connectors.cnf') == False):
        create_connectors()
        raise Exception("No .connectors.cnf found! I've created an empty one.")
    
    with open('bin/.connectors.cnf','r') as f:
        connectors = f.read()
        if connectors == connector_blank:
            raise Exception("Your .connectors.cnf file is blank. Please add variables to it.")

    conn = mysql.connector.connect(
        option_files='bin/.connectors.cnf',
        connect_timeout=3600
    )
    cur = conn.cursor()
    return cur, conn

if __name__ == '__main__':
    get_connection()