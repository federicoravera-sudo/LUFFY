% function [new_Dot1, new_Dot2] = perturbGroups(current_Dot1, current_Dot2,a)
function [new_Dot1, new_Dot2,new_Dot3] = perturbGroups(current_Dot1, current_Dot2,current_Dot3, a)
if a == 1
%     % Copia la matrice dei gruppi attuale
   new_Dot1 = current_Dot1;
   new_Dot2 = current_Dot2;
      new_Dot3 = current_Dot3;
    
%     Seleziona un atomo casuale in ogni gruppo
    atom1_idx = randi(size(new_Dot1, 2));
    atom2_idx = randi(size(new_Dot2, 2));
    
    % Scambia gli atomi tra i gruppi
    temp = new_Dot1(1, atom1_idx);
    new_Dot1(1,atom1_idx) = new_Dot2(1, atom2_idx);
    new_Dot2(1, atom2_idx) = temp;
else
    %     % Copia la matrice dei gruppi attuale
%     toss = rand(1);
%     if toss > 0.5
%    new_Dot1 = current_Dot1;
%    new_Dot2 = current_Dot2;
%       new_Dot3 = current_Dot3;
%     
% %     Seleziona un atomo casuale in ogni gruppo
%     atom1_idx = randi(size(new_Dot1, 2));
%     atom2_idx = randi(size(new_Dot3, 2));
%     
%     % Scambia gli atomi tra i gruppi
%     temp = new_Dot1(1, atom1_idx);
%     new_Dot1(1,atom1_idx) = new_Dot3(1, atom2_idx);
%     new_Dot3(1, atom2_idx) = temp;
%     else
%         
%            new_Dot1 = current_Dot1;
%          new_Dot2 = current_Dot2;
%       new_Dot3 = current_Dot3;
%     
%     Seleziona un atomo casuale in ogni gruppo
%     atom1_idx = randi(size(new_Dot2, 2));
%     atom2_idx = randi(size(new_Dot3, 2));
    
%     % Scambia gli atomi tra i gruppi
%     temp = new_Dot2(1, atom1_idx);
%     new_Dot2(1,atom1_idx) = new_Dot3(1, atom2_idx);
%     new_Dot3(1, atom2_idx) = temp;
% %     % Copia le matrici dei gruppi attuali versione a 3
%     new_Dot1 = current_Dot1;
%     new_Dot2 = current_Dot2;
%     new_Dot3 = current_Dot3;
%     
%     % Seleziona un atomo casuale in ogni gruppo
%     atom1_idx = randi(size(new_Dot1, 2));
%     atom2_idx = randi(size(new_Dot2, 2));
%     atom3_idx = randi(size(new_Dot3, 2));
%     
%     % Scambia gli atomi tra i gruppi
%     % Scambio tra Dot1 e Dot2
%     temp = new_Dot1(1, atom1_idx);
%     new_Dot1(1, atom1_idx) = new_Dot2(1, atom2_idx);
%     new_Dot2(1, atom2_idx) = temp;
%     
%     % Scambio tra Dot1 e Dot3
%     temp = new_Dot1(1, atom1_idx);
%     new_Dot1(1, atom1_idx) = new_Dot3(1, atom3_idx);
%     new_Dot3(1, atom3_idx) = temp;
% 
%     % Scambio tra Dot2 e Dot3 (opzionale)
%     temp = new_Dot2(1, atom2_idx);
%     new_Dot2(1, atom2_idx) = new_Dot3(1, atom3_idx);
%     new_Dot3(1, atom3_idx) = temp;
%  

new_Dot1 = current_Dot1;
new_Dot2 = current_Dot2;
new_Dot3 = current_Dot3;

% Seleziona un atomo casuale in ciascun gruppo
atom1_idx = randi(size(new_Dot1, 2));
atom2_idx = randi(size(new_Dot2, 2));
atom3_idx = randi(size(new_Dot3, 2));

% Seleziona casualmente un gruppo (1 o 2) per lo scambio con il gruppo 3
group_choice = randi([1, 2]);

if group_choice == 1
    % Scambia un atomo tra Dot3 e Dot1
    temp = new_Dot1(1, atom1_idx);
    new_Dot1(1, atom1_idx) = new_Dot3(1, atom3_idx);
    new_Dot3(1, atom3_idx) = temp;
elseif group_choice == 2
    % Scambia un atomo tra Dot3 e Dot2
    temp = new_Dot2(1, atom2_idx);
    new_Dot2(1, atom2_idx) = new_Dot3(1, atom3_idx);
    new_Dot3(1, atom3_idx) = temp;
end
    end
end

% %     % Copia le matrici dei gruppi attuali versione a 3
%     new_Dot1 = current_Dot1;
%     new_Dot2 = current_Dot2;
%     new_Dot3 = current_Dot3;
%     
%     % Seleziona un atomo casuale in ogni gruppo
%     atom1_idx = randi(size(new_Dot1, 2));
%     atom2_idx = randi(size(new_Dot2, 2));
%     atom3_idx = randi(size(new_Dot3, 2));
%     
%     % Scambia gli atomi tra i gruppi
%     % Scambio tra Dot1 e Dot2
%     temp = new_Dot1(1, atom1_idx);
%     new_Dot1(1, atom1_idx) = new_Dot2(1, atom2_idx);
%     new_Dot2(1, atom2_idx) = temp;
    
%     % Scambio tra Dot1 e Dot3
%     temp = new_Dot1(1, atom1_idx);
%     new_Dot1(1, atom1_idx) = new_Dot3(1, atom3_idx);
%     new_Dot3(1, atom3_idx) = temp;
%     
%     % Scambio tra Dot2 e Dot3 (opzionale)
%     temp = new_Dot2(1, atom2_idx);
%     new_Dot2(1, atom2_idx) = new_Dot3(1, atom3_idx);
%     new_Dot3(1, atom3_idx) = temp;