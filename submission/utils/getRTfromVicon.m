function [R pos] = getRTfromVicon(ts, vicon)
% By Yiren Lu at University of Pennsylvania
% 04/22/2016
% ESE 650 Project 6
% Get Rotation and Translation from Vicon data by timestamp
% Inputs:
%   ts:     timestamp a number;
%   vicon:     the vicon data;
% Outputs:
%   R:      3x3 rotation matrix
%   pos:    3:1 current position
[~, idx] = min(abs(ts-vicon.t));
% R = rpy2rot(vicon.E(idx,1),vicon.E(idx,2),vicon.E(idx,3));
R = rpy2rot(vicon.E(idx,1),-vicon.E(idx,2),vicon.E(idx,3));
pos = vicon.X(idx,:);
end