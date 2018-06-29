# CCMgen Scripts

A collection of scripts to reproduce the results presented in the publication: 
"Synthetic protein alignments by CCMgen quantify noise in residue-residue contact prediction", currently available at bioRxiv, doi: [10.1101/344333](https://doi.org/10.1101/344333).


## Installation

Clone this repository by running the command: 

```bash
git clone https://github.com/soedinglab/ccmgen-scripts.git
```

## Dependencies

An installation of [CCMgen/CCMpredpy](https://github.com/soedinglab/CCMgen) is required.

## Download Data Set

First of all, download the [PSICOV dataset](http://bioinfadmin.cs.ucl.ac.uk/downloads/PSICOV/suppdata/) which is the basis for the following analysis.

```bash
mkdir psicov_data
cd psicov_data
wget http://bioinfadmin.cs.ucl.ac.uk/downloads/PSICOV/suppdata/suppdata.tar.gz
tar -xvf suppdata.tar.gz
```

You fill find the following organization of data in ```psicov_data```:

```
aln - contains the alignments. One aligned sequence per line with no header information.
seq - contains the target sequences in FASTA format.
con - contains the predictions made using PSICOV and the given alignments.
pdb - contains the repaired and renumbered PDB files for the 150 targets.
```

By running the following scripts, several new folders will be added to the directory that should not be moved or renamed!  

## Reproduce Raw Data

Specify the path to the PSICOV data set that you just downloaded and the number of OMP threads that you want to use for parallelization:

```bash
data_dir=path/to/psicov_data/
num_threads=4

```

In order to generate all the necessary data to reproduce the analysis presented in the paper, run the following scripts from the CCMgen-scripts repository main folder:

1.
	a) ```bash run_ccmpred_pll.sh $data_dir $num_threads```

	This command will call CCMpredPy, learn Markov random field (MRF) models using pseuod-likelihood maximization for all protein families in the PSICOV data set and compute contact maps from the models coupling parameters. 
	The matrix files *.raw.mat, *.apc.mat and raw coupling scores *.braw.gz will be written to ```$data_dir/predictions_pll```.
	This data is required to reproduce all subplots of Figure 1 and Figure 3.

	b) ```bash run_ccmpred_pcd.sh $data_dir $num_threads```

	This command will call CCMpredPy, learn Markov random field (MRF) models using persistent contrastive divergence for all protein families in the PSICOV data set and compute contact maps from the models coupling parameters.
        The matrix files *.raw.mat, *.apc.mat and raw coupling scores *.braw.gz will be written to ```$data_dir/predictions_pcd```.
        This data is required to reproduce all subplots of Figure 1 and Figure 3.

2.
	a) ```bash run_ccmgen_mcmc.sh $data_dir/predictions_pll $num_threads```

	This command will call CCMgen and generate MCMC samples from the MRF models learned in step 1a.
	The resulting *.mcmc.aln alignment files will be written to ```$data_dir/samples_pll```.
	This data is required to reproduce Figure 1A.

	b) ```bash run_ccmgen_mcmc.sh $data_dir/predictions_pcd $num_threads```

	This command will call CCMgen and generate MCMC samples from the MRF models learned in step 1b.
        The resulting *.mcmc.aln alignment files will be written to ```$data_dir/samples_pcd```.
        This data is required to reproduce Figure 1B.


3. ```bash run_ccmpred_pcd_with_constraints.sh $data_dir $num_threads```

	This command will call CCMpredPy, learn Markov random field (MRF) models using persistent contrastive divergence for all protein families in the PSICOV data set.
	Residue pairs that do not form contacts (C_beta distance > 12 Angstrom) in the reference protein structure will receive zero couplings and therefore the models will have less constraints than the ones learned in step 1b. 
	The resulting *.mat contact matrix files and the raw coupling scores *.braw.gz will be writtne to ```$data_dir\predictions_pcd_constrained```.
	This data is required to reproduce Figure 6. 

4.
	a) ```bash run_ccmgen.sh $data_dir $num_threads star```

	This command will call CCMgen to generate synthetic alignments along a STAR-tree topology using Gibbs sampling with the constraints from the MRF models learned in step 3 for all proteins in the data set. 
	The resulting *star.aln alignment files will be written to ```$data_dir/samples_pcd_constrained```.
	This data is required to reproduce Figure 6.

	b) ```bash run_ccmgen.sh $data_dir $num_threads binary```

	This command will call CCMgen to generate synthetic alignments along a BINARY-tree topology using Gibbs sampling with the constraints from the MRF models learned in step 3 for all proteins in the data set.    
        The resulting *binary.aln alignment files will be written to ```$data_dir/samples_pcd_constrained```.
        This data is required to reproduce Figure 6.
	
5.
	a) ```bash run_ccmpred_recover.sh $data_dir $num_threads star```

	This command will call CCMpredPy, learn MRF models using persistent contrastive divergence for all synthetic STAR-tree alignments generated in step 4a and compute contact maps from the model coupling parameters.
	The contact maps will be corrected with the average product correction (APC) and with the entropy correction (EC). 
	The resulting contact matrix files *.raw.star.mat, *.apc.star.mat and *.ec.star.mat will be written to ```$data_dir/recover_pcd_constrained```.
	This data is required to reproduce Figure 6.


	b) ```bash run_ccmpred_recover.sh $data_dir $num_threads binary```

	This command will call CCMpredPy, learn MRF models using persistent contrastive divergence for all synthetic BINARY-tree alignments generated in step 4b and compute contact maps from the model coupling parameters.
        The contact maps will be corrected with the average product correction (APC) and with the entropy correction (EC). 
        The resulting contact matrix files *.raw.binary.mat, *.apc.binary.mat and *.ec.binary.mat will be written to ```$data_dir/recover_pcd_constrained```.
        This data is required to reproduce Figure 6.


## Reproduce Figure 1

1. ```bash plot_fig_1ab.sh $data_dir```

	This command will generate plots like Figure 1A and 1A for all proteins in the PSICOV data set.
	In order to generate the plots, MRF models need to be learned by maximizing pseudo-likelihood and persistent contrastive divergence as described in step 1 and 2. 
	Furthermore, MCMC samples need to be generated in advance as described in step 3 and 4.
	Note: the generated .html files can become large!
	Plots will be written to ```$data_dir/plots/alignment_statistics/```.

2. ```python plot_fig_1c.py $data_dir```

	This script will reproduce the contact prediction benchmark for pseudo-likelihood and persistent contrastive divergence from Figure 1C. 	
	In order to generate the plots, MRF models need to be learned by maximizing pseudo-likelihood and persistent contrastive divergence as described in step 1 and 2.
	The plot is written to ```$data_dir/plots/benchmarks/fig_1c.html```.
	
3. ```python plot_fig_1d.py $data_dir```

	This command will generate boxplots to visualize the distribution of run times for learning MRF with CCMpredPy like in Figure 1D for all proteins in the data set. 
	In order to generate this plot, MRF models need to be learned by maximizing pseudo-likelihood and persistent contrastive divergence as described in step 1 and 2.
	The plot will be written to ```$data_dir/plots/fig_1d.html```.

## Reproduce Figure 3

1. ```bash plot_fig_3abc.sh $data_dir```

	This command will generate plots of the contact score matrices, comprising the raw contact scores and APC and entropy corrected scores for all proteins in the PSICOV data set.
	In order to generate the plots, MRF models need to be learned by maximizing pseudo-likelihood and persistent contrastive divergence as described in step 1 and 2.
	Plots will be written to ```$data_dir/plots/contact_maps/```.

2. ```python plot_fig_3d.py $data_dir```

	This command will generate scatter plots of the APC correction term vs the entropy correction term per residue pair for all proteins in the PSICOV data set.
	In order to generate the plots, MRF models need to be learned by maximizing pseudo-likelihood and persistent contrastive divergence as described in step 1 and 2.
	Plots will be written to ```$data_dir/plots/apc_vs_ec/```.

## Reproduce Figure 6


```python plot_fig_6.py $data_dir```

This script will reproduce Figures 6A, B and C.


## Reproduce Supplemental Figures

1. ```python plot_fig_S1.py $data_dir```
	
	This script will reproduce supplememtal Figure 1.
	It generates boxplots visualizing the pearson correlation coefficients between the alignment statistics from the original Pfam alignment and MCMC samples drawn from either a pseudo-likelihood MRF model or a MRF learned with PCD over all proteins in the PSICOV dataset.
	The plot will be written to ```$data_dir/plots/supplement/fig_S1.html```.

2. ```python plot_fig_S4.py $data_dir```

	This script will reproduce supplememtal Figure 4.
	It generates a boxplot visualizing the pearson correlation coefficients between the APC and EC correction terms for all pairs of residues over all proteins in the PSICOV dataset.
	The plot will be written to ```$data_dir/plots/supplement/fig_S4.html```.
		


3. ```python plot_fig_S5.py $data_dir```

	This script fill reproduce supplemental Figures 5A and 5B: 
	boxplots visualizing the distribution of mutation rates used for generating the synthetic alignments with CCMgen and boxplots visualizing the difference in Neff values between synthetic and original Pfam alignments.
	The plots will be written to ```$data_dir/plots/supplement/```.	




