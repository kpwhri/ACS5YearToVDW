/*********************************************
* Alphonse Derus
* Kaiser Permanente Washington Research Institute
* (206) 287-2905
* alphonse.derus@kp.org
*
* 
*
* The purpose of this file is to create a macro that picks the right demog year.
*********************************************/

 * Census location - &_vdw_census_loc -- just like enrollment;
%macro get_census_demog(
                        input_ds = &_vdw_census_loc. (obs=100) /*YOUR data*/
                        , idvar = mrn /*Have it in your dataset; Don't touch*/
                        , geocode_var = geocode /*Have it in your dataset; Don't touch*/
                        , index_date = today() /*You should change this; needs to be a DATE*/
                        , years_prior_tolerance = 5 /*Recommended settings*/
                        , years_after_tolerance = 3 /*Recommended settings*/
                        , demog_data_src = &_vdw_census_demog. /*switch to new file*/
                        , demog_geo_var = geocode
                        , census_yr_var = census_year
                        , outds = work.outds /*Where do you want it to go? */
                        ) ;
    proc sql;
        create table work.census_years_temp_ as 
        select distinct
            &census_yr_var. as census_year
            , &census_yr_var. - &years_prior_tolerance. as census_year_lowest
            , &census_yr_var. + &years_after_tolerance. as census_year_highest
        from &demog_data_src
        ;
    quit;

    proc sql;
        create table work.census_select_temp_ as 
        select
            ids.&idvar.
            , substr(ids.&geocode_var.,1,11) as geocode
            , year(&index_date.) as index_year
            , &index_date as index_date
            , tol.census_year
            , tol.census_year_lowest
            , tol.census_year_highest
            , case 
                when length(ids.&geocode_var.) < 11 then 'WARNING: No tract level match'
                when length(ids.&geocode_var.) > 11 then 'OK: Note, only tract returned'
                when length(ids.&geocode_var.) = 11 then 'OK: Exact'
                end as match_flag
            , case when missing(tol.census_year) then 'Out of range' else put(tol.census_year,4.) end as year_select
        from &input_ds ids
        left join work.census_years_temp_ tol on
            year(&index_date.) = tol.census_year
            or 
            (year(&index_date.) < tol.census_year
                and year(&index_date.)>= tol.census_year_lowest)
            or 
            (year(&index_date.) > tol.census_year
                and year(&index_date.) <= tol.census_year_highest)
        group by ids.&idvar.
        having abs(year(&index_date)-tol.census_year) = min(abs(year(&index_date)-tol.census_year));
        ;
        create table &outds. as
        select 
            cst.&idvar
            , cst.index_year
            , cst.index_date format = yymmdd10.
            , cst.census_year_lowest
            , cst.census_year_highest 
            , cst.match_flag
            , cst.year_select 
            , dds.*
        from work.census_select_temp_ cst 
        left join &demog_data_src dds on 
            dds.&demog_geo_var = cst.geocode
            and cst.census_year = dds.census_year
        ;
    quit;

%mend get_census_demog ;


** Test the macro;
* old demog;
%get_census_demog(input_ds = &_vdw_census_loc. (obs=100)
                , geocode_var=geocode
                , index_date = today()
                , years_prior_tolerance = 5
                , years_after_tolerance = 3
                , demog_data_src = &_vdw_census_demog.
                , census_yr_var = census_year
                ) ;

%let acs5yr = td.acs_demog_v;
* new demog;
%get_census_demog(input_ds = &_vdw_census_loc. (obs=100)
                , geocode_var=geocode
                , index_date = today()
                , years_prior_tolerance = 5
                , years_after_tolerance = 3
                , demog_data_src = &acs5yr.
                , census_yr_var = census_year
                ) ;