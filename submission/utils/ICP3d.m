function [R T] = ICP3d(x, y)
% By Yiren Lu at University of Pennsylvania
% 04/22/2016
% ESE 650 Project 6
% Mapping x to y
% Inputs:
%   x & y    n*3 3d points
% Outputs:
%   R:      3x3 rotation matrix
%   T:      1x3 transition pos
% i.e.  R*x + trans = y (pysuedo code)

% T = mean(y) - R* mean(x);
% 

meanx = mean(x);
meany = mean(y);

qx = bsxfun(@minus, x, meanx);
qy = bsxfun(@minus, y, meany);
H = qx'*qy; % 3x3 matrix
[U,S,V] = svd(H);
X = V*U';
if det(X) > 0
    R = X;
else
    R = eye(3);
end
T = (meany' - R*meanx')';
end