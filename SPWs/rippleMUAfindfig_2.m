%-----------------------------------------------------------------------%
%%  This script for plotting the histograms of the SPWR analysis
%  Version 1.0 KL, JE @ CLI 07-07-2020                                       
%-----------------------------------------------------------------------%

BarPar=[]; % Start form scratch
%% Parameter definitions
% .x: the element within the struct results, which holds the
%       data to be plotted
% .type: type of plot, only 'bar' so far, maybe other types wil emerge...

%% Figure 1, ripple peak distance from SWR peak
BarPar(1).Title    = 'Ripple peak to SWR peak';
BarPar(1).xlabel   = 'Ripple peak to SWR peak (ms)';
BarPar(1).ylabel   = 'Normalized count';
BarPar(1).yData    = 'h_n_ripplePeak2SWRpeak';
BarPar(1).xData    = 'e_h_ripplePeak2SWRpeak';
BarPar(1).yfit     = 'h_f_ripplePeak2SWRpeak';
BarPar(1).xfit     = 'e_f_ripplePeak2SWRpeak';
BarPar(1).scale    = 'e_s_ripplePeak2SWRpeak';
BarPar(1).cBar     = 'w'; % 'white'
BarPar(1).yLog     =  false;
BarPar(1).type     = 'bar';

%% Figure 2, MUA peak distance from SWR peak
BarPar(2).Title    = 'Unit peak to SWR peak';
BarPar(2).xlabel   = 'Unit peak to SWR peak (ms)';
BarPar(2).ylabel   = 'Normalized count';
BarPar(2).yData    = 'h_n_MUAPeak2SWRpeak';
BarPar(2).xData    = 'e_h_MUAPeak2SWRpeak';
BarPar(2).yfit     = 'h_f_MUAPeak2SWRpeak';
BarPar(2).xfit     = 'e_f_MUAPeak2SWRpeak';
BarPar(2).scale    = 'e_s_MUAPeak2SWRpeak';
BarPar(2).cBar     = 'c'; % 'cyan'
BarPar(2).yLog     =  false;
BarPar(2).type     = 'bar';

%% Figure 3, All Ripples / SWR
BarPar(3).Title    = 'Ripples/SWR';
BarPar(3).xlabel   = 'Number of Ripples/SWR';
BarPar(3).ylabel   = 'Normalized count';
BarPar(3).yData    = 'h_n_AllripplesPerAllsw';
BarPar(3).xData    = 'e_h_AllripplesPerAllsw';
BarPar(3).yfit     = 'h_f_AllripplesPerAllsw';
BarPar(3).xfit     = 'e_f_AllripplesPerAllsw';
BarPar(3).scale    = 'e_s_AllripplesPerAllsw';
BarPar(3).cBar     = 'k'; % black'
BarPar(3).yLog     =  false;
BarPar(3).type     = 'bar';

%% Figure 4, NonZero Ripples / SWR
BarPar(4).Title    = 'NonZero Ripples/SWR';
BarPar(4).xlabel   = 'Number of NonZero Ripples/SWR';
BarPar(4).ylabel   = 'Normalized count';
BarPar(4).yData    = 'h_n_NzRipplesPerNzSW';
BarPar(4).xData    = 'e_h_NzRipplesPerNzSW';
BarPar(4).yfit     = 'h_f_NzRipplesPerNzSW';
BarPar(4).xfit     = 'e_f_AllripplesPerAllsw';
BarPar(4).scale    = 'e_s_AllripplesPerAllsw';
BarPar(4).cBar     = 'w'; % white'
BarPar(4).yLog     =  false;
BarPar(4).type     = 'bar';

%% Figure 5, All Units / SWR
BarPar(5).Title    = 'Units/SWR';
BarPar(5).xlabel   = 'Number of Units/SWR';
BarPar(5).ylabel   = 'Normalized count';
BarPar(5).yData    = 'h_n_AllMUAPerAllsw';
BarPar(5).xData    = 'e_h_AllMUAPerAllsw';
BarPar(5).yfit     = 'h_f_AllMUAPerAllsw';
BarPar(5).xfit     = 'e_f_AllMUAPerAllsw';
BarPar(5).scale    = 'e_s_AllMUAPerAllsw';
BarPar(5).cBar     = 'm'; % 'magenta'
BarPar(5).yLog     =  false;
BarPar(5).type     = 'bar';

%% Figure 6, NonZero Units / SWR
BarPar(6).Title    = 'NonZero Units/SWR';
BarPar(6).xlabel   = 'Number of NonZero Units/SWR';
BarPar(6).ylabel   = 'Normalized count';
BarPar(6).yData    = 'h_n_NzMUAPerNzSW';
BarPar(6).xData    = 'e_h_NzMUAPerNzSW';
BarPar(6).yfit     = 'h_f_NzMUAPerNzSW';
BarPar(6).xfit     = 'e_f_AllMUAPerAllsw';
BarPar(6).scale    = 'e_s_AllMUAPerAllsw';
BarPar(6).cBar     = 'r'; % 'red'
BarPar(6).yLog     =  false;
BarPar(6).type     = 'bar';

%% Figure 7, SWR duration 
BarPar(7).Title    = 'SWR duration';
BarPar(7).xlabel   = 'Duration (ms)';
BarPar(7).ylabel   = 'Normalized count';
BarPar(7).yData    = 'h_n_SWRDuration';
BarPar(7).xData    = 'e_h_SWRDuration';
BarPar(7).yfit     = 'h_f_SWRDuration';
BarPar(7).xfit     = 'e_f_SWRDuration';
BarPar(7).scale    = 'e_s_SWRDuration';
BarPar(7).cBar     = 'c'; % cyan
BarPar(7).yLog     =  false;
BarPar(7).type     = 'bar';

%% Figure 8, duration first to last ripple
BarPar(8).Title    = 'Duration of 1st to last Ripple/SWR';
BarPar(8).xlabel   = 'Duration (ms)';
BarPar(8).ylabel   = 'Normalized count';
BarPar(8).yData    = 'h_n_RippleDuration';
BarPar(8).xData    = 'e_h_RippleDuration';
BarPar(8).yfit     = 'h_f_RippleDuration';
BarPar(8).xfit     = 'e_f_RippleDuration';
BarPar(8).scale    = 'e_s_RippleDuration';
BarPar(8).cBar     = 'b'; % blue
BarPar(8).yLog     =  false;
BarPar(8).type     = 'bar';

%% Figure 9, duration first to last unit
BarPar(9).Title    = 'Duration of 1st to last Unit/SWR';
BarPar(9).xlabel   = 'Duration (ms)';
BarPar(9).ylabel   = 'Normalized count';
BarPar(9).yData    = 'h_n_MUADuration';
BarPar(9).xData    = 'e_h_MUADuration';
BarPar(9).yfit     = 'h_f_MUADuration';
BarPar(9).xfit     = 'e_f_MUADuration';
BarPar(9).scale    = 'e_s_MUADuration';
BarPar(9).cBar     = 'g'; % green
BarPar(9).yLog     =  false;
BarPar(9).type     = 'bar';


%% Figure 10, Number of ripples to SWR duration 
% Attention! SWR duration is not normalized! Does it need to be?
BarPar(10).Title    = 'Number of ripples to SWR duration';
BarPar(10).xlabel   = 'SWR duration (ms)';
BarPar(10).ylabel   = 'Number of ripples';
BarPar(10).yData    = 'm_numberofripples'; 
BarPar(10).xData    = 'm_Duration';
BarPar(10).cBar     = 'og'; % green circles
BarPar(10).yLog     =  false;
BarPar(10).type     = 'scatter';


%% Figure 11, Number of units to SWR duration 
BarPar(11).Title    = 'Number of units to SWR duration';
BarPar(11).xlabel   = 'SWR duration (ms)';
BarPar(11).ylabel   = 'Number of units';
BarPar(11).yData    = 'm_numberofunits'; 
BarPar(11).xData    = 'm_Duration';
BarPar(11).cBar     = 'ok'; % black circles
BarPar(11).yLog     =  false;
BarPar(11).type     = 'scatter';


%% Doing all figures
% (result = data, BarPar = plot parameter, ii= index)
for ii = 1:size(BarPar,2)
    switch BarPar(ii).type
        case 'bar'
            CreateBarPlot(results, BarPar, ii);
        case 'scatter'
            CreateScatterPlot(results, BarPar, ii);
    end
end
clearvars i BarPar;


%% The subfunction for bar graph plots
function CreateBarPlot(results, BarPar, i)
figure;%(i);
yData  = GetNestedFieldname(BarPar(i).yData, results);
xData  = GetNestedFieldname(BarPar(i).xData, results);
bar(xData,yData,'FaceColor',BarPar(i).cBar);
FinalizePlot(BarPar, i)


if ~isempty(BarPar(i).xfit) && ~isempty(BarPar(i).yfit)
    xfit  = GetNestedFieldname(BarPar(i).xfit, results);
    yfit  = GetNestedFieldname(BarPar(i).yfit, results);
    scale = GetNestedFieldname(BarPar(i).scale, results);
    
    % adjust the height of the fit to the height of the bars
    yfit  = yfit .* scale;
    % add the fit to the plot
    hold on;
    plot(xfit,yfit,'y','LineWidth',2);
    hold off;
end
end

%% The subfunction for scatter plots
function CreateScatterPlot(results, BarPar, i)
figure;%(i);
yData  = GetNestedFieldname(BarPar(i).yData, results);
xData  = GetNestedFieldname(BarPar(i).xData, results);

%example: scatter(results.m_Duration,results.m_numberofripples,'og');
scatter(xData,yData,BarPar(i).cBar);
FinalizePlot(BarPar, i)
end

%% A function for accessing nested field names
function [fN]=GetNestedFieldname(Item, results)
fN  = split(Item,".",2);    % 'split'... {'Statistics'} {'Duration'}
fN  = getfield(results, fN{:}); % with 'getfield' solves the issue
end

%% Add legends and titles, make log if required
function FinalizePlot(BarPar, i)
if BarPar(i).yLog
    set(gca,'YScale','log'); %log yscale
end
ylabel(BarPar(i).ylabel);
xlabel(BarPar(i).xlabel);
title(BarPar(i).Title);
end

% Done EOF