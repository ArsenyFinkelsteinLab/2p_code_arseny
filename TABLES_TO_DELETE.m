populate(STIMANAL.ROIGraphAll) % NOT USED DELETE 
populate(STIMANAL.ROIGraphAll3) % NOT USED DELETE (no ETL correction applied here)
populate(STIMANAL.ROIGraphAllETL3)

% XYZ coordinate correction of ETL abberations based on anatomical fiducial
populate(STIM.ROIInfluence3)
populate(STIM.ROIResponseDirect3);
populate(STIMANAL.NeuronOrControl3);
populate(STIMANAL.NeuronOrControlNumber3);
populate(STIMANAL.InfluenceDistance3);
populate(STIMANAL.OutDegree3)
populate(POP.ROICorrLocalPhoto3);

PLOT_InfluenceDistance3()
PLOT_ConnectionProbabilityDistance3()
PLOT_Network_Degree3()

STIMANAL.OutDegree3
STIMANAL.OutDegree3temp
STIMANAL.OutDegreeETL
    

PLOT_Network_Degree_vs_tuning() %directional and temporal tuning -- this is what I show in presentations (now animals 486673 and 486668 were added)
PLOT_Network_Degree_vs_tuning_ETL3() %directional and temporal tuning -- this is what I show in presentations (now animals 486673 and 486668 were added)
PLOT_Network_Degree_vs_tuning_ETL4() %directional and temporal tuning -- this is what I show in presentations (now animals 486673 and 486668 were added)
PLOT_Network_Degree_vs_tuning_reward()
PLOT_Network_Degree_vs_tuning_reward_ETL()
