close all
clear
clc

pause(2)
format long

%input file
stasiun='JBI2';

%Posisi Lintang
latitude=-1.03503533;

%WAKTU PREDIKSI (yyyy,mm,dd,HH,MM,SS)
awal=[2018,1,1,0,0,1];
akhir=[2018,12,31,23,59,59];

nama=['TIDES OBSERVATION DATA STATION ' stasiun '.xlsx'];
fdir='../Spreadsheet/';
data=xlsread([fdir nama],'Data');
bulan=data(:,2);
hari=data(:,3);
tahun=data(:,1);
jam=data(:,4);
menit=data(:,5);
detik=data(:,6);
pasut=data(:,7);
msl=mean(pasut);
waktu=datenum(tahun(1),bulan(1),hari(1),jam(1),menit(1),detik(1));
times=datenum(tahun,bulan,hari,jam,menit,detik);
interval=(times(2)-times(1));%in day

%get potential tidal constituent using GetCons
if(~exist('../Report/','dir'))
    mkdir('../Report/');
end
tidal=GetCons_v1(times(end)-times(1),interval,['../Report/Potensial tidal constituent in Station ' stasiun '.txt'],'all');

%{
%tidal harmonic analysis
ctyp='all';
file1=['tjPriok_' ctyp '.dat'];
y=detrend(pasut).*100;
[freqName,amp,pha]=TidHarm(y,times,interval,latitude,ctyp,1);
clear data
data.FreqName=freqName;
data.amplitude=amp;
data.phase=pha;
%save report
fid=fopen(['../Report/Tidal harmonic constituent Station ' stasiun '.txt'],'w');
fprintf(fid,'Tidal Harmonic Constituent based on TidHarm.m\r\n');
fprintf(fid,'Contituent\tAmplitude\tPhase\r\n');
for i=1:length(amp)
fprintf(fid,'%4s \t\t %8.4f \t\t %8.4f\r\n',freqName{i},amp(i),pha(i));
end
fclose(fid);
save('tidal harmonic.mat','data');
%}

%process using T-Tide
[NAME,FREQ,TIDECON,XOUT]=t_tide(pasut,'interval',interval*24,'start',waktu,'latitude',latitude,'output',['../Report/T-tide Report Station ' stasiun '.txt']);
error=abs(pasut-msl-XOUT);
err=sqrt(sum(error'*error)/length(error))*100; %RMSE in cm

%plot
gambar
plot (times,pasut-msl,'b','linewidth',2)

hold on
plot(times,XOUT,'r','linewidth',1.5)
datetick('x','mm/dd/yyyy','keeplimits','keepticks')
xlabel('Dates (mm/dd/yyyy)','fontsize',20);
ylabel('Tidal Height (m)','fontsize',20);
title(upper('Comparison observation data with T-Tide'),'fontsize',24,'fontweight','bold')
grid on
legend('Observation Data','T-Tide Prediction')
legend('location','best')
set(gca,'fontsize',16)
annotation('textbox', [0.15,0.8,0.1,0.1],...
    'String', ['RMSE=' num2str(err,2) ' cm'] , 'backgroundcolor', [1 1 1]);

%save image
if(~exist('../gambar/','dir'))
    mkdir('../gambar/');
end
F    = getframe(gcf);
imwrite(F.cdata, ['../gambar/Comparison observation data Station ' stasiun ' with T-Tide.tiff'], 'tif')

%save excel
%save data as excel
if(~exist('../Spreadsheet/','dir'))
    mkdir('../Spreadsheet/');
end
xlswrite(['../Spreadsheet/Comparison observation data Station ' stasiun ' with T-Tide.xlsx'],{'Year','Month','Day','Hour','Minute','Second','Obs Tides Height','Prediction Tides Height','Residual'},'Data','A1');
xlswrite(['../Spreadsheet/Comparison observation data Station ' stasiun ' with T-Tide.xlsx'],tahun,'Data','A2');
xlswrite(['../Spreadsheet/Comparison observation data Station ' stasiun ' with T-Tide.xlsx'],bulan,'Data','B2');
xlswrite(['../Spreadsheet/Comparison observation data Station ' stasiun ' with T-Tide.xlsx'],hari,'Data','C2');
xlswrite(['../Spreadsheet/Comparison observation data Station ' stasiun ' with T-Tide.xlsx'],jam,'Data','D2');
xlswrite(['../Spreadsheet/Comparison observation data Station ' stasiun ' with T-Tide.xlsx'],menit,'Data','E2');
xlswrite(['../Spreadsheet/Comparison observation data Station ' stasiun ' with T-Tide.xlsx'],detik,'Data','F2');
xlswrite(['../Spreadsheet/Comparison observation data Station ' stasiun ' with T-Tide.xlsx'],pasut,'Data','G2');
xlswrite(['../Spreadsheet/Comparison observation data Station ' stasiun ' with T-Tide.xlsx'],XOUT+msl,'Data','H2');
xlswrite(['../Spreadsheet/Comparison observation data Station ' stasiun ' with T-Tide.xlsx'],error,'Data','I2');

clear amp bulan hari tahun jam menit detik ctype data F err fid file1 pha tidal y waktu

%PREDICTION DATA
awal=datenum(awal);
akhir=datenum(akhir);
predictime=[awal:interval:akhir];

YOUT=t_predic(predictime,NAME,FREQ,TIDECON);
HAT=max(YOUT);
LAT=min(YOUT);
gambar
plot(predictime,YOUT,'k')
hold on
plot([predictime(1) predictime(end)],[HAT HAT],'r','linewidth',2)
plot([predictime(1) predictime(end)],[LAT LAT],'b','linewidth',2)
grid on
datetick('x','mmm')
xlabel('Date')
ylabel ('Tidal Height (m)')
legend('Prediction Tides',['HAT = ' num2str(HAT) ' m'],['LAT = ' num2str(LAT) ' m'])
legend('location','bestoutside')
set(gca,'fontsize',16)
title(upper('Prediction Tide in One Year Using T-Tide'),'fontsize',24,'fontweight','bold')


%save image
F    = getframe(gcf);
imwrite(F.cdata, ['../gambar/Tidal Prediction 1 Year Station ' stasiun ' with T-Tide.tiff'], 'tif')

%save to spreadsheet

xlswrite(['../Spreadsheet/Tidal Prediction 1 Year Station ' stasiun ' with T-Tide.xlsx'],{'Time','Tide Height'},'Sheet1','A1');
xlswrite(['../Spreadsheet/Tidal Prediction 1 Year Station ' stasiun ' with T-Tide.xlsx'],datestr(predictime),'Sheet1','A2');
xlswrite(['../Spreadsheet/Tidal Prediction 1 Year Station ' stasiun ' with T-Tide.xlsx'],YOUT','Sheet1','B2');

