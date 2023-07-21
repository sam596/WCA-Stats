import time
import database_utils

tables = [
    'results_extra', #~14mins
    'podium_sums',
    'final_missers',
    'all_attempts',
    'average_sor',
    'single_sor',
    'all_ranks_and_sor', #~18 mins
    'records', #~15secs
    'kinch', #~5 mins
    'uowc', #~12 mins
    'uoukc', #~20 secs
    'championship_podiums', #~2 mins
    'concise_results', #~40 mins
    'prs', #~15mins
    'pr_streak', #~5mins
    'mbld_decoded', #8min
    'relays', #2min
    'registrations_extra', #2min
    'persons_extra', 
    #'competitions_extra', 
    #'person_comps_extra', 
    #'seasons', 
    #'current_averages', 
    #'world_rank_history' 
]

def convertsecs(seconds):
    seconds = seconds % (24 * 3600)
    hour = seconds // 3600
    seconds %= 3600
    minutes = seconds // 60
    seconds %= 60
     
    return "%d:%02d:%02d" % (hour, minutes, seconds)

def import_table(table_path):
    with open(table_path, 'r') as f:
        query = ""
        query_list = []
        for line in f:
            if line and not line.startswith('-- '):
                query += line
                if database_utils.is_end_of_query(line):
                    query_list.append(query)
                    query = ""
        for x in query_list:
            x = ' '.join(x.split())
            if len(x) <= 128:
                print(x)
            else:
                print(x[:125] + "...")
            startquery = time.time()
            database_utils.execute_sql(x, False)
            endquery = time.time()
            totalquerytime = endquery-startquery
            print(str(convertsecs(totalquerytime)))

def iterate_tables(table):
    start = time.time()
    table_path = 'tables/' + table + '.sql'
    import_table(table_path)
    end = time.time()
    total_time = end - start
    print("\n" + str(convertsecs(total_time)))

def update_stats(singletable=None):
    db_name = 'wca_stats'
    database_utils.execute_sql("USE " + db_name)
    database_utils.start_transaction()
    if singletable == None:    
        for table in tables:
            iterate_tables(table)
    elif type(singletable) == list:
        for table in singletable:
            iterate_tables(table)
    else:
        iterate_tables(singletable)
    database_utils.commit()

update_stats('records')