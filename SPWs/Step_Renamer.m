%-------------------------------------------------------------------------%
%%  This script 'Step_Renamer' ...
% Orders information on files stored in MyTmp; 
% used in the context of storing information on all mat files in a given 
% folder. 'MyTmp' is the result of 'dir' and contains 'selpath' the path 
% of the folder, 'FolderIndex' a counter, and 'Label' the group name.
%
% Version 1.0 JE, CLI 21-07-2020, email: jens.eilers@medizin.uni-leipzig.de
%-------------------------------------------------------------------------%

%% Step_Renamer
function [MyTmp] = Step_Renamer(MyTmp, selpath, FolderIndex, Label)
% Copy 'name' collumn to 'Filename'
[MyTmp.Filename] = MyTmp.name;      % Filename
% add folder, group number and label
[MyTmp.Path]   = deal(selpath);     % Folder
[MyTmp.Group]  = deal(FolderIndex); % Group number
[MyTmp.Label]  = deal(Label);       % Label
[MyTmp.Name]   = deal('n.a.');      % We don't read the real name yet

% Delete all others
MyTmp = rmfield(MyTmp,{'name' 'folder' 'isdir' 'datenum' 'date' 'bytes'});
end
% Done, EOF