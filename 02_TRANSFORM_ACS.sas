/*********************************************
* Alphonse Derus
* Kaiser Permanente Washington Research Institute
* (206) 287-2905
* alphonse.derus@kp.org
*
* 
*
* The purpose of this file is to execute teradata sql to reshape existing tables into a new view. 
*********************************************/
%include "\\home.ghc.org\home$\deruaj1\remoteactivate.sas";

******************************************************************************************;
* Setup block                                                                         ;
******************************************************************************************;

%macro create_or_replace_td_view();
    %if %exist(td.acs_demog_v) %then %do;
        %put INFO: View exists!;
            proc sql;
            connect to teradata as td (&td_goo) ;
            execute (replace view &schema_sel..acs_demog_v as 
                select 
                    ad.geocode
                    , ad.census_year
                    , ad.state
                    , ad.county
                    , ad.tract
                    , ad.name as geo_name
                    , case when B15002_001E > 0 then 
                            (B15002_003E + B15002_004E + B15002_005E + B15002_006E 
                                + B15002_020E + B15002_021E + B15002_022E + B15002_023E) / B15002_001E
                        end as EDUCATION1
                    ,  case when B15002_001E > 0 then 
                            (B15002_007E + B15002_008E + B15002_009E + B15002_010E + 
                            B15002_024E + B15002_025E + B15002_026E + B15002_027E) / B15002_001E
                        end as EDUCATION2
                    , case when B15002_001E > 0 then 
                            (B15002_011E + B15002_028E) / B15002_001E
                        end as EDUCATION3
                    , case when B15002_001E > 0 then 
                            (B15002_012E + B15002_013E + B15002_029E + B15002_030E) / B15002_001E
                        end as EDUCATION4
                     , case when B15002_001E > 0 then 
                            (B15002_014E + B15002_031E) / B15002_001E
                        end as EDUCATION5 
                    , case when B15002_001E > 0 then 
                            (B15002_015E + B15002_032E) / B15002_001E
                        end as EDUCATION6
                    , case when B15002_001E > 0 then 
                            (B15002_016E + B15002_017E + B15002_033E + B15002_034E) / B15002_001E
                        end as EDUCATION7
                    , case when B15002_001E > 0 then 
                            (B15002_018E + B15002_035E) / B15002_001E
                        end as EDUCATION8
                    , ad.B19113_001E as MEDFAMINCOME
                    , ad.B19113_001M as kpwa_MEDFAMINCOME_MOE
                    , case when ad.B19101_001E = 0 then 'Y' else 'N' end as FAMINCOME_NO_PPL
                    , case when ad.B19101_001E > 0 then ad.B19101_002E /  ad.B19101_001E end as FAMINCOME1
                    , case when ad.B19101_001E > 0 then ad.B19101_003E /  ad.B19101_001E end as FAMINCOME2
                    , case when ad.B19101_001E > 0 then ad.B19101_004E /  ad.B19101_001E end as FAMINCOME3
                    , case when ad.B19101_001E > 0 then ad.B19101_005E /  ad.B19101_001E end as FAMINCOME4
                    , case when ad.B19101_001E > 0 then ad.B19101_006E /  ad.B19101_001E end as FAMINCOME5
                    , case when ad.B19101_001E > 0 then ad.B19101_007E /  ad.B19101_001E end as FAMINCOME6
                    , case when ad.B19101_001E > 0 then ad.B19101_008E /  ad.B19101_001E end as FAMINCOME7
                    , case when ad.B19101_001E > 0 then ad.B19101_009E /  ad.B19101_001E end as FAMINCOME8
                    , case when ad.B19101_001E > 0 then ad.B19101_010E /  ad.B19101_001E end as FAMINCOME9
                    , case when ad.B19101_001E > 0 then ad.B19101_011E /  ad.B19101_001E end as FAMINCOME10
                    , case when ad.B19101_001E > 0 then ad.B19101_012E /  ad.B19101_001E end as FAMINCOME11
                    , case when ad.B19101_001E > 0 then ad.B19101_013E /  ad.B19101_001E end as FAMINCOME12
                    , case when ad.B19101_001E > 0 then ad.B19101_014E /  ad.B19101_001E end as FAMINCOME13
                    , case when ad.B19101_001E > 0 then ad.B19101_015E /  ad.B19101_001E end as FAMINCOME14
                    , case when ad.B19101_001E > 0 then ad.B19101_016E /  ad.B19101_001E end as FAMINCOME15
                    , case when ad.B19101_001E > 0 then ad.B19101_017E /  ad.B19101_001E end as FAMINCOME16
                    , ad.B19013_001E as MEDHOUSINCOME
                    , ad.B19013_001M as kpwa_MEDHOUSINCOME_MOE
                    , case when ad.B19001_001E > 0 then ad.B19001_002E / ad.B19001_001E end as HOUSINCOME1
                    , case when ad.B19001_001E > 0 then ad.B19001_003E / ad.B19001_001E end as HOUSINCOME2
                    , case when ad.B19001_001E > 0 then ad.B19001_004E / ad.B19001_001E end as HOUSINCOME3
                    , case when ad.B19001_001E > 0 then ad.B19001_005E / ad.B19001_001E end as HOUSINCOME4
                    , case when ad.B19001_001E > 0 then ad.B19001_006E / ad.B19001_001E end as HOUSINCOME5
                    , case when ad.B19001_001E > 0 then ad.B19001_007E / ad.B19001_001E end as HOUSINCOME6
                    , case when ad.B19001_001E > 0 then ad.B19001_008E / ad.B19001_001E end as HOUSINCOME7
                    , case when ad.B19001_001E > 0 then ad.B19001_009E / ad.B19001_001E end as HOUSINCOME8
                    , case when ad.B19001_001E > 0 then ad.B19001_010E / ad.B19001_001E end as HOUSINCOME9
                    , case when ad.B19001_001E > 0 then ad.B19001_011E / ad.B19001_001E end as HOUSINCOME10
                    , case when ad.B19001_001E > 0 then ad.B19001_012E / ad.B19001_001E end as HOUSINCOME11
                    , case when ad.B19001_001E > 0 then ad.B19001_013E / ad.B19001_001E end as HOUSINCOME12
                    , case when ad.B19001_001E > 0 then ad.B19001_014E / ad.B19001_001E end as HOUSINCOME13
                    , case when ad.B19001_001E > 0 then ad.B19001_015E / ad.B19001_001E end as HOUSINCOME14
                    , case when ad.B19001_001E > 0 then ad.B19001_016E / ad.B19001_001E end as HOUSINCOME15
                    , case when ad.B19001_001E > 0 then ad.B19001_017E / ad.B19001_001E end as HOUSINCOME16
                    , case when ad.B17026_001E > 0 then (ad.B17026_002E + ad.B17026_003E + ad.B17026_004E) / ad.B17026_001E end as HOUSPOVERTY
                    , case when ad.B17026_001E > 0 then (ad.B17026_002E) / ad.B17026_001E end as POV_LT_50
                    , case when ad.B17026_001E > 0 then (ad.B17026_003E) / ad.B17026_001E end as POV_50_74
                    , case when ad.B17026_001E > 0 then (ad.B17026_004E) / ad.B17026_001E end as POV_75_99
                    , case when ad.B17026_001E > 0 then (ad.B17026_005E) / ad.B17026_001E end as POV_100_124
                    , case when ad.B17026_001E > 0 then (ad.B17026_006E) / ad.B17026_001E end as POV_125_149
                    , case when ad.B17026_001E > 0 then (ad.B17026_007E) / ad.B17026_001E end as POV_150_174
                    , case when ad.B17026_001E > 0 then (ad.B17026_008E) / ad.B17026_001E end as POV_175_184
                    , case when ad.B17026_001E > 0 then (ad.B17026_009E) / ad.B17026_001E end as POV_185_199
                    , case when ad.B17026_001E > 0 then (ad.B17026_010E + ad.B17026_011E + ad.B17026_012E + ad.B17026_013E) / ad.B17026_001E end as POV_GT_200
                from &schema_sel..acs_demog ad
                ;) by td;
            execute (commit;) by td;
        quit;
    %end;
    %else %if %exist(td.acs_demog) %then %do;
        proc sql;
            connect to teradata as td (&td_goo) ;
            execute (create view &schema_sel..acs_demog_v as select * from &schema_sel..acs_demog;) by td;
            execute (commit;) by td;
        quit;
        %put INFO: View was created!;

    %end;
%mend create_or_replace_td_view;

%macro set_mode(prod_or_dev);
    %global schema_sel td_goo;
    %if &prod_or_dev = dev %then %do;
        
        %let schema_sel = dl_kpwhri_rdw;
        %put INFO: Mode set to development.;
    %end;
    %else %if &prod_or_dev = prod %then %do;
        %put INFO: Mode set to production.;
        %let schema_sel = sb_ghri;
    %end;
    %else %do;
        %put WARNING: MUST SPECIFY MODE!;
    %end;

    %let td_goo = user              = "&nuid@LDAP"
                  password          = "&cspassword"
                  server            = "&td_prod."
                  schema            = "&schema_sel."
                  connection        = global
                  mode              = teradata
                  fastload          = yes
    ;

    libname td teradata &td_goo ;
%mend set_mode;

%macro test_the_view();
    proc contents data = td.acs_demog_v;
    run;
    proc freq data = td.acs_demog_v;
    tables
        state * census_year
    ;
    run;
%mend test_the_view;

* %set_mode(prod);
* %set_mode(other);

******************************************************************************************;
* Execution block                                                                         ;
******************************************************************************************;

* set the mode;
%set_mode(dev);

* Confirm the schema;
%put Target schema: &schema_sel.;

* Create or replace the view;
%create_or_replace_td_view();

* Test the view;
%test_the_view;


endrsubmit;
signoff ghridwip;