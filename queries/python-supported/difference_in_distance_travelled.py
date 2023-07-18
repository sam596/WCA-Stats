import sys, os, csv
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','..','bin'))

import db_init, connection
import pandas as pd
from import_new_db import cur, conn

competition_competitors_query = """
    SELECT DISTINCT personId, personCountryId, c.iso2 personCountryIso, competitionId, compCountryId, compLatitude/1000000 compLatitude, compLongitude/1000000 compLongitude
    FROM wca_stats.results_extra r JOIN wca_dev.countries c ON r.personCountryId = c.id WHERE personCountryId <> compCountryId
"""

df1 = pd.read_sql(competition_competitors_query,conn)
conn.close()
import geopandas as gpd
from shapely.geometry import Point
url = "https://cdn.jsdelivr.net/gh/gavinr/world-countries-centroids@v1/dist/countries.geojson"
gdf = gpd.read_file(url)
df2 = pd.DataFrame(gdf)

df2 = df2._append(
    pd.DataFrame({
        'COUNTRY': ['Chinese Taipei'],
        'ISO': ['TW'],
        'COUNTRYAFF': ['Taiwan'],
        'AFF_ISO': ['TW'],
        'geometry': [Point(-121.02904, 23.79035)]
    })
)
df2 = df2._append(
    pd.DataFrame({
        'COUNTRY': ['Hong Kong, China'],
        'ISO': ['HK'],
        'COUNTRYAFF': ['China'],
        'AFF_ISO': ['CN'],
        'geometry': [Point(114.2, 22.3)]
    })
)
df2 = df2._append(
    pd.DataFrame({
        'COUNTRY': ['Macau, China'],
        'ISO': ['MO'],
        'COUNTRYAFF': ['China'],
        'AFF_ISO': ['CN'],
        'geometry': [Point(113.55, 22.166667)]
    })
)  
df = pd.merge(df1,df2, left_on='personCountryIso', right_on='ISO')
pd.set_option('display.max_columns', None)
from geopy.distance import distance
from tqdm import tqdm
progress_bar = tqdm(total=len(df), desc="Calculating distances")
def calculate_distance(row):
    point = row['geometry']
    lat = row['compLatitude']
    lon = row['compLongitude']
    point_coords = (point.y, point.x)
    target_coords = (lat, lon)
    progress_bar.update(1)
    return distance(point_coords, target_coords).meters

df['distance'] = df.apply(calculate_distance, axis=1)
progress_bar.close()

# Assuming you have a DataFrame named df with columns 'competitionId', 'personId', and 'distance'

# Group the DataFrame by 'competitionId'
grouped_df = df.groupby('competitionId')

# Create an empty DataFrame to store the results
result_df = pd.DataFrame(columns=['competitionId', 'compCountryId', 'personId1', 'personId2', 'personCountryId1', 'personCountryId2', 'distance1', 'distance2', 'difference'])

# Iterate over each group
for group_name, group_data in grouped_df:
    # Sort the group by 'distance' in descending order
    sorted_group = group_data.sort_values('distance', ascending=False)
    
    # Get the top two rows with the greatest 'distance' values
    top_two = sorted_group.head(2)
    
    # Calculate the difference between the two distances
    try:
        difference = abs(top_two['distance'].diff().iloc[1])
    except IndexError as e:
        print(f"Failed for {sorted_group['competitionId']}")
        continue
    
    # Assign values to personId1, personId2, distance1, distance2, and difference
    personId1 = top_two.iloc[0]['personId']
    personId2 = top_two.iloc[1]['personId']
    distance1 = top_two.iloc[0]['distance']
    distance2 = top_two.iloc[1]['distance']
    country1 = top_two.iloc[0]['personCountryId']
    country2 = top_two.iloc[1]['personCountryId']
    compCountryId = top_two.iloc[0]['compCountryId']
    
    # Add the top two rows and the difference to the result DataFrame
    result_df = pd.concat([result_df, pd.DataFrame({
        'competitionId': [group_name],
        'compCountryId': [compCountryId],
        'personId1': [personId1],
        'personId2': [personId2],
        'personCountryId1': [country1],
        'personCountryId2': [country2],
        'distance1': [distance1],
        'distance2': [distance2],
        'difference': [difference]
    })], ignore_index=True)

# Sort the result DataFrame by the largest difference
result_df = result_df.sort_values('difference', ascending=False)

# Reset the index of the result DataFrame
result_df = result_df.reset_index(drop=True)

result_df['distance1'] = result_df['distance1'].map('{:.2f}'.format)
result_df['distance2'] = result_df['distance2'].map('{:.2f}'.format)
result_df['difference'] = result_df['difference'].map('{:.2f}'.format)

# Print the result DataFrame
print(result_df)

result_df.to_csv('tmp/difference_in_distance_travelled.csv', encoding='utf-8')