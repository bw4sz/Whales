This annotated animal movement dataset comes from the Env-DATA Track Annotation Service on Movebank (movebank.org). The environmental data attributes are created and distributed by government and research organizations. For general information on the Env-DATA System, see Dodge et al. (2013) and https://www.movebank.org/node/6607.

Terms of Use: Verify the terms of use for relevant tracking data and environmental datasets prior to presenting or publishing these data. Terms of use for animal movement data in Movebank are defined by the study owners in the License Terms for the study. Terms of use for environmental datasets vary by provider; see below for details.

Contact: support@movebank.org

---------------------------

Annotated data for the following Movebank entities are contained in this file:
Movebank study name: Antarctic Humpback overlap with krill fisheries 
Annotated Animal IDs: 131127, 131130, 131136, 131132, 131133, 131128, 131134, 112692, 112699, 112701, 112703, 112704, 112705, 112737, 112738, 112746, 121207, 121208, 121210, 121211, 121212, 123224, 123231, 123232, 123236, 131141, 131143, 131144, 131146, 131147, 131151, and more ...
Requested on Tue Jul 19 18:11:29 CEST 2016
Access key: 1133643618235885002
Requested by: Ben Weinstein

---------------------------

File attributes

Attributes from the Movebank database (see the Movebank Attribute Dictionary at http://www.movebank.org/node/2381):
Location Lat: latitude in decimal degrees, WGS84 reference system
Location Long: longitude in decimal degrees, WGS84 reference system
Timestamp: the time of the animal location estimates, in UTC
Argos Lon1
Argos Lon2
Argos Lat2
Argos Lat1
Argos Sensor 3
Argos Calcul Freq
Argos Nb Mes
Argos LC
Argos Nb Mes 120
Argos Sensor 2
Argos IQ
Argos Semi Major
Argos Semi Minor
Argos Sensor 4
Argos Orientation
Argos Error Radius
Argos GDOP
Argos Best Level
Argos Pass Duration
Argos Altitude
Argos Sensor 1
Argos NOPC
Argos Valid Location Algorithm
Algorithm Marked Outlier

Locations are the the geographic coordinates of locations along an animal track as estimated by the processed sensor data.

Attributes from annotated environmental data:
Name: OSU Ocean NPP 0.17deg Monthly NPP
Description: Net primary productivity in the ocean; the net rate at which carbon from the atmosphere is taken up by plants. Negative values indicate net carbon release to the atmosphere.
Unit: mgC m^-2 day^-1
No data values: -9999 (provider), NaN (interpolated)
Interpolation: inverse-distance-weighted

Name: ETOPO1 Elevation
Description: Elevation of the land surface over land and the ocean floor over ocean. Over the Antarctic and Greenland ice sheets values indicate the elevation of the top of the ice sheets.
Unit: m amsl
No data values: -32768 (provider), NaN (interpolated)
Interpolation: inverse-distance-weighted

Name: NASA Distance to Coast
Description: The distance to the nearest ocean coastline. Note: Incorrected coastline is found in some fjords of southern Chile and northern Greenland. 1 km uncertainty may lead to 2 km distance being adjacent to the coastline.
Unit: km
No data values: NaN (provider), NaN (interpolated)
Interpolation: inverse-distance-weighted

Name: MODIS Ocean Aqua OceanColor 4km Monthly Daytime SST
Description: Daytime water temperature near the ocean's surface computed from MODIS bands 31 and 32
Unit: deg C
No data values: -1 (provider), NaN (interpolated)
Interpolation: inverse-distance-weighted

Name: MODIS Ocean Aqua OceanColor 4km Monthly Chlorophyll A
Description: Chlorophyll A mass concentration near the surface of the ocean. See Hu et al. (2012) doi:10.1029/2011JC007395.
Unit: mg m^-3
No data values: -32767.0f (provider), NaN (interpolated)
Interpolation: inverse-distance-weighted

---------------------------

Environmental data services

Service: MODIS Ocean/Aqua Mapped OceanColor 4-km Monthly
Provider: NASA
Datum: N/A
Projection: N/A
Spatial granularity: 4.64 km
Spatial range (long x lat): E: 180.0    W: -180.0 x N: 90    S: -90
Temporal granularity: monthly
Temporal range: 2002 to present
Source link: http://oceandata.sci.gsfc.nasa.gov/MODIS-Aqua/Mapped/Monthly/4km
Terms of use: http://oceancolor.gsfc.nasa.gov/cms/citations, http://oceancolor.gsfc.nasa.gov/forum/oceancolor/topic_show.pl?tid=474

Service: NASA Distance to the Nearest Coast
Provider: NASA Ocean Biology Processing Group
Datum: N/A
Projection: N/A
Spatial granularity: 0.04 degrees
Spatial range (long x lat): E: 180.0    W: -180.0 x N: 90    S: -90
Temporal granularity: N/A
Temporal range: N/A
Source link: http://oceancolor.gsfc.nasa.gov/DOCS/DistFromCoast/
Terms of use: none found

Service: ETOPO1 Ice Surface Global Relief Model
Provider: NOAA National Geophysical Data Center
Datum: N/A
Projection: N/A
Spatial granularity: 1 arc-minute
Spatial range (long x lat): E: 180.0    W: -180.0 x N: 90    S: -90
Temporal granularity: N/A
Temporal range: N/A
Source link: http://www.ngdc.noaa.gov/mgg/global/
Terms of use: http://www.ngdc.noaa.gov/mgg/global/

Service: Oregon State Ocean Productivity Reanalysis/MODIS-based 0.17-deg Monthly
Provider: Oregon State University
Datum: N/A
Projection: N/A
Spatial granularity: 1/6 degree
Spatial range (long x lat): E: 180.0    W: -180.0 x N: 90    S: -90
Temporal granularity: monthly
Temporal range: 2002 to 2015
Source link: http://orca.science.oregonstate.edu/data/1x2/monthly/vgpm.r2014.m.chl.m.sst/hdf/
Terms of use: http://orca.science.oregonstate.edu/1080.by.2160.monthly.hdf.vgpm.m.chl.m.sst.php

Dodge, S., Bohrer, G., Weinzierl, R., Davidson, S.C., Kays, R., Douglas, D., Cruz, S., Han, J., Brandes, D., and Wikelski, M., 2013, The Environmental-Data Automated Track Annotation (Env-DATA) System: Linking animal tracks with environmental data: Movement Ecology, v. 1:3. doi:10.1186/2051-3933-1-3.