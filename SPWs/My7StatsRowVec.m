
%-------------------------------------------------------------------------%
%%  This script 'My7StatsRowVec' is intended for analysing SPW-R-complexes
% Reoorts 7 stat parameters for an array S, returned as a row vector
% Note: you may use x = My7StatsRowVec(S)' to obtain a column vector
% In case S is empty, all stats becoma NaN
% Version 1.0 JE, CLI 22-07-2020, email: jens.eilers@medizin.uni-leipzig.de                                       
%-------------------------------------------------------------------------%
function [Stats]= My7StatsRowVec(S)
    S=S(~isnan(S));
    if isempty(S)
        Stats(1:7) = NaN;
    else
        Stats(1)=mean   (S);    % mean
        Stats(2)=std    (S);    % SD
        Stats(3)=length (S);    % n
        Stats(4)=kstest (S);    % normal. test
        Stats(5)=median (S);    % median
        Stats(6)=prctile(S,25); % Q1
        Stats(7)=prctile(S,75); % Q3
    end
end