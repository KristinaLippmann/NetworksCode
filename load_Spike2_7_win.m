function [rawdata, timesOFint] = load_Spike2_7_win(loadinfo,i)

    rawdata=helfu_ImportSMR([loadinfo{i,1} filesep loadinfo{i,2}],loadinfo{i,3});
    
    % cut the start if necessary
    if ~isempty(loadinfo{i,6})
    rawdata.start2cut=str2num(loadinfo{i,6});
    rawdata.values(1:round(str2num(loadinfo{i,6})/rawdata.interval)-1)=[];
    timesOFint=str2num(loadinfo{i,8})-str2num(loadinfo{i,6});
        % stop if defined
        if ~isempty(loadinfo{i,7})
        rawdata.values(round((str2num(loadinfo{i,7})-str2num(loadinfo{i,6}))/rawdata.interval)+1:end)=[];
        else
        end
    
    else
    timesOFint=str2num(loadinfo{i,8});
    
        if ~isempty(loadinfo{i,7})
        rawdata.values(round((str2num(loadinfo{i,7}))/rawdata.interval)+1:end)=[];
        else
        end
    
    end
    
    rawdata.length=length(rawdata.values);
