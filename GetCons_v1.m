% ------------------------------------------------------------------------
% Purpose : Check reliability of tidal constituents according to Nyquist
%           rule and Rayleigh criteria. It applies for both original and 
%           aliased tidal frequencies.
%
% Input   : tobs = Observation length   (day)
%           Ts   = Observation sampling (day)
%
% Output  : results are written to a filename defined in 'fout'
%
% Routine : GetFreq
%
%
% Dudy D. Wijaya
% Geodesy Research Group
% Institut Teknologi Bandung - Indonesia
% e-mail: wijaya.dudy@gmail.com
%
% 05-Jul-2018: First crated - DDW
% ------------------------------------------------------------------------
%% 
function tidal=GetCons_v1(tobs,Ts,fout,ctyp)


% read list of tidal constituents
% ------------------------------
load t_constituents


% check possible tidal constituents
% ------------------------------
fid=fopen(fout,'w');
t=clock;
fprintf(fid,'-- file was created on %s %2i:%2i:%2.1f --\r\n',date,t(end-2:end));
fprintf(fid,'\r\n');
fprintf(fid,'Sampling record  : %8.4f (hrs) ~%8.4f (days)\r\n',Ts*24,Ts);
fprintf(fid,'Record length    : %8.4f (days)~%8.4f (yrs)\r\n',tobs,tobs/365.25);
switch ctyp
    case {'major'}
        ju=isnan(const.nshallow) ;
        fprintf(fid,'Constituent type : Major Astronomical\r\n');
    case {'shallow'}
        ju=~isnan(const.nshallow);
        fprintf(fid,'Constituent type : Shallow Water\r\n');
    case {'all'}
        ju=ones(length(const.freq),1);
        fprintf(fid,'Constituent type : Major Astronomical & Shallow Water\r\n');
end

fprintf(fid,'\r\n');fprintf(fid,'\r\n');fprintf(fid,'\r\n');
fprintf(fid,'Table 1. List of possible tidal constituents according to Nyquist rule and Rayleigh criteria.\n');
fprintf(fid,'-------------------------------------------------------------------------------------------------------------------------------------------------\n');
fprintf(fid,'  ID  CONS      T       |  ID  CONS      T      |  ID  CONS      T      |  ID  CONS      T      |  ID  CONS      T      |  ID  CONS      T      |\n');
fprintf(fid,'-------------------------------------------------------------------------------------------------------------------------------------------------\n');

nc=0;
for i=2:146
    x=ju(i) ;
    if x~=0
    [fi,cf]=GetFreq(Ts,const.freq(i)*24);
    tmin=1/fi;
   
     if tmin<tobs
         nc=nc+1;
         %iconst(nc)=i;
         tidal.name(nc,:)=const.name(i,:);
         tidal.freq(nc)=const.freq(i)*24; % Freq is now in cycle/day
         tidal.freqo(nc)=fi;
         tidal.nshallow(nc)=const.nshallow(i);
         tidal.df(nc)=const.df(i);
         tidal.id(nc)=i;
        
         if isnan(const.nshallow(i))
             fprintf(fid,'%4i %s%s %8.2f%s\t|',i,' ',const.name(i,:),tmin,cf);
         else
             fprintf(fid,'%4i %s%s %8.2f%s\t|',i,'*',const.name(i,:),tmin,cf);
         end
         
         if mod(nc,6)==0;fprintf(fid,'\n');end
     end
    end
end


  
 
fprintf(fid,'\n');
fprintf(fid,'-------------------------------------------------------------------------------------------------------------------------------------------------\n');
fprintf(fid,'                                                      ~~~ Number of constituents:%4i ~~~\n',nc);
fprintf(fid,'-------------------------------------------------------------------------------------------------------------------------------------------------\n');
switch ctyp
    case {'major'}
        fprintf(fid,'note: T is period (days), o/a denotes original/aliased frequency\n');
    otherwise
        fprintf(fid,'note: T is period (days), asterisk (*) denotes shallow water, while o/a denotes original/aliased frequency\n');
end            
fprintf(fid,'\n');fprintf(fid,'\n');fprintf(fid,'\n');

fprintf(fid,'Table 2. List of Rayleigh periods for inseparable constituent pairs.\n');
fprintf(fid,'---------------------------------------------------------------------------------------------------------------------\n');
fprintf(fid,'         PAIR                 T     |         PAIR                 T        |         PAIR                 T        |\n');
fprintf(fid,'---------------------------------------------------------------------------------------------------------------------\n');
nn=0;
for i=1:nc
    fi=GetFreq(Ts,tidal.freq(i));
    id=[];
    for j=i+1:nc
        fj=GetFreq(Ts,tidal.freq(j));
        ray=1/abs(fi-fj);
        if ray>tobs
            id=[id ;j ray];
          %  fprintf(fid,'%s %s %6.2f\n',const.name(iconst(j),:),const.name(iconst(j),:),ray);
        end
    end
    if ~isempty(id)
         for k=1:size(id,1)
             nn=nn+1;
            fprintf(fid,'%4i/%s -%4i/%s %14.2f\t|',tidal.id(i),tidal.name(i,:),...
                tidal.id(id(k,1)),tidal.name(id(k,1),:),id(k,2));
            jj=mod(nn,3);
            if jj==0;fprintf(fid,'\n');end
         end
        % if jj~=0; fprintf(fid,'\n');end
    end
end
fprintf(fid,'\n');
fprintf(fid,'---------------------------------------------------------------------------------------------------------------------\n');
fprintf(fid,'\n');fprintf(fid,'\n');  
fprintf(fid,'~~ Dudy D. Wijaya/wijaya.dudy@gmail.com ~~\n');
fclose(fid);       


% Check reliability of tidal constituents
% ---------------------------------------
