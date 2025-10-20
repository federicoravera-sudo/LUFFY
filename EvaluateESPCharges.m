function [ mol ] = EvaluateESPCharges(fileID,n_points_esp,distance,aggregated,molecule_name)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if ~exist('distance','var') 
    distance = [3 10];
end
if ~exist('aggregated','var') 
    aggregated = 0;
    molecule_name = 'deca';
end
%available names: deca, deca_cell, butane, notbisf, butane_cell

%ESP parameters
min_distance = distance(1); 
max_distance = distance(2); 

%import and display molecule
mol=importFromGamess(fileID,0);
figure(100)
Display_Molecule(mol,1:mol.n_atoms);

%import values for the potential
[coord,V] = importPotGamess(fileID,n_points_esp);
% Display_Molecule(driver,[1 2]);

%switch points to eliminate too close points
good_points=0;
for ii=1:length(coord)
    %assume far enough but not close enough
    is_far_enough = 1;
    is_close_enough = 0;
    
    %check distance
    for jj=1:mol.n_atoms
        x_distance_ii_jj_sq = (coord(ii,1) - mol.x(jj))^2;
        y_distance_ii_jj_sq = (coord(ii,2) - mol.y(jj))^2;
        z_distance_ii_jj_sq = (coord(ii,3) - mol.z(jj))^2;
        distance_ii_jj =  sqrt(x_distance_ii_jj_sq + y_distance_ii_jj_sq + z_distance_ii_jj_sq);
        
        if (distance_ii_jj < min_distance)
            is_far_enough = 0;
            break;
        end
        if (distance_ii_jj < max_distance)
            is_close_enough = 1;
        end
    end
    
    %if valid, copy
    if (is_far_enough && is_close_enough)==1
        good_points=good_points+1;
        good_coord(good_points,:) = coord(ii,:);
        good_V(good_points) = V(ii);
    end
end

%display potential points
scatter3(good_coord(:,1),good_coord(:,2),good_coord(:,3),'.k')

% plane = 1;
% figure(101)
% p1 = find(abs(good_coord(:,2)-plane)<0.0001);
% plot_data = [good_coord(p1,1) good_coord(p1,3) V(p1)];
% [mesh_x, mesh_y, mesh_z] = surfVector2(plot_data,20);
% surf(mesh_x,mesh_y,mesh_z);
% % scatter3(good_coord(p1,1),good_coord(p1,2),V(p1),'.k')
% drawnow;

% create coordinate structure
V_coord.x= good_coord(:,1)';
V_coord.y= good_coord(:,2)';
V_coord.z= good_coord(:,3)';

%% AGGREGATED CHARGES
if aggregated==1
    %molecule
    if strcmp(molecule_name,'deca')
        mol.x =[mol.x(9) mol.x(10) (mol.x(5)+mol.x(6))/2];
        mol.y =[mol.y(9) mol.y(10) (mol.y(5)+mol.y(6))/2];
        mol.z =[mol.z(9) mol.z(10) (mol.z(5)+mol.z(6))/2];
        mol.n_atoms =3;
        mol.element = {'DOT1','DOT2','DOT3'};
    elseif strcmp(molecule_name,'deca_cell')
        mol.x =[mol.x(10) mol.x(9) (mol.x(5)+mol.x(6))/2 mol.x(36) mol.x(35) (mol.x(31)+mol.x(32))/2];
        mol.y =[mol.y(10) mol.y(9) (mol.y(5)+mol.y(6))/2 mol.y(36) mol.y(35) (mol.y(31)+mol.y(32))/2];
        mol.z =[mol.z(10) mol.z(9) (mol.z(5)+mol.z(6))/2 mol.z(36) mol.z(35) (mol.z(31)+mol.z(32))/2];
        mol.n_atoms =6;
        mol.element = {'DOT1','DOT2','DOT3','DOT1','DOT2','DOT3'};
    elseif strcmp(molecule_name,'butane')
        mol.x =[mol.x(13) mol.x(20)];
        mol.y =[mol.y(13) mol.y(20)];
        mol.z =[mol.z(13) mol.z(20)];
        mol.n_atoms =2;
        mol.element = {'DOT1','DOT2'};
    elseif strcmp(molecule_name,'notbisf')
        mol.x =[-5.347 5.347 0.0002698];
        mol.y =[-1.719 -1.719 4.955];
        mol.z =[-0.1285 -0.1283 -0.7264];
        mol.n_atoms =3;
        mol.element = {'DOT1','DOT2','DOT3'};
    elseif strcmp(molecule_name,'butane_cell')
        mol.x =[mol.x(13) mol.x(20) mol.x(39) mol.x(46)];
        mol.y =[mol.y(13) mol.y(20) mol.y(39) mol.y(46)];
        mol.z =[mol.z(13) mol.z(20) mol.z(39) mol.z(46)];
        mol.n_atoms =4;
        mol.element = {'DOT1','DOT2','DOT1','DOT2'};
    end
end
n_points_esp
%evaluate esp_charge
mol.espCharge=FitESPCharges(mol,V_coord,good_V,0)';
% mol.espCharge

% newpot = EvaluatePotential(mol,V_coord);

% max(good_V-newpot)


end

