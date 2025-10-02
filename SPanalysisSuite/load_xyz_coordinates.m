% Funzione per caricare le coordinate degli atomi da un file .xyz
function coords = load_xyz_coordinates(file_path)
    % Apri il file per la lettura
    fid = fopen(file_path, 'r');
    if fid == -1
        error('Errore nell''apertura del file');
    end
    
    coords = []; % Inizializza la matrice per le coordinate
    first = 0;
    % Leggi il file riga per riga
    while ~feof(fid)
        line = fgetl(fid);
        
        % Verifica se la riga contiene coordinate atomiche
        tokens = strsplit(strtrim(line));
        
        if length(tokens) == 4 % Controlla che ci siano 4 elementi (Atomo, x, y, z)
            if first == 0
                first =1 ;
            else
            x = str2double(tokens{2});
            y = str2double(tokens{3});
            z = str2double(tokens{4});
           
            coords = [coords; x, y, z]; % Aggiunge le coordinate alla matrice
           
            end
        end
    end
    
    fclose(fid); % Chiudi il file
end
