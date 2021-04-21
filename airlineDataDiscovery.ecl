IMPORT $;
IMPORT GSECFiles;
IMPORT helperFiles;

/*	This file converts city/country/carrier codes and converts them into plain names to make further analysis and 
processing easier*/

//Record layout to add country where flight originates (departs)
countryDecodedRec := RECORD
  $.GSECFiles.GSECRec;
	STRING departCountryName;
END;

/*Join initial DS with CountriesCodeDS, matching condition is departCountryCode, adds departCountry name (First Join is 
2019 Data second Join is 2020 Data)*/
addDepartCountry2019 := JOIN($.GSECFiles.GsecDS2019,$.helperFiles.CountriesCodeDs,
                                  LEFT.DepartCountryCode = RIGHT.CountryCode,
                                  TRANSFORM(countryDecodedRec,
                                           SELF.departCountryName 	:= RIGHT.CountryName;
                                           SELF 										:= LEFT;
                                           SELF 										:= RIGHT),
                             SKEW(0.5));
addDepartCountry2020 := JOIN($.GSECFiles.GsecDS2020,$.helperFiles.CountriesCodeDs,
                                  LEFT.DepartCountryCode = RIGHT.CountryCode,
                                  TRANSFORM(countryDecodedRec,
                                           SELF.departCountryName := RIGHT.CountryName;
                                           SELF 									:= LEFT;
                                           SELF 									:= RIGHT)
                             ,SKEW(0.5));

//OUTPUT to test success of previous steps (commented after confirmed to work)
//OUTPUT(SAMPLE(addDepartCountry2019,5000),NAMED('departCountryNameAdded2019'));
//OUTPUT(SAMPLE(addDepartCountry2020,5000),NAMED('departCountryNameAdded2020'));

//Record layout to add country where flight ends (arrives)
bothCountryDecodedRec := RECORD
  countryDecodedRec;
	STRING arrivalCountryName;
END;
  
//Join result of previous joins with CountriesCodeDS again to add arrival country name
addDepartDestCountry2019 := JOIN(addDepartCountry2019,$.helperFiles.CountriesCodeDs,
                                  LEFT.ArriveCountryCode = RIGHT.CountryCode,
                                  TRANSFORM(bothCountryDecodedRec,
                                           SELF.arrivalCountryName 	:= RIGHT.CountryName;
                                           SELF 										:= LEFT;
                                           SELF 										:= RIGHT)
                                 ,SKEW(0.5));
addDepartDestCountry2020 := JOIN(addDepartCountry2020,$.helperFiles.CountriesCodeDs,
                                  LEFT.ArriveCountryCode = RIGHT.CountryCode,
                                  TRANSFORM(bothCountryDecodedRec,
                                           SELF.arrivalCountryName 	:= RIGHT.CountryName;
                                           SELF 										:= LEFT;
                                           SELF 										:= RIGHT)
                                 ,SKEW(0.5));

//OUTPUT to test success of previous steps (commented after confirmed to work)
//OUTPUT(SAMPLE(addDepartDestCountry2019,5000),NAMED('departAndArrivalCountryAdded2019'));
//OUTPUT(SAMPLE(addDepartDestCountry2020,5000),NAMED('departAndArrivalCountryAdded2020'));

//Record layout to add city information
locationsDecodedRec := RECORD
  bothCountryDecodedRec;
	STRING departureCity;
	STRING arrivalCity;
END;

//4 total Joins add city names for both departure and arrival to both DataSets from CitiesCodeDS
addDepartCityNames2019DS  := JOIN(addDepartDestCountry2019,$.helperFiles.CitiesCodeDs,
                                  LEFT.DepartCityCode = RIGHT.code,
                                  TRANSFORM(locationsDecodedRec,
                                            SELF.departureCity 	:= RIGHT.mixed_name;
                                            SELF 								:= LEFT;
                                            SELF 								:= [];
                                           ));
addCityNames2019DS 				:= JOIN(addDepartCityNames2019DS,$.helperFiles.CitiesCodeDs,
                                  LEFT.ArriveCityCode = RIGHT.code,
                                  TRANSFORM(locationsDecodedRec,
                                            SELF.arrivalCity 	:= RIGHT.mixed_name;
                                            SELF 							:= LEFT;
                                           ));
addDepartCityNames2020DS  := JOIN(addDepartDestCountry2020,$.helperFiles.CitiesCodeDs,
                                  LEFT.DepartCityCode = RIGHT.code,
                                  TRANSFORM(locationsDecodedRec,
                                            SELF.departureCity 	:= RIGHT.mixed_name;
                                            SELF 								:= LEFT;
                                            SELF 								:= [];
                                           ));
addCityNames2020DS 				:= JOIN(addDepartCityNames2020DS,$.helperFiles.CitiesCodeDs,
                                  LEFT.ArriveCityCode = RIGHT.code,
                                  TRANSFORM(locationsDecodedRec,
                                            SELF.arrivalCity 	:= RIGHT.mixed_name;
                                            SELF 							:= LEFT;
                                           ));

//OUTPUT to test success of previous steps (commented after confirmed to work)
//OUTPUT(SAMPLE(addCityNames2019DS ,5000),NAMED('cityAndCountryNamesAdded2019'));
//OUTPUT(SAMPLE(addCityNames2020DS ,5000),NAMED('cityAndCountryNamesAdded2020'));

//Record layout adds carrierName field
addCarrierRec := RECORD
  locationsDecodedRec;
	STRING carrierName;
END;

//Join datasets with country/city names addesd with CarrierCodeDS to add carrier name
addCarrierName2019DS := JOIN(addCityNames2019DS, $.helperFiles.CarriersCodeDs,
                          LEFT.carrier = RIGHT.CARCODE,
                          TRANSFORM(addCarrierRec,
                                   SELF.carrierName := RIGHT.LONGNAME;
                                   SELF 						:= LEFT;
                                   ));

 addCarrierName2020DS := JOIN(addCityNames2020DS, $.helperFiles.CarriersCodeDs,
                             LEFT.carrier = RIGHT.CARCODE,
                             TRANSFORM(addCarrierRec,
                                   SELF.carrierName := RIGHT.LONGNAME;
                                   SELF 						:= LEFT;
                                      ));
//OUTPUT to test success of previous steps (commented after confirmed to work)
//OUTPUT(SAMPLE(addCarrierName2019DS,5000),NAMED('locationAndCarrierNamesAdded2019'));
//OUTPUT(SAMPLE(addCarrierName2020DS,5000),NAMED('locationAndCarrierNamesAdded2020'));


EXPORT airlineDataDiscovery := MODULE
  /*RecordLayout reorganizes fields to move location and carrier data to beginning for easier checking, also removes code
versions of country/city/carrier fields and only preserves names*/
  EXPORT formattedAirlineDataRec := RECORD
    STRING 			carrier;
    STRING 			departCountryName;
    STRING2     DepartStateProvCode; 
    STRING 			departureCity;
    STRING 			arrivalCountryName;
    STRING2     ArriveStateProvCode;
    STRING 			arrivalCity;
    INTEGER2 		FlightNumber;
    STRING1   	CodeShareFlag;
    STRING3 		CodeShareCarrier; 
    STRING1     ServiceType;
    STRING8     EffectiveDate;
    STRING8     DiscontinueDate;
    UNSIGNED1   IsOpMon;
    UNSIGNED1   IsOpTue;
    UNSIGNED1   IsOpWed; 
    UNSIGNED1   IsOpThu;
    UNSIGNED1   IsOpFri;
    UNSIGNED1   IsOpSat; 
    UNSIGNED1   IsOpSun;
    STRING3     DepartStationCode;
    STRING10    DepartTimePassenger;
    STRING10    DepartTimeAircraft;
    STRING5     DepartUTCVariance;
    STRING2     DepartTerminal;
    STRING3     ArriveStationCode;
    STRING10    ArriveTimePassenger;
    STRING10    ArriveTimeAircraft;
    STRING5     ArriveUTCVariance;
    STRING2     ArriveTerminal;
    STRING3     EquipmentSubCode; 
    STRING3     EquipmentGroupCode;
    VARSTRING4  CabinCategoryClasses;
    VARSTRING40 BookingClasses; 
    INTEGER1    ArriveDayIndicator;
    INTEGER1    NumberOfIntermediateStops;
    VARSTRING50 IntermediateStopStationCodes;
    BOOLEAN     IsEquipmentChange;
    VARSTRING60 EquipmentCodesAcrossSector;
    VARSTRING80 MealCodes;
    INTEGER2    FlightDurationLessLayover;
    INTEGER2    FlightDistance;
    INTEGER2    FlightDistanceThroughIndividualLegs;
    INTEGER2    LayoverTime;
    INTEGER2    IVI;
    INTEGER2    FirstLegNumber;
    VARSTRING50 InFlightServiceCodes;                   
    BOOLEAN     IsCodeShare;                            
    BOOLEAN     IsWetLease;                             
    VARSTRING155 CodeShareInfo;                          
    INTEGER     FirstClassSeats;
    INTEGER     BusinessClassSeats;
    INTEGER     PremiumEconomySeats;
    INTEGER     EconomyClassSeats;
    INTEGER     TotalSeats;
    UNSIGNED    SectorizedId; 
  END;

  //Transform grabs all data in new order of Record Layout and changes the carrier field to hold only the name (instead of the code)
  EXPORT formattedAirlineDataRec finalFormatTransform(addCarrierRec L) := TRANSFORM
    SELF.carrier 	:= L.carrierName;
    SELF					:= L;
  END;

    //Project data into 2 final datasets and export them for further use
    EXPORT formattedAirlineData2019 	:= PROJECT(addCarrierName2019DS,finalFormatTransform(LEFT));
    EXPORT formattedAirlineData2020		:= PROJECT(addCarrierName2020DS,finalFormatTransform(LEFT));

    //OUTPUT(SAMPLE(formattedAirlineData2019,5000),NAMED('formattedAirlineData2019'));
    //OUTPUT(SAMPLE(formattedAirlineData2020,5000),NAMED('formattedAirlineData2020'));
END;