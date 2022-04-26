%% Read in Data

addpath('C:\Users\smano32\OneDrive\Desktop\Envi_Data&Exp\FinalProject_Datasets');
addpath('C:\Users\smano32\OneDrive\Desktop\Envi_Data&Exp\FinalProject_Datasets\USGS_wind_turbines');
addpath('C:\Users\smano32\OneDrive\Desktop\Envi_Data&Exp\BigMetalFan\borders');

filename = 'windspeeds_NREL.csv';
filename2 = 'uswtdb_v4_3_20220114.csv';

data = readtable(filename);
data_turb = readtable(filename2);

lat_turb = table2array(data_turb(:,27));
lon_turb = table2array(data_turb(:,26));

lat = table2array(data(:,3));
lon = table2array(data(:,2));
windspd = table2array(data(:,9));

%% Redefine resolution to be 0.50 degrees

maxlat = round(max(lat));
minlat = round(min(lat));
maxlon = round(max(lon));
minlon = round(min(lon));

r_lat = nan(length(lat),1);
r_lon = nan(length(lon),1);
for i = 1:length(lat)
    r_lat(i) = 0.5*round(lat(i)/0.5);
    r_lon(i) = 0.5*round(lon(i)/0.5);

 %       r_lat(i) = 5*round(lat(i)/5);
 %        r_lon(i) = 5*round(lon(i)/5);
end
coord = horzcat(r_lat,r_lon);

% unique coordinates (lat,lon) at 1.00 degree resolution
u_coord = unique(coord,'rows','stable');
u_lat = unique(u_coord(:,1),'sorted');
u_lon = unique(u_coord(:,2),'sorted');

% wind speed at 1.00 degree resolution
avg_windspd = nan(length(u_coord),1);
for k = 1:length(u_coord)
    ind = find(coord(:,1) == u_coord(k,1) & coord(:,2) == u_coord(k,2));
    avg = sum(windspd(ind)) / length(ind);
    avg_windspd(k) = avg;
end
%avg_windspd = (u_coord(:,2),u_coord(:,1),avg_windspd);
all = horzcat(u_coord,avg_windspd);
%% Create Windspeed Grid

windspd_grid = nan(length(u_lon)+1,length(u_lat)+1);
windspd_grid(2:end,1) = u_lon;
windspd_grid(1,2:end) = u_lat;

for i = 1:length(all)
    latInd = find(windspd_grid(1,:) == all(i,1));
    lonInd = find(windspd_grid(:,1) == all(i,2));
    windspd_grid(lonInd,latInd) = all(i,3);
end

windspd_grid = windspd_grid(2:end,2:end);

% for i = 2:length(windspd_grid)
%     windspd_grid(i,i) = avg_windspd(i-1);
% end
% 
% windspd_manip = windspd_grid(2:end,2:end);

%% Create Map 
load coastlines
figure(1); clf
%worldmap([23.5 50], [-127 -65])
usamap conus
% bordersm('continental us','k')
%geoshow(coastlat,coastlon,'Color','k')
plotm(coastlat,coastlon,'k')
%contourfm(u_coord(:,1), u_coord(:,2), avg_windspd,'linecolor','none');
contourfm(u_lat,u_lon,windspd_grid','linecolor','none')
cmocean('-ice')
bordersm('continental us','k')

%  for j = 1:length(avg_windspd)
%      plotm(u_coord(j,1),u_coord(j,2),'g.','markersize',10)
%  end

%scatterm(u_coord(:,1),u_coord(:,2),15,avg_windspd,'filled')
%scatterm(lat,lon,15,windspd,'filled')

cb = contourcbar("southoutside");

title('Modeled Wind Speed - Contiguous United States')
cb.XLabel.String = 'Wind Speed (meters per second)';

%% Create Map of Turbine Locations

figure(1); hold on

plotm(lat_turb,lon_turb,'r.','markersize',5)
hold off
% figure(2)
% usamap conus
% plotm(coastlat,coastlon,'k')
% gb = bubble(lat_turb,lon_turb);
% geolimits([22.00 50.00],[-125 -66])
