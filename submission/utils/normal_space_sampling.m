function [idx] = normal_space_sampling(normals, ns)
% By Yiren Lu at University of Pennsylvania
% 04/24/2016
% ESE 650 Project 6
% Sample ns points from normal-space
% First create buckets according to normals and then sampling uniformly
% from buckets
% INPUT:
%       normals     nx3 normal vectors
%       ns          number of samples
% OUPUT:  
%       idx         indices of selected points

% convert normals into Spherical coordinate system
sample_interval = 0.005;

thetas = atan2(normals(:,2),normals(:,1));
phis = atan2(sqrt(normals(:,1).^2 + normals(:,2).^2), normals(:,3));
normals_spherical = [thetas phis];
% binning the normals
[N edges mid loc] = histcn(normals_spherical, -pi:sample_interval:pi,-pi:sample_interval:pi);
loc2 = loc(:,1)*size(N,1)+loc(:,2);
[unique_loc,ids,ids2] = unique(loc2,'rows');
idx_tmp = randsample(size(unique_loc,1),min(ns,size(unique_loc,1)));
idx = ids(idx_tmp);
% idx_loc = loc2(idx_tmp);

% idx = zeros(ns,1);

% for i = 1:ns
%     tmp = 1:size(loc2,1);
%     idx(i) = randsample(tmp(loc2==idx_loc(i)),1);
% end

end