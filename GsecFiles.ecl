EXPORT GSECFiles := MODULE

EXPORT GSECRec := RECORD
    STRING3             Carrier;                                // two or three letter code assigned by IATA or ICAO for the Carrier
    INTEGER2            FlightNumber;                           // flight number
    STRING1             CodeShareFlag;                          // service type indicator is used to classify carriers according to the type of air service they provide
    STRING3             CodeShareCarrier;                       // alternate flight designator or ticket selling airline
    STRING1             ServiceType;                            // classify carriers according to the type of air service they provide
    STRING8             EffectiveDate;                          // effective date represents the date that the carrier has scheduled this flight service to begin; YYYYMMDD
    STRING8             DiscontinueDate;                        // discontinued date represents the last date that the carrier has scheduled this flight service to operate; YYYYMMDD
    UNSIGNED1           IsOpMon;                                // indicates whether the flight has service on Monday
    UNSIGNED1           IsOpTue;                                // indicates whether the flight has service on Tuesday
    UNSIGNED1           IsOpWed;                                // indicates whether the flight has service on Wednesday
    UNSIGNED1           IsOpThu;                                // indicates whether the flight has service on Thursday
    UNSIGNED1           IsOpFri;                                // indicates whether the flight has service on Friday
    UNSIGNED1           IsOpSat;                                // indicates whether the flight has service on Saturday
    UNSIGNED1           IsOpSun;                                // indicates whether the flight has service on Sunday
    STRING3             DepartStationCode;                      // standard IATA Airport code for the point of trip origin
    STRING2             DepartCountryCode;                      // standard IATA Country code for the point of trip origin
    STRING2             DepartStateProvCode;                    // Innovata State Code
    STRING3             DepartCityCode;                         // departure city code contains the city code for the point of trip origin
    STRING10            DepartTimePassenger;                    // published flight departure time; HHMMSS
    STRING10            DepartTimeAircraft;                     // agreed SLOT departure time; HHMMSS
    STRING5             DepartUTCVariance;                      // UTC Variant for the departure airport; [+-]HHMM
    STRING2             DepartTerminal;                         // departure terminal
    STRING3             ArriveStationCode;                      // standard IATA Airport code for the point of arrival
    STRING2             ArriveCountryCode;                      // standard IATA Country code for the point of arrival
    STRING2             ArriveStateProvCode;                    // Innovata State Code
    STRING3             ArriveCityCode;                         // arrival city code contains the city code for the point of trip origin
    STRING10            ArriveTimePassenger;                    // published flight arrival time; HHMMSS
    STRING10            ArriveTimeAircraft;                     // agreed SLOT arrival time; HHMMSS
    STRING5             ArriveUTCVariance;                      // UTC Variant for the arrival airport; [+-]HHMM
    STRING2             ArriveTerminal;                         // arrival terminal
    STRING3             EquipmentSubCode;                       // sub aircraft type on the first leg of the flight
    STRING3             EquipmentGroupCode;                     // group aircraft type on the first leg of the flight
    VARSTRING4          CabinCategoryClasses;                   // most commonly used service classes
    VARSTRING40         BookingClasses;                         // full list of Service Class descriptions
    INTEGER1            ArriveDayIndicator;                     // signifies which day the flight will arrive with respect to the origin depart day; <blank> = same day, -1 = day before, 1 = day after, 2 = two days after
    INTEGER1            NumberOfIntermediateStops;              // set to zero (i.e. nonstop) if the flight does not land between the point of origin and final destination
    VARSTRING50         IntermediateStopStationCodes;           // IATA airport codes where stops occur, separated by “!”
    BOOLEAN             IsEquipmentChange;                      // signifies whether there has been an aircraft change at a stopover point for the flight leg
    VARSTRING60         EquipmentCodesAcrossSector;             // sub-aircraft type on each leg of the flight
    VARSTRING80         MealCodes;                              // contains up to two meal codes per class of service
    INTEGER2            FlightDurationLessLayover;              // fefers to Actual Air time of flight; does not include layover time
    INTEGER2            FlightDistance;                         // shortest distance (in miles) between the origin and destination points
    INTEGER2            FlightDistanceThroughIndividualLegs;
    INTEGER2            LayoverTime;                            // minutes
    INTEGER2            IVI;
    INTEGER2            FirstLegNumber;
    VARSTRING50         InFlightServiceCodes;
    BOOLEAN             IsCodeShare;                            // true if flight is operated by another carrier
    BOOLEAN             IsWetLease;                             // true if wet lease (owned by one carrier and operated by another)
    VARSTRING155        CodeShareInfo;                          // information regarding operating and marketing carriers
    INTEGER             FirstClassSeats;
    INTEGER             BusinessClassSeats;
    INTEGER             PremiumEconomySeats;
    INTEGER             EconomyClassSeats;
    INTEGER             TotalSeats;
    UNSIGNED            SectorizedId;                           // unique record ID
END;


EXPORT GsecDS2019 := DATASET('~gsec::2019::raw::thor', GSECRec, THOR);

EXPORT GsecDS2020 :=  DATASET('~GSEC::2020::raw::Thor', GSECRec, THOR);

END;