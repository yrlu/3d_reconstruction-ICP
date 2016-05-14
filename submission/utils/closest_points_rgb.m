function [xhat yhat,ids, xnormals, ynormals] = closest_points_rgb(x, y, xrgb, yrgb, kdtree_rgb, xnormals, ynormals)
% By Yiren Lu at University of Pennsylvania
% 04/22/2016
% ESE 650 Project 6
% Evaluates closet point in y for each point in x, including rgb values
% Inputs:
%   x    n*3 3d points
%   y    m*3 3d points
%   kdree_rgb   precomputed kdtree of y 
%   xynormals   n*3 m*3 normals of x and y
% Outputs:
%   yhat    n*3 3d points each corresponding to a points in x
%   xhat    n*3 3d points of x after rejection
%   ids     indices
%   xnormals      x normals
%   ynormals      y normals


% kdtree
disp 'kdtree'
if nargin < 5
tic
kdtree_rgb = KDTreeSearcher([y yrgb]);
toc
end
tic
[match ~] = knnsearch(kdtree_rgb,[x xrgb]);
yhat = y(match,:);
xhat = x;
ids = match;
toc

% w = 1- sum((xhat - yhat).^2,2)/max(sum((xhat - yhat).^2,2));

if nargin==7 % input arguments includes xy normals
    % reject pairs with normals angle larger than 45 degree
    xn = xnormals;
    yn = ynormals(match,:);
    xnn = sqrt(sum(xn.^2,2));
    ynn = sqrt(sum(yn.^2,2));
    selected = abs(dot(xn, yn, 2)) > xnn.*ynn*cos(pi/4);% & w>0.95;
    xhat = x(selected, :);
    yhat = yhat(selected,:);
    ids = ids(selected);
    xnormals = xnormals(selected,:);
    ynormals = ynormals(selected,:);
end




