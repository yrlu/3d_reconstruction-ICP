function [points] = depthto3dpoints(D, fc)
% By Yiren Lu at University of Pennsylvania
% Mar 21 2016
% ESE 650 Project 4
% Convert Depth Imagen D into 3d points
% Inputs:
%   D:      Depth image
%   fc:     Camera focal parameters
% Outputs:
%   points: n*3 3dpoints;



% convert UVDepth to 3d points
% U-> X, V->Z, Depth->Y
% y = Depth/1000; % depth is in mm;
% x = U/fc_1*depth
% z = -V/fc_2*depth


Y = D/1000;
U = repmat([1:size(D,2)] -size(D,2)/2 ,size(D,1),1);
V = repmat([1:size(D,1)]'-size(D,1)/2, 1,size(D,2));
X = U/fc(1);
X(:) = X(:).*Y(:);
Z = -V/fc(2);
Z(:) = Z(:).*Y(:);
points = [X(:) Y(:) Z(:)];
% 
% X = D/1000;
% U = repmat([1:size(D,2)] -size(D,2)/2 ,size(D,1),1);
% V = repmat([1:size(D,1)]'-size(D,1)/2, 1,size(D,2));
% Y = -U/fc(1);
% Y(:) = X(:).*Y(:);
% Z = -V/fc(2);
% Z(:) = Z(:).*X(:);
% points = [X(:) Y(:) Z(:)];

end