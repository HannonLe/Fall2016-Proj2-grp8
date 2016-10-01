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
