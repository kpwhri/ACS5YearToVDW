# Introduction
This package uses the Census API to _extract_ tract level demographics, _load_ them into Teradata, and _transform_ the data as they exist in Teradata.

## EXTRACT_ACS.py
Several list comprehensions to create lists of variables. The API requires lists to be limited to < 50 variables. Decided that I'd chunk it into concept variables and separate estimates from margin of error values.

*get_state_list* - checks the distinct states from 2018. Pops them into a list
*generate_varlist* - Takes a base table, a maximum variable number, and (E)stimate or (M)argin of Error parameters.
*get_tract_demog* - Uses standard Census API call. For each state in the state list, look at every year between the start and stop dates, pull the variables from the list of variable. If debug isn't 0, then print the JSON response text.

Each of the *get_tract_demog* calls generates a dataframe. Later we make a list of dataframes in the census_mashup variable. We enumerate the list. If it is the first list, we keep the "NAME" (human readable State, county, and tract identifier).

Export the dataframe to a CSV.

## LOAD_ACS.sas
Take the CSV from the extraction, convert a few variables that look like they are numeric to character and zero pad to the appropriate length. 

Load to teradata with a primary index of geocode and census_year.

## TRANSFORM_ACS.sas

Perform transformations on the raw data loaded to meet VDW specifications.

~Fin