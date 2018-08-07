%{
reformat valeport text file into matlab struct file


07-Aug-2018 : first created by Hollanda
%}

function [data]=vale2struct(fdir,fname)
clear data
fid=fopen([fdir fname],'r');
data.FileName=fname;
np=0;
while(~feof(fid))
    str=fgetl(fid);
    if ~isempty(str)
        if ~isstrprop(str(1),'digit')
            %firmware
            idTeks=strfind(str,':');
            data.firmware=str(idTeks+1:end);
            %date created
            str=fgetl(fid);
            idTeks=strfind(str,':');
            data.DateCreated=str(idTeks+1:end);
            %BatteryLevel
            str=fgetl(fid);
            idTeks=strfind(str,':');
            data.BatteryLevel=str(idTeks+1:end);
            %SN
            str=fgetl(fid);
            idTeks=strfind(str,':');
            data.SN=str(idTeks+1:end);
            %ID
            str=fgetl(fid);
            idTeks=strfind(str,':');
            data.ID=str(idTeks+1:end);
            %SiteInfo
            str=fgetl(fid);
            idTeks=strfind(str,':');
            data.SiteInfo=str(idTeks+1:end);
            %Calibrated
            str=fgetl(fid);
            idTeks=strfind(str,':');
            data.Calibrated=str(idTeks+1:end);
            %Mode
            str=fgetl(fid);
            idTeks=strfind(str,':');
            data.Mode=str(idTeks+1:end);
            %PressureUnit
            str=fgetl(fid);
            idTeks=strfind(str,':');
            data.PressureUnit=str(idTeks+1:end);
            %OutputFormat
            str=fgetl(fid);
            idTeks=strfind(str,':');
            data.OutputFormat=str(idTeks+1:end);
            %Pressure
            str=fgetl(fid);
            idTeks=strfind(str,':');
            data.Pressure=str(idTeks+1:end);
            %UserPressCal
            str=fgetl(fid);
            idTeks=strfind(str,':');
            data.UserPressCal=str(idTeks+1:end);
            %Gain
            str=fgetl(fid);
            idTeks=strfind(str,':');
            data.Gain=str(idTeks+1:end);
            %Offset
            str=fgetl(fid);
            idTeks=strfind(str,':');
            data.Offset=str(idTeks+1:end);
            %ValePressCal
            str=fgetl(fid);
            idTeks=strfind(str,':');
            data.ValePressCal=str(idTeks+1:end);
            %P0
            str=fgetl(fid);
            idTeks=strfind(str,':');
            data.P0=str(idTeks+1:end);
            %P1
            str=fgetl(fid);
            idTeks=strfind(str,':');
            data.P1=str(idTeks+1:end);
            %P2
            str=fgetl(fid);
            idTeks=strfind(str,':');
            data.P2=str(idTeks+1:end);
            %WindSpeedUnit
            str=fgetl(fid);
            idTeks=strfind(str,':');
            data.WindSpeedUnit=str(idTeks+1:end);
            %AirPressureUnit
            str=fgetl(fid);
            idTeks=strfind(str,':');
            data.AirPressureUnit=str(idTeks+1:end);
            %AirTempUnit
            str=fgetl(fid);
            idTeks=strfind(str,':');
            data.AirTempUnit=str(idTeks+1:end);
            str=fgetl(fid);
            dTeks=strsplit(str,'\t');
            judul=dTeks;
            for b=1:length(judul)
                if(strfind(judul{b},' '))
                    judul(b) = strrep(judul(b), ' ', '_');
                end
            end
            str=fgetl(fid);
        else
            dTeks=strsplit(str,'\t');
            np=np+1;
            for b=1:length(dTeks)
                if b==1
                    s=['data.',char(judul(b)) '{' num2str(np) ',1}=cellstr(''' char(dTeks(b)) ''');'];
                    eval(s);
                else
                    s=['data.',char(judul(b)) '(' num2str(np) ',1)=str2num(''' char(dTeks(b)) ''');'];
                    eval(s);
                end
            end
        end
    end
end
fclose(fid);

clear dTeks fid str idTeks
%change timestamp to Date [mm,dd,yyyy,HH,MM,SS]
n=length(data.Timestamp);
tanggal=zeros(n,6);
for b=1:n
teks=strsplit(char(data.Timestamp{b}));
dates=strsplit(char(teks(1)),'/');
waktu=strsplit(char(teks(2)),':');
tanggal(b,1)=str2double(char(dates(2)));
tanggal(b,2)=str2double(char(dates(1)));
tanggal(b,3)=str2double(char(dates(3)));
tanggal(b,4)=str2double(char(waktu(1)));
tanggal(b,5)=str2double(char(waktu(2)));
tanggal(b,6)=str2double(char(waktu(3)));
end

data.Dates=tanggal;

clear tanggal b n teks dates waktu
