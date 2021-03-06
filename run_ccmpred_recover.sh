#!/usr/bin/env bash


#------------------------------------------------------------------------------
# This script runs CCMpredPy with persistent contrastive diverence for all
#   Pfam alignments in the PSICOV dataset.
#   The path to the directory containing the PSICOV data needs to be specified
#   by the first argument.
#   The second arguments specifies the number of OMP threads for parallelization.
#------------------------------------------------------------------------------



#------------------------------------------------------------------------------
# parameters
#------------------------------------------------------------------------------
data_dir=$1
num_threads=$2
topology=$3

#------------------------------------------------------------------------------
# set up OpenMP
#------------------------------------------------------------------------------
export OMP_NUM_THREADS=$num_threads
echo "using " $OMP_NUM_THREADS "threads for omp parallelization"

#------------------------------------------------------------------------------
# create data structure
#------------------------------------------------------------------------------
mat_dir=$data_dir"/recover_pcd_constrained/"
sample_dir=$data_dir"/samples_pcd_constrained/"

if [ ! -d $mat_dir ]
then
    mkdir $mat_dir
fi


#------------------------------------------------------------------------------
# settings for CCMpredPy
#------------------------------------------------------------------------------
settings=" --num-threads $num_threads --aln-format psicov"
settings=$settings" --wt-simple"
settings=$settings" --max-gap-seq 75 --max-gap-pos 50"
settings=$settings" --reg-lambda-single 10 --reg-lambda-pair-factor  0.2 --v-center"
settings=$settings" --pc-uniform --pc-single-count 1 --pc-pair-count 1"
settings=$settings" --ofn-cd --persistent"
settings=$settings" --nr-markov-chains 500 --gibbs_steps 1"
settings=$settings" --alpha0 0 --decay-start 1e-1 --decay-rate 5e-6 --decay-type sig"
settings=$settings" --maxit 5000 --epsilon 1e-8 --convergence_prev 5"


#------------------------------------------------------------------------------
# Run CCMpredPy
#------------------------------------------------------------------------------

for synthetic_alignment_file in $(ls $sample_dir/*.$topology.aln);
do

    name=$(basename $synthetic_alignment_file ".$topology.aln")

    file_paths=" -m $mat_dir/$name.raw.$topology.mat "
    file_paths=$file_paths" --apc $mat_dir/$name.apc.$topology.mat "
    file_paths=$file_paths" --entropy-correction $mat_dir/$name.ec.$topology.mat "
    file_paths=$file_paths" $synthetic_alignment_file "
    log_file=$mat_dir"/"$name.$topology.log

    if [ ! -f $log_file ]
    then
        echo -e "Running CCMpredPy with PCD for protein $name and topology $topology\n(Status is logged in: $log_file)"
        ccmpred $settings" "$file_paths > $log_file
    fi
done