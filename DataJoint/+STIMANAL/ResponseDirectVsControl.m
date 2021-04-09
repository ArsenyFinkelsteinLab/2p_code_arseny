%{
# Responses of couple neurons to photostimulation, as a function of distance
-> EXP2.SessionEpoch
neurons_or_control                          : boolean             # 1 - neurons, 0 control
response_p_val                              : double              # response p-value for inclusion. 1 means we take all pairs
---
is_volumetric                               : boolean             # 1 volumetric, 0 single plane
num_targets                                 : int                 # number of directly stimulated neurons (with significant response) or number of control targets (with non-significant responses)
num_pairs                                   : int                 # total number of cell-pairs included
distance_lateral_bins                       : blob                # lateral bins (um), edges
distance_axial_bins=null                    : blob                # axial positions (um), planes depth

response_lateral                            : longblob                # sum of response for all cell-pairs in each (lateral) bin, divided by the total number of all pairs (positive and negative) in that bin
response_lateral_excitation                 : longblob                # sum of response for all cell-pairs with positive response in each bin, divided by the total number of all pairs (positive and negative) in that bin
response_lateral_inhibition                 : longblob                # sum of response for all cell-pairs with negative response in each bin, divided by the total number of all pairs (positive and negative) in that bin
response_lateral_absolute                   : longblob                # sum of absolute value of tre response for all cell-pairs in each bin, divided by the total number of all pairs (positive and negative) in that bin

response_axial                            : longblob                # same for axial bins
response_axial_excitation                 : longblob                #
response_axial_inhibition                 : longblob                #
response_axial_absolute                   : longblob                #

response_2d=null                          : longblob                # ame for lateral-axial bin
response_2d_excitation=null               : longblob                #
response_2d_inhibition=null               : longblob                #
response_2d_absolute=null                 : longblob                #

counts_2d=null                              : longblob                #
counts_2d_excitation=null                   : longblob                #
counts_2d_inhibition =null                  : longblob                #
%}


classdef ResponseDirectVsControl < dj.Computed
    properties
        keySource = (EXP2.SessionEpoch & 'flag_photostim_epoch =1') & IMG.FOVEpoch & STIM.ROIResponseDirect5;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            clf
            pval_theshold_neurons=0.05;
            pval_theshold_control=0.05;
            z_score_threshold_neurons =0;
            z_score_threshold_controls =100;
            
%             rel=STIM.ROIResponseDirect3 & k & (EXP2.SessionEpoch & STIM.ROIInfluenceLocal); 
            rel=STIM.ROIResponseDirect5 ; 

            
            DATA=fetch(rel,'*');
%                         idx_neurons = [DATA.response_p_value2_odd]<=pval_theshold_neurons & [DATA.response_mean_odd]>=z_score_threshold_neurons & [DATA.num_of_target_trials_used]>20 & [DATA.num_of_baseline_trials_used]>1000;
%             idx_control = [DATA.response_p_value2_odd]>pval_theshold_control & [DATA.response_mean_odd]<z_score_threshold_controls  & [DATA.num_of_target_trials_used]>20 & [DATA.num_of_baseline_trials_used]>1000;
                   idx_neurons = [DATA.response_p_value1_odd]<=pval_theshold_neurons & [DATA.response_mean_odd]>z_score_threshold_neurons ;
            idx_control = [DATA.response_p_value1_odd]>pval_theshold_control & [DATA.response_mean_odd]<z_score_threshold_controls  ;

            
                        %% All trials
            x=[DATA.response_mean];
            
            subplot(3,2,1)
            hold on
            histogram(x,[-1:0.1:3],'FaceColor',[0 0 0])
            histogram(x(idx_control),[-1:0.1:3],'FaceColor',[0 0 1])
            histogram(x(idx_neurons),[-1:0.1:3],'FaceColor',[1 0 0])
            xlabel('Response, zscore')
            title('All trials');
                        ylabel('Counts');

            %% All trials, distance
            x=[DATA.response_distance_lateral_um];
            subplot(3,2,2)
            hold on
            histogram(x,[0:1:25],'FaceColor',[0 0 0])
            histogram(x(idx_control),[0:1:25],'FaceColor',[0 0 1])
            histogram(x(idx_neurons),[0:1:25],'FaceColor',[1 0 0])
            xlabel('Lateral distance (um)')
            title('All trials');
                        ylabel('Counts');

            
            %% Odd trials
            x=[DATA.response_mean_odd];
            y=-log10([DATA.response_p_value1_odd]);
            y(y==inf)=50;
            
            subplot(3,2,3)
            hold on
            histogram(x,[-1:0.1:3],'FaceColor',[0 0 0])
            histogram(x(idx_control),[-1:0.1:3],'FaceColor',[0 0 1])
            histogram(x(idx_neurons),[-1:0.1:3],'FaceColor',[1 0 0])
            xlabel('Response, zscore')
            title('Odd trials');
                        ylabel('Counts');

%             subplot(3,2,2)
%             hold on
%             plot([min(x),max(x)],[-log10(pval_theshold_neurons),-log10(pval_theshold_neurons)]);
%             plot(x,y, '.k')
%             plot(x(idx_control),y(idx_control), '.b')
%             plot(x(idx_neurons),y(idx_neurons), '.r')
%             xlabel('Response, zscore')
%             ylabel('-log10(p-val)')
%             xlim([prctile(x,0.5),prctile(x,99.5)])
%             ylim([0,prctile(y,99)])
            
            
            %% Even trials, restricted by odd trials
            x=[DATA.response_mean_even];
            y=-log10([DATA.response_p_value1_even]);
            y(y==inf)=50;
            
            subplot(3,2,4)
            hold on
            histogram(x,[-1:0.1:3],'FaceColor',[0 0 0])
            histogram(x(idx_control),[-1:0.1:3],'FaceColor',[0 0 1])
            histogram(x(idx_neurons),[-1:0.1:3],'FaceColor',[1 0 0])
            xlabel('Response, zscore')
            title('Even trials');
                        ylabel('Counts');

%             subplot(3,2,4)
%             hold on
%             plot([min(x),max(x)],[-log10(pval_theshold_neurons),-log10(pval_theshold_neurons)]);
%             plot(x,y, '.k')
%             plot(x(idx_control),y(idx_control), '.b')
%             plot(x(idx_neurons),y(idx_neurons), '.r')
%             xlabel('Response, zscore')
%             ylabel('-log10(p-val)')
%             xlim([prctile(x,0.5),prctile(x,99.5)])
%             ylim([0,prctile(y,99)])
            
            
            %% Odd versus even trials, restricted by odd trials
            x=[DATA.response_mean_odd];
            y=[DATA.response_mean_even];
            
            subplot(3,2,5)
            hold on
            %                 plot([min(x),max(x)],[-log10(pval_theshold),-log10(pval_theshold)]);
            plot(x,y, '.k')
            plot(x(idx_control),y(idx_control), '.b')
            plot(x(idx_neurons),y(idx_neurons), '.r')
            xlabel('Response odd, zscore')
            ylabel('Response even, zscore')
            xlim([prctile(x,0.5),prctile(x,99.5)])
            ylim([prctile(y,0.5),prctile(y,99.5)])
            
            subplot(3,2,6)
            histogram([DATA.num_of_target_trials_used])
            ylabel('Counts');
            xlabel('Num of trials per target');
            %                 insert(self,k);
            
            
            
        end
        
        
    end
end


