function network_degree()

% close all;
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Photostim_traces\coupled3'];

key.session=3;
key.session_epoch_number = 2;

group_list = fetchn(IMG.PhotostimGroup & (IMG.PhotostimGroupROI & STIM.ROIResponseDirect & 'flag_neuron_or_control=1' & 'distance_to_closest_neuron<17.38') & key,'photostim_group_num','ORDER BY photostim_group_num');

    S=fetch(STIM.ROIResponse1 & key  & 'response_p_value<0.0001','*');
network_k=[];
for i_g=1:1:numel(group_list)
        idx=[S.photostim_group_num] ==i_g;
        network_k(i_g)=numel(S(idx));
end

figure
subplot(2,2,1)
hist_bins = linspace(0,max(network_k),7);
hist_bins_centers = hist_bins(1:end-1) + mean(diff(hist_bins));
[k_prob]=histcounts(network_k,hist_bins);
k_prob=k_prob./length(network_k);
plot(hist_bins_centers,k_prob,'.-')
xlabel('Network degree of photostimulated neurons')
ylabel('Probability')


subplot(2,2,2)
loglog(log10(hist_bins_centers),log10(k_prob),'.-');
% plot(log10(hist_bins_centers),log10(k_prob))
xlabel('p k out')
ylabel('k out')

end
