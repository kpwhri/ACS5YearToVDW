/*********************************************
* Alphonse Derus
* Kaiser Permanente Washington Research Institute
* (206) 287-2905
* alphonse.derus@kp.org
*
* 
*
* The purpose of this file is to load ACS to Teradata.
*********************************************/

%let csv_file = //ghcmaster/ghri/Warehouse/management/Workspace/deruaj1/census_acs_5yr_dev/data/census_demog.csv;
 
proc import datafile = "&csv_file." 
    out = work.acs_demog_raw
    dbms = csv 
    ;
    getnames = yes ;
    
run;
proc contents data=work.acs_demog_raw order=varnum;
run;

data work.acs_demog;
    set work.acs_demog_raw (rename=(state=state_raw county=county_raw tract=tract_raw geocode=geocode_raw));
    geocode = put(geocode_raw,z11.);
    state = put(state_raw,z2.);
    county = put(county_raw,z3.);
    tract = put(tract_raw,z6.); 
    census_year=year;
    drop geocode_raw state_raw county_raw tract_raw year;
run;

libname td teradata &td_goo ;

%macro acs_to_teradata(runmode);
    %IF &RUNMODE. = dev %THEN %DO;
      %put acs_to_teradata runmode = &RUNMODE.;
      %IF %EXIST(td.acs_demog) %THEN %DO;
        %put NOTE: old table dropped;
        proc sql;
          drop table td.acs_demog;
        quit;
      %END;


      data td.acs_demog (dbcreate_table_opts='primary index (geocode,census_year)');
          set work.acs_demog;
      run;
    %END;
%mend acs_to_teradata;

%acs_to_teradata(dev);