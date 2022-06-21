function [Type, Subtype]= Step_MyTypes(FN)
    % We have:
    % v_ represents scalar (i.e., single) values
    % s_ represents statistics (7 parameters)
    % m_ represents kann weg
    % h_ represents histogrammed data
    % e_ represents the corresponding edges
    % a_*_ represents an array with * being either v or s
    Type=""; %#ok<NASGU>
    Subtype="";

    % Get the first character which defines the type of data:
    Type = extractBefore(FN,'_');   
    if ~(length(Type) == 1 && contains('vsmhea',Type))
        disp(append(FN, ' does not comply with our naming rules'));
        return
    end
   
    % In case of a_ or h_ we have to check for the subtype
    % e.g. 'a_s_numberofripples'
    if strcmp(Type,'a') || strcmp(Type,'h')
        Subtype = extractAfter(FN,'_');       % 's_numberofripples'
        Subtype = extractBefore(Subtype,'_'); % 's'
        if ~(length(Subtype) == 1 && contains('vsnrf',Subtype))
            disp(append(FN, ' does not comply with our naming rules'));
           return
        end
    end
    % A long way: we know the type (and if applicable the subtype)
end