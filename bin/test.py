import json
import database_utils

# Step 1: Execute the MySQL query
query = "SELECT * FROM wca_stats.SoR_combined;"
cur = database_utils.execute_sql(query)

# Step 2: Initialize an empty list to store the result
result_list = []

# Step 3: Iterate over the result set and add rows to the list
def add_row_to_list(row):
    columns = [desc[0] for desc in cur.description]  # Get column names from the cursor description
    result_list.append(dict(zip(columns, row)))

# You can use cur.fetchone() to fetch one row at a time
row = cur.fetchone()
while row is not None:
    add_row_to_list(row)
    print(row)
    row = cur.fetchone()

# Step 4: Write the list of dictionaries to a JSON file
json_file_path = "output.json"
with open(json_file_path, "w") as json_file:
    json.dump(result_list, json_file, indent=4)

# Closing the cursor and the connection (optional, but recommended)
cur.close()

database_utils.close_connection()
