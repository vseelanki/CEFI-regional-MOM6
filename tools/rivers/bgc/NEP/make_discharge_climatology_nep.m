clear all;
addpath /home/cas/matlab_budget_codes/
nc64startup;

syear = 1993;
eyear = 2022;
num_years = eyear-syear+1;
readme = '1993-2022 monthly NEP10k climatology from GLOFAS/Hill (March 7, 2025 from Liz Drenkard), kg m-2 sec-1';

% get grid information
%file_name = ['/archive/cas/Regional_MOM6/NEP10k/glofas_hill_05122023/glofas_hill_dis_runoff_mac_',num2str(syear,'%4u'),'.nc']
file_name = ['/archive/e1n/mom6/NEP/runoff/glofas/nep_10km/glofas_v4_hill_dis_runoff_',num2str(syear,'%4u'),'.nc']
lon = ncread(file_name,'lon');
lat = ncread(file_name,'lat');
nlat = size(lat,2);
nlon = size(lon,1);
area = ncread(file_name,'area');

% holds the runoff climatology
runoff_mc = zeros(nlon,nlat,12);

for yr = syear:eyear
  %file_name = ['/archive/cas/Regional_MOM6/NEP10k/glofas_hill_05122023/glofas_hill_dis_runoff_mac_',num2str(yr,'%4u'),'.nc']
  file_name = ['/archive/e1n/mom6/NEP/runoff/glofas/nep_10km/glofas_v4_hill_dis_runoff_',num2str(yr,'%4u'),'.nc']
  
  time = ncread(file_name,'time');
  ntime = size(time,1);
  
  date = datevec(time+datenum(1950,1,1,0,0,0));
  runoff_days_temp = ncread(file_name,'runoff');
  % files are padded with the first day of the following year, remove
  runoff_days = runoff_days_temp(:,:,1:(ntime-1));
  month = date(1:(ntime-1),2);
  
  for m = 1:12
      aa = find(month == m);
      runoff_temp = runoff_days(:,:,aa);
      runoff_mc(:,:,m) = runoff_mc(:,:,m) + mean(runoff_temp,3)/num_years;
  end
  
  clear runoff_days runoff_days_temp;
  clear runoff_temp aa time date month;
  
end

% modify so that it is time, nlat, nlon
runoff = permute(runoff_mc,[3 2 1]);
area = permute(area,[2 1]);
lon = permute(lon,[2 1]);
lat = permute(lat,[2 1]);

for m = 1:12; temp = squeeze(runoff(m,:,:)); total_runoff(m) = sum(temp(:).*area(:)); end
figure(1); clf; plot(total_runoff); xlabel('month'); ylabel('runoff, kg sec-1');

for m = 1:12;
    figure(2);
    clf
    temp = squeeze(runoff(m,:,:));
    scatter3(lon(:),lat(:),log10(temp(:)),ones(size(temp(:)))*10,log10(temp(:))); view(2); caxis([-3 -1]); colorbar;
    pause
end

save glofas_hill_runoff_monthlyclim_NEP10k_04072025 runoff area lat lon readme;
