load('V:\bernhard\20181002\AB13-5\TP00\Beads.mat');
c00=zeros(1,size(Forces,2));
F=zeros(2,size(Forces,2));
T=zeros(2,size(Forces,2));
for j=1:size(Forces,2)
    c00(j)=Beads(j).spherical_harmonics_parameters(1);
    F(1,j)=abs(getForce(Beads(j).spherical_harmonics_parameters(1)*10^(-6),Beads(j).spherical_harmonics_parameters(2)*10^(-6),2100,0.49));
    F(2,j)=vecnorm(Forces(j).Factio);
    T(1,j)=F(1,j)/((Beads(j).spherical_harmonics_parameters(1)*10^(-6))^2);
    T(2,j)=F(2,j)/((Beads(j).spherical_harmonics_parameters(1)*10^(-6))^2);
end