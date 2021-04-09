function plot_selectivity_maps_different_epochs
close all
dir_save_figure1 = ['Z:\users\Arseny\Projects\Learning\imaging2p\Results\Selectivity_maps\anm\f\epoch\'];
dir_save_figure2 = ['Z:\users\Arseny\Projects\Learning\imaging2p\Results\Selectivity_maps\anm\dff\epoch\'];

% FIGURE
%--------------------------------------------------------------------------
% Some WYSIWYG options:
figure;

set(gcf,'DefaultAxesFontSize',7);
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0.5 0.5 21 29.7]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[0 0 0 0]);

panel_width1=1;
panel_height1=panel_width1*0.7071;
horizontal_distance1=0.47;
vertical_distance1=0.45;


position_x1(1)=0;
position_x1(2)=position_x1(1)+horizontal_distance1;
position_x1(3)=position_x1(1);
position_x1(4)=position_x1(3)+horizontal_distance1;
% position_x1(3)=position_x1(2)+horizontal_distance1;
% position_x1(4)=position_x1(3)+horizontal_distance1;
% position_x1(5)=position_x1(4)+horizontal_distance1;

position_y1(1)=0.15;
position_y1(2)=position_y1(1);
position_y1(3)=position_y1(1)-vertical_distance1;
position_y1(4)=position_y1(3);
% position_y1(3)=position_y1(2)-vertical_distance1;
% position_y1(4)=position_y1(3)-vertical_distance1;
% position_y1(5)=position_y1(4)-vertical_distance1;
% position_y1(6)=position_y1(5)-vertical_distance1;



trial_epoch_name = fetchn(EXP2.EpochName2,'trial_epoch_name');
sessions = unique(fetchn(IMG.FOVMapSelectivity,'session'));

for i_s = 1:1:numel(sessions)
    k.session = sessions(i_s);
    for i_epoch=1:1:numel(trial_epoch_name)
        k.trial_epoch_name =trial_epoch_name{i_epoch};
        
        ax1=axes('position',[position_x1(1) position_y1(1) panel_width1 panel_height1]);
        label='R-L selectivity';
        map=fetch1(IMG.FOVMapSelectivity & k,'map_selectivity_f');
        map=smooth2a(map,1,1);
        map=map*(-1);
        colorbar_label = 'Selectivity (R-L), Fluorescence';
        [cmp] = fn_plot_map4 (map, label, k, colorbar_label);
        colormap(ax1,cmp);
        
        
        dir_current_figure = dir_save_figure1;
        dir_current_figure=[dir_current_figure '\' trial_epoch_name{i_epoch} '\'];
        if isempty(dir(dir_current_figure))
            mkdir (dir_current_figure)
        end
        
        filename=['maps_' num2str(sessions(i_s))];
        figure_name_out=[ dir_current_figure filename];
        eval(['print ', figure_name_out, ' -dtiff  -r600']);
        % eval(['print ', figure_name_out, ' -dpdf -r200']);
        
        clf;
        
        
        ax1=axes('position',[position_x1(1) position_y1(1) panel_width1 panel_height1]);
        label='R-L selectivity';
        map=fetch1(IMG.FOVMapSelectivity & k,'map_selectivity_dff');
                map=smooth2a(map,1,1);
        map=map*(-1);
        colorbar_label = 'Selectivity (R-L), \DeltaF/F';
        [cmp] = fn_plot_map4 (map, label, k, colorbar_label);
        colormap(ax1,cmp);
        
        
        
        dir_current_figure = dir_save_figure2;
        dir_current_figure=[dir_current_figure '\' trial_epoch_name{i_epoch} '\'];
        if isempty(dir(dir_current_figure))
            mkdir (dir_current_figure)
        end
        
        filename=['maps_' num2str(sessions(i_s))];
        figure_name_out=[ dir_current_figure filename];
        eval(['print ', figure_name_out, ' -dtiff  -r600']);
        % eval(['print ', figure_name_out, ' -dpdf -r200']);
        
        clf;
    end
end