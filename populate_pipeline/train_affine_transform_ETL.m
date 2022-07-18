function train_affine_transform_ETL()
close all
% r1 =[1 0 ]
% r2 =[1 1 ]
% r3 =[2 0 ]
% r4 =[1 0 ]
% % 4 pointset of target
% t1 =[0 0 ]
% t2 =[0 2 ]
% t3 =[2 0 ]
% t4 =[0 0 ]
% %homogenous coordinate
% RR=[r1,1; r2,1; r3,1; r4,1]';
% TT=[t1,1; t2,1; t3,1; t4,1]';
% %since R=A*T, A= R*inv(T) or just A=R/T (in MATLAB)
% A=R/T

z_pos_relative=60; %or 60 90 120
file_path='F:\Arseny\2p\ETL_abberations\ETL_all_Dec18th_2021\repeat_1\cropped\';

ff=imread([file_path sprintf('%d',z_pos_relative) '.jpg']);
resizedimage = imresize(ff, [512 512]);

figure
imagesc(resizedimage)
axis equal
set(gca,'YDir','normal');
R=ginput()
T=ginput(size(R,1))

R=R';
T=T';

R = [R; ones(1,size(R,2))];
T = [T; ones(1,size(T,2))];
Affine_transform=R/T;

Rtrans=Affine_transform*T;

R=R(1:2,:);
T=T(1:2,:);
Rtrans=Rtrans(1:2,:);

hold on

plot(R(1,:),R(2,:),'.c')
plot(T(1,:),T(2,:),'.m')
plot(Rtrans(1,:),Rtrans(2,:),'.y')

save([file_path 'Affine_transform120.mat'],'Affine_trasnform')

key1.etl_affine_transform=Affine_trasnform_across_sess;
key1.plane_depth=z_pos_relative;

insert(IMG.ETLTransform, key1);