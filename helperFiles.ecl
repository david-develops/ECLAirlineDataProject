EXPORT helperFiles := MODULE

    EXPORT CountriesRec := RECORD
        STRING CountryCode;
        STRING CountryName;
    END;

    EXPORT CountriesCodeDs := DATASET('~.::country.tsv', CountriesRec, CSV(SEPARATOR('\t'), HEADING(1)));


    EXPORT StationsRec := RECORD
        STRING STACODE;
        STRING CITYCODE;
        STRING STANAME;
        STRING CITYNAME;
        STRING STATEPROVCODE; 
        STRING CNTRYCODE;
        STRING LATITUDE;
        STRING LONGITUDE; 
        STRING TZCODE;
        STRING STATYPE;
    END;

    EXPORT StationsCodeDs := DATASET('~raw::stations.tsv', StationsRec, CSV(SEPARATOR('\t'), HEADING(1)));

    EXPORT CitiesRec := RECORD
        INTEGER ID;
        STRING  CODE;
        STRING  MIXED_NAME;
        STRING  STATE_ID;
        STRING  COUNTRY_ID;
        STRING  STATEPROVCODE;
        STRING  CNTRYCODE;
        STRING  PARENT_CITY_ID;
        STRING  CITY_AREA;
        STRING  TIME_ZONE_CODE;
        STRING  INTERNET_ADDRESS;
        STRING  URL;
        REAL    LAT;
        REAL    LONG;
    END;

    EXPORT CitiesCodeDs := DATASET('~raw::cities.dat', CitiesRec, CSV(SEPARATOR('\t'), HEADING(1)));

    EXPORT CarriersRec := RECORD
        STRING2 CARCODE;
        STRING3 CARCODETHREE;
        STRING1 CONTROLDUP;
        STRING  LONGNAME;
        STRING  SHORTNAME;
        STRING1 CARTYPE;
        STRING  RESPHONE;
        STRING  URL;
    END;

    EXPORT CarriersCodeDs := DATASET('~raw::carriers.tsv', CarriersRec, CSV(SEPARATOR('\t'), HEADING(1)));

END;
