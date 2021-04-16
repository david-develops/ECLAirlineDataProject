IMPORT $;
IMPORT GSECFiles;
IMPORT helperFiles;
IMPORT airlineDataDiscovery;


//grab the data in a easy to refernce label
dataset2019 := $.airlineDataDiscovery.formattedAirlineData2019;
dataset2020 := $.airlineDataDiscovery.formattedAirlineData2020;

//seperate alegiant flights from each dataset
allegiantFlights2019 	:= dataset2019(carrier='Allegiant Air LLC');
allegiantFlights2020	:= dataset2020(carrier='Allegiant Air LLC');

deltaFlights2019 	:= dataset2019(carrier='Delta Air Lines, Inc.');
deltaFlights2020	:= dataset2020(carrier='Delta Air Lines, Inc.');

aaFlights2019 	:= dataset2019(carrier='American Airlines');
aaFlights2020		:= dataset2020(carrier='American Airlines');


//seperate frontier flights from each dataset
frontierFlights2019		:= dataset2019(carrier='Frontier Airlines, Inc.');
frontierFlights2020		:= dataset2020(carrier='Frontier Airlines, Inc.');

//seperate southwest flights from each dataset
southwestFlights2019	:= dataset2019(carrier='Southwest Airlines');
southwestFlights2020	:= dataset2020(carrier='Southwest Airlines');

//seperate spirit flights from each dataset
spiritFlights2019			:= dataset2019(carrier='Spirit Airlines');
spiritFlights2020			:= dataset2020(carrier='Spirit Airlines');

//recordset which only includes route information
routeRecord := RECORD
  STRING 		carrier;
	STRING 		dprtCity;
	STRING 		dprtState;
	STRING 		arrvCity;
	STRING 		arrvState;
	INTEGER2	FlightNumber;
	STRING		dprtStation;
	STRING		arrvStation;
END;

//transformation refines the data into only route information
routeRecord routeTransform($.airlineDataDiscovery.formattedAirlineDataRec L) := TRANSFORM
  SELF.carrier 			:= L.carrier;
	SELF.dprtCity			:= L.departurecity;
	SELF.dprtState 		:= L.departstateprovcode;
	SELF.arrvCity			:= L.arrivalcity;
	SELF.arrvState 		:= L.arrivestateprovcode;
	SELF.FlightNumber	:= L.FlightNumber;
	SELF.dprtStation  := L.DepartStationCode;
	SELF.arrvStation	:= L.ArriveStationCode;
END;

//Series of project statements create 2 datasets for each carrier
//Performed DEDUP on each ds to remove duplicate flight numbers
// --same flight number seems to indicate same route(same depart and arrive airports)
allegiantRoutes2019 := DEDUP(SORT(PROJECT(allegiantFlights2019, routeTransform(LEFT)),FlightNumber),FlightNumber);
allegiantRoutes2020 := DEDUP(SORT(PROJECT(allegiantFlights2020, routeTransform(LEFT)),FlightNumber),FlightNumber);

frontierRoutes2019	:= DEDUP(SORT(PROJECT(frontierFlights2019, routeTransform(LEFT)),FlightNumber),FlightNumber);
frontierRoutes2020	:= DEDUP(SORT(PROJECT(frontierFlights2020, routeTransform(LEFT)),FlightNumber),FlightNumber);

southwestRoutes2019	:= DEDUP(SORT(PROJECT(southwestFlights2019, routeTransform(LEFT)),FlightNumber),FlightNumber);
southwestRoutes2020	:= DEDUP(SORT(PROJECT(southwestFlights2020, routeTransform(LEFT)),FlightNumber),FlightNumber);

spiritRoutes2019		:= DEDUP(SORT(PROJECT(spiritFlights2019, routeTransform(LEFT)),FlightNumber),FlightNumber);
spiritRoutes2020		:= DEDUP(SORT(PROJECT(spiritFlights2020, routeTransform(LEFT)),FlightNumber),FlightNumber);

deltaRoutes2019			:= DEDUP(SORT(PROJECT(deltaFlights2019, routeTransform(LEFT)),FlightNumber),FlightNumber);
deltaRoutes2020			:= DEDUP(SORT(PROJECT(deltaFlights2020, routeTransform(LEFT)),FlightNumber),FlightNumber);

aaRoutes2019				:= DEDUP(SORT(PROJECT(aaFlights2019, routeTransform(LEFT)),FlightNumber),FlightNumber);
aaRoutes2020				:= DEDUP(SORT(PROJECT(aaFlights2020, routeTransform(LEFT)),FlightNumber),FlightNumber);

//For each airline JOIN based on dprt and arrv city 
//LEFT ONLY in order to find routes from 2019 not in 2020 dataset
allegiantDropped	:= JOIN(allegiantRoutes2019,allegiantRoutes2020,
                         LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity,
                         TRANSFORM(routeRecord,
                                  SELF := LEFT;
                                  SELF := RIGHT;
                                  ),LEFT ONLY);
allegiantAdded	:= JOIN(allegiantRoutes2019,allegiantRoutes2020,
                         LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity,
                         TRANSFORM(routeRecord,
                                  SELF := LEFT;
                                  SELF := RIGHT;
                                  ),RIGHT ONLY);

frontierDropped 	:= JOIN(frontierRoutes2019,frontierRoutes2020,
                         LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity,
                         TRANSFORM(routeRecord,
                                  SELF := LEFT;
                                  SELF := RIGHT;
                                  ),LEFT ONLY);

frontierAdded 	:= JOIN(frontierRoutes2019,frontierRoutes2020,
                         LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity,
                         TRANSFORM(routeRecord,
                                  SELF := LEFT;
                                  SELF := RIGHT;
                                  ),RIGHT ONLY);

southwestDropped 	:= JOIN(southwestRoutes2019,southwestRoutes2020,
                         LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity,
                         TRANSFORM(routeRecord,
                                  SELF := LEFT;
                                  SELF := RIGHT;
                                  ),LEFT ONLY);

southwestAdded 	:= JOIN(southwestRoutes2019,southwestRoutes2020,
                         LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity,
                         TRANSFORM(routeRecord,
                                  SELF := LEFT;
                                  SELF := RIGHT;
                                  ),RIGHT ONLY);
spiritDropped 		:= JOIN(spiritRoutes2019,spiritRoutes2020,
                         LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity,
                         TRANSFORM(routeRecord,
                                  SELF := LEFT;
                                  SELF := RIGHT;
                                  ),LEFT ONLY);

spiritAdded 		:= JOIN(spiritRoutes2019,spiritRoutes2020,
                         LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity,
                         TRANSFORM(routeRecord,
                                  SELF := LEFT;
                                  SELF := RIGHT;
                                  ),RIGHT ONLY);

deltaDropped 			:= JOIN(deltaRoutes2019,deltaRoutes2020,
                         LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity,
                         TRANSFORM(routeRecord,
                                  SELF := LEFT;
                                  SELF := RIGHT;
                                  ),LEFT ONLY);
deltaAdded 			:= JOIN(deltaRoutes2019,deltaRoutes2020,
                         LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity,
                         TRANSFORM(routeRecord,
                                  SELF := LEFT;
                                  SELF := RIGHT;
                                  ),RIGHT ONLY);

aaDropped 			:= JOIN(aaRoutes2019,aaRoutes2020,
                         LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity,
                         TRANSFORM(routeRecord,
                                  SELF := LEFT;
                                  SELF := RIGHT;
                                  ),LEFT ONLY);

aaAdded 			:= JOIN(aaRoutes2019,aaRoutes2020,
                         LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity,
                         TRANSFORM(routeRecord,
                                  SELF := LEFT;
                                  SELF := RIGHT;
                                  ),RIGHT ONLY);
/*==		-- OUTPUTS --		==*/
//allegiant
OUTPUT(SORT(allegiantRoutes2019,dprtcity),NAMED('allegiantRoutes2019'));
OUTPUT(SORT(allegiantRoutes2020,dprtcity),NAMED('allegiantRoutes2020'));

OUTPUT(SORT(allegiantDropped,dprtcity),NAMED('allegiantDropped'));
OUTPUT(SORT(allegiantAdded,dprtcity),NAMED('allegiantAdded'));
//frontier
OUTPUT(frontierRoutes2019,NAMED('frontierRoutes2019'));
OUTPUT(frontierRoutes2020,NAMED('frontierRoutes2020'));

OUTPUT(SORT(frontierDropped,dprtcity),NAMED('frontierDropped'));
OUTPUT(SORT(frontierAdded,dprtcity),NAMED('frontierAdded'));
//southwest
OUTPUT(southwestRoutes2019,NAMED('southwestRoutes2019'));
OUTPUT(southwestRoutes2020,NAMED('southwestRoutes2020'));

OUTPUT(SORT(southwestDropped,dprtcity),NAMED('southwestDropped'));
OUTPUT(SORT(southwestAdded,dprtcity),NAMED('southwestAdded'));
//spirit
OUTPUT(spiritRoutes2019,NAMED('spiritRoutes2019'));
OUTPUT(spiritRoutes2020,NAMED('spiritRoutes2020'));

OUTPUT(SORT(spiritDropped,dprtcity),NAMED('spiritDropped'));
OUTPUT(SORT(spiritAdded,dprtcity),NAMED('spiritAdded'));
//delta
OUTPUT(deltaRoutes2019,NAMED('deltaRoutes2019'));
OUTPUT(deltaRoutes2020,NAMED('deltaRoutes2020'));

OUTPUT(SORT(deltaDropped,dprtcity),NAMED('deltaDropped'));
OUTPUT(SORT(deltaAdded,dprtcity),NAMED('deltaAdded'));
//american Airlines
OUTPUT(aaRoutes2019,NAMED('aaRoutes2019'));
OUTPUT(aaRoutes2020,NAMED('aaRoutes2020'));

OUTPUT(SORT(aaDropped,dprtcity),NAMED('aaDropped'));
OUTPUT(SORT(aaAdded,dprtcity),NAMED('aaAdded'));