function timeseries_figure=fig_Timeseries(wavelet_Xaxis, wavelet_Yaxis, waveletdata,... & wavelet
                        Xaxis, Frequency, Power, FWatHM, Area, TAU,... % LFP
                        totalTime_min, wavelet_digits, power_digits,area_digits)
               
                    
%% some definitions and conversion rules before figure is created
scrsz = get(0,'ScreenSize');
height4fig=scrsz(4)*0.8;
width4fig=height4fig/sqrt(2);
left4fig=(scrsz(3)-width4fig)/2;
bottom4fig=scrsz(4)*0.1;
figpos=[left4fig bottom4fig width4fig height4fig];

% Create figure
timeseries_figure = figure('Name','phases of individual experiments',...
    'Color',[0.94 0.94 0.94],...
    'PaperType','A4',...
    'PaperUnits','centimeters',...
    'PaperOrientation','Portrait',...
    'Position', figpos,...
    'Visible','off');

set(timeseries_figure,'PaperPosition', [0 0 get(timeseries_figure,'PaperSize')]);

% conversion factors
A4size_mm=get(timeseries_figure,'PaperSize')*10;
mm2points=0.352777778;

TWELVEpointsA4_mm=12/mm2points;
TWELVEpointsA4_relative=TWELVEpointsA4_mm/A4size_mm(2);

TENpointsA4_mm=10/mm2points;
TENpointsA4_relative=TENpointsA4_mm/A4size_mm(2);

EIGHTpointsA4_mm=8/mm2points;
EIGHTpointsA4_relative=EIGHTpointsA4_mm/A4size_mm(2);


%% Create wavelet axes
if ~isempty(waveletdata)

wavelet_axes = axes('Parent',timeseries_figure,'XMinorTick','on','TickDir','out',...
    'TickLength',[0.01 0.001],...
    'Position',[0.075 0.875 0.85 0.1],...    &'Layer','top',...
    'FontUnits','normalized',...
    'FontName','Arial',...
    'FontSize',TENpointsA4_relative,...
    'FontName','Arial');

MATversion=version;
if ((str2double(MATversion(end-5:end-2))-2014) + (~strcmp(MATversion(end-1),'a')))>0
colormap(wavelet_axes,parula)
else
load('parula_map');
colormap(wavelet_axes,parula_map)
end

xlim(wavelet_axes,[0 totalTime_min]);
ylim(wavelet_axes,[0.5 max(wavelet_Yaxis)]);
hold(wavelet_axes,'all');

% Create image
image(wavelet_Xaxis, wavelet_Yaxis, waveletdata,'Parent',wavelet_axes,'CDataMapping','scaled');
caxis([0, prctile(prctile(waveletdata,99,1),99,2)])

% Create ylabel
text('String','Frequency [HZ]',...
    'Parent',wavelet_axes,...
    'Units', 'normalized',...
    'Position',[-0.055 0.5 0],...
    'HorizontalAlignment','center',...
    'VerticalAlignment','bottom',...
    'FontUnits','normalized',...
    'FontName','Arial',...
    'FontWeight','bold',...
    'FontSize',TENpointsA4_relative,...
    'rotation',90,...
    'Color',[0.15 0.15 0.15]);

% Create xlabel
xlabel('time [min]',...
    'Units', 'normalized',...
    'Position',[0.5 -0.225 0],...
    'HorizontalAlignment','center',...
    'VerticalAlignment','top',...
    'FontUnits','normalized',...
    'FontName','Arial',...
    'FontWeight','bold',...
    'FontSize',TENpointsA4_relative,...
    'Color',[0.15 0.15 0.15]);

% Create title
title('Morlet wavelet spectrum',...
    'Units', 'normalized',...
    'Position',[0.5 1.025 0],...
    'HorizontalAlignment','center',...
    'VerticalAlignment','bottom',...
    'FontUnits','normalized',...
    'FontWeight','bold',...
    'FontName','Arial',...
    'FontSize',TWELVEpointsA4_relative,...
    'Color',[0.15 0.15 0.15]);

% Create colorbar
c = colorbar('peer',wavelet_axes,...
    'Units', 'normalized',...
    'Position',[0.93 0.875 0.01 0.1],...
    'FontName','Arial',...
    'Color',[0.15 0.15 0.15]);

if isfield(get(c),'FontUnits')

set(c, 'FontUnits','normalized',...
       'FontSize',EIGHTpointsA4_relative)

oldlabels=get(c,'YTick');
newlabels=oldlabels*10^wavelet_digits;
newlabels=num2str(newlabels');
set(c,'YTickLabel',newlabels)
set(c,'YTickMode','manual')
clear oldlabels newlabels
else
oldlabels=get(c,'Ticks');
newlabels=oldlabels*10^wavelet_digits;
newlabels=num2str(newlabels');
set(c,'TickLabels',newlabels)
set(c,'YTickMode','manual')
clear oldlabels newlabels
end

% Create ylabel
str = sprintf('Power [mV^{%.3g}] x 10^{%.3g}',2,wavelet_digits*-1);
ylabel(c,str,...
    'Units','normalized',...
    'Position',[2.5 0.5 0],...
    'HorizontalAlignment','center',...
    'VerticalAlignment','top',...
    'FontUnits','normalized',...
    'FontName','Arial',...
    'FontWeight','bold',....
    'FontSize',EIGHTpointsA4_relative,...
    'rotation',90,...
    'Color',[0.15 0.15 0.15]);
clear str
end
%% Create Frequency@peak axes
if ~isempty(Frequency)

Frequency_axes = axes('Parent',timeseries_figure,'XMinorTick','on','TickDir','out',...
    'TickLength',[0.01 0.001],...
    'Position',[0.075 0.71 0.85 0.1],...
    'FontUnits','normalized',...
    'FontSize',TENpointsA4_relative,...
    'FontName','Arial',...
    'xlim',[0 totalTime_min],...
    'ylim',[0 nanmax(Frequency)]);
hold(Frequency_axes,'all');

plot(Xaxis,Frequency,'LineWidth',1,'LineStyle','none','MarkerSize',2.5,'Marker','o',...
                'MarkerFaceColor',[0.85 0.85 0.75],...
                'MarkerEdgeColor',[0.333 0.333 0.333],...
                'Parent',Frequency_axes)

% Create ylabel
text('String','Frequency [HZ]',...
    'Parent',Frequency_axes,...
    'Units', 'normalized',...
    'Position',[-0.055 0.5 0],...
    'HorizontalAlignment','center',...
    'VerticalAlignment','bottom',...
    'FontUnits','normalized',...
    'FontName','Arial',...
    'FontWeight','bold',...
    'FontSize',TENpointsA4_relative,...
    'rotation',90,...
    'Color',[0.15 0.15 0.15]);

% Create xlabel
xlabel('time [min]',...
    'Units', 'normalized',...
    'Position',[0.5 -0.225 0],...
    'HorizontalAlignment','center',...
    'VerticalAlignment','top',...
    'FontUnits','normalized',...
    'FontName','Arial',...
    'FontWeight','bold',...
    'FontSize',TENpointsA4_relative,...
    'Color',[0.15 0.15 0.15]);

% Create title
title('Frequency @ peak of PSD',...
    'Units', 'normalized',...
    'Position',[0.5 1.025 0],...
    'HorizontalAlignment','center',...
    'VerticalAlignment','bottom',...
    'FontUnits','normalized',...
    'FontName','Arial',...
    'FontWeight','bold',...
    'FontSize',TWELVEpointsA4_relative,...
    'Color',[0.15 0.15 0.15]);
end

%% Create Power@peak axes
if ~isempty(Power)
    
Power_axes = axes('Parent',timeseries_figure,'XMinorTick','on','TickDir','out',...
    'TickLength',[0.01 0.001],...
    'Position',[0.075 0.545 0.85 0.1],...
    'FontUnits','normalized',...
    'FontSize',TENpointsA4_relative,...
    'FontName','Arial',...
    'xlim',[0 totalTime_min],...
    'ylim',[0 nanmax(Power)]);
hold(Power_axes,'all');

plot(Xaxis,Power,'LineWidth',1,'LineStyle','none','MarkerSize',2.5,'Marker','o',...
                'MarkerFaceColor',[0.85 0.85 0.75],...
                'MarkerEdgeColor',[0.333 0.333 0.333],...
                'Parent',Power_axes)

oldlabels=get(Power_axes,'YTick');
newlabels=oldlabels*10^power_digits;
newlabels=num2str(newlabels');
set(Power_axes,'YTickLabel',newlabels)
set(Power_axes,'YTickMode','manual')
clear oldlabels newlabels

% Create ylabel
str = sprintf('Power [mV^{%.3g}/Hz] x 10^{%.3g}',2,power_digits*-1);
text('String',str,...
    'Parent',Power_axes,...
    'Units', 'normalized',...
    'Position',[-0.055 0.5 0],...
    'HorizontalAlignment','center',...
    'VerticalAlignment','bottom',...
    'FontUnits','normalized',...
    'FontName','Arial',...
    'FontWeight','bold',...
    'FontSize',TENpointsA4_relative,...
    'rotation',90,...
    'Color',[0.15 0.15 0.15]);

% Create xlabel
xlabel('time [min]',...
    'Units', 'normalized',...
    'Position',[0.5 -0.225 0],...
    'HorizontalAlignment','center',...
    'VerticalAlignment','top',...
    'FontUnits','normalized',...
    'FontName','Arial',...
    'FontWeight','bold',...
    'FontSize',TENpointsA4_relative,...
    'Color',[0.15 0.15 0.15]);

% Create title
title('Power @ peak of PSD',...
    'Units', 'normalized',...
    'Position',[0.5 1.025 0],...
    'HorizontalAlignment','center',...
    'VerticalAlignment','bottom',...
    'FontUnits','normalized',...
    'FontName','Arial',...
    'FontWeight','bold',...
    'FontSize',TWELVEpointsA4_relative,...
    'Color',[0.15 0.15 0.15]);

end

%% Create fullWidth@halfMax axes
if ~isempty(FWatHM)

if isnan(nanmax(FWatHM))
    FWatHM_max=1;
else
    FWatHM_max=nanmax(FWatHM);
end


FWatHM_axes = axes('Parent',timeseries_figure,'XMinorTick','on','TickDir','out',...
    'TickLength',[0.01 0.001],...
    'Position',[0.075 0.38 0.85 0.1],...
    'FontUnits','normalized',...
    'FontSize',TENpointsA4_relative,...
    'FontName','Arial',...
    'xlim',[0 totalTime_min],...
    'ylim',[0 FWatHM_max]);
hold(FWatHM_axes,'all');

plot(Xaxis,FWatHM,'LineWidth',1,'LineStyle','none','MarkerSize',2.5,'Marker','o',...
                'MarkerFaceColor',[0.85 0.85 0.75],...
                'MarkerEdgeColor',[0.333 0.333 0.333],...
                'Parent',FWatHM_axes)

% Create ylabel
text('String','delta [HZ]',...
    'Parent',FWatHM_axes,...
    'Units', 'normalized',...
    'Position',[-0.055 0.5 0],...
    'HorizontalAlignment','center',...
    'VerticalAlignment','bottom',...
    'FontUnits','normalized',...
    'FontName','Arial',...
    'FontWeight','bold',...
    'FontSize',TENpointsA4_relative,...
    'rotation',90,...
    'Color',[0.15 0.15 0.15]);

% Create xlabel
xlabel('time [min]',...
    'Units', 'normalized',...
    'Position',[0.5 -0.225 0],...
    'HorizontalAlignment','center',...
    'VerticalAlignment','top',...
    'FontUnits','normalized',...
    'FontName','Arial',...
    'FontWeight','bold',...
    'FontSize',TENpointsA4_relative,...
    'Color',[0.15 0.15 0.15]);

% Create title
title('full Width @ half Max',...
    'Units', 'normalized',...
    'Position',[0.5 1.025 0],...
    'HorizontalAlignment','center',...
    'VerticalAlignment','bottom',...
    'FontUnits','normalized',...
    'FontName','Arial',...
    'FontWeight','bold',...
    'FontSize',TWELVEpointsA4_relative,...
    'Color',[0.15 0.15 0.15]);
end
%% Create fullWidth@halfMax axes
if ~isempty(Area)
    
if isnan(nanmax(Area))
    Area_max=1;
else
    Area_max=nanmax(Area);
end

AreaAThalfMax_axes = axes('Parent',timeseries_figure,'XMinorTick','on','TickDir','out',...
    'TickLength',[0.01 0.001],...
    'Position',[0.075 0.215 0.85 0.1],...
    'FontUnits','normalized',...
    'FontSize',TENpointsA4_relative,...
    'FontName','Arial',...
    'xlim',[0 totalTime_min],...
    'ylim',[0 nanmax(Area_max)]);

hold(AreaAThalfMax_axes,'all');

plot(Xaxis,Area,'LineWidth',1,'LineStyle','none','MarkerSize',2.5,'Marker','o',...
                'MarkerFaceColor',[0.85 0.85 0.75],...
                'MarkerEdgeColor',[0.333 0.333 0.333],...
                'Parent',AreaAThalfMax_axes)

oldlabels=get(AreaAThalfMax_axes,'YTick');
newlabels=oldlabels*10^area_digits;
newlabels=num2str(newlabels');
set(AreaAThalfMax_axes,'YTickLabel',newlabels)
set(AreaAThalfMax_axes,'YTickMode','manual')
clear oldlabels newlabels

% Create ylabel
str = sprintf('Area [Hz^{%.3g}] x 10^{%.3g}',2,area_digits*-1);
text('String',str,...
    'Parent',AreaAThalfMax_axes,...
    'Units', 'normalized',...
    'Position',[-0.055 0.5 0],...
    'HorizontalAlignment','center',...
    'VerticalAlignment','bottom',...
    'FontUnits','normalized',...
    'FontName','Arial',...
    'FontWeight','bold',...
    'FontSize',TENpointsA4_relative,...
    'rotation',90,...
    'Color',[0.15 0.15 0.15]);

% Create xlabel
xlabel('time [min]',...
    'Units', 'normalized',...
    'Position',[0.5 -0.225 0],...
    'HorizontalAlignment','center',...
    'VerticalAlignment','top',...
    'FontUnits','normalized',...
    'FontName','Arial',...
    'FontWeight','bold',...
    'FontSize',TENpointsA4_relative,...
    'Color',[0.15 0.15 0.15]);

% Create title
title('Area @ half Max',...
    'Units', 'normalized',...
    'Position',[0.5 1.025 0],...
    'HorizontalAlignment','center',...
    'VerticalAlignment','bottom',...
    'FontUnits','normalized',...
    'FontName','Arial',...
    'FontWeight','bold',...
    'FontSize',TWELVEpointsA4_relative,...
    'Color',[0.15 0.15 0.15]);

end
%% Create TAU axes
if ~isempty(TAU)
    
YLIM=nanmax(TAU);
if isnan(YLIM)
    YLIM=1;
end

Tau_axes = axes('Parent',timeseries_figure,'XMinorTick','on','TickDir','out',...
    'TickLength',[0.01 0.001],...
    'Position',[0.075 0.05 0.85 0.1],...
    'FontUnits','normalized',...
    'FontSize',TENpointsA4_relative,...
    'FontName','Arial',...
    'xlim',[0 totalTime_min],...
    'ylim',[0 YLIM]);
hold(Tau_axes,'all');

plot(Xaxis,TAU,'LineWidth',1,'LineStyle','none','MarkerSize',2.5,'Marker','o',...
                'MarkerFaceColor',[0.85 0.85 0.75],...
                'MarkerEdgeColor',[0.333 0.333 0.333],...
                'Parent',Tau_axes)

% Create ylabel
text('String','TAU',...
    'Parent',Tau_axes,...
    'Units', 'normalized',...
    'Position',[-0.055 0.5 0],...
    'HorizontalAlignment','center',...
    'VerticalAlignment','bottom',...
    'FontUnits','normalized',...
    'FontName','Arial',...
    'FontWeight','bold',...
    'FontSize',TENpointsA4_relative,...
    'rotation',90,...
    'Color',[0.15 0.15 0.15]);

% Create xlabel
xlabel('time [min]',...
    'Units', 'normalized',...
    'Position',[0.5 -0.225 0],...
    'HorizontalAlignment','center',...
    'VerticalAlignment','top',...
    'FontUnits','normalized',...
    'FontName','Arial',...
    'FontWeight','bold',...
    'FontSize',TENpointsA4_relative,...
    'Color',[0.15 0.15 0.15]);

% Create title
title('TAU',...
    'Units', 'normalized',...
    'Position',[0.5 1.025 0],...
    'HorizontalAlignment','center',...
    'VerticalAlignment','bottom',...
    'FontUnits','normalized',...
    'FontName','Arial',...
    'FontWeight','bold',...
    'FontSize',TWELVEpointsA4_relative,...
    'Color',[0.15 0.15 0.15]);
end