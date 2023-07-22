import connection

cur, conn = connection.get_connection()

def database_exists(db):
    cur.execute("SHOW DATABASES")
    database_list = [x[0] for x in cur.fetchall()]
    
    if db in database_list:
        return True
    else:
        return False

def create_db_if_not_exist(db):
    if not database_exists(db):
        query = 'CREATE DATABASE ' + db + ' CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;'

        cur.execute(query)

def table_exists(table, db):
    cur.execute('USE ' + db)
    cur.execute('SHOW TABLES')
    table_list = [x[0] for x in cur.fetchall()]

    if table in table_list:
        return True
    else:
        return False

def db_init():
    databases = ['wca','wca_dev','wca_stats']

    for db in databases:
        create_db_if_not_exist(db)

    if not table_exists('last_updated', 'wca_stats'):
        query = """CREATE TABLE `wca_stats`.`last_updated` (
            `query` varchar(20) NOT NULL,
            `started` datetime DEFAULT NULL,
            `completed` datetime DEFAULT NULL,
            `notes` TEXT DEFAULT NULL,
            PRIMARY KEY (query));"""
        cur.execute(query)

    print('Database Initialised')