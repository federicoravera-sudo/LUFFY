function [ mu ] = EvaluateDipole( mol,ref)
    
    mu=[0 0 0];
    q = 1.60217662e-19;
    coordinates = [mol.x mol.y  mol.z];
    charges = mol.espCharge;
    
    %loop each atom
    for ii=1:mol.n_atoms
       
        %evaluate dipole factor
        mu = mu + q*mol.espCharge(ii)* 1e-10*[mol.x(ii)-ref(1) mol.y(ii)-ref(2) mol.z(ii)-ref(3)]/ 3.336e-30;
        
    end

    % Calcola i momenti di dipolo individuali
% dipole_moments = coordinates .* charges'.*q.* 1e-10;
% 
% Calcola il momento di dipolo totale
% dipole_total = sum(dipole_moments, 1);
% mu = dipole_total/ 3.336e-30;
%     disp('momentum is in Debye')
end