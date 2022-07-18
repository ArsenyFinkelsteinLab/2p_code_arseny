function test_affine_transform_ETL()
% close all


file_path_transform='F:\Arseny\2p\ETL_abberations\ETL_all_Dec18th_2021\repeat_1\cropped\';
load([file_path_transform, 'Affine_transform120.mat']);
file_path='F:\Arseny\2p\ETL_abberations\ETL_all_Dec18th_2021\repeat_4\cropped\';
% file_path='F:\Arseny\2p\ETL_abberations\ETL_all_Dec3rd_2021\repeat_1\cropped\';

ff=imread([file_path '120.JPG']);
resizedimage = imresize(ff, [512 512]);

figure
imagesc(resizedimage)
axis equal
% set(gca,'YDir','normal');
axis xy;
% R=ginput()
% T=ginput(size(R,1))
T=ginput()

% R=R';
T=T';

% R = [R; ones(1,size(R,2))];
T = [T; ones(1,size(T,2))];
% A=R/T;

Rtrans=Affine_trasnform*T;
% R=R(1:2,:);
T=T(1:2,:);
% Rtrans=Rtrans(1:2,:);

hold on

% plot(R(1,:),R(2,:),'.c')
plot(T(1,:),T(2,:),'.m')
plot(Rtrans(1,:),Rtrans(2,:),'.y')

