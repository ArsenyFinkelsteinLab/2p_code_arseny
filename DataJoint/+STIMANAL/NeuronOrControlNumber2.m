%{
# Photostim Group
-> EXP2.SessionEpoch
---
num_targets_neurons            : int             # number of neurons or control sites
num_targets_controls            : int             # number of neurons or control sites

%}


classdef NeuronOrControlNumber2 < dj.Imported
    properties
        keySource = EXP2.SessionEpoch & 'flag_photostim_epoch =1' & STIMANAL.NeuronOrControl2;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            rel_neuron = STIMANAL.NeuronOrControl2 & key & 'neurons_or_control=1';
            rel_control = STIMANAL.NeuronOrControl2 & key & 'neurons_or_control=0';
            
            key.num_targets_neurons=count(rel_neuron);
            key.num_targets_controls=count(rel_control);
            
            
            insert(self,key);
            
            
        end
    end
end