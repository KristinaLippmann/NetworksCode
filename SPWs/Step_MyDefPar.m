%-------------------------------------------------------------------------%
%%  This script 'Step_MyDefPar' creates MyDefParams
% MyDefPar is a a struct that contains analysis parameters that must apply
% to all files.
%
% Whenever possible, the unit was added to the name (e.g., 'Binsize_min');
% frequency parameter are in Hz and denoted by a leading F ('Flo', 'Fhi'). 
% Note, however, that some parameters will be used in loops (e.g., 'sBin'),
% for these, different units ('_ms', '_us') would be problematic and,
% therefore, the units were omitted.
%
% Version 1.0 JE, CLI 10-07-2020, email: jens.eilers@medizin.uni-leipzig.de
% 
% Kristina: the MyDefPar. values should replace the corresponding entries
% in SPWanaliz_anna_Kristina. Avoid any numbers 'in the middle' of 
% subfunctions; so use MyDefPar.* as needed.
% Add all other stuff that should remain stable over all files.
%-------------------------------------------------------------------------%

%% General parameters
MyDefPar=[];           % Create/erase = a fresh start

MyDefPar.alpha       =  0.05;   % alpha for stats
MyDefPar.Binsize_min =     2;   % [min], for binning the data into periods
MyDefPar.updown      =     1;   % polarity of the LFP: up 1, down -1, in use
MyDefPar.Deathtime_s = 0.015;   % minimum interval [s] between events 0.015

%% Defaults for the three special multipliers 
MyDefPar.MultSD             =  2.5;   % for SD [detection tresh.]
MyDefPar.MultMUAthres       =    6;   % for MUAs
MyDefPar.MultRipplethresh   =    5;   % for ripples

%% Butterlowpass
% Note that 'MyDefPar.LP_butter.Flo' was 'lpcf'. We use the new name
% to comply with the parameters of all other filters
MyDefPar.LP_butter.Order    =    8;  % order of butterlowpass
MyDefPar.LP_butter.Flo      =   80;  % low-pass frequency, in Hz, in use

%% Timewindows to look for ripples relative to max of LP-filtered signal
MyDefPar.Timewin.Pre_ms     =   100;    % 100 in ms
MyDefPar.Timewin.Post_ms    =   100;    % 100 in ms

%% BP_butter: butterbandpass, in Hz
MyDefPar.BP_butter.Order         =    8;   % order
MyDefPar.BP_butter.Flo           =  120;   % lower f, in Hz
MyDefPar.BP_butter.Fhi           =  300;   % upper f, in Hz

%% MUA_butter: MUA butterbandpass, in Hz
MyDefPar.MUA_butter.Order        =    8;   % order
MyDefPar.MUA_butter.Flo          =  600;   % lower f, in Hz
MyDefPar.MUA_butter.Fhi          = 4000;   % upper f, in Hz

%% Figure 1, ripple peak distance from SWR peak, in s
MyDefPar.ripplePeak2SWRpeak.nBin =    101; % bins for histogram in ms
MyDefPar.ripplePeak2SWRpeak.fBin =    500; % bins for tLoc fit in ms
MyDefPar.ripplePeak2SWRpeak.sBin =   -100; % in ms
MyDefPar.ripplePeak2SWRpeak.eBin =    100; % in ms

%% Figure 2, MUA peak distance from SWR peak, in s
MyDefPar.MUAPeak2SWRpeak.nBin    =    101;
MyDefPar.MUAPeak2SWRpeak.fBin    =    500; % bins for tLoc fit in ms
MyDefPar.MUAPeak2SWRpeak.sBin    =   -100; % in ms
MyDefPar.MUAPeak2SWRpeak.eBin    =    100; % in ms

%% Figure 3, Ripples / SWR
MyDefPar.AllripplesPerAllsw.nBin =    21;
MyDefPar.AllripplesPerAllsw.fBin =   500; % bins for gamfit in ms
MyDefPar.AllripplesPerAllsw.sBin =     0;
MyDefPar.AllripplesPerAllsw.eBin =    20;

%% Figure 4, Units / SWR
MyDefPar.AllMUAPerAllsw.nBin     =    51;
MyDefPar.AllMUAPerAllsw.fBin     =   500; % bins for gamfit in ms
MyDefPar.AllMUAPerAllsw.sBin     =     0;
MyDefPar.AllMUAPerAllsw.eBin     =    50;

%% Figure 5, SWR duration, in ms
MyDefPar.SWRDuration.nBin        =    41;
MyDefPar.SWRDuration.fBin        =   500;  % bins for tLocfit in ms
MyDefPar.SWRDuration.sBin        =     0;  % in ms
MyDefPar.SWRDuration.eBin        =   200;  % in ms
% be aware to take a nBin which gives out a bar at 100 ms for extracting
% the fractions of Durations > 100 ms

%% Figure 6, duration first to last ripple, in ms
MyDefPar.RippleDuration.nBin     =    41;  
MyDefPar.RippleDuration.fBin     =   500;  % bins for LogNormal fit in ms
MyDefPar.RippleDuration.sBin     =     0;  % in ms
MyDefPar.RippleDuration.eBin     =   200;  % in ms

%% Figure 7, duration first to last Unit, in s
MyDefPar.MUADuration.nBin        =    41;
MyDefPar.MUADuration.fBin        =   500;  % bins for LogNormal fit in ms
MyDefPar.MUADuration.sBin        =     0;  % in s
MyDefPar.MUADuration.eBin        =   200;  % in s

disp('Created MyDefPar.* ...');

% Done, EOF
