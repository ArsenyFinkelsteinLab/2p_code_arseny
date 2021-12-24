
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

ff=imread('C:\Users\scanimage\Downloads\Presentation1\Slide1.PNG');
figure
imagesc(ff)

R=ginput(11)
T=ginput(11)

R=R';
T=T';

R = [R; ones(1,size(R,2))];
T = [T; ones(1,size(T,2))];
A=R/T;

Rtrans=A*T;

R=R(1:2,:);
T=T(1:2,:);
Rtrans=Rtrans(1:2,:);

hold on

plot(R(1,:),R(2,:),'.c')
plot(T(1,:),T(2,:),'.m')
plot(Rtrans(1,:),Rtrans(2,:),'.y')


ff=imread('C:\Users\scanimage\Downloads\Presentation1\Slide2.PNG');
figure
imagesc(ff)
T_v2=ginput(13)
T_v2=T_v2';
T_v2 = [T_v2; ones(1,size(T_v2,2))];

Rtrans_v2=A*T_v2;
Rtrans_v2=Rtrans_v2(1:2,:);

hold on
plot(T_v2(1,:),T_v2(2,:),'.m')
plot(Rtrans_v2(1,:),Rtrans_v2(2,:),'.y')


