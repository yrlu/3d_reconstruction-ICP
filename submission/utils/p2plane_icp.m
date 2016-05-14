function [R T] = p2plane_icp(x, y, ynormals)
% By Yiren Lu at University of Pennsylvania
% 04/26/2016
% ESE 650 Project 6
% point2plane ICP 
% Mapping x to y
% Inputs:
%   x & y    n*3 3d points
%   ynormals the normals of the destination points
% Outputs:
%   R:      3x3 rotation matrix
%   T:      1x3 transition pos
% i.e.  R*x + trans = y (pysuedo code)
% 
% Credit: partially refer to icp implementation of Martin Kjer and Jakob Wilm, Technical University of Denmark, 2012

s = x';
d = y';
n = ynormals';


% 
% b = dot(d-s, n, 2);
% A1 = cross(s, n);
% A2 = Normals;
% A=[A1 A2];
% X = (A\b)';


c = cross(s,n);

cn = vertcat(c,n);

A = cn*transpose(cn);

b = - [sum(sum((s-d).*repmat(cn(1,:),3,1).*n));
       sum(sum((s-d).*repmat(cn(2,:),3,1).*n));
       sum(sum((s-d).*repmat(cn(3,:),3,1).*n));
       sum(sum((s-d).*repmat(cn(4,:),3,1).*n));
       sum(sum((s-d).*repmat(cn(5,:),3,1).*n));
       sum(sum((s-d).*repmat(cn(6,:),3,1).*n))];
   
X = A\b;

cx = cos(X(1)); cy = cos(X(2)); cz = cos(X(3)); 
sx = sin(X(1)); sy = sin(X(2)); sz = sin(X(3)); 
R = [cy*cz cz*sx*sy-cx*sz cx*cz*sy+sx*sz;
     cy*sz cx*cz+sx*sy*sz cx*sy*sz-cz*sx;
     -sy cy*sx cx*cy];
T = X(4:6)';