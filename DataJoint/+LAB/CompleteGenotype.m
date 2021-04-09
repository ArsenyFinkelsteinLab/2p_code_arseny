%{
#
-> LAB.Subject
---
complete_genotype           : varchar(1000)                 #
%}


classdef CompleteGenotype < dj.Computed
    
    methods(Access=protected)
        
        function makeTuples(self, key)
            
            gene_modification = fetchn(LAB.SubjectGeneModification & key,'gene_modification');
            
            complete_genotype = []; %initializing
            for ii=1:1:numel(gene_modification) %concatenate gene_modifications 
                if ii==1
                    complete_genotype = gene_modification{ii};
                else
                    complete_genotype = [complete_genotype ' X ' gene_modification{ii}];
                end
            end
            
            key.complete_genotype = complete_genotype;
            self.insert(key)
            
        end
    end
    
end