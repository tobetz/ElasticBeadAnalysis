function [y] = real_sphericalHarmonics(theta,phi,l,m)
%SPHERICALHARMONICS Summary of this function goes here
%   theta [0,pi], phi [0,2pi]: elevation and azimuth
%   l,m: degree and order of spherical harmonic function

if m<0
    y=sqrt(2)*(-1)^m*imag(sphericalHarmonics(theta,phi,l,abs(m)));
elseif m>0
    y=sqrt(2)*(-1)^m*real(sphericalHarmonics(theta,phi,l,m));
else
    y=sphericalHarmonics(theta,phi,l,m);
end
    
end

