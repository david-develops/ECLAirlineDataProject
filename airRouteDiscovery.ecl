IMPORT $;
IMPORT GSECFiles;
IMPORT helperFiles;
IMPORT airlineDataDiscovery;

/*
	This file further shapes the data to focus on specific routes for different airlines from each dataset
		-2 budget airlines (Southwest, frontier)
		-2 large traditional airlines (Delta, American Airlines)

1. The first step is to isolate the flights from each carrier

2. Next enrich/append data using Transform/Project to focus on the departing and arriving locations for each flight
	 as well as remove any duplicate flight numbers (same route but diff day or configuration)

3. Then use 2 different types of joins for each resulting dataset which will output records that are in one 
	 dataset but not the other

			-first join shows flights that are in the 2019 dataset only (flights that were dropped for 2020)

			-second join shows the inverse, flights not in 2019 dataset but in 2020 dataset (flights that are new in 2020 
			for that airline)
4. Final step is to create datasets with just carrier and location as well as Region classification
	-will be used for visualization
*/



EXPORT airRouteDiscovery := MODULE
    /*
    STEP 1 - Isolate the data for each airline
  */

  //grab the data in a easy to refernce label
  EXPORT dataset2019 := $.airlineDataDiscovery.formattedAirlineData2019;
  EXPORT dataset2020 := $.airlineDataDiscovery.formattedAirlineData2020;

  //seperate frontier flights from each dataset
  EXPORT frontierFlights2019		:= dataset2019(carrier='Frontier Airlines, Inc.');
  EXPORT frontierFlights2020		:= dataset2020(carrier='Frontier Airlines, Inc.');

  //seperate southwest flights from each dataset
  EXPORT southwestFlights2019	:= dataset2019(carrier='Southwest Airlines');
  EXPORT southwestFlights2020	:= dataset2020(carrier='Southwest Airlines');

  //seperate delta flights from each dataset
  EXPORT deltaFlights2019 	:= dataset2019(carrier='Delta Air Lines, Inc.');
  EXPORT deltaFlights2020	:= dataset2020(carrier='Delta Air Lines, Inc.');

  //seperate american airlines flights from each dataset
  EXPORT aaFlights2019 	:= dataset2019(carrier='American Airlines');
  EXPORT aaFlights2020		:= dataset2020(carrier='American Airlines');

  /*
    STEP 2 - Enrich/Append - shape the data into a more useful form for comparison between years based on route
  */
    //recordset which only includes route information
  EXPORT routeRecord := RECORD
    STRING 		carrier;
    STRING		dprtStation;
    STRING 		dprtCity;
    STRING 		dprtState;
		STRING		dprtCountry;
    STRING		arrvStation;
    STRING 		arrvCity;
    STRING 		arrvState;
		STRING		arrvCountry;
    INTEGER2	FlightNumber;
  END;

  //transformation refines the data into only route information
  EXPORT routeRecord routeTransform($.airlineDataDiscovery.formattedAirlineDataRec L) := TRANSFORM
    SELF.carrier 			:= L.carrier;
    SELF.dprtStation  := L.DepartStationCode;
    SELF.dprtCity			:= L.departurecity;
    SELF.dprtState 		:= L.departstateprovcode;
		SELF.dprtCountry	:= L.departCountryName;
    SELF.arrvStation	:= L.ArriveStationCode;
    SELF.arrvCity			:= L.arrivalcity;
    SELF.arrvState 		:= L.arrivestateprovcode;
		SELF.arrvCountry	:= L.arrivalCountryName;
    SELF.FlightNumber	:= L.FlightNumber;


  END;

  //Series of project statements create 2 datasets for each carrier
  //Performed DEDUP on each ds to remove duplicate flight numbers
  // --same flight number seems to indicate same route(same depart and arrive airports)
  
  EXPORT frontierRoutes2019	:= DEDUP(SORT(PROJECT(frontierFlights2019, routeTransform(LEFT)),FlightNumber),FlightNumber);
  EXPORT frontierRoutes2020	:= DEDUP(SORT(PROJECT(frontierFlights2020, routeTransform(LEFT)),FlightNumber),FlightNumber);
  
  EXPORT southwestRoutes2019	:= DEDUP(SORT(PROJECT(southwestFlights2019, routeTransform(LEFT)),FlightNumber),FlightNumber);
  EXPORT southwestRoutes2020	:= DEDUP(SORT(PROJECT(southwestFlights2020, routeTransform(LEFT)),FlightNumber),FlightNumber);

  EXPORT deltaRoutes2019			:= DEDUP(SORT(PROJECT(deltaFlights2019, routeTransform(LEFT)),FlightNumber),FlightNumber);
  EXPORT deltaRoutes2020			:= DEDUP(SORT(PROJECT(deltaFlights2020, routeTransform(LEFT)),FlightNumber),FlightNumber);

  EXPORT aaRoutes2019				:= DEDUP(SORT(PROJECT(aaFlights2019, routeTransform(LEFT)),FlightNumber),FlightNumber);
  EXPORT aaRoutes2020				:= DEDUP(SORT(PROJECT(aaFlights2020, routeTransform(LEFT)),FlightNumber),FlightNumber);

  /*
    STEP 3 - Joins to create contrasts between datasets - 
      -"dropped" datasets show flights from 2019 not in 2020 for that airline
      -"added" datasets show flights from 2020 not in 2019 for that airline
  */
  //For each airline JOIN based on dprt and arrv city 
  
  //LEFT ONLY in order to find routes from 2019 not in 2020 dataset
  EXPORT frontierDropped 	:= JOIN(frontierRoutes2019,frontierRoutes2020,
                           LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity AND RIGHT.FlightNumber !=0 AND LEFT.FlightNumber !=0,
                           TRANSFORM(routeRecord,
                                    SELF := LEFT;
                                    SELF := RIGHT;
                                    ),LEFT ONLY);
  //RIGHT ONLY in order to find routes from 2020 not in 2019 dataset
  EXPORT frontierAdded 	:= JOIN(frontierRoutes2019,frontierRoutes2020,
                           LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity AND RIGHT.FlightNumber !=0 AND LEFT.FlightNumber !=0,
                           TRANSFORM(routeRecord,
                                    SELF := RIGHT;
                                    SELF := LEFT;
                                    ),RIGHT ONLY);

  //Southwest
  //LEFT ONLY in order to find routes from 2019 not in 2020 dataset
  EXPORT southwestDropped 	:= JOIN(southwestRoutes2019,southwestRoutes2020,
                           LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity AND RIGHT.FlightNumber !=0 AND LEFT.FlightNumber !=0,
                           TRANSFORM(routeRecord,
                                    SELF := LEFT;
                                    SELF := RIGHT;
                                    ),LEFT ONLY);
  //RIGHT ONLY in order to find routes from 2020 not in 2019 dataset
  EXPORT southwestAdded 	:= JOIN(southwestRoutes2019,southwestRoutes2020,
                           LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity AND RIGHT.FlightNumber !=0 AND LEFT.FlightNumber !=0,
                           TRANSFORM(routeRecord,
                                    SELF := RIGHT;
                                    SELF := LEFT;
                                    ),RIGHT ONLY);
  //Delta
  //LEFT ONLY in order to find routes from 2019 not in 2020 dataset
  EXPORT deltaDropped 			:= JOIN(deltaRoutes2019,deltaRoutes2020,
                           LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity AND RIGHT.FlightNumber !=0 AND LEFT.FlightNumber !=0,
                           TRANSFORM(routeRecord,
                                    SELF := LEFT;
                                    SELF := RIGHT;
                                    ),LEFT ONLY);
  //RIGHT ONLY in order to find routes from 2020 not in 2019 dataset
  EXPORT deltaAdded 			:= JOIN(deltaRoutes2019,deltaRoutes2020,
                           LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity AND RIGHT.FlightNumber !=0 AND LEFT.FlightNumber !=0,
                           TRANSFORM(routeRecord,
                                    SELF := RIGHT;
                                    SELF := LEFT;
                                    ),RIGHT ONLY);

  //American Airlines
  //LEFT ONLY in order to find routes from 2019 not in 2020 dataset
  EXPORT aaDropped 			:= JOIN(aaRoutes2019,aaRoutes2020,
                           LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity AND RIGHT.FlightNumber !=0 AND LEFT.FlightNumber !=0,
                           TRANSFORM(routeRecord,
                                    SELF := LEFT;
                                    SELF := RIGHT;
                                    ),LEFT ONLY);
  //RIGHT ONLY in order to find routes from 2020 not in 2019 dataset
  EXPORT aaAdded 			:= JOIN(aaRoutes2019,aaRoutes2020,
                           LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity AND RIGHT.FlightNumber !=0 AND LEFT.FlightNumber !=0,
                           TRANSFORM(routeRecord,
                                    SELF := RIGHT;
                                    SELF := LEFT;
                                    ),RIGHT ONLY);
  /*
    STEP 4 - Regions added for visualization - 
     
  */
	//Record only includes carrier - location/region - flightnumber
  EXPORT regionRecord	:= RECORD
    STRING 		carrier;
    STRING 		dprtCountry;
    STRING 		dprtRegion;
    STRING		arrvCountry;
    STRING		arrvRegion;
    INTEGER2	flightNumber;
  END;

	//Sets representing each region designation used to be utilized in transform
  EXPORT SET OF STRING africa 				:= ['Congo','Guinea','Angola','Democratic Republic of Congo','Mauritania','Seychelles','Nigeria'];
  EXPORT SET OF STRING caribbean			:= ['Trinidad and Tobago','Martinique','Sint Maarten','Grenada','Turks and Caicos Islands','Cuba','Bahamas','Dominican Republic','U.S. Virgin Islands','British Virgin Islands','Antigua and Barbuda','Cayman Islands','Haiti','Jamaica','Puerto Rico'];
  EXPORT SET of STRING southAmerica	:= ['Chile','Plurinational State of Bolivia','El Salvador','Peru','Argentina','Costa Rica','Belize','Colombia','Nicaragua','Aruba','Brazil','Ecuador','Honduras','Paraguay','Uruguay'];
  EXPORT SET OF STRING pacific				:= ['New Zealand','Australia','Indonesia','Malaysia','Palau','Philippines','Singapore','Thailand'];
  EXPORT SET OF STRING northAmerica	:= ['Bermuda','United States','Canada','Mexico'];
  EXPORT SET OF STRING europe				:= ['Sweden','Lithuania','Belgium','Finland','Iceland','Greece','Albania','Austria','Slovenia','serbia','Croatia','Czech Republic','Denmark','France','Germany','Ireland','Italy','Netherlands','Poland','Portugal','Romania','Spain and Canary Islands','Switzerland','United Kingdom'];
  EXPORT SET OF STRING asia					:= ['China','India','Japan','Republic of Korea','Viet Nam'];

	//Transform assigns region based on country
  EXPORT regionRecord regionTransform(routeRecord L)	:= TRANSFORM
    SELF.carrier			:= L.carrier;
    SELF.dprtCountry	:= L.dprtCountry;
    SELF.arrvCountry	:= L.arrvCountry;
    SELF.flightNumber := L.flightNumber;
    SELF.dprtRegion		:= MAP(	L.dprtCountry IN africa 			=> 'Africa',
                              L.dprtCountry IN caribbean 		=> 'Caribbean',
                              L.dprtCountry IN southAmerica	=> 'South America',
                              L.dprtCountry IN northAmerica	=> 'North America',
                              L.dprtCountry IN pacific			=> 'Pacific',
                              L.dprtCountry IN europe				=> 'Europe',
                              L.dprtCountry IN asia					=> 'Asia',
                             'REGION UNIDENTIFIED'
                            );
    SELF.arrvRegion		:= MAP(	L.arrvCountry IN africa 			=> 'Africa',
                              L.arrvCountry IN caribbean 		=> 'Caribbean',
                              L.arrvCountry IN southAmerica	=> 'South America',
                              L.arrvCountry IN northAmerica	=> 'North America',
                              L.arrvCountry IN pacific			=> 'Pacific',
                              L.arrvCountry IN europe				=> 'Europe',
                              L.arrvCountry IN asia					=> 'Asia',
                             'REGION UNIDENTIFIED'
                            );
	END;

  //Create easy to use region datasets with Sort/Project
  EXPORT frontierRouteRegion 	:= SORT(PROJECT(frontierDropped,regionTransform(LEFT)),arrvRegion,dprtRegion);
  EXPORT southWestRouteRegion	:= SORT(PROJECT(southWestDropped,regionTransform(LEFT)),arrvRegion,dprtRegion);
  EXPORT deltaRouteRegion 			:= SORT(PROJECT(deltaDropped,regionTransform(LEFT)),arrvRegion,dprtRegion);
  EXPORT aaRouteRegion					:= SORT(PROJECT(aaDropped,regionTransform(LEFT)),arrvRegion,dprtRegion);
	
EXPORT countriesServedByDelta := TABLE(deltaRoutes2019,{
  																			arrvCountry,
																				INTEGER numOfFLights	:= COUNT(GROUP),
																			},arrvCountry);
EXPORT countriesServedByAA := TABLE(aaRoutes2019,{
  																			arrvCountry,
																				INTEGER numOfFlights	:= COUNT(GROUP),
																			},arrvCountry);

END;

/*==		-- OUTPUTS --		==*/
/*
//frontier
//OUTPUT(frontierRoutes2019,NAMED('frontierRoutes2019'));
//OUTPUT(frontierRoutes2020,NAMED('frontierRoutes2020'));

//OUTPUT(SORT(frontierDropped,dprtcity),NAMED('frontierDropped'));
//OUTPUT(SORT(frontierAdded,dprtcity),NAMED('frontierAdded'));

//southwest
OUTPUT(southwestRoutes2019,NAMED('southwestRoutes2019'));
OUTPUT(southwestRoutes2020,NAMED('southwestRoutes2020'));

OUTPUT(SORT(southwestDropped,dprtcity),NAMED('southwestDropped'));
OUTPUT(SORT(southwestAdded,dprtcity),NAMED('southwestAdded'));
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
*/