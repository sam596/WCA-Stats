import time

tables = [
    'results_extra',
    'podium_sums',
    'final_missers',
    'all_attempts',
    'average_sor',
    'single_sor',
    'all_ranks_and_sor',
    'records',
    'kinch'
    #'uowc',
    #'records',
    #'championship_podiums',
    #'concise_results',
    #'prs',
    #'pr_streak',
    #'mbld_decoded',
    #'relays',
    #'registrations_extra',
    #'persons_extra',
    #'competitions_extra',
    #'person_comps_extra',
    #'seasons',
    #'current_averages',
    #'world_rank_history'
]

from import_new_db import is_end_of_query, execute_sql, cur, conn

db_name = 'wca_stats'
cur.execute("USE " + db_name)
conn.start_transaction()
for table in tables:
    start = time.time()
    table_path = 'tables/' + table + '.sql'
    with open(table_path, 'r') as f:
        query = ""
        query_list = []
        for line in f:
            if line and not line.startswith('-- '):
                query += line
                if is_end_of_query(line):
                    query_list.append(query)
                    query = ""
        for x in query_list:
            x = ' '.join(x.split())
            try:
                print(x[:64] + "...")
            except KeyError:
                print(x)
            execute_sql(x, False)
    end = time.time()
    total_time = end - start
    print("\n" + str(total_time))

conn.commit()