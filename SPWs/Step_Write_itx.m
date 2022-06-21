w0 = 0:.1:1;                                 % Test data
w1 = [w0; exp(w0)];                          % Test data

fileID = fopen('exp.itx','w');
fprintf(fileID,'IGOR\n\n');
fprintf(fileID,'WAVES %6s %12s\n','w0','w1');
fprintf(fileID,'BEGIN\n');
fprintf(fileID,'%6.2f %12.8f\n',w1);
fprintf(fileID,'End');
fprintf(fileID,'X Dipslay w1\n');
fclose(fileID);

return




% Window Boxplots() : Graph
% 	PauseUpdate; Silent 1
% 	Display  as "Boxplots"
% 	AppendViolinPlot t1 vs t1_textX0
% 	AppendBoxPlot t1 vs t1_textX0
% 	AppendViolinPlot t2 vs t1_textX0
% 	AppendBoxPlot t2 vs t1_textX0
% 	ModifyGraph margin(bottom)=35
% 	ModifyGraph mode=4
% 	ModifyGraph noLabel(bottom)=2
% 	ModifyGraph lblMargin(left)=12
% 	ModifyGraph standoff=0
% 	ModifyGraph axThick(bottom)=0
% 	ModifyGraph lblLatPos(left)=-2
% 	Label left "\\Z12 Ripple frequency"
% 	SetAxis/A/N=1 left
% 	ModifyViolinPlot trace=t1,MarkerColor=(32125,32125,32125),LineThickness=0
% 	ModifyBoxPlot trace=t1,instance=1,markers={-1,8,8,8,8},showMean,boxColor=(32125,32125,32125)
% 	ModifyBoxPlot trace=t1,instance=1,medianLineColor=(32125,32125,32125),medianMarkerColor=(65535,65535,65535)
% 	ModifyBoxPlot trace=t1,instance=1,whiskerColor=(32125,32125,32125),dataColor=(65535,65535,65535)
% 	ModifyBoxPlot trace=t1,instance=1,outlierColor=(65535,65535,65535),farOutlierColor=(65535,65535,65535)
% 	ModifyBoxPlot trace=t1,instance=1,meanColor=(32125,32125,32125)
% 	ModifyViolinPlot trace=t2,MarkerColor=(0,0,0),LineThickness=0
% 	ModifyBoxPlot trace=t2,instance=1,markers={-1,8,8,8,8},showMean,medianMarkerColor=(65535,65535,65535)
% 	ModifyBoxPlot trace=t2,instance=1,dataColor=(65535,65535,65535),outlierColor=(65535,65535,65535)
% 	ModifyBoxPlot trace=t2,instance=1,farOutlierColor=(65535,65535,65535),meanColor=(0,0,0)
% 	SetDrawLayer UserFront
% 	SetDrawEnv textxjust= 1,textyjust= 1
% 	DrawText 0.241,1.111,"Control\rn=26"
% 	SetDrawEnv textxjust= 1,textyjust= 1
% 	DrawText 0.707,1.111,"SE\rn=19"
% EndMacro