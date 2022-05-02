%% Read in Data

addpath('C:\Users\smano32\OneDrive\Desktop\Envi_Data&Exp\FinalProject_Datasets');
addpath('C:\Users\smano32\OneDrive\Desktop\Envi_Data&Exp\FinalProject_Datasets\wind_capacity');
addpath('C:\Users\smano32\OneDrive\Desktop\Envi_Data&Exp\BigMetalFan\borders');

filename = 'pot_wind_cap_110_current.csv';

data = readtable(filename);

lat = table2array(data(:,3));
lon = table2array(data(:,4));
tot_area = table2array(data(:,6));
area40 = table2array(data(:,10));
ratio40 = (area40./tot_area);

%look at data for wind capacity of 40% or higher because average cap was
%41% (calculated in 2019) for turbines built 2014-2018

%% Filter Data

for i = 1:length(tot_area)
    if area40(i) > tot_area(i)
        ratio40(i) = nan;
    end
%     if ratio40(i) < 0.01
%         ratio40(i) = nan;
%     end
end

%% Create Map 
load coastlines
figure(1); clf
usamap conus
plotm(coastlat,coastlon,'k')
scatterm(lat,lon,10,ratio40,'filled')
bordersm('continental us','k')
cb = contourcbar("southoutside");
cmocean('matter')
title('Percent Area with Wind Capcity Factor 40%+ (Contiguous United States)')
cb.XLabel.String = 'Percent Area';
