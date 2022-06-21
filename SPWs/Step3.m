%-------------------------------------------------------------------------%
%% This script 'Step3' is intended for analysing SPW-R-complexes
% This is step 3: it tests for structures, asks to overwrite any previous
% data, adds all information as a struct, and saves data to file.
% Version 1.0 JE, CLI 21-07-2020, email: jens.eilers@medizin.uni-leipzig.de
%-------------------------------------------------------------------------%

%% Block 1, test for structures
if ~logical(exist('MyDat', 'var')   *exist('MyDatPar', 'var')*...
            exist('MyDefPar', 'var')*exist('Dat', 'var'))
    beep; disp('Structures are missing! start with Step1');
    return
end % '~logical...'

%% Block 2, ask to overwrite any previous analysis
% Check whether a previous SWR analysis is present.
if isfield(Dat, 'SWR')
    sound(sin(1:300));
    answer = questdlg('The file included a SWR analysis. Overwrite it?');
    if answer == "Cancel"   % The user canceled
        clearvars answer;   % Clean up
        return              % Stop here
    end% 'answer...'
    if answer == "No"       % Do not overwrite, so do not store
        sound(sin(1:300)); disp('As requested the file was not saved...');
        clearvars answer;   % We clean up our vars but keep the other ...
        return;             % data in memory. Stop here.
    end % 'answer...'
end % 'isfield...'

%%  Block 3, if requested, do overwrite the file
% The rest is for 'overwrite', otherwise we would have seen a 'return'. 
% Add parameters to Dat.SWR.Params
Dat.SWR.Params.DefPar  = MyDefPar;
Dat.SWR.Params.DatPar  = MyDatPar;
% Add info, results, and data to Dat.SWR
Dat.SWR.info           = info;
Dat.SWR.results        = results;
% Dat.SWR.data         = data;      % We don't store this huge data

% Save everything to the original file. For this, we have to 
% recreate the filename; this must be done via copying the data...
% Copy Dat.* to, e.g., V120329_000_Ch1.
assignin('base',MyDat(1).Name,Dat);     

% Save it:
SaveName    = [MyDat(1).Path MyDat(1).Filename];
save(SaveName,MyDat.Name);           % save copy

% Clean up, MyDatPar & MyDat are kept for any subsequent analysis
clearvars -except MyDatPar MyDat;
disp('Done 3... The file was saved...');
disp('You may work on the next file via Step1...');

% done EOF