

rel_group = IMG.PhotostimGroup &   STIM.ROIResponseDirect & (STIMANAL.NeuronOrControl & 'neurons_or_control=1') & IMG.Volumetric;
group = fetch(rel_group);

for i = 1:1: rel_group.count
    rel_group_current = group(i);
    response(i) = fetch1(STIM.ROIResponseDirect & rel_group_current,'response_mean');
    
    rel_current = (STIM.ROIInfluence & rel_group_current) & 'num_svd_components_removed' & 'response_p_value1<=0.05' & 'response_mean>0' & 'response_distance_lateral_um>25';
    out_degree(i)= rel_current.count;
    
    rel_current_near = (STIM.ROIInfluence & rel_group_current) & 'num_svd_components_removed' & 'response_p_value1<=0.05' & 'response_mean>0' & 'response_distance_lateral_um>25' & 'response_distance_lateral_um<=100';
    out_degree_near(i)= rel_current_near.count;

end

histogram(out_degree)
histogram(out_degree_near)
histogram(response)

plot(response, out_degree_near,'.')

network_k=out_degree_near;




figure
subplot(2,2,1)
hold on
hist_bins = linspace(0,max(network_k),15);
[k_prob]=histcounts(network_k,hist_bins);
k_prob=k_prob./length(network_k);
plot(hist_bins_centers,k_prob,'.-b')

poisson_k = poissrnd(mean(network_k),10*numel(network_k),1); 
% hist_bins_poisson = linspace(0,max(poisson_k),30);
% hist_bins_poisson_centers = hist_bins_poisson(1:end-1) + mean(diff(hist_bins_poisson));
[poisson_prob]=histcounts(poisson_k,hist_bins);
poisson_prob=poisson_prob./(10*numel(network_k));
plot(hist_bins_centers,poisson_prob,'-' ,'Color',[0.5 0.5 0.5])

xlabel('Network degree of photostimulated neurons')
ylabel('Probability')


subplot(2,2,2)
hold on
loglog(log10(hist_bins_centers),log10(k_prob),'.-b');
% plot(log10(hist_bins_centers),log10(k_prob))

%poisson
loglog(log10(hist_bins_centers),log10(poisson_prob),'-','Color',[0.5 0.5 0.5]);

xlabel('Network degree of photostimulated neurons')
ylabel('Probability')
text(0,0,'Observed','Color',[0 0 1]);
text(0,-0.25,'Random Network (Erdos-Renye)','Color',[0.5 0.5 0.5]);

% set(gca,'FontSize',12);