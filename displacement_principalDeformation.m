function [displacement] = displacement_principalDeformation(parameters, x, y, z)
%SPHERICALHARMONICS Summary of this function goes here
%   parameters: vector containing parameters (c_00 c_20 q0 q1 q2 q3)
%   points defining surface in the form [x, y, z]
q0=cos(parameters(3));
az=parameters(4);
el=parameters(5);
tmp=[cos(el)*cos(az), -sin(az), -sin(el)*cos(az); ...
		cos(el)*sin(az),  cos(az), -sin(el)*sin(az); ...
		sin(el),           0,         cos(el)];
q1=sin(parameters(3))*tmp(1,1);
q2=sin(parameters(3))*tmp(2,1);
q3=sin(parameters(3))*tmp(3,1);
q = quaternion(q0,q1,q2,q3);
n = RotateVector( q, [x,y,z] );
[az,el,~]=cart2sph(n(:,1),n(:,2),n(:,3));
theta=pi/2-el;
phi=az+pi;
r_fit = parameters(1)*real_sphericalHarmonics(theta,phi,0,0)+parameters(2)*real_sphericalHarmonics(theta,phi,2,0);

[x_dis,y_dis,z_dis] = sph2cart(az,el,r_fit);
displacement=RotateVector( inverse(q), [x_dis,y_dis,z_dis])-[x,y,z];
end

