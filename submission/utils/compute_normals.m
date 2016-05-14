function [normals] = compute_normals(x, k)
% By Yiren Lu at University of Pennsylvania
% 04/22/2016
% ESE 650 Project 6
% compute normals for x. For each point, compute the normal based on the
% pca of its k-nn
% For large point sets, the function performs significantly
% faster if Statistics Toolbox >= v. 7.3 is installed.
% INPUTs:   
%       x:      n*3 3d points
%       k:      use k nearest neighbours to compute the normal
% OUTPUT:
%       normals:    n*3 normals


v = ver('stats');
if str2double(v.Version) >= 7.5 
    nn_ids = transpose(knnsearch(x, x, 'k', k+1));
else
    nn_ids = k_nearest_neighbors(x, x, k+1);
end


n = size(x,1);
normals = zeros(n,3);
for i = 1:n
    nn = x(nn_ids(2:end,i),:);
    % use PCA to find the normal
    P = 2*cov(nn);
    [V,D] = eig(P);
    [~, idx] = min(diag(D)); % choses the smallest eigenvalue
    normals(i, :) = V(:,idx)';
end
