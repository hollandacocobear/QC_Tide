close all
clear
clc

% Input definisi 
lokasi='morowali stasiun 3';
folder='../sheet/';
file=['Data Observasi Pasang Surut di ' lokasi '.xlsx'];
sheet='data';

% Input data file dan folder yang digunakan yaitu morowali dengan menggunakan fungsi xlsread
[data,header,~]=xlsread([ folder file ],'data');

tanggal=datenum(data(:,1),data(:,2),data(:,3),data(:,4),data(:,5),data(:,6));
interval=round(tanggal(2)-tanggal(1),4);
fprintf('Interval = %s menit',num2str(round(interval*24*60),0));

% Cek interval
for i=2:length(tanggal)
    cekint(i,1)=round(tanggal(i)-tanggal(i-1),4);
end

% Cari interval yang berbeda dari yang ditentukan
indeks=find(cekint>interval);

% Simpan data sebagai xlsx
judul={'Tanggal Awal (dd/mm/yyyy HH:MM)','Tanggal Akhir (dd/mm/yyyy HH:MM)','Interval (menit)'}; 
xlswrite([folder 'Cek Interval Pasang Surut di ' lokasi '.xlsx'],judul,'Data','A1'); %Simpan header
xlswrite([folder 'Cek Interval Pasang Surut di ' lokasi '.xlsx'],cellstr(datestr(tanggal(indeks-1),'dd/mm/yyyy HH:MM')),'data','A2'); %Simpan taggal
xlswrite([folder 'Cek Interval Pasang Surut di ' lokasi '.xlsx'],cellstr(datestr(tanggal(indeks),'dd/mm/yyyy HH:MM')),'data','B2'); 
xlswrite([folder 'Cek Interval Pasang Surut di ' lokasi '.xlsx'],cekint(indeks)*24*60,'data','C2');

fprintf('Data Sudah Disimpan di Folder %s\r\n',folder)
