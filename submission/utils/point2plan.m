function [yhat,ids] = point2plan(x, y)
% By Yiren Lu at University of Pennsylvania
% 04/22/2016
% ESE 650 Project 6
% Evaluates point-to-plane closet point in y for each point in x
% Inputs:
%   x    n*3 3d points
%   y    m*3 3d points
% Outputs:
%   yhat    n*3 3d points each corresponding to a points in x
yhat = zeros(size(x,1),size(x,2));
ids = zeros(size(x,1),1);

for i = 1:size(x,1)
    [~, idx] = min(sum(bsxfun(@minus, y, x(i,:)).^2, 2));
    yhat(i,:) = y(idx, :);
    ids(i) = idx;
end