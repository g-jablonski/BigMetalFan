addpath('/Users/ginnyjablonski/Desktop/')
addpath('/Users/ginnyjablonski/Documents/GitHub/BigMetalFan/borders')
filename = 'ACSST5Y2020.S0101_data_with_overlays_2022-04-26T171210.csv';
county_pop = readtable(filename);

%% Extract Data from Population Density
NAME=table2array(county_pop(:,2));
pop=table2array(county_pop(:,3));
geoid=table2array(county_pop(:,1));
geoid2=extractAfter(geoid,"0500000US");
geoid3=str2double(geoid2);

%% Extract Data on latitude longitude
filename='uscounties.csv';
uscounty = readtable(filename);
lat = table2array(uscounty(:,5));
lon = table2array(uscounty(:,6));
fips = table2array(uscounty(:,2));

%% elimitating nonmatched fips
matches=ismembertol(geoid3, fips, 0);
countyid=(geoid3(matches));
countyidpop=(pop(matches));
population=NaN(length(countyid), 1);
samesizeid=ismembertol(countyid, fips, 0);
fips2=(fips(samesizeid));

for i=1:height(countyid)
    population(fips2==countyid(i))=countyidpop(i);
end
%% update size of latlon
lat2=(lat(samesizeid));
lon2=(lon(samesizeid));

%% combining data to one array

datapart1 = NaN(length(population), 4);
datapart1(:,1) = countyid;
datapart1(:,2) = lat2;
datapart1(:,3) = lon2;
datapart1(:,4) = population;
%% county area data

%readfile & make array
filename = 'LND01_2.csv';
file = readtable(filename);
county_areas = table2array(file(:,2:3));

%match up areas with populations
areaIND = ismember(countyid,county_areas(:,1));
areasID = countyid(areaIND);
countyIND = ismember(areasID,county_areas(:,1));
countyid2 = county_areas(countyIND,1);
areaID2 = county_areas(countyIND,2);
finalareas=NaN(length(countyid2), 1);
%Full data, geoid, area, pop, lat, lon
for m=1:length(countyid2)
    finalareas(areasID==countyid2(m,1))=areaID2(m,1);
end


datapart2 = NaN(length(countyid2),2);
datapart2(:,1)=areasID;
datapart2(:,2)=finalareas;
%% Combing Population and Area Data
finaldata=NaN(length(datapart2),7);

finaldata(:,1)=datapart1(areaIND,1);
finaldata(:,2)=datapart1(areaIND,2);
finaldata(:,3)=datapart1(areaIND,3);
finaldata(:,4)=datapart1(areaIND,4);
finaldata(:,5)=datapart2(:,2);

for n=1:length(finaldata)
    finaldata(n,6)=(finaldata(n,4))/(finaldata(n,5));
end

for q=1:length(finaldata)
    finaldata(q,7)=log(finaldata(q,6));
end
%% Replace infinite values with NaN

    indinf = find(isinf(finaldata(:,6)) == 1); 
    finaldata(indinf,6) = NaN;
    
    

%% redefine resolution
maxlat = round(max(finaldata(:,2)));
minlat = round(min(finaldata(:,2)));
maxlon = round(max(finaldata(:,3)));
minlon = round(min(finaldata(:,3)));

r_lat = nan(length(finaldata(:,2)),1);
r_lon = nan(length(finaldata(:,3)),1);
for i = 1:length(finaldata(:,2))
    r_lat(i) = 0.5*round(finaldata(i,2)/0.5);
    r_lon(i) = 0.5*round(finaldata(i,3)/0.5);

 %       r_lat(i) = 5*round(lat(i)/5);
 %        r_lon(i) = 5*round(lon(i)/5);
end
coord = horzcat(r_lat,r_lon);

%% %% Unique Lat/Lon
u_coord = unique(coord,'rows','stable');
u_lat = unique(u_coord(:,1),'sorted');
u_lon = unique(u_coord(:,2),'sorted');

avg_pop = nan(length(u_coord),1);
for k = 1:length(u_coord)
    ind = find(coord(:,1) == u_coord(k,1) & coord(:,2) == u_coord(k,2));
    avg = sum(finaldata(ind,7)) / length(ind);
    avg_pop(k) = avg;
end
%avg_windspd = (u_coord(:,2),u_coord(:,1),avg_windspd);
all = horzcat(u_coord,avg_pop);
%% Shaping the Data

gridpop = NaN(length(u_lat)+1, length(u_lon)+1);
gridpop(2:end,1) = u_lat;
gridpop(1,2:end) = u_lon;

for i = 1:length(all)
    latInd = find(gridpop(:,1) == all(i,1));
    lonInd = find(gridpop(1,:) == all(i,2));
    gridpop(latInd,lonInd) = all(i,3);
end

gridpop = gridpop(2:end,2:end);

%% %% Create Map Without Turbine Ports
load coastlines
figure(1); clf
%worldmap([23.5 50], [-127 -65])
usamap conus
% bordersm('continental us','k')
%geoshow(coastlat,coastlon,'Color','k')
plotm(coastlat,coastlon,'k')
%contourfm(u_coord(:,1), u_coord(:,2), avg_windspd,'linecolor','none');
contourfm(u_lat,u_lon,gridpop,'linecolor','none')
bordersm('continental us','k')

%  for j = 1:length(avg_windspd)
%      plotm(u_coord(j,1),u_coord(j,2),'g.','markersize',10)
%  end

%scatterm(u_coord(:,1),u_coord(:,2),15,avg_windspd,'filled')
%scatterm(lat,lon,15,windspd,'filled')

cb = contourcbar("southoutside");

title('Log of Population Density in the Contiguous United States')
%cb.XLabel.String = 'Wind Speed (meters per second)';

%% Load in Turbine Points
filename2 = 'uswtdb_v5_0_20220427.csv';

data = readtable(filename);
data_turb = readtable(filename2);

lat_turb = table2array(data_turb(:,27));
lon_turb = table2array(data_turb(:,26));
%% Map with Turbines
load coastlines
figure(1); clf
usamap conus
plotm(coastlat,coastlon,'k')
contourfm(u_lat,u_lon,gridpop,'linecolor','none')
bordersm('continental us','k')
cb = contourcbar("southoutside");
title('Logarithm of Population Density in the Contiguous United States')
hold on
plotm(lat_turb,lon_turb,'r.','markersize',5)
hold off