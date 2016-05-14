function [vpath] = get_vicon_path(ts, vicon)
% By Yiren Lu at University of Pennsylvania
% 04/25/2016
% ESE 650 Project 6
% Get "ground truth" vicon path
% INPUTS:
%       ts:       n*1 timestamp
%       vicon:      vicon data
% OUTPUT:
%       vpath:      n*7 vicon path. Format: [rpy, xyz, timestamp];

vpath = zeros(numel(ts),7);
for i = 1:numel(ts)
    [~, idx] = min(abs(ts(i)-vicon.t));
    rpy = vicon.E(idx,:);
    xyz = vicon.X(idx,:);    
    vpath(i, :) = [rpy, xyz, vicon.t(idx)];
end