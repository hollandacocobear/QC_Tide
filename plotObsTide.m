%plot observation data & save data to spreadsheet file

close all
clear
clc


fdir='../Tide/';
nama='JBI2.mat';
satuan='meter';

data=importdata([fdir,nama]);
lenD=length(data);
kedalaman=[];
dates=[];

%process the data
for i=1:lenD
    tanggal=datenum(data(i).Dates(:,3),data(i).Dates(:,1),data(i).Dates(:,2),...
        data(i).Dates(:,4),data(i).Dates(:,5),data(i).Dates(:,6));
    dates=cat(1,dates,tanggal);
    kedalaman=cat(1,kedalaman,data(i).Depth);
    
   
end
n=length(kedalaman);

%plot data
gambar
plot(dates,kedalaman,'b')
    hold on
grid on
datetick('x','dd/mm/yyyy','keeplimits','keepticks')
HWL=max(kedalaman);
LWL=min(kedalaman);
MTL=mean(kedalaman);
title(['TIDES OBSERVATION DATA STATION ' nama(1:end-4)],'fontsize',24,'fontweight','bold')

plot([dates(1) dates(n,1)],[HWL HWL],'k','linewidth',2)
plot([dates(1) dates(n,1)],[LWL LWL],'r','linewidth',2)
plot([dates(1) dates(n,1)],[MTL MTL],'g','linewidth',2)

legend('Obs Data',['HWL = ' num2str(HWL) ' ' satuan],['LWL = ' num2str(LWL) ' ' satuan],['MSL = ' num2str(MTL) ' ' satuan])
legend ('location','bestoutside')
xlabel('Dates (mm/dd/yyyy')
ylabel(['Water Height (' satuan ')']);
set(gca,'fontsize',14)

%save image
if(~exist('../gambar/','dir'))
    mkdir('../gambar/');
end
F    = getframe(gcf);
imwrite(F.cdata, ['../gambar/TIDES OBSERVATION DATA STATION ' nama(1:end-4) '.tiff'], 'tif')


%save data as excel
if(~exist('../Spreadsheet/','dir'))
    mkdir('../Spreadsheet/');
end
xlswrite(['../Spreadsheet/TIDES OBSERVATION DATA STATION ' nama(1:end-4) '.xlsx'],{'Year','Month','Day','Hour','Minute','Second','Tides Height'},'Data','A1');
xlswrite(['../Spreadsheet/TIDES OBSERVATION DATA STATION ' nama(1:end-4) '.xlsx'],datevec(dates),'Data','A2');
xlswrite(['../Spreadsheet/TIDES OBSERVATION DATA STATION ' nama(1:end-4) '.xlsx'],kedalaman,'Data','G2');





