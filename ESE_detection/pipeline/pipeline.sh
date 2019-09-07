#!/bin/sh

workdir=
genomedir=


cancertypefile=TCGA_cancertype_list.txt
refflatfile=refflat_SORT_2nd_ver2.txt
exonskipfile=exon_skip_junction_detail_type1.txt


perl $workdir/pipeline/copy_metafiles.pl $workdir $workdir/$cancertypefile

perl $workdir/pipeline/decompress_metafiles.pl $workdir $workdir/$cancertypefile

perl $workdir/pipeline/integrate_metafiles_ver2.pl $workdir $workdir/$cancertypefile

perl $workdir/pipeline/C1_classify_files.pl $workdir $workdir/$cancertypefile

perl $workdir/pipeline/P1_filename.pl $workdir $workdir/$cancertypefile

perl $workdir/pipeline/CT1-2_file_pickup_all.pl $workdir $workdir/$cancertypefile

perl $workdir/pipeline/CT2_integrate_maf_all.pl $workdir $workdir/$cancertypefile

perl $workdir/pipeline/CT3_count_raw_reads_and_normalize_all.pl $workdir $workdir/$cancertypefile

perl $workdir/pipeline/CT4_var_identification_located_exon.pl $workdir $workdir/$cancertypefile $workdir/$refflatfile

perl $workdir/pipeline/CT5_combine_exonskip_rpkm_variants.pl $workdir $workdir/$cancertypefile $workdir/$exonskipfile

perl $workdir/pipeline/CT6_rpkm_non_variant_exon.pl $workdir $workdir/$cancertypefile $workdir/$exonskipfile

perl $workdir/pipeline/CT7_judge.pl $workdir $workdir/$cancertypefile

perl $workdir/pipeline/CT8_ese_candidate_edit_for_Rtest.pl $workdir $workdir/$cancertypefile

R --vanilla --slave < R_ks_test_all.R

perl $workdir/pipeline/CT9_combine_pnorm_test_result_ks.pl $workdir $workdir/$cancertypefile

perl $workdir/pipeline/CT10_validation_ks.pl $workdir $workdir/$cancertypefile

perl $workdir/pipeline/CT11_merge_all_tissue_validated_ese_ks.pl $workdir $workdir/$cancertypefile

perl $workdir/pipeline/CT12_add_seq_around_mutation_ks.pl $workdir $genomedir

perl $workdir/pipeline/CT13_number_of_ALL_variants_in_each_gene_all.pl $workdir $workdir/$cancertypefile

perl $workdir/pipeline/CT14_cal_ese_proportion_all.pl $workdir $workdir/$cancertypefile

perl $workdir/pipeline/CT15_count_candidate_variants.pl $workdir $workdir/$cancertypefile

perl $workdir/pipeline/CT16_count_used_samples.pl $workdir $workdir/$cancertypefile








