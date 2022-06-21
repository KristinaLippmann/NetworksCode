%-------------------------------------------------------------------------%
%%  This script 'Step10' is intended for analysing SPW-R-complexes
% It is the entry point for selecting a single or multiple folders for a 
% per-group analysis, each containing data from one group.        
% The script expects folder(s) with *.mat - files you created with spike2! 
% The script stores user inputs on the file in 'MyDat', similar to what is              
% done in'Step1'. Here, however, we use it's multi-file capability.
% MyDat.*    is a struct that contains the filennames,                        
%            the paths, the group numbers ('1', '2',...'n'), 
%            the group label (e.g., 'sham', 'SE'),
%            and the name of the data (e.g., 'V120329_000_Ch1').
% Subsequent scripts should test the validity of 'MyDat' by
% testing: "exist ('MyDat') && ~isempty(MyDat)".
% Version 1.0 JE, CLI 21-07-2020, email: jens.eilers@medizin.uni-leipzig.de                                       
%-------------------------------------------------------------------------%

%% Get started
% Let's aks the user on what is to be done:
FolderMode = questdlg('Averaging results:',...
    'SPWR averager','Single folder','Several folders','Single folder');
if isempty(FolderMode)      % The user canceled
    disp('No harm done...');
    clearvars FolderMode;   % Clean up
    return                  % Stop here
end

% If possible, start from the last chosen folder
StdPath='';
if exist('MyDat', 'var')
    if ~isempty(MyDat)
        StdPath = MyDat(1).Path;
    end % '~isempty...'
end % 'exist...'

%% Select a single folder
if FolderMode == "Single folder"
    selpath = uigetdir(StdPath);   % Ask for the folder
    if selpath == 0                % The user did pressed escape
        disp('No harm done...');
        return
    else           % OK, we have a folder, read its *.mat files into myDat
        selpath = append(selpath,'/');
        MyDat = dir(strcat( selpath, '*.mat'));
        if isempty(MyDat) == 1    % No files in this folder
            beep;
            disp(selpath);        % Inform the user
            disp('    has no *.mat files.');
        else
            % Store relevant information in MyDat via Renamer.
            % For this mode (single folder), group = '1', label is 'group'.
             MyDat = Step_Renamer(MyDat, selpath, 1, 'group');
        end % 'isempty...'
    end % 'selpath...'
end % 'Foldermode...'

%% Select several folders
if FolderMode == "Several folders"
    % Get prepared for the loop
    MyDat = [];   
    FolderIndex=0;            % Counter for successfully identified folders
    
    while(1)
        answer = questdlg('Select folder ' + string(FolderIndex+1), ...
            'Group mode', ...
            'Go on','Done','Abort','Go on');
        % Handle response
        if isempty(answer)    % Dialogue was closed
            MyDat = [];       % Indicate that no folder was chosen
            break;
        end
        
        switch answer
            case 'Done'
                break         % Leave the loop
           case 'Abort'
                MyDat = [];   % Indicating that no folder was chosen
                break;
        end % 'answer'
        
        % So the remainder is for 'Go on'
        % Ask for the new folder
        selpath = uigetdir(StdPath);
        if selpath == 0   % The user pressed escape
            MyDat = [];
            break;
        else
            % Read its *.mat files
            selpath = append(selpath,'/');
            StdPath = selpath;
            MyTmp = dir(strcat( selpath, '*.mat'));
            if isempty(MyTmp)    % no files in this folder
                beep;
                disp(selpath);
                disp('    has no *.mat files.');
            else
                FolderIndex = FolderIndex+1;
                Label = SPWR_Ask4GroupLabel(FolderIndex);
                MyTmp = Step_Renamer(MyTmp, selpath, FolderIndex, Label);
  
                % Fill MyDat with MyTmp
                % (works also in the first round with an empty MyDat)
                MyDat = vertcat(MyDat,MyTmp); %#ok<AGROW>
            end % 'isempty...'
        end % 'selpath...'
    end % while
end % 'if Foldermode...'

%% Clean up
clearvars  FolderMode FolderIndex selpath MyTmp answer Label StdPath
if isempty(MyDat)    % No files in this folder
    disp('No harm done');
    clearvars  MyDat; 
else
    disp('Done 10... Going on with Step11 (analysis)');
    Step11;                % Pass over to the next script
end
% Done
%-------------------------------------------------------------------------%

%% SPWR_Ask4GroupLabel
% Asks the user to provide a name, used in the context of  assigning
% a group name to a recently selected folder. 'Index' provides means to
% suggest default names (1='sham', 2='SE') to the user.
function Label = SPWR_Ask4GroupLabel(index)
DefGroupLabels = {'sham';'SE'};   % You may edit/extend this as needed.

if index <= size(DefGroupLabels,1)
    definput = DefGroupLabels(index);
else
    definput = {'John Doe'};  % A name that doesn't really make sense...
end

% Do ask
Label = char(inputdlg('Grouping:','Group label:',[1 50],definput));
% In case the user presses escape
if isempty(Label)
    Label = 'John Doe';
end
% clear up the workspace

end
% Done EOF