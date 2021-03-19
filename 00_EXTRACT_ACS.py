# Imports
import requests
import pandas as pd
import censusdata as cnd
# Census API stuff
apikey = 'YOURAPIKEYGOESHERE'

## Get all state codes
def get_state_list(year):
    
    HOST = 'https://api.census.gov/data' 
    year = f'{year}'
    dataset = 'acs/acs5'
    get_vars = ['NAME']
    predicates = {}
    predicates['get'] = ','.join(get_vars)
    predicates['for'] = 'state:*'
    base_url = "/".join([HOST, year, dataset])
    r = requests.get(base_url, params=predicates)
    global state_list
    state_list = []
    state_json = r.json()[1:]
    for state in state_json:
        state_list.append(state[1])
    states = pd.DataFrame(columns=r.json()[0], data = r.json()[1:])

get_state_list(year=2018) #states don't change enough. 
print(state_list)

# cnd.printtable(cnd.censustable('acs5',2009,'B15002'))
cnd.printtable(cnd.censustable('acs5',2009,'B19113'))
# inc_search = cnd.search('acs5',2009,'label','Median Family Income')

## Education variables
'''List comprehensions seem scary at first.
    In general, a function is defined that will only be used in the context of this operation.
    We're creating this list to pull up the list of estimates from a given base table and add them to a list.
    We do the same thing for Margin of Error Estimates (at 90% CI).
    We'll later call on these variables in the API call.

'''
def generate_varlist(base_table,maxvar,e_or_m):
    output_list = [(lambda x: base_table + '_' + str(x + 1).zfill(3) + f'{e_or_m}')(x) for x in range(maxvar)]
    return output_list
# # https://api.census.gov/data/2009/acs/acs5/groups/B15002.html
education_est = generate_varlist('B15002',35,'E')
education_moe = generate_varlist('B15002',35,'M')
# base_table = 'B15002'
print(education_est)
print(education_moe)

# # https://api.census.gov/data/2009/acs/acs5/groups/B19113.html
fam_inc_median = ['B19113_001E', 'B19113_001M']

# # https://api.census.gov/data/2009/acs/acs5/groups/B19101.html
# base_table = 'B19101'
fam_inc_est = generate_varlist('B19101',17,'E')
fam_inc_moe = generate_varlist('B19101',17,'M')
print(fam_inc_moe)

# https://api.census.gov/data/2009/acs/acs5/groups/B19013.html
hh_inc_median = ['B19013_001E','B19013_001M']

# https://api.census.gov/data/2009/acs/acs5/groups/B19001.html
hh_inc_est = generate_varlist('B19001',17,'E')
hh_inc_moe = generate_varlist('B19001',17,'M')

# https://api.census.gov/data/2010/acs/acs5/groups/B17026.html
### NOTE: Does not come into play until 2010
pov_est = generate_varlist('B17026',17,'E')
pov_moe = generate_varlist('B17026',17,'M')

# English vs. Spanish Speaker
# "B16007003 
# B16007009 
# B16007015"	B16007001 is total number as denominator for speaker variables
# "B16007004 
# B16007010 
# B16007016"	B16007001 is total number as denominator for speaker variables

# BORNINUS - Born in US
# B05001002	B05001001 is total number as denominator for borninUS variable

# MOVEDINLAST12MON - Moved in the last 12 months
# 1-(B07001017/B07001001)

def get_tract_demog(year_start,year_end,var_list,debug=0):
    HOST = 'https://api.census.gov/data'
    dataset = 'acs/acs5'
    dfs = []
    for state in state_list:
        get_vars = []
        for var in var_list:
            get_vars.append(var)
        get_vars = ['NAME'] + get_vars
        predicates = {}
        predicates['get'] = ','.join(get_vars)
        predicates['for'] = 'tract:*'
        predicates['in'] = f'state:{state}'
        predicates['key'] = apikey;
        

        for year in range(year_start,year_end+1):
            base_url = '/'.join([HOST, str(year), dataset])
            r = requests.get(base_url, params = predicates)
            if debug != 0:
                print(r.text)
            df = pd.DataFrame(columns=r.json()[0], data = r.json()[1:])
            df['year'] = year
            dfs.append(df)
    _ = pd.concat(dfs)
    for var in var_list:
        _[var] = _[var].astype(float)
    return _

# Use the function from above for the groups of variables defined in the previous cell

# Education
edu_est_df = get_tract_demog(year_start=2010, year_end=2018,var_list=education_est)
edu_moe_df = get_tract_demog(year_start=2010, year_end=2018,var_list=education_moe)

# Family Income
fam_inc_median_df = get_tract_demog(year_start=2010, year_end=2018,var_list=fam_inc_median)
fam_inc_est_df = get_tract_demog(year_start=2010, year_end=2018,var_list=fam_inc_est)
fam_inc_moe_df = get_tract_demog(year_start=2010, year_end=2018,var_list=fam_inc_moe)

# Household Income
hh_inc_median_df = get_tract_demog(year_start=2010, year_end=2018,var_list=hh_inc_median)
hh_inc_est_df = get_tract_demog(year_start=2010, year_end=2018,var_list=hh_inc_est)
hh_inc_moe_df = get_tract_demog(year_start=2010, year_end=2018,var_list=hh_inc_moe)
# Make a list of df. Join on year, state, county, and tract

census_mashup = [edu_est_df, edu_moe_df, 
                 fam_inc_median_df, 
                 fam_inc_est_df, fam_inc_moe_df, 
                 hh_inc_median_df, 
                 hh_inc_est_df, hh_inc_moe_df,
                ]
# If it is the first df, include "NAME", otherwise join and drop "NAME"
for idx,concept in enumerate(census_mashup):
    if idx == 0:
        census_mashup_df = concept
        print(idx)
        print(type(census_mashup_df))
    else:
        print(idx)
        census_mashup_df = pd.merge(census_mashup_df, concept.drop(['NAME'], axis=1), on=['year','state','county','tract'],suffixes = [None,None])

census_mashup_df['GEOCODE']= census_mashup_df['state'] \
    + census_mashup_df['county'] \
    + census_mashup_df['tract']


file_loc = '//ghcmaster/ghri/Warehouse/management/Workspace/deruaj1/census_demog_dev/data/census_demog.csv'
census_mashup_df.to_csv(file_loc,index=False)