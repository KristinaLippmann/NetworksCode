%-------------------------------------------------------------------------%
%%  This script 'Step11' is intended for analysing SPW-R-complexes
% To be executed follwing 'Step10'. Here we extract all results from the
% files listed in 'MyDat' and store them in the struct 'AllRes'.
% Version 1.0 JE, CLI 22-07-2020, email: jens.eilers@medizin.uni-leipzig.de                                       
%-------------------------------------------------------------------------%

%% Get started
% Let's assure MyDat has some data:
if ~(exist ('MyDat', 'var') && ~isempty('MyDat')) 
   beep;
   disp('MyDat has problems...')
   return % Stop here
end
disp('Importing results from files...')

%% Fill 'AllResults' with results from the files
AllRes   = [];         % Collects the results
HaveDat  = false;      % Flag for first loaded file
StdPar   = [];         % Holds the Pars of the first load
RefFile  = '';         % String of path&name of reference file

% We go through all rows of MyDat
for ii = 1:numel(MyDat)
    % Load file as Dat
    [Dat, MyDat]=Step_LoadFile(MyDat,ii);
    
    % Results weres saved this way:
    % Dat.SWR.results = results;

    % Test for the 'SWR' field
    if ~isfield(Dat,'SWR')
        disp(append('The file ', MyDat(ii).Filename))
        disp(append('   in the folder ', MyDat(ii).Path))
        disp('   harbours no SWR analysis!')
        beep; continue  % next loop round
    end % '~isfield'
    
    if ~HaveDat  % This is the very first data set to be loaded
        StdPar  = Dat.SWR.Params.DefPar;
        HaveDat = true;
        RefFile  = [MyDat(ii).Path MyDat(ii).Filename];
    elseif ~isequal(StdPar, Dat.SWR.Params.DefPar)
        beep;
        disp(append('CAVE: The file ', MyDat(ii).Filename))
        disp(append('   in the folder ', MyDat(ii).Path))
        disp('   harbours different parameters than')
        disp(append('the ref. file ', RefFile))
        [~, Fneq, FonlyS1, FonlyS2] = CompareStructures(StdPar,...
            Dat.SWR.Params.DefPar,0);
        % The next three blocks could create a more userfriendly
        % output... See example for FonlyS1
        if ~isempty(Fneq)
            Fneq               %#ok<NOPTS>
        end
        if ~isempty(FonlyS1)
            FonlyS1            %#ok<NOPTS>
        end
        if ~isempty(FonlyS2)
            FonlyS2            %#ok<NOPTS>
        end
    end % '~HaveDat'
 
    % Collect all relevant results from SWR
    % Start from scratch
    tmpRes=[];
    % Start with the info fromMyDat(ii)
    tmpRes.Filename = MyDat(ii).Filename;  % Filename
    tmpRes.Path     = MyDat(ii).Path;      % Folder
    tmpRes.Label    = MyDat(ii).Label;     % Label
    tmpRes.Group    = MyDat(ii).Group;     % Group
 
    tmpRes = catstruct(tmpRes,Dat.SWR.results);
    
    % append tmpRes to AllRes
    AllRes = vertcat(AllRes,tmpRes); %#ok<*AGROW>
    
    % Inform the user
    disp(append('Imported ',MyDat(ii).Filename,' from ',MyDat(ii).Path))
end % 'for'

%% Clean up
clearvars ii Dat HaveDat tmpRes StdPar RefFile Fneq FonlyS1 FonlyS2
disp('Done 11 ...Going on with Step12 (grouping)');
Step12;                % Pass over to the next script
 
% Done EOF