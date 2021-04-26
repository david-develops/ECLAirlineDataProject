IMPORT $;
IMPORT airRouteDiscovery;
/*
	This file uses the files 
*/

routeRecord := $.airRouteDiscovery.routeRecord;
	
//import all of the datasets to be used in easier to type & read names

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

	EXPORT	carrierRouteRecord := RECORD
  	      	STRING CarrierTwo;
    	    	routeRecord;
      		END;
	EXPORT budgetDropped := JOIN(frontierDropped,southWestDropped,
                     LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity,
                     TRANSFORM(carrierRouteRecord,
                              SELF 									:= LEFT;
                              SELF 									:= RIGHT;
                              SELF.carrierTwo 			:= RIGHT.carrier;
                              ));
	EXPORT majorDropped	:= JOIN(deltaDropped,aaDropped,
                     LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity,
                     TRANSFORM(carrierRouteRecord,
                              SELF 									:= LEFT;
                              SELF 									:= RIGHT;
                              SELF.carrierTwo 			:= RIGHT.carrier;
                              ));
	EXPORT bothDropped		:= JOIN(budgetDropped,majorDropped,
                     LEFT.dprtCity = RIGHT.dprtCity AND LEFT.arrvCity = RIGHT.arrvCity,
                     TRANSFORM(routeRecord,
                              SELF 									:= LEFT;
                              SELF 									:= RIGHT;
                              ));
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
	//This set of tables organizes the data by state and number of flights to that state for map visualization
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