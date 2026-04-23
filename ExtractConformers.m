function ExtractConformers(inputFile,outPath,numberofAtoms)

% Leggi tutto il contenuto del file
fileID = fopen(inputFile, 'r');
content = textscan(fileID, '%s', 'Delimiter', '\n');
fclose(fileID);

lines = content{1};


fileCount = 0;
currentFile = [];

% Scorri ogni riga del file
for i = 1:length(lines)
    line = lines{i};
    
   
    if startsWith(line, numberofAtoms) %insert number of atoms
        
        if ~isempty(currentFile)
            fclose(currentFile);
        end
        
        
        fileCount = fileCount + 1;
        outputFileName = sprintf('Conformer%d.xyz', fileCount);
        outputFileName = fullfile(outPath, outputFileName);
        currentFile = fopen(outputFileName, 'w');
    end
    fprintf(currentFile, '%s\n', line);
end
if ~isempty(currentFile)
    fclose(currentFile);
end
end
