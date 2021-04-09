%{
#
-> EXP2.SessionEpoch
%}


classdef CorrPairwiseDistance < dj.Computed
    properties
        
        keySource = EXP2.SessionEpoch & POP.CorrPairwiseDistanceSVDSpikes;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_save_fig = [dir_base  '\POP\corr_distance_plots\neuropil_subtracted\'];
            num_svd_components_removed_vector = [0, 1, 10, 100, 500];
            
            k=key;
            k.threshold_for_event=0;
            
            rel_data=POP.CorrPairwiseDistanceSVDSpikes;
            %                         rel_data=POP.CorrPairwiseDistanceSVDSpikes	;
            
            clf
            %Graphics
            %             %---------------------------------
            %             figure;
            %             set(gcf,'DefaultAxesFontName','helvetica');
            %             set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
            %             set(gcf,'PaperOrientation','portrait');
            %             set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
            %             set(gcf,'color',[1 1 1]);
            
            for i_c=1:1:numel(num_svd_components_removed_vector)
                k.num_svd_components_removed=num_svd_components_removed_vector(i_c);
                DATA=fetch(rel_data & k,'*');
                
                corr_histogram = DATA.corr_histogram;
                corr_histogram_bins = DATA.corr_histogram_bins;
                corr_histogram_bins=corr_histogram_bins(1:1:end-1) + diff(corr_histogram_bins);
                
                
                distance_corr_all = DATA.distance_corr_all;
                distance_bins = DATA.distance_bins;
                distance_bins=distance_bins(1:1:end-1) + diff(distance_bins);
                
                
                
                subplot(2,2,1);
                hold on
                plot(corr_histogram_bins,corr_histogram);
                
                subplot(2,2,2);
                if i_c==1
                    plot([0,distance_bins(end)],[0,0],'-k');
                end
                hold on
                plot(distance_bins(1:1:end),distance_corr_all(1:1:end));
                
            end
            
        end
    end
end