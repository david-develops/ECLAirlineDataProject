IMPORT $;
IMPORT airRouteDiscovery;
/*
	This file uses the files built in the previous steps to begin drawing conclusions about changes airlines have made
	
	1. First step is to combine budget carriers to see what routes they both dropped -then the same for major carriers
		-also combined the resulting datasets to check for routes dropped by all 3 (they were none dropped by all 4)
	2. Second step is to count the routes dropped by each airline to each region, this dataset will be used for
		 visualization directly 
	3. Perform similar step for U.S. States since budget carriers don't offer many int'l routes
*/

//First define the data we will need in easy to reference names
//reuse the record from previous steps
routeRecord := $.airRouteDiscovery.routeRecord;
	
//import all of the datasets to be used
frontierDropped			:= $.airRouteDiscovery.frontierDropped;
frontierAdded				:= $.airRouteDiscovery.frontierAdded;
frontierRouteRegion := $.airRouteDiscovery.frontierRouteRegion;
southWestDropped 		:= $.airRouteDiscovery.southWestDropped;
southWestAdded			:= $.airRouteDiscovery.southWestAdded;
southWestRouteRegion:= $.airRouteDiscovery.southWestRouteRegion;
deltaDropped				:= $.airRouteDiscovery.deltaDropped;
deltaAdded					:= $.airRouteDiscovery.deltaAdded;
deltaRouteRegion		:= $.airRouteDiscovery.deltaRouteRegion;
aaDropped						:= $.airRouteDiscovery.aaDropped;
aaAdded							:= $.airRouteDiscovery.aaAdded;
aaRouteRegion				:= $.airRouteDiscovery.aaRouteRegion;

EXPORT airRouteAnalysis := MODULE
/*
	STEP 1 - Check for routes dropped by multiple carriers
		-one ds of budget routes dropped
		-another for the major carriers
		-check for any dropped by all 4
*/
  
  //add field for second carrier for each route
	EXPORT	carrierRouteRecord := RECORD
  	      	STRING CarrierTwo;
    	    	routeRecord;
      		END;
	//create DS of routes dropped by both SouthWest and Frontier
	EXPORT budgetDropped := JOIN(frontierDropped,southWestDropped,
                     LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity,
                     TRANSFORM(carrierRouteRecord,
                              SELF 									:= LEFT;
                              SELF 									:= RIGHT;
                              SELF.carrierTwo 			:= RIGHT.carrier;
                              ));
	//create DS of routes dropped by both American and Delta
	EXPORT majorDropped	:= JOIN(deltaDropped,aaDropped,
                     LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity,
                     TRANSFORM(carrierRouteRecord,
                              SELF 									:= LEFT;
                              SELF 									:= RIGHT;
                              SELF.carrierTwo 			:= RIGHT.carrier;
                              ));
	//create DS of routes dropped by all 4 carriers (empty)
	EXPORT bothDropped		:= JOIN(budgetDropped,majorDropped,
                     LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity,
                     TRANSFORM(routeRecord,
                              SELF 									:= LEFT;
                              SELF 									:= RIGHT;
                              ));
	/*
		STEP 2 - Count the number of records for each region, will be used for visualization
	*/
	//Table for each ds calculates the number of records by region
	EXPORT frontierDroppedByRegion 	:= TABLE(frontierRouteRegion,{
                                            arrvRegion,
                                            INTEGER droppedRoutes := COUNT(GROUP),
  																					},arrvRegion);
	EXPORT southWestDroppedByRegion := TABLE(southWestRouteRegion,{
                                            arrvRegion,
    																				INTEGER droppedRoutes	:= COUNT(GROUP),
  																					},arrvRegion);
	EXPORT deltaDroppedByRegion			:= TABLE(deltaRouteRegion,{
                                            arrvRegion,
    																				INTEGER droppedRoutes	:= COUNT(GROUP),
  																					},arrvRegion);
	EXPORT aaDroppedByRegion				:= TABLE(aaRouteRegion,{
                                            arrvRegion,
    																				INTEGER droppedRoutes	:= COUNT(GROUP),
  																					},arrvRegion);
	/*
		STEP 3 - Count the number of records for each state, will be used for visualization
	*/

	EXPORT frontierDroppedByState		:= TABLE(frontierDropped,{
																					arrvState,
                                          INTEGER droppedRoutesforState := COUNT(GROUP),
																					},arrvState);
	EXPORT southWestDroppedByState	:= TABLE(southWestDropped,{
																					arrvState,
                                          INTEGER droppedRoutesforState := COUNT(GROUP),
																					},arrvState);
	EXPORT deltaDroppedByState			:= TABLE(deltaDropped,{
																					arrvState,
                                          INTEGER droppedRoutesforState := COUNT(GROUP),
																					},arrvState);
	EXPORT aaDroppedByState					:= TABLE(frontierDropped,{
																					arrvState,
                                          INTEGER droppedRoutesforState := COUNT(GROUP),
																					},arrvState);
END;

/*--OUTPUTS --


/* --Frontier Dropped routes-- */

//All dropped flights
//OUTPUT(SORT(frontierDropped,arrvcity),NAMED('frontierDropped'));

//dropped flights from countries team is focused on (the budget carriers were not operating any flights to these before)
//OUTPUT(SORT(frontierDropped(arrvCountry='Italy'),arrvCountry),NAMED('frontierDroppedfromItaly'));
//OUTPUT(SORT(frontierDropped(arrvCountry='China'),arrvCountry),NAMED('frontierDroppedfromChina'));

//dropped flights with region included for visualization
//OUTPUT(frontierRouteRegion,NAMED('droppedFrontierFlightsbyRegion'));


/* --SouthWest Dropped routes-- */

//All dropped flights
//OUTPUT(SORT(southWestDropped,arrvcity),NAMED('southWestDropped'));

//dropped flights from countries team is focused on (the budget carriers were not operating any flights to these before)
//OUTPUT(SORT(southWestDropped(arrvCountry='Italy'),arrvCountry),NAMED('southWestDroppedfromItaly'));
//OUTPUT(SORT(southWestDropped(arrvCountry='China'),arrvCountry),NAMED('southWestDroppedfromChina'));

//dropped flights with region included for visualization
//OUTPUT(southWestRouteRegion,NAMED('droppedSouthWestFlightsbyRegion'));


/* --Delta Dropped routes-- */

//All dropped flights
//OUTPUT(SORT(deltaDropped,arrvcity),NAMED('deltaDropped'));

//dropped flights from countries team is focused on
//OUTPUT(SORT(deltaDropped(arrvCountry='Italy'),arrvCountry),NAMED('deltaDroppedfromItaly'));
//OUTPUT(SORT(deltaDropped(arrvCountry='China'),arrvCountry),NAMED('deltaDroppedfromChina'));

//dropped flights with region included for visualization
//OUTPUT(deltaRouteRegion,NAMED('droppedDeltaFlightsbyRegion'));

/* --American Airlines Dropped routes-- */

//All dropped flights
//OUTPUT(SORT(aaDropped,arrvcity),NAMED('aaDropped'));

//dropped flights from countries team is focused on
//OUTPUT(SORT(aaDropped(arrvCountry='Italy'),arrvCountry),NAMED('aaDroppedfromItaly'));
//OUTPUT(SORT(aaDropped(arrvCountry='China'),arrvCountry),NAMED('aaDroppedfromChina'));

//dropped flights with region included for visualization
//OUTPUT(aaRouteRegion,NAMED('droppedAmericanAirlinesFlightsbyRegion'));


//flights dropped by both budget carriers analyzed - potential trends of U.S. budget carriers
//OUTPUT(budgetDropped,NAMED('budgetDropped'));

//flights dropped by both major carriers analyzed - potential trends of larger U.S. carriers
//OUTPUT(majorDropped,NAMED('majorDropped'));

//flights dropped by all four carriers analyzed - no matches (diff types of carrier biz models don't compete on many routes?)
//OUTPUT(bothDropped,NAMED('bothDropped'));