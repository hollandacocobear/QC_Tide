% ------------------------------------------------------------------------
% Purpose : Check whether or not a tidal's frequency is aliased. If it is
%           aliased, then calculate the corresopnding aliasing frequency
%
% Input   : f  = Original frequency             (cycle/day)
%           Ts = Observation sampling           (day)
%
% Output  : f  = Original/aliasing frequency    (cycle/day)
%
% Routine : --
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

function [f,typ]=GetFreq(Ts,f)


if 2*Ts<1/f  % Nyquist criterion
    typ='o'; % Not-aliased
else
    typ='a'; % Aliased
    c=abs(f*Ts-floor((f*Ts)+0.5));
    f=c/Ts;    % aliasing freq (cyc/day)    
    % wa=2*pi*f;  % angular freq (rad/day)
    % ta=1/fa;    % period (day)
end
end