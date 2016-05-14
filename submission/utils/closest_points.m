function [xhat yhat,ids, xnormals, ynormals] = closest_points(x, y, kdtree, xnormals, ynormals)
% By Yiren Lu at University of Pennsylvania
% 04/22/2016
% ESE 650 Project 6
% Evaluates closet point in y for each point in x
% Inputs:
%   x    n*3 3d points
%   y    m*3 3d points
%   kdree   precomputed kdtree of y (optional)
%   xynormals   n*3 m*3 normals of x and y
% Outputs:
%   yhat    n*3 3d points each corresponding to a points in x
%   xhat    n*3 3d points of x after rejection
%   ids     indices
%   xnormals      x normals
%   ynormals      y normals



% naive for loop approach, super slow!
% yhat = zeros(size(x,1),size(x,2));
% ids = zeros(size(x,1),1);
% for i = 1:size(x,1)
%     [~, idx] = min(sum(bsxfun(@minus, y, x(i,:)).^2, 2));
%     yhat(i,:) = y(idx, :);
%     ids(i) = idx;
% end

% builtin knn, much faster!
% v = ver('stats');
% if str2double(v.Version) >= 7.5 
%     nn_ids = transpose(knnsearch(y, x, 'k', 1));
% else
%     nn_ids = k_nearest_neighbors(y, x, 1);
% end
% ids = nn_ids;
% yhat = y(nn_ids,:);


% kdtree
disp 'kdtree'
if nargin < 3
tic
kdtree = KDTreeSearcher(y);
toc
end
tic
[match ~] = knnsearch(kdtree,x);
yhat = y(match,:);
xhat = x;
ids = match;
toc


if nargin==5 % input arguments includes xy normals
    % reject pairs with normals angle larger than 45 degree
    xn = xnormals;
    yn = ynormals(match,:);
    xnn = sqrt(sum(xn.^2,2));
    ynn = sqrt(sum(yn.^2,2));
    selected = abs(dot(xn, yn, 2)) > xnn.*ynn*cos(pi/4);
    xhat = x(selected, :);
    yhat = yhat(selected,:);
    ids = ids(selected);
    xnormals = xnormals(selected,:);
    ynormals = ynormals(selected,:);
end



% kdOBJ = KDTreeSearcher(transpose(q));
% function [match mindist] = match_kDtree(~, p, kdOBJ)
% 	[match mindist] = knnsearch(kdOBJ,transpose(p));
%     match = transpose(match);
