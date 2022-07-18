function session_avg_affine_transform_from_fiducials_ETL
close all
z_pos_relative=120; %60 90 or 120

S=fetch(IMG.PlaneETLTransform*IMG.PlaneCoordinates & 'num_fiducials>=8' & sprintf('z_pos_relative=%d',z_pos_relative),'*');
dir_ETL_transform = 'F:\Arseny\2p\ETL_abberations\';  %trained and tested manually prior to running DJ with  train_affine_transform_ETL() test_affine_transform_ETL() functions
Affine_transform_beads =load([dir_ETL_transform 'Affine_transform' num2str(z_pos_relative) '.mat']);
Affine_transform_beads=Affine_transform_beads.Affine_trasnform;

Rx=[];
Ry=[];

Tx=[];
Ty=[];

for i_s=1:1:numel(S)
    
    Rx = [Rx S(i_s).x_superficial];
    Ry = [Ry S(i_s).y_superficial];
    
    Tx = [Tx S(i_s).x_current_deeper];
    Ty = [Ty S(i_s).y_current_deeper];
    
    R_ses = [S(i_s).x_superficial;    S(i_s).y_superficial];
    R_ses = [R_ses; ones(1,size(R_ses,2))];

    T_ses = [S(i_s).x_current_deeper; S(i_s).y_current_deeper];
    T_ses = [T_ses; ones(1,size(T_ses,2))];

    Affine_trasnform_ses=R_ses/T_ses;
    Rtrans_per_ses{i_s}=Affine_trasnform_ses*T_ses;

end

R=[Rx;Ry];
T=[Tx;Ty];

R = [R; ones(1,size(R,2))];
T = [T; ones(1,size(T,2))];
Affine_trasnform_across_sess=R/T;
Rtrans_across_sess=Affine_trasnform_across_sess*T;

Rtrans_beads=Affine_transform_beads*T;

Rtrans_per_ses=cell2mat(Rtrans_per_ses);



R=R(1:2,:);
T=T(1:2,:);
Rtrans_across_sess=Rtrans_across_sess(1:2,:);
Rtrans_beads=Rtrans_beads(1:2,:);


figure

subplot(2,2,1)
hold on
plot( R(1,:),R(2,:),'.c')
plot( T(1,:),T(2,:),'.m')
plot( Rtrans_across_sess(1,:),Rtrans_across_sess(2,:),'.y')
% plot( Rtrans_beads(1,:),Rtrans_beads(2,:),'.g')
plot( Rtrans_per_ses(1,:),Rtrans_per_ses(2,:),'.w')

set(gca,'color',[0 0 0])

subplot(2,2,2)
hold on
plot(T(1,:)-R(1,:),T(2,:)-R(2,:),'.m')
hold on
plot(Rtrans_across_sess(1,:)-R(1,:),Rtrans_across_sess(2,:)-R(2,:),'.y')
% plot(Rtrans_beads(1,:)-R(1,:),Rtrans_beads(2,:)-R(2,:),'.g')
plot(Rtrans_per_ses(1,:)-R(1,:),Rtrans_per_ses(2,:)-R(2,:),'.w')

set(gca,'color',[0 0 0])


key1.etl_affine_transform=Affine_trasnform_across_sess;
key1.plane_depth=z_pos_relative;

insert(IMG.ETLTransform2, key1);