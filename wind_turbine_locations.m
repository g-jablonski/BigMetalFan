%% Read in Data

addpath('C:\Users\smano32\OneDrive\Desktop\Envi_Data&Exp\FinalProject_Datasets\USGS_wind_turbines');

filename = 'uswtdb_v4_3_20220114.csv';

data = readtable(filename);

lat = table2array(data(:,27));
lon = table2array(data(:,26));

%% Create Map of Turbine Locations

load coastlines
figure(1); clf
worldmap([23.5 50], [-127 -65])
plotm(coastlat,coastlon,'k')
scatterm(lat,lon,15,'filled')
plotm(lat,lon,'g.','markersize',10)
%cb = contourcbar("southoutside");
%cmocean('balance', 'pivot', 0)
%cmocean('thermal')
title('Wind Turbine Location - Contiguous United States')
%cb.XLabel.String = 'Wind Speed (meters per second)';