function C = quad2dcovred(varargin)
% Reduced-size noise covariance structure corresponding to a 2D quadratic function.
%
% Input arguments:
% sigma_x, sigma_y:
%    vector of noise covariance components
% -- OR --
% phi:
%    the noise direction in the range [0, 1/2 \pi]
%
% x, y:
%    vector of observed data
%
% Example:
% Z = [x.^2, x.*y, y.^2, x, y];
% mZ = mean(Z);
% Z = bsxfun(@minus, Z, mZ);  % translate hyperplane to pass through origin
% D = (Z'*Z) / size(Z,1);
% C = quad2dcovred(angle, x, y);

% Copyright 2008-2013 Levente Hunyadi

narginchk(3,4);
switch nargin
    case 3
        phi = varargin{1};
        [x,y,mx2,mxy,my2] = quad2dcovred_data(varargin{2:3});
        
        sx = cos(phi);
        sy = sin(phi);
        Ce = zeros(6,6,3);
        Ce(:,:,1) = ...
        [ mean(0), mean(0), mean(0), mean(0), mean(0), mean(0) ...
        ; mean(0), mean(0), mean(0), mean(0), mean(0), mean(0) ...
        ; mean(0), mean(0), mean(0), mean(0), mean(0), mean(0) ...
        ; mean(0), mean(0), mean(0), mean(0), mean(0), mean(0) ...
        ; mean(0), mean(0), mean(0), mean(0), mean(0), mean(0) ...
        ; mean(0), mean(0), mean(0), mean(0), mean(0), mean(0) ...
        ];
        Ce(:,:,2) = ...
        [                      mean(-2.*mx2.*sx.^2 + 6.*sx.^2.*x.^2), mean(-mxy.*sx.^2 + 3.*sx.^2.*x.*y), mean(-mx2.*sy.^2 - my2.*sx.^2 + sx.^2.*y.^2 + sy.^2.*x.^2), mean(3.*sx.^2.*x),    mean(sx.^2.*y), mean(sx.^2) ...
        ;                         mean(-mxy.*sx.^2 + 3.*sx.^2.*x.*y),    mean(sx.^2.*y.^2 + sy.^2.*x.^2),                         mean(-mxy.*sy.^2 + 3.*sy.^2.*x.*y),    mean(sx.^2.*y),    mean(sy.^2.*x),     mean(0) ...
        ; mean(-mx2.*sy.^2 - my2.*sx.^2 + sx.^2.*y.^2 + sy.^2.*x.^2), mean(-mxy.*sy.^2 + 3.*sy.^2.*x.*y),                      mean(-2.*my2.*sy.^2 + 6.*sy.^2.*y.^2),    mean(sy.^2.*x), mean(3.*sy.^2.*y), mean(sy.^2) ...
        ;                                          mean(3.*sx.^2.*x),                     mean(sx.^2.*y),                                             mean(sy.^2.*x),       mean(sx.^2),           mean(0),     mean(0) ...
        ;                                             mean(sx.^2.*y),                     mean(sy.^2.*x),                                          mean(3.*sy.^2.*y),           mean(0),       mean(sy.^2),     mean(0) ...
        ;                                                mean(sx.^2),                            mean(0),                                                mean(sy.^2),           mean(0),           mean(0),     mean(0) ...
        ];
        Ce(:,:,3) = ...
        [       mean(-sx.^4),             mean(0), mean(sx.^2.*sy.^2), mean(0), mean(0), mean(0) ...
        ;            mean(0), mean(-sx.^2.*sy.^2),            mean(0), mean(0), mean(0), mean(0) ...
        ; mean(sx.^2.*sy.^2),             mean(0),       mean(-sy.^4), mean(0), mean(0), mean(0) ...
        ;            mean(0),             mean(0),            mean(0), mean(0), mean(0), mean(0) ...
        ;            mean(0),             mean(0),            mean(0), mean(0), mean(0), mean(0) ...
        ;            mean(0),             mean(0),            mean(0), mean(0), mean(0), mean(0) ...
        ];

        %m = mean([x.^2, x.*y, y.^2, x, y], 1);
        C = Ce(1:5,1:5,:);
        C(:,:,3) = C(:,:,3) + Ce(1:5,6,2) * Ce(6,1:5,2);
    case 4
        sigma_x = varargin{1};
        sigma_y = varargin{2};
        [x,y,mx2,mxy,my2] = quad2dcovred_data(varargin{3:4});

        Ce = ...
        [                                            mean(-2.*mx2.*sigma_x.^2 - sigma_x.^4 + 6.*sigma_x.^2.*x.^2),                        mean(-mxy.*sigma_x.^2 + 3.*sigma_x.^2.*x.*y), mean(-mx2.*sigma_y.^2 - my2.*sigma_x.^2 + sigma_x.^2.*sigma_y.^2 + sigma_x.^2.*y.^2 + sigma_y.^2.*x.^2), mean(3.*sigma_x.^2.*x),    mean(sigma_x.^2.*y), mean(sigma_x.^2) ...
        ;                                                            mean(-mxy.*sigma_x.^2 + 3.*sigma_x.^2.*x.*y), mean(-sigma_x.^2.*sigma_y.^2 + sigma_x.^2.*y.^2 + sigma_y.^2.*x.^2),                                                            mean(-mxy.*sigma_y.^2 + 3.*sigma_y.^2.*x.*y),    mean(sigma_x.^2.*y),    mean(sigma_y.^2.*x),          mean(0) ...
        ; mean(-mx2.*sigma_y.^2 - my2.*sigma_x.^2 + sigma_x.^2.*sigma_y.^2 + sigma_x.^2.*y.^2 + sigma_y.^2.*x.^2),                        mean(-mxy.*sigma_y.^2 + 3.*sigma_y.^2.*x.*y),                                            mean(-2.*my2.*sigma_y.^2 - sigma_y.^4 + 6.*sigma_y.^2.*y.^2),    mean(sigma_y.^2.*x), mean(3.*sigma_y.^2.*y), mean(sigma_y.^2) ...
        ;                                                                                  mean(3.*sigma_x.^2.*x),                                                 mean(sigma_x.^2.*y),                                                                                     mean(sigma_y.^2.*x),       mean(sigma_x.^2),                mean(0),          mean(0) ...
        ;                                                                                     mean(sigma_x.^2.*y),                                                 mean(sigma_y.^2.*x),                                                                                  mean(3.*sigma_y.^2.*y),                mean(0),       mean(sigma_y.^2),          mean(0) ...
        ;                                                                                        mean(sigma_x.^2),                                                             mean(0),                                                                                        mean(sigma_y.^2),                mean(0),                mean(0),          mean(0) ...
        ];
    
        C = Ce(1:5,1:5) - Ce(1:5,6,3) * Ce(6,1:5,3);
end

function [x,y,mx2,mxy,my2] = quad2dcovred_data(x,y)

validateattributes(x, {'numeric'}, {'real','nonempty','vector'});
validateattributes(y, {'numeric'}, {'real','nonempty','vector'});
x = x(:);
y = y(:);
n = numel(x);

% data vectors x and y must have the same number of elements
validateattributes(x, {'numeric'}, {'size',[n,1]});
validateattributes(y, {'numeric'}, {'size',[n,1]});

mx2 = mean(x.^2);
mxy = mean(x.*y);
my2 = mean(y.^2);
