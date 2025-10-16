function generateFile(folder,fileName,fileContent)
%% generate folder and file with content according to unix characters
% Select folder=0 if you don't want to create a folder
if isstring(folder) || ischar(folder)
    if ~exist(folder, 'dir')
        mkdir(folder);
    end
end
    
fid = fopen(fileName,'wt');
contentLines = splitlines(fileContent);
fprintf(fid, '%s\n',contentLines);
fclose(fid);
end

