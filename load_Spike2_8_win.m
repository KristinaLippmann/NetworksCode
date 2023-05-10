function [rawdata, timesOFint] = load_Spike2_8_win(loadinfo,i)
%file_load_time=tic;
rawdata.filename=[loadinfo{i,1} filesep loadinfo{i,2}];

% add path to CED code
if isempty(getenv('CEDS64ML'))
    setenv('CEDS64ML', [pwd filesep 'spike2.8mat' filesep 'CEDS64ML']);
end
cedpath = getenv('CEDS64ML');
addpath(cedpath);
% load ceds64int.dll
CEDS64LoadLib( cedpath );
% Open a file
file_handle = CEDS64Open(rawdata.filename);

if (file_handle <= 0); unloadlibrary ceds64int; return; end

if ischar(loadinfo{i,3})
chan2load=str2num(loadinfo{i,3});
else    
chan2load=loadinfo{i,3};
end

rawdata.title=[num2str(loadinfo{i,3}) '_' loadinfo{i,4}];

% [ i64Div ] = CEDS64ChanDiv( file_handle, chan2load );
% rawdata.interval = CEDS64TicksToSecs( file_handle, i64Div );



rawdata.interval = 1/CEDS64IdealRate( file_handle, chan2load );

    if ~isempty(loadinfo{i,6})
    [ startP ] = CEDS64SecsToTicks( file_handle, str2num(loadinfo{i,6}) );    
    rawdata.start2cut=str2num(loadinfo{i,6});
    timesOFint=str2num(loadinfo{i,8})-str2num(loadinfo{i,6});
        % stop if defined
        if ~isempty(loadinfo{i,7})
        [ stopP ] = CEDS64SecsToTicks( file_handle, str2num(loadinfo{i,7}) );    
        rawdata.stop2cut=str2num(loadinfo{i,7});
        n2read=stopP-startP;
        else
        stopP=-1;
        n2read=CEDS64MaxTime( file_handle );
        end
    
    else
    [ startP ] = 1;
    timesOFint=str2num(loadinfo{i,8});
    
        % stop if defined
        if ~isempty(loadinfo{i,7})
        [ stopP ] = CEDS64SecsToTicks( file_handle, str2num(loadinfo{i,7}) );    
        rawdata.stop2cut=str2num(loadinfo{i,7});
        n2read=stopP;
        else
        stopP=-1;
        n2read=CEDS64MaxTime( file_handle );
        end
    
    end

% get waveform data from channel 1
[ rawdata.length, rawdata.values, ~ ] = CEDS64ReadWaveF( file_handle, chan2load, n2read, startP, stopP);

[ ~, TimeStamp ] = CEDS64TimeDate( file_handle);
rawdata.experiment_started=[num2str(TimeStamp(4)) ':' num2str(TimeStamp(3))];
rawdata.values=double(rawdata.values);


% close all the files
CEDS64CloseAll();
% unload ceds64int.dll
unloadlibrary ceds64int;

%disp(['time to load file: ' num2str((round(toc(file_load_time)*100))/100) ' s'])

end
