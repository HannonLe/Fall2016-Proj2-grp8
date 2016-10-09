# Dev log

* 20160929, Gao
    1. Basic framework constructed
        * Navigation tab Page
        * leaflet map
        * background paper
        * css added
    2. Data __"311_Service_Requests_from_2015.csv"__
        * see https://data.cityofnewyork.us/dataset/311-Service-Requests-From-2015/57g5-etyj
        * Latitude and longitude is included in each row of data. Conversion from physical address to geo coordinate is not needed for this dataset.
        * Still some cleaning work needs to be done: text filtering & tagging, NAs.
        * Lots of columns are useful, like datetime, complaint type, descriptor...
    3. Data __"DOB_Complaints_Received.csv"__
        * see https://data.cityofnewyork.us/Housing-Development/DOB-Complaints-Received/eabe-havv

* 20161006, Gao
    1. Added click circle and popup feature to the map tab, along with a few control options, popup icons.
    2. Possible noise data structure:
        * For public noise maker (static), like FDNY, pubs and clubs, subway station, hospital, construction: FLOAT latitude, FLOAT longitude, CHAR name.
        * For a designated point (variable): FLOAT lat, FLOAT long, FLOAT diameter (input), FLOAT noise_lvl (Calculated from 311 complaint data). In addition, all the public noise makers within range pop up.
    3. Idea: Reverse noise representation. Instead of showing the noise condition in a clicked area, we can calculate the noise condition around public noise makers and compare them with each others.

* 20161008, Gao
	1. Got the geodata of contruction, hospital, fire station, pubs/clubs.f
	2. Features to be added: calculate the total/avg #comlaints within a circle.
	3. Features to be added: show the 24h time pattern of total #comlaints within a cricle, put it on the same plot with the that of whole NYC.