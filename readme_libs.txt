30.07.2018, Bernhard Wallmeyer, bwallmeyer@uni-muenster.de
This GUI allows to manually locate elastic beads in a stack of tiff-images. After detection of the beads they are automatically segmented and spherical harmonics are fitted to the segmentation. When a connection of matlab to comsol server is established, the tension dipol leading to the segmented deformation of the bead can be calculated.
This software benefits from following code:
1. Canny edge detection in 2-D and 3-D version 1.2 by David Young https://de.mathworks.com/matlabcentral/fileexchange/45459-canny-edge-detection-in-2-d-and-3-d
2. fminsearchbnd, fminsearchcon version 1.4 by John D'Errico https://de.mathworks.com/matlabcentral/fileexchange/8277-fminsearchbnd--fminsearchcon
3. Fitting quadratic curves and surfaces version 1.4 by Levente Hunyadi https://de.mathworks.com/matlabcentral/fileexchange/45356-fitting-quadratic-curves-and-surfaces
4. quaternion version 1.8 by Mark Tincknell https://de.mathworks.com/matlabcentral/fileexchange/33341-quaternion
5. Multipage TIFF stack version 4.4.0.0 by YoonOh Tak https://de.mathworks.com/matlabcentral/fileexchange/35684-multipage-tiff-stack
6. RunLength version 1.2.0.0 by Jan Simon https://de.mathworks.com/matlabcentral/fileexchange/41813-runlength
