function test()
key.subject_id = 463189;
key.session =1;
key.session_epoch_number = 1;

roi_list=fetchn(IMG.ROIdeltaF & key,'roi_number','ORDER BY roi_number');
chunk_size=500;
for i_chunk=1:chunk_size:numel(roi_list)
    roi_interval = [i_chunk, i_chunk+chunk_size];
    if roi_interval(end)>numel(roi_list)
        roi_interval(end) = numel(roi_list)+1;
    end
    temp_Fall=cell2mat(fetchn(IMG.ROIdeltaF & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'dff_trace','ORDER BY roi_number'));
    temp_roi_num=fetchn(IMG.ROIdeltaF & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'roi_number','ORDER BY roi_number');
    Fall(temp_roi_num,:)=temp_Fall;
end


[rho,pval]=corr(Fall');
Y = tsne(rho, 'Perplexity', 500);

plot(Y(:,1),Y(:,2),'.');