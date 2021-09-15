function DELETE_FROM_PIPELINE()
% Relvar - disable user-promt in this script for fast deletion
key.subject_id = 481101;
EXP2.Session & key 
% key.session = 2;

del (IMG.ROITrace & key)
del (IMG.ROISpikes & key)
del (IMG.ROIdeltaF & key)
del (IMG.ROIdeltaFPeak & key)
del (IMG.ROIdeltaFMean	 & key)
del (IMG.ROIFMean & key)

del (IMG.ROITraceNeuropil & key)
del (IMG.ROIdeltaFNeuropil & key)


del (POP.ROIClusterCorr & key)
del (POP.ROIClusterCorr2 & key)
del (POP.ROICorrLocal & key)
del (POP.ROIPCA	 & key)
del (POP.ROISubClusterCorr	 & key)
del (IMG.PhotostimGroupROI & key)

% del (IMG.ROI & key)

del(EXP2.Session & key);

