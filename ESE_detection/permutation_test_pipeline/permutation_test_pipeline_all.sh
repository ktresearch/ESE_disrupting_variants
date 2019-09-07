#!/bin/sh

workdir=
genomedir=


cancertypefile=TCGA_cancertype_list.txt
refflatfile=refflat_SORT_2nd_ver2.txt
exonskipfile=exon_skip_junction_detail_type1.txt


perl PT1_prepare_var_rpkm_data.pl $workdir/$cancertypefile $workdir

perl PT1-2_prepare_rpkm_non_variant_exon.pl $workdir/$cancertypefile $workdir $exonskipfile

mkdir $workdir/permutation_results

###iteration start

for i in `seq 1 1000`
do
echo $i

perl PT2_permutation_data.pl $workdir/$cancertypefile $workdir $exonskipfile

perl PT3_rpkm_non_variant_exon.pl $workdir/$cancertypefile $workdir

perl PT4_normalized_data_name_change.pl $workdir/$cancertypefile $workdir

perl PT5_judge.pl $workdir/$cancertypefile $workdir

perl PT6_ese_candidate_edit_for_Rtest.pl $workdir/$cancertypefile $workdir 

perl PT7_R_test_check.pl $workdir/$cancertypefile $workdir 

R --vanilla --slave < R_ks_test_all.R

perl PT8_combine_pnorm_test_result_ks.pl $workdir/TCGA_cancertype_list_for_permutationtest.txt $work_dir

perl PT9_validation_ks.pl $workdir/TCGA_cancertype_list_for_permutationtest.txt $work_dir

perl PT10_merge_all_tissue_validated_ese_ks.pl $workdir/TCGA_cancertype_list_for_permutationtest.txt $work_dir

perl PT11_restore_normalized_data_name.pl $workdir/$cancertypefile $work_dir

perl PT12_prepare_next_pt.pl $workdir/$cancertypefile $work_dir $i

done

