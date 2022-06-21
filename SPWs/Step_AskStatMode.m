%% This is a special function for asking the plot mode of s_ and v_ data.
% The function has the inputs GroupResults, fieldname and type
% We use two subfunction, one for type v_, on for type s_ data
function [Ret]=Step_AskStatMode(GroupResults,FN,Type)
switch Type
    case 'v_'
        Ret=AskStatMode_v(GroupResults,FN);
    case 's_'
        Ret=AskStatMode_s(GroupResults,FN);
end
end

% For v_ we report the ksstastics per group average and aks the user
% whether means or medians are to be used
% Return values are: 'Mean','Median','Skip', or user canceled
function [Ret]=AskStatMode_v(GroupResults,FN)
n       = size(GroupResults,1);    % No. of groups
TL      = strings(2+n+2,1);        % String array for asking the user

% Line 1, the fieldname
TL(1,1) = strcat(FN,':');          

% The 2nd line 
TL(2,1)= 'norm. data (per group) is';                             

% The n middle lines, one per group
for ii=1:n
    myPerc = GroupResults(ii).(FN);
    myPerc = myPerc(1,4);      % not-normal distr.
    myPerc = 1 - myPerc;       % normal distr.
    TL(2+ii,1)= myPerc; %
end

% The second last line, a spacer
TL(2+n+1,1)= ' ';

% The last line
TL(2+n+2,1)= 'Plot as...';  % The last line, the question

% Ask the user
Ret = questdlg(TL,'Decision:','Mean','Median','Skip','Mean');
end % Done

% For s_ we report the ksstastics per group and aks the user
% whether means or medians are to be used. We than ask the same
% for the group avererage. Return values are: 'Skip', user canceled,
%'MeanofMeans, MeanOfMedians,MedianOfMeans,MedianOfMedians'
function [Ret]= AskStatMode_s(GroupResults,FN)
n       = size(GroupResults,1);    % No. of groups
TL      = strings(2+n+2,1);        % String array for asking the user

% Line 1, the fieldname
TL(1,1) = strcat(FN,':');          

% The 2nd line 
TL(2,1)= 'percentage (per group) of norm. data is';

% The n middle lines, one per group
for ii=1:n
    myPerc = GroupResults(ii).(FN);
    myPerc = myPerc(1,16);     % fraction of not-normal distr.
    myPerc = 1 - myPerc;       % fraction of normal distr.
    TL(2+ii,1)= myPerc; %
end

% The second last line, a spacer
TL(2+n+1,1)= ' ';

% The last line
TL(2+n+2,1)= 'Use...';      % The last line, the question

% Ask the user
Ret = questdlg(TL,'Decision:','Mean','Median','Skip','Mean');
if isempty(Ret)    % the user cancelled
    return
end
if strcmp(Ret,'Skip')         % skip
    return
end

% Now we know wheter to use mean or median data per slice
% What about the average per group? We have to ask a 2nd question
TL(1,1) = strcat(Ret,'s:');          

% The 2nd line 
TL(2,1)= 'norm. data (per group) is';                             

% The n middle lines, one per group
for ii=1:n
    myPerc = GroupResults(ii).(FN);
    switch Ret
        case 'Mean'
            myPerc = myPerc(1,4);      % kstest of means
        case 'Median'
            myPerc = myPerc(1,7+4);    % kstest of medians
    end
    myPerc    = 1 - myPerc;       % normal distr.
    TL(2+ii,1) = myPerc; %
end

% The second last line, a spacer
TL(2+n+1,1)= ' ';

% The last line
TL(2+n+2,1)= 'Plot as...';  % The last line, the question

switch Ret
    case 'Mean'
        Ret = questdlg(TL,'Decision:','MeanOfMeans',...
            'MedianOfMeans','Skip','MeanOfMeans');
    case 'Median'
        Ret = questdlg(TL,'Decision:','MeanOfMedians',...
            'MedianOfMedians','Skip','MeanOfMedians');
end

end

% Done, EOF