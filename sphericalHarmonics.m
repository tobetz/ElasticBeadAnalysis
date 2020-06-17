function [y] = sphericalHarmonics(theta,phi,l,m)
%SPHERICALHARMONICS Summary of this function goes here
%   theta [0,pi], phi [0,2pi]: elevation and azimuth
%   l,m: degree and order of spherical harmonic function

%Calculate Normalization-factor
N=sqrt(((2*l+1)/2)*(factorial(l-m)/factorial(l+m)));
%Calculate associated legendre-function
P=legendre(l,cos(theta));
Plm=P(abs(m)+1,:)';
if m<0
   Plm=(-1)^(abs(m))*(factorial(l-abs(m))/factorial(l+abs(m)))*Plm; 
end
%Calculate spherical harmonic function
y=sqrt(1/(2*pi))*N*Plm.*exp(1i*m*phi);
end

