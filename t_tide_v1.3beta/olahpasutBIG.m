clear
clc

data=xlsread('inputPasut.xlsx','input');
bulan=data(:,1);
hari=data(:,2);
tahun=data(:,3);
jam=data(:,4);
menit=data(:,5);
detik=data(:,6);
pasut=data(:,7);
waktu=datenum(tahun(1),bulan(1),hari(1),jam(1),menit(1),detik(1));
times=datenum(tahun,bulan,hari,jam,menit,detik);
[NAME,FREQ,TIDECON,XOUT]=t_tide(pasut,'interval',1/60,'start',waktu,'output','report.txt');
YOUT=t_predic(times,NAME,FREQ,TIDECON,0);