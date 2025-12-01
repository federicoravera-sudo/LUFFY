%Elementary charge
q = 1.60217662e-19;

%Dielectric permittivity
e0 = 8.854187817e-12;

%Coulomb Constant
k = 1/(4*pi*e0);

%Speed of light
c_light = 299792458;

%speed of sound
c_sound = 343;

%electron mass
m_e = 9.10938356e-31;

%Planck constant
h_const = 6.62607004E-34;
h_cut = h_const/2/pi;

%bohr radius a0 or r0
bohr_radius = (4*pi*e0*h_cut^2)/(m_e*q^2);

%Hartreee energy
hartree_energy_joule = 4.359744650e-18;
hartree_energy_eV = 27.21138602;

%Boltzmann constant
kB = 1.380649e-23;

%Avogadro Constant
Navo = 6.02214086e23;