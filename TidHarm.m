function [name,amp,pha]=TidHarm(y,t,Ts,lat,ctyp,img)
%{
y = data sea level
t = time
Ts   = Observation sampling (day)
lat  = latitude
ctyp = Constituent type ('major', 'shallow','all')

- 9 Jul 2018  : first crated - DDK
- 18 Jul 2018 : added img option - Hollanda
- 
%}


% Check length of obs. (in MJD-day)
% ------------------------------
tobs=t(end)-t(1);

% Check type of nodal correction
% ------------------------------
ltype='nodal';
if tobs>18.5*365.25;ltype='full';end

% Check reliability of tidal constituents
%output struct file containing const.name, cons.freq
% ---------------------------------------
tidal=GetCons_v1(tobs,Ts,'rayleigh.dat',ctyp);

nc=length(tidal.freq); %jumlah konstituen
name=cellstr(tidal.name);%nama konstituen dijadikan cell

% Accumulate matrices AtY & AtA every epoch
% ------------------------------------------
tob=(t); %number from date
tm=t(1);
%rad=pi/180; %original from DDK
ATY=zeros(2*nc,1);
ATA=zeros(2*nc,2*nc);
%whos ATY ATA
f=ones(nc,1);u=f*0;v=u;
for i=1:size(y,1)
    dt=(t(i)-tm);%
    if i==1
        %nodal correction
        [v,u,f]=t_vuf(ltype,mean(tob),tidal.id,lat) ; % nodal is corrected every epoch
        %v=v*360*rad;u=u*360*rad; %original from DDK
        v=v*2*pi;u=u*2*pi;
    end
    
    for j=1:nc					% CONSTRUCT EPOCH-WISE ROW MATRIX A
        arg=2*pi*tidal.freq(j)*dt+v(j)+u(j); %ori DDK
        A(j)=f(j)*cos(arg);
        A(j+nc)=f(j)*sin(arg);
    end
    
    for j=1:2*nc
        ATY(j)=ATY(j)+A(j)*y(i)	;	% ACCUMULATE ATY EVERY EPOCH
        for k=1:2*nc
            ATA(j,k)=ATA(j,k)+A(j)*A(k)	;% ACCUMULATE ATA EVERY EPOCH
        end
    end
    %clear A
end

% Least square estimation
% -----------------------
Qx=pinv(ATA); %seharusnya inv
X=Qx*ATY;
%X=ATA\ATY;
% Determine amplitude and phase
% -----------------------------
amp=NaN(nc,1);
pha=NaN(nc,1);
for i=1:nc
    amp(i)=sqrt(X(i)^2+X(i+nc)^2);	% AMPLITUDE
    pha(i)=atan2(X(i+nc),X(i));		% PHASE
    %fprintf('%2i %2i %s %8.4f %8.2f %8.2f\n',i,tidal.id(i),tidal.name(i,:),tidal.freq(i),amp(i),pha(i)/rad)
end

%tidal analysis
yp=zeros(size(y,1),1);
for I=1:size(y,1)
    dt=(t(I)-tm);
    %[VN,PF,PU]=nodal(t(I));		% CALCULATE NODAL CORRECTIONS
    %VN=zeros(MAXCON,1);PU=zeros(MAXCON,1);PF=ones(MAXCON,1);
    for J=1:nc					% CONSTRUCT EPOCH-WISE ROW MATRIX A
        Ck=f(J)*amp(J)*cos(pha(J));
        Sk=f(J)*amp(J)*sin(pha(J));
        ARG=2*pi*tidal.freq(J)*dt+v(J)+u(J);
        yp(I)=yp(I)+Ck*cos(ARG)+Sk*sin(ARG);
        %        ARG=WA(J)*dt(I)-pha(J)+VN(J)+PU(J);
        %        yp(I)=yp(I)+PF(J)*amp(J)*cos(ARG);
    end
end



figure('units','normalized','outerposition',[0 0 1 1])
plot(t,y,'-b','linewidth',2);%data observation
hold on
plot(t,yp+mean(y),'--r','linewidth',1.5); %tide prediction
% plot(yp-y,'o-g') %selisih antara prediksi dengan observasi
datetick('x','yyyy/mm/dd','keepticks','keeplimits')
xlabel('Time (yyyy/mm/dd)','fontsize',16,'fontweight','bold')
ylabel('Sea Level (cm)','fontsize',16,'fontweight','bold')
legend ('Observation','Prediction')
legend('location','best')
s=['Tidal Analysis using ' ctyp ' constituents'];
title(upper(s),'fontsize',24,'fontweight','bold')
err=(y-yp);
err=sqrt(sum(err'*err)/length(err)); %RMSE in cm
annotation('textbox', [0.2,0.8,0.1,0.1],...
    'String', ['RMSE=' num2str(err,2) ' cm'],'backgroundcolor',[1 1 1]);

if(img==1)
    %save figure
    [~,~,~] = mkdir('../gambar/');
    p=pwd;
    cd('../gambar/')
    p1=pwd;
    F    = getframe(gcf);
    
    imwrite(F.cdata, [p1 '\' s '.tif'], 'tif')
    cd (p)
end
