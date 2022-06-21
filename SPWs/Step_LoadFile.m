%-------------------------------------------------------------------------%
%%  This script 'Step_LoadFile' loads a matlab file into 'Dat'
% It loads the file described in 'MyDat' and returns the data as 'Dat'
%
% Version 1.0 JE, CLI 21-07-2020, email: jens.eilers@medizin.uni-leipzig.de
%-------------------------------------------------------------------------%

function [Dat, MyDat]=Step_LoadFile(MyDat, ii)
% Get the full filename, including the path - e.g.:
% folder   = '/Users/walther/Desktop/SPWR_anna_anton/', 
% filename = '120329_000.mat', 
% MyFile.FileName = '/Users/walther/Desktop/SPWR_anna_anton/120329_000.mat'
% Also store the fieldname, e.g., 'V120329_000_Ch1'

MyFile.FileName     = [MyDat(ii).Path MyDat(ii).Filename];

% Get the struct's field name, e.g., 'V120329_000_Ch1'
% 'who' reports 2 fields: file and the unpredictable name - in either order
% So we search and destroy 'file'
MyFile.StructName	= who('-file',MyFile.FileName); % 2 fieldnames
idx = strcmp(MyFile.StructName,'file');     % get the index of 'file'
MyFile.StructName(idx) = [];                % Remove that field
MyFile.StructName = char(MyFile.StructName);% Remove {}

% Load the data into Dat.* and reduce to the relevant fieldname
Dat = load(MyFile.FileName);      % Load the original
Dat = Dat.(MyFile.StructName);    % Reduce to the fieldname

% Remember the fieldname, e.g., 'V120329_000_Ch1'
MyDat(ii).Name     = MyFile.StructName;  % Needed for saving the results
end
% Done, EOF
