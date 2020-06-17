function [residuum] = fit_principalDeformation_convolved(parameters, x, y, z, dx, dz, center, size_img, psf, interp, diameter_openclose, radius_peak, clipping_level, aspectRatio, binary)
%SPHERICALHARMONICS Summary of this function goes here
%   parameters: vector containing parameters (c_00 c_20 rotation_angle az_axis el_axis)
%   points defining surface in the form [x, y, z]
factor=2;
[az,el,r]=cart2sph(x,y,z);
el=pi/2-el;
az=az+pi;

[x_undis,y_undis,z_undis]=sph2cart(az, el,parameters(1)/sqrt(4*pi));
displacement_harmonic=zeros(size(x_undis,1),6);
displacement_harmonic(:,1:3)=[x_undis,y_undis,z_undis];
displacement_harmonic(:,4:6)=displacement_principalDeformation(parameters,x_undis, y_undis, z_undis);
harmonics=zeros(factor*size_img+1);
for i=1:size(displacement_harmonic,1)
    itmp=zeros(size(displacement_harmonic(i,1:3)));
    itmp(:,1)=round((displacement_harmonic(i,1)+displacement_harmonic(i,4)+factor*center(1))/(dx/interp));
    itmp(:,2)=round((displacement_harmonic(i,2)+displacement_harmonic(i,5)+factor*center(2))/(dx/interp));
    itmp(:,3)=round((displacement_harmonic(i,3)+displacement_harmonic(i,6)+factor*center(3))/(dz/(interp*aspectRatio)));
    if (all(itmp<(factor*size_img+1)) && all(itmp>0))
        harmonics(itmp(1),itmp(2),itmp(3))=1;
    end
end
se = strel('disk',diameter_openclose);
harmonics = imclose(harmonics,se);
harmonics = imfill(harmonics,'holes');
harmonics = convn(harmonics,psf,'same');
harmonics=harmonics/max(harmonics(:));

%Segment convolved fit
intensity_values=sort(harmonics(:));
intensity_peak=mean(intensity_values(round((100-radius_peak)/100*size(intensity_values,1)):end));
baselevel=median(harmonics(:));
surf_intens=clipping_level*(intensity_peak-baselevel);
%Smooth image; transform to binary and close gaps
binary_harmonics = harmonics>(surf_intens+baselevel);
binary_harmonics = imclose(binary_harmonics,se);
binary_harmonics = imopen(binary_harmonics,se);
%detect edge using canny edge detection
binary_harmonics = canny(single(binary_harmonics));

nx=floor(size(binary,1)/2);
ny=floor(size(binary,2)/2);
nz=floor(size(binary,3)/2);
cx=ceil(size(harmonics,1)/2);
cy=ceil(size(harmonics,2)/2);
cz=ceil(size(harmonics,3)/2);
tmp=binary_harmonics(cx-nx:cx+nx,cy-ny:cy+ny,cz-nz:cz+nz);
% ind = find(binary_harmonics==1);
% [x_harmonics,y_harmonics,z_harmonics] = ind2sub(factor*size_img,ind);
% bead_surface = [x_harmonics*dx/interp,y_harmonics*dx/interp,z_harmonics*dz/(interp*aspectRatio)];
% 
% tmp=[bead_surface(:,1) bead_surface(:,2) bead_surface(:,3)];
% % [center_harmonics,~,~] = spherefit(tmp(:,1),tmp(:,2),tmp(:,3));
% tmp=tmp-center';
% 
% [az_harmonics,el_harmonics,r_harmonics]=cart2sph(tmp(:,1),tmp(:,2),tmp(:,3));
% el_harmonics=pi/2-el_harmonics;
% az_harmonics=az_harmonics+pi;
% 
% azrg=0:2*pi/100:2*pi;
% elrg=0:pi/100:pi;
% [ym,~]=bindata2(r,az,el,azrg,elrg);
% [ym_harmonics,~]=bindata2(r_harmonics,az_harmonics,el_harmonics,azrg,elrg);
% diff=ym-ym_harmonics;
% ind=isnan(diff);
% diff(ind)=0;
% residuum=sqrt(sum(diff(:).^2)/sum(~ind(:)));
tmp=imfill(tmp,'holes');
c=corr(binary(:),tmp(:));
residuum=-c;
end

