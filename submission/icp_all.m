function [R T] = icp_all(ptx, pty)
% By Yiren Lu at University of Pennsylvania
% 04/25/2016
% ESE 650 Project 6
% Using ICP to do 3d point cloud registration
% INPUT:
%       ptx     n*9 source points cloud. Format [xyz, rgb, normals]
%       pty     m*9 distination points cloud
% Outputs:
%   R:      3x3 rotation matrix
%   T:      1x3 transition pos
% i.e.  R*x + trans = y (pysuedo code)



% flags
display = 0;
savevideo = 0;
n_samples = 3000;
max_iter = 70;


% prepare video writer
if savevideo==1
v = VideoWriter(sprintf('./results/%s',datestr(datetime('now'))),'MPEG-4');
open(v)
end






curR = eye(3);
curT = zeros(1,3);


ptx_o = ptx;
pty_o = pty;



% normal-space sampling (bucket sampling) 

idy = normal_space_sampling(pty_o(:,7:9), n_samples);
pty = pty_o(idy,:);

idx = normal_space_sampling(ptx_o(:,7:9), n_samples);
ptx = ptx_o(idx,:);
% pre-construct kdtree for closest points evaluation
% kdtree = KDTreeSearcher(pty(:,1:3));
kdtree_rgb = KDTreeSearcher(pty(:,1:6));




i = 1;
while i < max_iter
i 
i = i+1;






% Matching
% Current:      Closest point 
% TODO:         within 45 degree normal
%               Projection-based (normal shooting)
disp 'evaluating correspondence';
% tic;
% [x, yhat, idx, xn, yn] = closest_points(ptx(:,1:3), pty(:,1:3), kdtree, ptx(:,7:9), pty(:,7:9));
[x, yhat,idx, xn, yn] = closest_points_rgb(ptx(:,1:3), pty(:,1:3),ptx(:,4:6), pty(:,4:6), kdtree_rgb, ptx(:,7:9), pty(:,7:9));
% [x, yhat,idx] = closest_points(x, y, kdtree);
% [yhat,idx] = closest_points(x, y);
% toc

% Weighting 
% Current:      None

% Rejecting
% Current:      None    
% TODO:         Reject boundary points


% Error metric
% Current:      Least-squares 
% TODO:         Point 2 Plane
disp 'ICP';
% tic;
% [R T] = ICP3d(x, yhat);
[R T] = p2plane_icp(x, yhat, yn);
% toc
% perform transformation
% x = bsxfun(@plus, (R*x')', T);
curR = R*curR;
curT = (R*curT')' + T;
ptx(:,1:3) = bsxfun(@plus, (R*ptx(:,1:3)')', T);
ptx(:,7:9) = bsxfun(@plus, (R*ptx(:,7:9)')', T);

ptx_o(:,1:3) = bsxfun(@plus, (R*ptx_o(:,1:3)')', T);
ptx_o(:,7:9) = bsxfun(@plus, (R*ptx_o(:,7:9)')', T);


if display==1
disp 'display frame' 
% tic;
% pcshow(pty(:,1:3),pty(:,4:6) ,'MarkerSize',200);
pcshow(pty_o(:,1:3),pty_o(:,4:6) ,'MarkerSize',200);
hold on;
% pcshow(bsxfun(@plus, (R*ptx(:,1:3)')', T),ptx(:,4:6),'MarkerSize',200);
pcshow(bsxfun(@plus, (R*ptx_o(:,1:3)')', T),ptx_o(:,4:6),'MarkerSize',200);
% pcshow(bsxfun(@plus, (curR*ptx_o(:,1:3)')', curT),ptx_o(:,4:6),'MarkerSize',200);
hold off;
drawnow;
% toc
end

norm(R - eye(3))
if norm(R - eye(3))<10e-5
   break; 
end



if savevideo ==1
disp 'save video';
% tic
F = getframe;
[X,map] = frame2im(F);
writeVideo(v,X)
% toc
end

end


if savevideo == 1
close(v);
end


R = curR;
T = curT;


