%-------------------------------------------------------------------------%
%%  This script 'Step1' is intended for analysing SPW-R-complexes
% It is the entry point ('Step1') for selecting the file               
% and creating parameter defaults.                                               
% The script expects an exported *.mat - file you created with spike2! 
% The script stores user inputs on the file in 'MyDat'               
% and on the parameter in 'MyDefPar' and 'MyDatPar'.
% MyDat.*    is a struct that contains the filenname,the path, the group
%            number ('1'), the group label ('single'), and the field name 
%            of the data (e.g., 'V120329_000_Ch1').
% MyDefPar.* is a a struct that contains standard parameters; it is created 
%            by calling 'Step_MyDefPar'.
% MyDatPar.* is a a struct that contains the 3 special parameters
%            MultSD, MultMUAthres, MultRipplethresh, 
%            which are the only parameters to be adjusted for each file.                                 
% Version 1.0 JE, CLI 21-07-2020, email: jens.eilers@medizin.uni-leipzig.de                                       
%-------------------------------------------------------------------------%

%% Block 1, get prepared
% Start by clearing the workspace (keeping any previous MyDatPar & MyDat),
% by closing graphs, and by clearing the command window.

answer = questdlg('This will delete the workspace!',...
                  'Go on?','Yes','No','No');
if isempty(answer)      % The user canceled
    disp('No harm done'); % Reassure the user
    clearvars answer; return
elseif answer ==  "No"  % The user said 'No'
    disp('No harm done'); % Reassure the user
    clearvars answer; return
else                    % "Yes", do it
    close all; clearvars -except MyDatPar MyDat;
    % Keeping 'MyDatPar' & 'MyDat' for today's session
end % 'isempty...'


%% Block 2, create MyDefPar.*, holding the default parameters
%  Done by calling the script 'Step_MyDefPar'.
Step_MyDefPar;

%% Block 3, create MyDatPar.*, holding the three special multipliers
% If not present, create MyDatPar.* from MyDefPar. It holds the 3 special, 
% to-be-adjusted multipliers for SD, ripplethresh, and MUAthres.
% Keep previous values if present, otherwise use defaults from 'MyDefVar'.
if ~exist('MyDatPar', 'var')    
    MyDatPar.MultSD             = MyDefPar.MultSD;
    MyDatPar.MultRipplethresh   = MyDefPar.MultRipplethresh;
    MyDatPar.MultMUAthres       = MyDefPar.MultMUAthres;
end % '~exist...'

%% Block 4, create MyDat.*, holding info on the file to be analysed
% Create MyDat.* (empty if the user canceled). MyPath has a structure that
% is multi-file, multi-folder capable (see Step10). Here, however, we use
% it just for one file. Ask for the file-of-interest.
% For subsequent loadings, we remember the last file & path
if exist('MyDat', 'var')
    if ~isempty(MyDat)
        MyDat = MyDat(1);   % In case we used it for Step10 before...
        [file,path] = uigetfile([MyDat(1).Path MyDat(1).Filename]);
    else
        [file,path] = uigetfile('*.mat');
    end % '~isempty...'
else
        [file,path] = uigetfile('*.mat');
end % 'exist...'

if file==0                   % No file was selected, the user canceled
    MyDat =[];               % Create an empty MyDat
    disp('No file, I stop'); % Inform the user
    clearvars file path;     % Clean up
    return                   % End here
else                         % A file had been selected, store it's info
    MyDat(1).Filename = file ;    % Filename, e.g., '120329_000.mat'
    MyDat(1).Path     = path;     % Path, e.g.
                             % '/Users/walther/Desktop/SPWR_anna_anton/'
    MyDat(1).Group    = 1;        % Group number, here '1'
    MyDat(1).Label    = 'single'; % Group label,  here 'single'
    MyDat(1).Name     = 'name';   % Field name, e.g. 'V120329_000_Ch1'
    
    % Finally, direct call to analysis Step2, which can be repeated 
    % manually,i.e., via 'Step2' from the command window.
    disp('Done 1... Going on with Step2 (analysis)');
    clearvars file path;      % Clean up
    Step2;                    % Pass over to the next script
end  % 'file==0'

% Done, EOF
%-----------------------------------------------------------------------%