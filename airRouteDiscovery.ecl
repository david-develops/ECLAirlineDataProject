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
END;

//transformation refines the data into only route information
routeRecord routeTransform($.airlineDataDiscovery.formattedAirlineDataRec L) := TRANSFORM
  SELF.carrier 			:= L.carrier;
	SELF.dprtCity			:= L.departurecity;
	SELF.dprtState 		:= L.departstateprovcode;
	SELF.arrvCity			:= L.arrivalcity;
	SELF.arrvState 		:= L.arrivestateprovcode;
	SELF.FlightNumber	:= L.FlightNumber;
END;

//Series of project statements create 2 datasets for each carrier
allegiantRoutes2019 := DEDUP(SORT(PROJECT(allegiantFlights2019, routeTransform(LEFT)),FlightNumber),FlightNumber);
allegiantRoutes2020 := DEDUP(SORT(PROJECT(allegiantFlights2020, routeTransform(LEFT)),FlightNumber),FlightNumber);

frontierRoutes2019	:= DEDUP(SORT(PROJECT(frontierFlights2019, routeTransform(LEFT)),FlightNumber),FlightNumber);
frontierRoutes2020	:= DEDUP(SORT(PROJECT(frontierFlights2020, routeTransform(LEFT)),FlightNumber),FlightNumber);

southwestRoutes2019	:= DEDUP(SORT(PROJECT(southwestFlights2019, routeTransform(LEFT)),FlightNumber),FlightNumber);
southwestRoutes2020	:= DEDUP(SORT(PROJECT(southwestFlights2020, routeTransform(LEFT)),FlightNumber),FlightNumber);

spiritRoutes2019	:= DEDUP(SORT(PROJECT(spiritFlights2019, routeTransform(LEFT)),FlightNumber),FlightNumber);
spiritRoutes2020	:= DEDUP(SORT(PROJECT(spiritFlights2020, routeTransform(LEFT)),FlightNumber),FlightNumber);

deltaRoutes2019	:= DEDUP(SORT(PROJECT(deltaFlights2019, routeTransform(LEFT)),FlightNumber),FlightNumber);
deltaRoutes2020	:= DEDUP(SORT(PROJECT(deltaFlights2020, routeTransform(LEFT)),FlightNumber),FlightNumber);

aaRoutes2019	:= DEDUP(SORT(PROJECT(aaFlights2019, routeTransform(LEFT)),FlightNumber),FlightNumber);
aaRoutes2020	:= DEDUP(SORT(PROJECT(aaFlights2020, routeTransform(LEFT)),FlightNumber),FlightNumber);

/*==		-- OUTPUTS --		==*/
//allegiant
OUTPUT(allegiantRoutes2019,NAMED('allegiantRoutes2019'));
OUTPUT(allegiantRoutes2020,NAMED('allegiantRoutes2020'));

//frontier
OUTPUT(frontierRoutes2019,NAMED('frontierRoutes2019'));
OUTPUT(frontierRoutes2020,NAMED('frontierRoutes2020'));

//southwest
OUTPUT(southwestRoutes2019,NAMED('southwestRoutes2019'));
OUTPUT(southwestRoutes2020,NAMED('southwestRoutes2020'));

//spirit
OUTPUT(spiritRoutes2019,NAMED('spiritRoutes2019'));
OUTPUT(spiritRoutes2020,NAMED('spiritRoutes2020'));

OUTPUT(deltaRoutes2019,NAMED('deltaRoutes2019'));
OUTPUT(deltaRoutes2020,NAMED('deltaRoutes2020'));

OUTPUT(aaRoutes2019,NAMED('aaRoutes2019'));
OUTPUT(aaRoutes2020,NAMED('aaRoutes2020'));