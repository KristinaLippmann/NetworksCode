%-------------------------------------------------------------------------%
%%  This script 'Step2' is intended for analysing SPW-R-complexes
% This is step 2: it creates #info', 'data', and 'results'.
% It checks for necessary variables,loads the file and starts the analysis,
% checks for a previous analysis stored in the file, and
% plots or does the analysis.
% Version 1.0 JE, CLI 10-07-2020, email: jens.eilers@medizin.uni-leipzig.de
%-------------------------------------------------------------------------%

%% To be done
% Adjust the external functions SPWanaliz_anna_Kristina, rippleMUAfindcalc,
% rippleMUAfindfig, see line 108 ff.

%% Block 1, test for structures, close graphs 
if ~logical(exist('MyDat', 'var')*exist('MyDatPar', 'var')...
           *exist('MyDefPar', 'var'))
    beep; disp('Structures are missing, start with Step1');
    return
elseif isempty('MyDat')
    beep; disp('No file had been selected, start with Step1');
    return
else
    close all; % close all pre-existing graphs
end % '~logical...'

%% Block 2, load data
%  Done by calling the script 'Step_LoadFile'.
[Dat, MyDat]=Step_LoadFile(MyDat,1);
 
%% Block 3, check for a previous analysis
% If it is available, ask whether to use it or not.
DoAnalysis = 1;  % Default behaviour

if isfield(Dat, 'SWR')     % There is a SWR analysis in the loaded data
    sound(sin(1:300));
    LoadMode = questdlg('The file includes a SWR analysis!',...
        'Attention!','Plot it','Reanalyse it','Plot it');
    if isempty(LoadMode)      % The user canceled
        clearvars DoAnalysis LoadMode; return
    end

    % Do the 3 multipliers differ between file and the current session?
    Check =  isequaln(MyDatPar, Dat.SWR.Params.DatPar);

    % For both, plotting and reanalysing:
    if Check
        disp('Multiplicators in file are the same as we currently use.')
    else
        disp('Multiplicators in file differ from those we currently use.')
        fprintf('\tParameter:\t\tSession / file:\n');
        fprintf('\tMultSD\t\t%7g / %g\n', ...
                 MyDatPar.MultSD,...
                 Dat.SWR.Params.DatPar.MultSD);
        fprintf('\tMultMUAthres\t\t%7g / %g\n',...
                 MyDatPar.MultMUAthres,...
                 Dat.SWR.Params.DatPar.MultMUAthres);
        fprintf('\tMulttripplethresh\t%7g / %g\n',...
                MyDatPar.MultRipplethresh,...
                Dat.SWR.Params.DatPar.MultRipplethresh);
    end  % 'Check'        
    
    switch LoadMode
        case 'Plot it'      % Just plot it
            DoAnalysis = 0;
            
            if ~Check % Obtain the 3 previously stored multipliers
                disp('Multiplicators from file were loaded.')
                MyDatPar = Dat.SWR.Params.DatPar;
            end
            
            % Obtain the previous results from the stored information
            info      = Dat.SWR.info;
            %data     = Dat.SWR.data; % omitted for space reasons 
            results   = Dat.SWR.results;
            
        case 'Reanalyse it'       % Analyse it
            if ~Check
                sound(sin(1:300));
                answer = questdlg('Which parameter set should be used!',...
                    'See command window...',...
                    'From file','Current','From file');
                if isempty(answer)      % The user canceled
                    clearvars answer DoAnalysis Check LoadMode;
                    return
                elseif answer ==  "From file"
                    % Obtain the previously stored 3 multipliers
                    MyDatPar = Dat.SWR.Params.DatPar;
                end
            end
    end % switch 'LoadMode'
 end
 clearvars answer Check LoadMode;

%% Block 4, do the analysis if requested / necessary
% ############################ work to be done #####
if DoAnalysis
    % Ask for the 3 special multipliers; the user may cancel
    [MyDatPar, Escape] = SPWR_Ask4AnaParams(MyDatPar);
    if Escape                        % The user canceled
        clearvars DoAnalysis Escape; % Clean up
        return                       % Stop here
    end % 'Escape'
   
    % Send to the BIG SPWR analysis routine, 
     [info, data, results] = SWRs_Jagk20(Dat,MyDefPar,MyDatPar);
end % 'DoAnalysis'
clearvars DoAnalysis Escape;   % Clean up     

%% Block 5, plotting
% ############################ more work  ############
% Plot the results. 
rippleMUAfindfig_2; 
disp('Done 2... Repeat (Step2) or go on with Step3 (saving results)');
return
% Done

%-----------------------------------------------------------------------%
%% Subfunction 1: Ask for 3 special parameters
% This function allows the user to set the parameters of the SPWR analysis.
function [MyDatPar, Escape] = SPWR_Ask4AnaParams(MyDatPar)
% Get prepared to ask for the three multipliers
prompt   = {'SD multiplicator',...
            'Ripplethresh multiplicator'...
            'MUAthres multiplicator'};
dlgtitle =  'Adjust analysis multiplicators';
definput =  {num2str(MyDatPar.MultSD),...
             num2str(MyDatPar.MultRipplethresh)...
             num2str(MyDatPar.MultMUAthres)};

% Do ask
Set = inputdlg(prompt,dlgtitle,[1 60],definput);

% If the user didn't press escape, store the parameters
if isempty(Set)    % The user pressed cancelor closed the dialogue
    Escape = 1;    % We do not touch MyDatPar.* to keep its content
else
    Escape = 0;
    MyDatPar.MultSD             = str2double(Set{1});
    MyDatPar.MultRipplethresh   = str2double(Set{2});
    MyDatPar.MultMUAthres       = str2double(Set{3});
end % 'isempty...'
end
% EOF
