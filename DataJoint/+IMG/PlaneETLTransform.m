%{
# Imaging plane
-> IMG.FOV
plane_num              : int           # imaging plane within this field of view
channel_num            : int           # imaging channel (e.g. 1 green, 2 red etc)
---
etl_affine_transform=null   : blob      #  affine transform to correct for ETL abberations, to align position of deeper planes to the most superficial plane
x_superficial=null          : blob      # x coordinate of the superificial plane fiducials used to compute the affine transform
y_superficial=null          : blob      # y coordinate of the superificial plane fiducials used to compute the affine transform
x_current_deeper=null       : blob      # x coordinate of the deeper plane matching fiducials used to compute the affine transform
y_current_deeper=null       : blob      # y coordinate of the deeper plane matching fiducials used to compute the affine transform
good_fiducials_flag         : int       # 1 -- good fiducials, 0 no good fiducials, therefore no transform available for that session
num_fiducials               : int       # number of fiducials

%}


classdef PlaneETLTransform < dj.Imported
    properties
        keySource = IMG.Plane & (EXP2.Session*EXP2.SessionID & IMG.Volumetric & (STIMANAL.SessionEpochsIncludedFinal & 'flag_include=1')) & (IMG.PlaneCoordinates & 'z_pos_relative>0');
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_save_figure='F:\Arseny\2p\ETL_abberations\Fiducial_correction\';
            session_date =fetch1(EXP2.Session & key,'session_date');
            
            
            close all
            
            figure
            
            image_contrast=2;
            
            %% superficial plane
            key2=key;
            key2.plane_num=1;
            mean_img_superficial =fetch1(IMG.Plane & key2,'mean_img');
            
            max_mean_img=median(mean_img_superficial(:));
            mean_img_superficial(mean_img_superficial>(max_mean_img*image_contrast))=max_mean_img*image_contrast;
            
            
            %% current (deeper) plane
            mean_img_current =fetch1(IMG.Plane & key,'mean_img');
            z_pos_relative = fetch1(IMG.PlaneCoordinates & key,'z_pos_relative');
            max_mean_img=median(mean_img_current(:));
            mean_img_current(mean_img_current>(max_mean_img*image_contrast))=max_mean_img*image_contrast;
            
            subplot(1,2,2) % we plot the deeper first just as referene
            hold on
            imagesc(mean_img_current)
            colormap(gray)
            axis tight
            Affine_transform = fetchn(IMG.PlaneETLTransform*IMG.PlaneCoordinates & key & 'num_fiducials>=8' & sprintf('z_pos_relative=%d',z_pos_relative),'etl_affine_transform');

            subplot(1,2,1) % now we plot the superficial
            hold on
            imagesc(mean_img_superficial)
            colormap(gray)
            axis tight
            R=ginput();
            
            if size(R,1)== 1 %% no good fiducials are available for that FOV
                key.etl_affine_transform = NaN;
                key.x_superficial = NaN;
                key.y_superficial = NaN;
                key.x_current_deeper = NaN;
                key.y_current_deeper = NaN;
                key.good_fiducials_flag=0;
                key.num_fiducials =0;
                insert(self, key);
            else
                
                plot(R(:,1),R(:,2),'.c')
                for ir=1:1:size(R,1)
                    text(R(ir,1),R(ir,2),sprintf('%d',ir),'Color','c');
                end
                
                subplot(1,2,2) % now we plot the deeper again (otherwise ginput won't work)
                hold on
                imagesc(mean_img_current)
                colormap(gray)
                axis tight
                T=ginput(size(R,1));
                R=R';
                T=T';
                
                R = [R; ones(1,size(R,2))];
                T = [T; ones(1,size(T,2))];
                Affine_trasnform=R/T;
                Rtrans=Affine_trasnform*T;
                R=R(1:2,:);
                T=T(1:2,:);
                Rtrans=Rtrans(1:2,:);
                title(sprintf('Current plane depth = %d um \n anm %d Session %d \n   %s \n  \n',z_pos_relative ,key.session, key.subject_id, session_date));
                
                subplot(1,2,1)
                hold on
                imagesc(mean_img_superficial)
                colormap(gray)
                axis tight
                
                %             axis equal
                %             set(gca,'YDir','normal');
                %             axis tight
                plot(R(1,:),R(2,:),'.c')
                plot(T(1,:),T(2,:),'.m')
                plot(Rtrans(1,:),Rtrans(2,:),'.y')
                title(sprintf('Reference Plane depth = 0 \n um Cyan - Reference Plane fiducials,\n Magenta -- Current (deeper) plane fiducials, \nYellow -- deeper fiducials corrected\n'))
                
                key.etl_affine_transform = Affine_trasnform;
                key.x_superficial = R(1,:);
                key.y_superficial = R(2,:);
                key.x_current_deeper = T(1,:);
                key.y_current_deeper = T(2,:);
                key.good_fiducials_flag=1;
                key.num_fiducials =size(R,2);
                
                
                insert(self, key);
                
                if isempty(dir(dir_save_figure))
                    mkdir (dir_save_figure)
                end
                figure_name_out = [dir_save_figure session_date '_anm' num2str(key.subject_id) '_' 's' num2str(key.session ) '_' 'plane' num2str(key.plane_num)];
                eval(['print ', figure_name_out, ' -dtiff  -r200']);
            end
        end
    end
end