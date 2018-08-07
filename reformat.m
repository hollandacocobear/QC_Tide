close all
clear
clc


nama='JBI2';
fdir='../JBI-2/';
file='*.TXT';
fout='../Tide/';
fx=dir([fdir file]);

lenF=length(fx);
%txt to struct
for i=1:lenF
    fprintf('Process %s\n',fx(i).name);
    data(i)=vale2struct(fdir,fx(i).name);
    fprintf('%s finish!\n',fx(i).name);
end

%save struct file
if(~exist(fout,'dir'))
    mkdir(fout);
end

save([fout nama '.mat'],'data');
fprintf('file exported to folder %s\n',fout);


