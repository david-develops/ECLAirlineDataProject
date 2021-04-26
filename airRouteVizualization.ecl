IMPORT $;
IMPORT airRouteDiscovery;
IMPORT airRouteAnalysis;
IMPORT Visualizer;

/*
	This file is a BWR for visualization
	-all data manipulation happens in the other files
*/

//Label Datasets with easy to use names

//Region Datasets
frontierDroppedByRegion		:= $.airRouteAnalysis.frontierDroppedByRegion;
southWestDroppedByRegion	:= $.airRouteAnalysis.southWestDroppedByRegion;
deltaDroppedByRegion			:= $.airRouteAnalysis.deltaDroppedByRegion;
aaDroppedByRegion					:= $.airRouteAnalysis.aaDroppedByRegion;

//State Datasets
frontierDroppedByState		:= $.airRouteAnalysis.frontierDroppedByState;
southWestDroppedByState		:= $.airRouteAnalysis.southWestDroppedByState;
deltaDroppedByState				:= $.airRouteAnalysis.deltaDroppedByState;
aaDroppedByState					:= $.airRouteAnalysis.aaDroppedByState;

//OUTPUTS for visualization

//Region outputs
OUTPUT(frontierDroppedByRegion,NAMED('FrontierByRegion'));
OUTPUT(southWestDroppedByRegion,NAMED('SouthWestByRegion'));
OUTPUT(deltaDroppedByRegion,NAMED('DeltaByRegion'));
OUTPUT(aaDroppedByRegion,NAMED('AmericanAirlinesByRegion'));

//State outputs
OUTPUT(frontierDroppedByState,NAMED('frontierDroppedByState'));
OUTPUT(southWestDroppedByState,NAMED('southWestDroppedByState'));
OUTPUT(deltaDroppedByState,NAMED('deltaDroppedByState'));
OUTPUT(aaDroppedByState,NAMED('aaDroppedByState'));

//Visualization

//Region Pie Charts
Visualizer.TwoD.Pie('FrontierVizByRegion',,'FrontierByRegion');
Visualizer.TwoD.Pie('SouthWestVizByRegion',,'SouthWestByRegion');
Visualizer.TwoD.Pie('DeltaByRegion',,'DeltaByRegion');
Visualizer.TwoD.Pie('AmericanAirlinesVizByRegion',,'AmericanAirlinesByRegion');

//State maps
Visualizer.Choropleth.USStates('frontierDroppedByState',,'frontierDroppedByState');
Visualizer.Choropleth.USStates('southWestDroppedByState',,'southWestDroppedByState');