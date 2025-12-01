function [PCnames,coordinates] = importPCFileTemplate(filename)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
PCTemplateFile = fileread(filename);
OptFile_Lines = regexp(PCTemplateFile,"([A-z]*[0-9])\s+([-|+]?[0-9]+.[0-9]+)\s+([-|+]?[0-9]+.[0-9]+)\s+([-|+]?[0-9]+.[0-9]+)","tokens");

%extract coordinates
rawdata = [OptFile_Lines{:}];
PCnames = rawdata(1:4:end)';
coordinates = [str2num(cell2mat({char(rawdata{2:4:end})})),...
    str2num(cell2mat({char(rawdata{3:4:end})})),...
    str2num(cell2mat({char(rawdata{4:4:end})}))];

end