% By Yiren Lu at University of Pennsylvania
% April 22 2016
% ESE 650 Project 6 3D dense Mapping/Localization with ICP from RGBD
% Visualize the RGBD data and convert them into .mat format to use
% Also compute the normals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
clear all;

dataset = '5';
basedir = sprintf('./%s/',dataset);
depthlist = dir(strcat(basedir, 'depth/'));
depthlist = depthlist(3:end-1); % get rid of '.' '..' and 'ts.mat'
rgblist = dir(strcat(basedir, 'rgb/'));
rgblist = rgblist(3:end-1);

load(strcat(basedir,'depth/','ts.mat'));
tsd = ts;
load(strcat(basedir,'rgb/','ts.mat'));
tsr = ts;
load(strcat(basedir,'vicon.mat'));

nframe = min(numel(depthlist), numel(rgblist));


imdepth = imread(strcat(basedir,'depth/',depthlist(1).name));
imrgb = imread(strcat(basedir,'rgb/',rgblist(1).name));
depthmat = zeros(size(imdepth,1),size(imdepth,2), nframe);
rgbmat = zeros(size(imrgb,1),size(imrgb,2),3,nframe);


for i = 1:nframe
    i
    
[~, idx] = min(abs(ts(i,2)-t));

depth = imread(strcat(basedir,'depth/',depthlist(i).name));
depthmat(:,:,i) = depth;
subplot(1,2,1), imagesc(depth); 
axis image
rgb = imread(strcat(basedir, 'rgb/',rgblist(i).name));
rgbmat(:,:,:,i) = rgb;
subplot(1,2,2), imshow(rgb); 
title(sprintf('frame:%d, r:%f, p:%f,y:%f',i, E(idx,1)/pi*180,E(idx,2)/pi*180,E(idx,3)/pi*180));

drawnow;
end
% 


vicon.E = E;
vicon.t = t;
vicon.X = X;
save(strcat(basedir,'datamat.mat'),'depthmat','rgbmat','vicon', 'tsd','tsr');
% 

%% load dataset:
clear all;
dataset = '1';
basedir = sprintf('./%s/',dataset);
load(strcat(basedir,'datamat.mat'),'depthmat','rgbmat','vicon','tsd','tsr');

%% compute all normals 

dataset = '5';
basedir = sprintf('./%s/',dataset);

normals = zeros(size(depthmat,1)*size(depthmat,2), 3,size(depthmat,3));
% 41:200,41:280
normals_s = zeros(160*240,3, size(depthmat,3));


parfor i= 1:size(depthmat,3)
    tic
i
x = depthto3dpoints(depthmat(:,:,i), [cali_mat(1,1),cali_mat(2,2)]);
x_s = depthto3dpoints(depthmat(41:200,41:280,i), [cali_mat(1,1),cali_mat(2,2)]);

normals(:,:,i) = compute_normals(x,4);
normals_s(:,:,i) = compute_normals(x_s,4);
    toc
end

save(strcat(basedir,'normals.mat'),'normals','normals_s');


