function fn_insert_ridge_dj(self,key,key_ROI1,predictor_name,i_p,X,it,num_of_predict,time_shift_vec)

for i_roi=1:1:numel(key_ROI1)
    key_ROI1(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI1(i_roi).session_epoch_number = key.session_epoch_number;
    key_ROI1(i_roi).predictor_name = predictor_name{i_p};
    key_ROI1(i_roi).predictor_beta = X(i_roi,i_p+(it-1)*num_of_predict);
    key_ROI1(i_roi).time_shift=time_shift_vec(it);
end
insert(self,key_ROI1 );
end