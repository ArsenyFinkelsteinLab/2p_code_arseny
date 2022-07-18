%{
# Imaging plane
-> IMG.FOV
plane_num              : int           # imaging plane within this field of view
channel_num            : int           # imaging channel (e.g. 1 green, 2 red etc)
---
error_without_transform =null                   : double           #
transform_error_individual_session_based=null   : double           #
transform_error_average_session_based=null      : double           #
transform_error_etl_callibration_based=null     : double           #
num_fiducials                                   : double           #
%}


classdef PlaneETLTransformVerification < dj.Imported
    properties
        keySource = IMG.Plane & (EXP2.Session*EXP2.SessionID & IMG.Volumetric & (STIMANAL.SessionEpochsIncludedFinal & 'flag_include=1')) & (IMG.PlaneCoordinates & 'z_pos_relative>0');
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_save_figure='F:\Arseny\2p\ETL_abberations\Fiducial_correction_verification\';
            session_date =fetch1(EXP2.Session & key,'session_date');
            
            
            close all
            
            % figure
            set(gcf,'DefaultAxesFontName','helvetica');
            set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 25 25]);
            set(gcf,'PaperOrientation','portrait');
            set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
            set(gcf,'color',[1 1 1]);
            
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
            
            x_superficial = cell2mat(fetchn(IMG.PlaneETLTransform*IMG.PlaneCoordinates & key & 'num_fiducials>=4' & sprintf('z_pos_relative=%d',z_pos_relative),'x_superficial'));
            if isempty(x_superficial)
                return
            end
            y_superficial = cell2mat(fetchn(IMG.PlaneETLTransform*IMG.PlaneCoordinates & key & 'num_fiducials>=4' & sprintf('z_pos_relative=%d',z_pos_relative),'y_superficial'));
            x_current_deeper = cell2mat(fetchn(IMG.PlaneETLTransform*IMG.PlaneCoordinates & key & 'num_fiducials>=4' & sprintf('z_pos_relative=%d',z_pos_relative),'x_current_deeper'));
            y_current_deeper = cell2mat(fetchn(IMG.PlaneETLTransform*IMG.PlaneCoordinates & key & 'num_fiducials>=4' & sprintf('z_pos_relative=%d',z_pos_relative),'y_current_deeper'));
            
            XY_superficial = [x_superficial;y_superficial; ones(1,size(x_superficial,2))];
            XY_deeper = [x_current_deeper;y_current_deeper; ones(1,size(x_superficial,2))];
            
            
            Affine_transform_individual_session = cell2mat(fetchn(IMG.PlaneETLTransform*IMG.PlaneCoordinates & key & sprintf('z_pos_relative=%d',z_pos_relative),'etl_affine_transform'));
            Affine_transform_average_session = cell2mat(fetchn(IMG.ETLTransform2 & key & sprintf('plane_depth=%d',z_pos_relative),'etl_affine_transform'));
            Affine_transform_etl_calibration = cell2mat(fetchn(IMG.ETLTransform & key & sprintf('plane_depth=%d',z_pos_relative),'etl_affine_transform'));
            
            subplot(1,2,2) % we plot the deeper first just as referene
            hold on
            imagesc(mean_img_current)
            colormap(gray)
            axis tight
            
            XY_trans_individual_session=Affine_transform_individual_session*XY_deeper;
            XY_trans_average_session=Affine_transform_average_session*XY_deeper;
            XY_trans_etl_calibration=Affine_transform_etl_calibration*XY_deeper;
            
            temp=(XY_superficial- XY_deeper).^2;
            error_without_transform=mean(sqrt(temp(1,:)+temp(2,:)));
            
            temp=(XY_superficial- XY_trans_individual_session).^2;
            transform_error_individual_session_based=mean(sqrt(temp(1,:)+temp(2,:)));
            
            temp=(XY_superficial- XY_trans_average_session).^2;
            transform_error_average_session_based=mean(sqrt(temp(1,:)+temp(2,:)));
            
            temp=(XY_superficial- XY_trans_etl_calibration).^2;
            transform_error_etl_callibration_based=mean(sqrt(temp(1,:)+temp(2,:)));
            
            subplot(1,2,1)
            hold on
            imagesc(mean_img_superficial)
            colormap(gray)
            axis tight
            plot(XY_superficial(1,:),XY_superficial(2,:),'.c')
            plot(XY_deeper(1,:),XY_deeper(2,:),'.m')
            plot(XY_trans_individual_session(1,:),XY_trans_individual_session(2,:),'.y')
            plot(XY_trans_average_session(1,:),XY_trans_average_session(2,:),'.b')
            plot(XY_trans_etl_calibration(1,:),XY_trans_etl_calibration(2,:),'.g')
            title(sprintf('Reference Plane depth = 0 um\n Cyan Reference Plane fiducials\n Magenta, Current plane fiducial. No correction. Error %.1f um, \nYellow, corrected based on this session.  Error %.1fum \nBlue, corrected based on avg session. Error %.1fum\n Green, corrected based on ETL callibration. Error %.1fum',error_without_transform, transform_error_individual_session_based, transform_error_average_session_based, transform_error_etl_callibration_based))
            
            
            subplot(1,2,2) % now we plot the deeper again (otherwise ginput won't work)
            hold on
            imagesc(mean_img_current)
            colormap(gray)
            plot(XY_deeper(1,:),XY_deeper(2,:),'.m')
            axis tight
            if numel(x_superficial)>=8
                title(sprintf('Current plane depth = %d um \n anm %d Session %d \n   %s \nCorrected based on \n  this session fiducial callibration\n',z_pos_relative ,key.session, key.subject_id, session_date));
            else
                title(sprintf('Current plane depth = %d um \n anm %d Session %d \n   %s  \n Corrected based on  \naverage session fiducial callibration\n',z_pos_relative ,key.session, key.subject_id, session_date));
            end
            
            
            
            
            key.num_fiducials = numel(x_superficial);
            key.error_without_transform = error_without_transform;
            key.transform_error_individual_session_based = transform_error_individual_session_based;
            key.transform_error_average_session_based = transform_error_average_session_based;
            key.transform_error_etl_callibration_based = transform_error_etl_callibration_based;
            
            insert(self, key);
            
            if isempty(dir(dir_save_figure))
                mkdir (dir_save_figure)
            end
            figure_name_out = [dir_save_figure session_date '_anm' num2str(key.subject_id) '_' 's' num2str(key.session ) '_' 'plane' num2str(key.plane_num)];
            eval(['print ', figure_name_out, ' -dtiff  -r200']);
        end
    end
end
