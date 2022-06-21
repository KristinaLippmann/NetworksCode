%% ANALYSING SPWs
% Version 1.0 JE/KL, CLI 24-07-2020
% email: jens.eilers@... kristina.lippmann@medizin.uni-leipzig.de
%% Activate the scripts
% 
% In the command window type either
% 
% * "SPWs"   (with Steps.m in your folder) or
% * "addpath ('SPWs')"
% 
% This will add the folder 'SPWs', which contains all relevant scripts, 
% to the search paths.


%% ANALYSING INDIVIDUAL FILES
% Do Steps 1, (2,) 3

%% 'Step1', the starting point
% You will be asked to select the file of interest.
% The strucute 'MyDat' will be cretaed that holds information on the file
% to be loaded. Also, the structures 'MyDefPar' and 'MyDatPar' will be 
% created. They hold the parameters for the analysis (see Step2).

%% 'Step2' will start automatically
% The data will be analysed. You will be asked for the thresholds, which
% will be loaded from / stored in 'MyDatPar'. The analyisis will create
% the structures 'info', 'data' and 'results'.
%
% Results habors 3 char fields (Path,Filename, Name) and one normal scalar
% field (Group). The rest is numeric with prefixes that indicate the type
% of data:
    % v_ represents scalar (i.e., single) values
    % s_ represents statistics 
    %           (7 parameters: mean, SD, n, norm, median, Q1, Q3)
    % m_ represents events
    % h_ represents histogrammed data
    % e_ represents the corresponding edges
    % a_*_ represents an array with * being either v or s
% Inspect the plots. If you want to change the thresholds, restart Step2.
%
% Otherwise proceed to Step3.

%% 'Step3' will save the results
% If the file you loaded did not include a (previous) analysis the results
% you will be saved to the file without further notice.
%
% If the file did include a previous analysis, you will be 
% asked if the results should be overwritten.

%% That's it for individual files
%  
%  

%% GROUP ANALYSIS
% It is assumed that files in one folder belong to one experimental
% condition. Analysis can be performed on a single or on multiple folders.
%
% Do Steps 10, (11,) 12

%% 'Step10', the entry point
% You will be asked whether to work on a single or on several folders.
%
% In any case, you will be asked to select the folder(s).
% In case of several folders you are asked for group labels.
% The variable MyDat will be created, holding infos on all files in all
% selected folders.

%% 'Step11' will start automatically
% It will read all results from all files in the selected folder(s).
% The structures 'AllResults' will be created.

%% 'Step12' to be done (will,at the end, start automatically)
% Sort results, average and output them to 'GroupResults'
% The following averaging is done:
% Remember: 
% Results habors 3 char fields (Path,Filename, Name) and one normal scalar
% field (Group). The rest is numeric with prefixes that indicate the type
% of data:
    % v_ represents scalar (i.e., single) values, 
    % s_ represents statistics  
    %           (7 parameters: mean, SD, n, norm, median, Q1, Q3), 
    % m_ represents events, 
    % h_ represents histogrammed data, 
    % e_ represents the corresponding edges, 
    % a_*_ represents an array with * being either v or s

    % GroupResults will hold the follwing
    % a simple copy of the three chars and of group, all from the 1. slice 

    % for each v_ we get the '7 statistics'
    
    % for each s_ we get the '16 statistics': 7 stats from means, 7 stats
    % from median, probability of kstest=1, and the total number of data

    % m_ will be ignored
    % a_ will be ignored as of this writing
    % e_ will be kept as a simple copy
    % h_ , a row vector of bins, will become a row vector with, per bin,
    % the 7 statistics. First all menas, than all SDs, ...
    
 %EOF