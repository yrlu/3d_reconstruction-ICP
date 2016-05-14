% By Yiren Lu at University of Pennsylvania
% April 24 2016
% ESE 650 Project 6 3D dense Mapping/Localization with ICP from RGBD
% Demo 3d reconstruction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
dataset = '5';
basedir = sprintf('./%s/',dataset);
load(strcat(basedir,'datamat.mat'),'depthmat','rgbmat','vicon','tsd','tsr');

load('camparam.mat');
load(strcat(basedir,'normals.mat'));
cali_mat = reshape(K,[3 3])';

addpath ./utils;
% addpath ./icp;




%% reconstruct 3d scene with vicon's data
curR=eye(3);
curT=zeros(1,3);


path_v = zeros(55,7);

% figure;

for i = 51:90%size(depthmat,3)-3
    i

y_o= depthto3dpoints(depthmat(:,:,i), [cali_mat(1,1),cali_mat(2,2)]);
yrgb = reshape(rgbmat(:,:,:,i)/255,[240*320, 3]);

rot = rpy2rot(0,0,-pi/2);
y_o = (rot * y_o')';

[~, idx] = min(abs(tsd(i,2)-vicon.t));
curR = rpy2rot(vicon.E(idx,1),-vicon.E(idx,2),vicon.E(idx,3));
curT = vicon.X(idx,:);

[r p y] = rot2rpy(curR);
path_v(i-50, :) = [r,p,y,curT(1),curT(2),curT(3), tsd(i,2)];
% [curR curT] = getRTfromVicon(tsd(i,2),vicon);
% curR = rpy2rot(vpath(i-50,1),vpath(i-50,3),vpath(i-50,3));
% curT = vpath(i-50,4:6);
toshow = bsxfun(@plus, (curR*y_o')', curT);
subplot(2,1,1);pcshow(toshow(1:10:end,:),yrgb(1:10:end,:),'MarkerSize',200);
hold on;
xlabel('x');
ylabel('y');
zlabel('z');
drawnow;
end


% reconstruct 3d scene using ICP

% figure;
savevideo = 0;
if savevideo==1
v = VideoWriter(sprintf('./results/%s',datestr(datetime('now'))),'MPEG-4');
open(v)
end

% rpy = rand(3,1);
% curR = rpy2rot(rpy(1),rpy(2),rpy(3));
% curT = rand(1,3)*1;

curR=eye(3); %rpy2rot(0,0,-pi/2);
curT=zeros(1,3);
path = zeros(55, 7);
elapsed = zeros(55,1);

interval = 1;

% path = zeros(60,7); % rpy xyz, ts


for i = 51:interval:90%size(depthmat,3)-interval
    i
    
    
    
frame1 = i;
frame2 = i+interval;
y_o= depthto3dpoints(depthmat(:,:,frame1), [cali_mat(1,1),cali_mat(2,2)]);
yrgb = reshape(rgbmat(:,:,:,frame1)/255,[240*320, 3]);
% x_o= depthto3dpoints(depthmat(:,:,frame2), [cali_mat(1,1),cali_mat(2,2)]);
% xrgb = reshape(rgbmat(:,:,:,frame2)/255,[240*320, 3]);
x_o1 = depthto3dpoints(depthmat(41:200,41:280,frame2), [cali_mat(1,1),cali_mat(2,2)]);
xrgb1 = reshape(rgbmat(41:200,41:280,:,frame2)/255,[160*240, 3]);

ynormals = normals(:,:,frame1);
xnormals = normals_s(:,:,frame2);

[x_o1,ix,~] = unique(x_o1,'rows');
xrgb1 = xrgb1(ix,:);
xnormals = xnormals(ix,:);
[y_o,iy,~] = unique(y_o,'rows');
yrgb = yrgb(iy,:);
ynormals = ynormals(iy,:);

ptx = [x_o1, xrgb1, xnormals];
pty = [y_o, yrgb, ynormals];


% y_o = (rot * y_o')';
% rot = rpy2rot(0,0,-pi/2);
% ptx(:,1:3) = (rot*ptx(:,1:3)')';
% ptx(:,7:9) = (rot*ptx(:,7:9)')';
% 
% pty(:,1:3) = (rot*pty(:,1:3)')';
% pty(:,7:9) = (rot*pty(:,7:9)')';
% rot = rpy2rot(0,0,-0.);

ptx(:,1:3) = bsxfun(@plus, (curR*ptx(:,1:3)')', curT);
ptx(:,7:9) = bsxfun(@plus, (curR*ptx(:,7:9)')', curT);

pty(:,1:3) = bsxfun(@plus, (curR*pty(:,1:3)')', curT);
pty(:,7:9) = bsxfun(@plus, (curR*pty(:,7:9)')', curT);



disp 'display frame' 
tic;
subplot(2,1,2);pcshow(pty(1:10:end,1:3),pty(1:10:end,4:6) ,'MarkerSize',200);
hold on;
drawnow;
toc

disp 'ICP'
tic
[R T] = icp_all(ptx, pty);
% [r, p, y] = rot2rpy(R)
% R = rpy2rot(r, p, y+0.025);
curR = R*curR;
curT = (R*curT')' + T;
elapsedTime = toc
elapsed(i-50) = elapsedTime;

[r p y] = rot2rpy(curR);
path(i-50, :) = [r,p,y,curT(1),curT(2),curT(3), tsd(i,2)];

% [r, p, y] = rot2rpy(curR)
% path(i,:) = [r,p,y, curT,tsd(i,2)];


if savevideo ==1
disp 'save video';
tic
F = getframe;
[X,map] = frame2im(F);
writeVideo(v,X)
toc
end



end



if savevideo == 1
close(v);
end


fps = 1/mean(elapsed(1:40)) % fps = 108.7144

%% plot the rpy xyz against vicon's data

figure;

path0 = path;
path = path0(1:40,:);
vpath = get_vicon_path(path(:,7),vicon);
vpath(:,6) = vpath(:,6)-vpath(1,6);

subplot(3,2,1); plot(path(:,7),path(:,1));
hold on;
plot(vpath(:,7),vpath(:,1));
legend('icp','vicon');
ylabel('r');
subplot(3,2,3); plot(path(:,7),path(:,2));
hold on;
plot(vpath(:,7),-vpath(:,2));
legend('icp','vicon');
ylabel('p');
subplot(3,2,5); plot(path(:,7),path(:,3));
hold on;
plot(vpath(:,7),vpath(:,3));
legend('icp','vicon');
ylabel('y');
subplot(3,2,2); plot(path(:,7),path(:,4));
hold on;
plot(vpath(:,7),vpath(:,5));
legend('icp','vicon');
ylabel('x');
subplot(3,2,4); plot(path(:,7),path(:,5));
hold on;
plot(vpath(:,7),vpath(:,4));
legend('icp','vicon');
ylabel('y');
subplot(3,2,6); plot(path(:,7),path(:,6));
hold on;
plot(vpath(:,7),vpath(:,6));
legend('icp','vicon');
ylabel('z');


%%


