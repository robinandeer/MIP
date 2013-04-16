#!/usr/bin/perl -w

use strict;
use warnings;

###Master script for analysing paired end reads from the Illumina plattform in fastq(.gz) format to sorted, dedupped and merged bam files. The program performs QC, aligns reads using Mosaik or BWA and generates a coverage report.
 
###Copyright 2011 Henrik Stranneheim

=head1 SYNOPSIS
    
mip_align.pl  -id [inFilesDirs,.,.,.,n] -ids [inScriptDir,.,.,.,n] -rd [reference dir] -p [project ID] -s [sampleIDs...n] -em [e-mail] -osd [outScriptDir] -odd [outDataDir] -f [familyID] -p[program]
    
=head2 COMMANDS AND OPTIONS

-ifd/--inFilesDirs Infile directory(s). Comma sep (Mandatory: Supply whole path)

-isd/--inScriptDir The pipeline script in directory (Mandatory: Supply whole path)

-rd/--referencesDir Reference(s) directory (Mandatory: Supply whole path)

-p/--projectID The project ID (Mandatory)

-s/--sampleIDs The sample ID(s) (Mandatory)

-em/--email

-odd/--outDataDir The data files output directory (Mandatory: Supply whole path)

-osd/--outScriptDir The script files (.sh) output directory (Mandatory: Supply whole path)

-f/--familyID Group id of samples to be compared (defaults to "0" (=no), (Ex: 1 for IDN 1-1-1A))

-pedigree/--pedigreeFile (Supply whole path, defaults to "")

-huref/--humanGenomeReference Fasta file for the human genome reference (defaults to "")

-al/--aligner Setting which aligner was used for alignment in previous analysis (defaults to "")

-wgs/--wholeGenomeSequencing Analysis to perform are based on whole genome sequencing data or not (defaults to "0" (=no))

-mc/--maximumCores The maximum number of cores per node used in the analysis (defaults to "8")

-env_up/--environmentUppmax Sets the environment to UPPMAX (defaults to "0" (=no))

-c/--configFile YAML config file for script parameters (defaults to "")

-wc/--writeConfigFile Write YAML config file with used script parameters. (defaults to "";Supply whole path)

-pGZ/--pGZip GZip fastq files (defaults to "1" (=yes))

-pFQC/--pFastQC Sequence quality analysis using FastQC (defaults to "1" (=yes))

-pREM/--pRemovalRedundantFiles Generating sbatch script for deletion of redundant files (defaults to "1" (=yes);Note: Must be submitted manually)

-pMoB/--pMosaikBuild Convert reads to Mosaik format using MosaikBuild (defaults to "1" (=yes))

-mobmfl/--mosaikBuildMedianFragLength Flag for setting the mean fragment length, mfl, (defaults to (=375) bp)

-pMoA/--pMosaikAlign Align reads using MosaikAlign (defaults to "1" (=yes))

-moaref/--mosaikAlignReference MosaikAlign reference (defaults to "")

-moaannpe/--mosaikAlignNeuralNetworkPeFile MosaikAlign Neural Network PE File (defaults to "")

-moaannse/--mosaikAlignNeuralNetworkSeFile MosaikAlign Neural Network SE File (defaults to "")

-mojdb/--mosaikJumpDbStub MosaikJump stub (defaults to "")

-pBWA_aln/--pBwaAln Index reads using BWA Aln (defaults to "0" (=no))

-bwaalnq/--bwaAlnQualityTrimming BWA Aln quality threshold for read trimming (defaults to "20")

-pBWA_sampe/--pBwaSampe Align reads using BWA Sampe (defaults to "0" (=no))

-pSamT_sort/--pSamToolsSort Sort & index aligned reads using SamTools sort & index (defaults to "1" (=yes))

-picardpath/--picardToolsPath Path to PicardTools. Mandatory for use of PicardTools (defaults to "")

-pPicT_merge/--pPicardToolsMergeSamFiles Merge (BAM file(s)) using PicardTools MergeSamFiles (defaults to "0" (=no))

-pictmergetmpd/--PicardToolsMergeTempDirectory Temporary Directory to write to using PicardTools MergeSamFiles (defaults to "/scratch/$SLURM_JOB_ID";Supply whole path)

-picT_mergeprev/--picardToolsMergeSamFilesPrevious Flag running picardTools MergeSamFiles on merged current files and previous BAM-file(s) (Supply whole path and name, name must contain sample id, and lanes_Xn info)

-pPicT_markdup/--pPicardToolsMarkduplicates Markduplicates using PicardTools MarkDuplicates (defaults to "1" (=yes))

-pCC/--pCalculateCoverage Use coverage calculation tools: qaCompute, genomeCoverageBED and PicardTools (MultipleMetrics & HSmetrics) (defaults to "1" (=yes))

-pCC_bedgc/--pGenomeCoverageBED Genome coverage calculation using genomeCoverageBED under '-pCC' (defaults to "1" (=yes))

-pCC_bedc/--pCoverageBED BED file coverage calculation using coverageBED under '-pCC' (defaults to "1" (=yes))

-extb/--exomeTargetBed Target BED file of exome capture for coverageBed '-pCC_bedc' (defaults to "")

-pCC_qac/--pQaCompute Genome coverage calculation using qaCompute under '-pCC' (defaults to "1" (=yes))

-xcov/--xCoverage Max coverage depth when using '-genomeCoverageBED', '-qaCompute' (defaults to "30")

-pCC_picmm/--pPicardToolsCollectMultipleMetrics Metrics calculation using PicardTools collectMultipleMetrics under '-pCC' (defaults to "1" (=yes))

-pCCE_pichs/--pPicardToolsCalculateHSMetrics Capture calculation using PicardTools CalculateHSmetrics under '-pCC' (defaults to "1" (=yes))

-extbl/--exomeTargetBedInfileList Prepared target BED file for PicardTools CalculateHSMetrics (defaults to "". File ending should be ".infile_list")
              
-extpbl/--exomeTargetPaddedBedInfileList Prepared padded target BED file for PicardTools CalculateHSMetrics (defaults to "". File ending should be ".padXXX.infile_list")

-pRCP/--pRCovPlots Plots of genome coverage using rCovPlots (defaults to "1" (=yes))

-pSamT_view/--pSamToolsViewSplitChr Split BAM file into individual chromosomes & index using samTools view (defaults to "1" (=yes))

-gatkpath/--genomeAnalysisToolKitPath  Path to GATK. Mandatory for use of GATK (defaults to "")

-gatktmpd/--GATKTempDirectory Temporary Directory to write to using GATK ReAlignerTargetCreator & BaseRecalibrator (defaults to "/scratch/$SLURM_JOB_ID";Supply whole path)

-gatktpbl/--GATKTargetPaddedBedIntervalList Target BED file interval for GATK (defaults to "". File ending should be ".padXXX.interval_list")

-pGATK_real/--pGATKRealigner Realignments of reads using GATK ReAlignerTargetCreator/IndelRealigner (defaults to "1" (=yes))

-gatkrealknset1/--GATKReAlignerINDELKnownSet1 GATK ReAlignerTargetCreator/IndelRealigner known INDEL set 1 (defaults to "1000G_phase1.indels.hg19.vcf")

-gatkrealknset2/--GATKReAlignerINDELKnownSet2 GATK ReAlignerTargetCreator/IndelRealigner known INDEL set 2 (defaults to "Mills_and_1000G_gold_standard.indels.hg19.sites.vcf")

-pGATK_baserecal/--pGATKBaseRecalibration Recalibration of bases using GATK BaseRecalibrator/PrintReads (defaults to "1" (=yes))

-gatkbaserecalknset/--GATKBaseReCalibrationSNPKnownSet GATK BaseReCalinbration known SNP set (defaults to "dbsnp_135.b37.vcf")

-pGATK_hapcall/--pGATKHaploTypeCaller Variant discovery using GATK HaplotypeCaller (defaults to "1" (=yes))

-gatkhapcallsnpknset/--GATKHaploTypeCallerSNPKnownSet GATK HaplotypeCaller dbSNP set for annotating ID columns (defaults to "dbsnp_135.b37.vcf")

-pGATK_varrecal/--pGATKVariantRecalibration Variant recalibration using GATK VariantRecalibrator/ApplyRecalibration (defaults to "1" (=yes))

-gatkexrefsnp/--GATKExomeReferenceSNPs Prepared exome reference file (SNVs) for GATKVariantRecalibration (defaults to "")

-gatkvarrecaltrhapmap/--GATKVariantReCalibrationTrainingSetHapMap GATK VariantRecalibrator HapMap training set (defaults to "hapmap_3.3.b37.sites.vcf")

-gatkvarrecaltrdbsnp/--GATKVariantReCalibrationTrainingSetDbSNP GATK VariantRecalibrator dbSNP training set (defaults to "dbsnp_135.b37.vcf")

-gatkvarrecaltromni/--GATKVariantReCalibrationTrainingSet1000GOmni GATK VariantRecalibrator 1000G_omni training set (defaults to "1000G_omni2.5.b37.sites.vcf")

-gatkvarrecaltrdbmills/--GATKVariantReCalibrationTrainingSetMills GATK VariantRecalibrator Mills training set (defaults to "Mills_and_1000G_gold_standard.indels.hg19.sites.vcf")

-gatkvarrecaltsfilterlevel/--GATKVariantReCalibrationTSFilterLevel The truth sensitivity level at which to start filtering used in GATK VariantRecalibrator (defaults to "99.9")

-pGATK_varevalall/--pGATKVariantEvalAll Variant evaluation using GATK VariantEval for all variants  (defaults to "1" (=yes))

-pGATK_varevalexome/--pGATKVariantEvalExome Variant evaluation using GATK VariantEval for exonic variants  (defaults to "1" (=yes))

-gatkvarevaldbsnp/--GATKVariantEvalDbSNP DbSNP file used in GATK VariantEval (defaults to "")
 
-gatkvarevaldbgold/--GATKVariantEvalGold Gold Indel file used in GATK VariantEval (defaults to "")

-pANVAR/--pAnnovar Annotate variants using Annovar (defaults to "1" (=yes))

-anvarpath/--annovarPath  Path to Annovar script directory (Supply whole path, defaults to "". NOTE: Assumes that the annovar db files are located in annovar/humandb)

-anvargbv/--annovarGenomeBuildVersion Annovar genome build version (defaults to "hg19")

-anvartn/--annovarTableNames Annovar table names (comma sep)

-anvarstn/--annovarSupportedTableNames Print Annovar MIP supported table names (defaults 0 (=no))

-anvarmafth/--annovarMAFThreshold Sets the minor allele frequency threshold in annovar (defaults to "0")

-anvarsiftth/--annovarSiftThreshold Sets the avsift threshold in annovar (defaults to "0")

-pMerge_anvar/--pMergeAnnotatedVariants Merge (& annotate) all annotated variants into one file using intersectCollect.pl to  (defaults to "1" (=yes))

-mergeanvarte/--mergeAnnotatedVariantsTemplateFile Db template file used to create the specific family '-vm_dbf' master file (defaults to "")

-mergeanvardbf/--mergeAnnotatedVariantsDbFile Db master file to be used in intersectCollect.pl (defaults to "")

-pAdd_dp/--pAddDepth Adds read depth at nonvariant sites using SamTools mpileup and add_depth.pl (defaults to "1" (=yes))

-pRankVar/--pRankVariants Ranking of annotated variants (defaults to "1" (=yes))

-rs/--rankScore The rank score cut-off (defaults to "-100", .i.e. include everything)

-gf/--geneFiltering Filtering of genes that should be removed from downstream processing (Defaults to "1" (=yes))

-gfl/--geneFilteringList List of genes that should be removed from downstream processing (Supply whole path, Format: 1 entry per line;HGNC Symbol)

-alldbfile/--allElementsDbFile All elements Db file (Defaults to "")

-alldbcc/--allElementsDbGeneCoverageCalculation All elements Db file coverage calculation (Defaults to "1" (=yes))

-alldbgidc/--allElementsDbGeneIdCol All elements Db file gene ID column (zero-based, defaults to "4")

-imdbfile/--ImportantDbFile Important Db file (Defaults to "")

-imdbte/--ImportantDbTemplate Important Db template file used to create the specific family '-im_dbmf' master file (Defaults to "")

-imdbmf/--ImportantDbMasterFile Importnat Db master file to be used when selecting variants (defaults to "")

-imdbfof/--ImportantDbFileOutFile The file(s) to write to when selecting variants with intersectCollect.pl. Comma sep (defaults to "outDataDir/familyID/aligner/GATK/candidates/ranking/familyID_orphan.selectVariants, outDataDir/familyID/aligner/GATK/candidates/ranking/IEM_Db_CMMS/familyID.selectVariants"; Supply whole path/file)

-imdbcc/--ImportantDbGeneCoverageCalculation Important Db gene coverage calculation (Defaults to "1" (=yes))

-imdbgidc/--ImportantDbGeneIdCol Important Db gene file gene ID column (zero-based, defaults to "18")

-pSCheck/--pSampleCheck QC for samples gender and relationship (defaults to "1" (=yes) )

=head3 I/O

Input format ( dir/infile.fastq or dir/infile.fastq.gz)

Output format

1. FastQC files/Gzipped fastq files
2. Mosaik.dat 
3. Mosaik.bam
4. Mosaik_sorted.bam(.bai)
5. Mosaik_lanes_sorted_merged.bam(.bai)
6. calculateCoverage_results
7. Coverage plots
8. Bwa.sai
9. Bwa.sam
10. Bwa.bam
11. Bwa_sorted.bam(.bai)
12. Bwa_lanes_sorted_merged.bam

=head4 Dependencies

Local installation of:
Mosaik
BWA
SamTools
BedTools
PicardTools
qaCompute
perl module YAML

Located in -rd, reference dir
Genome reference

Mosaik
1. .dat files of genome reference
2. Jump database keys, positions, meta
3. Neural network .ann (PE & SE)

BWA
1. BWA index files (amb,ann,bwt etc)

calculateCoverage
1. Target file
2. Genome reference file
3. Target.infile_list
4. Padded bed.infile_list

Located in -ids, inScriptDir
R scripts
1. covplots_genome.R
2. covplots_exome.R 

=cut
    
use Pod::Usage;
use Pod::Text;
use Getopt::Long;
use POSIX;

use vars qw($USAGE);

BEGIN {
    $USAGE =
	qq{
mip_align.pl  -id [inFilesDirs,.,.,.,n] -ids [inScriptDir,.,.,.,n] -rd [refdir] -p [project ID] -s [sample ID...n] -em [e-mail] -ods [outdirscripts] -odf [outDataDir] -f [familyID] -p[program]
               ####MIP
	       -ifd/--inFilesDirs Infile directory(s), comma sep (Mandatory: Supply whole path,)
               -isd/--inScriptDir The pipeline custom script in directory (Mandatory: Supply whole path)
               -rd/--referencesDir Reference(s) directory (Mandatory: Supply whole path)
	       -p/--projectID The project ID  (Mandatory)
	       -s/--sampleIDs The sample ID(s),comma sep (Mandatory)
	       -em/--email E-mail
	       -odd/--outDataDir The data files output directory (Mandatory: Supply whole path)
	       -osd/--outScriptDir The script files (.sh) output directory (Mandatory: Supply whole path)
               -f/--familyID Group id of samples to be compared (defaults to "0" (=no), (Ex: 1 for IDN 1-1-1A))
               -pedigree/--pedigreeFile (Supply whole path, defaults to "")
               -huref/--humanGenomeReference Fasta file for the human genome reference (defaults to "")
               -al/--aligner Setting which aligner was used for alignment in previous analysis (defaults to "")
               -wgs/--wholeGenomeSequencing Analysis to perform are based on whole genome sequencing data or not (defaults to "0" (=no))
               -mc/--maximumCores The maximum number of cores per node used in the analysis (defaults to "8")
               -env_up/--environmentUppmax Sets the environment to UPPMAX (defaults to "0" (=no))
               -c/--configFile YAML config file for script parameters (defaults to "")
               -wc/--writeConfigFile Write YAML configuration file for script parameters (defaults to "";Supply whole path)
               -h/--help Display this help message               

               
               ####Programs
               -pGZ/--pGZip GZip fastq files (defaults to "1" (=yes))
	       -pFQC/--pFastQC Sequence quality analysis using FastQC (defaults to "1" (=yes))
               -pREM/--pRemovalRedundantFiles Generating sbatch script for deletion of redundant files (defaults to "1" (=yes);Note: Must be submitted manually)
               
               ##Mosaik
	       -pMoB/--pMosaikBuild  Convert reads to Mosaik format using MosaikBuild (defaults to "1" (=yes))
                -mobmfl/--mosaikBuildMedianFragLength Flag for setting the mean fragment length, mfl, (defaults to (=375) bp)
	       -pMoA/--pMosaikAlign Align reads using MosaikAlign (defaults to "1" (=yes))
                 -moaref/--mosaikAlignReference MosaikAlign reference (defaults to "")
                 -moaannpe/--mosaikAlignNeuralNetworkPeFile MosaikAlign Neural Network PE File (defaults to "")
                 -moaannse/--mosaikAlignNeuralNetworkSeFile MosaikAlign Neural Network SE File (defaults to "")
                 -mojdb/--mosaikJumpDbStub MosaikJump stub (defaults to "")
               
               ##BWA
               -pBWA_aln/--pBwaAln Index reads using BWA Aln (defaults to "0" (=no))
                 -bwaalnq/--bwaAlnQualityTrimming BWA Aln quality threshold for read trimming (defaults to "20")
               -pBWA_sampe/--pBwaSampe Align reads using BWA Sampe (defaults to "0" (=no))
               
               -pSamT_sort/--pSamToolsSort Sort & index aligned reads using SamTools sort & index (defaults to "1" (=yes))
               
               ##PicardTools
               -picardpath/--picardToolsPath Path to PicardTools. Mandatory for use of PicardTools (defaults to "")
               -pPicT_merge/--pPicardToolsMergeSamFiles Merge (BAM file(s) ) using PicardTools MergeSamFiles (defaults to "0" (=no))
                 -pictmergetmpd/--PicardToolsMergeTempDirectory Temporary Directory to write to using PicardTools MergeSamFiles (defaults to "/scratch/SLURM_JOB_ID";Supply whole path)
                 -picT_mergeprev/--picardToolsMergeSamFilesPrevious PicardTools MergeSamFiles on merged current files and previous BAM-file(s) (Supply whole path and name, name must contain sample id, and lanes_Xn info)
               -pPicT_markdup/--pPicardToolsMarkduplicates Markduplicates using PicardTools MarkDuplicates (defaults to "1" (=yes))
               
               ##Coverage Calculations
               -pCC/--pCalculateCoverage Use coverage calculation tools: qaCompute, genomeCoverageBED and PicardTools (MultipleMetrics & HSmetrics) (defaults to "1" (=yes))
               -pCC_bedgc/--pGenomeCoverageBED Genome coverage calculation using genomeCoverageBED under '-pCC' (defaults to "1" (=yes))
               -pCC_bedc/--pCoverageBED BED file coverage calculation using coverageBED under '-pCC' (defaults to "1" (=yes))
                 -extb/--exomeTargetBed Target BED file of exome capture for coverageBed '-pCC_bedc' (defaults to "")
               -pCC_qac/--pQaCompute Genome coverage calculation using qaCompute under '-pCC' (defaults to "1" (=yes))
               -xcov/--xCoverage Max coverage depth when using '-genomeCoverageBED', '-qaCompute' (defaults to "30")
               -pCC_picmm/--pPicardToolsCollectMultipleMetrics Metrics calculation using PicardTools collectMultipleMetrics under '-pCC' (defaults to "1" (=yes))
               -pCCE_pichs/--pPicardToolsCalculateHSMetrics Capture calculation using PicardTools CalculateHSmetrics under '-pCC' (defaults to "1" (=yes))
                 -extbl/--exomeTargetBedInfileList Prepared target BED file for PicardTools CalculateHSMetrics (defaults to "". File ending should be ".infile_list") 
                 -extpbl/--exomeTargetPaddedBedInfileList Prepared padded target BED file for PicardTools CalculateHSMetrics (defaults to "". File ending should be ".padXXX.infile_list")
               -pRCP/--pRCovPlots Plots of genome coverage using rCovPlots (defaults to "1" (=yes))
               
               ##GATK
               -pSamT_view/--pSamToolsViewSplitChr Split BAM file into individual chromosomes & index using samTools view (defaults to "1" (=yes))
               -gatkpath/--genomeAnalysisToolKitPath  Path to GATK. Mandatory for use of GATK (defaults to "")
               -gatktmpd/--GATKTempDirectory Temporary Directory to write to using GATK ReAlignerTargetCreator & BaseRecalibrator (defaults to "/scratch/SLURM_JOB_ID";Supply whole path)
               -gatktpbl/--GATKTargetPaddedBedIntervalList Target BED file interval for GATK (defaults to "". File ending should be ".padXXX.interval_list")
               -pGATK_real/--pGATKRealigner Realignments of reads using GATK realign (defaults to "1" (=yes))
                 -gatkrealknset1/--GATKReAlignerINDELKnownSet1 GATK ReAlignerTargetCreator/IndelRealigner known INDEL set 1 (defaults to "1000G_phase1.indels.hg19.vcf")
                 -gatkrealknset2/--GATKReAlignerINDELKnownSet2 GATK ReAlignerTargetCreator/IndelRealigner known INDEL set 2 (defaults to "Mills_and_1000G_gold_standard.indels.hg19.sites.vcf")
               -pGATK_baserecal/--pGATKBaseRecalibration Recalibration of bases using GATK BaseRecalibrator/PrintReads (defaults to "1" (=yes))
                 -gatkbaserecalknset/--GATKBaseReCalibrationSNPKnownSet GATK BaseReCalinbration known SNP set (defaults to "dbsnp_135.b37.vcf")
               -pGATK_hapcall/--pGATKHaploTypeCaller Variant discovery using GATK HaplotypeCaller (defaults to "1" (=yes))
                 -gatkhapcallsnpknset/--GATKHaploTypeCallerSNPKnownSet GATK HaplotypeCaller dbSNP set for annotating ID columns (defaults to "dbsnp_135.b37.vcf")
               -pGATK_varrecal/--pGATKVariantRecalibration Variant recalibration using GATK VariantRecalibrator/ApplyRecalibration (defaults to "1" (=yes))
                 -gatkexrefsnp/--GATKExomeReferenceSNPs Prepared exome reference file (SNVs) for GATKVariantRecalibration (defaults to "")
                 -gatkvarrecaltrhapmap/--GATKVariantReCalibrationTrainingSetHapMap GATK VariantRecalibrator HapMap training set (defaults to "hapmap_3.3.b37.sites.vcf")
                 -gatkvarrecaltrdbsnp/--GATKVariantReCalibrationTrainingSetDbSNP GATK VariantRecalibrator dbSNP training set (defaults to "dbsnp_135.b37.vcf")
                 -gatkvarrecaltromni/--GATKVariantReCalibrationTrainingSet1000GOmni GATK VariantRecalibrator 1000G_omni training set (defaults to "1000G_omni2.5.b37.sites.vcf")
                 -gatkvarrecaltrdbmills/--GATKVariantReCalibrationTrainingSetMills GATK VariantRecalibrator Mills training set (defaults to "Mills_and_1000G_gold_standard.indels.hg19.sites.vcf")
                 -gatkvarrecaltsfilterlevel/--GATKVariantReCalibrationTSFilterLevel The truth sensitivity level at which to start filtering used in GATK VariantRecalibrator (defaults to "99.9")
               -pGATK_varevalall/--pGATKVariantEvalAll Variant evaluation using GATK VariantEval for all variants  (defaults to "1" (=yes))
               -pGATK_varevalexome/--pGATKVariantEvalExome Variant evaluation using GATK VariantEval for exonic variants  (defaults to "1" (=yes))
                 -gatkvarevaldbsnp/--GATKVariantEvalDbSNP DbSNP file used in GATK VariantEval (defaults to "")
                 -gatkvarevaldbgold/--GATKVariantEvalGold Gold Indel file used in GATK VariantEval (defaults to "")
               
               ##ANNOVAR
               -pANVAR/--pAnnovar Annotate variants using Annovar (defaults to "1" (=yes))
                 -anvarpath/--annovarPath  Path to Annovar script directory (Supply whole path, defaults to "". NOTE: Assumes that the annovar db files are located in annovar/humandb)
                 -anvargbv/--annovarGenomeBuildVersion Annovar genome build version (defaults to "hg19")
                 -anvartn/--annovarTableNames Annovar table names (comma sep)
                 -anvarstn/--annovarSupportedTableNames Print Annovar MIP supported table names (defaults 0 (=no))
                 -anvarmafth/--annovarMAFThreshold Sets the minor allele frequency threshold in annovar (defaults to "0")
                 -anvarsiftth/--annovarSiftThreshold Sets the avsift threshold in annovar (defaults to "0")   
               
               ##VMerge  
               -pMerge_anvar/--pMergeAnnotatedVariants Merge (& annotate) all annotated variants into one file using intersectCollect.pl to  (defaults to "1" (=yes))
                 -mergeanvarte/--mergeAnnotatedVariantsTemplateFile Db template file used to create the specific family '-mergeanvardbf' master file (defaults to "")
                 -mergeanvardbf/--mergeAnnotatedVariantsDbFile Db master file to be used in intersectCollect.pl (defaults to "")

               ##Add_depth
               -pAdd_dp/--pAddDepth Adds read depth at nonvariant sites using SamTools mpileup and add_depth.pl (defaults to "1" (=yes))

               ##RankVariants
               -pRankVar/--pRankVariants Ranking of annotated variants (defaults to "1" (=yes))
                 -rs/--rankScore The rank score cut-off (defaults to "-100", .i.e. include everything)
                 -gf/--geneFiltering Filtering of genes that should be removed from downstream processing (Defaults to "1" (=yes))
                 -gfl/--geneFilteringList List of genes that should be removed from downstream processing (Supply whole path, Format: 1 entry per line;HGNC Symbol)
                 -alldbfile/--allElementsDbFile All elements Db file (Defaults to "")
                 -alldbcc/--allElementsDbGeneCoverageCalculation All elements Db file coverage calculation (Defaults to "1" (=yes))
                 -alldbgidc/--allElementsDbGeneIdCol All elements Db file gene ID column (zero-based, defaults to "4")
                 -imdbfile/--ImportantDbFile Important Db file (Defaults to "")
                 -imdbte/--ImportantDbTemplate Important Db template file used to create the specific family '-im_dbmf' master file (Defaults to "")
                 -imdbmf/--ImportantDbMasterFile Importnat Db master file to be used when selecting variants (defaults to "") 
                 -imdbfof/--ImportantDbFileOutFile The file(s) to write to when selecting variants with intersectCollect.pl. Comma sep (defaults to "outDataDir/familyID/aligner/GATK/candidates/ranking/familyID_orphan.selectVariants, outDataDir/familyID/aligner/GATK/candidates/ranking/IEM_Db_CMMS/familyID.selectVariants"; Supply whole path/file)
                 -imdbcc/--ImportantDbGeneCoverageCalculation Important Db gene coverage calculation (Defaults to "1" (=yes))
                 -imdbgidc/--ImportantDbGeneIdCol Important Db gene file gene ID column (zero-based, defaults to "18")
               
               -pSCheck/--pSampleCheck QC for samples gender and relationship (defaults to "1" (=yes) )
	   };
}


####Program parameters

##Project specific
my ($projectID,$email, $wholeGenomeSequencing, $familyID, $outScriptDir, $outDataDir, $inScriptDir, $referencesDir, $pedigreeFile, $configFile, $writeConfigFile) = (-1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0);
my (@inFilesDirs,@sampleIDs); #Arrays for input file directorys,sampleIDs

##GZip
my ($pGZip) = (-1);

##FastQC
my ($pFastQC) = (-1);

##Mosaik
my ($pMosaikBuild, $pMosaikAlign) = (-1, -1);
my ($mosaikBuildMedianFragLength, $mosaikAlignReference, $mosaikAlignNeuralNetworkPeFile, $mosaikAlignNeuralNetworkSeFile, $mosaikJumpDbStub) = (-1,0,0,0,0);

##BWA
my ($pBwaAln, $pBwaSampe) = (-1, -1);
my ($bwaAlnQualityTrimming) = (-1);

##SamTools
my ($pSamToolsSort, $pSamToolsViewSplitChr) = (-1, -1);

##PicardTools
my ($picardToolsPath, $PicardToolsMergeTempDirectory) = (0, 0);
my ($pPicardToolsMergeSamFiles, $pPicardToolsMarkduplicates) = (-1, -1);
my (@picardToolsMergeSamFilesPrevious);

##Coverage
my ($pCalculateCoverage, $pGenomeCoverageBED, $pCoverageBED, $pQaCompute, $pPicardToolsCollectMultipleMetrics, $pPicardToolsCalculateHSMetrics, $pRCovPlots) = (-1, -1, -1, -1, -1, -1, -1);
my ($exomeTargetBed, $exomeTargetBedInfileList, $exomeTargetPaddedBedInfileList, $xCoverage, $identicalCaptureBedCounter, $identicalCaptureBedIntervalCounter, $identicalCaptureBedPaddedIntervalCounter) = (0, 0, 0, -1, 0, 0, 0);

##GATK
my ($genomeAnalysisToolKitPath, $GATKTempDirectory, $GATKTargetPaddedBedIntervalList) = (0, 0, 0);
my $pGATKRealigner = -1;
my ($GATKReAlignerINDELKnownSet1, $GATKReAlignerINDELKnownSet2) = (0, 0, 0);
my $pGATKBaseRecalibration = -1;
my ($GATKBaseReCalibrationSNPKnownSet) = (0);
my $pGATKHaploTypeCaller = -1;
my ($GATKHaploTypeCallerSNPKnownSet) = (0);
my $pGATKVariantRecalibration = -1;
my ($GATKExomeReferenceSNPs, $GATKVariantReCalibrationTrainingSetHapMap, $GATKVariantReCalibrationTrainingSetDbSNP, $GATKVariantReCalibrationTrainingSet1000GOmni, $GATKVariantReCalibrationTrainingSetMills, $GATKVariantReCalibrationTSFilterLevel) = (0, 0, 0, 0, 0, 0);
my $pGATKVariantEvalAll = -1;
my $pGATKVariantEvalExome = -1;
my ($GATKVariantEvalDbSNP, $GATKVariantEvalGold) = (0, 0);

##Annovar
my $pAnnovar = -1;
my ($annovarPath, $annovarGenomeBuildVersion, $annovarSupportedTableNames, $annovarMAFThreshold, $annovarSiftThreshold) = (0, -1, -1, -1, -1);
my @annovarTableNames;

##VMerge
my $pMergeAnnotatedVariants = -1;
my ($mergeAnnotatedVariantsTemplateFile, $mergeAnnotatedVariantsDbFile) = (0,-1);

##Add_depth
my $pAddDepth = -1;

##RankVariants
    my $pRankVariants = -1;
my ($rankScore, $geneFiltering, $geneFilteringList, $allElementsDbFile, $allElementsDbGeneCoverageCalculation, $allElementsDbGeneIdCol, $ImportantDbFile, $ImportantDbTemplate, $ImportantDbMasterFile, $ImportantDbGeneCoverageCalculation, $ImportantDbGeneIdCol) = (-1, -1, 0, 0, -1, -1, 0, 0, -1, -1, -1);
my @ImportantDbFileOutFile;

##SChecks
my $pSampleCheck = -1;

##MIP
my ($pRemovalRedundantFiles) = (-1);
my ($humanGenomeReference, $humanGenomeReferenceSource, $humanGenomeRefereceChromosomePrefix, $humanGenomeReferenceVersion, $fnend, $maximumCores, $environmentUppmax, $aligner, $filename, $fnt, $fnt2, $help) = (0, 0, 0, 0, ".sh", 0, -1, -1);
my (@chromosomes);
my (%infile, %indirpath, %infilesLaneNoEnding, %lane, %infilesBothStrandsNoEnding, %jobID, %paralleljobID, %allsampleIDjobID, %sampleInfo, %scriptParameter); 
#%infiles=from platform (Illumina), %indirpath for the path to infiles, %infilesLaneNoEnding for MosaikBuild (one entry for both strands), %lanes for sample lanes, infilesBothStrandsNoEnding for bwa_aln (one entry per strand)


####Staging/Sanity Check Area 

##Capture kits supported from pedigree file.
my %supportedCaptureKits = (
    'Nimblegen_SeqCapEZExome.V2' => "Nimblegen_SeqCapEZExome.V2.GenomeReferenceSourceVersion_targets_ChromosomePrefix.bed",
    'Agilent_SureSelect.V2' => "Agilent_SureSelect.V2.GenomeReferenceSourceVersion_targets_ChromosomePrefix.bed",
    'Agilent_SureSelect.V3' => "Agilent_SureSelect.V3.GenomeReferenceSourceVersion_targets_ChromosomePrefix.bed",
    'Agilent_SureSelect.V4' => "Agilent_SureSelect.V4.GenomeReferenceSourceVersion_targets_ChromosomePrefix.bed",
    'Agilent_SureSelect.V5' => "Agilent_SureSelect.V5.GenomeReferenceSourceVersion_targets_ChromosomePrefix.bed",
    );

##Set supported annovar table name filtering options
my @annovarSupportedTableNames = ("refgene", "knownGene", "ensGene", "mce46way", "gerp++elem", "segdup", "gwascatalog", "tfbs", "mirna", "snp137", "snp135", "snp132", "snp131", "snp130", "snp129", "snp137NonFlagged", "snp135NonFlagged", "snp132NonFlagged", "snp131NonFlagged", "snp130NonFlagged", "1000g2012apr_all", "1000g2012apr_amr", "1000g2012apr_eur", "1000g2012apr_asn", "1000g2012apr_afr", "1000g2012feb_all", "hg19_esp6500si_all.txt", "hg19_esp6500_all.txt", "hg19_esp6500_aa.txt", "hg19_esp6500_ea.txt", "hg19_esp5400_all.txt", "hg19_esp5400_aa.txt", "hg19_esp5400_ea.txt", "avsift", "ljb_sift", "ljb_pp2", "ljb_mt", "ljb_lrt", "ljb_all", "ljb_gerp++", "ljb_phylop"); #Used to print list of supported table names

my %annovarFilteringOption = ( 
    'refgene' => "geneanno",
    'knownGene' => "geneanno",
    'ensGene' => "geneanno",
    'mce46way' => "regionanno",
    'gerp++elem' => "regionanno",
    'segdup' => "regionanno",
    'gwascatalog' => "regionanno",
    'tfbs' => "regionanno",
    'mirna' => "regionanno",
    'snp137' => "filter",
    'snp135' => "filter",
    'snp132' => "filter",
    'snp131' => "filter",
    'snp130' => "filter",
    'snp129' => "filter",
    'snp137NonFlagged' => "filter",    
    'snp135NonFlagged' => "filter",
    'snp132NonFlagged' => "filter",
    'snp131NonFlagged' => "filter",
    'snp130NonFlagged' => "filter",
    '1000g2012apr_all' => "filter",
    '1000g2012apr_amr' => "filter",
    '1000g2012apr_eur' => "filter",
    '1000g2012apr_asn' => "filter",
    '1000g2012apr_afr' => "filter",
    '1000g2012feb_all' => "filter",
    'hg19_esp6500si_all.txt' => "filter",
    'hg19_esp6500_all.txt' => "filter",
    'hg19_esp6500_aa.txt' => "filter",
    'hg19_esp6500_ea.txt' => "filter",
    'hg19_esp5400_all.txt' => "filter",
    'hg19_esp5400_aa.txt' => "filter",
    'hg19_esp5400_ea.txt' => "filter",
    'avsift' => "filter",
    'ljb_sift' => "filter",
    'ljb_pp2' => "filter",
    'ljb_mt' => "filter",
    'ljb_lrt' => "filter",
    'ljb_all' => "filter",
    'ljb_gerp++' => "filter",
    'ljb_phylop' => "filter",
    );

##Set supported annovar table name generic type
my %annovarGenericFilteringOption = ( 
    'hg19_esp6500si_all.txt' => "generic",    
    'hg19_esp6500_all.txt' => "generic",
    'hg19_esp6500_aa.txt' => "generic",
    'hg19_esp6500_ea.txt' => "generic",
    'hg19_esp5400_all.txt' => "generic",
    'hg19_esp5400_aa.txt' => "generic",
    'hg19_esp5400_ea.txt' => "generic",
    );


###User Options

GetOptions('ifd|inFilesDirs:s'  => \@inFilesDirs, #Comma separated list
	   'isd|inScriptDir:s'  => \$inScriptDir, #Directory for custom scripts required by the pipeline
	   'rd|referencesDir:s'  => \$referencesDir, #directory containing references
	   'p|projectID:s'  => \$projectID,
	   's|sampleIDs:s'  => \@sampleIDs, #Comma separated list, one below outDataDir
	   'em|email:s'  => \$email,
	   'odd|outDataDir:s'  => \$outDataDir, #One dir above sample id, must supply whole path i.e. /proj/...
	   'osd|outScriptDir:s'  => \$outScriptDir,  #One dir above sample id, must supply whole path i.e. /proj/...
	   'f|familyID:s' => \$familyID, #Family group ID (Merged to same vcf file after GATK Base Recalibration)
	   'pedigree|pedigreeFile:s' => \$pedigreeFile, #Pedigree file
	   'huref|humanGenomeReference:s' => \$humanGenomeReference, #Human genome reference
	   'al|aligner:s' => \$aligner, #determining which aligner was used previously (if not specified)
	   'wgs|wholeGenomeSequencing:n' => \$wholeGenomeSequencing,
	   'mc|maximumCores:n' => \$maximumCores, #Per node
	   'env_up|environmentUppmax:n' => \$environmentUppmax, #Sets several default paths, so that they do not have to be supplied
	   'c|configFile:s' => \$configFile,
	   'wc|writeConfigFile:s' => \$writeConfigFile,
	   'h|help' => \$help, #Display help text
	   'pGZ|pGZip:n' => \$pGZip,
	   'pFQC|pFastQC:n' => \$pFastQC,
	   'pREM|pRemovalRedundantFiles:n' => \$pRemovalRedundantFiles,
	   'pMoB|pMosaikBuild:n' => \$pMosaikBuild,
	   'mobmfl|mosaikBuildMedianFragLength:n' => \$mosaikBuildMedianFragLength, #for fragment length estimation and local search
	   'pMoA|pMosaikAlign:n' => \$pMosaikAlign,
	   'moaref|mosaikAlignReference:s' => \$mosaikAlignReference, #MosaikAlign reference file assumes existance of jump database files in same dir
	   'moaannpe|mosaikAlignNeuralNetworkPeFile:s' => \$mosaikAlignNeuralNetworkPeFile,
	   'moaannse|mosaikAlignNeuralNetworkSeFile:s' => \$mosaikAlignNeuralNetworkSeFile, 
	   'mojdb|mosaikJumpDbStub:s' => \$mosaikJumpDbStub, #Stub for MosaikJump database
	   'pBWA_aln|pBwaAln:n' => \$pBwaAln,
	   'bwaalnq|bwaAlnQualityTrimming:n' => \$bwaAlnQualityTrimming, #BWA aln quality threshold for read trimming down to 35bp
	   'pBWA_sampe|pBwaSampe:n' => \$pBwaSampe,
	   'pSamT_sort|pSamToolsSort:n' => \$pSamToolsSort,
	   'pPicT_merge|pPicardToolsMergeSamFiles:n' => \$pPicardToolsMergeSamFiles, #PicardTools MergeSamFiles
	   'pictmergetmpd|PicardToolsMergeTempDirectory:s' => \$PicardToolsMergeTempDirectory, #PicardToolsMerge Temporary Directory
	   'pict_mergeprev|picardToolsMergeSamFilesPrevious:s' => \@picardToolsMergeSamFilesPrevious, #Comma separated list
	   'pPicT_markdup|pPicardToolsMarkduplicates:s' => \$pPicardToolsMarkduplicates, #PicardTools MarkDuplicates
	   'picardpath|picardToolsPath:s' => \$picardToolsPath, #Path to picardtools
	   'pCC|pCalculateCoverage:n' => \$pCalculateCoverage,
	   'pCC_bedgc|pGenomeCoverageBED:n' => \$pGenomeCoverageBED,
	   'pCC_bedc|pCoverageBED:n' => \$pCoverageBED,
	   'extb|exomeTargetBed:s' => \$exomeTargetBed, #target file for coverageBed
	   'pCC_qac|pQaCompute:n' => \$pQaCompute,
	   'xcov|xCoverage:n' => \$xCoverage, #Sets max depth to calculate coverage
	   'pCC_picmm|pPicardToolsCollectMultipleMetrics:n' => \$pPicardToolsCollectMultipleMetrics,
	   'pCCE_pichs|pPicardToolsCalculateHSMetrics:n' => \$pPicardToolsCalculateHSMetrics,
	   'extbl|exomeTargetBedInfileList:s' => \$exomeTargetBedInfileList, #target file for CalculateHsMetrics
	   'extpbl|exomeTargetPaddedBedInfileList:s' => \$exomeTargetPaddedBedInfileList, #Padded target file for CalculateHsMetrics, GATK
	   'pRCP|pRCovPlots:n' => \$pRCovPlots,
	   'pSamT_view|pSamToolsViewSplitChr:n' => \$pSamToolsViewSplitChr, #spilt to chr.bam and index
	   'gatkpath|genomeAnalysisToolKitPath:s' => \$genomeAnalysisToolKitPath, #GATK whole path
	   'gatktmpd|GATKTempDirectory:s' => \$GATKTempDirectory, #GATK ReAlignerTargetCreator & BaseRecalibrator temporary directory
	   'gatktpbl|GATKTargetPaddedBedIntervalList:s' => \$GATKTargetPaddedBedIntervalList, #Target file set to be used in GATK
	   'pGATK_real|pGATKRealigner:n' => \$pGATKRealigner, #GATK ReAlignerTargetCreator/IndelRealigner
	   'gatkrealknset1|GATKReAlignerINDELKnownSet1:s' => \$GATKReAlignerINDELKnownSet1, #Known INDEL set to be used in GATK ReAlignerTargetCreator/IndelRealigner
	   'gatkrealknset2|GATKReAlignerINDELKnownSet2:s' => \$GATKReAlignerINDELKnownSet2, #Known INDEL set to be used in GATK ReAlignerTargetCreator/IndelRealigner
	   'pGATK_baserecal|pGATKBaseRecalibration:n' => \$pGATKBaseRecalibration, #GATK BaseRecalibrator/PrintReads
	   'gatkbaserecalknset|GATKBaseReCalibrationSNPKnownSet:s' => \$GATKBaseReCalibrationSNPKnownSet, #Known SNP set to be used in GATK BaseRecalibrator/PrintReads
	   'pGATK_hapcall|pGATKHaploTypeCaller:n' => \$pGATKHaploTypeCaller, #GATK Haplotypecaller
	   'gatkhapcallsnpknset|GATKHaploTypeCallerSNPKnownSet:s' => \$GATKHaploTypeCallerSNPKnownSet, #Known SNP set to be used in GATK HaplotypeCaller
	   'pGATK_varrecal|pGATKVariantRecalibration:n' => \$pGATKVariantRecalibration, #GATK VariantRecalibrator/ApplyRecalibration
	   'gatkexrefsnp|GATKExomeReferenceSNPs:s' => \$GATKExomeReferenceSNPs, #File of 33 exomes to power probabalistic model GATK Varrecal (SNVs) (Recieved from Måns, 120413)
	   'gatkvarrecaltrhapmap|GATKVariantReCalibrationTrainingSetHapMap:s' => \$GATKVariantReCalibrationTrainingSetHapMap, #GATK VariantRecalibrator resource
	   'gatkvarrecaltrdbsnp|GATKVariantReCalibrationTrainingSetDbSNP:s' => \$GATKVariantReCalibrationTrainingSetDbSNP, #GATK VariantRecalibrator resource
	   'gatkvarrecaltromni|GATKVariantReCalibrationTrainingSet1000GOmni:s' => \$GATKVariantReCalibrationTrainingSet1000GOmni, #GATK VariantRecalibrator resource
	   'gatkvarrecaltrdbmills|GATKVariantReCalibrationTrainingSetMills:s' => \$GATKVariantReCalibrationTrainingSetMills, #GATK VariantRecalibrator resource
	   'gatkvarrecaltsfilterlevel|GATKVariantReCalibrationTSFilterLevel:n' => \$GATKVariantReCalibrationTSFilterLevel, #Truth senativity level
	   'pGATK_varevalall|pGATKVariantEvalAll:n' => \$pGATKVariantEvalAll, #GATK varianteval all variants
	   'pGATK_varevalexome|pGATKVariantEvalExome:n' => \$pGATKVariantEvalExome, #GATK varianteval only exonic variants
	   'gatkvarevaldbsnp|GATKVariantEvalDbSNP:s' => \$GATKVariantEvalDbSNP,
	   'gatkvarevaldbgold|GATKVariantEvalGold:s' => \$GATKVariantReCalibrationTrainingSetMills,
	   'pANVAR|pAnnovar:n' => \$pAnnovar, #Performs annovar filter gene, region and filter analysis
	   'anvarpath|annovarPath:s'  => \$annovarPath, #path to annovar script dir
	   'anvargbv|annovarGenomeBuildVersion:s'  => \$annovarGenomeBuildVersion,
	   'anvartn|annovarTableNames:s'  => \@annovarTableNames, #Comma sepatated list
	   'anvarstn|annovarSupportedTableNames:n' => \$annovarSupportedTableNames, #Generates a list of supported table names
	   'anvarmafth|annovarMAFThreshold:n' => \$annovarMAFThreshold,
	   'anvarsiftth|annovarSiftThreshold:n' => \$annovarSiftThreshold,
	   'pMerge_anvar|pMergeAnnotatedVariants:n' => \$pMergeAnnotatedVariants, #Merges annovar analysis results to one master file
	   'mergeanvarte|mergeAnnotatedVariantsTemplateFile:s' => \$mergeAnnotatedVariantsTemplateFile, #Template file to create the specific family db master file
	   'mergeanvardbf|mergeAnnotatedVariantsDbFile:s' => \$mergeAnnotatedVariantsDbFile, #db master file to use when collecting external data
	   'pAddDP|pAddDepth:n' => \$pAddDepth, #Adds depth (DP) for nonvariants to master file (annovar_merged.txt)
	   'pRankVar|pRankVariants:n' => \$pRankVariants, #Ranking variants
	   'rs|rankscore:n'  => \$rankScore, #The rank score cut-off
	   'gf|geneFiltering:n'  => \$geneFiltering, #Enables dispensible gene filtering
	   'gfl|geneFilteringList:s'  => \$geneFilteringList, #List of dispensible genes (1 entry per line; HGNC Symbol)
	   'alldbfile|allElementsDbFile:s'  => \$allElementsDbFile, #Db of all genes
	   'alldbcc|allElementsDbGeneCoverageCalculation:n'  => \$allElementsDbGeneCoverageCalculation, #Db of all genes for coverage calculation (all features connected to overlapping genes across variant)
	   'alldbgidc|allElementsDbGeneIdCol:n'  => \$allElementsDbGeneIdCol, #Db of all genes GeneName column nr zero-based
	   'imdbfile|ImportantDbFile:s'  => \$ImportantDbFile, #Db of important genes
	   'imdbte|ImportantDbTemplate:s' => \$ImportantDbTemplate, #Template file to create the specific family selectVariants db master file
	   'imdbmf|ImportantDbMasterFile:s' => \$ImportantDbMasterFile, #Specific db master file to use when collecting external dataselectingVariants 
	   'imdbfof|ImportantDbFileOutFile:s' => \@ImportantDbFileOutFile, #The intersectCollect select variants output directorys	      
	   'imdbcc|ImportantDbGeneCoverageCalculation:n'  => \$ImportantDbGeneCoverageCalculation, #Db of important genes coverage calculation (all features connected to overlapping genes across variant)
	   'imdbgidc|ImportantDbGeneIdCol:n'  => \$ImportantDbGeneIdCol, #Db of important genes GeneName column nr zero-based
	   'pSCheck|pSampleCheck:n' => \$pSampleCheck, #QC for samples gender and relationship
	   );

die $USAGE if($help);

if ($configFile ne 0) { #No input from cmd
    
    use lib '/bubo/home/h12/henriks/lib/'; #YAML not installed at @UPPMAX and is not included in the standard distribution of perl
    use YAML;
    open (YAML, "<".$configFile) or die "can't open ".$configFile.": $!\n";
    %scriptParameter = YAML::LoadFile($configFile);
    close(YAML);
}

if ($annovarSupportedTableNames == 1) {
    print STDOUT "\nThese Annovar databases are supported by MIP:\n";
    for (my $annovarSupportedTableNameCounter=0;$annovarSupportedTableNameCounter<scalar(@annovarSupportedTableNames);$annovarSupportedTableNameCounter++) {
	print STDOUT $annovarSupportedTableNames[$annovarSupportedTableNameCounter], "\n";
    }
    print STDOUT "\n";
    die;
}

###3 type of variables: MIP, path or program/program_parameters each is handled in the AddToScriptParameter subroutine.
##parameterName, parameterValue, parameterType, parameterDefault, environmentUppmaxDefault, AssociatedProgram, (parameterDependencies, Check directory/file existence)
AddToScriptParameter("environmentUppmax", $environmentUppmax, "MIP", 0, 0, "MIP");

AddToScriptParameter("projectID", $projectID, "MIP", 0, "b2010080", "MIP");

AddToScriptParameter("email", $email, "MIP", 0, 0, "MIP");

AddToScriptParameter("familyID", $familyID, "MIP", 0, 0, "MIP");

AddToScriptParameter("maximumCores", $maximumCores, "MIP", 8, 8, "MIP");

AddToScriptParameter("configFile", $configFile, "MIP", 0, 0, "MIP");

AddToScriptParameter("writeConfigFile", $writeConfigFile, "MIP", 0, 1, "MIP");

AddToScriptParameter("wholeGenomeSequencing", $wholeGenomeSequencing, "program", 0, 0, "MIP"); #wholeGenomeSequencing is hard to place since it affects both programs and path and MIP

AddToScriptParameter("outDataDir", $outDataDir, "path", 0, 1, "MIP", 1); #outDataDir is dependent on wholegenomeSequencing for environmentUppmax option. No check for directory existence since MIP will create directory if lacking

if ($pedigreeFile eq 0) {
    
    if (defined($scriptParameter{'pedigreeFile'})) { #Input from config file - ReadPedigreefile
	if (scalar(@sampleIDs) == 0) { #No user supplied sample info
	    if (defined($scriptParameter{'sampleIDs'})) { #sampleIDs info in config file
		ReadPedigreeFile($scriptParameter{'pedigreeFile'}, 1);  # scalar(@sampleIDs) = 0:No user supplied sample info, but present in config file do NOT overwrite using info from pedigree file
	    }
	    else { #No sampleIDs info in config file
		ReadPedigreeFile($scriptParameter{'pedigreeFile'}, scalar(@sampleIDs));  # scalar(@sampleIDs) = 0:No user supplied sample info, not defined $scriptParameter{'sampleIDs'} in config file, add it from pedigree file
	    }
	}
	else {
	    ReadPedigreeFile($scriptParameter{'pedigreeFile'}, scalar(@sampleIDs));  # User supplied sample info, do NOT overwrite using info from pedigree file
	}
    }
    elsif ($scriptParameter{'environmentUppmax'} == 1) {
	print STDOUT "\n";
	if ($scriptParameter{'wholeGenomeSequencing'} == 0) {
	    $pedigreeFile = "/proj/".$scriptParameter{'projectID'}."/private/exomes/".$scriptParameter{'familyID'}."/".$scriptParameter{'familyID'}."_pedigree.txt";
	}
	else {
	    $pedigreeFile = "/proj/".$scriptParameter{'projectID'}."/private/genomes/".$scriptParameter{'familyID'}."/".$scriptParameter{'familyID'}."_pedigree.txt";
	}
	print STDOUT "Assuming location of pedigree file to be: ".$pedigreeFile, "\n\n";
	if (-e $pedigreeFile) { #if file exists 
	    print STDOUT "Found pedigree file at: ".$pedigreeFile, "\n\n";
	    $scriptParameter{'pedigreeFile'} = $pedigreeFile; #Add to enable recreation of cmd line later
	    ReadPedigreeFile($pedigreeFile, scalar(@sampleIDs)); #  scalar(@sampleIDs)= 0:No user supplied sample info, add it from pedigree file
	}
	else { 
	    print STDERR "Could not find pedigree file at: ".$pedigreeFile, "\n";
	    die $USAGE;
	} 
    }
}
else { #Add to enable or overwrite info gathered from config and use in recreation of cmd line later
    ReadPedigreeFile($pedigreeFile, scalar(@sampleIDs));  # scalar(@sampleIDs) = 0:No user supplied sample info, add it from pedigree file
    $scriptParameter{'pedigreeFile'} = $pedigreeFile;   
}

if (scalar(@sampleIDs) == 0) { #No input from cmd or from pedigree
    @sampleIDs = 0; #to enable use of subroutine AddToScriptParameter
    AddToScriptParameter("sampleIDs", @sampleIDs, "path", 0, 0, "MIP");
}
else {
    $scriptParameter{'sampleIDs'} = join(',',@sampleIDs); #Add to enable recreation of cmd line later
    @sampleIDs = split(/,/,join(',',@sampleIDs)); #Enables comma separated list of sample IDs from user supplied cmd info
}


if (scalar(@inFilesDirs) == 0) { #No input from cmd
    @inFilesDirs = (0);
}
AddToScriptParameter("inFilesDirs", @inFilesDirs, "path", 0, 1, "MIP", 1, "directory"); #inFileDirs is dependent on wholegenomeSequencing for environmentUppmax option, hence 6th arg. Check if directory exists 7th arg

AddToScriptParameter("inScriptDir", $inScriptDir, "path", 0, "/proj/".$scriptParameter{'projectID'}."/private/mip_scripts_master", "MIP", 0, "directory");

AddToScriptParameter("referencesDir", $referencesDir, "path", 0, "/proj/".$scriptParameter{'projectID'}."/private/mip_references", "MIP", 1, "directory"); 

AddToScriptParameter("outScriptDir", $outScriptDir, "path", 0, 1, "MIP", 1); #No check for directory existence since MIP will create directory if lacking

##Programs and associated parameters
AddToScriptParameter("pGZip", $pGZip, "program", 1, 1, "MIP");

AddToScriptParameter("pFastQC", $pFastQC, "program", 1, 1, "MIP");

AddToScriptParameter("pRemovalRedundantFiles", $pRemovalRedundantFiles, "program", 1, 1, "RemovalRedundantFiles");

AddToScriptParameter("pMosaikBuild", $pMosaikBuild, "program", 1, 1, "MIP");

if ($scriptParameter{'pMosaikBuild'} > 0) { #MosaikBuild is to be used
    
    AddToScriptParameter("mosaikBuildMedianFragLength", $mosaikBuildMedianFragLength, "program", 375, 375, "MosaikBuild");
}

AddToScriptParameter("pMosaikAlign", $pMosaikAlign, "program", 1, 1, "MIP");

if ($scriptParameter{'pMosaikAlign'} > 0) { #MosaikAlign is to be used - check prerequisets

    AddToScriptParameter("mosaikAlignReference", $mosaikAlignReference, "path", 0, "Homo_sapiens.GRCh37.70_nochr.dat", "MosaikAlign",0 ,"file");

    AddToScriptParameter("mosaikAlignNeuralNetworkPeFile", $mosaikAlignNeuralNetworkPeFile, "path", 0, "2.1.78.pe.ann", "MosaikAlign",0 ,"file");

    AddToScriptParameter("mosaikAlignNeuralNetworkSeFile", $mosaikAlignNeuralNetworkSeFile, "path", 0, "2.1.78.se.ann", "MosaikAlign",0 ,"file");

    AddToScriptParameter("mosaikJumpDbStub", $mosaikJumpDbStub, "path", 0, "Homo_sapiens.GRCh37.70_nochr_jdb_15", "MosaikAlign",0 ,"file");    
}

AddToScriptParameter("pBwaAln", $pBwaAln, "program", 0, 0, "MIP");

if ($scriptParameter{'pBwaAln'} > 0) {

    AddToScriptParameter("bwaAlnQualityTrimming", $bwaAlnQualityTrimming, "program", 20, 20, "BWA Aln");
}

AddToScriptParameter("pBwaSampe", $pBwaSampe, "program", 0, 0, "BWA Sampe");

AddToScriptParameter("aligner", $aligner, "MIP", 0, 0, "MIP");

AddToScriptParameter("pSamToolsSort", $pSamToolsSort, "program", 1, 1, "SamToolsSort");

AddToScriptParameter("pPicardToolsMergeSamFiles", $pPicardToolsMergeSamFiles, "program", 0, 0, "PicardToolsMergeSamFiles");

if ( ($scriptParameter{'pPicardToolsMergeSamFiles'} > 0) || (scalar(@picardToolsMergeSamFilesPrevious) > 0)) { #2nd term to enable write to config
    
    AddToScriptParameter("PicardToolsMergeTempDirectory", $PicardToolsMergeTempDirectory, "path", "/scratch/".'$SLURM_JOB_ID', "/proj/".$scriptParameter{'projectID'}."/private/nobackup/".'$SLURM_JOB_ID', "PicardToolsMergeSamFiles",0);
    
    if (scalar(@picardToolsMergeSamFilesPrevious) == 0) {
	@picardToolsMergeSamFilesPrevious = (0); 
    }
    AddToScriptParameter("picardToolsMergeSamFilesPrevious", @picardToolsMergeSamFilesPrevious, "path", 0, 0, "PicardToolsMergeSamFiles");
     
    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) { #Check all samples to check, which are to be merged with previous files later
	if (scalar(@picardToolsMergeSamFilesPrevious) > 0) { #Supplied info - check for which sampleIDs  	
	    for (my $mergeFileCounter=0;$mergeFileCounter<scalar(@picardToolsMergeSamFilesPrevious);$mergeFileCounter++) {
		
		if ($picardToolsMergeSamFilesPrevious[$mergeFileCounter] =~ /$sampleIDs[$sampleIDCounter]/) { #Look for sampleID in previously generated file to be merged with current run to be able to merge correct files
		    $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'picardToolsMergeSamFilesPrevious'} = 1;
		}
		else {
		    $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'picardToolsMergeSamFilesPrevious'} = 0;
		}
	    }
	}
	else { #Not supplied - Set to 0 
	    $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'picardToolsMergeSamFilesPrevious'} = 0;
	}
    }
}
else { #Not supplied - Set to 0 to handle correctly in program subroutines 
    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) { #Set for all sampleIDs
	$sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'picardToolsMergeSamFilesPrevious'} = 0;
    }
}

AddToScriptParameter("pPicardToolsMarkduplicates", $pPicardToolsMarkduplicates, "program", 1, 1, "PicardToolsMarkduplicates");

AddToScriptParameter("pCalculateCoverage", $pCalculateCoverage, "program", 1, 1, "CalculateCoverage");

if ($scriptParameter{'pCalculateCoverage'} > 0) {

    AddToScriptParameter("pGenomeCoverageBED", $pGenomeCoverageBED, "program", 1, 1, "GenomeCoverageBED");
    
    AddToScriptParameter("pCoverageBED", $pCoverageBED, "program", 1, 1, "CoverageBED");
   
    AddToScriptParameter("pQaCompute", $pQaCompute, "program", 1, 1, "QaCompute");

    AddToScriptParameter("pPicardToolsCollectMultipleMetrics", $pPicardToolsCollectMultipleMetrics, "program", 1, 1, "PicardToolsCollectMultipleMetrics");

    AddToScriptParameter("pPicardToolsCalculateHSMetrics", $pPicardToolsCalculateHSMetrics, "program", 1, 1, "PicardToolsCalculateHSMetrics");
    
    if ( ($scriptParameter{'pQaCompute'} > 0) || ($scriptParameter{'pGenomeCoverageBED'} > 0) ) {
	
	AddToScriptParameter("xCoverage", $xCoverage, "program", 30, 30, "QaCompute or GenomeCoverageBED");
    }
}

if ( ($scriptParameter{'pPicardToolsMergeSamFiles'} > 0) || ($scriptParameter{'pPicardToolsMarkduplicates'} > 0) ) {

    AddToScriptParameter("picardToolsPath", $picardToolsPath, "path", 0, "/bubo/home/h12/henriks/programs/picard-tools-1.74", "PicardToolsMergeSamFiles or PicardToolsMarkduplicates", 0, "directory"); 
}
elsif ($scriptParameter{'pCalculateCoverage'} > 0) { 
    
    if ( ($scriptParameter{'pPicardToolsCalculateHSMetrics'} > 0) || ($scriptParameter{'pPicardToolsCollectMultipleMetrics'} > 0) ) {
	AddToScriptParameter("picardToolsPath", $picardToolsPath, "path", 0, "/bubo/home/h12/henriks/programs/picard-tools-1.74", "PicardToolsCalculateHSMetrics or PicardToolsCollectMultipleMetrics", 0, "directory");
    }
}

AddToScriptParameter("pRCovPlots", $pRCovPlots, "program", 1, 1, "RCovPlots");

AddToScriptParameter("pSamToolsViewSplitChr", $pSamToolsViewSplitChr, "program", 1, 1, "SamToolsViewSplitChr");

AddToScriptParameter("pGATKRealigner", $pGATKRealigner, "program", 1, 1, "GATK ReAlignerTargetCreator/IndelRealigner");

if ($scriptParameter{'pGATKRealigner'} > 0) { #GATK ReAligner is to be used

    AddToScriptParameter("GATKReAlignerINDELKnownSet1", $GATKReAlignerINDELKnownSet1, "path", "1000G_phase1.indels.hg19.vcf", "1000G_phase1.indels.hg19.vcf", "GATK ReAlignerTargetCreator/IndelRealigner",0 ,"file");
    
    AddToScriptParameter("GATKReAlignerINDELKnownSet2", $GATKReAlignerINDELKnownSet2, "path", "Mills_and_1000G_gold_standard.indels.hg19.sites.vcf", "Mills_and_1000G_gold_standard.indels.hg19.sites.vcf", "GATK ReAlignerTargetCreator/IndelRealigner",0 ,"file");
}

AddToScriptParameter("pGATKBaseRecalibration", $pGATKBaseRecalibration, "program", 1, 1, "GATK BaseRecalibrator/PrintReads");

if ($scriptParameter{'pGATKBaseRecalibration'} > 0) { #GATK BaseReCalibration is to be used

    AddToScriptParameter("GATKBaseReCalibrationSNPKnownSet", $GATKBaseReCalibrationSNPKnownSet, "path", "dbsnp_135.b37.vcf", "dbsnp_135.b37.vcf", "GATK BaseRecalibrator/PrintReads",0 ,"file");
    
}

AddToScriptParameter("pGATKHaploTypeCaller", $pGATKHaploTypeCaller, "program", 1, 1, "GATK HaplotypeCaller");

if ($scriptParameter{'pGATKHaploTypeCaller'} > 0) { #GATK GATKHaplotypeCaller is to be used
    
    AddToScriptParameter("GATKHaploTypeCallerSNPKnownSet", $GATKHaploTypeCallerSNPKnownSet, "path", "dbsnp_135.b37.vcf", "dbsnp_135.b37.vcf", "GATK HaplotypeCaller",0 ,"file");
}

AddToScriptParameter("pGATKVariantRecalibration", $pGATKVariantRecalibration, "program", 1, 1, "GATK VariantRecalibration");

if ($scriptParameter{'pGATKVariantRecalibration'} > 0) { #GATK GATKHaplotypeCaller is to be used

    AddToScriptParameter("GATKExomeReferenceSNPs", $GATKExomeReferenceSNPs, "path", 0, "all-agilent_50mb-GRCh37-SNPS_pad100_interval_list.vcf", "GATK VariantRecalibration",0 ,"file");

    AddToScriptParameter("GATKVariantReCalibrationTrainingSetHapMap", $GATKVariantReCalibrationTrainingSetHapMap, "path", "hapmap_3.3.b37.sites.vcf", "hapmap_3.3.b37.sites.vcf", "GATK VariantRecalibration",0 ,"file");

    AddToScriptParameter("GATKVariantReCalibrationTrainingSetDbSNP", $GATKVariantReCalibrationTrainingSetDbSNP, "path", "dbsnp_135.b37.vcf", "dbsnp_135.b37.vcf", "GATK VariantRecalibration",0 ,"file");
    
    AddToScriptParameter("GATKVariantReCalibrationTrainingSet1000GOmni", $GATKVariantReCalibrationTrainingSet1000GOmni, "path", "1000G_omni2.5.b37.sites.vcf", "1000G_omni2.5.b37.sites.vcf", "GATK VariantRecalibration",0 ,"file");
    
    AddToScriptParameter("GATKVariantReCalibrationTrainingSetMills", $GATKVariantReCalibrationTrainingSetMills, "path", "Mills_and_1000G_gold_standard.indels.hg19.sites.vcf", "Mills_and_1000G_gold_standard.indels.hg19.sites.vcf", "GATK VariantRecalibration",0 ,"file");
    
    AddToScriptParameter("GATKVariantReCalibrationTSFilterLevel", $GATKVariantReCalibrationTSFilterLevel, "program", 99.9, 99.9, "GATK VariantRecalibration");

}

AddToScriptParameter("pGATKVariantEvalAll", $pGATKVariantEvalAll, "program", 1, 1, "GATK VariantEvalAll");

AddToScriptParameter("pGATKVariantEvalExome", $pGATKVariantEvalExome, "program", 1, 1, "GATK VariantEvalExome");


if ( ($scriptParameter{'pGATKVariantEvalAll'} > 0) || ($scriptParameter{'pGATKVariantEvalExome'} > 0) ) {
    
    AddToScriptParameter("GATKVariantEvalDbSNP", $GATKVariantEvalDbSNP, "path", 0, "dbsnp_132.hg19.excluding_sites_after_129_nochr.vcf", "GATK VariantEval",0 ,"file");

    AddToScriptParameter("GATKVariantEvalGold", $GATKVariantEvalGold, "path", 0, "Mills_and_1000G_gold_standard.indels.hg19.sites.vcf", "GATK VariantEval",0 ,"file");
    
}

if ( ($scriptParameter{'pGATKRealigner'} > 0) || ($scriptParameter{'pGATKBaseRecalibration'} > 0) || ($scriptParameter{'pGATKHaploTypeCaller'} > 0) || ($scriptParameter{'pGATKVariantRecalibration'} > 0) || ($scriptParameter{'pGATKVariantEvalAll'} > 0) || ($scriptParameter{'pGATKVariantEvalExome'} > 0) ) {

    AddToScriptParameter("genomeAnalysisToolKitPath", $genomeAnalysisToolKitPath, "path", 0, "/bubo/home/h12/henriks/programs/GenomeAnalysisTK-2.4-7-g5e89f01", "GATK", 0, "directory");

    AddToScriptParameter("GATKTempDirectory", $GATKTempDirectory, "path", "/scratch/".'$SLURM_JOB_ID', "/proj/".$scriptParameter{'projectID'}."/private/nobackup/".'$SLURM_JOB_ID', "GATK", 0); #No check for directory since it does not exist yet.
}

AddToScriptParameter("pAnnovar", $pAnnovar, "program", 1, 1, "Annovar");

if ($scriptParameter{'pAnnovar'} > 0) {

    AddToScriptParameter("annovarPath", $annovarPath, "path", 0, "/bubo/proj/b2010080/private/annovar", "Annovar", 0, "directory");

    AddToScriptParameter("annovarGenomeBuildVersion", $annovarGenomeBuildVersion, "program", "hg19", "hg19", "Annovar");

    if (scalar(@annovarTableNames) == 0) {
	@annovarTableNames = (-1); #No input from cmd 
    }
    AddToScriptParameter("annovarTableNames", @annovarTableNames, "program", "yes", "yes", "Annovar"); #"yes" added to enable addition of default table names in AddToScriptParameters

    AddToScriptParameter("annovarSupportedTableNames", $annovarSupportedTableNames, "program", 0, 0, "Annovar");

    AddToScriptParameter("annovarMAFThreshold", $annovarMAFThreshold, "program", 0, 0, "Annovar");

    AddToScriptParameter("annovarSiftThreshold", $annovarSiftThreshold, "program", 0, 0, "Annovar");
    
}

AddToScriptParameter("pMergeAnnotatedVariants", $pMergeAnnotatedVariants, "program", 1, 1, "MergeAnnotatedVariants");

if ($scriptParameter{'pMergeAnnotatedVariants'} > 0) {

    AddToScriptParameter("mergeAnnotatedVariantsTemplateFile", $mergeAnnotatedVariantsTemplateFile, "path", 0, "CMMS_intersectCollect_db_master_template.txt", "MergeAnnotatedVariants", 0, "file");

    AddToScriptParameter("mergeAnnotatedVariantsDbFile", $mergeAnnotatedVariantsDbFile, "program", $scriptParameter{'familyID'}."_intersectCollect_db_master.txt", $scriptParameter{'familyID'}."_intersectCollect_db_master.txt", "MergeAnnotatedVariants");
}

AddToScriptParameter("pAddDepth", $pAddDepth, "program", 1, 1, "AddDepth");

AddToScriptParameter("pRankVariants", $pRankVariants, "program", 1, 1, "RankVariants");

if ($scriptParameter{'pRankVariants'} > 0) {

    AddToScriptParameter("rankScore", $rankScore, "program", -100, -100, "RankVariants");

    AddToScriptParameter("geneFiltering", $geneFiltering, "program", 1, 1, "RankVariants");

    AddToScriptParameter("geneFilteringList", $geneFilteringList, "path", 0, "IEM_dispGeneList.txt", "RankVariants", 0, "file");

    AddToScriptParameter("allElementsDbFile", $allElementsDbFile, "path", 0, "mart_export_Ensembl_GeneID_key_cleaned_chr.txt", "RankVariants", 0, "file");

    AddToScriptParameter("allElementsDbGeneCoverageCalculation", $allElementsDbGeneCoverageCalculation, "program", 1, 1, "RankVariants");

    AddToScriptParameter("allElementsDbGeneIdCol", $allElementsDbGeneIdCol, "program", 4, 4, "RankVariants");

    AddToScriptParameter("ImportantDbFile", $ImportantDbFile, "path", 0, "IEM_Db_CMMS_version1.2.txt", "RankVariants", 0, "file");

    AddToScriptParameter("ImportantDbTemplate", $ImportantDbTemplate, "path", 0, "select_dbIEM_variants_db_master.txt", "RankVariants", 0, "file");

    AddToScriptParameter("ImportantDbMasterFile", $ImportantDbMasterFile, "program", $scriptParameter{'familyID'}.".intersectCollect_selectVariants_db_master.txt", $scriptParameter{'familyID'}.".intersectCollect_selectVariants_db_master.txt", "RankVariants"); #No file check since file is created by MIP later

    if (scalar(@ImportantDbFileOutFile) == 0 ){
	@ImportantDbFileOutFile = (-1); #No input from cmd
    }
    AddToScriptParameter("ImportantDbFileOutFile", @ImportantDbFileOutFile, "program", "yes", "yes", "RankVariants"); 

    AddToScriptParameter("ImportantDbGeneCoverageCalculation", $ImportantDbGeneCoverageCalculation, "program", 1, 1, "RankVariants");

    AddToScriptParameter("ImportantDbGeneIdCol", $ImportantDbGeneIdCol, "program", 18, 18, "RankVariants");
}

AddToScriptParameter("pSampleCheck", $pSampleCheck, "program", 1, 1, "SampleCheck");

if ( ($scriptParameter{'pBwaAln'} > 0) || ($scriptParameter{'pBwaSampe'} > 0) || ($scriptParameter{'pGATKRealigner'} > 0) || ($scriptParameter{'pGATKBaseRecalibration'} > 0) || ($scriptParameter{'pGATKHaploTypeCaller'} > 0) || ($scriptParameter{'pGATKVariantRecalibration'} > 0) || ($scriptParameter{'pGATKVariantEvalAll'} > 0) || ($scriptParameter{'pGATKVariantEvalExome'} > 0) || ($scriptParameter{'pAnnovar'} > 0) || ($scriptParameter{'pAddDepth'} > 0) ) { #Programs that uses $humanGenomeReference

    AddToScriptParameter("humanGenomeReference", $humanGenomeReference, "path", 0, "Homo_sapiens.GRCh37.70_nochr.fasta", "Alignment or GATK",0 ,"file");

}
elsif ($scriptParameter{'pCalculateCoverage'} > 0) {
    if ( ($scriptParameter{'pPicardToolsCalculateHSMetrics'} > 0) || ($scriptParameter{'pPicardToolsCollectMultipleMetrics'} > 0) ) { #Programs that uses $humanGenomeReference

 AddToScriptParameter("humanGenomeReference", $humanGenomeReference, "path", 0, "Homo_sapiens.GRCh37.70_nochr.fasta", "CalculateCoverage/PicardToolsCalculateHSMetrics/PicardToolsCollectMultipleMetrics",0 ,"file");

    }
}

if ( defined ($scriptParameter{'pCoverageBED'}) && ($scriptParameter{'pCoverageBED'} > 0) ) {
    
    SetTargetFiles("exomeTargetBed", $exomeTargetBed, "Calculate Coverage/CoverageBED", "file");
}

if ( defined($scriptParameter{'pPicardToolsCalculateHSMetrics'}) && ($scriptParameter{'pPicardToolsCalculateHSMetrics'} > 0 ) ) {

    SetTargetFiles("exomeTargetBedInfileList", $exomeTargetBedInfileList, "Calculate Coverage/CalculateHSMetrics", "file");

    SetTargetFiles("exomeTargetPaddedBedInfileList", $exomeTargetPaddedBedInfileList, "Calculate Coverage/CalculateHSMetrics", "file");

}

if ( ($scriptParameter{'pGATKHaploTypeCaller'} > 0) || ($scriptParameter{'pGATKVariantRecalibration'} > 0) ) {
 
   SetTargetFiles("GATKTargetPaddedBedIntervalList", $GATKTargetPaddedBedIntervalList, "GATK/HaplotypeCaller/VariantReCalibration", "file");

}


if ($scriptParameter{'writeConfigFile'} ne 0) { #Write config file for family
    open (YAML, '>', $scriptParameter{'writeConfigFile'}) or die "can't open ".$scriptParameter{'writeConfigFile'}.": $!\n";
    print YAML Dump(%scriptParameter), "\n";
    close (YAML);
}

##Set chr prefix and chromosome names depending on reference used
if ($scriptParameter{'humanGenomeReference'}=~/hg\d+/) { #Refseq - prefix and M
    @chromosomes = ("chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11","chr12","chr13","chr14","chr15","chr16","chr17","chr18","chr19","chr20","chr21","chr22","chrX","chrY","chrM"); #Chr for filtering of bam file
}
elsif ($scriptParameter{'humanGenomeReference'}=~/GRCh\d+/) { #Ensembl - no prefix and MT
    @chromosomes = ("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y","MT"); #Chr for filtering of bam file
}


####Creates master_logg for the master script 

`mkdir -p $scriptParameter{'outDataDir'}/$scriptParameter{'familyID'}/master_logg;`; #Creates the master_logg dir
my ($base,$script) = (`date +%Y%m%d`,`basename $0`); #Catches current date and script name
chomp($base,$script); #Remove \n;
my $masterLoggName = $scriptParameter{'outDataDir'}."/".$scriptParameter{'familyID'}."/master_logg/".$script."_".$base.".txt"; #concatenates master_logg filename

open (MASTERL, ">>".$masterLoggName) or die "Can't write to ".$masterLoggName.": $!\n"; #Open file masterLogg

##Add parameters
print MASTERL "\n".$script." "; #Adds script name to recontruct command line

WriteCMDMasterLogg();

print STDOUT "\nScript parameters and info from ".$script." are saved in file: ".$masterLoggName, "\n";


####Collect infiles

for (my $inputDirectoryCounter=0;$inputDirectoryCounter<scalar(@inFilesDirs);$inputDirectoryCounter++) { #Collects inputfiles
    
    my @infiles = `cd $inFilesDirs[ $inputDirectoryCounter ];ls *.fastq*;`; #cd to input dir and collect fastq files and fastq.gz files
   
    print STDOUT "\nReads from Platform", "\n";print MASTERL "\nReads from Platform", "\n";
    print STDOUT "\nSample ID\t".$sampleIDs[$inputDirectoryCounter],"\n";print MASTERL "\nSample ID\t".$sampleIDs[$inputDirectoryCounter],"\n";
    print STDOUT "Inputfiles\n",@ { $infile{ $sampleIDs[$inputDirectoryCounter] }  =[@infiles] }, "\n"; #hash with sample id as key and inputfiles in dir as array 
    print MASTERL "Inputfiles\n",@ { $infile{ $sampleIDs[$inputDirectoryCounter] }  =[@infiles] }, "\n";
    
    $indirpath{$sampleIDs[$inputDirectoryCounter]} = $inFilesDirs[ $inputDirectoryCounter ];  #Catch inputdir path
    chomp(@infiles);    #Remove newline from every entry in array
    $infile{ $sampleIDs[$inputDirectoryCounter] }  =[@infiles]; #Reload files into hash (kept above newline just for print STDOUT)
}

close(MASTERL);

my $uncompressedFileSwitch = InfilesReFormat(); #Required to format infiles correctly for subsequent input into aligners

CreateFileEndings(); #Creates all fileendings as the samples is processed depending on the chain of modules activated



####MAIN

open (MASTERL, ">>".$masterLoggName) or die "Can't write to ".$masterLoggName.": $!\n"; #Open file run logg

if ( ($scriptParameter{'pGZip'} > 0) && ($uncompressedFileSwitch eq 1) ) { #GZip of fastq files

    print STDOUT "\nGZip for fastq files", "\n";print MASTERL "\nGZip for fastq files", "\n";

    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) {  

	for (my $infileCounter=0;$infileCounter<scalar( @{ $infile{$sampleIDs[$sampleIDCounter]} });$infileCounter++) { #To determine which sampleID had the uncompressed files
	    
	    if ($infile{$sampleIDs[$sampleIDCounter]}[$infileCounter] =~/.fastq$/) {
	
		GZipfastq($sampleIDs[$sampleIDCounter]);
		last; #Return to sampleID loop i.e. only call subroutine GZipfastq once per sampleID
	    }
	}
    }
}

if ($scriptParameter{'pFastQC'} > 0) { #Run FastQC
    
    print STDOUT "\nFastQC", "\n";print MASTERL "\nFastQC", "\n";
    
    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) {  
	
	FastQC($sampleIDs[$sampleIDCounter]);	
    }
}

if ($scriptParameter{'pMosaikBuild'} > 0) { #Run MosaikBuild
    
    print STDOUT "\nMosaikBuild", "\n";print MASTERL "\nMosaikBuild", "\n";

    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) {  
	
	MosaikBuild($sampleIDs[$sampleIDCounter]);	
    }
}


if ($scriptParameter{'pMosaikAlign'} > 0) { #Run MosaikAlign
    
    print STDOUT "\nMosaikAlign", "\n"; print MASTERL "\nMosaikAlign", "\n";

    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) {  
	
	MosaikAlign($sampleIDs[$sampleIDCounter]);	
    }
}

if ($scriptParameter{'pBwaAln'} > 0) { #Run BWA Aln
    
    print STDOUT "\nBWA Aln", "\n";print MASTERL "\nBWA Aln", "\n";
    
    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) {  
	
	BWA_Aln($sampleIDs[$sampleIDCounter]);	
    }    
}

if ($scriptParameter{'pBwaSampe'} > 0) { #Run BWA Sampe
    
    print STDOUT "\nBWA Sampe", "\n";print MASTERL "\nBWA Sampe", "\n";
    
    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) {  
	
	BWA_Sampe($sampleIDs[$sampleIDCounter]);
    }
}

if ($scriptParameter{'pSamToolsSort'} > 0) { #Run samtools Sort and Index

    print STDOUT "\nSamTools sort & index", "\n";

    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) {  
    
	SamToolsSortIndex($sampleIDs[$sampleIDCounter], $scriptParameter{'aligner'});
	
    }
}

if ($scriptParameter{'pPicardToolsMergeSamFiles'} > 0) { #Run picardtools merge

    print STDOUT "\nPicardTool MergeSamFiles", "\n";

    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) {  
	if ( ($sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'picardToolsMergeSamFilesPrevious'} == 1) || (scalar( @{ $infilesLaneNoEnding{ $sampleIDs[$sampleIDCounter] } }) > 1) ) { #Sanity Check that we have something to merge with
	    PicardToolsMerge($sampleIDs[$sampleIDCounter], $scriptParameter{'aligner'}, $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'fileEnding'});	
	}
    }
}

if ($scriptParameter{'pPicardToolsMarkduplicates'} > 0) { #PicardTools MarkDuplicates

    print STDOUT "\nPicardTools MarkDuplicates", "\n";print MASTERL "\nPicardTools MarkDuplicates", "\n";

    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) {  
    
	PicardToolsMarkDuplicates($sampleIDs[$sampleIDCounter], $scriptParameter{'aligner'});	
    }
}

if ($scriptParameter{'pCalculateCoverage'} > 0) { #Run GenomeCoverageBED, qaCompute (Paul Costea), Picard (CollectAlignmentSummaryMetrics, CalculateHsMetrics)
    
    print STDOUT "\nCalculate Coverage", "\n";print MASTERL "\nCalculate Coverage", "\n";    
    
    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) {  

	CalculateCoverage($sampleIDs[$sampleIDCounter], $scriptParameter{'aligner'});
    }
}

if ($scriptParameter{'pRCovPlots'} > 0) { #Run Rcovplot scripts   
    print STDOUT "\nRCovPlots", "\n";print MASTERL "\nRCovPlots", "\n";	

    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) {  
	
	RCoveragePlots($sampleIDs[$sampleIDCounter], $scriptParameter{'aligner'});	
    }
}

if ($scriptParameter{'pSamToolsViewSplitChr'} > 0) { #Run SamTools View to print per chromosome output, ie, from one whole genome bam file per sample, to chr bam files.

    print STDOUT "\nSamTools view split genome to chromosomes & index", "\n";print MASTERL "\nSamTools view split genome to chromosome & index", "\n";

    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) {   
    
	SamToolsViewSplitChromosomes($sampleIDs[$sampleIDCounter], $scriptParameter{'aligner'});	
    }
}

if ($scriptParameter{'pGATKRealigner'} > 0) { #Run GATK ReAlignerTargetCreator/IndelRealigner

    print STDOUT "\nGATK ReAlignerTargetCreator/IndelRealigner", "\n";print MASTERL "\nGATK ReAlignerTargetCreator/IndelRealigner", "\n";

    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) {   
    
	GATKReAligner($sampleIDs[$sampleIDCounter], $scriptParameter{'aligner'});	
    }
}

if ($scriptParameter{'pGATKBaseRecalibration'} > 0) { #Run GATK BaseRecalibrator/PrintReads

    print STDOUT "\nGATK BaseRecalibrator/PrintReads", "\n";print MASTERL "\nGATK BaseRecalibrator/PrintReads", "\n";

    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) {   
    
	GATKBaseReCalibration($sampleIDs[$sampleIDCounter], $scriptParameter{'aligner'});	
    }
}

if ($scriptParameter{'pGATKHaploTypeCaller'} > 0) { #Run GATK HaploTypeCaller. Done per family

    print STDOUT "\nGATK HaplotypeCaller", "\n";print MASTERL "\nGATK HaplotypeCaller", "\n";

    if ($scriptParameter{'wholeGenomeSequencing'} == 0) { #Exome samples
    
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",0,3,8); #Argument 3 & 4 is where in @chr to start and stop processing. Arg 5 is java heap allocation (Gb).
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",3,6,8);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",6,12,4);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",12,18,4);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",18,26,4);	
    }
    else { #Whole genome sequencing requires more memory
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",0,1,24); #Argument 3 & 4 is where in @chr to start and stop processing. Arg 5 is java heap allocation (Gb).
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",1,2,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",2,3,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",3,4,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",4,5,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",5,6,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",6,7,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",7,8,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",8,9,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",9,10,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",10,11,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",11,12,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",12,13,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",13,14,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",14,15,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",15,16,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",16,17,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",17,18,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",18,19,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",19,20,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",20,21,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",21,22,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",22,23,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",23,24,24);
	GATKHaploTypeCaller($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH",24,25,24);
    }
    GATKHaplotypeCallerCombineVariants($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH");
}

if ($scriptParameter{'pGATKVariantRecalibration'} > 0) { #Run GATK VariantRecalibrator/ApplyRecalibration. Done per family

    print STDOUT "\nGATK VariantRecalibrator/ApplyRecalibration", "\n";print MASTERL "\nGATK VariantRecalibrator/ApplyRecalibration", "\n";

    GATKVariantReCalibration($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH");

}

if ($scriptParameter{'pAnnovar'} > 0) { #Run Annovar. Done per family

    print STDOUT "\nAnnovar", "\n";print MASTERL "\nAnnovar", "\n";

    Annovar($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH");

}

if ($scriptParameter{'pGATKVariantEvalAll'} > 0) { #Run GATK VariantEval for all variants. Done per sampleID

    print STDOUT "\nGATK VariantEval All", "\n";print MASTERL "\nGATK VariantEval All", "\n";
    
    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) { 
	GATKVariantEvalAll($sampleIDs[$sampleIDCounter], $scriptParameter{'aligner'}, "BOTH", $scriptParameter{'familyID'});
    }
}

if ($scriptParameter{'pGATKVariantEvalExome'} > 0) { #Run GATK VariantEval for exome variants. Done per sampleID

    print STDOUT "\nGATK VariantEval Exome", "\n";print MASTERL "\nGATK VariantEval Exome", "\n";
    
    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) { 
	GATKVariantEvalExome($sampleIDs[$sampleIDCounter], $scriptParameter{'aligner'}, "BOTH", $scriptParameter{'familyID'});
    }
}

if ($scriptParameter{'pMergeAnnotatedVariants'} > 0) { #Run MergeAnnotationVariants using intersectCollect.pl. Done per family

    print STDOUT "\nMergeAnnotatedVariants", "\n";print MASTERL "\nMergeAnnotatedVariants", "\n";

    MergeAnnotatedVariants($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH");

}

if ($scriptParameter{'pAddDepth'} > 0) { #Run AddDepth using add_depth.pl. Done per family

    print STDOUT "\nAddDepth", "\n";print MASTERL "\nAddDepth", "\n";

    AddDp($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH");

}

if ($scriptParameter{'pRankVariants'} > 0) { #Run RankVariants. Done per family

    print STDOUT "\nRankVariants", "\n";print MASTERL "\nRankVariants", "\n";

    RankVariants($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH");

}

if ($scriptParameter{'pSampleCheck'} > 0) { #Run SampleCheck. Done per family

    print STDOUT "\nSampleCheck", "\n";print MASTERL "\nSampleCheck", "\n";

    SampleCheck($scriptParameter{'familyID'}, $scriptParameter{'aligner'}, "BOTH");

}

if ($scriptParameter{'pRemovalRedundantFiles'} > 0) { #Sbatch generation of removal of alignment files
    
    print STDOUT "\nRemoval of alignment files", "\n"; print MASTERL "\nRemoval of alignment files", "\n";
    
    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) {  
	
	RemoveRedundantFiles($sampleIDs[$sampleIDCounter], $scriptParameter{'aligner'});	
    }
}

close(MASTERL); #Close Master_logg file

######################
###Sub Routines#######
######################

sub RemoveRedundantFiles {
#Generates a sbatch script, which removes some alignment files.
    
    my $sampleID = $_[0]; 
    my $aligner = $_[1];
    
    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/$aligner/info;`; #Creates the aligner and info data file directory
    `mkdir -p $scriptParameter{'outScriptDir'}/$sampleID/$aligner;`; #Creates the aligner script directory
    if ($scriptParameter{'pRemovalRedundantFiles'} == 1) {
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/".$aligner."/removeRedundantFiles_".$sampleID.".";
    }
    elsif ($scriptParameter{'pRemovalRedundantFiles'} == 2) { #Dry run
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/".$aligner."/dry_run_removeRedundantFiles_".$sampleID.".";
	print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";
    }

    Checkfnexists($filename, $fnend);

###Info and Logg
    print STDOUT "Creating sbatch script RemoveRedundantFiles and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script RemoveRedundantFiles and writing script file(s) to: ".$filename, "\n";
    print STDOUT "Sbatch script RemoveRedundantFiles data files will be removed in: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner, "\n";print MASTERL "Sbatch script RemoveRedundantFiles data files will be removed in: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner, "\n";

    open (REM, ">".$filename) or die "Can't write to ".$filename.": $!\n";
    
    print REM "#! /bin/bash -l", "\n";
    print REM "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
    print REM "#SBATCH -n 1", "\n";
    print REM "#SBATCH -C thin", "\n";
    print REM "#SBATCH -t 00:15:00", "\n";
    print REM "#SBATCH -J REM_".$sampleID, "\n";
    if ($scriptParameter{'pRemovalRedundantFiles'} == 1) {
	print REM "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/rem_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print REM "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/rem_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }
    elsif ($scriptParameter{'pRemovalRedundantFiles'} == 2) { #Dry run
	print REM "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/rem_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print REM "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/rem_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }
    unless ($scriptParameter{'email'} eq 0) {
	print REM "#SBATCH --mail-type=END", "\n";
	print REM "#SBATCH --mail-type=FAIL", "\n";
	print REM "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
	
    }
    print REM 'echo "Running on: $(hostname)"',"\n\n";

    print REM "cd ";
    print REM $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner, "\n\n";

    my $inSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner;
    my $infile;
    my $mergeLanes; #To pick up merged lanes later 
    my $PicardToolsMergeSwitch = 0;

    
#Check if any files for this sampleID were merged previously to set infile and PicardToolsMergeSwitch
    if ($sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'picardToolsMergeSamFilesPrevious'} == 1) { # Files merged this round with merged file from previous round
	
	for (my $mergeFileCounter=0;$mergeFileCounter<scalar(@picardToolsMergeSamFilesPrevious);$mergeFileCounter++) {
	    
	    if ($picardToolsMergeSamFilesPrevious[$mergeFileCounter] =~ /lane(\d+)|s_(\d+)/) { #Look for lanes_ or lane\d in previously generated file to be merged with current run to be able to extract previous lanes
		
		if($1) {$mergeLanes = $1;} else {$mergeLanes = $2;} #Make sure to always supply lanes from previous regexp  
		$infile = $sampleID."_lanes_".$mergeLanes;
		for (my $laneCounter=0;$laneCounter<scalar(@ { $lane{$sampleID} });$laneCounter++) {
		    $infile .= $lane{$sampleID}[$laneCounter]; #Extract lanes per sampleID
		}
		$PicardToolsMergeSwitch = 1;
	    }
	}
    }
    elsif ( ($scriptParameter{'pPicardToolsMergeSamFiles'} > 0) && (scalar( @{ $infilesLaneNoEnding{$sampleID} }) > 1) ) { #but only if there is more than one mosaikBuild/BWA_Aln file per sample ID (Sanity check)
	$infile = $sampleID."_lanes_";
	for (my $laneCounter=0;$laneCounter<scalar(@ { $lane{$sampleID} });$laneCounter++) {
	    $infile .= $lane{$sampleID}[$laneCounter]; #Extract lanes per sampleID
	}
	$PicardToolsMergeSwitch = 1;
    }    
    
    if ($PicardToolsMergeSwitch == 1) { #Files was merged previously
	
	if ( defined($scriptParameter{'pCoverageBED'}) && ($scriptParameter{'pCoverageBED'} > 0) )
 {
	    my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pCoverageBED'}{'fileEnding'};
	    print REM "rm ";
	    print REM $inSampleDirectory."/coverageReport/".$infile.$infileEnding, "\n\n"; #bedtools histogram of BED-file	    
	    
	    $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pCoverageBEDRMDup'}{'fileEnding'};
	    
	    print REM "rm ";
	    print REM $inSampleDirectory."/coverageReport/".$infile.$infileEnding, "\n\n"; #bedtools histogram of BED-file
	}	
    }
    else {
	for (my $infileCounter=0;$infileCounter < scalar( @{ $infilesLaneNoEnding{$sampleID} });$infileCounter++) { #MosaikBuild takes both reads at once
	    
	    my $infile = $infilesLaneNoEnding{$sampleID}[$infileCounter];
	    
	    if ( defined($scriptParameter{'pCoverageBED'}) && ($scriptParameter{'pCoverageBED'} > 0) ) {
		my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pCoverageBED'}{'fileEnding'};
		print REM "rm ";
		print REM $inSampleDirectory."/coverageReport/".$infile.$infileEnding, "\n\n"; #bedtools histogram of BED-file	    
		
		$infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pCoverageBEDRMDup'}{'fileEnding'};
		
		print REM "rm ";
		print REM $inSampleDirectory."/coverageReport/".$infile.$infileEnding, "\n\n"; #bedtools histogram of BED-file
	    }
	}	
    }
    
    for (my $infileCounter=0;$infileCounter < scalar( @{ $infilesLaneNoEnding{$sampleID} });$infileCounter++) { #MosaikBuild takes both reads at once
	
	my $infile = $infilesLaneNoEnding{$sampleID}[$infileCounter]; 
	
	if ( ($scriptParameter{'pMosaikBuild'} > 0) || ($scriptParameter{'pMosaikAlign'} > 0) || ($scriptParameter{'aligner'} eq "mosaik") ) {

	    print REM "rm ";
	    print REM $inSampleDirectory."/".$infile.".dat", "\n\n"; #MosaikBuild
	    
	    print REM "rm ";
	    print REM $inSampleDirectory."/".$infile.".stat", "\n\n"; #MosaikAlign Stats
	    
	    print REM "rm ";
	    print REM $inSampleDirectory."/".$infile.".bam", "\n\n"; #MosaikAlign
	    
	    #print REM "rm ";
	    #print REM $inSampleDirectory."/".$infile.".multiple.bam", "\n\n"; #MosaikAlign Multiple
	    
	    #print REM "rm ";
	    #print REm $inSampleDirectory."/".$infile."_sorted.bam", "\n\n"; #MosaikAlign/samtools
	    
	    #print REM "rm ";
	    #print REM $inSampleDirectory."/".$infile."_sorted.bam.bai", "\n\n"; #MosaikAlign/samtools index
	    
	}
    }
###
#Remove BWA files
###
    if ( ($scriptParameter{'pBwaAln'} > 0) || ($scriptParameter{'pBwaSampe'} >0) || ($scriptParameter{'aligner'} eq "bwa")) {
	
	for (my $infileCounter=0;$infileCounter < scalar( @{ $infilesBothStrandsNoEnding{$sampleID} });$infileCounter++) { #BWA_Aln takes 1 read at a time 
	    
	    my $infile = $infilesBothStrandsNoEnding{$sampleID}[$infileCounter]; 
	    
	    print REM "rm ";
	    print REM $inSampleDirectory."/".$infile.".sai", "\n\n"; #BWA_Aln
	}
	for (my $infileCounter=0;$infileCounter < scalar( @{ $infilesLaneNoEnding{$sampleID} });$infileCounter++) { #BWA_Sampe 
	    
	    my $infile = $infilesLaneNoEnding{$sampleID}[$infileCounter]; 
	    
	    print REM "rm ";
	    print REM $inSampleDirectory."/".$infile.".bam", "\n\n"; #BWA_Sampe
	}    
    }    
    print REM "rm ";
    print REM "-rf ";
    print REM $inSampleDirectory."/per_chr", "\n\n"; #samtools/GATK (real/recal)
    
    close(REM);
    return;
}

sub UNifiedGT {

    my $familyID = $_[0]; #familyID NOTE: not sampleid
    my $aligner = $_[1];
    
    my $outFamilyDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/per_chr/GATK/";
    my $outSampleDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/per_chr/GATK/";
    my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pGATKHaploTypeCaller'}{'fileEnding'}; #Change to UnifiedGT later
    my $coreCounter = 1;
    my $callsCounter = 0; #Count the number of calls for both merged and non-merged files to portion out "wait" command
    
    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) { #For all sampleIDs
	
	my ($infile, $PicardToolsMergeSwitch) = CheckIfMergedFiles($sampleIDs[$sampleIDCounter]);
	
	if ($callsCounter eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} cores
	    
	    print GATK_UNIGT "wait", "\n\n";
	    $coreCounter=$coreCounter+1;
	}
	
	if ($PicardToolsMergeSwitch == 1) { #Alignment BAM-files merged previously	    	
	    
	    my $inSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleIDs[$sampleIDCounter]."/".$aligner."/per_chr/GATK";
	    my $outSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleIDs[$sampleIDCounter]."/".$aligner."/per_chr/GATK";
	    my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pGATKBaseRecalibration'}{'fileEnding'};
	    my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pGATKBaseRecalibration'}{'fileEnding'};
	    
	    for (my $chromosomeCounter=0;$chromosomeCounter<scalar(@chromosomes);$chromosomeCounter++) { #For all chromosomes	    
		
		if ($chromosomeCounter == 0) {
		    
		    print GATK_UNIGT "java -Xmx4g ";
		    print GATK_UNIGT "-jar ".$scriptParameter{'picardToolsPath'}."/MergeSamFiles.jar "; #Merge all individual chromosomes to 1 file
		    print GATK_UNIGT "TMP_DIR=".$scriptParameter{'PicardToolsMergeTempDirectory'}; #Temp Directory
		    print GATK_UNIGT "OUTPUT=".$outSampleDirectory."/".$infile.$outfileEnding.".bam "; #OutFile
		}
		
		print GATK_UNIGT "INPUT=".$inSampleDirectory."/".$infile.$infileEnding.$chromosomes[$chromosomeCounter].".bam "; #InFile
	    }
	    print GATK_UNIGT "& ", "\n\n";
	    $callsCounter++;
	    
	    if ($callsCounter eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} cores
		
		print GATK_UNIGT "wait", "\n\n";
		$coreCounter=$coreCounter+1;
	    }
	    
	    print GATK_UNIGT "samtools index ";
	    print GATK_UNIGT $outSampleDirectory."/".$infile.$outfileEnding.".bam &", "\n\n"; #Index just created PicardTools outfile
	    $callsCounter++;	    
	}
	
	else  { #No previous merge of alignment BAM-files
	    
	    for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{ $sampleIDs[$sampleIDCounter] } });$infileCounter++) { #For all infiles per lane
		
		my $infile = $infilesLaneNoEnding{ $sampleIDs[$sampleIDCounter] }[$infileCounter];
		
		if ($callsCounter eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} cores
		    
		    print GATK_UNIGT "wait", "\n\n";
		    $coreCounter=$coreCounter+1;
		}
		
		my $inSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleIDs[$sampleIDCounter]."/".$aligner."/per_chr/GATK";
		my $outSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleIDs[$sampleIDCounter]."/".$aligner."/per_chr/GATK";
		my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pGATKBaseRecalibration'}{'fileEnding'};
		my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pGATKBaseRecalibration'}{'fileEnding'};
		
		for (my $chromosomeCounter=0;$chromosomeCounter<scalar(@chromosomes);$chromosomeCounter++) { #For all chromosomes	    
		    
		    if ($chromosomeCounter == 0) {
			
			print GATK_UNIGT "java -Xmx4g ";
			print GATK_UNIGT "-jar ".$scriptParameter{'picardToolsPath'}."/MergeSamFiles.jar "; #Merge all individual chromosomes to 1 file
			print GATK_UNIGT "TMP_DIR=".$scriptParameter{'PicardToolsMergeTempDirectory'}; #Temp Directory
			print GATK_UNIGT "OUTPUT=".$outSampleDirectory."/".$infile.$outfileEnding.".bam "; #OutFile
		    }
		    
		    print GATK_UNIGT "INPUT=".$inSampleDirectory."/".$infile.$infileEnding.$chromosomes[$chromosomeCounter].".bam "; #InFile
		}
		print GATK_UNIGT "& ", "\n\n";
		$callsCounter++;
		
	    }
	    for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{ $sampleIDs[$sampleIDCounter] } });$infileCounter++) { #For all infiles per lane
		if ($callsCounter eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} cores
		    
		    print GATK_UNIGT "wait", "\n\n";
		    $coreCounter=$coreCounter+1;
		}
		
		my $infile = $infilesLaneNoEnding{ $sampleIDs[$sampleIDCounter] }[$infileCounter];
		print GATK_UNIGT "samtools index ";
		print GATK_UNIGT $outSampleDirectory."/".$infile.$outfileEnding.".bam &", "\n\n"; #Index just created PicardTools outfile
		$callsCounter++;
	    }
	}
    }
#All infiles should now be merged to 1 file.
}

sub SampleCheck { 
###Tests sample for correct relatives (only performed for samples with relatives defined in pedigree file) performed on sequence data.

    my $familyID = $_[0]; #familyID NOTE: not sampleid 
    my $aligner = $_[1];
    my $callType = $_[2]; #SNV,INDEL or BOTH

    `mkdir -p $scriptParameter{'outDataDir'}/$familyID/$aligner/info;`; #Creates the aligner folder and info data file directory
    `mkdir -p $scriptParameter{'outDataDir'}/$familyID/$aligner/samplecheck`; #Creates the aligner folder, Samplecheck data file directory
    `mkdir -p $scriptParameter{'outScriptDir'}/$familyID/$aligner`; #Creates the aligner folder script file directory
    if ($scriptParameter{'pSampleCheck'} == 1) {
	$filename = $scriptParameter{'outScriptDir'}."/".$familyID."/".$aligner."/samplecheck_".$familyID."_".$callType."."; 
    }
    elsif ($scriptParameter{'pSampleCheck'} == 2) { #Dry run
	$filename = $scriptParameter{'outScriptDir'}."/".$familyID."/".$aligner."/dry_run_samplecheck_".$familyID."_".$callType."."; 
	print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";
    }
    Checkfnexists($filename, $fnend);

###Info and Logg
    print STDOUT "Creating sbatch script Sample Check (Gender & Relatives) and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script Sample Check (Gender & Relatives) and writing script file(s) to: ".$filename, "\n";
    print STDOUT "Sbatch script Sample Check (Gender & Relatives) data files will be written to: ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/samplecheck", "\n";print MASTERL "Sbatch script Sample Check (Gender & Relatives) data files will be written to: ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/samplecheck", "\n";

    open (SCHECK, ">".$filename) or die "Can't write to ".$filename.": $!\n";
    
    print SCHECK "#! /bin/bash -l", "\n";
    print SCHECK "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
    print SCHECK "#SBATCH -n 1", "\n";
    print SCHECK "#SBATCH -C thin", "\n";	
    print SCHECK "#SBATCH -t 1:00:00", "\n";
    print SCHECK "#SBATCH -J SCheck_".$familyID."_".$callType, "\n";
    if ($scriptParameter{'pSampleCheck'} == 1) {
	print SCHECK "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/samplecheck_".$familyID."_".$callType.".".$fnt.".stderr.txt", "\n";
	print SCHECK "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/samplecheck_".$familyID."_".$callType.".".$fnt.".stdout.txt", "\n";
    }
    elsif ($scriptParameter{'pSampleCheck'} == 2) { #Dry run
	print SCHECK "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/dry_run_samplecheck_".$familyID."_".$callType.".".$fnt.".stderr.txt", "\n";
	print SCHECK "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/dry_run_samplecheck_".$familyID."_".$callType.".".$fnt.".stdout.txt", "\n";
    }

    unless ($scriptParameter{'email'} eq 0) {
	print SCHECK "#SBATCH --mail-type=END", "\n";
	print SCHECK "#SBATCH --mail-type=FAIL", "\n";
	print SCHECK "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";	
    }
    
    print SCHECK 'echo "Running on: $(hostname)"',"\n\n";
    
    my $inFamilyDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK";
    my $outFamilyDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/samplecheck";
    my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pGATKVariantRecalibration'}{'fileEnding'};

    print SCHECK "#Create Plink .ped and .map file per family using vcfTools","\n";
    print SCHECK "vcftools ";
    print SCHECK "--vcf ".$inFamilyDirectory."/".$familyID.$infileEnding.$callType.".vcf "; #InFile
    print SCHECK "--plink "; #PLINK format
    print SCHECK "--out ".$outFamilyDirectory."/".$familyID, "\n\n"; #OutFile (.ped and .map)

    print SCHECK "#Create vcfTools inbreeding coefficient F per family using vcfTools","\n";
    print SCHECK "vcftools ";
    print SCHECK "--vcf ".$inFamilyDirectory."/".$familyID.$infileEnding.$callType.".vcf "; #InFile
    print SCHECK "--het "; #Individual inbreeding
    print SCHECK "--out ".$outFamilyDirectory."/".$familyID, "\n\n"; #Outfile

    print SCHECK "#Create Plink .mibs per family","\n"; 
    print SCHECK "plink ";
    print SCHECK "--noweb "; #No web check
    print SCHECK "--ped ".$outFamilyDirectory."/".$familyID.".ped "; #InFile
    print SCHECK "--map ".$outFamilyDirectory."/".$familyID.".map "; #InFile
    print SCHECK "--cluster "; #Perform IBS clustering
    print SCHECK "--matrix "; #Create a N x N matrix of genome-wide average IBS pairwise identities
    print SCHECK "--out ".$outFamilyDirectory."/".$familyID, "\n\n"; #OutFile

    print SCHECK "#Create Plink sexcheck per family","\n"; 
    print SCHECK "plink ";
    print SCHECK "--noweb "; #No web check
    print SCHECK "--ped ".$outFamilyDirectory."/".$familyID.".ped "; #InFile
    print SCHECK "--map ".$outFamilyDirectory."/".$familyID.".map "; #InFile
    print SCHECK "--check-sex "; #uses X chromosome data to determine sex (i.e. based on heterozygosity rates) 
    print SCHECK "--out ".$outFamilyDirectory."/".$familyID, "\n\n"; #OutFile
    
    print SCHECK "wait", "\n\n";    
    
    close(SCHECK); 
    if ($scriptParameter{'pSampleCheck'} == 1) {
	FIDSubmitJob(0,$familyID, 2, $callType,$filename,0);
    }
    return;
}

sub RankVariants { 
###Filter and Rank variants depending on mendelian inheritance, frequency and phenotype using rank_filter:chr.pl
   
    my $familyID = $_[0]; #familyID NOTE: not sampleid 
    my $aligner = $_[1];
    my $callType = $_[2]; #SNV,INDEL or BOTH
 
    `mkdir -p $scriptParameter{'outDataDir'}/$familyID/$aligner/info;`; #Creates the alignment folder and info data file directory
    `mkdir -p $scriptParameter{'outScriptDir'}/$familyID/$aligner;`; #Creates the aligner script folder 

    if ($scriptParameter{'pRankVariants'} == 1) { 
	$filename = $scriptParameter{'outScriptDir'}."/".$familyID."/".$aligner."/rank_variants_".$familyID."_".$callType.".";
    }
    elsif ($scriptParameter{'pRankVariants'} == 2) { #Dry run 
	$filename = $scriptParameter{'outScriptDir'}."/".$familyID."/".$aligner."/dry_run_rank_variants_".$familyID."_".$callType.".";
	print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";
    }
    Checkfnexists($filename, $fnend);

###Info and Logg
    print STDOUT "Creating sbatch script for RankVariants and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script for RankVariants and writing script file(s) to: ".$filename, "\n";
    
###Create the ranking/Db selection directories
    for (my $ImportantDbFileOutFileCounter=0;$ImportantDbFileOutFileCounter<scalar(@ImportantDbFileOutFile);$ImportantDbFileOutFileCounter++) {
	
	my ($volume,$directories,$file) = File::Spec->splitpath($ImportantDbFileOutFile[$ImportantDbFileOutFileCounter]);
	`mkdir -p $directories;`; 
	print STDOUT "RankVariants data files will be written to: ".$directories.$familyID."_ranked_".$callType.".txt", "\n";print MASTERL "RankVariants data files will be written to: ".$directories.$familyID."_ranked_".$callType.".txt", "\n";    
    }

    open (RV, ">".$filename) or die "Can't write to ".$filename.": $!\n";
    
    print RV "#! /bin/bash -l", "\n";
    print RV "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
    print RV "#SBATCH -p node -n 1", "\n";
    print RV "#SBATCH -C thin", "\n";	
    print RV "#SBATCH -t 05:00:00", "\n";
    print RV "#SBATCH -J RV_".$familyID."_".$callType, "\n";

    if ($scriptParameter{'pRankVariants'} == 1) {
	print RV "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/rank_variants_".$familyID."_".$callType.".".$fnt.".stderr.txt", "\n";
	print RV "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/rank_variants_".$familyID."_".$callType.".".$fnt.".stdout.txt", "\n";
    }
    elsif ($scriptParameter{'pRankVariants'} == 2) { #Dry run
	print RV "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/dry_run_rank_variants_".$familyID."_".$callType.".".$fnt.".stderr.txt", "\n";
	print RV "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/dry_run_rank_variants_".$familyID."_".$callType.".".$fnt.".stdout.txt", "\n";
    }
    
    unless ($scriptParameter{'email'} eq 0) {
	print RV "#SBATCH --mail-type=END", "\n";
	print RV "#SBATCH --mail-type=FAIL", "\n";
	print RV "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
    }
    
    print RV 'echo "Running on: $(hostname)"',"\n\n";

    my $inFamilyDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK";
    my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pAddDepth'}{'fileEnding'};

    print RV "#Create db master file to select variants from template", "\n";
    my $nrColumns; #Total Nr of columns 
    my $nrAnnotationColumns; #The number of columns containing annotation info
    my $pNrofCol; #For perl regexp
    if (-f $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK/".$familyID.$infileEnding.$callType.".txt") { #Check if the file exists (rerun actual data to sample from) 
	$pNrofCol = q?perl -nae 'if ($_=~/^#/ ) { chomp($_); my @nr_of_columns=split("\t",$_); print scalar(@nr_of_columns);last; }' ?; #Find the number of columns
	$nrColumns = `$pNrofCol $scriptParameter{'outDataDir'}/$familyID/$aligner/GATK/$familyID$infileEnding$callType.txt;`; #perl onel-liner, inFile and return nr of columns
	$nrAnnotationColumns = $nrColumns - scalar(@sampleIDs);
    }
    elsif (-f $scriptParameter{'outDataDir'}."/".$familyID."/".$scriptParameter{'mergeAnnotatedVariantsDbFile'}) { #First analysis run - no actual data file exists - locate IDN columns from family specific template file (if defined)
	$pNrofCol = q?perl -nae 'if ($_=~/^outinfo/ || $_=~/^outheaders/ ) { chomp($_); my @nr_of_columns=split(",",$_); print scalar(@nr_of_columns);last; }' ?; #Find the number of columns
	$nrColumns = `$pNrofCol $scriptParameter{'outDataDir'}/$familyID/$scriptParameter{'mergeAnnotatedVariantsDbFile'};`; #perl onel-liner, inFile and return nr of columns
	$nrAnnotationColumns = $nrColumns - scalar(@sampleIDs);
    }
    elsif (-f $scriptParameter{'referencesDir'}."/".$scriptParameter{'mergeAnnotatedVariantsTemplateFile'}) { #No information on previous intersectCollect to create annovar_merge file - locate IDN columns from unspecific interSect db template file
	$pNrofCol = q?perl -nae 'if ($_=~/^outinfo/ || $_=~/^outheaders/ ) { chomp($_); my @nr_of_columns=split(",",$_); print scalar(@nr_of_columns);last; }' ?;
	$nrAnnotationColumns = `$pNrofCol $scriptParameter{'referencesDir'}/$scriptParameter{'mergeAnnotatedVariantsTemplateFile'};`-1; #"-1" Since IDN is already factored in from the regexp
	$nrColumns = $nrAnnotationColumns + scalar(@sampleIDs);
    }
    else {
	print STDERR "Could not estimate location of IDN columns from variant file, nor from templates ('-mergeAnnotatedVariantsDbFile' or '-mergeAnnotatedVariantsTemplateFile'). Please provide this information to run 'pRankVariants'.", "\n";
	die;
    }
    
    my $sampleIDcolcond = $nrColumns-1; #To write last IDN entry without "," at the end
    
    $scriptParameter{'ImportantDbMasterFile'} =~ s/FDN/$familyID/g; #Exchange FND for the real familyID
    
##Add relative path to db_template for variant file(s) 
    my ($volume,$directories,$file) = File::Spec->splitpath($scriptParameter{'outDataDir'});
    my @directories = File::Spec->splitdir($directories);#regExpOutDataFile
    my $regExpOutDataFile;
    for (my $directoryCount=1;$directoryCount<scalar(@directories);$directoryCount++) {
	
	$regExpOutDataFile .= "\\/".$directories[$directoryCount]; #Create escape char for / in later regexp
    }
    $regExpOutDataFile .= $file;
    
##Add relative path to db_template for reference/db files
    ($volume,$directories,$file) = File::Spec->splitpath($scriptParameter{'referencesDir'});
    @directories = File::Spec->splitdir( $directories );
    my $regExpReferenceDirectory;	
    for (my $directoryCount=1;$directoryCount<scalar(@directories);$directoryCount++) {
	
	$regExpReferenceDirectory .= "\\/".$directories[$directoryCount]; #Create escape char for / in later regexp
    }
    $regExpReferenceDirectory .= $file;
    
##Create family specific template
    print RV q?perl -nae 'if ($_=~/outinfo/i) { if ($_=~/IDN/) { my $sidstring; for (my $sampleID=?.$nrAnnotationColumns.q?;$sampleID<?.$nrColumns.q?;$sampleID++) { if ($sampleID<?.$sampleIDcolcond.q?) { $sidstring.="IDN_GT_Call=>0_$sampleID,"} else { $sidstring.="IDN_GT_Call=>0_$sampleID"} } s/IDN/$sidstring/g; print $_;} next;} if ($_=~/outcolumns/i) { if ($_=~/IDN/) { my $sidstring; for (my $sampleID=?.$nrAnnotationColumns.q?;$sampleID<?.$nrColumns.q?;$sampleID++) { if ($sampleID<?.$sampleIDcolcond.q?) { $sidstring.="0_$sampleID,"} else { $sidstring.="0_$sampleID"} } s/IDN/$sidstring/g; print $_;} next;} if ($_=~/outheaders/i) { if ($_=~/IDN/) { my $sidstring; for (my $sampleID=?.$nrAnnotationColumns.q?;$sampleID<?.$nrColumns.q?;$sampleID++) { if ($sampleID<?.$sampleIDcolcond.q?) { $sidstring.="IDN_GT_Call,"} else { $sidstring.="IDN_GT_Call"} } s/IDN/$sidstring/g; print $_;} next;} elsif ($_=~s/FDN_|FDN/?.$familyID.q?/g) { if($_=~s/^ODF/?.$regExpOutDataFile.q?/g) {} if($_=~s/ALIGNER/?.$aligner.q?/g) {} if($_=~s/FILEENDING_/?.$infileEnding.q?/g) {} if($_=~s/CALLTYPE/?.$callType.q?/g) {} if ($_=~/IDN/) { my $sidstring; for (my $sampleID=?.$nrAnnotationColumns.q?;$sampleID<?.$nrColumns.q?;$sampleID++) { if ($sampleID<?.$sampleIDcolcond.q?) { $sidstring.="$sampleID,"} else { $sidstring.="$sampleID"} } s/IDN/$sidstring/g; print $_;} else { print $_;} } else { if($_=~s/^RD/?.$regExpReferenceDirectory.q?/g) {} print $_;}' ?;
    print RV $scriptParameter{'referencesDir'}."/".$scriptParameter{'ImportantDbTemplate'}." "; #Infile
    print RV "> ".$scriptParameter{'outDataDir'}."/".$familyID."/".$scriptParameter{'ImportantDbMasterFile'}, "\n\n"; #OutFile
    
    my $haploTypeCallerFile = $inFamilyDirectory."/".$familyID.$infileEnding.$callType.".txt";

###Add chr if required
    if ( ($scriptParameter{'pAddDepth'} == 0) && ($humanGenomeReferenceSource eq "GRCr") ) {
	print RV "#Add chromosome prefix", "\n";
	print RV q?perl -i -p -e ' if($_=~/^#/) {} else {s/^(.+)/chr$1/g }' ?;
	print RV $haploTypeCallerFile, "\n\n"; #InFile
    }

###Only Clinically interesting variants
    
    if ( ($scriptParameter{'pGATKHaploTypeCaller'} > 0) || (-f $haploTypeCallerFile) ) { #HaplotypeCaller has been used in present call or previously

	print RV "#Create temp_file containing only clinically interesting variants (to avoid duplicates in ranked list)", "\n";
	print RV "perl ".$scriptParameter{'inScriptDir'}."/intersectCollect.pl ";
	print RV "-db ".$scriptParameter{'outDataDir'}."/".$familyID."/".$scriptParameter{'ImportantDbMasterFile'}." "; #A tab-sep file containing 1 db per line
	print RV "-s 1 "; #Select all entries in first infile matching keys in subsequent db files
	print RV "-sofs "; #Selected variants and orphan db files out data directory
	for (my $ImportantDbFileOutFileCounter=0;$ImportantDbFileOutFileCounter<scalar(@ImportantDbFileOutFile);$ImportantDbFileOutFileCounter++) {
	    if ($ImportantDbFileOutFileCounter eq scalar(@ImportantDbFileOutFile)-1) {
		print RV $ImportantDbFileOutFile[$ImportantDbFileOutFileCounter]." ","\n\n";
	    }
	    else {
		print RV $ImportantDbFileOutFile[$ImportantDbFileOutFileCounter].",";
	    }
	}
		
###Ranking
	print RV "#Ranking", "\n";
	for (my $ImportantDbFileOutFileCounter=1;$ImportantDbFileOutFileCounter<scalar(@ImportantDbFileOutFile);$ImportantDbFileOutFileCounter++) { #Skip orphan file and run selected files
	    print RV "perl ".$scriptParameter{'inScriptDir'}."/rank_list_filter.pl ";
	    print RV "-i ".$ImportantDbFileOutFile[$ImportantDbFileOutFileCounter]." "; #InFile
	    if ($scriptParameter{'environmentUppmax'} == 1) {
		print RV "-cmms_imdb 1 ";
	    }
	    print RV "-dgf ".$scriptParameter{'geneFiltering'}." "; #Filtering of genes that should be removed from downstream processing
	    print RV "-dgfl ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'geneFilteringList'}." "; #List of genes that should be removed from downstream processing
	    print RV "-im_db_file ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'ImportantDbFile'}." "; #Db file of clinically relevant variants
	    print RV "-im_db_cc ".$scriptParameter{'ImportantDbGeneCoverageCalculation'}." "; #Add coverage info for clinically relevant variants
	    print RV "-im_db_gidc ".$scriptParameter{'ImportantDbGeneIdCol'}." "; #Identifer column number for coverage calculation
	    print RV "-rs ".$scriptParameter{'rankScore'}." "; #The rank score cut-off
	    print RV "-pedigree ".$scriptParameter{'pedigreeFile'}." "; #Pedigree file
	    print RV "-tarcov "; #Target coverage files for family members, comma sep
	    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) {#For all sample ids 
		
		my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleIDs[$sampleIDCounter]}{'pPicardToolsMarkduplicates'}{'fileEnding'}; #Last program before coverage calculation
		my ($infile, $PicardToolsMergeSwitch) = CheckIfMergedFiles($sampleIDs[$sampleIDCounter]);
 
		if ($PicardToolsMergeSwitch == 1) { #Files was merged previously

		    if ($sampleIDCounter eq scalar(@sampleIDs)-1) {
			
			print RV $scriptParameter{'outDataDir'}."/".$sampleIDs[$sampleIDCounter]."/".$aligner."/coverageReport/".$infile.$infileEnding."_target_coverage.txt ";
		    }
		    else {
			
			print RV $scriptParameter{'outDataDir'}."/".$sampleIDs[$sampleIDCounter]."/".$aligner."/coverageReport/".$infile.$infileEnding."_target_coverage.txt,";			    
		    }
		}
		else { #No previous merge

		    for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{$sampleIDs[$sampleIDCounter]} });$infileCounter++) { #For all infiles per lane
			
			my $infile = $infilesLaneNoEnding{$sampleIDs[$sampleIDCounter]}[$infileCounter];
			
			if ($sampleIDCounter eq scalar(@sampleIDs)-1) {
			    
			    print RV $scriptParameter{'outDataDir'}."/".$sampleIDs[$sampleIDCounter]."/".$aligner."/coverageReport/".$infile.$infileEnding."_target_coverage.txt ";
			}
			else {
			    
			    print RV $scriptParameter{'outDataDir'}."/".$sampleIDs[$sampleIDCounter]."/".$aligner."/coverageReport/".$infile.$infileEnding."_target_coverage.txt,";
			}
			
		    }
		}
	    }
	    ($volume,$directories,$file) = File::Spec->splitpath( $ImportantDbFileOutFile[$ImportantDbFileOutFileCounter] ); #Collect outfile directory
	    print RV "-o ".$directories.$familyID."_ranked_".$callType.".txt", "\n\n"; #OutFile
	}
    }
    

###Create a Mosaic BAM file for viewing only relevant variants related to clinical interesting genes 

    print RV "#Create a Mosaic BAM file for viewing only relevant variants related to clinical interesting genes", "\n";
    print RV "cp ";
    print RV $directories.$familyID."_ranked_".$callType.".txt "; #InFile
    print RV $directories.$familyID."_ranked_".$callType."_temp.txt", "\n\n"; #OutFile

    print RV q?perl -i -p -e 'unless ($_=~/^#/) { s/^chr(.+)/$1/g }' ?;
    print RV $directories.$familyID."_ranked_".$callType."_temp.txt", "\n\n"; #InFile, remove chr for intersect with BAM
    
    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) {#For all sampleIDs
	
	my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleIDs[$sampleIDCounter]}{'pPicardToolsMarkduplicates'}{'fileEnding'}; #Last program before calculation
	my ($infile, $PicardToolsMergeSwitch) = CheckIfMergedFiles($sampleIDs[$sampleIDCounter]);
 
	if ($PicardToolsMergeSwitch == 1) { #Files was merged previously
	
	    print RV "intersectBed ";
	    print RV "-wa ";
	    print RV "-abam ".$scriptParameter{'outDataDir'}."/".$sampleIDs[$sampleIDCounter]."/".$aligner."/".$infile.$infileEnding.".bam "; #InFile (BAM format)
	    print RV "-b ".$directories.$familyID."_ranked_".$callType."_temp.txt "; #InFile (temp)
	    print RV "> ".$directories.$infile.".bam &", "\n\n"; #OutFile		
	}
	else { #No previous merge

	    for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{$sampleIDs[$sampleIDCounter]} });$infileCounter++) { #For all infiles per lane
		
		my $infile = $infilesLaneNoEnding{$sampleIDs[$sampleIDCounter]}[$infileCounter];

		print RV "intersectBed ";
		print RV "-wa ";
		print RV "-abam ".$scriptParameter{'outDataDir'}."/".$sampleIDs[$sampleIDCounter]."/".$aligner."/".$infile.$infileEnding.".bam "; #InFile (BAM format)
		print RV "-b ".$directories.$familyID."_ranked_".$callType."_temp.txt "; #InFile (temp)
		print RV "> ".$directories.$infile.".bam &", "\n\n"; #OutFile
	    }
	}
    }
    print RV "wait\n\n";

    print RV "rm ".$directories.$familyID."_ranked_".$callType."_temp.txt", "\n\n"; #Remove temp file used in the intersect
	
###Research variants
    
##Ranking
    print RV "#Ranking", "\n";
    print RV "perl ".$scriptParameter{'inScriptDir'}."/rank_list_filter.pl ";
    print RV "-i ".$ImportantDbFileOutFile[0]." ";
    print RV "-dgf ".$scriptParameter{'geneFiltering'}." "; #Filtering of genes that should be removed from downstream processing
    print RV "-dgfl ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'geneFilteringList'}." "; #List of genes that should be removed from downstream processing
    print RV "-im_db_file ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'allElementsDbFile'}." "; #Db file of research variants
    print RV "-im_db_cc ".$scriptParameter{'allElementsDbGeneCoverageCalculation'}." "; #Add coverage info for research variants
    print RV "-im_db_gidc ".$scriptParameter{'allElementsDbGeneIdCol'}." "; #Identifer column number for coverage calculation
    print RV "-rs ".$scriptParameter{'rankScore'}." "; #The rank score cut-off
    print RV "-pedigree ".$scriptParameter{'pedigreeFile'}." "; #Pedigree file
    print RV "-tarcov "; #Target coverage files for family members, comma sep
    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) {#For all sample ids 
	
	my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleIDs[$sampleIDCounter]}{'pPicardToolsMarkduplicates'}{'fileEnding'}; #Last program before calculation
	my ($infile, $PicardToolsMergeSwitch) = CheckIfMergedFiles($sampleIDs[$sampleIDCounter]);
	
	if ($PicardToolsMergeSwitch == 1) { #Files was merged previously
	    
	    if ($sampleIDCounter eq scalar(@sampleIDs)-1) {
		
		print RV $scriptParameter{'outDataDir'}."/".$sampleIDs[$sampleIDCounter]."/".$aligner."/coverageReport/".$infile.$infileEnding."_target_coverage.txt ";
	    }
	    else {
		
		print RV $scriptParameter{'outDataDir'}."/".$sampleIDs[$sampleIDCounter]."/".$aligner."/coverageReport/".$infile.$infileEnding."_target_coverage.txt,";			    
	    }
	}
	else { #No previous merge
	    
	    for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{$sampleIDs[$sampleIDCounter]} });$infileCounter++) { #For all infiles per lane
		
		my $infile = $infilesLaneNoEnding{$sampleIDs[$sampleIDCounter]}[$infileCounter];
		
		if ($sampleIDCounter eq scalar(@sampleIDs)-1) {
		    
		    print RV $scriptParameter{'outDataDir'}."/".$sampleIDs[$sampleIDCounter]."/".$aligner."/coverageReport/".$infile.$infileEnding."_target_coverage.txt ";
		}
		else {
		    
		    print RV $scriptParameter{'outDataDir'}."/".$sampleIDs[$sampleIDCounter]."/".$aligner."/coverageReport/".$infile.$infileEnding."_target_coverage.txt,";
		}
		
	    }
	}
    }
    
    ($volume,$directories,$file) = File::Spec->splitpath( $ImportantDbFileOutFile[0] ); #Create outfile path
    print RV "-o ".$directories.$familyID."_ranked_".$callType.".txt", "\n\n";
    
    for (my $ImportantDbFileOutFileCounter=0;$ImportantDbFileOutFileCounter<scalar(@ImportantDbFileOutFile);$ImportantDbFileOutFileCounter++) {
	print RV "rm "; #Remove select files
	print RV $ImportantDbFileOutFile[$ImportantDbFileOutFileCounter], "\n\n";
    }

    close(RV);   
    if ($scriptParameter{'pRankVariants'} == 1) {
	FIDSubmitJob(0,$familyID, 1, $callType,$filename,0);
    }
    return;
}

sub AddDp { 
###Adds depth (=DP) for all nonvariants pos for all chr (and subjects) to create a master file containing all annovar information and DP for nonvariants in annovar_merged.txt master file. NOTE: Overwrites current ..annovar_merged.txt file. 

    my $familyID = $_[0]; #familyID NOTE: not sampleid  
    my $aligner = $_[1];
    my $callType = $_[2]; #SNV,INDEL or BOTH 
    
    `mkdir -p $scriptParameter{'outDataDir'}/$familyID/$aligner/info;`; #Creates the alignment folder and info data file directory
    `mkdir -p $scriptParameter{'outDataDir'}/$familyID/$aligner/GATK;`; #Creates the aligner and GATK folder   
    `mkdir -p $scriptParameter{'outScriptDir'}/$familyID/$aligner;`; #Creates the aligner script folder    
    
    if ($scriptParameter{'pAddDepth'} == 1) {
	$filename = $scriptParameter{'outScriptDir'}."/".$familyID."/".$aligner."/add_depth_".$familyID."_".$callType.".";
    }
    elsif ($scriptParameter{'pAddDepth'} == 2) { #Dry run
	$filename = $scriptParameter{'outScriptDir'}."/".$familyID."/".$aligner."/dry_run_add_depth_".$familyID."_".$callType.".";
	print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";
    }
    Checkfnexists($filename, $fnend);
    
###Info and Logg
    print STDOUT "Creating sbatch script AddDepth and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script AddDepth and writing script file(s) to: ".$filename, "\n";
    print STDOUT "Sbatch script AddDepth data files will be written to: ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK", "\n";print MASTERL "Sbatch script AddDepth data files will be written to: ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK", "\n";

    open (ADDDP, ">".$filename) or die "Can't write to ".$filename.": $!\n";
    
    print ADDDP "#! /bin/bash -l", "\n";
    print ADDDP "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
    print ADDDP "#SBATCH -p node -n 1", "\n";
    print ADDDP "#SBATCH -C thin", "\n";	
    print ADDDP "#SBATCH -t 10:00:00", "\n";
    print ADDDP "#SBATCH -J AddDp_".$familyID."_".$callType, "\n";

    if ($scriptParameter{'pAddDepth'} == 1) {
	print ADDDP "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/add_depth_".$familyID."_".$callType.".".$fnt.".stderr.txt", "\n";
	print ADDDP "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/add_depth_".$familyID."_".$callType.".".$fnt.".stdout.txt", "\n";
    }
    elsif ($scriptParameter{'pAddDepth'} == 2) { #Dry run
	print ADDDP "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/dry_run_add_depth_".$familyID."_".$callType.".".$fnt.".stderr.txt", "\n";
	print ADDDP "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/dry_run_add_depth_".$familyID."_".$callType.".".$fnt.".stdout.txt", "\n";
    }

    unless ($scriptParameter{'email'} eq 0) {	
	print ADDDP "#SBATCH --mail-type=END", "\n";
	print ADDDP "#SBATCH --mail-type=FAIL", "\n";
	print ADDDP "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
    }
    
    print ADDDP 'echo "Running on: $(hostname)"',"\n\n";
    
    my $inFamilyDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK";
    my $outFamilyDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK";
    my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pMergeAnnotatedVariants'}{'fileEnding'};
    my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pAddDepth'}{'fileEnding'};
    
#Find all "./." per sample ID and print chr pos to new file (mpileup -l format)
    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) { #For all sample ids, find nonvariants
	
	print ADDDP "#Find all './.' per sampleID and print chrosome position to new file (mpileup -l format)", "\n";
	
	print ADDDP q?perl -F'\t' -nae' if ($_=~ /?.$sampleIDs[$sampleIDCounter].q?\S+\.\/\./ ) { print "$F[0] $F[1]","\n"; }' ?; #print chromosome and start for sampleID
	print ADDDP $inFamilyDirectory."/".$familyID.$infileEnding.$callType.".txt "; #InFile
	print ADDDP "> ".$outFamilyDirectory."/".$sampleIDs[$sampleIDCounter]."_nonvariants.txt", "\n\n"; #OutFile
	
	if ($humanGenomeReferenceSource eq "hg19") {
	    print ADDDP "#Remove chr", "\n";
	    print ADDDP q?perl -i -p -e 's/^chr(.+)/$1/g' ?;
	    print ADDDP $outFamilyDirectory."/".$sampleIDs[$sampleIDCounter]."_nonvariants.txt", "\n\n"; #Remove chromosome prefix
	}
	
	print ADDDP "#Samples indirectory (BAM-files)", "\n\n"; #Indirectory for sample BAM-files
	
	my ($infile, $PicardToolsMergeSwitch) = CheckIfMergedFiles($sampleIDs[$sampleIDCounter]);
##Find depth (Only proper pairs)
	print ADDDP "samtools mpileup ";
	print ADDDP "-A "; #count anomalous read pairs
	print ADDDP "-l ".$outFamilyDirectory."/".$sampleIDs[$sampleIDCounter]."_nonvariants.txt "; #list of positions (chr pos) or regions (BED)
	if ($PicardToolsMergeSwitch == 1) { #Files was merged previously
	    
	    print ADDDP $scriptParameter{'outDataDir'}."/".$sampleIDs[$sampleIDCounter]."/".$aligner."/".$infile.".bam "; #InFile (BAM-file)
	}
	else { #No previous merge - list all files at once 
	    for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{$sampleIDs[$sampleIDCounter]} });$infileCounter++) { #For all infiles per lane
		
		my $infile = $infilesLaneNoEnding{$sampleIDs[$sampleIDCounter]}[$infileCounter];
		print ADDDP $scriptParameter{'outDataDir'}."/".$sampleIDs[$sampleIDCounter]."/".$aligner."/".$infile.".bam "; #InFile (BAM-file)
	    }
	}
	print ADDDP "| "; #Pipe
	print ADDDP q?perl -F'\t' -nae' print $F[0],"\t", $F[1],"\t", $F[3], "\n";' ?; #only print chr coordinates 
	print ADDDP "> ".$outFamilyDirectory."/".$sampleIDs[$sampleIDCounter]."_mpileup_nonvariants.txt", "\n\n"; #OutFile
	
	if ($humanGenomeReferenceSource eq "hg19") { #Add chr again for annovar master file uses chr
	    print ADDDP "#Add chr", "\n";
	    print ADDDP q?perl -i -p -e 's/^(.+)/chr$1/g' ?;
	    print ADDDP $outFamilyDirectory."/".$sampleIDs[$sampleIDCounter]."_mpileup_nonvariants.txt", "\n\n";
	}
    }
    
    if ($humanGenomeReferenceSource eq "GRCr") { #Add chr for annovar_merged master file uses chrosome prefix downstream
	print ADDDP q?perl -i -p -e ' if($_=~/^#/) {} else {s/^(.+)/chr$1/g }' ?;
	print ADDDP $inFamilyDirectory."/".$familyID.$infileEnding.$callType.".txt", "\n\n"; #InFile.txt
    }
    
    print ADDDP "#Add depth to original file", "\n";
    print ADDDP "perl ".$scriptParameter{'inScriptDir'}."/add_depth.pl ";
    print ADDDP "-i ".$inFamilyDirectory."/".$familyID.$infileEnding.$callType.".txt "; #InFile
    print ADDDP "-infnv "; #No variant files from mpileup
    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) {#For all sample ids mpileup nonvariant files
	
	if ($sampleIDCounter eq scalar(@sampleIDs)-1) {
	    
	    print ADDDP $outFamilyDirectory."/".$sampleIDs[$sampleIDCounter]."_mpileup_nonvariants.txt ";
	}
	else {
	    
	    print ADDDP $outFamilyDirectory."/".$sampleIDs[$sampleIDCounter]."_mpileup_nonvariants.txt,";	
	}
    }
    print ADDDP "-sid "; #SampleIDs 
    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) {#For all sample ids mpileup nonvariant files
	
	if ($sampleIDCounter eq scalar(@sampleIDs)-1) {
	    
	    print ADDDP $sampleIDs[$sampleIDCounter]." ";
	}
	else {
	    print ADDDP $sampleIDs[$sampleIDCounter].",";	
	    
	}
    }
    print ADDDP "-o ".$inFamilyDirectory."/".$familyID.$infileEnding.$callType.".txt", "\n\n"; #Overwrites original annovar_merge.txt file
    
    close(ADDDP);   
    if ($scriptParameter{'pAddDepth'} == 1) {
	FIDSubmitJob(0,$familyID, 1, $callType,$filename,0);
    }
    return;
}

sub MergeAnnotatedVariants { 
###Merges (& annotates) all variants for all sampleIDs within family to create a master file containing all annotated information
    
    my $familyID = $_[0]; #familyID NOTE: not sampleid 
    my $aligner = $_[1];
    my $callType = $_[2]; #SNV,INDEL or BOTH 
    
    `mkdir -p $scriptParameter{'outDataDir'}/$familyID/$aligner/info;`; #Creates the alignment folder and info data file directory
    `mkdir -p $scriptParameter{'outDataDir'}/$familyID/$aligner/GATK;`; #Creates the aligner and GATK folder   
    `mkdir -p $scriptParameter{'outScriptDir'}/$familyID/$aligner;`; #Creates the aligner script folder    
    
    if ($scriptParameter{'pMergeAnnotatedVariants'} == 1) {
	$filename = $scriptParameter{'outScriptDir'}."/".$familyID."/".$aligner."/mergeannotatedvariants_".$familyID."_".$callType.".";
    }
    elsif ($scriptParameter{'pMergeAnnotatedVariants'} == 2) { #Dry run
	$filename = $scriptParameter{'outScriptDir'}."/".$familyID."/".$aligner."/dry_run_mergeannotatedvariants_".$familyID."_".$callType.".";
	print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";
    }
    Checkfnexists($filename, $fnend);
    
###Info and Logg
    print STDOUT "Creating sbatch script MergeAnnotatedVariants and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script MergeAnnotatedVariants and writing script file(s) to: ".$filename, "\n";
    print STDOUT "Sbatch script MergeAnnotatedVariants data files will be written to: ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK", "\n";print MASTERL "Sbatch script MergeAnnotatedVariants data files will be written to: ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK", "\n";

    open (MERGE_AV, ">".$filename) or die "Can't write to ".$filename.": $!\n";
    
    print MERGE_AV "#! /bin/bash -l", "\n";
    print MERGE_AV "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
    print MERGE_AV "#SBATCH -p node -n 1", "\n";
    print MERGE_AV "#SBATCH -C thin", "\n";	
    print MERGE_AV "#SBATCH -t 04:00:00", "\n";
    print MERGE_AV "#SBATCH -J MERGE_AV_".$familyID."_".$callType, "\n";

    if ($scriptParameter{'pMergeAnnotatedVariants'} == 1) {
	print MERGE_AV "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/mergeannotatedvariants_".$familyID."_".$callType.".".$fnt.".stderr.txt", "\n";
	print MERGE_AV "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/mergeannotatedvariants_".$familyID."_".$callType.".".$fnt.".stdout.txt", "\n";
    }
    elsif ($scriptParameter{'pMergeAnnotatedVariants'} == 2) { #Dry run
	print MERGE_AV "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/dry_run_mergeannotatedvariants_".$familyID."_".$callType.".".$fnt.".stderr.txt", "\n";
	print MERGE_AV "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/dry_run_mergeannotatedvariants_".$familyID."_".$callType.".".$fnt.".stdout.txt", "\n";
    }

    unless ($scriptParameter{'email'} eq 0) {
	print MERGE_AV "#SBATCH --mail-type=END", "\n";
	print MERGE_AV "#SBATCH --mail-type=FAIL", "\n";
	print MERGE_AV "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
    }
    
    print MERGE_AV 'echo "Running on: $(hostname)"',"\n\n";

    my $inFamilyDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK";
    my $outFamilyDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK";
    my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pAnnovar'}{'fileEnding'};
    my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pMergeAnnotatedVariants'}{'fileEnding'};
    
##Create db master file from template
    print MERGE_AV "#Create db master file from template", "\n";
    my $sampleIDColumns = scalar(@sampleIDs)+5; #Requires CMMS format (chr,start,stop,ref_allele,alt_allel,IDN...)
    my $sampleIDcolumnsCondition = scalar(@sampleIDs)+4;
    $scriptParameter{'mergeAnnotatedVariantsDbFile'} =~ s/FDN/$scriptParameter{'familyID'}/g; #Exchange FND for the real familyID
    
##Add relative path to db_template for annovar files 
    my ($volume,$directories,$file) = File::Spec->splitpath($scriptParameter{'outDataDir'});
    my @directories = File::Spec->splitdir($directories);
    my $regExpOutDataFile;
    for (my $directoryCount=1;$directoryCount<scalar(@directories);$directoryCount++) {
       
	$regExpOutDataFile .= "\\/".$directories[$directoryCount]; #Create escape char for / in later regexp
    }
    $regExpOutDataFile .= $file;
    
##Add relative path to db_template for reference files
    ($volume,$directories,$file) = File::Spec->splitpath($scriptParameter{'referencesDir'});
    @directories = File::Spec->splitdir( $directories );
    my $regExpReferenceDirectory;	
    for (my $directoryCount=1;$directoryCount<scalar(@directories);$directoryCount++) {
	
	$regExpReferenceDirectory .= "\\/".$directories[$directoryCount]; #Create escape char for / in later regexp
    }
    $regExpReferenceDirectory .= $file;
    
##Create family specific template
    print MERGE_AV q?perl -nae 'if ($_=~/outinfo/i) { if ($_=~/IDN/) { my $sidstring; for (my $sampleID=5;$sampleID<?.$sampleIDColumns.q?;$sampleID++) { if ($sampleID<?.$sampleIDcolumnsCondition.q?) { $sidstring.="IDN_GT_Call=>0_$sampleID,"} else { $sidstring.="IDN_GT_Call=>0_$sampleID"} } s/IDN/$sidstring/g; print $_;} next;} if ($_=~/outcolumns/i) { if ($_=~/IDN/) { my $sidstring; for (my $sampleID=5;$sampleID<?.$sampleIDColumns.q?;$sampleID++) { if ($sampleID<?.$sampleIDcolumnsCondition.q?) { $sidstring.="0_$sampleID,"} else { $sidstring.="0_$sampleID"} } s/IDN/$sidstring/g; print $_;} next;} if ($_=~/outheaders/i) { if ($_=~/IDN/) { my $sidstring; for (my $sampleID=5;$sampleID<?.$sampleIDColumns.q?;$sampleID++) { if ($sampleID<?.$sampleIDcolumnsCondition.q?) { $sidstring.="IDN_GT_Call,"} else { $sidstring.="IDN_GT_Call"} } s/IDN/$sidstring/g; print $_;} next;} elsif ($_=~s/FDN_|FDN/?.$familyID.q?/g) { if($_=~s/^ODF/?.$regExpOutDataFile.q?/g) {} if($_=~s/ALIGNER/?.$aligner.q?/g) {} if($_=~s/FILEENDING_/?.$infileEnding.q?/g) {} if($_=~s/CALLTYPE/?.$callType.q?/g) {} if ($_=~/IDN/) { my $sidstring; for (my $sampleID=5;$sampleID<?.$sampleIDColumns.q?;$sampleID++) { if ($sampleID<?.$sampleIDcolumnsCondition.q?) { $sidstring.="$sampleID,"} else { $sidstring.="$sampleID"} } s/IDN/$sidstring/g; print $_;} else { print $_;} } else { if($_=~s/^RD/?.$regExpReferenceDirectory.q?/g) {} print $_;}' ?;
    print MERGE_AV $scriptParameter{'referencesDir'}."/".$scriptParameter{'mergeAnnotatedVariantsTemplateFile'}." "; #Infile
    print MERGE_AV "> ".$scriptParameter{'outDataDir'}."/".$familyID."/".$scriptParameter{'mergeAnnotatedVariantsDbFile'}, "\n\n"; #OutFile

    print MERGE_AV "perl ".$scriptParameter{'inScriptDir'}."/intersectCollect.pl ";
    print MERGE_AV "-db ".$scriptParameter{'outDataDir'}."/".$familyID."/".$scriptParameter{'mergeAnnotatedVariantsDbFile'}." ";
    print MERGE_AV "-o ".$outFamilyDirectory."/".$familyID.$outfileEnding.$callType.".txt", "\n\n";
    
    close(MERGE_AV);   
    if ($scriptParameter{'pMergeAnnotatedVariants'} == 1) {
	FIDSubmitJob(0,$familyID, 1, $callType,$filename,0);
    }
    return;
}

sub GATKVariantEvalExome { 
###GATK VariantEval for exome variants

    my $sampleID = $_[0]; 
    my $aligner = $_[1];
    my $callType = $_[2]; #SNV,INDEL or BOTH 
    my $familyID = $_[3]; 

    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/$aligner/info;`; #Creates the aligner folder and info data file directory
    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/$aligner/GATK/varianteval`; #Creates the aligner folder, GATK VariantEval data file directory
    `mkdir -p $scriptParameter{'outScriptDir'}/$sampleID/$aligner`; #Creates the aligner folder script file directory
    
    if ($scriptParameter{'pGATKVariantEvalExome'} == 1) {
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/".$aligner."/gatk_varianteval_exome_".$sampleID."_".$callType.".";
    }
    elsif ($scriptParameter{'pGATKVariantEvalExome'} == 2) { #Dry run
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/".$aligner."/dry_run_gatk_varianteval_exome_".$sampleID."_".$callType.".";
	print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";
    }
    Checkfnexists($filename, $fnend);

###Info and Logg
    print STDOUT "Creating sbatch script GATK VariantEval Exome and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script GATK VariantEval Exome and writing script file(s) to: ".$filename, "\n";
    print STDOUT "Sbatch script GATK VariantEval Exome data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/GATK/varianteval", "\n";print MASTERL "Sbatch script GATK VariantEval Exome data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/GATK/varianteval", "\n";
    
    open (GATK_VAREVALEX, ">".$filename) or die "Can't write to ".$filename.": $!\n";
    
    print GATK_VAREVALEX "#! /bin/bash -l", "\n";
    print GATK_VAREVALEX "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
    print GATK_VAREVALEX "#SBATCH -p node -n 1", "\n";
    print GATK_VAREVALEX "#SBATCH -C thin", "\n";	
    print GATK_VAREVALEX "#SBATCH -t 2:00:00", "\n";
    print GATK_VAREVALEX "#SBATCH -J GATK_VarEvalEx_".$sampleID."_".$callType, "\n";
    
    if ($scriptParameter{'pGATKVariantEvalExome'} == 1) {
	print GATK_VAREVALEX "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/gatk_varianteval_exome_".$sampleID."_".$callType.".".$fnt.".stderr.txt", "\n";
	print GATK_VAREVALEX "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/gatk_varianteval_exome_".$sampleID."_".$callType.".".$fnt.".stdout.txt", "\n";
    }
    elsif ($scriptParameter{'pGATKVariantEvalExome'} == 2) { #Dry run
	print GATK_VAREVALEX "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/dry_run_gatk_varianteval_exome_".$sampleID."_".$callType.".".$fnt.".stderr.txt", "\n";
	print GATK_VAREVALEX "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/dry_run_gatk_varianteval_exome_".$sampleID."_".$callType.".".$fnt.".stdout.txt", "\n";
    }
    
    unless ($scriptParameter{'email'} eq 0) {	
	print GATK_VAREVALEX "#SBATCH --mail-type=END", "\n";
	print GATK_VAREVALEX "#SBATCH --mail-type=FAIL", "\n";
	print GATK_VAREVALEX "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
    }
    
    print GATK_VAREVALEX 'echo "Running on: $(hostname)"',"\n\n";

    my $inSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/GATK";
    my $outSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/GATK/varianteval";
    my $inFamilyDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK";
    my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pGATKVariantRecalibration'}{'fileEnding'};
    my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pGATKVariantRecalibration'}{'fileEnding'};
    my ($infile, $PicardToolsMergeSwitch) = CheckIfMergedFiles($sampleID);
    
    if ($PicardToolsMergeSwitch == 1) { #Files was merged previously
    
###GATK SelectVariants
##Select SampleID from familyID vrecal vcf file
	print GATK_VAREVALEX "#GATK SelectVariants","\n\n";
	print GATK_VAREVALEX "java -Xmx2g ";
	print GATK_VAREVALEX "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
	print GATK_VAREVALEX "-l INFO "; #Set the minimum level of logging
	print GATK_VAREVALEX "-T SelectVariants "; #Type of analysis to run
	print GATK_VAREVALEX "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file
	print GATK_VAREVALEX "-V: ".$inFamilyDirectory."/".$familyID.$infileEnding.$callType.".vcf "; #FamilyID inFile
	print GATK_VAREVALEX "-o ".$outSampleDirectory."/".$infile.$outfileEnding.$callType."_exome.vcf "; #SampleID exome outFile
	print GATK_VAREVALEX "-sn ".$sampleID, "\n\n"; #Include genotypes from this sample

	if ($humanGenomeReferenceSource eq "hg19") {
	    print GATK_VAREVALEX q?perl -i -p -e 's/^chr(.+)/$1/g' ?;
	    print GATK_VAREVALEX $outSampleDirectory."/".$infile.$outfileEnding.$callType.".vcf", "\n\n"; #Remove chromosome prefix
	}

###VariantEval (exome variants)

	my $inSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/GATK/varianteval";

	print GATK_VAREVALEX "#GATK VariantEval","\n\n";
	
	print GATK_VAREVALEX "java -Xmx2g ";
	print GATK_VAREVALEX "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
	print GATK_VAREVALEX "-l INFO "; #Set the minimum level of logging
	print GATK_VAREVALEX "-T VariantEval "; #Type of analysis to run
	print GATK_VAREVALEX "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file
	print GATK_VAREVALEX "-D ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKVariantEvalDbSNP'}." "; #dbSNP file
	print GATK_VAREVALEX "-gold ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKVariantEvalGold'}." "; #Evaluations that count calls at sites of true variation (e.g., indel calls) will use this argument as their gold standard for comparison
	print GATK_VAREVALEX "--eval ".$inSampleDirectory."/".$infile.$infileEnding.$callType."_exome.vcf "; #InFile
	print GATK_VAREVALEX "-o ".$outSampleDirectory."/".$infile.$outfileEnding.$callType."_exome.vcf.varianteval", "\n\n"; #OutFile
    }   
    else { #No previous merge
###GATK SelectVariants
##Select SampleID from familyID vrecal vcf file
	
	for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{$sampleID} });$infileCounter++) { #For all infiles per lane
	    
	    my $infile = $infilesLaneNoEnding{$sampleID}[$infileCounter];
	    
	    print GATK_VAREVALEX "#GATK SelectVariants","\n\n";
	    print GATK_VAREVALEX "java -Xmx2g ";
	    print GATK_VAREVALEX "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
	    print GATK_VAREVALEX "-l INFO "; #Set the minimum level of logging
	    print GATK_VAREVALEX "-T SelectVariants "; #Type of analysis to run
	    print GATK_VAREVALEX "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file
	    print GATK_VAREVALEX "-V: ".$inFamilyDirectory."/".$familyID.$infileEnding.$callType.".vcf "; #FamilyID infile 
	    print GATK_VAREVALEX "-o ".$outSampleDirectory."/".$infile.$outfileEnding.$callType."_exome.vcf "; #SampleID outFile
	    print GATK_VAREVALEX "-sn ".$sampleID, "\n\n"; #Include genotypes from this sample
	    
	    if ($humanGenomeReferenceSource eq "hg19") {
		print GATK_VAREVALEX q?perl -i -p -e 's/^chr(.+)/$1/g' ?;
		print GATK_VAREVALEX $outSampleDirectory."/".$infile.$outfileEnding.$callType.".vcf", "\n\n";  #Remove chromosome prefix
	    }

###VariantEval (exome variants)

	    my $inSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/GATK/varianteval";

	    print GATK_VAREVALEX "#GATK VariantEval","\n\n";
	    
	    print GATK_VAREVALEX "java -Xmx2g ";
	    print GATK_VAREVALEX "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
	    print GATK_VAREVALEX "-l INFO "; #Set the minimum level of logging
	    print GATK_VAREVALEX "-T VariantEval "; #Type of analysis to run
	    print GATK_VAREVALEX "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file
	    print GATK_VAREVALEX "-D ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKVariantEvalDbSNP'}." "; #dbSNP file
	    print GATK_VAREVALEX "-gold ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKVariantEvalGold'}." "; #Evaluations that count calls at sites of true variation (e.g., indel calls) will use this argument as their gold standard for comparison
	    print GATK_VAREVALEX "--eval ".$inSampleDirectory."/".$infile.$infileEnding.$callType."_exome.vcf "; #InFile
	    print GATK_VAREVALEX "-o ".$outSampleDirectory."/".$infile.$outfileEnding.$callType."_exome.vcf.varianteval", "\n\n"; #OutFile
	}
    } 
    
    close(GATK_VAREVALEX);   
    if ($scriptParameter{'pGATKVariantEvalExome'} == 1) {
	FIDSubmitJob(0,$familyID, 2, $callType,$filename,0); #Do not add jobIDs to later jobID{chainkey}
    }
    return;
}

sub GATKVariantEvalAll { 
###GATK VariantEval for all variants

    my $sampleID = $_[0]; 
    my $aligner = $_[1];
    my $callType = $_[2]; #SNV,INDEL or BOTH 
    my $familyID = $_[3]; 

    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/$aligner/info;`; #Creates the aligner folder and info data file directory
    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/$aligner/GATK/varianteval`; #Creates the aligner folder, GATK VariantEval data file directory
    `mkdir -p $scriptParameter{'outScriptDir'}/$sampleID/$aligner`; #Creates the aligner folder script file directory
    
    if ($scriptParameter{'pGATKVariantEvalAll'} == 1) {
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/".$aligner."/gatk_varianteval_".$sampleID."_".$callType.".";
    }
    elsif ($scriptParameter{'pGATKVariantEvalAll'} == 2) { #Dry run
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/".$aligner."/dry_run_gatk_varianteval_".$sampleID."_".$callType.".";
	print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";
    }
    Checkfnexists($filename, $fnend);

###Info and Logg
    print STDOUT "Creating sbatch script GATK VariantEval All and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script GATK VariantEval All and writing script file(s) to: ".$filename, "\n";
    print STDOUT "Sbatch script GATK VariantEval All data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/GATK/varianteval", "\n";print MASTERL "Sbatch script GATK VariantEval All data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/GATK/varianteval", "\n";
    
    open (GATK_VAREVAL, ">".$filename) or die "Can't write to ".$filename.": $!\n";
    
    print GATK_VAREVAL "#! /bin/bash -l", "\n";
    print GATK_VAREVAL "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
    print GATK_VAREVAL "#SBATCH -p node -n 1", "\n";
    print GATK_VAREVAL "#SBATCH -C thin", "\n";	
    print GATK_VAREVAL "#SBATCH -t 2:00:00", "\n";
    print GATK_VAREVAL "#SBATCH -J GATK_VarEvalAll_".$sampleID."_".$callType, "\n";
    
    if ($scriptParameter{'pGATKVariantEvalAll'} == 1) {
	print GATK_VAREVAL "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/gatk_varianteval_".$sampleID."_".$callType.".".$fnt.".stderr.txt", "\n";
	print GATK_VAREVAL "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/gatk_varianteval_".$sampleID."_".$callType.".".$fnt.".stdout.txt", "\n";
    }
    elsif ($scriptParameter{'pGATKVariantEvalAll'} == 2) { #Dry run
	print GATK_VAREVAL "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/dry_run_gatk_varianteval_".$sampleID."_".$callType.".".$fnt.".stderr.txt", "\n";
	print GATK_VAREVAL "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/dry_run_gatk_varianteval_".$sampleID."_".$callType.".".$fnt.".stdout.txt", "\n";
    }
    
    unless ($scriptParameter{'email'} eq 0) {	
	print GATK_VAREVAL "#SBATCH --mail-type=END", "\n";
	print GATK_VAREVAL "#SBATCH --mail-type=FAIL", "\n";
	print GATK_VAREVAL "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
    }
    
    print GATK_VAREVAL 'echo "Running on: $(hostname)"',"\n\n";

    my $inSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/GATK";
    my $outSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/GATK/varianteval";
    my $inFamilyDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK";
    my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pGATKVariantRecalibration'}{'fileEnding'};
    my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pGATKVariantRecalibration'}{'fileEnding'};
    my ($infile, $PicardToolsMergeSwitch) = CheckIfMergedFiles($sampleID);
    
    if ($PicardToolsMergeSwitch == 1) { #Files was merged previously
    
###GATK SelectVariants
##Select SampleID from familyID vrecal vcf file
	print GATK_VAREVAL "#GATK SelectVariants","\n\n";
	print GATK_VAREVAL "java -Xmx2g ";
	print GATK_VAREVAL "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
	print GATK_VAREVAL "-l INFO "; #Set the minimum level of logging
	print GATK_VAREVAL "-T SelectVariants "; #Type of analysis to run
	print GATK_VAREVAL "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file
	print GATK_VAREVAL "-V: ".$inFamilyDirectory."/".$familyID.$infileEnding.$callType.".vcf "; #FamilyID inFile
	print GATK_VAREVAL "-o ".$outSampleDirectory."/".$infile.$outfileEnding.$callType.".vcf "; #SampleID outFile
	print GATK_VAREVAL "-sn ".$sampleID, "\n\n"; #Include genotypes from this sample

	if ($humanGenomeReferenceSource eq "hg19") {
	    print GATK_VAREVAL q?perl -i -p -e 's/^chr(.+)/$1/g' ?;
	    print GATK_VAREVAL $outSampleDirectory."/".$infile.$outfileEnding.$callType.".vcf", "\n\n";  #Remove chromosome prefix
	}

####VariantEval (all variants)

	my $inSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/GATK/varianteval";

	print GATK_VAREVAL "#GATK VariantEval","\n\n";
	
	print GATK_VAREVAL "java -Xmx2g ";
	print GATK_VAREVAL "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
	print GATK_VAREVAL "-l INFO "; #Set the minimum level of logging
	print GATK_VAREVAL "-T VariantEval "; #Type of analysis to run
	print GATK_VAREVAL "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file
	print GATK_VAREVAL "-D ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKVariantEvalDbSNP'}." "; #dbSNP file
	print GATK_VAREVAL "-gold ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKVariantEvalGold'}." "; #Evaluations that count calls at sites of true variation (e.g., indel calls) will use this argument as their gold standard for comparison
	print GATK_VAREVAL "--eval ".$inSampleDirectory."/".$infile.$infileEnding.$callType.".vcf "; #InFile
	print GATK_VAREVAL "-o ".$outSampleDirectory."/".$infile.$outfileEnding.$callType.".vcf.varianteval", "\n\n"; #OutFile
    }   
    else { #No previous merge
###GATK SelectVariants
##Select SampleID from familyID vrecal vcf file
	
	for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{$sampleID} });$infileCounter++) { #For all infiles per lane
	    
	    my $infile = $infilesLaneNoEnding{$sampleID}[$infileCounter];
	    
	    print GATK_VAREVAL "#GATK SelectVariants","\n\n";
	    print GATK_VAREVAL "java -Xmx2g ";
	    print GATK_VAREVAL "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
	    print GATK_VAREVAL "-l INFO "; #Set the minimum level of logging
	    print GATK_VAREVAL "-T SelectVariants "; #Type of analysis to run
	    print GATK_VAREVAL "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file
	    print GATK_VAREVAL "-V: ".$inFamilyDirectory."/".$familyID.$infileEnding.$callType.".vcf "; #FamilyID infile 
	    print GATK_VAREVAL "-o ".$outSampleDirectory."/".$infile.$outfileEnding.$callType.".vcf "; #SampleID outFile
	    print GATK_VAREVAL "-sn ".$sampleID, "\n\n"; #Include genotypes from this sample
	    
	    if ($humanGenomeReferenceSource eq "hg19") {
		print GATK_VAREVAL q?perl -i -p -e 's/^chr(.+)/$1/g' ?;
		print GATK_VAREVAL $outSampleDirectory."/".$infile.$outfileEnding.$callType.".vcf", "\n\n";  #Remove chromosome prefix
	    }

###VariantEval (all variants)

	    my $inSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/GATK/varianteval";

	    print GATK_VAREVAL "#GATK VariantEval","\n\n";
	    
	    print GATK_VAREVAL "java -Xmx2g ";
	    print GATK_VAREVAL "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
	    print GATK_VAREVAL "-l INFO "; #Set the minimum level of logging
	    print GATK_VAREVAL "-T VariantEval "; #Type of analysis to run
	    print GATK_VAREVAL "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file
	    print GATK_VAREVAL "-D ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKVariantEvalDbSNP'}." "; #dbSNP file
	    print GATK_VAREVAL "-gold ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKVariantEvalGold'}." "; #Evaluations that count calls at sites of true variation (e.g., indel calls) will use this argument as their gold standard for comparison
	    print GATK_VAREVAL "--eval ".$inSampleDirectory."/".$infile.$infileEnding.$callType.".vcf "; #InFile
	    print GATK_VAREVAL "-o ".$outSampleDirectory."/".$infile.$outfileEnding.$callType.".vcf.varianteval", "\n\n"; #OutFile
	}
    } 
    
    close(GATK_VAREVAL);   
    if ($scriptParameter{'pGATKVariantEvalAll'} == 1) {
	FIDSubmitJob(0,$familyID, 2, $callType,$filename,0); #Do not add jobIDs to later jobID{chainkey}
    }
    return;
}

sub Annovar { 
###Filter SNVs by gene, region and databases

    my $familyID = $_[0]; #familyID NOTE: not sampleid 
    my $aligner = $_[1];
    my $callType = $_[2]; #SNV,INDEL or BOTH 
    
    `mkdir -p $scriptParameter{'outDataDir'}/ $familyID/$aligner/info;`; #Creates the alignment folder and info data file directory
    `mkdir -p $scriptParameter{'outDataDir'}/ $familyID/$aligner/GATK;`; #Creates the aligner and GATK folder   
    `mkdir -p $scriptParameter{'outScriptDir'}/ $familyID/$aligner;`; #Creates the aligner script folder

    if ($scriptParameter{'pAnnovar'} == 1) {   
	$filename = $scriptParameter{'outScriptDir'}."/".$familyID."/".$aligner."/annovar_".$familyID."_".$callType.".";
    }
    elsif ($scriptParameter{'pAnnovar'} == 2) { #Dry run   
	$filename = $scriptParameter{'outScriptDir'}."/".$familyID."/".$aligner."/dry_run_annovar_".$familyID."_".$callType.".";
	print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";
    }
    Checkfnexists($filename, $fnend);

###Info and Logg
    print STDOUT "Creating sbatch script Annovar and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script Annovar and writing script file(s) to: ".$filename, "\n";
    print STDOUT "Sbatch script Annovar data files will be written to: ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK", "\n";print MASTERL "Sbatch script Annovar data files will be written to: ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK", "\n";

    open (ANVAR, ">".$filename) or die "Can't write to ".$filename.": $!\n";
    
    print ANVAR "#! /bin/bash -l", "\n";
    print ANVAR "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
    print ANVAR "#SBATCH -p node -n ".$scriptParameter{'maximumCores'}, "\n";
    print ANVAR "#SBATCH -C thin", "\n";	
    print ANVAR "#SBATCH -t 7:00:00", "\n";
    print ANVAR "#SBATCH -J ANNOVAR_".$familyID."_".$callType, "\n";
    
    if ($scriptParameter{'pAnnovar'} == 1) {
	print ANVAR "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/annovar_".$familyID."_".$callType.".".$fnt.".stderr.txt", "\n";
	print ANVAR "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/annovar_".$familyID."_".$callType.".".$fnt.".stdout.txt", "\n";    
    }
    elsif ($scriptParameter{'pAnnovar'} == 2) { #Dry run
	print ANVAR "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/dry_run_annovar_".$familyID."_".$callType.".".$fnt.".stderr.txt", "\n";
	print ANVAR "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/dry_run_annovar_".$familyID."_".$callType.".".$fnt.".stdout.txt", "\n";    
    }

    unless ($scriptParameter{'email'} eq 0) {
	print ANVAR "#SBATCH --mail-type=END", "\n";
	print ANVAR "#SBATCH --mail-type=FAIL", "\n";
	print ANVAR "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
    }
    
    print ANVAR 'echo "Running on: $(hostname)"',"\n\n";

    my $inFamilyDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK";
    my $outFamilyDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK";
    my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pGATKVariantRecalibration'}{'fileEnding'};
    my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pAnnovar'}{'fileEnding'};
    
    if ($humanGenomeReferenceSource eq "GRCh") {
	print ANVAR q?perl -i -p -e 's/^(MT)/M/g' ?;
	print ANVAR $inFamilyDirectory."/".$familyID.$infileEnding.$callType.".vcf ", "\n\n"; #Make sure that mitochondral genome is M and not MT
    }
	
    print ANVAR "#Prepare infile to Annovar format from GATK vcf4", "\n";
    print ANVAR "perl ".$scriptParameter{'annovarPath'}."/convert2annovar.pl ".$inFamilyDirectory."/".$familyID.$infileEnding.$callType.".vcf ";
    print ANVAR "-format vcf4 "; #the format of the input file
    print ANVAR "-includeinfo "; #specify that the output should contain additional information in the input line
    print ANVAR "> ".$outFamilyDirectory."/".$familyID.$outfileEnding.$callType."_temp", "\n\n"; #Annovar script
    
    print ANVAR "#Intersect for all samples within familyid and remake file to fit annovar format and subsequent filtering", "\n";
    print ANVAR q?perl -nae 'my @format; my $formatInfo;chomp($_); if ($_=~/^#/) {print $_;next;} if ($_=~/;set=2/) {} else{ if($F[11] eq "PASS") {} else {$F[11] = "PRES";} @format = split(":",$F[13]); print $F[0], "\t", $F[1], "\t", $F[2], "\t", $F[3], "\t", $F[4], "\t"; ?;
    
    my @sampleIDLexSorts = sort @sampleIDs; #Use lexiographically sorted sample IDNs since GATK HaplotypeCaller/UnifiedGT assigns columns in lexigraphical order. @sampleIDs is not lexiographically sorted if taken straight from the command line. This lex sort ensures that if the user did not supply samples in lex order, there will be no sample column swaping. 
    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDLexSorts);$sampleIDCounter++) { #For all sample ids
	
	my $samplecolumn = 14+$sampleIDCounter; #First sample genotype starts at col 14 (start 0, perl). NOTE: Important that samples for HaplotypeCaller/UnifiedGT has same order. Otherwise there will be a sample mix-up.
	
	if ($sampleIDCounter eq scalar(@sampleIDLexSorts)-1) {	#Ensure correct order as long as HaplotypeCAller/UnifiedGT uses lex sort. 
	    print ANVAR q?print "?.$sampleIDLexSorts[$sampleIDCounter].q?:$F[11]:"; @formatInfo = split(":",$F[?.$samplecolumn.q?]); for (my $formatInfoCounter=0;$formatInfoCounter<scalar(@formatInfo);$formatInfoCounter++) { print "$format[$formatInfoCounter]=$formatInfo[$formatInfoCounter]"; if ( $formatInfoCounter<scalar(@formatInfo)-1 ) {print ":"} } print "\n"; } ?;
	}
	else {
	    print ANVAR q?print "?.$sampleIDLexSorts[$sampleIDCounter].q?:FILTER=$F[11]:"; @formatInfo = split(":",$F[?.$samplecolumn.q?]); for (my $formatInfoCounter=0;$formatInfoCounter<scalar(@formatInfo);$formatInfoCounter++) { print "$format[$formatInfoCounter]=$formatInfo[$formatInfoCounter]"; if ( $formatInfoCounter<scalar(@formatInfo)-1 ) {print ":"} } print "\t"; ?;
	}
    }

    print ANVAR "' ".$outFamilyDirectory."/".$familyID.$outfileEnding.$callType."_temp "; #InFile from just created convert2annovar.pl outfile
    print ANVAR "> ".$outFamilyDirectory."/".$familyID.$outfileEnding.$callType, "\n\n"; #OutFile
 
    $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pAnnovar'}{'fileEnding'};
    my $coreCounter=1;   	    

    for (my $tableNamesCounter=0;$tableNamesCounter<scalar(@annovarTableNames);$tableNamesCounter++) { #For all specified table names
	
	if ($tableNamesCounter eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} cores
	    
	    print ANVAR "wait", "\n\n";
	    $coreCounter=$coreCounter+1;
	}
	print ANVAR "perl ".$scriptParameter{'annovarPath'}."/annotate_variation.pl "; #Annovar script 
	print ANVAR "-".$annovarFilteringOption{ $annovarTableNames[$tableNamesCounter] }." "; #Filtering option
	if ( $annovarFilteringOption{ $annovarTableNames[$tableNamesCounter] } eq "geneanno" ) { #Use hgvs output style
	    print ANVAR "-hgvs ";
	}
	print ANVAR "-buildver ".$scriptParameter{'annovarGenomeBuildVersion'}." ";
	if ( $annovarGenericFilteringOption{ $annovarTableNames[$tableNamesCounter] } ) { #Handle generic format
	    print ANVAR "-dbtype generic -genericdbfile ".$annovarTableNames[$tableNamesCounter]." "; #generic db file
	    print ANVAR "--outfile ".$outFamilyDirectory."/".$familyID.$outfileEnding.$callType."_".$annovarTableNames[$tableNamesCounter]." "; #OutFile
	}	
	else{
	    print ANVAR "-dbtype ".$annovarTableNames[$tableNamesCounter]." "; #db file
	}
	if ( ($annovarTableNames[$tableNamesCounter] =~/^snp/) || ($annovarTableNames[$tableNamesCounter] =~/^1000g/) || ($annovarTableNames[$tableNamesCounter] =~/_esp/) ) {#Set MAF TH
	    print ANVAR "--maf_threshold ".$annovarMAFThreshold." ";
	}
	if ( $annovarTableNames[$tableNamesCounter] =~/^avsift/ ) {#Set sift score TH
	    print ANVAR "--sift_threshold ".$annovarSiftThreshold." ";
	}
	print ANVAR $inFamilyDirectory."/".$familyID.$infileEnding.$callType." "; #Infile. Outfile is named using infile prefix except for generic files 
	print ANVAR $scriptParameter{'annovarPath'}."/humandb &", "\n\n"; #annovar/humandb directory is assumed
    }
    print ANVAR "wait", "\n\n";
    
    print ANVAR "rm ".$outFamilyDirectory."/".$familyID.$outfileEnding.$callType."_temp", "\n"; #Remove temp file
    close(ANVAR);

    if ($scriptParameter{'pAnnovar'} == 1) {
	FIDSubmitJob(0,$familyID, 1, $callType,$filename,0);
    }
    return;
}

sub GATKVariantReCalibration { 
#GATK VariantRecalibrator/ApplyRecalibration

    my $familyID = $_[0]; #familyID NOTE: not sampleid 
    my $aligner = $_[1];
    my $callType = $_[2]; #SNV,INDEL or BOTH 
    
    `mkdir -p $scriptParameter{'outDataDir'}/$familyID/$aligner/info;`; #Creates the aligner folder and info data file directory
    `mkdir -p $scriptParameter{'outDataDir'}/$familyID/$aligner/GATK/intermediary`; #Creates the aligner folder, GATK data file directory
    `mkdir -p $scriptParameter{'outDataDir'}/$familyID/$aligner/GATK`; #Creates the aligner folder, GATK data file directory
    `mkdir -p $scriptParameter{'outScriptDir'}/$familyID/$aligner`; #Creates the aligner folder script file directory
    
    if ($scriptParameter{'pGATKVariantRecalibration'} == 1) {
	$filename = $scriptParameter{'outScriptDir'}."/".$familyID."/".$aligner."/gatk_variantrecalibration_".$familyID."_".$callType.".";   
    }
    elsif ($scriptParameter{'pGATKVariantRecalibration'} == 2) { #Dry run
	$filename = $scriptParameter{'outScriptDir'}."/".$familyID."/".$aligner."/dry_run_gatk_variantrecalibration_".$familyID."_".$callType."."; 
	print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";  
    }

    Checkfnexists($filename, $fnend);

###Info and Logg
    print STDOUT "Creating sbatch script GATK VariantRecalibrator/ApplyRecalibration and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script GATK VariantRecalibrator/ApplyRecalibration and writing script file(s) to: ".$filename, "\n";
    print STDOUT "Sbatch script GATK VariantRecalibrator/ApplyRecalibration data files will be written to: ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK", "\n";print MASTERL "Sbatch script GATK VariantRecalibrator/ApplyRecalibration data files will be written to: ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK", "\n";

    open (GATK_VARREC, ">".$filename) or die "Can't write to ".$filename.": $!\n";
    
    print GATK_VARREC "#! /bin/bash -l", "\n";
    print GATK_VARREC "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
    print GATK_VARREC "#SBATCH -p node -n ".$scriptParameter{'maximumCores'}, "\n";
    print GATK_VARREC "#SBATCH -C thin", "\n";	
    print GATK_VARREC "#SBATCH -t 10:00:00", "\n";
    print GATK_VARREC "#SBATCH -J GATK_VarReCal_".$familyID."_".$callType, "\n";
    if ($scriptParameter{'pGATKVariantRecalibration'} == 1) {
	print GATK_VARREC "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/gatk_variantrecalibration_".$familyID."_".$callType.".".$fnt.".stderr.txt", "\n";
	print GATK_VARREC "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/gatk_variantrecalibration_".$familyID."_".$callType.".".$fnt.".stdout.txt", "\n";
    }
    elsif ($scriptParameter{'pGATKVariantRecalibration'} == 2) { #Dry run
	print GATK_VARREC "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/dry_run_gatk_variantrecalibration_".$familyID."_".$callType.".".$fnt.".stderr.txt", "\n";
	print GATK_VARREC "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/dry_run_gatk_variantrecalibration_".$familyID."_".$callType.".".$fnt.".stdout.txt", "\n";
    }

    unless ($scriptParameter{'email'} eq 0) {
	print GATK_VARREC "#SBATCH --mail-type=END", "\n";
	print GATK_VARREC "#SBATCH --mail-type=FAIL", "\n";
	print GATK_VARREC "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
    }
    
    print GATK_VARREC 'echo "Running on: $(hostname)"',"\n\n";
 
    my $outFamilyFileDirectory = $scriptParameter{'outDataDir'}."/".$familyID;
    my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pGATKHaploTypeCaller'}{'fileEnding'};
    my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pGATKVariantRecalibration'}{'fileEnding'};

    unless (-e $scriptParameter{'outDataDir'}."/".$familyID."/".$familyID.".fam") { #Check to see if file already exists
	print GATK_VARREC "#Generating '.fam' file for GATK VariantRecalibrator/ApplyRecalibration","\n\n";
	print GATK_VARREC q?perl -nae 'my %sample_info;my $mother;my $father; while (<>) { my @F = split(/\t/,$_); if ($_!~/^#/) { if($F[0]=~/(\d+)-(\d+|-\d+)-(\d+)(A|U)/) {} if ($F[3] == 1) {$father = $F[0];} if ($F[2] == 1) {$mother = $F[0];} if($3 % 2 == 1) {push (@{ $sample_info{$1}{$F[0]} }, "1");} else {push (@{ $sample_info{$1}{$F[0]} }, "2");} if ($4 eq "A") {push (@{ $sample_info{$1}{$F[0]} }, "2");} else {push (@{ $sample_info{$1}{$F[0]} }, "1");} } } for my $familyid (keys %sample_info) { for my $sampleid (keys %{ $sample_info{$familyid} }) {print $familyid, " ", $sampleid, " ", $father, " ", $mother," "; for (my $i=0;$i<scalar(@{ $sample_info{$familyid}{$sampleid} });$i++) {print $sample_info{$familyid}{$sampleid}[$i], " ";}print "\n"; } } last;' ?.$scriptParameter{'pedigreeFile'}." > ".$outFamilyFileDirectory."/".$familyID.".fam", "\n\n";
    }

    if ($callType eq "BOTH") {#Requires that the input sample has been produced with HaplotypeCaller   
	
	my $inFamilyDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK";
	
	if ($scriptParameter{'wholeGenomeSequencing'} == 0) { #Exome analysis 
	    
	    my $outFamilyDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK";
	    my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pGATKHaploTypeCaller'}{'fileEnding'};
###
#GATK CombineVariants
###
#Needed to include reference exomes to power the building of the probabalistic model. Variants unique to these exomes will be filtered out after varrecal and applyrecal.
	    print GATK_VARREC "\n#GATK CombineVariants","\n\n";
	    print GATK_VARREC "java -Xmx4g ";
	    print GATK_VARREC "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
	    print GATK_VARREC "-l INFO "; #Set the minimum level of logging
	    print GATK_VARREC "-T CombineVariants "; #Type of analysis to run
	    print GATK_VARREC "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file
	    print GATK_VARREC "-V: ".$inFamilyDirectory."/".$familyID.$infileEnding.$callType.".vcf "; #InFile (family vcf)
	    print GATK_VARREC "-V: ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKExomeReferenceSNPs'}." "; #Infile (exome reference)
	    print GATK_VARREC "-o ".$outFamilyDirectory."/".$familyID.$outfileEnding.$callType."_comb_ref.vcf"; #OutFile
	    
	}

	my $outFamilyDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK/intermediary";

	print GATK_VARREC "\n\n#GATK VariantRecalibrator","\n\n";	
	print GATK_VARREC "java -Xmx12g ";
	print GATK_VARREC "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
	print GATK_VARREC "-l INFO "; #Set the minimum level of logging
	print GATK_VARREC "-T VariantRecalibrator "; #Type of analysis to run
	print GATK_VARREC "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file
	
	if ($scriptParameter{'wholeGenomeSequencing'} == 0) { #Exome analysis use comined reference for more power

	    my %GATKTargetPaddedBedIntervalListTracker;

	    print GATK_VARREC "-recalFile ".$outFamilyDirectory."/".$familyID.$outfileEnding.$callType."_comb_ref.intervals "; #Recalibration outFile
	    print GATK_VARREC "-rscriptFile ".$outFamilyDirectory."/".$familyID.$outfileEnding.$callType."_comb_ref.intervals.plots.R "; #The output rscript file generated by the VQSR to aid in visualization of the input data and learned model
	    print GATK_VARREC "-tranchesFile ".$outFamilyDirectory."/".$familyID.$outfileEnding.$callType."_comb_ref.intervals.tranches "; #The output tranches file used by ApplyRecalibration
	    print GATK_VARREC "-input ".$inFamilyDirectory."/".$familyID.$infileEnding.$callType."_comb_ref.vcf "; #Infile just created combined vcf

	    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) { #Collect infiles for all sampleIDs
		
		my $GATKTargetPaddedBedIntervalList = $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'GATKTargetPaddedBedIntervalList'};
		if ($identicalCaptureBedIntervalCounter eq scalar(@sampleIDs)) {
		    print GATK_VARREC "-L ".$scriptParameter{'referencesDir'}."/".$GATKTargetPaddedBedIntervalList." "; #One or more genomic intervals over which to operate
		    last; #All identical print once
		}
		else {
		    
		    $GATKTargetPaddedBedIntervalListTracker{$GATKTargetPaddedBedIntervalList}++;
		    if ($GATKTargetPaddedBedIntervalListTracker{$GATKTargetPaddedBedIntervalList} == 1) { #Not printed previously
			print GATK_VARREC "-L ".$scriptParameter{'referencesDir'}."/".$GATKTargetPaddedBedIntervalList." "; #One or more genomic intervals over which to operate
		    }
		}
	    }
	}
	else { #WGS
	    print GATK_VARREC "-recalFile ".$outFamilyDirectory."/".$familyID.$outfileEnding.$callType.".intervals ";
	    print GATK_VARREC "-rscriptFile ".$outFamilyDirectory."/".$familyID.$outfileEnding.$callType.".intervals.plots.R ";
	    print GATK_VARREC "-tranchesFile ".$outFamilyDirectory."/".$familyID.$outfileEnding.$callType.".intervals.tranches ";
	    print GATK_VARREC "-input ".$inFamilyDirectory."/".$familyID.$infileEnding.$callType.".vcf ";	  
	}
	print GATK_VARREC "-resource:hapmap,VCF,known=false,training=true,truth=true,prior=15.0 ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKVariantReCalibrationTrainingSetHapMap'}." "; #A list of sites for which to apply a prior probability of being correct but which aren't used by the algorithm
	print GATK_VARREC "-resource:omni,VCF,known=false,training=true,truth=false,prior=12.0 ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKVariantReCalibrationTrainingSet1000GOmni'}." "; #A list of sites for which to apply a prior probability of being correct but which aren't used by the algorithm
	print GATK_VARREC "-resource:dbsnp,VCF,known=true,training=false,truth=false,prior=8.0 ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKVariantReCalibrationTrainingSetDbSNP'}." "; #A list of sites for which to apply a prior probability of being correct but which aren't used by the algorithm
	print GATK_VARREC "-resource:mills,VCF,known=true,training=true,truth=true,prior=12.0 ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKVariantReCalibrationTrainingSetMills'}." "; #A list of sites for which to apply a prior probability of being correct but which aren't used by the algorithm
	print GATK_VARREC "-an QD "; #The names of the annotations which should used for calculations
	print GATK_VARREC "-an HaplotypeScore "; #The names of the annotations which should used for calculations
	print GATK_VARREC "-an MQRankSum "; #The names of the annotations which should used for calculations
	print GATK_VARREC "-an ReadPosRankSum "; #The names of the annotations which should used for calculations
	print GATK_VARREC "-an FS "; #The names of the annotations which should used for calculations
	print GATK_VARREC "-an MQ "; #The names of the annotations which should used for calculations
	print GATK_VARREC "--mode ".$callType." "; #Recalibration mode to employ (SNP|INDEL|BOTH)
	print GATK_VARREC "-nt ".$scriptParameter{'maximumCores'}." "; #How many data threads should be allocated to running this analysis    
	if (scalar(@sampleIDs) > 2) {
	    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) { #For all sampleIDs
		if ( $sampleIDs[$sampleIDCounter] =~ /(\d+)-(\d+|-\d+)-(\d+)(A|U)/) {#Match sampleID
		    if ($2 eq 2) { #Parent
			print GATK_VARREC "--pedigree SILENT --pedigree ".$outFamilyFileDirectory."/".$familyID.".fam "; #Pedigree files for samples		
			last; #Only print once if a parent is found (required to include pedigree)
		    }
		}
	    }	
	}
    }

#GATK ApplyRecalibration
    print GATK_VARREC "\n\n#GATK ApplyRecalibration","\n\n";

    my $inFamilyDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK/intermediary";
    my $outFamilyDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK";

    if ($callType eq "BOTH") {
	 
	print GATK_VARREC "java -Xmx2g ";
	print GATK_VARREC  "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
	print GATK_VARREC "-l INFO "; #Set the minimum level of logging
	print GATK_VARREC "-T ApplyRecalibration ";
	print GATK_VARREC "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file
	if ($scriptParameter{'wholeGenomeSequencing'} == 0) { #Exome analysis use comined reference for more power

	    my %GATKTargetPaddedBedIntervalListTracker;

	    print GATK_VARREC "-recalFile ".$inFamilyDirectory."/".$familyID.$infileEnding.$callType."_comb_ref.intervals "; #Recalibration outFile
	    print GATK_VARREC "-tranchesFile ".$inFamilyDirectory."/".$familyID.$infileEnding.$callType."_comb_ref.intervals.tranches "; #The output tranches file used by ApplyRecalibration
	    print GATK_VARREC "-input ".$inFamilyDirectory."/".$familyID.$infileEnding.$callType."_comb_ref.vcf ";
	    print GATK_VARREC "-o ".$outFamilyDirectory."/".$familyID.$outfileEnding.$callType."_comb_ref_filtered.vcf ";
	    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) { #Collect infiles for all sampleIDs
		
		my $GATKTargetPaddedBedIntervalList = $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'GATKTargetPaddedBedIntervalList'};
		if ($identicalCaptureBedIntervalCounter eq scalar(@sampleIDs)) {
		    print GATK_VARREC "-L ".$scriptParameter{'referencesDir'}."/".$GATKTargetPaddedBedIntervalList." "; #One or more genomic intervals over which to operate
		    last; #All identical print once
		}
		else {
		    
		    $GATKTargetPaddedBedIntervalListTracker{$GATKTargetPaddedBedIntervalList}++;
		    if ($GATKTargetPaddedBedIntervalListTracker{$GATKTargetPaddedBedIntervalList} == 1) { #Not printed previously
			print GATK_VARREC "-L ".$scriptParameter{'referencesDir'}."/".$GATKTargetPaddedBedIntervalList." "; #One or more genomic intervals over which to operate
		    }
		}
	    }
	}
	else  { #WGS
	    print GATK_VARREC "-recalFile ".$inFamilyDirectory."/".$familyID.$infileEnding.$callType.".intervals ";
	    print GATK_VARREC "-tranchesFile ".$inFamilyDirectory."/".$familyID.$infileEnding.$callType.".intervals.tranches ";
	    print GATK_VARREC "-input ".$inFamilyDirectory."/".$familyID.$infileEnding.$callType.".vcf ";
	    print GATK_VARREC "-o ".$outFamilyDirectory."/".$familyID.$outfileEnding.$callType.".vcf ";
	}
	print GATK_VARREC "--ts_filter_level ".$scriptParameter{'GATKVariantReCalibrationTSFilterLevel'}." ";
	if (scalar(@sampleIDs) > 2) {
	    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) { #For all sampleIDs
		if ($sampleIDs[$sampleIDCounter] =~ /(\d+)-(\d+|-\d+)-(\d+)(A|U)/) {#Match sampleID
		    if ($2 eq 2) { #Parent
			print GATK_VARREC "--pedigree SILENT --pedigree ".$outFamilyFileDirectory."/".$familyID.".fam "; #Pedigree files for samples		
			last; #Only print once if a parent is found (required to include pedigree)
		    }
		}
	    }	
	}	  
	my $inFamilyDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK";
	my $outFamilyDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK";
###
#GATK SelectVariants
###
#Removes all genotype information for exome ref and recalulates meta-data info for remaining samples in new file.
	if ($scriptParameter{'wholeGenomeSequencing'} == 0) { #Exome analysis
	
	    print GATK_VARREC "\n\n#GATK SelectVariants","\n\n";
	    print GATK_VARREC "java -Xmx2g ";
	    print GATK_VARREC  "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
	    print GATK_VARREC "-l INFO "; #Set the minimum level of logging
	    print GATK_VARREC "-T SelectVariants "; #Type of analysis to run
	    print GATK_VARREC "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file
	    print GATK_VARREC "-V: ".$inFamilyDirectory."/".$familyID.$infileEnding.$callType."_comb_ref_filtered.vcf "; #InFile
	    print GATK_VARREC "-o ".$outFamilyDirectory."/".$familyID.$outfileEnding.$callType.".vcf "; #OutFile
	    
	    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) { #For all sampleIDs
		
		print GATK_VARREC "-sn ".$sampleIDs[$sampleIDCounter]." "; #Include genotypes from this sample
	    }
	}
	
    }

    print GATK_VARREC "\n\nwait", "\n\n";
    close(GATK_VARREC);   
    if ($scriptParameter{'pGATKVariantRecalibration'} == 1) {
	FIDSubmitJob(0,$familyID, 1, $callType, $filename,0);
    }
    return;
}

sub GATKHaplotypeCallerCombineVariants { 
#GATK CombineVariants. Since HaplotypeCaller is presently used per chromosomes ot batches of chromosomes this module will combine the vcf to 1 file. 

    my $familyID = $_[0]; #familyID NOTE: not sampleid
    my $aligner = $_[1];
    my $callType = $_[2]; #SNV,INDEL or BOTH
    
    `mkdir -p $scriptParameter{'outDataDir'}/$familyID/$aligner/info;`; #Creates the aligner folder and info data file directory
    `mkdir -p $scriptParameter{'outDataDir'}/$familyID/$aligner/GATK`; #Creates the aligner folder, GATK data file directory
    `mkdir -p $scriptParameter{'outScriptDir'}/$familyID/$aligner`; #Creates the aligner folder script file directory

    if ($scriptParameter{'pGATKHaploTypeCaller'} == 1) {
	$filename = $scriptParameter{'outScriptDir'}."/".$familyID."/".$aligner."/gatk_haploTypeCallerCombineVariants_".$familyID."_".$callType.".";   
    }
    elsif ($scriptParameter{'pGATKHaploTypeCaller'} == 2) { #Dry run
	$filename = $scriptParameter{'outScriptDir'}."/".$familyID."/".$aligner."/dry_run_gatk_haploTypeCallerCombineVariants_".$familyID."_".$callType.".";   
	print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";
    }
    Checkfnexists($filename, $fnend);

###Info and Logg
    print STDOUT "Creating sbatch script GATK HaplotypeCaller Combine Variants and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script GATK HaplotypeCaller Combine Variants and writing script file(s) to: ".$filename, "\n";
    print STDOUT "Sbatch script GATK HaplotypeCaller Combine Variants data files will be written to: ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK", "\n";print MASTERL "Sbatch script GATK HaplotypeCaller Combine Variants data files will be written to: ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK", "\n";

    open (GATK_HAPCALCOMVAR, ">".$filename) or die "Can't write to ".$filename.": $!\n";
    
    print GATK_HAPCALCOMVAR "#! /bin/bash -l", "\n";
    print GATK_HAPCALCOMVAR "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
    print GATK_HAPCALCOMVAR "#SBATCH -p node -n 1", "\n";
    print GATK_HAPCALCOMVAR "#SBATCH -C thin", "\n";	
    print GATK_HAPCALCOMVAR "#SBATCH -t 1:00:00", "\n";
    print GATK_HAPCALCOMVAR "#SBATCH -J GATK_HapCComVar_".$familyID."_".$callType, "\n";

    if ($scriptParameter{'pGATKHaploTypeCaller'} == 1) {
	print GATK_HAPCALCOMVAR "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/gatk_haplotypecallercombinevariants_".$callType."_".$familyID.".".$fnt.".stderr.txt", "\n";
	print GATK_HAPCALCOMVAR "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/gatk_haplotypecallercombinevariants_".$callType."_".$familyID.".".$fnt.".stdout.txt", "\n";
    }
    elsif ($scriptParameter{'pGATKHaploTypeCaller'} == 2) { #Dry run
	print GATK_HAPCALCOMVAR "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/dry_run_gatk_haplotypecallercombinevariants_".$callType."_".$familyID.".".$fnt.".stderr.txt", "\n";
	print GATK_HAPCALCOMVAR "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/dry_run_gatk_haplotypecallercombinevariants_".$callType."_".$familyID.".".$fnt.".stdout.txt", "\n";
    }    

    unless ($scriptParameter{'email'} eq 0) {
	print GATK_HAPCALCOMVAR "#SBATCH --mail-type=END", "\n";
	print GATK_HAPCALCOMVAR "#SBATCH --mail-type=FAIL", "\n";
	print GATK_HAPCALCOMVAR "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
    }
    
    print GATK_HAPCALCOMVAR 'echo "Running on: $(hostname)"',"\n\n";
 
    my $inFamilyDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK/HaploTypeCaller";
    my $outFamilyDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK";
    my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pGATKHaploTypeCaller'}{'fileEnding'};
    my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pGATKHaploTypeCaller'}{'fileEnding'};
    
    print GATK_HAPCALCOMVAR "#GATK CombineVariants","\n\n";
    	   
    print GATK_HAPCALCOMVAR "java -Xmx2g ";
    print GATK_HAPCALCOMVAR "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
    print GATK_HAPCALCOMVAR "-l INFO "; #Set the minimum level of logging
    print GATK_HAPCALCOMVAR "-T CombineVariants "; #Type of analysis to run
    print GATK_HAPCALCOMVAR "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file

    for (my $chromosomeCounter=0;$chromosomeCounter<scalar(@chromosomes);$chromosomeCounter++) { #For all chromosome	    
	print GATK_HAPCALCOMVAR "-V ".$inFamilyDirectory."/".$familyID.$infileEnding.$chromosomes[$chromosomeCounter]."_".$callType.".vcf "; #InFiles  
    }
    print GATK_HAPCALCOMVAR "-o ".$outFamilyDirectory."/".$familyID.$outfileEnding.$callType.".vcf", "\n\n"; #OutFile

    print GATK_HAPCALCOMVAR "wait", "\n\n";
    close(GATK_HAPCALCOMVAR);   
    if ($scriptParameter{'pGATKHaploTypeCaller'} == 1) {
	FIDSubmitJob(0,$familyID, 1, "MAIN",$filename,0);    
    }
    return;
}

sub GATKHaploTypeCaller { 
#GATK HaplotypeCaller
    
    my $familyID = $_[0]; #familyID NOTE: not sampleid
    my $aligner = $_[1];
    my $callType = $_[2]; #SNV,INDEL or BOTH
    my $chrStartPosition = $_[3]; 
    my $chrStopPosition = $_[4];
    my $javaHeapAllocation = $_[5];
    
    `mkdir -p $scriptParameter{'outDataDir'}/$familyID/$aligner/info;`; #Creates the aligner folder and info data file directory
    `mkdir -p $scriptParameter{'outDataDir'}/$familyID/$aligner/GATK/HaploTypeCaller`; #Creates the aligner folder, GATK data file directory
    `mkdir -p $scriptParameter{'outScriptDir'}/$familyID/$aligner`; #Creates the aligner folder script file directory
    
    my $tempChromosomeStartPosition = $chrStartPosition+1;
    my $tempChromosomeStopPosition = $chrStopPosition;
    
    if ($chrStopPosition == 26) {
	$tempChromosomeStopPosition = $chrStopPosition-1;
    } 
    
    if ($scriptParameter{'pGATKHaploTypeCaller'} == 1) {
	$filename = $scriptParameter{'outScriptDir'}."/".$familyID."/".$aligner."/gatk_haplotypecaller_".$familyID."_".$callType."_chr".$tempChromosomeStartPosition."-".$tempChromosomeStopPosition."."; 
    }
    elsif ($scriptParameter{'pGATKHaploTypeCaller'} == 2) { #Dry run
	$filename = $scriptParameter{'outScriptDir'}."/".$familyID."/".$aligner."/dry_run_gatk_haplotypecaller_".$familyID."_".$callType."_chr".$tempChromosomeStartPosition."-".$tempChromosomeStopPosition."."; 
	print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n"; 
    }
    Checkfnexists($filename, $fnend);
    
###Info and Logg
    print STDOUT "Creating sbatch script GATK HaplotypeCaller and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script GATK HaplotypeCaller and writing script file(s) to: ".$filename, "\n";
    print STDOUT "Sbatch script GATK HaplotypeCaller data files will be written to: ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK/HaplotypeCaller", "\n";print MASTERL "Sbatch script GATK HaplotypeCaller data files will be written to: ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK/HaploTypeCaller", "\n";
    
    open (GATK_HAPCAL, ">".$filename) or die "Can't write to ".$filename.": $!\n";
    
    print GATK_HAPCAL "#! /bin/bash -l", "\n";
    print GATK_HAPCAL "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
    print GATK_HAPCAL "#SBATCH -p node -n ".$scriptParameter{'maximumCores'}, "\n";
    print GATK_HAPCAL "#SBATCH -C thin", "\n";	
    print GATK_HAPCAL "#SBATCH -t 50:00:00", "\n";
    
    print GATK_HAPCAL "#SBATCH -J GATK_HAPCALL_".$familyID."_".$callType."_chr".$tempChromosomeStartPosition."-".$chrStopPosition, "\n";
    
    if ($scriptParameter{'pGATKHaploTypeCaller'} == 1) {
	print GATK_HAPCAL "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/gatk_haplotypecaller_".$familyID."_".$callType."_chr".$tempChromosomeStartPosition."-".$tempChromosomeStopPosition.".".$fnt.".stderr.txt", "\n";
	print GATK_HAPCAL "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/gatk_haplotypecaller_".$familyID."_".$callType."_chr".$tempChromosomeStartPosition."-".$tempChromosomeStopPosition.".".$fnt.".stdout.txt", "\n";
    }
    elsif ($scriptParameter{'pGATKHaploTypeCaller'} == 2) { #Dry run
	print GATK_HAPCAL "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/dry_run_gatk_haplotypecaller_".$familyID."_".$callType."_chr".$tempChromosomeStartPosition."-".$tempChromosomeStopPosition.".".$fnt.".stderr.txt", "\n";
	print GATK_HAPCAL "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/info/dry_run_gatk_haplotypecaller_".$familyID."_".$callType."_chr".$tempChromosomeStartPosition."-".$tempChromosomeStopPosition.".".$fnt.".stdout.txt", "\n";
    }
    
    unless ($scriptParameter{'email'} eq 0) {
	print GATK_HAPCAL "#SBATCH --mail-type=END", "\n";
	print GATK_HAPCAL "#SBATCH --mail-type=FAIL", "\n";
	print GATK_HAPCAL "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
    }
    
    print GATK_HAPCAL 'echo "Running on: $(hostname)"',"\n\n";
    
    my $outFamilyFileDirectory = $scriptParameter{'outDataDir'}."/".$familyID;
    my $outFamilyDirectory = $scriptParameter{'outDataDir'}."/".$familyID."/".$aligner."/GATK/HaploTypeCaller";
    my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pGATKHaploTypeCaller'}{'fileEnding'};
    
    if ($chrStartPosition == 0) { #Only for the first call of subroutine GATK_hapcal.
	
#Generate .fam file for later use in relevant GATK walkers (HaploTypeCaller, VariantscoreRequalibration etc)
	print GATK_HAPCAL "#Generating '.fam' file for GATK HaploTypeCaller","\n\n";
	
	print GATK_HAPCAL q?perl -nae 'my %sample_info;my $mother;my $father; while (<>) { my @F = split(/\t/,$_); if ($_!~/^#/) { if($F[0]=~/(\d+)-(\d+|-\d+)-(\d+)(A|U)/) {} if ($F[3] == 1) {$father = $F[0];} if ($F[2] == 1) {$mother = $F[0];} if($3 % 2 == 1) {push (@{ $sample_info{$1}{$F[0]} }, "1");} else {push (@{ $sample_info{$1}{$F[0]} }, "2");} if ($4 eq "A") {push (@{ $sample_info{$1}{$F[0]} }, "2");} else {push (@{ $sample_info{$1}{$F[0]} }, "1");} } } for my $familyid (keys %sample_info) { for my $sampleid (keys %{ $sample_info{$familyid} }) {print $familyid, " ", $sampleid, " ", $father, " ", $mother," "; for (my $i=0;$i<scalar(@{ $sample_info{$familyid}{$sampleid} });$i++) {print $sample_info{$familyid}{$sampleid}[$i], " ";}print "\n"; } } last;' ?.$scriptParameter{'pedigreeFile'}." > ".$outFamilyFileDirectory."/".$familyID.".fam", "\n\n";
    }
    
    print GATK_HAPCAL "#GATK HaplotypeCaller","\n\n";
    
    if ($chrStopPosition == 26) { #Special case to enable processing of MT as well within same node for last call, overstrecthing a bit but should be fine
	for (my $chromosomeCounter=$chrStartPosition;$chromosomeCounter<$chrStopPosition-1;$chromosomeCounter++) { #Determined by chr start and stop arguments given as input	   
	    
	    print GATK_HAPCAL "java -Xmx".$javaHeapAllocation."g ";
	    print GATK_HAPCAL "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
	    print GATK_HAPCAL "-l INFO "; #Set the minimum level of logging
	    print GATK_HAPCAL "-T HaplotypeCaller "; #Type of analysis to run
	    print GATK_HAPCAL "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file
	    print GATK_HAPCAL "-D ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKHaploTypeCallerSNPKnownSet'}." "; #Known SNPs to use for annotation SNPs
	    print GATK_HAPCAL "-stand_call_conf 30.0 "; #The minimum phred-scaled confidence threshold at which variants should be called
	    print GATK_HAPCAL "-stand_emit_conf 30.0 "; #The minimum phred-scaled confidence threshold at which variants should be emitted
	    print GATK_HAPCAL "--annotation BaseQualityRankSumTest "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation ChromosomeCounts "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation Coverage "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation FisherStrand "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation HaplotypeScore "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation InbreedingCoeff "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation MappingQualityRankSumTest "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation MappingQualityZero "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation QualByDepth "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation RMSMappingQuality "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation ReadPosRankSumTest "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation SpanningDeletions "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation TandemRepeatAnnotator " ;#annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation DepthPerAlleleBySample "; #annotations to apply to variant calls
	    if (scalar(@sampleIDs) > 2) {
		for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) { #For all sampleIDs
		    if ($sampleIDs[$sampleIDCounter] =~ /(\d+)-(\d+|-\d+)-(\d+)(A|U)/) {#Match sampleID
			if ($2 eq 2) { #Parent
			    print GATK_HAPCAL "--pedigree ".$outFamilyFileDirectory."/".$familyID.".fam "; #Pedigree files for samples		
			    last; #Only print once if a parent is found (required to include pedigree)
			}
		    }
		}		
	    }
	    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) { #Collect infiles for all sampleIDs
		
		my $inSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleIDs[$sampleIDCounter]."/".$aligner."/per_chr/GATK";
		my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pGATKBaseRecalibration'}{'fileEnding'};
		my ($infile, $PicardToolsMergeSwitch) = CheckIfMergedFiles($sampleIDs[$sampleIDCounter]);
		
		if ($PicardToolsMergeSwitch == 1) { #Alignment BAM-files merged previously
		    
		    print GATK_HAPCAL "-I ".$inSampleDirectory."/".$infile.$infileEnding.$chromosomes[$chromosomeCounter].".bam "; #InFile
		}
		else { #No previous merge of alignment BAM-files
		    
		    for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{ $sampleIDs[$sampleIDCounter] } });$infileCounter++) { #For all infiles per lane
			my $infile = $infilesLaneNoEnding{ $sampleIDs[$sampleIDCounter] }[$infileCounter];
			
			print GATK_HAPCAL "-I ".$inSampleDirectory."/".$infile.$infileEnding.$chromosomes[$chromosomeCounter].".bam "; #InFile(s)
		    } 
		}
	    }
	    if ($scriptParameter{'wholeGenomeSequencing'} == 0) { #Exome analysis - Restrict analysis to padded target file
		
		my %GATKTargetPaddedBedIntervalListTracker; 
		
		for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) { #Collect infiles for all sampleIDs
		    
		    my $GATKTargetPaddedBedIntervalList = $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'GATKTargetPaddedBedIntervalList'};
		    if ($identicalCaptureBedIntervalCounter eq scalar(@sampleIDs)) {
			print GATK_HAPCAL "-L ".$scriptParameter{'referencesDir'}."/".$GATKTargetPaddedBedIntervalList." "; #One or more genomic intervals over which to operate
			last; #All identical print once
		    }
		    else {

			$GATKTargetPaddedBedIntervalListTracker{$GATKTargetPaddedBedIntervalList}++;
			if ($GATKTargetPaddedBedIntervalListTracker{$GATKTargetPaddedBedIntervalList} == 1) { #Not printed previously
			    print GATK_HAPCAL "-L ".$scriptParameter{'referencesDir'}."/".$GATKTargetPaddedBedIntervalList." "; #One or more genomic intervals over which to operate
			}
		    }
		}		
	    } 
	    print GATK_HAPCAL "-o ".$outFamilyDirectory."/".$familyID.$outfileEnding.$chromosomes[$chromosomeCounter]."_".$callType.".vcf &", "\n\n"; #OutFile
	}
    }
    else {
	for (my $chromosomeCounter=$chrStartPosition;$chromosomeCounter<$chrStopPosition;$chromosomeCounter++) { #Determined by chromosome start and stop arguments given as input to subroutine
	    print GATK_HAPCAL "java -Xmx".$javaHeapAllocation."g ";
	    print GATK_HAPCAL "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
	    print GATK_HAPCAL "-l INFO "; #Set the minimum level of logging
	    print GATK_HAPCAL "-T HaplotypeCaller "; #Type of analysis to run
	    print GATK_HAPCAL "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file
	    print GATK_HAPCAL "-D ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKHaploTypeCallerSNPKnownSet'}." "; #Known SNPs to use for annotation SNPs
	    print GATK_HAPCAL "-stand_call_conf 30.0 "; #The minimum phred-scaled confidence threshold at which variants should be called
	    print GATK_HAPCAL "-stand_emit_conf 30.0 "; #The minimum phred-scaled confidence threshold at which variants should be emitted
	    print GATK_HAPCAL "--annotation BaseQualityRankSumTest "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation ChromosomeCounts "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation Coverage "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation FisherStrand "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation HaplotypeScore "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation InbreedingCoeff "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation MappingQualityRankSumTest "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation MappingQualityZero "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation QualByDepth "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation RMSMappingQuality "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation ReadPosRankSumTest "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation SpanningDeletions "; #annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation TandemRepeatAnnotator " ;#annotations to apply to variant calls
	    print GATK_HAPCAL "--annotation DepthPerAlleleBySample "; #annotations to apply to variant calls
	    if (scalar(@sampleIDs) > 2) {
		for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) { #For all sampleIDs
		    if ($sampleIDs[$sampleIDCounter] =~ /(\d+)-(\d+|-\d+)-(\d+)(A|U)/) {#Match sampleID
			if ($2 eq 2) { #Parent
			    print GATK_HAPCAL "--pedigree ".$outFamilyFileDirectory."/".$familyID.".fam "; #Pedigree files for samples		
			    last; #Only print once if a parent is found (required to include pedigree)
			}
		    }
		}		
	    }
	    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) { #Collect infiles for all sampleIDs
		
		my $inSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleIDs[$sampleIDCounter]."/".$aligner."/per_chr/GATK";
		my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pGATKBaseRecalibration'}{'fileEnding'};
		my ($infile, $PicardToolsMergeSwitch) = CheckIfMergedFiles($sampleIDs[$sampleIDCounter]);
		
		if ($PicardToolsMergeSwitch == 1) { #Alignment BAM-files merged previously
		    
		    print GATK_HAPCAL "-I ".$inSampleDirectory."/".$infile.$infileEnding.$chromosomes[$chromosomeCounter].".bam "; #InFile
		}
		else { #No previous merge of alignment BAM-files
		    
		    for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{ $sampleIDs[$sampleIDCounter] } });$infileCounter++) { #For all infiles per lane
			my $infile = $infilesLaneNoEnding{ $sampleIDs[$sampleIDCounter] }[$infileCounter];
			
			print GATK_HAPCAL "-I ".$inSampleDirectory."/".$infile.$infileEnding.$chromosomes[$chromosomeCounter].".bam "; #InFile(s)
		    } 
		}
	    }
	    if ($scriptParameter{'wholeGenomeSequencing'} == 0) { #Exome analysis - Restrict analysis to padded target file
		
		my %GATKTargetPaddedBedIntervalListTracker; #
		
		for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) { #Collect infiles for all sampleIDs
		    
		    my $GATKTargetPaddedBedIntervalList = $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'GATKTargetPaddedBedIntervalList'};
		    if ($identicalCaptureBedIntervalCounter eq scalar(@sampleIDs)) {
	
			print GATK_HAPCAL "-L ".$scriptParameter{'referencesDir'}."/".$GATKTargetPaddedBedIntervalList." "; #One or more genomic intervals over which to operate
			last; #All identical print once
		    }
		    else {
			
			$GATKTargetPaddedBedIntervalListTracker{$GATKTargetPaddedBedIntervalList}++;
			if ($GATKTargetPaddedBedIntervalListTracker{$GATKTargetPaddedBedIntervalList} == 1) { #Not printed previously
			    print GATK_HAPCAL "-L ".$scriptParameter{'referencesDir'}."/".$GATKTargetPaddedBedIntervalList." "; #One or more genomic intervals over which to operate
			}
		    }
		}		
	    }  
	    print GATK_HAPCAL "-o ".$outFamilyDirectory."/".$familyID.$outfileEnding.$chromosomes[$chromosomeCounter]."_".$callType.".vcf &", "\n\n"; #OutFile
	}   	
    }
    print GATK_HAPCAL "\n\nwait", "\n\n";    
    
    close(GATK_HAPCAL);  
    if ($scriptParameter{'pGATKHaploTypeCaller'} == 1) {
	FIDSubmitJob(0,$familyID, 3, "MAIN",$filename,0); #Arg2 eq 3 for parallel execution  
    }
    return;
}

sub GATKBaseReCalibration { 
#GATK BaseRecalibrator/PrintReads to recalibrate bases before variant calling. Both BaseRecalibrator/PrintReads will be executed within the same sbatch script

    my $sampleID = $_[0];
    my $aligner = $_[1];

    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/$aligner/info;`; #Creates the aligner folder and info data file directory
    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/$aligner/per_chr/GATK/intermediary`; #Creates the aligner folder, per chromosome and GATK intermediary data file directory
    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/$aligner/GATK/`; #Creates the aligner folder, GATK all chr data file directory
    `mkdir -p $scriptParameter{'outScriptDir'}/$sampleID/$aligner;`; #Creates the aligner folder script file directory

    if ($scriptParameter{'pGATKBaseRecalibration'} == 1) {
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/".$aligner."/gatk_baserecalibration_".$sampleID.".";   
    }
    elsif ($scriptParameter{'pGATKBaseRecalibration'} == 2) { #Dry run
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/".$aligner."/dry_run_gatk_baserecalibration_".$sampleID."."; 
	print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";  
    }
    Checkfnexists($filename, $fnend);

###Info and Logg
    print STDOUT "Creating sbatch script GATK BaseRecalibrator/PrintReads and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script GATK BaseRecalibrator/PrintReads and writing script file(s) to: ".$filename, "\n";
    print STDOUT "Sbatch script GATK BaseRecalibrator/PrintReads data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/per_chr/GATK", "\n";print MASTERL "Sbatch script GATK BaseRecalibrator/PrintReads data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/per_chr/GATK", "\n";

    open (GATK_RECAL, ">".$filename) or die "Can't write to ".$filename.": $!\n";
    
    print GATK_RECAL "#! /bin/bash -l", "\n";
    print GATK_RECAL "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
    print GATK_RECAL "#SBATCH -p node -n ".$scriptParameter{'maximumCores'}, "\n";
    print GATK_RECAL "#SBATCH -C thin", "\n";	
    print GATK_RECAL "#SBATCH -t 60:00:00", "\n";
    print GATK_RECAL "#SBATCH -J GATK_RECAL_".$sampleID."_".$aligner, "\n";
    if ($scriptParameter{'pGATKBaseRecalibration'} == 1) {
	print GATK_RECAL "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/gatk_baserecalibration_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print GATK_RECAL "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/gatk_baserecalibration_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }
    if ($scriptParameter{'pGATKBaseRecalibration'} == 2) { #Dry run
	print GATK_RECAL "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/dry_run_gatk_baserecalibration_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print GATK_RECAL "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/dry_run_gatk_baserecalibration_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }
    
    unless ($scriptParameter{'email'} eq 0) {
	print GATK_RECAL "#SBATCH --mail-type=END", "\n";
	print GATK_RECAL "#SBATCH --mail-type=FAIL", "\n";
	print GATK_RECAL "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
    }
    
    print GATK_RECAL 'echo "Running on: $(hostname)"',"\n\n";
    
    my $inSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/per_chr/GATK";
    my $intervalSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/per_chr/GATK/intermediary";
    my $outSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/per_chr/GATK";
    my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pGATKRealigner'}{'fileEnding'};
    my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pGATKBaseRecalibration'}{'fileEnding'};
    my ($infile, $PicardToolsMergeSwitch) = CheckIfMergedFiles($sampleID);
    my $coreCounter=1;
    
    print GATK_RECAL "#GATK BaseRecalibrator","\n\n";
    
    if ($PicardToolsMergeSwitch == 1) { #Files was merged previously
	
	for (my $chromosomeCounter=0;$chromosomeCounter<scalar(@chromosomes);$chromosomeCounter++) { #For all chromosomes	    
	    
	    if ($chromosomeCounter eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} 
		
		print GATK_RECAL "wait", "\n\n";
		$coreCounter=$coreCounter+1;
	    }
	    print GATK_RECAL "java -Xmx3g ";
	    print GATK_RECAL "-Djava.io.tmpdir=".$scriptParameter{'GATKTempDirectory'}."/".$chromosomes[$chromosomeCounter]."/ "; #Temporary Directory per chr
	    print GATK_RECAL "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
	    print GATK_RECAL "-l INFO "; #Set the minimum level of logging
	    print GATK_RECAL "-T BaseRecalibrator "; #Type of analysis to run
	    print GATK_RECAL "-cov ReadGroupCovariate "; #Covariates to be used in the recalibration
	    print GATK_RECAL "-cov ContextCovariate "; #Covariates to be used in the recalibration
	    print GATK_RECAL "-cov CycleCovariate "; #Covariates to be used in the recalibration
	    print GATK_RECAL "-cov QualityScoreCovariate "; #Covariates to be used in the recalibration
	    print GATK_RECAL "-cov ReadGroupCovariate "; #Covariates to be used in the recalibration
	    print GATK_RECAL "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file
	    print GATK_RECAL "-knownSites ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKBaseReCalibrationSNPKnownSet'}." ";
	    print GATK_RECAL "-I ".$inSampleDirectory."/".$infile.$infileEnding.$chromosomes[$chromosomeCounter].".bam "; #InFile
	    print GATK_RECAL "-o ".$intervalSampleDirectory."/".$infile.$infileEnding.$chromosomes[$chromosomeCounter].".grp &", "\n\n"; #Recalibration table file
	}
	
	print GATK_RECAL "wait", "\n\n";
	
	$coreCounter=1; #Resetting
	
	print GATK_RECAL "#GATK PrintReads","\n\n";
	
	for (my $chromosomeCounter=0;$chromosomeCounter<scalar(@chromosomes);$chromosomeCounter++) { #For all chromosomes	    
	    
	    if ($chromosomeCounter eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} cores
		
		print GATK_RECAL "wait", "\n\n";
		$coreCounter=$coreCounter+1;
	    }
	    
	    print GATK_RECAL "java -Xmx3g ";
	    print GATK_RECAL "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
	    print GATK_RECAL "-l INFO "; #Set the minimum level of logging"-jar $gatk_path/GenomeAnalysisTK.
	    print GATK_RECAL "-T PrintReads "; #Type of analysis to run
	    print GATK_RECAL "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file
	    print GATK_RECAL "-I ".$inSampleDirectory."/".$infile.$infileEnding.$chromosomes[$chromosomeCounter].".bam "; #InFile
	    print GATK_RECAL "-o ".$outSampleDirectory."/".$infile.$outfileEnding.$chromosomes[$chromosomeCounter].".bam "; #OutFile
	    print GATK_RECAL "-BQSR ".$intervalSampleDirectory."/".$infile.$infileEnding.$chromosomes[$chromosomeCounter].".grp &", "\n\n";
	}
	print GATK_RECAL "wait", "\n\n";
    }
    else { #no previous merge

	for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{$sampleID} });$infileCounter++) { #For all infiles per lane
	    
	    my $infile = $infilesLaneNoEnding{$sampleID}[$infileCounter];
	    
	    for (my $chromosomeCounter=0;$chromosomeCounter<scalar(@chromosomes);$chromosomeCounter++) { #For all chromosomes	    
		
		if ($chromosomeCounter eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} 
		    
		    print GATK_RECAL "wait", "\n\n";
		    $coreCounter=$coreCounter+1;
		}
		print GATK_RECAL "java -Xmx3g ";
		print GATK_RECAL "-Djava.io.tmpdir=".$scriptParameter{'GATKTempDirectory'}."/".$chromosomes[$chromosomeCounter]."/ "; #Temporary Directory per chr
		print GATK_RECAL "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
		print GATK_RECAL "-l INFO "; #Set the minimum level of logging
		print GATK_RECAL "-T BaseRecalibrator "; #Type of analysis to run
		print GATK_RECAL "-cov ReadGroupCovariate "; #Covariates to be used in the recalibration
		print GATK_RECAL "-cov ContextCovariate "; #Covariates to be used in the recalibration
		print GATK_RECAL "-cov CycleCovariate "; #Covariates to be used in the recalibration
		print GATK_RECAL "-cov QualityScoreCovariate "; #Covariates to be used in the recalibration
		print GATK_RECAL "-cov ReadGroupCovariate "; #Covariates to be used in the recalibration
		print GATK_RECAL "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file
		print GATK_RECAL "-knownSites ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKBaseReCalibrationSNPKnownSet'}." ";
		print GATK_RECAL "-I ".$inSampleDirectory."/".$infile.$infileEnding.$chromosomes[$chromosomeCounter].".bam "; #InFile
		print GATK_RECAL "-o ".$intervalSampleDirectory."/".$infile.$infileEnding.$chromosomes[$chromosomeCounter].".grp &", "\n\n"; #Recalibration table file
	    }
	    
	    print GATK_RECAL "wait", "\n\n";
	    $coreCounter=1; #Resetting
	    
	    print GATK_RECAL "#GATK PrintReads","\n\n";
	    
	    for (my $chromosomeCounter=0;$chromosomeCounter<scalar(@chromosomes);$chromosomeCounter++) { #For all chromosomes	    
		
		if ($chromosomeCounter eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} cores
		    
		    print GATK_RECAL "wait", "\n\n";
		    $coreCounter=$coreCounter+1;
		}
		
		print GATK_RECAL "java -Xmx3g ";
		print GATK_RECAL "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
		print GATK_RECAL "-l INFO "; #Set the minimum level of logging"-jar $gatk_path/GenomeAnalysisTK.
		print GATK_RECAL "-T PrintReads "; #Type of analysis to run
		print GATK_RECAL "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file
		print GATK_RECAL "-I ".$inSampleDirectory."/".$infile.$infileEnding.$chromosomes[$chromosomeCounter].".bam "; #InFile
		print GATK_RECAL "-o ".$outSampleDirectory."/".$infile.$outfileEnding.$chromosomes[$chromosomeCounter].".bam "; #OutFile
		print GATK_RECAL "-BQSR ".$intervalSampleDirectory."/".$infile.$infileEnding.$chromosomes[$chromosomeCounter].".grp &", "\n\n";
	    }
	    print GATK_RECAL "wait", "\n\n";
	}
    }
    
    close(GATK_RECAL);  
    if ($scriptParameter{'pGATKBaseRecalibration'} == 1) { 
	FIDSubmitJob($sampleID,$familyID, 1, "MAIN",$filename,0);
    }
    return;
}

sub GATKReAligner { 
#GATK ReAlignerTargetCreator/IndelRealigner to rearrange reads around INDELs. Both ReAlignerTargetCreator and IndelRealigner will be executed within the same sbatch script

    my $sampleID = $_[0];
    my $aligner = $_[1];

    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/$aligner/info;`; #Creates the aligner folder and info data file directory
    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/$aligner/per_chr/GATK/intermediary`; #Creates the aligner folder, per chromosome and GATK intermediary data file directory
    `mkdir -p $scriptParameter{'outScriptDir'}/$sampleID/$aligner;`; #Creates the aligner folder script file directory

    if ($scriptParameter{'pGATKRealigner'} == 1) {
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/".$aligner."/gatk_realign_".$sampleID.".";   
    }
    if ($scriptParameter{'pGATKRealigner'} == 2) { #Dry run
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/".$aligner."/dry_run_gatk_realign_".$sampleID.".";   
	print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";
    }
    Checkfnexists($filename, $fnend);

###Info and Logg
    print STDOUT "Creating sbatch script GATK ReAlignerTargetCreator/IndelRealigner and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script GATK ReAlignerTargetCreator/IndelRealigner and writing script file(s) to: ".$filename, "\n";
    print STDOUT "Sbatch script GATK ReAlignerTargetCreator/IndelRealigner data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/per_chr/GATK", "\n";print MASTERL "Sbatch script GATK ReAlignerTargetCreator/IndelRealigner data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/per_chr/GATK", "\n";

    open (GATK_REAL, ">".$filename) or die "Can't write to ".$filename.": $!\n";
    
    print GATK_REAL "#! /bin/bash -l", "\n";
    print GATK_REAL "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
    print GATK_REAL "#SBATCH -p node -n ".$scriptParameter{'maximumCores'}, "\n";
    print GATK_REAL "#SBATCH -C thin", "\n";	
    print GATK_REAL "#SBATCH -t 40:00:00", "\n";
    print GATK_REAL "#SBATCH -J GATK_REAL_".$sampleID."_".$aligner, "\n";
    if ($scriptParameter{'pGATKRealigner'} == 1) {
	print GATK_REAL "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/gatk_realign_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print GATK_REAL "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/gatk_realign_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }
    elsif ($scriptParameter{'pGATKRealigner'} == 2) { #Dry run
	print GATK_REAL "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/dry_run_gatk_realign_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print GATK_REAL "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/dry_run_gatk_realign_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }

    unless ($scriptParameter{'email'} eq 0) {
	print GATK_REAL "#SBATCH --mail-type=END", "\n";
	print GATK_REAL "#SBATCH --mail-type=FAIL", "\n";
	print GATK_REAL "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
    }
    
    print GATK_REAL 'echo "Running on: $(hostname)"',"\n\n";
   
    my $inSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/per_chr";
    my $intervalSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/per_chr/GATK/intermediary";
    my $outSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/per_chr/GATK";
    my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pSamToolsViewSplitChr'}{'fileEnding'};
    my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pGATKRealigner'}{'fileEnding'};
    my ($infile, $PicardToolsMergeSwitch) = CheckIfMergedFiles($sampleID);
    my $coreCounter=1;

    print GATK_REAL "#GATK ReAlignerTargetCreator","\n\n";
    
    if ($PicardToolsMergeSwitch == 1) { #Files was merged previously

	for (my $chromosomeCounter=0;$chromosomeCounter<scalar(@chromosomes);$chromosomeCounter++) { #For all chromosome	    
	    
	    if ($chromosomeCounter eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} cores
		
		print GATK_REAL "wait", "\n\n";
		$coreCounter=$coreCounter+1;
	    }
	    
	    print GATK_REAL "java -Xmx3g ";
	    print GATK_REAL "-Djava.io.tmpdir=".$scriptParameter{'GATKTempDirectory'}."/".$chromosomes[$chromosomeCounter]."/ "; #Temporary Directory per chr
	    print GATK_REAL "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
	    print GATK_REAL "-l INFO "; #Set the minimum level of logging
	    print GATK_REAL "-T RealignerTargetCreator "; #Type of analysis to run
	    print GATK_REAL "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file 
	    print GATK_REAL "-known ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKReAlignerINDELKnownSet1'}." "; #Input VCF file with known indels
	    print GATK_REAL "-known ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKReAlignerINDELKnownSet2'}." "; #Input VCF file with known indels
	    print GATK_REAL "-I ".$inSampleDirectory."/".$infile.$infileEnding.$chromosomes[$chromosomeCounter].".bam "; #InFile
	    print GATK_REAL "-o ".$intervalSampleDirectory."/".$infile.$outfileEnding.$chromosomes[$chromosomeCounter].".intervals &", "\n\n"; #Interval outFile
	    
	}	
	
	print GATK_REAL "wait", "\n\n";
	
	$coreCounter=1; #Resetting
	print GATK_REAL "#GATK IndelRealigner","\n\n";
	
	for (my $chromosomeCounter=0;$chromosomeCounter<scalar(@chromosomes);$chromosomeCounter++) { #For all chromosome	    
	    
	    if ($chromosomeCounter eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} cores
		
		print GATK_REAL "wait", "\n\n";
		$coreCounter=$coreCounter+1;
	    }
	    
	    print GATK_REAL "java -Xmx3g ";
	    print GATK_REAL "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
	    print GATK_REAL "-l INFO ";
	    print GATK_REAL "-T IndelRealigner ";
	    print GATK_REAL "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file
	    print GATK_REAL "-known ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKReAlignerINDELKnownSet1'}." "; #Input VCF file with known indels
	    print GATK_REAL "-known ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKReAlignerINDELKnownSet2'}." "; #Input VCF file with known indels
	    print GATK_REAL "-I ".$inSampleDirectory."/".$infile.$infileEnding.$chromosomes[$chromosomeCounter].".bam "; #InFile	
	    print GATK_REAL "-o ".$outSampleDirectory."/".$infile.$outfileEnding.$chromosomes[$chromosomeCounter].".bam ";
	    print GATK_REAL "-targetIntervals ".$intervalSampleDirectory."/".$infile.$outfileEnding.$chromosomes[$chromosomeCounter].".intervals &", "\n\n";
	    
	}
    }
    else  { #No previous merge
	
	for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{$sampleID} });$infileCounter++) { #For all infiles per lane
	    
	    my $infile = $infilesLaneNoEnding{$sampleID}[$infileCounter];
	    
	    for (my $chromosomeCounter=0;$chromosomeCounter<scalar(@chromosomes);$chromosomeCounter++) { #For all chromosome	    
		
		if ($chromosomeCounter eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} cores
		    
		    print GATK_REAL "wait", "\n\n";
		    $coreCounter=$coreCounter+1;
		}
		
		print GATK_REAL "java -Xmx3g ";
		print GATK_REAL "-Djava.io.tmpdir=".$scriptParameter{'GATKTempDirectory'}."/".$chromosomes[$chromosomeCounter]."/ "; #Temporary Directory per chr
		print GATK_REAL "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
		print GATK_REAL "-l INFO "; #Set the minimum level of logging
		print GATK_REAL "-T RealignerTargetCreator "; #Type of analysis to run
		print GATK_REAL "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file 
		print GATK_REAL "-known ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKReAlignerINDELKnownSet1'}." "; #Input VCF file with known indels
		print GATK_REAL "-known ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKReAlignerINDELKnownSet2'}." "; #Input VCF file with known indels
		print GATK_REAL "-I ".$inSampleDirectory."/".$infile.$infileEnding.$chromosomes[$chromosomeCounter].".bam "; #InFile
		print GATK_REAL "-o ".$intervalSampleDirectory."/".$infile.$outfileEnding.$chromosomes[$chromosomeCounter].".intervals &", "\n\n"; #Interval outFile
		
	    }
	    
	    print GATK_REAL "wait", "\n\n";
	    
	    $coreCounter=1; #Resetting
	    print GATK_REAL "#GATK IndelRealigner","\n\n";
	    
	    for (my $chromosomeCounter=0;$chromosomeCounter<scalar(@chromosomes);$chromosomeCounter++) { #For all chromosome	    
		
		if ($chromosomeCounter eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} cores
		    
		    print GATK_REAL "wait", "\n\n";
		    $coreCounter=$coreCounter+1;
		}
		print GATK_REAL "java -Xmx3g ";
		print GATK_REAL "-jar ".$scriptParameter{'genomeAnalysisToolKitPath'}."/GenomeAnalysisTK.jar ";
		print GATK_REAL "-l INFO ";
		print GATK_REAL "-T IndelRealigner ";
		print GATK_REAL "-R ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file
		print GATK_REAL "-known ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKReAlignerINDELKnownSet1'}." "; #Input VCF file with known indels
		print GATK_REAL "-known ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'GATKReAlignerINDELKnownSet2'}." "; #Input VCF file with known indels
		print GATK_REAL "-I ".$inSampleDirectory."/".$infile.$infileEnding.$chromosomes[$chromosomeCounter].".bam "; #InFile	
		print GATK_REAL "-o ".$outSampleDirectory."/".$infile.$outfileEnding.$chromosomes[$chromosomeCounter].".bam ";
		print GATK_REAL "-targetIntervals ".$intervalSampleDirectory."/".$infile.$outfileEnding.$chromosomes[$chromosomeCounter].".intervals &", "\n\n";
		
	    }
	    $coreCounter=1; #Resetting for new infile
	}
    }
    
    print GATK_REAL "wait", "\n\n";
    
    close(GATK_REAL);
    if ($scriptParameter{'pGATKRealigner'} == 1) {
	FIDSubmitJob($sampleID,$familyID, 1, "MAIN",$filename, 0); 
    }
    return;
}

sub SamToolsViewSplitChromosomes { 
#SamTools view split genome.bam file to chr.bam files and index
    
    my $sampleID = $_[0]; 
    my $aligner = $_[1];
    
    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/$aligner/info;`; #Creates the aligner folder and info data file directory
    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/$aligner/per_chr;`; #Creates the aligner folder and per chromosome data file directory
    `mkdir -p $scriptParameter{'outScriptDir'}/$sampleID/$aligner;`; #Creates the aligner folder script file directory
    
    if ($scriptParameter{'pSamToolsViewSplitChr'} == 1) {
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/".$aligner."/samTools_view_split_to_chr_".$sampleID.".";
    }
    elsif ($scriptParameter{'pSamToolsViewSplitChr'} == 2) { #Dry run
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/".$aligner."/dry_run_samTools_view_split_to_chr_".$sampleID.".";
	print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";
    }    
    Checkfnexists($filename, $fnend);
    
###Info and Logg
    print STDOUT "Creating sbatch script SamTools view split to chromosomes & index and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script SamTools view split to chromosomes & index and writing script file(s) to: ".$filename, "\n";
    print STDOUT "Sbatch script SamTools view split to chromosomes & index data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/per_chr", "\n";print MASTERL "Sbatch script SamTools view split to chromosomes & index data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/per_chr", "\n";
    
    open (ST_VSCHR, ">".$filename) or die "Can't write to ".$filename.": $!\n";
    
    print ST_VSCHR "#! /bin/bash -l", "\n";
    print ST_VSCHR "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
    print ST_VSCHR "#SBATCH -p node -n ".$scriptParameter{'maximumCores'}, "\n";
    print ST_VSCHR "#SBATCH -C thin", "\n";	
    print ST_VSCHR "#SBATCH -t 5:00:00", "\n"; 
    print ST_VSCHR "#SBATCH -J ST_VSC_".$sampleID."_".$aligner, "\n";
    if ($scriptParameter{'pSamToolsViewSplitChr'} == 1) {
	print ST_VSCHR "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/samTools_view_split_to_chr_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print ST_VSCHR "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/samTools_view_split_to_chr_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }
    elsif ($scriptParameter{'pSamToolsViewSplitChr'} == 2) {
	print ST_VSCHR "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/dry_run_samTools_view_split_to_chr_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print ST_VSCHR "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/dry_run_samTools_view_split_to_chr_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }
    
    unless ($scriptParameter{'email'} eq 0) {	
	print ST_VSCHR "#SBATCH --mail-type=END", "\n";
	print ST_VSCHR "#SBATCH --mail-type=FAIL", "\n";
	print ST_VSCHR "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
    }
    
    print ST_VSCHR 'echo "Running on: $(hostname)"',"\n\n";

    my $inSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner;
    my $outSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/per_chr";
    my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pPicardToolsMarkduplicates'}{'fileEnding'};
    my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pSamToolsViewSplitChr'}{'fileEnding'};
    my ($infile, $PicardToolsMergeSwitch) = CheckIfMergedFiles($sampleID);
    my $coreCounter=1;
    
    if ($PicardToolsMergeSwitch == 1) { #Files was merged previously
	
	for (my $chromosomeCounter=0;$chromosomeCounter<scalar(@chromosomes);$chromosomeCounter++) { #For all chromosomes
	    
	    if ($chromosomeCounter eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} cores
		
		print ST_VSCHR "wait", "\n\n";
		$coreCounter=$coreCounter+1;
	    }
	    
	    print ST_VSCHR "samtools view ";
	    print ST_VSCHR "-b "; #Output in the BAM format
	    print ST_VSCHR "-o ".$outSampleDirectory."/".$infile.$outfileEnding.$chromosomes[$chromosomeCounter].".bam "; #OutFile
	    print ST_VSCHR $inSampleDirectory."/".$infile.$infileEnding.".bam "; #InFile
	    print ST_VSCHR $chromosomes[$chromosomeCounter]." &", "\n\n"; #Split for each chromosome
	}
	
	print ST_VSCHR "wait", "\n\n";
	$coreCounter=1; #Reset
	for (my $chromosomeCounter=0;$chromosomeCounter<scalar(@chromosomes);$chromosomeCounter++) { #For all chromosomes
	    
	    if ($chromosomeCounter eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} cores
		
		print ST_VSCHR "wait", "\n\n";
		$coreCounter=$coreCounter+1;
	    }
	    print ST_VSCHR "samtools index ";
	    print ST_VSCHR $outSampleDirectory."/".$infile.$outfileEnding.$chromosomes[$chromosomeCounter].".bam &", "\n\n"; #Outfile
	}
    }
    else { #No previous merge
	
	for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{$sampleID} });$infileCounter++) { #For all infiles per lane
	    
	    my $infile = $infilesLaneNoEnding{$sampleID}[$infileCounter];
	    
	    for (my $chromosomeCounter=0;$chromosomeCounter<scalar(@chromosomes);$chromosomeCounter++) { #For all chromosomes
		
		if ($chromosomeCounter eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} cores
		    
		    print ST_VSCHR "wait", "\n\n";
		    $coreCounter=$coreCounter+1;
		}
		
		print ST_VSCHR "samtools view ";
		print ST_VSCHR "-b "; #Output in the BAM format
		print ST_VSCHR "-o ".$outSampleDirectory."/".$infile.$outfileEnding.$chromosomes[$chromosomeCounter].".bam "; #OutFile
		print ST_VSCHR $inSampleDirectory."/".$infile.$infileEnding.".bam "; #InFile
		print ST_VSCHR $chromosomes[$chromosomeCounter]." &", "\n\n"; #Split for each chromosome
	    }
	    
	    print ST_VSCHR "wait", "\n\n";
	    $coreCounter=1; #Reset
	    for (my $chromosomeCounter=0;$chromosomeCounter<scalar(@chromosomes);$chromosomeCounter++) { #For all chromosomes
		
		if ($chromosomeCounter eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} cores
		    
		    print ST_VSCHR "wait", "\n\n";
		    $coreCounter=$coreCounter+1;
		}
		
		print ST_VSCHR "samtools index ";
		print ST_VSCHR $outSampleDirectory."/".$infile.$outfileEnding.$chromosomes[$chromosomeCounter].".bam &", "\n\n"; #Outfile
	    }
	}
    }
    print ST_VSCHR "wait", "\n\n";
    close(ST_VSCHR);
    if ($scriptParameter{'pSamToolsViewSplitChr'} == 1) {
	FIDSubmitJob($sampleID,$familyID, 1, "MAIN",$filename,0);
    }
    return;
}

sub RCoveragePlots { 
#Generates sbatch scripts for R scripts:
#1. covplots_genome.R 
#2. covplots_exome.R
#on files generated from calculateCoverage genomeCoverageBED

    my $sampleID = $_[0]; 
    my $aligner = $_[1];
    
    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/$aligner/info;`; #Creates the aligner folder and info data file directory
    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/$aligner/coverageReport;`; #Creates the aligner and coverageReport folder
    `mkdir -p $scriptParameter{'outScriptDir'}/$sampleID/$aligner;`; #Creates the aligner script directory
    if ($scriptParameter{'pRCovPlots'} == 1) {
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/".$aligner."/rCovPlots_".$sampleID.".";
    }
    elsif ($scriptParameter{'pRCovPlots'} == 2) { #Dry run
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/".$aligner."/dry_run_rCovPlots_".$sampleID.".";
	print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";
    }

    Checkfnexists($filename, $fnend);

###Info and Logg
    print STDOUT "Creating sbatch script RCoveragePlots and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script RCoveragePlots and writing script file(s) to: ".$filename, "\n";
    print STDOUT "Sbatch script RCoveragePlots data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/coverageReport", "\n";print MASTERL "Sbatch script RCoveragePlots data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/coverageReport", "\n";
    
    open (RCOVP, ">".$filename) or die "Can't write to ".$filename.": $!\n";
    
    print RCOVP "#! /bin/bash -l", "\n";
    print RCOVP "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
    print RCOVP "#SBATCH -n 1 ", "\n";
    print RCOVP "#SBATCH -C thin", "\n";	
    print RCOVP "#SBATCH -t 01:00:00", "\n"; 
    print RCOVP "#SBATCH -J RCP_".$sampleID."_".$aligner, "\n";
    if ($scriptParameter{'pRCovPlots'} == 1) {
	print RCOVP "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/rCovPlots_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print RCOVP "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/rCovPlots_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }
    elsif ($scriptParameter{'pRCovPlots'} == 2) { #Dry run
	print RCOVP "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/dry_run_rCovPlots_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print RCOVP "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/dry_run_rCovPlots_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }

    unless ($scriptParameter{'email'} eq 0) {	
	print RCOVP "#SBATCH --mail-type=END", "\n";
	print RCOVP "#SBATCH --mail-type=FAIL", "\n";
	print RCOVP "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
    }
    
    print RCOVP 'echo "Running on: $(hostname)"',"\n\n";
 
    my $inSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/coverageReport";
    my $outSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/coverageReport";
    my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pPicardToolsMarkduplicates'}{'fileEnding'};
    my ($infile, $PicardToolsMergeSwitch) = CheckIfMergedFiles($sampleID);    
    
    if ($PicardToolsMergeSwitch == 1) { #Files was merged previously
	
	if ( defined($scriptParameter{'pGenomeCoverageBED'}) && ($scriptParameter{'pGenomeCoverageBED'} > 0) ) {
	    my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pGenomeCoverageBED'}{'fileEnding'};

	    print RCOVP "Rscript ";
	    print RCOVP $scriptParameter{'inScriptDir'}."/covplots_genome.R ";
	    print RCOVP $inSampleDirectory."/".$infile.$infileEnding." "; #InFile
	    print RCOVP $infile." "; #Sample name
	    print RCOVP $scriptParameter{'xCoverage'}." "; #X-axis max scale
	    print RCOVP $outSampleDirectory, " &","\n\n"; #OutFile
	}
	if ( defined($scriptParameter{'pCoverageBED'}) && ($scriptParameter{'pCoverageBED'} > 0) ) {
	    my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pCoverageBED'}{'fileEnding'};
	    
	    print RCOVP "grep ";
	    print RCOVP "^all "; #Prepp indata file to contain only all features
	    print RCOVP $inSampleDirectory."/".$infile.$infileEnding." "; #InFile
	    print RCOVP "> ".$inSampleDirectory."/".$infile.$outfileEnding."_coverageBed_all_hist &", "\n\n"; #OutFile

	    print RCOVP "wait", "\n\n";

	    print RCOVP "Rscript ";
	    print RCOVP $scriptParameter{'inScriptDir'}."/covplots_exome_all.R ";
	    print RCOVP $inSampleDirectory."/".$infile.$infileEnding."_coverageBed_all_hist "; #InFile
	    print RCOVP $infile." "; #Sample name
	    print RCOVP $outSampleDirectory, " &", "\n\n"; #OutFile
	    
	    #Duplicates removed
	    $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pCoverageBEDRMDup'}{'fileEnding'};

	    print RCOVP "#Duplicates removed\n\n";
	    print RCOVP "#Prepp indata file to contain only all features\n";

	    print RCOVP "grep ";
	    print RCOVP "^all "; #Prepp indata file to contain only all features
	    print RCOVP $inSampleDirectory."/".$infile.$infileEnding." "; #InFile
	    print RCOVP "> ".$outSampleDirectory."/".$infile.$outfileEnding."_rmdup_coverageBed_all_hist &", "\n\n"; #OutFile
	    print RCOVP "wait", "\n\n";

	    print RCOVP "Rscript ";
	    print RCOVP $scriptParameter{'inScriptDir'}."/covplots_exome_all.R ";
	    print RCOVP $inSampleDirectory."/".$infile.$outfileEnding."rmdup_coverageBed_all_hist "; #InFile
	    print RCOVP $infile."_rmdup "; #Sample name
	    print RCOVP $outSampleDirectory, " &", "\n\n"; #OutFile
	}
    }
    else { #No previous merge
	for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{$sampleID} });$infileCounter++) { #For all infiles per lane
	    
	    my $infile = $infilesLaneNoEnding{$sampleID}[$infileCounter];
	    
	    if ( defined($scriptParameter{'pGenomeCoverageBED'}) && ($scriptParameter{'pGenomeCoverageBED'} > 0) ) {
		my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pGenomeCoverageBED'}{'fileEnding'};
		
		print RCOVP "Rscript ";
		print RCOVP $scriptParameter{'inScriptDir'}."/covplots_genome.R ";
		print RCOVP $inSampleDirectory."/".$infile.$infileEnding." "; #InFile
		print RCOVP $infile." "; #Sample name
		print RCOVP $scriptParameter{'xCoverage'}." "; #X-axis max scale
		print RCOVP $outSampleDirectory, " &", "\n\n"; #OutFile
	    }
	    if ( defined($scriptParameter{'pCoverageBED'}) && ($scriptParameter{'pCoverageBED'} > 0) ) {
		my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pCoverageBED'}{'fileEnding'};
		
		print RCOVP "#Prepp indata file to contain only all features\n";
		
		print RCOVP "grep ";
		print RCOVP "^all "; #Prepp indata file to contain only all features
		print RCOVP $inSampleDirectory."/".$infile.$infileEnding." "; #InFile
		print RCOVP "> ".$outSampleDirectory."/".$infile.$outfileEnding."_coverageBed_all_hist &", "\n\n"; #OutFile 
		print RCOVP "wait", "\n\n";

		print RCOVP "Rscript ";
		print RCOVP $scriptParameter{'inScriptDir'}."/covplots_exome_all.R ";
		print RCOVP $inSampleDirectory."/".$infile.$outfileEnding."_coverageBed_all_hist "; #InFile
		print RCOVP $infile." "; #X-axis max scale
		print RCOVP $outSampleDirectory, " &","\n\n"; #OutFile
#Duplicates removed
		$infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pCoverageBEDRMDup'}{'fileEnding'};
		print RCOVP "#Duplicates removed\n\n";	    
		print RCOVP "#Prepp indata file to contain only all features\n";
		
		print RCOVP "grep ";
		print RCOVP "^all "; #Prepp indata file to contain only all features 
		print RCOVP $inSampleDirectory."/".$infile.$infileEnding." "; #InFile
		print RCOVP "> ".$outSampleDirectory."/".$infile.$outfileEnding."_rmdup_coverageBed_all_hist &", "\n\n"; #OutFile
		print RCOVP "wait", "\n\n";

		print RCOVP "Rscript ";
		print RCOVP $scriptParameter{'inScriptDir'}."/covplots_exome_all.R ";
		print RCOVP $inSampleDirectory."/".$infile.$outfileEnding."_rmdup_coverageBed_all_hist "; #InFile
		print RCOVP $infile."_rmdup "; #Sample name
		print RCOVP $outSampleDirectory, " &", "\n\n"; #OutFile	    
	    }
	}
    }
    print RCOVP "wait", "\n\n";
    close(RCOVP);
    if ($scriptParameter{'pRCovPlots'} == 1) {
	#ParallelSampleIDSubmitJob($sampleID,$filename,"all");
	FIDSubmitJob($sampleID,$familyID,2,"Coverage",$filename,0);
    }
    return;
}

sub CalculateCoverage { 
#Generates sbatch scripts and calculates coverage on alignment files (sorted). 
#NOTE:Collect_info.pl collects key metric reference file from .alignment_summary_metrics. If not processed genome build will be missing in key metric file.

    my $sampleID = $_[0]; 
    my $aligner = $_[1]; 
    
    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/$aligner/info;`; #Creates the aligner folder and info data file directory
    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/$aligner/coverageReport;`; #Creates the aligner and coverageReport folder
    `mkdir -p $scriptParameter{'outScriptDir'}/$sampleID/$aligner;`; #Creates the aligner script directory
    if ($scriptParameter{'pCalculateCoverage'} == 1) {
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/".$aligner."/calculate_coverage_".$sampleID.".";
    }
    elsif ($scriptParameter{'pCalculateCoverage'} == 2) { #Dry run
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/".$aligner."/dry_run_calculate_coverage_".$sampleID.".";
	print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";
    }
    Checkfnexists($filename, $fnend);

###Info and Logg
    print STDOUT "Creating sbatch script Calculate Coverage and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script Calculate Coverage and writing script file(s) to: ".$filename, "\n";
    print STDOUT "Sbatch script Calculate Coverage data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/coverageReport", "\n";print MASTERL "Sbatch script Calculate Coverage data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/coverageReport", "\n";

    my $time = ceil(3*scalar( @{ $infilesBothStrandsNoEnding{$sampleID} })); #One full lane on Hiseq takes approx. 2 h to process, round up to nearest full hour.
    
    open (CAL_COV, ">".$filename) or die "Can't write to ".$filename.": $!\n";
    
    print CAL_COV "#! /bin/bash -l", "\n";
    print CAL_COV "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
    print CAL_COV "#SBATCH -p node -n ".$scriptParameter{'maximumCores'}, "\n";
    print CAL_COV "#SBATCH -C thin", "\n";

    if ($scriptParameter{'pPicardToolsMergeSamFiles'} eq 0) {	
	print CAL_COV "#SBATCH -t 4:00:00", "\n";	
    }
    else{
	print CAL_COV "#SBATCH -t ".$time.":00:00", "\n";	
    }	

    print CAL_COV "#SBATCH -J Cov_Ca".$sampleID."_".$aligner, "\n";
    if ($scriptParameter{'pCalculateCoverage'} == 1) {
	print CAL_COV "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/calculate_coverage_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print CAL_COV "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/calculate_coverage_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }
    elsif ($scriptParameter{'pCalculateCoverage'} == 2) {
	print CAL_COV "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/dry_run_calculate_coverage_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print CAL_COV "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/dry_run_calculate_coverage_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }

    unless ($scriptParameter{'email'} eq 0) {
	print CAL_COV "#SBATCH --mail-type=END", "\n";
	print CAL_COV "#SBATCH --mail-type=FAIL", "\n";
	print CAL_COV "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
    }
    
    print CAL_COV 'echo "Running on: $(hostname)"',"\n\n";
   
    my $inSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner;
    my $outSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/coverageReport";
    my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pPicardToolsMarkduplicates'}{'fileEnding'};
    my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pPicardToolsMarkduplicates'}{'fileEnding'}; #Programs that will be used downstream will get a local outFileEnding later
    my ($infile, $PicardToolsMergeSwitch) = CheckIfMergedFiles($sampleID);
    my $coreCounter=1;

    if ($PicardToolsMergeSwitch == 1) { #Files was merged previously
	
	if ($scriptParameter{'pGenomeCoverageBED'} > 0) {
	    my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pGenomeCoverageBED'}{'fileEnding'};
	    
	    print CAL_COV "genomeCoverageBed ";
	    print CAL_COV "-max ".$scriptParameter{'xCoverage'}." "; #Combine all positions with a depth >= max into a single bin in the histogram.
	    print CAL_COV "-ibam ".$inSampleDirectory."/".$infile.$infileEnding.".bam "; #InFile
	    print CAL_COV "> ".$outSampleDirectory."/".$infile.$outfileEnding." &", "\n\n"; #OutFile
	}
	if ($scriptParameter{'pQaCompute'} > 0) {
	    print CAL_COV "qaCompute ";
	    print CAL_COV "-m "; #Compute median coverage
	    print CAL_COV "-d "; #Print per-chromosome histogram
	    print CAL_COV "-i "; #Silent
	    print CAL_COV "-c ".$scriptParameter{'xCoverage'}." ";
	    print CAL_COV $inSampleDirectory."/".$infile.$infileEnding.".bam "; #InFile
	    print CAL_COV $outSampleDirectory."/".$infile.$outfileEnding."_qaCompute &", "\n\n"; #OutFile
	}
	if ($scriptParameter{'pPicardToolsCollectMultipleMetrics'} > 0) {
	    print CAL_COV "java -Xmx4g -jar ".$scriptParameter{'picardToolsPath'}."/CollectMultipleMetrics.jar ";
	    print CAL_COV "INPUT=".$inSampleDirectory."/".$infile.$infileEnding.".bam "; #InFile
	    print CAL_COV "OUTPUT=".$outSampleDirectory."/".$infile.$outfileEnding." "; #OutFile
	    print CAL_COV "R=".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." &", "\n\n"; #Reference file
	}
	if ($scriptParameter{'pPicardToolsCalculateHSMetrics'} > 0) { #Run CalculateHsMetrics (Target BED-file)
	    print CAL_COV "java -Xmx4g -jar ".$scriptParameter{'picardToolsPath'}."/CalculateHsMetrics.jar ";
	    print CAL_COV "INPUT=".$inSampleDirectory."/".$infile.$infileEnding.".bam "; #InFile
	    print CAL_COV "OUTPUT=".$outSampleDirectory."/".$infile.$outfileEnding."_CalculateHsMetrics "; #OutFile
	    print CAL_COV "REFERENCE_SEQUENCE=".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file
	    print CAL_COV "BAIT_INTERVALS=".$scriptParameter{'referencesDir'}."/".$sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'exomeTargetPaddedBedInfileList'}." "; #Capture kit padded target infile_list file
	    print CAL_COV "TARGET_INTERVALS=".$scriptParameter{'referencesDir'}."/".$sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'exomeTargetBedInfileList'}." &", "\n\n"; #Capture kit target infile_list file
	}
	if ($scriptParameter{'pCoverageBED'} > 0) { #Run coverageBed (exome)
	    my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pCoverageBED'}{'fileEnding'};
	    
	    print CAL_COV "coverageBed ";
	    print CAL_COV "-hist "; #Report a histogram of coverage for each feature in B as well as a summary histogram for _all_ features in B.
	    print CAL_COV "-abam ".$inSampleDirectory."/".$infile.$infileEnding.".bam "; #InFile in BAM format
	    print CAL_COV "-b ".$scriptParameter{'referencesDir'}."/".$sampleInfo{$scriptParameter{'familyID'}}{$sampleID}{'exomeTargetBed'}." "; #InFile
	    print CAL_COV "> ".$outSampleDirectory."/".$infile.$outfileEnding." &", "\n\n"; #OutFile
	    #Remove PCR and Optical duplicates
	    $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pCoverageBEDRMDup'}{'fileEnding'};
	    
	    print CAL_COV "samtools view ";
	    print CAL_COV "-F 0x400 "; #Skip alignments where read is PCR or optical duplicate
	    print CAL_COV "-b ".$inSampleDirectory."/".$infile.$infileEnding.".bam "; #InFile
	    print CAL_COV "| coverageBed "; #Note "|"
	    print CAL_COV "-hist "; #Report a histogram of coverage for each feature in B as well as a summary histogram for _all_ features in B.
	    print CAL_COV "-abam stdin "; #InStream
	    print CAL_COV "-b ".$scriptParameter{'referencesDir'}."/".$sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'exomeTargetBed'}." "; #InFile
	    print CAL_COV "> ".$outSampleDirectory."/".$infile.$outfileEnding." &", "\n\n"; #OutFile
	}

	print CAL_COV "wait", "\n\n";
###
#Coverage Report
###
	print CAL_COV "#Coverage Report Generation\n\n";
	print CAL_COV "#Returns the depth and breadth of coverage of features from A (-abam)\n";
	print CAL_COV "coverageBed "; #Returns the depth and breadth of coverage of features from A
	print CAL_COV "-abam ".$inSampleDirectory."/".$infile.$infileEnding.".bam "; #InFile in BAM format
	print CAL_COV "-b ".$scriptParameter{'referencesDir'}."/".$sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'exomeTargetBed'}." "; #InFile
	print CAL_COV "> ".$outSampleDirectory."/".$infile.$outfileEnding."_coverageBed &", "\n\n"; #OutFile
	
	print CAL_COV "coverageBed ";
	print CAL_COV "-d "; #Report the depth at each position in each B feature.
	print CAL_COV "-abam ".$inSampleDirectory."/".$infile.$infileEnding.".bam "; #InFile in BAM format
	print CAL_COV "-b ".$scriptParameter{'referencesDir'}."/".$sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'exomeTargetBed'}." "; #InFile
	print CAL_COV "> ".$outSampleDirectory."/".$infile.$outfileEnding."_coverageBed_depth_pos &", "\n\n"; #OutFile
	
	print CAL_COV "wait", "\n\n";
	
	#Generate the average depth per feature and the number of zero-coverage bases as well as their relative to feature position
	print CAL_COV "#Generate the average depth per feature and the number of zero-coverage bases as well as their relative to feature position", "\n";
	print CAL_COV q?perl -nae'my $prev_chr=0;my $prev_start;my $prev_end;my $average_cov=0;my $nr_positions=0;my %feature;my %zerofeature;my @temp_line; while (<>) { chomp($_);  @temp_line = split("\t",$_); if($feature{$temp_line[0]}{$temp_line[1]}{$temp_line[2]}) { if ($temp_line[5] >= 10) { $feature{$temp_line[0]}{$temp_line[1]}{$temp_line[2]}{'high-coverage'}++;} if ($temp_line[5] == 0) { push (@ {$zerofeature{$temp_line[0]}{$temp_line[1]}{$temp_line[2]}{'zero-coverage'}}, $temp_line[1]+$temp_line[4]-1);} $average_cov=$average_cov+$temp_line[5];$nr_positions++;} else { if ($prev_chr && ($prev_start != $temp_line[1]) && ($prev_end != $temp_line[2])) { print "$prev_chr\t","$prev_start\t","$prev_end\t",$average_cov/$nr_positions,"\t"; if ($feature{$prev_chr}{$prev_start}{$prev_end}{'high-coverage'}) { print $feature{$prev_chr}{$prev_start}{$prev_end}{'high-coverage'}/$nr_positions, "\t";} else {print "0\t";} if ($zerofeature{$prev_chr}{$prev_start}{$prev_end}{'zero-coverage'}) { print scalar(@ {$zerofeature{$prev_chr}{$prev_start}{$prev_end}{'zero-coverage'} }), "\t"; for (my $i=0;$i<scalar(@ {$zerofeature{$prev_chr}{$prev_start}{$prev_end}{'zero-coverage'}});$i++) { print "$zerofeature{$prev_chr}{$prev_start}{$prev_end}{'zero-coverage'}[$i];";} print "\tdepth_pos\n"; } else {print "0\t","Na\tdepth_pos\n";} } %feature = ();%zerofeature = ();$average_cov=0;$nr_positions=0;$feature{$temp_line[0]}{$temp_line[1]}{$temp_line[2]} = $_; $prev_chr = $temp_line[0];$prev_start = $temp_line[1];$prev_end = $temp_line[2];if ($temp_line[5] >= 10) { $feature{$temp_line[0]}{$temp_line[1]}{$temp_line[2]}{'high-coverage'}++;} if ($temp_line[5] == 0) { push (@ {$zerofeature{$temp_line[0]}{$temp_line[1]}{$temp_line[2]}{'zero-coverage'} }, $temp_line[1]+$temp_line[4]-1);} $average_cov=$average_cov+$temp_line[5];$nr_positions++;} } print "$prev_chr\t","$prev_start\t","$prev_end\t",$average_cov/$nr_positions,"\t"; if ($feature{$prev_chr}{$prev_start}{$prev_end}{'high-coverage'}) { print $feature{$prev_chr}{$prev_start}{$prev_end}{'high-coverage'}/$nr_positions, "\t";} else {print "0\t";} if ($zerofeature{$prev_chr}{$prev_start}{$prev_end}{'zero-coverage'}) { print scalar(@ {$zerofeature{$prev_chr}{$prev_start}{$prev_end}{'zero-coverage'} }), "\t"; for (my $i=0;$i<scalar(@ {$zerofeature{$prev_chr}{$prev_start}{$prev_end}{'zero-coverage'}});$i++) { print "$zerofeature{$prev_chr}{$prev_start}{$prev_end}{'zero-coverage'}[$i];";} print "\tdepth_pos\n"; } else {print "0\t","Na\tdepth_pos\n";} last;' ?.$outSampleDirectory."/".$infile.$infileEnding."_coverageBed_depth_pos "; #InFile using the just created depth_pos file located in the outSampleDirectory
	print CAL_COV "> ".$outSampleDirectory."/".$infile.$outfileEnding."_coverageBed_depth_pos_collapsed", "\n\n"; #OutFile
	
	#Concatenate to 1 file to be able to include info from _coverageBed file
	print CAL_COV "#Concatenate to 1 file to be able to include info from _coverageBed file", "\n";
	print CAL_COV "cat ";
	print CAL_COV $outSampleDirectory."/".$infile.$infileEnding."_coverageBed_depth_pos_collapsed "; #InFile
	print CAL_COV $outSampleDirectory."/".$infile.$infileEnding."_coverageBed "; #InFile
	print CAL_COV "> ".$outSampleDirectory."/".$infile.$outfileEnding."_coverageBed_merged_temp", "\n\n"; #OutFile
	
	#Sort on chr and then numerically on start position. NOTE makes the two lines from each file end up next to each other. The line order is preserved unless the feature annotation is "-", then it is reversed (exception handled by the next perl one-liner) 
	print CAL_COV "#Sort on chr and then numerically on start position.\n";
	print CAL_COV "sort ";
	print CAL_COV "-k1,1 -k2,2n "; #Sort on chr and then numerically on start position.
	print CAL_COV $outSampleDirectory."/".$infile.$infileEnding."_coverageBed_merged_temp "; #Infile
	print CAL_COV "> ".$outSampleDirectory."/".$infile.$outfileEnding."_coverageBed_merged", "\n\n"; #OutFile
	
	#Collpase the two lines from coverageBed_depth_pos_collapsed and _coverageBed
	print CAL_COV "##Collpase the two lines from coverageBed_depth_pos_collapsed and _coverageBed\n";
	print CAL_COV q?perl -nae ' print "#Chr\tStart\tStop\tOverlapping_Reads\tNon-zero_Coverage_Bases\tFeature_Length(Nucleotides)\tAverage_Coverage\tFraction_Non-zero_Coverage_Bases\tFraction_Ten_Coverage_Bases\tNr_Zero_Coverage_Bases\tRelative_position_for_Zero_Coverage_Bases\n";chomp($_);my @prev_line=split("\t",$_);my @temp_line; while (<>) { chomp($_); @temp_line = split("\t",$_); if ($prev_line[0]  && ($prev_line[0] eq $temp_line[0]) && ($prev_line[1] == $temp_line[1]) && ($prev_line[2] == $temp_line[2])) { unless ($prev_line[7] eq "depth_pos") { $temp_line[3]=~s/\./\,/;$prev_line[4]=~s/\./\,/; print $prev_line[0],"\t", $prev_line[1],"\t",$prev_line[2],"\t",$prev_line[4],"\t",$prev_line[5],"\t",$prev_line[6],"\t",$temp_line[3],"\t","$prev_line[7]\t","$temp_line[4]\t","$temp_line[5]\t","$temp_line[6]\n";} else { $prev_line[3]=~s/\./\,/;$temp_line[4]=~s/\./\,/; print $temp_line[0],"\t", $temp_line[1],"\t",$temp_line[2],"\t",$temp_line[4],"\t",$temp_line[5],"\t",$temp_line[6],"\t",$prev_line[3],"\t","$temp_line[7]\t","$prev_line[4]\t","$prev_line[5]\t","$prev_line[6]\n";} } else { @prev_line = @temp_line;} }last;' ?.$outSampleDirectory."/".$infile.$infileEnding."_coverageBed_merged "; #InFile using the just created sorted _coverageBed_merged file located in the outSampleDirectory
	print CAL_COV "> ".$outSampleDirectory."/".$infile.$outfileEnding."_target_coverage.txt", "\n\n"; #OutFile
	
	#Add chr to entry to enable comparison to Gene Db
	print CAL_COV "#Add chr to entry to enable later comparison to Gene Db", "\n";
	print CAL_COV q?perl -i -p -e ' if($_=~/^#/) {} else {s/^(.+)/chr$1/g }' ?.$outSampleDirectory."/".$infile.$infileEnding."_target_coverage.txt", "\n\n"; #Modify in place
	
	#Removal of files which the necessary info has been extracted from
	print CAL_COV "#Removal of files which the necessary info has been extracted from\n";
	print CAL_COV "rm ";
	print CAL_COV $outSampleDirectory."/".$infile.$outfileEnding."_coverageBed", "\n\n";
		
	print CAL_COV "rm ";
	print CAL_COV $outSampleDirectory."/".$infile.$outfileEnding."_coverageBed_depth_pos", "\n\n";
	print CAL_COV "rm ";
	print CAL_COV $outSampleDirectory."/".$infile.$outfileEnding."_coverageBed_depth_pos_collapsed", "\n\n";
	print CAL_COV "rm ";
	print CAL_COV $outSampleDirectory."/".$infile.$outfileEnding."_coverageBed_merged_temp", "\n\n";
	print CAL_COV "rm ";
	print CAL_COV $outSampleDirectory."/".$infile.$outfileEnding."_coverageBed_merged", "\n\n";
		
	my $targetCoverageDbFile = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/coverageReport/".$infile;
	my $targetCoverageFile =  $targetCoverageDbFile;
	
	$targetCoverageDbFile .= $infileEnding."_coverage_target_db_master.txt";		    
	$targetCoverageFile .= $infileEnding."_target_coverage.txt";    
	my @targetCoverageDbFiles = ($targetCoverageDbFile); #Db master files	    
	my @targetCoverageFiles = ($targetCoverageFile); #Target coverage files created above
	
###
#Create target file with EnsembleGeneID (Required for coverage calculation in rank_script)
###
	#Create db master template 
	print CAL_COV "#Add GeneName to Coverage Report", "\n";
	for (my $dbFileCounter=0;$dbFileCounter<scalar(@targetCoverageDbFiles);$dbFileCounter++) {
	    open (TARCOV, ">".$targetCoverageDbFiles[$dbFileCounter]) or die "Can't write to ".$targetCoverageDbFiles[$dbFileCounter].": $!\n";
	    print TARCOV "outcolumns=0_0,0_1,0_2,0_3,0_4,0_5,0_6,0_7,0_8,0_9,0_10,1_4\n"; #Order of columns in outfile
	    print TARCOV "outheaders=Chr,Start,Stop,Overlapping_Reads,Non-zero_Coverage_Bases,Feature_Length(Nucleotides),Average_Coverage,Fraction_Non-zero_Coverage_Bases,Fraction_Ten_Coverage_Bases,Nr_Zero_Coverage_Bases,Relative_position_for_Zero_Coverage_Bases,Ensembl_GeneID\n"; #Order and header content in outfile
	    print TARCOV $targetCoverageFiles[$dbFileCounter],"\t".'\t'."\t0,1,2\t0\texact\t0,1,2,3,4,5,6,7,8,9,10\tsmall","\n";
	    print TARCOV $scriptParameter{'referencesDir'}."/mart_export_Ensembl_GeneID_key_cleaned_noblanks_chr.txt\t".'\t'."\t0,1,2\t0\trange\t4\tsmall", "\n";
	    close(TARCOV);
	    
	    #Add GeneNameID to Coverage report
	    print CAL_COV "perl ";
	    print CAL_COV $scriptParameter{'inScriptDir'}."/intersectCollect.pl ";
	    print CAL_COV "-o ".$targetCoverageFiles[$dbFileCounter]." "; #OutFile
	    print CAL_COV "-db ".$targetCoverageDbFiles[$dbFileCounter]." "; #Db master file (InFile(s))
	    print CAL_COV "-prechr 1", "\n\n"; #Use chromosome prefix
	}   
    }

    else { #No merged files
	
	for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{$sampleID} });$infileCounter++) { #For all files from MosaikAlign or BWA_Sampe
	    
	    my $infile = $infilesLaneNoEnding{$sampleID}[$infileCounter];
	    if ($scriptParameter{'pGenomeCoverageBED'} > 0) {
		my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pGenomeCoverageBED'}{'fileEnding'};
		
		print CAL_COV "genomeCoverageBed ";
		print CAL_COV "-max ".$scriptParameter{'xCoverage'}." "; #Combine all positions with a depth >= max into a single bin in the histogram.
		print CAL_COV "-ibam ".$inSampleDirectory."/".$infile.$infileEnding.".bam "; #InFile
		print CAL_COV "> ".$outSampleDirectory."/".$infile.$outfileEnding." &", "\n\n"; #outFile
	    }
	    if ($scriptParameter{'pQaCompute'} > 0) { #Genome coverage calculations
		print CAL_COV "qaCompute ";
		print CAL_COV "-m "; #Compute median coverage
		print CAL_COV "-d "; #Print per-chromosome histogram
		print CAL_COV "-i "; #Silent 
		print CAL_COV "-c ".$scriptParameter{'xCoverage'}." "; #Max depth to calculate coverage on
		print CAL_COV $inSampleDirectory."/".$infile.$infileEnding.".bam "; #InFile
		print CAL_COV $outSampleDirectory."/".$infile.$outfileEnding."_qaCompute &", "\n\n"; #OutFile
	    }
	    if ($scriptParameter{'pPicardToolsCollectMultipleMetrics'} > 0) {
		print CAL_COV "java -Xmx4g -jar ".$scriptParameter{'picardToolsPath'}."/CollectMultipleMetrics.jar ";
		print CAL_COV "INPUT=".$inSampleDirectory."/".$infile.$infileEnding.".bam "; #InFile
		print CAL_COV "OUTPUT=".$outSampleDirectory."/".$infile.$outfileEnding." "; #outFile
		print CAL_COV "R=".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." &", "\n\n"; #Reference file
	    }
	    if ($scriptParameter{'pPicardToolsCalculateHSMetrics'} > 0) { #Run CalculateHsMetrics (Target BED-file)
		print CAL_COV "java -Xmx4g -jar ".$scriptParameter{'picardToolsPath'}."/CalculateHsMetrics.jar ";
		print CAL_COV "INPUT=".$inSampleDirectory."/".$infile.$infileEnding.".bam "; #InFile
		print CAL_COV "OUTPUT=".$outSampleDirectory."/".$infile.$outfileEnding."_CalculateHsMetrics "; #OutFile
		print CAL_COV "REFERENCE_SEQUENCE=".$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference file
		print CAL_COV "BAIT_INTERVALS=".$scriptParameter{'referencesDir'}."/".$sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'exomeTargetPaddedBedInfileList'}." "; #Capture kit padded target infile_list file
		print CAL_COV "TARGET_INTERVALS=".$scriptParameter{'referencesDir'}."/".$sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'exomeTargetBedInfileList'}." &", "\n\n"; #Capture kit target infile_list file 
	    }
	    if ($scriptParameter{'pCoverageBED'} > 0) { #Run coverageBed (Target BED-file)
		my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pCoverageBED'}{'fileEnding'};
		
		print CAL_COV "coverageBed ";
		print CAL_COV "-hist "; #Report a histogram of coverage for each feature in B as well as a summary histogram for _all_ features in B.
		print CAL_COV "-abam ".$inSampleDirectory."/".$infile.$infileEnding.".bam "; #InFile in BAM format
		print CAL_COV "-b ".$scriptParameter{'referencesDir'}."/".$sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'exomeTargetBed'}." "; #InFile
		print CAL_COV "> ".$outSampleDirectory."/".$infile.$outfileEnding." &", "\n\n"; #OutFile
		#Remove PCR and Optical duplicates
		$outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pCoverageBEDRMDup'}{'fileEnding'};

		print CAL_COV "samtools view ";
		print CAL_COV "-F 0x400 "; #Skip alignments where read is PCR or optical duplicate
		print CAL_COV "-b ".$inSampleDirectory."/".$infile.$infileEnding.".bam "; #InFile
		print CAL_COV "| coverageBed "; #Note "|"
		print CAL_COV "-hist "; #Report a histogram of coverage for each feature in B as well as a summary histogram for _all_ features in B.
		print CAL_COV "-abam stdin "; #InStream
		print CAL_COV "-b ".$scriptParameter{'referencesDir'}."/".$sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'exomeTargetBed'}." "; #InFile
		print CAL_COV "> ".$outSampleDirectory."/".$infile.$infileEnding.$outfileEnding." &", "\n\n"; #OutFile
		
	    }
	    print CAL_COV "wait", "\n\n";
	}
###
#Coverage Report
###
	print CAL_COV "#Coverage Report Generation\n\n";
	for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{$sampleID} });$infileCounter++) { #For all files from MosaikAlign or BWA_Sampe
	    
	    my $infile = $infilesLaneNoEnding{$sampleID}[$infileCounter];
	    
	    print CAL_COV "#Calculate coverage statistics to enable coverage calculation in rank_script", "\n";
	    print CAL_COV "coverageBed "; #Returns the depth and breadth of coverage of features from A
	    print CAL_COV "-abam ".$inSampleDirectory."/".$infile.$infileEnding.".bam "; #InFiles in BAM format
	    print CAL_COV "-b ".$scriptParameter{'referencesDir'}."/".$sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'exomeTargetBed'}." "; #Infile
	    print CAL_COV "> ".$outSampleDirectory."/".$infile.$outfileEnding."_coverageBed &", "\n\n"; #OutFile
	    
	    print CAL_COV "coverageBed ";
	    print CAL_COV "-d "; #Report the depth at each position in each B feature.
	    print CAL_COV "-abam ".$inSampleDirectory."/".$infile.$infileEnding.".bam "; #InFiles in BAM format
	    print CAL_COV "-b ".$scriptParameter{'referencesDir'}."/".$sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'exomeTargetBed'}." "; #InFile
	    print CAL_COV "> ".$outSampleDirectory."/".$infile.$outfileEnding."_coverageBed_depth_pos &", "\n\n"; #OutFile
	    
	    print CAL_COV "wait", "\n\n";

#Generate the average depth per feature and the number of zero-coverage bases as well as their relative to feature position
	    print CAL_COV "#Generate the average depth per feature and the number of zero-coverage bases as well as their relative to feature position", "\n";
	    print CAL_COV q?perl -nae'my $prev_chr=0;my $prev_start;my $prev_end;my $average_cov=0;my $nr_positions=0;my %feature;my %zerofeature;my @temp_line; while (<>) { chomp($_);  @temp_line = split("\t",$_); if($feature{$temp_line[0]}{$temp_line[1]}{$temp_line[2]}) { if ($temp_line[5] >= 10) { $feature{$temp_line[0]}{$temp_line[1]}{$temp_line[2]}{'high-coverage'}++;} if ($temp_line[5] == 0) { push (@ {$zerofeature{$temp_line[0]}{$temp_line[1]}{$temp_line[2]}{'zero-coverage'}}, $temp_line[1]+$temp_line[4]-1);} $average_cov=$average_cov+$temp_line[5];$nr_positions++;} else { if ($prev_chr && ($prev_start != $temp_line[1]) && ($prev_end != $temp_line[2])) { print "$prev_chr\t","$prev_start\t","$prev_end\t",$average_cov/$nr_positions,"\t"; if ($feature{$prev_chr}{$prev_start}{$prev_end}{'high-coverage'}) { print $feature{$prev_chr}{$prev_start}{$prev_end}{'high-coverage'}/$nr_positions, "\t";} else {print "0\t";} if ($zerofeature{$prev_chr}{$prev_start}{$prev_end}{'zero-coverage'}) { print scalar(@ {$zerofeature{$prev_chr}{$prev_start}{$prev_end}{'zero-coverage'} }), "\t"; for (my $i=0;$i<scalar(@ {$zerofeature{$prev_chr}{$prev_start}{$prev_end}{'zero-coverage'}});$i++) { print "$zerofeature{$prev_chr}{$prev_start}{$prev_end}{'zero-coverage'}[$i];";} print "\tdepth_pos\n"; } else {print "0\t","Na\tdepth_pos\n";} } %feature = ();%zerofeature = ();$average_cov=0;$nr_positions=0;$feature{$temp_line[0]}{$temp_line[1]}{$temp_line[2]} = $_; $prev_chr = $temp_line[0];$prev_start = $temp_line[1];$prev_end = $temp_line[2];if ($temp_line[5] >= 10) { $feature{$temp_line[0]}{$temp_line[1]}{$temp_line[2]}{'high-coverage'}++;} if ($temp_line[5] == 0) { push (@ {$zerofeature{$temp_line[0]}{$temp_line[1]}{$temp_line[2]}{'zero-coverage'} }, $temp_line[1]+$temp_line[4]-1);} $average_cov=$average_cov+$temp_line[5];$nr_positions++;} } print "$prev_chr\t","$prev_start\t","$prev_end\t",$average_cov/$nr_positions,"\t"; if ($feature{$prev_chr}{$prev_start}{$prev_end}{'high-coverage'}) { print $feature{$prev_chr}{$prev_start}{$prev_end}{'high-coverage'}/$nr_positions, "\t";} else {print "0\t";} if ($zerofeature{$prev_chr}{$prev_start}{$prev_end}{'zero-coverage'}) { print scalar(@ {$zerofeature{$prev_chr}{$prev_start}{$prev_end}{'zero-coverage'} }), "\t"; for (my $i=0;$i<scalar(@ {$zerofeature{$prev_chr}{$prev_start}{$prev_end}{'zero-coverage'}});$i++) { print "$zerofeature{$prev_chr}{$prev_start}{$prev_end}{'zero-coverage'}[$i];";} print "\tdepth_pos\n"; } else {print "0\t","Na\tdepth_pos\n";} last;' ?.$outSampleDirectory."/".$infile.$infileEnding."_coverageBed_depth_pos "; #InFile using the just created depth_pos file located in the outSampleDirectory
	    print CAL_COV "> ".$outSampleDirectory."/".$infile.$outfileEnding."_coverageBed_depth_pos_collapsed", "\n\n"; #OutFile
	    
	    #Concatenate to 1 file to be able to include info from _coverageBed file
	    print CAL_COV "#Concatenate to 1 file to be able to include info from _coverageBed file", "\n";
	    print CAL_COV "cat ";
	    print CAL_COV $outSampleDirectory."/".$infile.$infileEnding."_coverageBed_depth_pos_collapsed "; #InFile
	    print CAL_COV $outSampleDirectory."/".$infile.$infileEnding."_coverageBed "; #InFile
	    print CAL_COV "> ".$outSampleDirectory."/".$infile.$outfileEnding."_coverageBed_merged_temp",  "\n\n"; #OutFile
	    
            #Sort on chr and then numerically on start position. NOTE makes the two lines from each file end up next to each other. The line order is preserved unless the feature annotation is "-", then it is reversed (exception handled by the next perl one-liner) 
	    print CAL_COV "#Sort on chr and then numerically on start position.\n";
	    print CAL_COV "sort ";
	    print CAL_COV "-k1,1 -k2,2n "; #Sort on chr and then numerically on start position.
	    print CAL_COV $outSampleDirectory."/".$infile.$infileEnding."_coverageBed_merged_temp "; #InFile
	    print CAL_COV "> ".$outSampleDirectory."/".$infile.$outfileEnding."_coverageBed_merged",  "\n\n"; #OutFile
	    
	    #Collpase the two lines from coverageBed_depth_pos_collapsed and _coverageBed
	    print CAL_COV "#Collpase the two lines from coverageBed_depth_pos_collapsed and _coverageBed", "\n";
	    print CAL_COV q?perl -nae ' print "#Chr\tStart\tStop\tOverlapping_Reads\tNon-zero_Coverage_Bases\tFeature_Length(Nucleotides)\tAverage_Coverage\tFraction_Non-zero_Coverage_Bases\tFraction_Ten_Coverage_Bases\tNr_Zero_Coverage_Bases\tRelative_position_for_Zero_Coverage_Bases\n";chomp($_);my @prev_line=split("\t",$_);my @temp_line; while (<>) { chomp($_); @temp_line = split("\t",$_); if ($prev_line[0]  && ($prev_line[0] eq $temp_line[0]) && ($prev_line[1] == $temp_line[1]) && ($prev_line[2] == $temp_line[2])) { unless ($prev_line[7] eq "depth_pos") { $temp_line[3]=~s/\./\,/;$prev_line[4]=~s/\./\,/; print $prev_line[0],"\t", $prev_line[1],"\t",$prev_line[2],"\t",$prev_line[4],"\t",$prev_line[5],"\t",$prev_line[6],"\t",$temp_line[3],"\t","$prev_line[7]\t","$temp_line[4]\t","$temp_line[5]\t","$temp_line[6]\n";} else { $prev_line[3]=~s/\./\,/;$temp_line[4]=~s/\./\,/; print $temp_line[0],"\t", $temp_line[1],"\t",$temp_line[2],"\t",$temp_line[4],"\t",$temp_line[5],"\t",$temp_line[6],"\t",$prev_line[3],"\t","$temp_line[7]\t","$prev_line[4]\t","$prev_line[5]\t","$prev_line[6]\n";} } else { @prev_line = @temp_line;} }last;' ?.$outSampleDirectory."/".$infile.$infileEnding."_coverageBed_merged "; #InFile using the just created sorted _coverageBed_merged file located in the outSampleDirectory
	    print CAL_COV "> ".$outSampleDirectory."/".$infile.$outfileEnding."_target_coverage.txt", "\n\n"; #OutFile
	    
	    #Add chr to entry to enable comparison to Gene Db
	    print CAL_COV "#Add chr to entry to enable later comparison to Gene Db", "\n";
	    print CAL_COV q?perl -i -p -e ' if($_=~/^#/) {} else {s/^(.+)/chr$1/g }' ?.$outSampleDirectory."/".$infile.$outfileEnding."_target_coverage.txt", "\n\n";
            #Removal of files which the necessary info has been extracted from
	    print CAL_COV "#Removal of files which the necessary info has been extracted from\n";
	    print CAL_COV "rm ";
	    print CAL_COV $outSampleDirectory."/".$infile.$outfileEnding."_coverageBed", "\n\n";
	    
	    print CAL_COV "rm ";
	    print CAL_COV $outSampleDirectory."/".$infile.$outfileEnding."_coverageBed_depth_pos", "\n\n";
	    
	    print CAL_COV "rm ";
	    print CAL_COV $outSampleDirectory."/".$infile.$outfileEnding."_coverageBed_depth_pos_collapsed", "\n\n";
	    
	    print CAL_COV "rm ";
	    print CAL_COV $outSampleDirectory."/".$infile.$outfileEnding."_coverageBed_merged_temp", "\n\n";
	    
	    print CAL_COV "rm ";
	    print CAL_COV $outSampleDirectory."/".$infile.$outfileEnding."_coverageBed_merged", "\n\n";
	    
###
#Create target file with EnsembleGeneID (Required for coverage calculation in rank_script)
###
	    
	    my @targetCoverageDbFiles = ($scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/coverageReport/".$infile.$infileEnding."_coverage_target_db_master.txt"); #Db master files	    
	    my @targetCoverageFiles = ($scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/coverageReport/".$infile.$infileEnding."_target_coverage.txt"); 
	    
#Create db master template 
	    print CAL_COV "#Add GeneName to Coverage Report", "\n";
	    for (my $dbFileCounter=0;$dbFileCounter<scalar(@targetCoverageDbFiles);$dbFileCounter++) { 
		open (TARCOV, ">".$targetCoverageDbFiles[$dbFileCounter]) or die "Can't write to ".$targetCoverageDbFiles[$dbFileCounter].": $!\n";
		print TARCOV "outcolumns=0_0,0_1,0_2,0_3,0_4,0_5,0_6,0_7,0_8,0_9,0_10,1_4\n"; #Order of outcolumns in outfile
		print TARCOV "outheaders=Chr,Start,Stop,Overlapping_Reads,Non-zero_Coverage_Bases,Feature_Length(Nucleotides),Average_Coverage,Fraction_Non-zero_Coverage_Bases,Fraction_Ten_Coverage_Bases,Nr_Zero_Coverage_Bases,Relative_position_for_Zero_Coverage_Bases,Ensembl_GeneID\n"; #Order and header content in outfile
		print TARCOV $targetCoverageFiles[$dbFileCounter],"\t".'\t'."\t0,1,2\t0\texact\t0,1,2,3,4,5,6,7,8,9,10\tsmall","\n";
		print TARCOV $scriptParameter{'referencesDir'}."/mart_export_Ensembl_GeneID_key_cleaned_noblanks_chr.txt\t".'\t'."\t0,1,2\t0\trange\t4\tsmall", "\n";
		close(TARCOV);
		
#Add GeneNameID to Coverage Report
		print CAL_COV "perl ";
		print CAL_COV $scriptParameter{'inScriptDir'}."/intersectCollect.pl ";
		print CAL_COV "-o ".$targetCoverageFiles[$dbFileCounter]." "; #OutFile
		print CAL_COV "-db ".$targetCoverageDbFiles[$dbFileCounter]." "; #Db master file (InFile(s)) 
		print CAL_COV "-prechr 1", "\n\n"; #Chromosome prefix
	    }
	}
    }
    print CAL_COV "wait", "\n\n";
    
    close(CAL_COV);
    if ($scriptParameter{'pCalculateCoverage'} == 1) {
	#ParallelSampleIDSubmitJob($sampleID,$filename,"all");
	#FIDSubmitJob($sampleID,$familyID,1,"MAIN",$filename,0);
	FIDSubmitJob($sampleID,$familyID,1,"Coverage",$filename,0);
    }
    return;
}

sub PicardToolsMarkDuplicates { 
#Mark duplicated reads using PicardTools MarkDuplicates in files generated from alignment (sorted, merged)

    my $sampleID = $_[0];
    my $aligner = $_[1]; 
    
    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/$aligner/info;`; #Creates the aligner folder and info data file directory
    `mkdir -p $scriptParameter{'outScriptDir'}/$sampleID/$aligner;`; #Creates the aligner script directory
    if ($scriptParameter{'pPicardToolsMarkduplicates'} == 1) {
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/".$aligner."/picardTools_markdup_".$sampleID.".";
    }
    elsif ($scriptParameter{'pPicardToolsMarkduplicates'} == 2) {
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/".$aligner."/dry_run_picardTools_markdup_".$sampleID.".";
	print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";
    }
    Checkfnexists($filename, $fnend);

###Info and Logg
    print STDOUT "Creating sbatch script PicardToolsMarkDuplicates and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script PicardToolsMarkDuplicates and writing script file(s) to: ".$filename, "\n";
    print STDOUT "Sbatch script PicardToolsMarkDuplicates data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner, "\n";print MASTERL "Sbatch script PicardToolsMarkDuplicates data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner, "\n";

    my $time = ceil(3*scalar( @{ $infilesBothStrandsNoEnding{$sampleID} })); #One full lane on Hiseq takes approx. 3 h to process, round up to nearest full hour.
    
    open (PT_MDUP, ">".$filename) or die "Can't write to ".$filename.": $!\n";
    
    print PT_MDUP "#! /bin/bash -l", "\n";
    print PT_MDUP "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
    print PT_MDUP "#SBATCH -p node -n ".$scriptParameter{'maximumCores'}, "\n";
    print PT_MDUP "#SBATCH -C thin", "\n";
    
    if ($scriptParameter{'pPicardToolsMergeSamFiles'} eq 0) { #If No merge has been performed then time requirements goes down
	print PT_MDUP "#SBATCH -t 3:00:00", "\n";	
    }
    else{
	print PT_MDUP "#SBATCH -t ".$time.":00:00", "\n";	
    }	
    
    print PT_MDUP "#SBATCH -J PT_MD_".$sampleID."_".$aligner, "\n";
    if ($scriptParameter{'pPicardToolsMarkduplicates'} == 1) {
	print PT_MDUP "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/picardTools_markdup_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print PT_MDUP "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/picardTools_markdup_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }
    elsif ($scriptParameter{'pPicardToolsMarkduplicates'} == 2) { #Dry run
	print PT_MDUP "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/dry_run_picardTools_markdup_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print PT_MDUP "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/dry_run_picardTools_markdup_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }

    unless ($scriptParameter{'email'} eq 0) {
	print PT_MDUP "#SBATCH --mail-type=END", "\n";
	print PT_MDUP "#SBATCH --mail-type=FAIL", "\n";
	print PT_MDUP "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
    }
    
    print PT_MDUP 'echo "Running on: $(hostname)"',"\n\n";
    
    my $inSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner;
    my $outSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner;
    my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pPicardToolsMergeSamFiles'}{'fileEnding'};
    my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pPicardToolsMarkduplicates'}{'fileEnding'};
    my ($infile, $PicardToolsMergeSwitch) = CheckIfMergedFiles($sampleID);
    my $coreCounter=1;

###
#PicardToolsMarkDuplicates
###
    
    if ($PicardToolsMergeSwitch == 1) { #Files was merged previously

	print PT_MDUP "java -Xmx4g ";
	print PT_MDUP "-jar ".$scriptParameter{'picardToolsPath'}."/MarkDuplicates.jar ";
	print PT_MDUP "ASSUME_SORTED=true ";
	print PT_MDUP "REMOVE_DUPLICATES=false ";
	print PT_MDUP "VALIDATION_STRINGENCY=LENIENT ";
	print PT_MDUP "INPUT=".$inSampleDirectory."/".$infile.$infileEnding.".bam "; #InFile
	print PT_MDUP "OUTPUT=".$outSampleDirectory."/".$infile.$outfileEnding.".bam "; #OutFile
	print PT_MDUP "METRICS_FILE=".$outSampleDirectory."/".$infile.$outfileEnding."metric ", "\n\n"; #Metric file 
	
        #SamTools index on just created _sorted(_merged)_pmd.bam
	
	print PT_MDUP "samtools index ";
	print PT_MDUP $outSampleDirectory."/".$infile.$outfileEnding.".bam ","\n\n";
    }
    else { #No merged files
	for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{$sampleID} });$infileCounter++) { #For all files from independent of merged or not
	    
	    if ($infileCounter eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} cores
		
		print PT_MDUP "wait", "\n\n";
		$coreCounter=$coreCounter+1;
	    }
	    my $infile = $infilesLaneNoEnding{$sampleID}[$infileCounter];
	    
	    print PT_MDUP "java -Xmx4g ";
	    print PT_MDUP "-jar ".$scriptParameter{'picardToolsPath'}."/MarkDuplicates.jar ";
	    print PT_MDUP "ASSUME_SORTED=true ";
	    print PT_MDUP "REMOVE_DUPLICATES=false ";
	    print PT_MDUP "VALIDATION_STRINGENCY=LENIENT ";
	    print PT_MDUP "INPUT=".$inSampleDirectory."/".$infile.$infileEnding.".bam "; #InFile
	    print PT_MDUP "OUTPUT=".$outSampleDirectory."/".$infile.$outfileEnding.".bam "; #OutFile
	    print PT_MDUP "METRICS_FILE=".$outSampleDirectory."/".$infile.$outfileEnding."metric &","\n\n"; #Metric file  
	}    
	
	print PT_MDUP "wait", "\n\n";

        #SamTools index on just created _sorted(_merged)_pmd.bam
	for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{$sampleID} });$infileCounter++) { #For all files from alignment
	    
	    if ($infileCounter eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} cores
		
		print PT_MDUP "wait", "\n\n";
		$coreCounter=$coreCounter+1;
	    }
	    
	    my $infile = $infilesLaneNoEnding{$sampleID}[$infileCounter];
	    
	    print PT_MDUP "samtools index ";
	    print PT_MDUP $outSampleDirectory."/".$infile.$outfileEnding.".bam &","\n\n"; #Just created dedupped inFile located in outSamplesDirectory
	    print PT_MDUP "wait", "\n\n";	    
	}
    }
    close(PT_MDUP);
    if ($scriptParameter{'pPicardToolsMarkduplicates'} == 1) {
	#ParallelSampleIDSubmitJob($sampleID,$filename,"all");
	FIDSubmitJob($sampleID,$familyID,1,"MAIN",$filename,0);
    }
    return;
}

sub PicardToolsMerge { 
#Merges all bam files using PicardTools MergeSamFiles within each sampleid and files generated previously (option if provided with '-picardToolsMergeSamFilesPrevious'). The merged files have to be sorted before attempting to merge.
 
    my $sampleID = $_[0];
    my $aligner = $_[1];
    my $fileEnding = $_[2]; 
    
    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/$aligner/info;`; #Creates the aligner folder and info data file directory
    `mkdir -p $scriptParameter{'outScriptDir'}/$sampleID/$aligner;`; #Creates the aligner folder and info data file directory
    if ($scriptParameter{'pPicardToolsMergeSamFiles'} == 1) {
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/".$aligner."/picardTools_merge_".$sampleID.".";
    }
    elsif ($scriptParameter{'pPicardToolsMergeSamFiles'} == 2) { #Dry run
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/".$aligner."/dry_run_picardTools_merge_".$sampleID.".";
	print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";
    }
    Checkfnexists($filename, $fnend);

###Info and Logg
    print STDOUT "Creating sbatch script PicardToolsMerge and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script PicardToolsMerge and writing script file(s) to: ".$filename, "\n";
    print STDOUT "Sbatch script PicardToolsMerge data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner, "\n";print MASTERL "Sbatch script PicardToolsMerge data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner, "\n";
    
    open (PT_MERGE, ">".$filename) or die "Can't write to ".$filename.": $!\n";
    
    print PT_MERGE "#! /bin/bash -l", "\n";
    print PT_MERGE "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
    print PT_MERGE "#SBATCH -p node -n ".$scriptParameter{'maximumCores'}, "\n";
    print PT_MERGE "#SBATCH -C thin", "\n";	
    print PT_MERGE "#SBATCH -t 20:00:00", "\n";
    
    print PT_MERGE "#SBATCH -J PT_Me_".$sampleID."_".$aligner, "\n";
    if ($scriptParameter{'pPicardToolsMergeSamFiles'} == 1) {
	print PT_MERGE "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/picardTools_merge_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print PT_MERGE "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/picardTools_merge_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }
    elsif ($scriptParameter{'pPicardToolsMergeSamFiles'} == 2) { #Dry run
	print PT_MERGE "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/dry_run_picardTools_merge_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print PT_MERGE "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/dry_run_picardTools_merge_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }
    unless ($scriptParameter{'email'} eq 0) {
	print PT_MERGE "#SBATCH --mail-type=END", "\n";
	print PT_MERGE "#SBATCH --mail-type=FAIL", "\n";
	print PT_MERGE "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
    }
    
    print PT_MERGE 'echo "Running on: $(hostname)"',"\n\n";
   
    my $inSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner;
    my $outSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner;
    my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pSamToolsSort'}{'fileEnding'};
    my $outfileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pPicardToolsMergeSamFiles'}{'fileEnding'};

    if (scalar( @{ $infilesLaneNoEnding{$sampleID} }) > 1) { #Check that we have something to merge and then merge current files before merging with previously merged files

	for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{$sampleID} });$infileCounter++) { #For all files from 

	    my $infile = $infilesLaneNoEnding{$sampleID}[$infileCounter];

	    if ($infileCounter eq 0) {

		print PT_MERGE "java -Xmx4g ";
		print PT_MERGE "-jar ".$scriptParameter{'picardToolsPath'}."/MergeSamFiles.jar ";
		print PT_MERGE "TMP_DIR=".$scriptParameter{'PicardToolsMergeTempDirectory'}." "; #Temp Directory
		print PT_MERGE "OUTPUT=".$outSampleDirectory."/".$sampleID."_lanes_", @{ $lane{$sampleID} } ,$outfileEnding.".bam "; #OutFile
	    }
	    
	    print PT_MERGE "INPUT=".$inSampleDirectory."/".$infile.$infileEnding.".bam "; #InFile
	}
	print PT_MERGE "\n\n";

	print PT_MERGE "samtools index ";
	print PT_MERGE $outSampleDirectory."/".$sampleID."_lanes_", @{ $lane{$sampleID} } ,$outfileEnding.".bam", "\n\n"; #InFile using just created merged outfile
	print PT_MERGE "wait", "\n\n";

	print PT_MERGE "#Remove Temp Directory\n\n";
	print PT_MERGE "rm ";
	print PT_MERGE "-rf ".$scriptParameter{'PicardToolsMergeTempDirectory'}, "\n\n"; #Remove Temp Directory
    }
    if ( ($sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'picardToolsMergeSamFilesPrevious'} == 1) && (scalar( @{ $infilesLaneNoEnding{$sampleID} }) > 1) ) { #merge previously merged files with merged files generated this run
	
	for (my $mergeFileCounter=0;$mergeFileCounter<scalar(@picardToolsMergeSamFilesPrevious);$mergeFileCounter++) {
	    
	    if ($picardToolsMergeSamFilesPrevious[$mergeFileCounter] =~ /$sampleID/) { #Look for sampleID in previously generated file to be merged with current run to be able to merge correct files
		if ($picardToolsMergeSamFilesPrevious[$mergeFileCounter] =~ /lane(\d+)|s_(\d+)/) { #Look for lanes_ or lane\d in previously generated file to be merged with current run to be able to extract previous lanes
		    
		    my $mergeLanes; if($1) {$mergeLanes = $1;} else {$mergeLanes = $2;} #Make sure to always supply lanes from previous regexp		    

		    print PT_MERGE "java -Xmx4g ";
		    print PT_MERGE "-jar ".$scriptParameter{'picardToolsPath'}."/MergeSamFiles.jar ";
		    print PT_MERGE "TMP_DIR=".$scriptParameter{'PicardToolsMergeTempDirectory'}." "; #Temp directory
		    print PT_MERGE "OUTPUT=".$outSampleDirectory."/".$sampleID."_lanes_".$mergeLanes, @{ $lane{$sampleID} } ,$outfileEnding.".bam "; #OutFile
		    print PT_MERGE "INPUT=".$inSampleDirectory."/".$sampleID."_lanes_", @{ $lane{$sampleID} } ,$outfileEnding.".bam "; #InFile
		    print PT_MERGE "INPUT=".$picardToolsMergeSamFilesPrevious[$mergeFileCounter], "\n\n"; #$mergeLanes contains lane info on previous merge, $infilesLaneNoEnding{$sampleID}[0] uses @RG for very first .bam file to include read group for subsequent merges. Complete path. 
		    
		    print PT_MERGE "samtools index ";
		    print PT_MERGE $outSampleDirectory."/".$sampleID."_lanes_".$mergeLanes, @{ $lane{$sampleID} } ,$outfileEnding.".bam ","\n\n"; #InFile

		    print PT_MERGE "#Remove Temp Directory\n\n";
		    print PT_MERGE "rm ";
		    print PT_MERGE "-rf ".$scriptParameter{'PicardToolsMergeTempDirectory'}, "\n\n"; #Remove Temp Directory
		}
	    }
	}
    }
    elsif ($sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'picardToolsMergeSamFilesPrevious'} == 1) { #merge previously merged files with single file generated this run
	
	for (my $mergeFileCounter=0;$mergeFileCounter<scalar(@picardToolsMergeSamFilesPrevious);$mergeFileCounter++) {
	    
	    if ($picardToolsMergeSamFilesPrevious[$mergeFileCounter] =~ /lane(\d+)|s_(\d+)/) { #Look for lanes_ or lane\d in previously generated file to be merged with current run to be able to extract previous lanes
		
		my $mergeLanes; if($1) {$mergeLanes = $1;} else {$mergeLanes = $2;} #Make sure to always supply lanes from previous regexp
		my $infile = $infilesLaneNoEnding{$sampleID}[0]; #Can only be 1 element in array due to previous if statement		    
		
		print PT_MERGE "java -Xmx4g ";
		print PT_MERGE "jar ".$scriptParameter{'picardToolsPath'}."/MergeSamFiles.jar ";
		print PT_MERGE "TMP_DIR=".$scriptParameter{'PicardToolsMergeTempDirectory'}." "; #Temp Directory
		print PT_MERGE "OUTPUT=".$outSampleDirectory."/".$sampleID."_lanes_".$mergeLanes, @{ $lane{$sampleID} } ,$outfileEnding.".bam "; #OutFile
		print PT_MERGE "INPUT=".$inSampleDirectory."/".$infile.$infileEnding.".bam "; #InFile
		print PT_MERGE "INPUT=".$picardToolsMergeSamFilesPrevious[$mergeFileCounter],"\n\n"; #$mergeLanes contains lane info on previous merge, $infilesLaneNoEnding{$sampleID}[0] uses @RG for very first .bam file to include read group for subsequent merges. Complete path. 
		
		print PT_MERGE "samtools index ";
		print PT_MERGE $outSampleDirectory."/".$sampleID."_lanes_".$mergeLanes, @{ $lane{$sampleID} } ,$outfileEnding.".bam", "\n\n"; #InFile
		
		print PT_MERGE "#Remove Temp Directory\n\n";
		print PT_MERGE "rm ";
		print PT_MERGE "-rf ".$scriptParameter{'PicardToolsMergeTempDirectory'}, "\n\n"; #Remove Temp Directory
	    }
	}
    }
    close(PT_MERGE);
    if ($scriptParameter{'pPicardToolsMergeSamFiles'} == 1) {
	#ParallelSampleIDSubmitJob($sampleID,$filename,"all");
	FIDSubmitJob($sampleID,$familyID,1,"MAIN",$filename, 0);
    }
    return;
}

sub SamToolsSortIndex { 
#Sort and indexes bam files using samtools sort and samtools index

    my $sampleID = $_[0];
    my $aligner = $_[1];

    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/$aligner/info;`; #Creates the aligner folder and info data file directory
    `mkdir -p $scriptParameter{'outScriptDir'}/$sampleID/$aligner;`; #Creates the aligner folder and info data file directory

    my $sbatchScriptTracker=0;
    my $time=0;
    my $infileSize;
    for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{$sampleID} });$infileCounter++) { #For all files

	
	if ($scriptParameter{'pSamToolsSort'} ==1) {
	    $filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/".$aligner."/samToolsSort_index_".$infilesLaneNoEnding{$sampleID}[$infileCounter].".";
	}
	elsif ($scriptParameter{'pSamToolsSort'} ==2) {
	    $filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/".$aligner."/dry_run_samToolsSort_index_".$infilesLaneNoEnding{$sampleID}[$infileCounter].".";
	    print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";
	}
	if ($infile{$sampleID}[$infileCounter] =~/.fastq.gz$/) { #Files are already gz and presently the scalar for compression has not been investigated. Therefore no automatic time allocation can be performed.
	    if ($scriptParameter{'wholeGenomeSequencing'} == 1) {
		$time = 25;  
	    }
	    else {
		$time = 15;
	    }
	}
	else { #Files are in fastq format
	    $infileSize = -s $indirpath{$sampleID}."/".$infile{$sampleID}[$infileCounter+$sbatchScriptTracker]; # collect .fastq file size to enable estimation of time required for sort & index, +$sbatchScriptTracker for syncing multiple infiles per sampleID. Hence, filesize will be calculated on read1 (should not matter).	   
	    
	    if ($scriptParameter{'pMosaikBuild'} || $scriptParameter{'pMosaikAlign'} || ($scriptParameter{'aligner'} eq "mosaik")) {
		$time = ceil($infileSize/(1700000*60*60)); #1700000 is a constant calculated from the filesize and time needed for procesing in samtools-0.1.12-10 sort and index and 60*60 is to scale to hours.
	    }
	    if ($scriptParameter{'pBwaAln'} || $scriptParameter{'pBwaSampe'} || ($scriptParameter{'aligner'} eq "bwa")) {
		$time = ceil($infileSize/(1700000*60*60)); #1700000 is a constant calculated from the filesize and time needed for procesing in samtools-0.1.12-10 sort and index and 60*60 is to scale to hours.	    
	    }
	}
	
	Checkfnexists($filename, $fnend);
	
###Info and Logg
	print STDOUT "Creating sbatch script SamTools sort & index and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script SamTools sort & index and writing script file(s) to: ".$filename, "\n";
	print STDOUT "Sbatch script SamTools sort & index data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner, "\n";print MASTERL "Sbatch script SamTools sort & index data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner, "\n";
	
	open (ST_SI, ">".$filename) or die "Can't write to ".$filename.": $!\n";
	
	print ST_SI "#! /bin/bash -l", "\n";
	print ST_SI "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
	print ST_SI "#SBATCH -p node -n 1", "\n";
	print ST_SI "#SBATCH -C thin", "\n";	
	print ST_SI "#SBATCH -t ".$time.":00:00", "\n";
	
	print ST_SI "#SBATCH -J ST_SI_".$sampleID."_".$aligner, "\n";
	if ($scriptParameter{'pSamToolsSort'} ==1) {
	    print ST_SI "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/samToolsSort_index_".$infilesLaneNoEnding{$sampleID}[$infileCounter].".".$fnt.".stderr.txt", "\n";
	    print ST_SI "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/samToolsSort_index_".$infilesLaneNoEnding{$sampleID}[$infileCounter].".".$fnt.".stdout.txt", "\n";
	}
	elsif ($scriptParameter{'pSamToolsSort'} ==1) {
	    print ST_SI "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/dry_run_samToolsSort_index_".$infilesLaneNoEnding{$sampleID}[$infileCounter].".".$fnt.".stderr.txt", "\n";
	    print ST_SI "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner."/info/dry_run_samToolsSort_index_".$infilesLaneNoEnding{$sampleID}[$infileCounter].".".$fnt.".stdout.txt", "\n";
	}
    
	unless ($scriptParameter{'email'} eq 0) {
	    print ST_SI "#SBATCH --mail-type=END", "\n";
	    print ST_SI "#SBATCH --mail-type=FAIL", "\n";
	    print ST_SI "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
	}
	
	print ST_SI 'echo "Running on: $(hostname)"',"\n\n";
    
###	
#SamTools Sort
###	
	my $inSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner;
	my $outSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/".$aligner;
	my $infile = $infilesLaneNoEnding{$sampleID}[$infileCounter];
	my $infileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'pSamToolsSort'}{'fileEnding'};

	print ST_SI "samtools sort ";
	print ST_SI $inSampleDirectory."/".$infile.".bam ".$outSampleDirectory."/".$infile.$infileEnding, "\n\n"; #InFile. SamTools sort adds .bam ending
	print ST_SI "wait", "\n\n";
###	
#SamTools Index
###	
	print ST_SI "samtools index ";
	print ST_SI $inSampleDirectory."/".$infile.$infileEnding.".bam", "\n\n"; #InFile	
	
	close(ST_SI);
	if ($scriptParameter{'pSamToolsSort'} ==1) {
	    #ParallelSampleIDSubmitJob($sampleID,$filename,$infilesLaneNoEnding{$sampleID}[$infileCounter]);
	    FIDSubmitJob($sampleID,$familyID,4,"MAIN",$filename, $sbatchScriptTracker);
	}
	$sbatchScriptTracker++; 
    }
    return;
}

sub BWA_Sampe {
#Alignments of BWA Aln index reads using BWA sampe
    
    my $sampleID = $_[0];

    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/bwa/info;`; #Creates the bwa folder and info data file directory
    `mkdir -p $scriptParameter{'outScriptDir'}/$sampleID/bwa;`; #Creates the bwa script directory
    
    my $sbatchScriptTracker=0;
    my $time=0;
    my $infileSize;
    for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{$sampleID} });$infileCounter++) { #For all files from BWA aln but process in the same command i.e. both reads per align call
	if ($infile{$sampleID}[$infileCounter] =~/.fastq.gz$/) { #Files are already gz and presently the scalar for compression has not been investigated. Therefore no automatic time allocation can be performed.
	    if ($scriptParameter{'wholeGenomeSequencing'} == 1) {
		$time = 60;  
	    }
	    else {
		$time = 30;
	    }
	}
	else { #Files are in fastq format	
	    $infileSize = -s $indirpath{$sampleID}."/".$infile{$sampleID}[$infileCounter+$sbatchScriptTracker]; # collect .fastq file size to enable estimation of time required for aligning, +1 for syncing multiple infiles per sampleID. Hence, filesize will be calculated on read2 (should not matter).
	    $time = ceil(($infileSize/238)/(3000*60*60)); #238 is a scalar estimating the number of reads depending on filesize. 3500 is the number of reads/s in Bwa_sampe-0.6.1 plus samtools-0.1.12-10 view sam to bam conversion and 60*60 is to scale to hours. (4600 BWA-0.5.9)
	}
	if ($scriptParameter{'pBwaSampe'} == 1) {
	    $filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/bwa/bwa_sampe_".$infilesLaneNoEnding{$sampleID}[$infileCounter].".";	
	}
	elsif ($scriptParameter{'pBwaSampe'} == 2) { #Dry run
	    $filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/bwa/dry_run_bwa_sampe_".$infilesLaneNoEnding{$sampleID}[$infileCounter].".";
	    print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";
	}
	Checkfnexists($filename, $fnend);

###Info and Logg
	print STDOUT "Creating sbatch script BWA_Sampe and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script BWA_Sampe and writing script file(s) to: ".$filename, "\n";
	print STDOUT "Sbatch script BWA_Sampe data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$scriptParameter{'aligner'}, "\n";print MASTERL "Sbatch script BWA_Sampe data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$scriptParameter{'aligner'}, "\n";
	
	open (BWA_SA, ">".$filename) or die "Can't write to ".$filename.": $!\n";
	
	print BWA_SA "#! /bin/bash -l", "\n";
	print BWA_SA "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
	print BWA_SA "#SBATCH -p node -n ".$scriptParameter{'maximumCores'}, "\n";
	print BWA_SA "#SBATCH -C thin", "\n";
	print BWA_SA "#SBATCH -t ".$time.":00:00", "\n";
	print BWA_SA "#SBATCH -J BWA_Sa_".$sampleID, "\n";
	if ($scriptParameter{'pBwaSampe'} == 1) {
	    print BWA_SA "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/bwa/info/bwa_sampe_".$infilesLaneNoEnding{$sampleID}[$infileCounter].".".$fnt.".stderr.txt", "\n";
	    print BWA_SA "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/bwa/info/bwa_sampe_".$infilesLaneNoEnding{$sampleID}[$infileCounter].".".$fnt.".stdout.txt", "\n";
	}
	elsif ($scriptParameter{'pBwaSampe'} == 2) {
	    print BWA_SA "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/bwa/info/dry_run_bwa_sampe_".$infilesLaneNoEnding{$sampleID}[$infileCounter].".".$fnt.".stderr.txt", "\n";
	    print BWA_SA "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/bwa/info/dry_run_bwa_sampe_".$infilesLaneNoEnding{$sampleID}[$infileCounter].".".$fnt.".stdout.txt", "\n";
	}
	
	unless ($scriptParameter{'email'} eq 0) {	    
	    print BWA_SA "#SBATCH --mail-type=END", "\n";
	    print BWA_SA "#SBATCH --mail-type=FAIL", "\n";
	    print BWA_SA "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
	}
	
	print BWA_SA 'echo "Running on: $(hostname)"',"\n\n";
	
	my $BWAinSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/bwa";
	my $FASTQinSampleDirectory = $indirpath{$sampleID};
	my $outSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/bwa";
	my $infile = $infile{$sampleID}[$infileCounter+$sbatchScriptTracker]; #For required .fastq file
	my $infile2 = $infile{$sampleID}[ ($infileCounter+$sbatchScriptTracker+1)]; # #For required .fastq file (Paired read)   

#BWA Sampe	
	print BWA_SA "bwa sampe ";
	print BWA_SA "-r ".'"@RG\tID:'.$infilesBothStrandsNoEnding{$sampleID}[$infileCounter+$sbatchScriptTracker].'\tSM:'.$sampleID.'\tPL:ILLUMINA" '.$scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #read group header line
	print BWA_SA $BWAinSampleDirectory."/".$infilesBothStrandsNoEnding{$sampleID}[$infileCounter+$sbatchScriptTracker].".sai "; #Read 1
	print BWA_SA $BWAinSampleDirectory."/".$infilesBothStrandsNoEnding{$sampleID}[ ($infileCounter+$sbatchScriptTracker+1) ].".sai "; #Read 2
	print BWA_SA $FASTQinSampleDirectory."/".$infile." "; #Fastq read 1
	print BWA_SA $FASTQinSampleDirectory."/".$infile2." "; #Fastq read 2
	print BWA_SA "> ".$outSampleDirectory."/".$infilesLaneNoEnding{$sampleID}[$infileCounter].".sam", "\n\n"; #Outfile (SAM)

#Convert SAM to BAM using samTools view	
	print BWA_SA "samtools view -bS ".$BWAinSampleDirectory."/".$infilesLaneNoEnding{$sampleID}[$infileCounter].".sam "; #Infile (SAM)
	print BWA_SA "> ".$outSampleDirectory."/".$infilesLaneNoEnding{$sampleID}[$infileCounter].".bam", "\n\n"; #Outfile (BAM)

#Remove SAM file
	print BWA_SA "Removing temporary SAM-file\n";
	print BWA_SA "rm ".$BWAinSampleDirectory."/".$infilesLaneNoEnding{$sampleID}[$infileCounter].".sam";
		
	close(BWA_SA);
	if ($scriptParameter{'pBwaSampe'} == 1) {
	    #ParallelSampleIDSubmitJob($sampleID,$filename,$infilesLaneNoEnding{$sampleID}[$infileCounter]);
	    FIDSubmitJob($sampleID,$familyID,3,"MAIN",$filename, $sbatchScriptTracker);
	}
	$sbatchScriptTracker++;
    }
    return;
}

sub BWA_Aln {
#Generates BWA aln index on fastq files
    
    my $sampleID = $_[0];

    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/bwa/info;`; #Creates the bwa folder and info data file directory
    `mkdir -p $scriptParameter{'outScriptDir'}/$sampleID/bwa;`; #Creates the bwa script directory
    if ($scriptParameter{'pBwaAln'} == 1) {
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/bwa/bwa_aln_".$sampleID.".";
    }
    elsif ($scriptParameter{'pBwaAln'} == 2) {
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/bwa/dry_run_bwa_aln_".$sampleID.".";
	print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";
    }
    Checkfnexists($filename, $fnend);

###Info and Logg
    print STDOUT "Creating sbatch script BWA_Aln and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script BWA_Aln and writing script file(s) to: ".$filename, "\n";
    print STDOUT "Sbatch script BWA_Aln data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$scriptParameter{'aligner'}, "\n";print MASTERL "Sbatch script BWA_Aln data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$scriptParameter{'aligner'}, "\n";
    
    open (BWA_AL, ">".$filename) or die "Can't write to ".$filename.": $!\n";
    
    my $time = ceil(2.5*scalar( @{ $infilesLaneNoEnding{$sampleID} })); #One full lane on Hiseq takes approx. 2,5 h for BWA_Aln to process, round up to nearest full hour.
    
    print BWA_AL "#! /bin/bash -l", "\n";
    print BWA_AL "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
    print BWA_AL "#SBATCH -p node -n ".$scriptParameter{'maximumCores'}, "\n";
    print BWA_AL "#SBATCH -C thin", "\n";
    print BWA_AL "#SBATCH -t ".$time.":00:00", "\n";
    print BWA_AL "#SBATCH -J BWA_Al_".$sampleID, "\n";
    if ($scriptParameter{'pBwaAln'} == 1) {
	print BWA_AL "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/bwa/info/bwa_aln_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print BWA_AL "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/bwa/info/bwa_aln_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }
    elsif ($scriptParameter{'pBwaAln'} == 2) { #Dry run
	print BWA_AL "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/bwa/info/dry_run_bwa_aln_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print BWA_AL "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/bwa/info/dry_run_bwa_aln_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }
    unless ($scriptParameter{'email'} eq 0) {
	print BWA_AL "#SBATCH --mail-type=END", "\n";
	print BWA_AL "#SBATCH --mail-type=FAIL", "\n";
	print BWA_AL "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
    }
    
    print BWA_AL 'echo "Running on: $(hostname)"',"\n\n";
    
    my $inSampleDirectory =  $indirpath{$sampleID};
    my $outSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/bwa";
    my $coreCounter=1;    
    for (my $infileCounter=0;$infileCounter<scalar( @{ $infile{$sampleID} });$infileCounter++) {
	
	if ($infileCounter eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} cores
	    
	    print BWA_AL "wait", "\n\n";
	    $coreCounter=$coreCounter+1;
	}

	my $tempinfile = $infile{$sampleID}[$infileCounter];

	print BWA_AL "bwa aln ";
	print BWA_AL "-k 1 "; #maximum differences in the seed
	print BWA_AL "-t 4 "; #number of threads
	print BWA_AL "-n 3 "; #max #diff (int) or missing prob under 0.02 err rate (float)
	print BWA_AL "-q ".$scriptParameter{'bwaAlnQualityTrimming'}." "; #Quality trimming
	print BWA_AL $scriptParameter{'referencesDir'}."/".$scriptParameter{'humanGenomeReference'}." "; #Reference
	print BWA_AL $inSampleDirectory."/".$tempinfile." "; #InFile
	print BWA_AL "> ".$outSampleDirectory."/".$infilesBothStrandsNoEnding{$sampleID}[$infileCounter].".sai &", "\n\n"; #OutFile 
    }
    print BWA_AL "wait", "\n\n";
    close(BWA_AL);
    if ($scriptParameter{'pBwaAln'} == 1) {
	#SampleIDSubmitJob($sampleID,$filename, 1);   
	FIDSubmitJob($sampleID,$familyID,1,"MAIN",$filename,0);
    }
    return;
}

sub MosaikAlign {
#Aligning reads using MosaikAlign
    
    my $sampleID = $_[0];
    
    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/mosaik/info;`; #Creates the mosaik folder and info data file directory
    `mkdir -p $scriptParameter{'outScriptDir'}/$sampleID/mosaik;`; #Creates the mosaik script directory
    
    my $sbatchScriptTracker=0;
    my $time=0;
    my $infileSize;
    for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{$sampleID} });$infileCounter++) { #For all infiles per lane
	if ($infile{$sampleID}[$infileCounter] =~/.fastq.gz$/) { #Files are already gz and presently the scalar for compression has not been investigated. Therefore no automatic time allocation can be performed.
	    if ($scriptParameter{'wholeGenomeSequencing'} == 1) {
		$time = 80;  
	    }
	    else {
		$time = 40;
	    }
	}
	else { #Files are in fastq format
	    if (-e $indirpath{$sampleID}."/".$infile{$sampleID}[$infileCounter+$sbatchScriptTracker]) {
		$infileSize = -s $indirpath{$sampleID}."/".$infile{$sampleID}[$infileCounter+$sbatchScriptTracker]; # collect .fastq file size to enable estimation of time required for aligning, +$sbatchScriptTracker for syncing multiple infiles per sampleID. Hence, filesize will be calculated on read1 (should not matter).      
		$time = ceil(($infileSize/238)/(650*60*60)); #238 is a scalar estimating the number of reads depending on filesize. 650 is the number of reads/s in MosaikAlign-2.1.52 and 60*60 is to scale to hours.
	    }	    
	} 
	if ($scriptParameter{'pMosaikAlign'} == 1) {
	    $filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/mosaik/mosaikAlign_".$infilesLaneNoEnding{$sampleID}[$infileCounter].".";
	}
	elsif ($scriptParameter{'pMosaikAlign'} == 2) { #Dry run
	    $filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/mosaik/dry_run_mosaikAlign_".$infilesLaneNoEnding{$sampleID}[$infileCounter].".";
	    print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";
	}
	Checkfnexists($filename, $fnend);
	
###Info and Logg
	print STDOUT "Creating sbatch script MosaikAlign and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script MosaikAlign and writing script file(s) to: ".$filename, "\n";
	print STDOUT "Sbatch script MosaikAlign data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$scriptParameter{'aligner'}, "\n";print MASTERL "Sbatch script MosaikAlign data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$scriptParameter{'aligner'}, "\n";
	
	open (MOS_AL, ">".$filename) or die "Can't write to ".$filename.": $!\n";
	
	print MOS_AL "#! /bin/bash -l", "\n";
	print MOS_AL "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
	print MOS_AL "#SBATCH -p node -n ".$scriptParameter{'maximumCores'}, "\n";
	print MOS_AL "#SBATCH -C thin", "\n";
	print MOS_AL "#SBATCH -t ".$time.":00:00", "\n";
	print MOS_AL "#SBATCH -J MosAl_".$sampleID."_".$sbatchScriptTracker, "\n";
	if ($scriptParameter{'pMosaikAlign'} == 1) {
	    print MOS_AL "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/mosaik/info/mosaikAlign_".$infilesLaneNoEnding{$sampleID}[$infileCounter].".".$fnt.".stderr.txt", "\n";
	    print MOS_AL "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/mosaik/info/mosaikAlign_".$infilesLaneNoEnding{$sampleID}[$infileCounter].".".$fnt.".stdout.txt", "\n";
	}
	elsif ($scriptParameter{'pMosaikAlign'} == 2) { #Dry run
	    print MOS_AL "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/mosaik/info/dry_run_mosaikAlign_".$infilesLaneNoEnding{$sampleID}[$infileCounter].".".$fnt.".stderr.txt", "\n";
	    print MOS_AL "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/mosaik/info/dry_run_mosaikAlign_".$infilesLaneNoEnding{$sampleID}[$infileCounter].".".$fnt.".stdout.txt", "\n";
	}
	unless ($scriptParameter{'email'} eq 0) {
	    print MOS_AL "#SBATCH --mail-type=END", "\n";
	    print MOS_AL "#SBATCH --mail-type=FAIL", "\n";
	    print MOS_AL "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
	}
	
	print MOS_AL 'echo "Running on: $(hostname)"',"\n\n";
	print MOS_AL "mkdir -p /scratch/mosaik_tmp", "\n";
	print MOS_AL "export MOSAIK_TMP=/scratch/mosaik_tmp", "\n\n";

	my $inSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/mosaik";
	my $outSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/mosaik";
	my $infile = $infilesLaneNoEnding{$sampleID}[$infileCounter];

	print MOS_AL "MosaikAligner ";
	print MOS_AL "-in ".$inSampleDirectory."/".$infile.".dat "; #Infile
	print MOS_AL "-out ".$outSampleDirectory."/".$infilesLaneNoEnding{$sampleID}[$infileCounter]." "; #OutFile
	print MOS_AL "-ia ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'mosaikAlignReference'}." "; #Mosaik Reference
	print MOS_AL "-annpe ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'mosaikAlignNeuralNetworkPeFile'}." "; #NerualNetworkPE
	print MOS_AL "-annse ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'mosaikAlignNeuralNetworkSeFile'}." "; #NerualNetworkSE
	print MOS_AL "-hs 15 "; #hash size
	print MOS_AL "-mm 4 "; #the # of mismatches allowed
	print MOS_AL "-mhp 100 "; #the maximum # of positions stored per seed
	print MOS_AL "-ls 100 "; #enable local alignment search for PE reads
	print MOS_AL "-act 35 "; #the alignment candidate threshold (length)
	print MOS_AL "-bw 35 "; #specifies the Smith-Waterman bandwidth.
	print MOS_AL "-j ".$scriptParameter{'referencesDir'}."/".$scriptParameter{'mosaikJumpDbStub'}." "; #JumpDatabase
	print MOS_AL "-p ".$scriptParameter{'maximumCores'}, "\n\n"; #Nr of cores
	
	close(MOS_AL);
	if ($scriptParameter{'pMosaikAlign'} == 1) {
	    #ParallelSampleIDSubmitJob($sampleID,$filename, $infilesLaneNoEnding{$sampleID}[$infileCounter]);
	    FIDSubmitJob($sampleID,$familyID,3,"MAIN",$filename, $sbatchScriptTracker);
	}
	$sbatchScriptTracker++; #Tracks nr of sbatch scripts
    }
    return;
}

sub MosaikBuild {
#Generates Mosaik hash format on reads using MosaikBuild   
    
    my $sampleID = $_[0];
    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/mosaik/info;`; #Creates the mosaik folder and info data file directory
    `mkdir -p $scriptParameter{'outScriptDir'}/$sampleID/mosaik;`; #Creates the mosaik script directory

    if ($scriptParameter{'pMosaikBuild'} == 1) {	
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/mosaik/mosaikBuild_".$sampleID.".";    
    }
    elsif ($scriptParameter{'pMosaikBuild'} == 2) {
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/mosaik/dry_run_mosaikBuild_".$sampleID.".";
	print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";
    }
    Checkfnexists($filename, $fnend);
    
###Info and Logg
    print STDOUT "Creating sbatch script MosaikBuild and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script MosaikBuild and writing script file(s) to: ".$filename, "\n";
    print STDOUT "Sbatch script MosaikBuild data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$scriptParameter{'aligner'}, "\n";print MASTERL "Sbatch script MosaikBuild data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/".$scriptParameter{'aligner'}, "\n";

    my $time = ceil(2.5*scalar( @{ $infilesLaneNoEnding{$sampleID} })); #One full lane on Hiseq takes approx. 1 h for MosaikBuild to process (compressed format, uncompressed 0.5 h), round up to nearest full hour.
    
    open (MOS_BU, ">".$filename) or die "Can't write to ".$filename.": $!\n";
    
    print MOS_BU "#! /bin/bash -l", "\n";
    print MOS_BU "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
    print MOS_BU "#SBATCH -p node -n ".$scriptParameter{'maximumCores'}, "\n";
    print MOS_BU "#SBATCH -C thin", "\n";
    print MOS_BU "#SBATCH -t ".$time.":00:00", "\n";
    print MOS_BU "#SBATCH -J MosBu_".$sampleID, "\n";
    if ($scriptParameter{'pMosaikBuild'} == 1) {
	print MOS_BU "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/mosaik/info/mosaikBuild_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print MOS_BU "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/mosaik/info/mosaikBuild_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }
    elsif ($scriptParameter{'pMosaikBuild'} == 2) {
	print MOS_BU "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/mosaik/info/dry_run_mosaikBuild_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print MOS_BU "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/mosaik/info/dry_run_mosaikBuild_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }
    unless ($scriptParameter{'email'} eq 0) {
	print MOS_BU "#SBATCH --mail-type=END", "\n";
	print MOS_BU "#SBATCH --mail-type=FAIL", "\n";
	print MOS_BU "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
    }
    
    print MOS_BU 'echo "Running on: $(hostname)"',"\n\n";
    
    my $inSampleDirectory = $indirpath{$sampleID};
    my $outSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/mosaik";
    my $coreCounter=1;
    my $coreTracker=0; #Required to portion out cores and files before wait and to track the MOS_BU outfiles to correct lane
    
    for (my $infileCounter=0;$infileCounter<(scalar( @{ $infile{$sampleID} }) -1);$infileCounter++) {
	
	if ($coreTracker eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} nr of cores
	    
	    print MOS_BU "wait", "\n\n";
	    $coreCounter=$coreCounter+1;
	}
	my $infile = $infile{$sampleID}[$infileCounter];
	my $infile2 = $infile{$sampleID}[ ($infileCounter+1)]; #Paired read
	$infileCounter = $infileCounter+1; #To correct for reading 2 files at once

	print MOS_BU "MosaikBuild ";
	print MOS_BU "-id ".$infilesBothStrandsNoEnding{$sampleID}[$infileCounter]." "; #Read group ID for BAM Header
	print MOS_BU "-sam ".$sampleID." "; #Sample name for BAM Header
	print MOS_BU "-st illumina_long "; #Sequencing technology for BAM Header
	print MOS_BU "-mfl ".$scriptParameter{'mosaikBuildMedianFragLength'}." "; #Median Fragment Length
	print MOS_BU "-q ".$inSampleDirectory."/".$infile." "; #Read 1
	print MOS_BU "-q2 ".$inSampleDirectory."/".$infile2." "; #Read 2
	print MOS_BU "-out ".$outSampleDirectory."/".$infilesLaneNoEnding{$sampleID}[($coreTracker)].".dat &", "\n\n"; #OutFile
	$coreTracker++; #Track nr of mosaikBuild calls so that wait can be printed at the correct intervals (dependent on $scriptParameter{'maximumCores'})
    }
    print MOS_BU "wait", "\n\n";    
    close(MOS_BU);
    if ($scriptParameter{'pMosaikBuild'} == 1) {
	#SampleIDSubmitJob($sampleID,$filename, 1); 
	FIDSubmitJob($sampleID,$familyID,1,"MAIN",$filename, 0);
    }
    return;
}   

sub FastQC {
#Raw sequence quality analysis using FASTQC

    my $sampleID = $_[0];
    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/fastqc/info;`; #Creates the fastqc folder and info data file directory
    `mkdir -p $scriptParameter{'outScriptDir'}/$sampleID/fastqc;`; #Creates the fastqc script directory
    if ($scriptParameter{'pFastQC'} == 1) {
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/fastqc/fastqc_".$sampleID.".";
    }
    elsif ($scriptParameter{'pFastQC'} == 2) { #Dry run
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/fastqc/dry_run_fastqc_".$sampleID.".";
	print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";
    }
    Checkfnexists($filename, $fnend);

###Info and Logg
    print STDOUT "Creating sbatch script FastQC and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script Sample check FastQC and writing script file(s) to: ".$filename, "\n";
    print STDOUT "Sbatch script FastQC data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/fastqc", "\n";print MASTERL "Sbatch script Sample check FastQC data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/fastqc", "\n";

    my $time = ceil(0.5*scalar( @{ $infile{$sampleID} })); #One full lane on Hiseq takes approx. 0.5 h for FASTQC to process, round up to nearest full hour.
    
    open (FASTQC, ">".$filename) or die "Can't write to ".$filename.": $!\n";
    
    print FASTQC "#! /bin/bash -l", "\n";
    print FASTQC "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
    print FASTQC "#SBATCH -p node -n ".$scriptParameter{'maximumCores'}, "\n";
    print FASTQC "#SBATCH -C thin", "\n";
    print FASTQC "#SBATCH -t ".$time.":00:00", "\n";
    print FASTQC "#SBATCH -J FQC_".$sampleID, "\n";
    if ($scriptParameter{'pFastQC'} == 1) {
	print FASTQC "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/fastqc/info/fastqc_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print FASTQC "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/fastqc/info/fastqc_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }
    elsif ($scriptParameter{'pFastQC'} == 2) { #Dry run
	print FASTQC "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/fastqc/info/dry_run_fastqc_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print FASTQC "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/fastqc/info/dry_run_fastqc_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }
    unless ($scriptParameter{'email'} eq 0) {
	print FASTQC "#SBATCH --mail-type=END", "\n";
	print FASTQC "#SBATCH --mail-type=FAIL", "\n";
	print FASTQC "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
    }
    
    print FASTQC 'echo "Running on: $(hostname)"',"\n\n";
    
    my $inSampleDirectory = $indirpath{$sampleID};
    my $outSampleDirectory = $scriptParameter{'outDataDir'}."/".$sampleID."/fastqc";
    my $coreCounter=1;
    for (my $infileCounter=0;$infileCounter<scalar( @{ $infile{$sampleID} });$infileCounter++) {
	
	if ($infileCounter eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} cores
	    
	    print FASTQC "wait", "\n\n";
	    $coreCounter=$coreCounter+1;
	}
	my $infile = $infile{$sampleID}[$infileCounter];
	print FASTQC "fastqc ";
	print FASTQC $inSampleDirectory."/".$infile." "; #InFile
	print FASTQC "-o ".$outSampleDirectory. " &", "\n\n"; #OutFile
    }
    print FASTQC "wait", "\n";    
    
    close(FASTQC);
    if ($scriptParameter{'pFastQC'} == 1) {
	#SampleIDSubmitJob($sampleID,$filename, 0);
	FIDSubmitJob($sampleID,$familyID,2,"MAIN",$filename,0);
    }
    return;
}

sub GZipfastq { 
#Automatically gzips fastq files. 
    
    my $sampleID = $_[0];
    `mkdir -p $scriptParameter{'outDataDir'}/$sampleID/gzip/info;`; #Creates the gzip folder and info data file directory
    `mkdir -p $scriptParameter{'outScriptDir'}/$sampleID/gzip;`; #Creates the gzip script folder 
    if ($scriptParameter{'pGZip'} == 1) {
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/gzip/gzipFastq_".$sampleID.".";
    }
    elsif ($scriptParameter{'pGZip'} == 2) { #Dry run  
	$filename = $scriptParameter{'outScriptDir'}."/".$sampleID."/gzip/dry_run_gzipFastq_".$sampleID.".";
	print STDOUT "Dry Run:\n";print MASTERL  "Dry Run:\n";
    }
    Checkfnexists($filename, $fnend);

###Info and Logg
    print STDOUT "Creating sbatch script GzipFastq and writing script file(s) to: ".$filename, "\n";print MASTERL "Creating sbatch script GzipFastq and writing script file(s) to: ".$filename, "\n";
    print STDOUT "Sbatch script GzipFastq data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/fastq", "\n";print MASTERL "Sbatch script GzipFastq data files will be written to: ".$scriptParameter{'outDataDir'}."/".$sampleID."/fastq", "\n";
    
    my $time = ceil(1.5*scalar( @{ $infile{$sampleID} })); #One full lane on Hiseq takes approx. 1.5 h for gzip to process, round up to nearest full hour.
    open (GZ_FASTQ, ">".$filename) or die "Can't write to ".$filename.": .$!", "\n";
    
    print GZ_FASTQ "#! /bin/bash -l", "\n";
    print GZ_FASTQ "#SBATCH -A ".$scriptParameter{'projectID'}, "\n";
    print GZ_FASTQ "#SBATCH -p node -n ".$scriptParameter{'maximumCores'}, "\n";
    print GZ_FASTQ "#SBATCH -C thin", "\n";	
    print GZ_FASTQ "#SBATCH -t ".$time.":00:00", "\n";
    print GZ_FASTQ "#SBATCH -J GZFQ_".$sampleID, "\n";
    if ($scriptParameter{'pGZip'} == 1) {
	print GZ_FASTQ "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/gzip/info/gzipFastq_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print GZ_FASTQ "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/gzip/info/gzipFastq_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }
    elsif ($scriptParameter{'pGZip'} == 2) { #Dry run
	print GZ_FASTQ "#SBATCH -e ".$scriptParameter{'outDataDir'}."/".$sampleID."/gzip/info/dry_run_gzipFastq_".$sampleID.".".$fnt.".stderr.txt", "\n";
	print GZ_FASTQ "#SBATCH -o ".$scriptParameter{'outDataDir'}."/".$sampleID."/gzip/info/dry_run_gzipFastq_".$sampleID.".".$fnt.".stdout.txt", "\n";
    }
    unless ($scriptParameter{'email'} eq 0) {
	
	print GZ_FASTQ "#SBATCH --mail-type=END", "\n";
	print GZ_FASTQ "#SBATCH --mail-type=FAIL", "\n";
	print GZ_FASTQ "#SBATCH --mail-user=".$scriptParameter{'email'}, "\n\n";
	
    }
    
    print GZ_FASTQ 'echo "Running on: $(hostname)"',"\n\n";
    print GZ_FASTQ "cd ".$indirpath{$sampleID}, "\n\n";
    my $inSampleDirectory = $indirpath{$sampleID};
    my $coreCounter=1;
    my $uncompressedFileCounter = 0; #Used to print wait at the right times since infiles cannot be used (can be a mixture of .gz and .fast files)
    for (my $infileCounter=0;$infileCounter<scalar( @{ $infile{$sampleID} });$infileCounter++) {

	if ($infile{$sampleID}[$infileCounter] =~/.fastq$/) { #For files ending with .fastq required since there can be a mixture (also .fastq.gz) within the sample dir
	    if ($uncompressedFileCounter eq $coreCounter*$scriptParameter{'maximumCores'}) { #Using only $scriptParameter{'maximumCores'} cores
		
		print GZ_FASTQ "wait", "\n\n";
		$coreCounter=$coreCounter+1;
	    }
	    my $infile = $infile{$sampleID}[$infileCounter];
	    print GZ_FASTQ "gzip ";
	    print GZ_FASTQ $inSampleDirectory."/".$infile," &", "\n\n"; #InFile
	    $uncompressedFileCounter++;
	    $infile{$sampleID}[$infileCounter] =~ s/.fastq/.fastq.gz/g; #Replace the .fastq ending with .fastq.gz since this will execute before fastQC screen and mosaikBuild, hence changing the original file name ending from ".fastq" to ".fastq.gz". 

	}
    }
    print GZ_FASTQ "wait", "\n\n";
    if ($scriptParameter{'pGZip'} == 1) { 
	#SampleIDSubmitJob($sampleID,$filename, 1);
	FIDSubmitJob($sampleID,$familyID,0,"MAIN",$filename, 0);
    }
    return;
}

sub ReadPedigreeFile {
#Reads famid_pedigree.txt file
#IDN\tSampleID\tMother\tFather\t\Child..n

    my $fileName = $_[0];  
    my $userSampleidSwitch = $_[1];
    
    open(PEDF, "<".$fileName) or die "Can't open ".$fileName.":$!, \n";    
     
    while (<PEDF>) {
	chomp $_;
	
	if (m/^\s+$/) {		# Avoid blank lines
            next;
        }
	if (m/^\#/) {		# Avoid #
            next;
        }		
	if ($_ =~/(\S+)/) {	
	    chomp($_);
	    my @lineInfo = split("\t",$_);	    #Loads pedigree info
	    if ($lineInfo[0] =~ /(\d+)-(\d+|-\d+)-(\d+)(A|U)/) { #Match IDN
		my $familyID = $1;
		if ($userSampleidSwitch == 0) {
		    push(@sampleIDs, $lineInfo[0]); #Save sampleid info
		} 
		if ($3 % 2 == 1) { #Male
#% modulous operator, it gives you an integer representation of the remainder of a division operation. If X / Y divides evenly (that is to say, there's no remainder (or modulus)), the result of X % Y will be zero.
		    $sampleInfo{$familyID}{$lineInfo[0]}{'Sex'} = "M"; #Sex, M=Male
		}
		else { #Female
		   $sampleInfo{$familyID}{$lineInfo[0]}{'Sex'} = "F"; #Sex, F=Female
		}
		if ($4 eq "A") { #Affected
		    $sampleInfo{$familyID}{$lineInfo[0]}{'Disease_status'} = 1; #1=Affected
		}
		else { #Unaffected
		    $sampleInfo{$familyID}{$lineInfo[0]}{'Disease_status'} = 0; #0=Unaffected
		}
		
		if ($lineInfo[14]) { #Capture kit
		    my @captureKits = split(";", $lineInfo[14]);
		    my $capture_kit =  pop(@captureKits); #Use only the last capture kit since it should be the most interesting
		    
		    for my $supportedCaptureKit (keys %supportedCaptureKits) {
			if ($supportedCaptureKit eq $capture_kit) {
			    if ($exomeTargetBed eq 0) { #No user supplied info on capture kit target BED-file. Add from pedigree file
				$sampleInfo{$familyID}{$lineInfo[0]}{'exomeTargetBed'} = $supportedCaptureKits{$supportedCaptureKit}; #capture kit Bed-file
			    }
			    if ($exomeTargetBedInfileList eq 0) { #No user supplied info on capture kit target BED-file infile list. Add from pedigree file
				$sampleInfo{$familyID}{$lineInfo[0]}{'exomeTargetBedInfileList'} = $supportedCaptureKits{$supportedCaptureKit}.".infile_list"; #capture kit target infile_list
			    }
			    if ($exomeTargetPaddedBedInfileList eq 0) { #No user supplied info on capture kit target BED-file infile list. Add from pedigree file
				$sampleInfo{$familyID}{$lineInfo[0]}{'exomeTargetPaddedBedInfileList'} = $supportedCaptureKits{$supportedCaptureKit}.".pad100.infile_list"; #capture kit padded target infile_list
			    }
			    if ($GATKTargetPaddedBedIntervalList eq 0) { #No user supplied info on capture kit target BED-file infile list. Add from pedigree file
				$sampleInfo{$familyID}{$lineInfo[0]}{'GATKTargetPaddedBedIntervalList'} = $supportedCaptureKits{$supportedCaptureKit}.".pad100.interval_list"; #capture kit padded target interval_list
			    }
			}
		    }
		}	
	    }
	}
    } 	
    if ($userSampleidSwitch == 0) {
	@sampleIDs = sort(@sampleIDs); #Lexiographical sort to determine the correct order of ids indata
    }
    print STDOUT "Read pedigree file: ".$fileName, "\n\n";
    close(PEDF);
    return;
}

sub FIDSubmitJob {
#Submits all jobIDs to SLURM using SLURM dependencies. The first path is MAIN and any subsequent splits into other paths later is handled by adding relevant previous jobIDs to the new paths key in jobID{path_key} hash. The subroutine supports parallel job within each step and submission which do not leave any dependencies. Currently any path downstream of MAIN inherits the relevant previous jobIds, but it is not possible to merge to splited paths downstream of main to each other.
#$_[0] = sampleid or 0 when family is supplied 
#$_[1] = familyID
#$_[2] = Dependencies
#$_[3] = Path (MAIN, SNV, INDEL, BOTH). MAIN is before there is any split.
#$_[4] = sbatch filename to submit.
#$_[5] = $sbatchScriptTracker

###
#Dependencies
###
#0 = Not dependent on earlier scripts
#1 = Dependent on earlier scripts (within sampleID_path or familyID_path)
#2 = Dependent on earlier scripts (within sampleID_path or familyID_path), but are self cul-de-sâcs. 
#3 = Dependent on earlier scripts and executed in parallel within step
#4 = Dependent on earlier scripts and parallel scripts and executed in parallel within step 

    my $sampleID = $_[0];
    my $familyID = $_[1];
    my $dependencies = $_[2]; 
    my $path = $_[3]; 
    my $sbatchFileName = $_[4];
    my $sbatchScriptTracker = $_[5]; 

    my $jobIDs=""; #Create string with all previous jobIDs
    my $return; #Return jobID
    my $sampleIDChainKey = $sampleID."_".$path; 
    my $familyIDChainKey = $familyID."_".$path;
    my $sampleIDParallelChainKey = $sampleID."_parallel_".$path.$sbatchScriptTracker; 
    my $familyIDParallelChainKey = $familyID."_parallel_".$path.$sbatchScriptTracker;
    my $jobID; #The jobID that is returned from submission
    
    if ($dependencies == 0) { #Initiate chain - No dependencies
	$return = `sbatch $sbatchFileName`; #No jobs have been run: submit
	($jobID) = ($return =~ /Submitted batch job (\d+)/);
	push ( @{ $jobID{$sampleIDChainKey} }, $jobID); #Add jobID to hash{$sampleID}[]
	push ( @{ $jobID{$familyIDChainKey} }, $jobID); #Add jobID to hash{$familyID}[]. Required to enable later test for all subjects sampleID_MAIN have finished before merging to family.
    }
    else { #Dependent on earlier scripts and/or parallel. JbIDs that do not leave dependencies do not get pushed to jobID hash
	
	if ($sampleID) { #BEFORE merging to familyID

	    if ( ($dependencies == 1) || ($dependencies == 2) ) {
		
		for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{$sampleID} });$infileCounter++) {
		    
		    my $sampleIDParallelChainKey = $sampleID."_parallel_".$path.$infileCounter;
		    
		    if ($jobID{$sampleIDParallelChainKey}) {
			
			for my $sbatchScriptTracker (keys %{$jobID{$sampleIDParallelChainKey} }) {
			    
			    for (my $jobCounter=0;$jobCounter<scalar( @{ $jobID{$sampleIDParallelChainKey}{$sbatchScriptTracker} });$jobCounter++) {

				my $seenJobIDsSwitch = 0;
 
				if ($jobID{$sampleIDChainKey}) {#If any previous jobIds within current chain exists else go ahead and add
				    for (my $currentJobCounter=0;$currentJobCounter<scalar( @{ $jobID{$sampleIDChainKey} });$currentJobCounter++) {
					if ($jobID{$sampleIDChainKey}[$currentJobCounter] =~/$jobID{$sampleIDParallelChainKey}{$sbatchScriptTracker}[$jobCounter]/) { #Only add if not already present
					    $seenJobIDsSwitch++;
					}
				    }
				    if ($seenJobIDsSwitch == 0) {#JobID was not present in CURRENT path
					push ( @{ $jobID{$sampleIDChainKey} }, $jobID{$sampleIDParallelChainKey}{$sbatchScriptTracker}[$jobCounter]); #Add jobID to hash{$}			
				    }
				}
				else { #Go ahead and add
				    push ( @{ $jobID{$sampleIDChainKey} }, $jobID{$sampleIDParallelChainKey}{$sbatchScriptTracker}[$jobCounter]); #Add jobID to hash{$}
				}   	
			    }
			}	   
		    }
		}
	    }
	    if ( ($path eq "MAIN") && ($jobID{$sampleIDChainKey}) ) { #Check for any previous jobIDs within path MAIN. Test for previous must be done to allow initiating from broken chain
		if ($dependencies == 4) {
		    for (my $infileCounter=0;$infileCounter<scalar( @{ $infilesLaneNoEnding{$sampleID} });$infileCounter++) {
			if ($jobID{$sampleIDParallelChainKey}{$infileCounter}) {
			    
			    for (my $jobCounter=0;$jobCounter<scalar( @{ $jobID{$sampleIDParallelChainKey}{$infileCounter} });$jobCounter++) {	
			       
				if ( ($jobCounter == 0) && (scalar( @{ $jobID{$sampleIDParallelChainKey}{$infileCounter} }) == 1) ) {#Only 1 previous jobID 
				    $jobIDs .= ":$jobID{$sampleIDParallelChainKey}{$infileCounter}[$jobCounter]"; #first and last jobID start with ":" and end without ":"
				}
				elsif ($jobCounter == 0) {
				    $jobIDs .= ":$jobID{$sampleIDParallelChainKey}{$infileCounter}[$jobCounter]:"; #first jobID start with :
				}
				elsif ($jobCounter eq (scalar( @{ $jobID{$sampleIDChainKey}{$infileCounter} }) -1) ) {
				    $jobIDs .= "$jobID{$sampleIDParallelChainKey}{$infileCounter}[$jobCounter]"; #last jobID finish without :
				}
				else {
				    $jobIDs .= "$jobID{$sampleIDParallelChainKey}{$infileCounter}[$jobCounter]:";
				}
			    }
			}
		    }
		}
		else  {
		    for (my $jobCounter=0;$jobCounter<scalar( @{ $jobID{$sampleIDChainKey} });$jobCounter++) {	
			if ( ($jobCounter == 0) && (scalar( @{ $jobID{$sampleIDChainKey} }) == 1) ) {#Only 1 previous jobID 
			    $jobIDs .= ":$jobID{$sampleIDChainKey}[$jobCounter]"; #first and last jobID start with ":" and end without ":"
			}
			elsif ($jobCounter == 0) {
			    $jobIDs .= ":$jobID{$sampleIDChainKey}[$jobCounter]:"; #first jobID start with :
			}
			elsif ($jobCounter eq (scalar( @{ $jobID{$sampleIDChainKey} }) -1) ) {
			    $jobIDs .= "$jobID{$sampleIDChainKey}[$jobCounter]"; #last jobID finish without :
			}
			else {
			    $jobIDs .= "$jobID{$sampleIDChainKey}[$jobCounter]:";
			}
		    }
		}
	    }
	    if ($path ne "MAIN") { #Check for any previous jobIDs within path current PATH
		my $sampleIDMainParallelChainKey = $sampleID."_parallel_MAIN"; 
		if ( ($dependencies != 3) && ($jobID{$sampleIDMainParallelChainKey}{$sbatchScriptTracker}) ){ #If not a parallel job and a parallel job within MAIN path has prev been processed. Check if previous step was parallel and adds previous parallel jobs that have previously been submitted.
		    for (my $jobCounter=0;$jobCounter<scalar( @{ $jobID{$sampleIDMainParallelChainKey}{$sbatchScriptTracker} });$jobCounter++) { #All prev parallel MAIN jobIDs
			my $seenJobIDsCounter = 0;
			if ($jobID{$sampleIDChainKey}) {#If any previous jobIds within current chain exists - else go ahead and add
			    for (my $currentJobCounter=0;$currentJobCounter<scalar( @{ $jobID{$sampleIDChainKey} });$currentJobCounter++) { #CURRENT path
				if ($jobID{$sampleIDChainKey}[$currentJobCounter] =~/$jobID{$sampleIDMainParallelChainKey}{$sbatchScriptTracker}[$jobCounter]/) { #Only add if not already present
				    $seenJobIDsCounter++;
				}
			    }
			    if ($seenJobIDsCounter eq 0) {#JobID was not present in CURRENT path
				push ( @{ $jobID{$sampleIDChainKey} }, $jobID{$sampleIDMainParallelChainKey}{$sbatchScriptTracker}[$jobCounter]); #Add jobID to hash{$}
			    }
			}
			else { #Go ahead and add
			    push ( @{ $jobID{$sampleIDChainKey} }, $jobID{$sampleIDMainParallelChainKey}{$sbatchScriptTracker}[$jobCounter]); #Add jobID to hash{$}
			}
		    }
		}
		my $sampleIDMainChainKey = $sampleID."_MAIN";
		if ($jobID{$sampleIDMainChainKey}) { #Any MAIN jobIDs necessary for broken chains, since this will be empty then
		    for (my $jobCounter=0;$jobCounter<scalar( @{ $jobID{$sampleIDMainChainKey} });$jobCounter++) { #Prev MAIN jobIDs
			my $seenJobIDsCounter = 0; 
			if ($jobID{$sampleIDChainKey}) {#If any previous jobIds within current chain exists else go ahead and add
			    for (my $currentJobCounter=0;$currentJobCounter<scalar( @{ $jobID{$sampleIDChainKey} });$currentJobCounter++) { #CURRENT path
				if ($jobID{$sampleIDChainKey}[$currentJobCounter] =~/$jobID{$sampleIDMainChainKey}[$jobCounter]/) {
				    $seenJobIDsCounter++;
				}
			    }
			    if ($seenJobIDsCounter eq 0) {#JobID was not present in CURRENT path
				push ( @{ $jobID{$sampleIDChainKey} }, $jobID{$sampleIDMainChainKey}[$jobCounter]); #Add jobID to hash{$}
			    }
			}
			else  { #Go ahead and add
			    push ( @{ $jobID{$sampleIDChainKey} }, $jobID{$sampleIDMainChainKey}[$jobCounter]); #Add jobID to hash{$}
			}
		    }
		}
		if ($jobID{$sampleIDChainKey}) {
		    for (my $jobCounter=0;$jobCounter<scalar( @{ $jobID{$sampleIDChainKey} });$jobCounter++) {	
			if ( ($jobCounter == 0) && (scalar( @{ $jobID{$sampleIDChainKey} })== 1) ) {#Only 1 previous jobID 
			    $jobIDs .= ":$jobID{$sampleIDChainKey}[$jobCounter]"; #first and last jobID start with ":" and end without ":"
			}
			elsif ($jobCounter == 0) {
			    $jobIDs .= ":$jobID{$sampleIDChainKey}[$jobCounter]:"; #first jobID start with :
			}
			elsif ($jobCounter eq ( scalar( @{ $jobID{$sampleIDChainKey} }) -1)) {
			    $jobIDs .= "$jobID{$sampleIDChainKey}[$jobCounter]"; #last jobID finish without :
			}
			else {
			    $jobIDs .= "$jobID{$sampleIDChainKey}[$jobCounter]:";
			}
		    }
		}
	    }
	    if ($jobIDs) {
		$return = `sbatch --dependency=afterok$jobIDs $sbatchFileName`; #Supply with dependency of previous jobs that this one is dependent on
		($jobID) = ($return =~ /Submitted batch job (\d+)/);
	    }
	    else {
		$return = `sbatch $sbatchFileName`; #No jobs have been run: submit
		($jobID) = ($return =~ /Submitted batch job (\d+)/);
	    }
	    if ($dependencies == 1) { #Ordinary job push to array
		push ( @{ $jobID{$sampleIDChainKey} }, $jobID); #Add jobID to hash{$sampleID}[]
		push ( @{ $jobID{$familyIDChainKey} }, $jobID); #Add jobID to hash{$familyID}[]. Required to enable later test for all subjects sampleID_MAIN have finished before merging to family.
	    }
	    if ($dependencies == 3) { #Parallel job wait to push to array until all parallel jobs are finished within step
		push ( @{ $jobID{$sampleIDParallelChainKey}{$sbatchScriptTracker} }, $jobID); #Add jobID to hash{$sampleID_parallel}[].
		push ( @{ $jobID{$familyIDChainKey} }, $jobID); #Add jobID to hash{$familyID}[]. Required to enable later test for all subjects sampleID_MAIN have finished before merging to family.
	    }
	    if ($dependencies == 4) { #Parallel job after parallel job wait to push to array until all parallel jobs are finished within step
		
		push ( @{ $jobID{$sampleIDParallelChainKey}{$sbatchScriptTracker} }, $jobID); #Add jobID to hash{$sampleID_parallel}[].
		push ( @{ $jobID{$familyIDChainKey} }, $jobID); #Add jobID to hash{$familyID}[]. Required to enable later test for all subjects sampleID_MAIN have finished before merging to family.
	    }
	}
	else { #AFTER merging to familyID
	    if ( ($dependencies != 3) && ($jobID{$familyIDParallelChainKey}) ){ #If not a parallel job and a parallel job within CURRENT PATH has prev been processed. Check if previous step was parallel and adds previous parallel jobs that have previously been submitted.
		for (my $jobCounter=0;$jobCounter<scalar( @{ $jobID{$familyIDParallelChainKey} });$jobCounter++) {
		    my $seenJobIDsCounter = 0;
		    if ($jobID{$familyIDChainKey}) {#If any previous jobIds within current chain exists else go ahead and add
			for (my $currentJobCounter=0;$currentJobCounter<scalar( @{ $jobID{$familyIDChainKey} });$currentJobCounter++) {
			    if ($jobID{$familyIDChainKey}[$currentJobCounter] =~/$jobID{$familyIDParallelChainKey}[$jobCounter]/) { #Only add if not already present
				$seenJobIDsCounter++;
			    }
			}
			if ($seenJobIDsCounter eq 0) {#JobID was not present in CURRENT path
			    push ( @{ $jobID{$familyIDChainKey} }, $jobID{$familyIDParallelChainKey}[$jobCounter]); #Add jobID to hash{$}			
			}
		    }
		    else { #Go ahead and add
			push ( @{ $jobID{$familyIDChainKey} }, $jobID{$familyIDParallelChainKey}[$jobCounter]); #Add jobID to hash{$}
		    }   	
		}
	    }
	    if ( ($path eq "MAIN") && ($jobID{$familyIDChainKey})  ) { #Check for any previous jobIDs within path MAIN. Test for pevious must be done to allow initiating from broken chain
		for (my $jobCounter=0;$jobCounter<scalar( @{ $jobID{$familyIDChainKey} });$jobCounter++) {	
		    if ( ($jobCounter == 0) && (scalar( @{ $jobID{$familyIDChainKey} })== 1) ) {#Only 1 previous jobID 
			$jobIDs .= ":$jobID{$familyIDChainKey}[$jobCounter]"; #first and last jobID start with ":" and end without ":"
		    }
		    elsif ($jobCounter == 0) {
			$jobIDs .= ":$jobID{$familyIDChainKey}[$jobCounter]:"; #first jobID start with :
		    }
		    elsif ($jobCounter eq ( scalar( @{ $jobID{$familyIDChainKey} }) -1)) {
			$jobIDs .= "$jobID{$familyIDChainKey}[$jobCounter]"; #last jobID finish without :
		    }
		    else {
			$jobIDs .= "$jobID{$familyIDChainKey}[$jobCounter]:";
		    }
		}
	    }
	    if ($path ne "MAIN") { #Check for any previous jobIDs within MAIN path and current PATH
		my $fid_main_parallel_chainkey = $familyID."_parallel_MAIN"; 
		if ( ($dependencies != 3) && ($jobID{$fid_main_parallel_chainkey}) ){ #If not a parallel job and a parallel job within MAIN path has prev been processed. Check if previous step was parallel and adds previous parallel jobs that have previously been submitted.
		    for (my $jobCounter=0;$jobCounter<scalar( @{ $jobID{$fid_main_parallel_chainkey} });$jobCounter++) { #All prev parallel MAIN jobIDs
			my $seenJobIDsCounter = 0;
			if ($jobID{$familyIDChainKey}) {#If any previous jobIds within current chain exists - else go ahead and add
			    for (my $currentJobCounter=0;$currentJobCounter<scalar( @{ $jobID{$familyIDChainKey} });$currentJobCounter++) { #CURRENT path
				if ($jobID{$familyIDChainKey}[$currentJobCounter] =~/$jobID{$fid_main_parallel_chainkey}[$jobCounter]/) { #Only add if not already present
				    $seenJobIDsCounter++;
				}
			    }
			    if ($seenJobIDsCounter eq 0) {#JobID was not present in CURRENT path
				push ( @{ $jobID{$familyIDChainKey} }, $jobID{$fid_main_parallel_chainkey}[$jobCounter]); #Add jobID to hash{$}
			    }
			}
			else { #Go ahead and add
			    push ( @{ $jobID{$familyIDChainKey} }, $jobID{$fid_main_parallel_chainkey}[$jobCounter]); #Add jobID to hash{$}
			}
		    }
		}
		my $fid_main_chainkey = $familyID."_MAIN";
		if ($jobID{$fid_main_chainkey}) { #Any MAIN jobIDs necessary for broken chains, since this will be empty then
		    for (my $jobCounter=0;$jobCounter<scalar( @{ $jobID{$fid_main_chainkey} });$jobCounter++) { #Prev MAIn jobIDs
			my $seenJobIDsCounter = 0; 
			if ($jobID{$familyIDChainKey}) {#If any previous jobIds within current chain exists else go ahead and add
			    for (my $currentJobCounter=0;$currentJobCounter<scalar( @{ $jobID{$familyIDChainKey} });$currentJobCounter++) { #CURRENT path
				if ($jobID{$familyIDChainKey}[$currentJobCounter] =~/$jobID{$fid_main_chainkey}[$jobCounter]/) {
				    $seenJobIDsCounter++;
				}
			    }
			    if ($seenJobIDsCounter eq 0) {#JobID was not present in CURRENT path
				push ( @{ $jobID{$familyIDChainKey} }, $jobID{$fid_main_chainkey}[$jobCounter]); #Add jobID to hash{$}
			    }
			}
			else  { #Go ahead and add
			    push ( @{ $jobID{$familyIDChainKey} }, $jobID{$fid_main_chainkey}[$jobCounter]); #Add jobID to hash{$}
			}
		    }
		}
		if ($jobID{$familyIDChainKey}) {
		    for (my $jobCounter=0;$jobCounter<scalar( @{ $jobID{$familyIDChainKey} });$jobCounter++) {	
			if ( ($jobCounter == 0) && (scalar( @{ $jobID{$familyIDChainKey} })== 1) ) {#Only 1 previous jobID 
			    $jobIDs .= ":$jobID{$familyIDChainKey}[$jobCounter]"; #first and last jobID start with ":" and end without ":"
			}
			elsif ($jobCounter == 0) {
			    $jobIDs .= ":$jobID{$familyIDChainKey}[$jobCounter]:"; #first jobID start with :
			}
			elsif ($jobCounter eq (scalar( @{ $jobID{$familyIDChainKey} }) -1)) {
			    $jobIDs .= "$jobID{$familyIDChainKey}[$jobCounter]"; #last jobID finish without :
			}
			else {
			    $jobIDs .= "$jobID{$familyIDChainKey}[$jobCounter]:";
			}
		    }
		}
	    }
	    if ($jobIDs) {
		$return = `sbatch --dependency=afterok$jobIDs $sbatchFileName`; #Supply with dependency of previous jobs that this one is dependent on
		($jobID) = ($return =~ /Submitted batch job (\d+)/);
	    }
	    else {
		$return = `sbatch $sbatchFileName`; #No jobs have been run: submit
		($jobID) = ($return =~ /Submitted batch job (\d+)/);
	    }
	    if ($dependencies == 1) { #Ordinary job push to array
		push ( @{ $jobID{$familyIDChainKey} }, $jobID); #Add jobID to hash{$familyID}[]. Required to enable later test for all subjects sampleID_MAIN have finished before merging to family.
	    }
	    if ($dependencies == 3) { #Parallel job wait to push to array until all parallel jobs are finished within step
		push ( @{ $jobID{$familyIDParallelChainKey} }, $jobID); #Add jobID to hash{$familyID_parallel}[]. 
	    }
	}
    }
    print STDOUT "Sbatch script submitted, job id: $jobID\n";
    print STDOUT "To check status of job, please run \'jobinfo -j $jobID\'\n";
    print STDOUT "To check status of job, please run \'squeue -j $jobID\'\n";
}

sub ParallelSampleIDSubmitJob {
#Submits parallel jobs within sampleID and infile and includes any previous jobIDs within that sampleID. Use from time of parallelization until time of merge within sampleID. When it is time to merge: the third argument should be all and the subroutine then will only enter the first coding block and hence wait for all jobIDs that previously have been submitted within that sampleID. 
#$_[0] = sampleid
#$_[1] = whole path filename (.sh)
#$_[2] = filename (.sh) or all 
   
    my $parallelsamplejobids=""; #Create string with all previous jobIDs for a sampleID
    my $ret;

    if ($_[2] eq "all") {

	if ($allsampleIDjobID{$_[0]}) { #All jobIDs for a sampleID
	    
	    for (my $alljob=0;$alljob<scalar( @{ $allsampleIDjobID{$_[0]} });$alljob++) {	
		
		if ($alljob eq (scalar( @{ $allsampleIDjobID{$_[0]} }) -1) ) {
		    $parallelsamplejobids .= ":$allsampleIDjobID{$_[0]}[$alljob]"; #last jobID finish without :
		}
		else {
		    $parallelsamplejobids .= ":$allsampleIDjobID{$_[0]}[$alljob]";
		}
	    }
	    $ret = `sbatch --dependency=afterok$parallelsamplejobids $_[1]`; #Supply with dependency of previous within sampleID
	    #$ret = `sbatch --dependency=afterok:$samplejobids $_[1]`; #Supply with dependency of previous within sampleID
	    my ($jobID) = ($ret =~ /Submitted batch job (\d+)/);
	    push ( @{ $paralleljobID{$_[2]} }, $jobID); #Add paralleljobID to hash[sampleID]
	    push ( @{$allsampleIDjobID{$_[0]} }, $jobID); #Add allsamplejobID to hash[sampleID] 
	    print STDOUT "Sbatch script submitted, job id: $jobID\n";
	    print STDOUT "To check status of job, please run \'jobinfo -j $jobID\'\n";
	    print STDOUT "To check status of job, please run \'squeue -j $jobID\'\n";
	}
	else {
	# Iniate chain for sampleID   
	$ret = `sbatch $_[1]`;
	my ($jobID) = ($ret =~ /Submitted batch job (\d+)/);
	push ( @{$jobID{$_[0]} }, $jobID); #Add jobID to hash[sampleID]
	push ( @{$allsampleIDjobID{$_[0]} }, $jobID); #Add allsamplejobID to hash[sampleID]
	print STDOUT "Sbatch script submitted, job id: $jobID\n";
	print STDOUT "To check status of job, please run \'jobinfo -j $jobID\'\n";
	print STDOUT "To check status of job, please run \'squeue -j $jobID\'\n";
	}
    }

    elsif ( ($jobID{$_[0]}) || ($paralleljobID{$_[2]}) ) { #Any previous jobIDs
	
	if ($jobID{$_[0]}) {
	    
	    for (my $job=0;$job<scalar( @{ $jobID{$_[0]} });$job++) {	
		
		if ($job eq (scalar( @{ $jobID{$_[0]} }) -1) ) {
		    $parallelsamplejobids .= ":$jobID{$_[0]}[$job]"; #last jobID finish without :
		}
		else {
		    $parallelsamplejobids .= ":$jobID{$_[0]}[$job]";
		}
	    }
	}
	if ($_[2] && $paralleljobID{$_[2]} ) {

	    for (my $parjob=0;$parjob<scalar( @{ $paralleljobID{$_[2]} });$parjob++) {	
		
		if ($parjob eq (scalar( @{ $paralleljobID{$_[2]} }) -1)) {
		$parallelsamplejobids .= ":$paralleljobID{$_[2]}[$parjob]"; #last paralleljobID finish without :
		}
		else {
		    $parallelsamplejobids .= ":$paralleljobID{$_[2]}[$parjob]";
		}
	    }
	}
	$ret = `sbatch --dependency=afterok$parallelsamplejobids $_[1]`; #Supply with dependency of previous within sampleID
	#$ret = `sbatch --dependency=afterok:$samplejobids $_[1]`; #Supply with dependency of previous within sampleID
	my ($jobID) = ($ret =~ /Submitted batch job (\d+)/);
	push ( @{ $paralleljobID{$_[2]} }, $jobID); #Add paralleljobID to hash[sampleID] 
	push ( @{$allsampleIDjobID{$_[0]} }, $jobID); #Add allsamplejobID to hash[sampleID]
	print STDOUT "Sbatch script submitted, job id: $jobID\n";
	print STDOUT "To check status of job, please run \'jobinfo -j $jobID\'\n";
	print STDOUT "To check status of job, please run \'squeue -j $jobID\'\n";
    }
    else {
# Iniate chain for paralleljobs within sampleID   
	$ret = `sbatch $_[1]`;
	my ($jobID) = ($ret =~ /Submitted batch job (\d+)/);
	push ( @{$paralleljobID{$_[2]} }, $jobID); #Add paralleljobID to hash[sampleID]
	push ( @{$allsampleIDjobID{$_[0]} }, $jobID); #Add allsamplejobID to hash[sampleID]
	print STDOUT "Sbatch script submitted, job id: $jobID\n";
	print STDOUT "To check status of job, please run \'jobinfo -j $jobID\'\n";
	print STDOUT "To check status of job, please run \'squeue -j $jobID\'\n";
    }
}

sub SampleIDSubmitJob {
#Submits jobs for per sampleID. Use until there is need to parallelize within each sampleID
#$_[0] = sampleid
#$_[1] = filename (.sh)
#$_[2] = add to chain or not (0 = do not add, 1 = add)
    
    my $samplejobids=""; #Create string with all previous jobIDs
    my $ret;
    if ($jobID{$_[0]}) {
	
	for (my $job=0;$job<scalar( @{ $jobID{$_[0]} });$job++) {	
	    
	    if ($job eq (scalar( @{ $jobID{$_[0]} }) -1)) {
		$samplejobids .= "$jobID{$_[0]}[$job]"; #last jobID finish without :
	    }
	    else {
		$samplejobids .= "$jobID{$_[0]}[$job]:";
	    }
	}
	$ret = `sbatch --dependency=afterok:$samplejobids $_[1]`; #Supply with dependency of previous within sampleID
	my ($jobID) = ($ret =~ /Submitted batch job (\d+)/);
	if ($_[2] == 1) {
	    push ( @{ $jobID{$_[0]} }, $jobID); #Add jobID to hash[sampleID] 
	    push ( @{$allsampleIDjobID{$_[0]} }, $jobID); #Add allsamplejobID to hash[sampleID]
	}
	print STDOUT "Sbatch script submitted, job id: $jobID\n";
	print STDOUT "To check status of job, please run \'jobinfo -j $jobID\'\n";
	print STDOUT "To check status of job, please run \'squeue -j $jobID\'\n";
    }
    else {
# Iniate chain for sampleID   
	$ret = `sbatch $_[1]`;
	my ($jobID) = ($ret =~ /Submitted batch job (\d+)/);
	if ($_[2] == 1) {
	    push ( @{$jobID{$_[0]} }, $jobID); #Add jobID to hash[sampleID]
	    push ( @{$allsampleIDjobID{$_[0]} }, $jobID); #Add allsamplejobID to hash[sampleID]
	}
	print STDOUT "Sbatch script submitted, job id: $jobID\n";
	print STDOUT "To check status of job, please run \'jobinfo -j $jobID\'\n";
	print STDOUT "To check status of job, please run \'squeue -j $jobID\'\n";
    }
}

sub InfilesReFormat {
    
#Code needed to reformat files for mosaik output, which have not yet been created into, correct format so that a sbatch script can be generated with the correct filenames. 

my $uncompressedFileCounter = 0;     

    for my $samplid (keys %infile) { #For every sample id
	
	my $k=1;
	my $itrack=0; #Needed to be able to track when lanes are finished
	for (my $i=0;$i<scalar( @ { $infile{ $samplid } });$i++) { #Collects inputfiles for every fastq dir and remakes format
	    if ($infile{$samplid}[$i] =~ /\/?([^\.\/]+\.[^\.]+)\.lane(\d+)_([12FfRr])\.fastq.gz/) { #Parse fastq.gz 'old' format
		
		push( @ {$lane{$samplid} }, $2);
		$infilesLaneNoEnding{ $samplid }[$itrack]= "$1.$2"; #Save new format in hash with samplid as keys and inputfiles in array. Note: These files have not been created yet and there is one entry into hash for both strands and .ending is removed (.fastq).
		$i++; #Skip second direction
		$itrack++; #Track for every lane finished
	    }
	    elsif ($infile{$samplid}[$i] =~ /\/?([^\.\/]+\.[^\.]+)\.lane(\d+)_([12FfRr])\.fastq/) { #Parse 'old' format

		push( @ {$lane{$samplid} }, $2);
		$uncompressedFileCounter = 1;
		$infilesLaneNoEnding{ $samplid }[$itrack]= "$1.$2"; #Save new format in hash with samplid as keys and inputfiles in array. Note: These files have not been created yet and there is one entry into hash for both strands and .ending is removed (.fastq).
		$i++; #Skip second direction
		$itrack++; #Track for every lane finished
	    }
	    elsif ($infile{$samplid}[$i] =~ /(\d+)_(\d+)_([^_]+)_([^_]+)_(index[^_]+)_(\d).fastq.gz/) { #Parse fastq.gz 'new' format $1=lane, $2=date, $3=Flow-cell, $4=SampleID, $5=index,$6=direction
	
		push( @ {$lane{$samplid} }, $1);
		$infilesLaneNoEnding{ $samplid }[$itrack]= "$4.$2_$3_$5."."lane"."$1_$6"; #Save new format (sampleID_date_flow-cell_index_lane_direction) in hash with samplid as keys and inputfiles in array. Note: These files have not been created yet and there is one entry into hash for both strands and .ending is removed (.fastq).
		$i++; #Skip second direction
		$itrack++; #Track for every lane finished
	    }
	    elsif ($infile{$samplid}[$i] =~/(\d+)_(\d+)_([^_]+)_([^_]+)_(index[^_]+)_(\d).fastq/) { #Parse 'new' format $1=lane, $2=date, $3=Flow-cell, $4=SampleID, $5=index,$6=direction
		
		push( @ {$lane{$samplid} }, $1);
		$uncompressedFileCounter = 1;
		$infilesLaneNoEnding{ $samplid }[$itrack]= "$4.$2_$3_$5."."lane"."$1_$6"; #Save new format (sampleID_date_flow-cell_index_lane_direction) in hash with samplid as keys and inputfiles in array. Note: These files have not been created yet and there is one entry into hash for both strands and .ending is removed (.fastq).
		$i++; #Skip second direction
		$itrack++; #Track for every lane finished
	    }
	}
	$k=1;
	for (my $i=0;$i<scalar( @ { $infile{ $samplid } });$i++) { #Collects inputfiles for every fastq dir and remakes format
	    if ($infile{$samplid}[$i] =~ /\/?([^\.\/]+\.[^\.]+)\.lane(\d+_[12FfRr])\.fastq/) { #Parse 'old' format
		
		$infilesBothStrandsNoEnding{ $samplid }[$i]= "$1.$2"; #Save new format in hash with samplid as keys and inputfiles in array. Note: These files have not been created yet and there is one entry per strand and .ending is removed (.fastq).
		$itrack++; #Track for every lane finished
	    }
	    elsif ($infile{$samplid}[$i] =~ /(\d+)_(\d+)_([^_]+)_([^_]+)_(index[^_]+)_(\d).fastq/) { #Parse 'new' format
	
		$infilesBothStrandsNoEnding{ $samplid }[$i]= "$4.$2_$3_$5."."lane"."$1_$6"; #Save new format in hash with samplid as keys and inputfiles in array. Note: These files have not been created yet and there is one entry per strand and .ending is removed (.fastq).
		$itrack++; #Track for every lane finished
	    }
			    
	}
    }
return $uncompressedFileCounter;
}

sub Checkfnexists {
    
#$_[0] = complete filepath
#$_[1] = file ending

    my $fn;
    $fnt = 0; #Nr of sbatch with identical filenames
    for (my $i=0;$i<999;$i++) { #Number of possible files with the same name
	
	$fn = "$_[0]$i$_[1]"; #filename, filenr and fileending
	$fnt = $i; #Nr of sbatch with identical filenames, global variable
	if (-e $fn) { #if file exists 
	}
	else {
	    $i=999; #Exit loop
	}
	
    }
    $filename = $fn; #Transfer to global variable
    return;
}

sub AddToScriptParameter {
###Checks and sets environmentUppmax or default values to scriptPrameters
    
    my $parameterName = $_[0]; #ParameterName
    my $parameterValue = $_[1]; #Parameter to evaluate
    my $parameterType = $_[2]; #Path or program
    my $parameterDefault = $_[3]; #Default setting
    my $environmentUppmaxDefault = $_[4]; #Specific for Uppmax
    my $associatedProgram = $_[5]; #The parameters program
    my $parameterDependence = $_[6]; #Current parameter is dependent on already set parameter to acquire its value
    my $parameterExistsCheck = $_[7]; #Check if intendent file exists in reference directory
    
##Validation
    #print "parameterName: ".$parameterName, "\n";
    #print "parameterValue: ".$parameterValue, "\n";
    #print "parameterType: ".$parameterType, "\n";
    #print "parameterDefault: ".$parameterDefault, "\n";
    #print "environmentUppmaxDefault: ".$environmentUppmaxDefault, "\n";
    #print "associatedProgram: ".$associatedProgram, "\n";

    if ($parameterType eq "path") {
	
	if ($parameterValue eq 0) { #No input from cmd

	    if (defined($scriptParameter{$parameterName})) { #Input from config file - do nothing

		if ($parameterName eq "sampleIDs") { #SampleIDs is a comma separated list 
		    @sampleIDs = split(/,/, $scriptParameter{'sampleIDs'}); #Transfer to array
		} 
		if ($parameterName eq "picardToolsMergeSamFilesPrevious") {
		    @picardToolsMergeSamFilesPrevious = split(/,/, $scriptParameter{'picardToolsMergeSamFilesPrevious'}); #Transfer to array
		}
		if ($parameterName eq "humanGenomeReference") {
		    if ($scriptParameter{'humanGenomeReference'} =~/^Homo_sapiens.GRCh(\d+\.\d+)/) { #Used to change capture kit genome reference version later
			$humanGenomeReferenceVersion = $1;
			$humanGenomeReferenceSource = "GRCh"; #Ensembl
			$humanGenomeRefereceChromosomePrefix = "nochr";
		    }
		    elsif ($scriptParameter{'humanGenomeReference'} =~/^Homo_sapiens.hg(\d+)/) { #Used to change capture kit genome reference version later
			$humanGenomeReferenceVersion = $1;
			$humanGenomeReferenceSource = "hg"; #Refseq
			$humanGenomeRefereceChromosomePrefix = "chr";
		    }
		}
	    }
	    elsif ( (defined($scriptParameter{'environmentUppmax'})) && ($scriptParameter{'environmentUppmax'} == 1) ) { #Use default 

		if ($environmentUppmaxDefault eq 0) { #Zero should be unlikely to use as a default for "path" 
		    if ($parameterName eq "picardToolsMergeSamFilesPrevious") { #Special case 
			@picardToolsMergeSamFilesPrevious = (); #Empty to not add a 0 as a value, which will cause errors in later conditions use
		    }
		    else {
			print STDERR "\nSupply '-".$parameterName."' if you want to run ".$associatedProgram, "\n\n";
			die $USAGE;
		    }
		}
		else { #Default exists

		    if ($parameterDependence == 1) { #Current parameter is dependent on previous parameter(s)
			
			if ($scriptParameter{'wholeGenomeSequencing'} == 1) {

			    if ($parameterName eq "outDataDir") {
				$scriptParameter{'outDataDir'} = "/proj/".$scriptParameter{'projectID'}."/private/nobackup/genomes";
			    }
			    if ( ($parameterName eq "inFilesDirs") && ($scriptParameter{'pedigreeFile'} ne 0) ) {
				pop(@inFilesDirs); #Remove added 0
				for (my $indirectoryCount=0;$indirectoryCount<scalar(@sampleIDs);$indirectoryCount++) {
				    push(@inFilesDirs, "/proj/".$scriptParameter{'projectID'}."/private/genomes/".$sampleIDs[$indirectoryCount]."/fastq");
				}
				$scriptParameter{'inFilesDirs'} = join(',',@inFilesDirs); #Add to enable recreation of cmd line later
			    }
			    if ( $parameterName eq "outScriptDir") {
				$scriptParameter{'outScriptDir'} = "/proj/".$scriptParameter{'projectID'}."/private/genomes_scripts";
			    }
			}
			else { #Exome

			    if ($parameterName eq "outDataDir") {
				$scriptParameter{'outDataDir'} = "/proj/".$scriptParameter{'projectID'}."/private/nobackup/exomes";
			    }
			    if ( ($parameterName eq "inFilesDirs") && ($scriptParameter{'pedigreeFile'} ne 0) ) {

				pop(@inFilesDirs); #Remove added 0

				for (my $indirectoryCount=0;$indirectoryCount<scalar(@sampleIDs);$indirectoryCount++) {
				    push(@inFilesDirs, "/proj/".$scriptParameter{'projectID'}."/private/exomes/".$sampleIDs[$indirectoryCount]."/fastq");
				}

				$scriptParameter{'inFilesDirs'} = join(',', @inFilesDirs); #Add to enable recreation of cmd line later
			    }
			    if ( $parameterName eq "outScriptDir") {
				$scriptParameter{'outScriptDir'} = "/proj/".$scriptParameter{'projectID'}."/private/exomes_scripts";
			    }
			}
		    }
		    else { #No dependencies on previous parameter(s) and default exits - go ahead and add
			if ($parameterName eq "humanGenomeReference") {
			    if ($environmentUppmaxDefault =~/Homo_sapiens.GRCh(\d+\.\d+)/) {
				$humanGenomeReferenceVersion = $1;
				$humanGenomeReferenceSource = "GRCh"; #Ensembl
				$humanGenomeRefereceChromosomePrefix = "nochr";
			    }
			}
			$scriptParameter{$parameterName} = $environmentUppmaxDefault; #Set environmentUppmax default value
		    }
		}
	    }
	    elsif ($parameterDefault ne 0) { #add default value
		$scriptParameter{$parameterName} = $parameterDefault; #Set default value
	    }
	    else {
	
		if ($parameterName eq "picardToolsMergeSamFilesPrevious") {  
		    @picardToolsMergeSamFilesPrevious = (); #Empty to not add a 0 as a value, which will cause errors in later conditions use
		}
		else {
		    print STDERR "\nSupply '-".$parameterName."' if you want to run ".$associatedProgram, "\n\n";
		    die $USAGE;
		    #my $verbosity = 2;
		    #print"\n";
		    #pod2usage({-message => "Must supply an infile directory as comma separated list.\n",
		    #	   -verbose => $verbosity
		    #	  });
		}
	    }
	}
	else { #Add to enable or overwrite info gathered from config and use in recreation of cmd line later
	     
	    if ($parameterName eq "sampleIDs") {	    
		$scriptParameter{'sampleIDs'} = join(',',@sampleIDs); #Add to enable recreation of cmd line later
		@sampleIDs = split(/,/,join(',', @sampleIDs)); #Enables comma separated list of sample IDs from user supplied cmd info
	    }
	    elsif ($parameterName eq "picardToolsMergeSamFilesPrevious") {
		$scriptParameter{'picardToolsMergeSamFilesPrevious'} = join(',',@picardToolsMergeSamFilesPrevious);
		@picardToolsMergeSamFilesPrevious = split(/,/,join(',', @picardToolsMergeSamFilesPrevious)); #Enables comma separated list of sample IDs from user supplied cmd info
	    }
	    else {
		
		if ($parameterName eq "humanGenomeReference") {
		    
		    if ($parameterValue =~/^Homo_sapiens.GRCh(\d+\.\d+)/) { #Used to change capture kit genome reference version later
			$humanGenomeReferenceVersion = $1;
			$humanGenomeReferenceSource = "GRCh"; #Ensembl
			$humanGenomeRefereceChromosomePrefix = "nochr";
		    }
		    elsif ($parameterValue =~/^Homo_sapiens.hg(\d+)/) { #Used to change capture kit genome reference version later
			$humanGenomeReferenceVersion = $1;
			$humanGenomeReferenceSource = "hg"; #Refseq
			$humanGenomeRefereceChromosomePrefix = "chr";
		    }
		}
		$scriptParameter{$parameterName} = $parameterValue;
	    }
	}

	if ( $parameterExistsCheck && ($parameterExistsCheck eq "directory") ) { #Check dir existence

	    if ($parameterName eq "inFilesDirs") {

		@inFilesDirs = split(/,/, join(',', @inFilesDirs));

		for (my $indirectoryCount=0;$indirectoryCount<scalar(@inFilesDirs);$indirectoryCount++) {

		    unless (-d $inFilesDirs[$indirectoryCount]) { #Check existence of supplied directory
			print STDERR "\nCould not find intended ".$parameterName." directory: ".$inFilesDirs[$indirectoryCount], "\n\n";
			die $USAGE;		
		    }
		}
	    }
	    else {

		unless (-d $scriptParameter{$parameterName}) { #Check existence of supplied directory
		    print STDERR "\nCould not find intended ".$parameterName." directory: ".$scriptParameter{$parameterName}, "\n\n";
		    die $USAGE;		
		}
	    }
	}
	elsif ( $parameterExistsCheck && ($parameterExistsCheck eq "file") ) { #Check file existence in reference directory

	    if ($parameterName eq "mosaikJumpDbStub") {

		my @mosaikJumpDbStubEndings = ("_keys.jmp", "_meta.jmp", "_positions.jmp");

		for (my $mosaikJumpDbStubEndingsCounter=0;$mosaikJumpDbStubEndingsCounter<scalar(@mosaikJumpDbStubEndings);$mosaikJumpDbStubEndingsCounter++) {

		    my $mosaikJumpStubFile = $scriptParameter{'referencesDir'}."/".$scriptParameter{'mosaikJumpDbStub'}.$mosaikJumpDbStubEndings[$mosaikJumpDbStubEndingsCounter];
		    unless (-f $mosaikJumpStubFile) { #Check existence of supplied file in supplied reference dir
			print STDERR "\nCould not find intended ".$parameterName." file: ".$mosaikJumpStubFile, "\n\n";
			die $USAGE;		
		    }
		}
	    } 
	    else {

		unless (-f $scriptParameter{'referencesDir'}."/".$scriptParameter{$parameterName}) { #Check existence of supplied file in supplied reference dir
		    print STDERR "\nCould not find intended ".$parameterName." file: ".$scriptParameter{'referencesDir'}."/".$scriptParameter{$parameterName}, "\n\n";
		    die $USAGE;		
		}
	    }
	}
    }

    if ($parameterType eq "MIP") {
    
	if ($parameterValue eq -1) { #No input from cmd

	    if (defined($scriptParameter{$parameterName})) { #Input from config file - do nothing
	    }
	    elsif ( (defined($scriptParameter{'environmentUppmax'})) && ($scriptParameter{'environmentUppmax'} == 1) ) { #Use default 

		if ($environmentUppmaxDefault eq 0) { #Zero should be unlikely to use as a default for "MIP" 

		    if ($parameterName eq "email") { #Set to zero
			$scriptParameter{'email'} = 0;
		    }
		    else {
			print STDERR "\nSupply '-".$parameterName."' if you want to run ".$associatedProgram, "\n\n";
			die $USAGE;
		    }
		}
		else {
		    $scriptParameter{$parameterName} = $environmentUppmaxDefault; #Set environmentUppmax default value
		}
	    }
	    elsif ($parameterDefault ne 0) {
		$scriptParameter{$parameterName} = $parameterDefault; #Set default value
	    }
	    else {
		if ($parameterName eq "environmentUppmax") { #set to zero
		    $scriptParameter{'environmentUppmax'} = 0;
		}
		elsif ($parameterName eq "email") { #set to zero
		    $scriptParameter{'email'} = 0;
		}
		elsif ($parameterName eq "aligner") { #set to -1
		$scriptParameter{'aligner'} = -1;
		}
		else {
		    print STDERR "\nSupply '-".$parameterName."' if you want to run ".$associatedProgram, "\n\n";
		    die $USAGE;
		}
	    }
	}
	else { #Add to enable or overwrite info gathered from config and use in recreation of cmd line later
	    
	    $scriptParameter{$parameterName} = $parameterValue; 
	}
    }

    if ( $parameterType eq "program") {
	
	if($parameterValue eq -1) { #No input from cmd
	    
	    if (defined($scriptParameter{$parameterName})) { #Input from config file - do nothing
		
		if ($parameterName eq "annovarTableNames") {
		    @annovarTableNames = split(/,/, $scriptParameter{'annovarTableNames'});
		}
		if ($parameterName eq "ImportantDbFileOutFile") {
		    @ImportantDbFileOutFile = split(/,/, $scriptParameter{'ImportantDbFileOutFile'});
		}
	    }
	    elsif ( (defined($scriptParameter{'environmentUppmax'})) && ($scriptParameter{'environmentUppmax'} == 1) ) { #Use default 
		if ($parameterName eq "annovarTableNames") {
##Set default annovar table names
		    @annovarTableNames = ("refgene", "mce46way", "gerp++elem", "segdup", "gwascatalog", "tfbs", "mirna", "snp137NonFlagged", "1000g2012apr_all", "hg19_esp6500si_all.txt", "avsift", "ljb_pp2", "ljb_mt", "ljb_lrt", "ljb_gerp++", "ljb_phylop");
		    $scriptParameter{'annovarTableNames'} = join(",", @annovarTableNames);
		}
		elsif ($parameterName eq "ImportantDbFileOutFile") {
		    my $inDirectoryResearch = $scriptParameter{'outDataDir'}."/".$scriptParameter{'familyID'}."/".$scriptParameter{'aligner'}."/GATK/candidates/ranking";
		    my $inDirectoryClinical = $scriptParameter{'outDataDir'}."/".$scriptParameter{'familyID'}."/".$scriptParameter{'aligner'}."/GATK/candidates/ranking/clinical"; 
		    @ImportantDbFileOutFile = ($inDirectoryResearch."/".$scriptParameter{'familyID'}."_orphan.selectVariants", $inDirectoryClinical."/".$scriptParameter{'familyID'}.".selectVariants");
		    $scriptParameter{'ImportantDbFileOutFile'} = join(",", @ImportantDbFileOutFile);
		}
		else {
		    $scriptParameter{$parameterName} = $environmentUppmaxDefault; #Set environmentUppmax default value
		}
	    }
	    elsif (defined($parameterDefault)) {

		if ($parameterName eq "annovarTableNames") {
##Set default annovar table names
		    @annovarTableNames = ("refgene", "mce46way", "gerp++elem", "segdup", "gwascatalog", "tfbs", "mirna", "snp137NonFlagged", "1000g2012apr_all", "hg19_esp6500si_all.txt", "avsift", "ljb_pp2", "ljb_mt", "ljb_lrt", "ljb_gerp++","ljb_phylop");
		    $scriptParameter{'annovarTableNames'} = join(",", @annovarTableNames);
		}
		elsif ($parameterName eq "ImportantDbFileOutFile") {
		    my $inDirectoryResearch = $scriptParameter{'outDataDir'}."/".$scriptParameter{'familyID'}."/".$scriptParameter{'aligner'}."/GATK/candidates/ranking";
		    my $inDirectoryClinical = $scriptParameter{'outDataDir'}."/".$scriptParameter{'familyID'}."/".$scriptParameter{'aligner'}."/GATK/candidates/ranking/clinical"; 
		    @ImportantDbFileOutFile = ($inDirectoryResearch."/".$scriptParameter{'familyID'}."_orphan.selectVariants", $inDirectoryClinical."/".$scriptParameter{'familyID'}.".selectVariants");
		    $scriptParameter{'ImportantDbFileOutFile'} = join(",", @ImportantDbFileOutFile);
		}
		else {
		    $scriptParameter{$parameterName} = $parameterDefault; #Set default value
		}
	    }
	}
	else {
	    if ($parameterName eq "annovarTableNames") {
		@annovarTableNames = split(/,/, $parameterValue);
	    }
	    if ($parameterName eq "ImportantDbFileOutFile") {
		@ImportantDbFileOutFile = split(/,/, $parameterValue);
	    }
	    $scriptParameter{$parameterName} = $parameterValue;
	}
    }

    if ($parameterName eq "aligner") {

	if ( ($scriptParameter{'pMosaikBuild'} > 0) || ($scriptParameter{'pMosaikAlign'} > 0)) { #Mosaik track
	    
	    if ( ($scriptParameter{'pBwaAln'} == 0) && ($scriptParameter{'pBwaSampe'} == 0)) {
		
		if ( $scriptParameter{'aligner'} eq -1) {
		    $scriptParameter{'aligner'} = "mosaik";
		}
	    }
	    else {
		print STDERR "\n";
		print STDERR "You have to choose either mosaik or bwa to perform alignments or specify which aligner (-aligner 'mosaik' or 'bwa') was used if you want to only run programs after alignment.", "\n\n";
		die $USAGE;
	    }
	}
	elsif ( ($scriptParameter{'pBwaAln'} > 0) || ($scriptParameter{'pBwaSampe'} > 0)) { #BWA track
	    if ( $scriptParameter{'aligner'} eq -1) {
		$scriptParameter{'aligner'} = "bwa";
	    }
	    else {
		print STDERR "\n";
		print STDERR "You have to choose either mosaik or bwa to perform alignments or specify which aligner (-aligner 'mosaik' or 'bwa') was used if you want to only run programs after alignment.", "\n\n";
		die $USAGE;
	    }
	}
	elsif ($scriptParameter{'aligner'} eq -1) {
	    print STDERR "\n";
	    print STDERR "You have to choose either mosaik or bwa to perform alignments or specify which aligner (-aligner 'mosaik' or 'bwa') was used if you want to only run programs after alignment.", "\n\n";
	    die $USAGE;
	}
    }
    
##All parameter set
    if (defined($scriptParameter{$parameterName})) {
	print "Set ".$parameterName." to: ".$scriptParameter{$parameterName}, "\n";
    }
    return;
}

sub SetTargetFiles {
###Check and assign target files from pedigree file or config. Allows indivually adjusted settings of target files. 
    
    my $parameterName = $_[0]; #ParameterName
    my $parameterValue = $_[1]; #Parameter to evaluate
    my $associatedProgram = $_[2]; #The parameters program
    my $parameterExistsCheck = $_[3]; #Check if intendent file exists in reference directory

    my $uncorrectCaptureCounter = 0; #Track no entries or wrong format entry in pedigree file
    
    if ($parameterValue eq 0) { #No input from cmd
	for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) { #Check all samples
	    
	    if (defined($scriptParameter{ $sampleIDs[$sampleIDCounter] }{$parameterName})) { #Input from config file - transfer to sampleInfo
		$sampleInfo{$scriptParameter{'familyID'}}{$sampleIDs[$sampleIDCounter]}{$parameterName} = $scriptParameter{ $sampleIDs[$sampleIDCounter] }{$parameterName};
	    }
	    elsif ($scriptParameter{'environmentUppmax'} == 1) {
		
		if (defined($sampleInfo{ $scriptParameter{'familyID'} }{$sampleIDs[$sampleIDCounter]}{$parameterName})) { #Capture kit check
		    $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{$parameterName} =~ s/GenomeReferenceSource/$humanGenomeReferenceSource/; #Replace with Refseq genome or Ensembl genome
		    $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{$parameterName} =~ s/Version/$humanGenomeReferenceVersion/; #Replace with actual version 
		    $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{$parameterName} =~ s/ChromosomePrefix/$humanGenomeRefereceChromosomePrefix/; #Replace with chromosome prefix
		    $scriptParameter{ $sampleIDs[$sampleIDCounter] }{$parameterName} = $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{$parameterName}; #Add to enable recreation of cmd line later
		}
		else {
		    print STDERR "\nCould not find a target file entry for sample: ".$sampleIDs[$sampleIDCounter], "\n";
		    print STDERR "\nSupply '-".$parameterName."' if you want to run ".$associatedProgram, "\n\n";		   
		    $uncorrectCaptureCounter++;
		}
	    }
	    else { #No capture kit information   
		print STDERR "\nSupply '-".$parameterName."' if you want to run ".$associatedProgram, "\n\n";
		print STDERR "\n";
		die $USAGE;
	    }
	}
	if ($uncorrectCaptureCounter > 0) { #If lacking or not supported in pedigree file
	    print STDERR "\nChange/add capture kit record in pedigree file: ".$scriptParameter{'pedigreeFile'}, "\n";
	    print STDERR "List of pedigree supported capture kits records:\n\n";
	    print STDERR "Pedigree record", "\t", "Capture kit BED-file\n";
	    for my $supportedCaptureKit (keys %supportedCaptureKits) {
		print STDERR $supportedCaptureKit, "\t", $supportedCaptureKits{$supportedCaptureKit}, "\n";
	    }	    
	    print STDERR "\n";
	    die $USAGE;
	}
	if ( $parameterExistsCheck && ($parameterExistsCheck eq "file") ) { #Check file existence in reference directory
	 
	    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) { #Add target file to all samples
		
		unless (-f $scriptParameter{'referencesDir'}."/".$sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{$parameterName}) { #Check for target file in supplied reference dir
		    print STDERR "\nCould not find target file: ".$scriptParameter{'referencesDir'}."/".$sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{$parameterName}, "\n\n";
		    die $USAGE;		
		}   	
	    }
	}
    }
    else {
	for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) { #Add target file to all samples
	    $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{$parameterName} = $parameterValue; #Add target file to sampleInfo info to enable individal adjusted capture calculation for each family member
#Check for file existence
	    unless (-f $scriptParameter{'referencesDir'}."/".$sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{$parameterName}) { #Check for target file in supplied reference dir
		print STDERR "\nCould not find target file: ".$scriptParameter{'referencesDir'}."/".$sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{$parameterName}, "\n\n";
		die $USAGE;		
	    }
	    $scriptParameter{ $sampleIDs[$sampleIDCounter] }{$parameterName} = $parameterValue; #Add to enable recreation of cmd line later
	}
    }

##All parameter set
    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) { #Add target file to all samples
	if ($scriptParameter{ $sampleIDs[$sampleIDCounter] }{$parameterName}) {
	    print "Set ".$parameterName." for ".$sampleIDs[$sampleIDCounter]." to: ".$scriptParameter{ $sampleIDs[$sampleIDCounter] }{$parameterName}, "\n";
	}
    }
    print "\n";
    return;
}

sub CreateFileEndings {

    my $tempFileEnding;
    
    for (my $sampleIDCounter=0;$sampleIDCounter<scalar(@sampleIDs);$sampleIDCounter++) {
	
#SamToolsSort/Index
	if ($scriptParameter{'pSamToolsSort'} > 0) {
	    $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pSamToolsSort'}{'fileEnding'} = "_sorted"; 
	}
	else {
	    $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pSamToolsSort'}{'fileEnding'} = ""; #Just inititate
	}
	
	$tempFileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pSamToolsSort'}{'fileEnding'}; #To enable sequential build-up of fileending
	
#PicardToolsMerge
	if ($scriptParameter{'pPicardToolsMergeSamFiles'} > 0) {
	    if ( (@picardToolsMergeSamFilesPrevious) || (scalar( @{ $infilesLaneNoEnding{ $sampleIDs[$sampleIDCounter] } }) > 1) ) { #Sanity check that we have something to merge
		$sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pPicardToolsMergeSamFiles'}{'fileEnding'} = $tempFileEnding."_merged"; #Adds from previous entry 
	    }
	    else {
		$sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pPicardToolsMergeSamFiles'}{'fileEnding'} = $tempFileEnding."";
	    }
	}
	else  {
	    $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pPicardToolsMergeSamFiles'}{'fileEnding'} = $tempFileEnding."";
	}
	
	$tempFileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pPicardToolsMergeSamFiles'}{'fileEnding'}; #To enable sequential build-up of fileending
	
#PicardToolsMarkduplicates
	if ($scriptParameter{'pPicardToolsMarkduplicates'} > 0) {
	    $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pPicardToolsMarkduplicates'}{'fileEnding'} = $tempFileEnding."_pmd"; #Adds from previous entry 
	}
	else  {
	    $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pPicardToolsMarkduplicates'}{'fileEnding'} = $tempFileEnding."";
	}
	$tempFileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pPicardToolsMarkduplicates'}{'fileEnding'}; #To enable sequential build-up of fileending
	

#Calculate Coverage
	if ($scriptParameter{'pCalculateCoverage'} > 0) {
	    if ($scriptParameter{'pGenomeCoverageBED'} > 0) {
		$sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pGenomeCoverageBED'}{'fileEnding'} = $tempFileEnding."_genomeCoverageBed"; #Adds from previous entry 
	    }
	    else  {
		$sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pGenomeCoverageBED'}{'fileEnding'} = $tempFileEnding."";
	    }
	    if ($scriptParameter{'pCoverageBED'} > 0) {
		$sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pCoverageBED'}{'fileEnding'} = $tempFileEnding."_coverageBed_hist"; #Adds from previous entry
		$sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pCoverageBEDRMDup'}{'fileEnding'} = $tempFileEnding."_rmdup_coverageBed_hist"; #Adds from previous entry
	    }
	    else  {
		$sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pCoverageBED'}{'fileEnding'} = $tempFileEnding."";
		$sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pCoverageBEDRMDup'}{'fileEnding'} = $tempFileEnding."";
	    }
	}
#pSamToolsViewSplitChr
	if ($scriptParameter{'pSamToolsViewSplitChr'} > 0) {
	    $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pSamToolsViewSplitChr'}{'fileEnding'} = $tempFileEnding."_"; #Adds from previous entry 
	}
	else  {
	    $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pSamToolsViewSplitChr'}{'fileEnding'} = $tempFileEnding."";
	}
	$tempFileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pSamToolsViewSplitChr'}{'fileEnding'}; #To enable sequential build-up of fileending
	

#pGATKRealigner
	if ($scriptParameter{'pGATKRealigner'} > 0) {
	    if ($scriptParameter{'pSamToolsViewSplitChr'} > 0) {
		$sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pGATKRealigner'}{'fileEnding'} = $tempFileEnding."rreal_"; #Adds from previous entry 
	    }
	    else {
		$sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pGATKRealigner'}{'fileEnding'} = $tempFileEnding."_rreal_"; #Adds from previous entry 
	    }
	}
	else  {
	    $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pGATKRealigner'}{'fileEnding'} = $tempFileEnding."";
	}
	$tempFileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pGATKRealigner'}{'fileEnding'}; #To enable sequential build-up of fileending
	

#pGATKBaseReCalibration
	if ($scriptParameter{'pGATKBaseRecalibration'} > 0) {
	    $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pGATKBaseRecalibration'}{'fileEnding'} = $tempFileEnding."brecal_"; #Adds from previous entry 
	}
	else  {
	    $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pGATKBaseRecalibration'}{'fileEnding'} = $tempFileEnding."";
	}
	$tempFileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{ $sampleIDs[$sampleIDCounter] }{'pGATKBaseRecalibration'}{'fileEnding'}; #To enable sequential build-up of fileending
	
    }
    
#Per family
#pGATKHaploTypeCaller
    if ($scriptParameter{'pGATKHaploTypeCaller'} > 0) {
	$sampleInfo{ $scriptParameter{'familyID'} }{'pGATKHaploTypeCaller'}{'fileEnding'} = $tempFileEnding.""; #Adds from previous entry. Haplotypecaller changes from .bam --> .vcf, but raw calls
    }
    else  {
	$sampleInfo{ $scriptParameter{'familyID'} }{'pGATKHaploTypeCaller'}{'fileEnding'} = $tempFileEnding."";
    }
    $tempFileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pGATKHaploTypeCaller'}{'fileEnding'}; #To enable sequential build-up of fileending

#pGATKVariantRecalibration
    if ($scriptParameter{'pGATKVariantRecalibration'} > 0) {
	$sampleInfo{ $scriptParameter{'familyID'} }{'pGATKVariantRecalibration'}{'fileEnding'} = $tempFileEnding."vrecal_"; #Adds from previous entry 
    }
    else  {
	$sampleInfo{ $scriptParameter{'familyID'} }{'pGATKVariantRecalibration'}{'fileEnding'} = $tempFileEnding."";
    }
    $tempFileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pGATKVariantRecalibration'}{'fileEnding'}; #To enable sequential build-up of fileending
    
#pAnnovar
    if ($scriptParameter{'pAnnovar'} > 0) {
	$sampleInfo{ $scriptParameter{'familyID'} }{'pAnnovar'}{'fileEnding'} = $tempFileEnding."annovar_"; #Adds from previous entry 
    }
    else  {
	$sampleInfo{ $scriptParameter{'familyID'} }{'pAnnovar'}{'fileEnding'} = $tempFileEnding."";
    }
    $tempFileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pAnnovar'}{'fileEnding'}; #To enable sequential build-up of fileending
    
#pMergeAnnotatedVariants
    if ($scriptParameter{'pMergeAnnotatedVariants'} > 0) {
	$sampleInfo{ $scriptParameter{'familyID'} }{'pMergeAnnotatedVariants'}{'fileEnding'} = $tempFileEnding."merged_"; #Adds from previous entry 
    }
    else  {
	$sampleInfo{ $scriptParameter{'familyID'} }{'pMergeAnnotatedVariants'}{'fileEnding'} = $tempFileEnding."";
    }
    $tempFileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pMergeAnnotatedVariants'}{'fileEnding'}; #To enable sequential build-up of fileending

#pAddDepth
    if ($scriptParameter{'pAddDepth'} > 0) {
	$sampleInfo{ $scriptParameter{'familyID'} }{'pAddDepth'}{'fileEnding'} = $tempFileEnding.""; #Adds from previous entry 
    }
    else  {
	$sampleInfo{ $scriptParameter{'familyID'} }{'pAddDepth'}{'fileEnding'} = $tempFileEnding."";
    }
    $tempFileEnding = $sampleInfo{ $scriptParameter{'familyID'} }{'pAddDepth'}{'fileEnding'}; #To enable sequential build-up of fileending
    
}

sub CheckIfMergedFiles {
#Check if any files for this sampleID were merged previously to set infile and PicardToolsMergeSwitch
    my $sampleID = $_[0];

    my $infile;
    my $mergeLanes; #To pick up merged lanes later 
    my $PicardToolsMergeSwitch = 0;

    if ($sampleInfo{ $scriptParameter{'familyID'} }{$sampleID}{'picardToolsMergeSamFilesPrevious'} == 1) { # Files merged this round with merged file from previous round
	
	for (my $mergeFileCounter=0;$mergeFileCounter<scalar(@picardToolsMergeSamFilesPrevious);$mergeFileCounter++) {
	    
	    if ($picardToolsMergeSamFilesPrevious[$mergeFileCounter] =~ /lane(\d+)|s_(\d+)/) { #Look for lanes_ or lane\d in previously generated file to be merged with current run to be able to extract previous lanes
		
		if($1) {$mergeLanes = $1;} 
		else {$mergeLanes = $2;} #Make sure to always supply lanes from previous regexp  
		$infile = $sampleID."_lanes_".$mergeLanes;
		for (my $laneCounter=0;$laneCounter<scalar(@ { $lane{$sampleID} });$laneCounter++) {
		    $infile .= $lane{$sampleID}[$laneCounter]; #Extract lanes per sampleID
		}
		$PicardToolsMergeSwitch = 1;
	    }
	}
    }
    elsif ( ($scriptParameter{'pPicardToolsMergeSamFiles'} > 0) && (scalar( @{ $infilesLaneNoEnding{$sampleID} }) > 1) ) { #but only if there is more than one mosaikBuild/BWA_Aln file per sample ID (Sanity check)
	$infile = $sampleID."_lanes_";
	for (my $laneCounter=0;$laneCounter<scalar(@ { $lane{$sampleID} });$laneCounter++) {
	    $infile .= $lane{$sampleID}[$laneCounter]; #Extract lanes per sampleID
	}
	$PicardToolsMergeSwitch = 1;
    }
    else {
	$PicardToolsMergeSwitch = 0;
    }
    return ($infile, $PicardToolsMergeSwitch);
}

sub WriteCMDMasterLogg {
    
    open (MASTERL, ">>".$masterLoggName) or die "Can't write to ".$masterLoggName.": $!\n"; #Open file run logg
    
    print MASTERL 
	"-p ".$scriptParameter{'projectID'};
    if ($scriptParameter{'email'}) {
	print MASTERL " -email ".$scriptParameter{'email'};
    }
    print MASTERL " -familyID ".$scriptParameter{'familyID'};
    if ($scriptParameter{'pedigreeFile'}) {
	print MASTERL " -pedigreeFile ".$scriptParameter{'pedigreeFile'};
    }
    print MASTERL
	" -sampleIDs ".$scriptParameter{'sampleIDs'},
	" -inFilesDirs ".$scriptParameter{'inFilesDirs'},
	" -outDataDir ".$scriptParameter{'outDataDir'},   
	" -inScriptDir ".$scriptParameter{'inScriptDir'},
	" -outScriptDir ".$scriptParameter{'outScriptDir'},
	" -referencesDir ".$scriptParameter{'referencesDir'};
    if ($scriptParameter{'humanGenomeReference'}) {
	print MASTERL " -humanGenomeReference ".$scriptParameter{'humanGenomeReference'};
    }
    print MASTERL
	" -pGZip ".$scriptParameter{'pGZip'},
	" -pRemovalRedundantFiles ".$scriptParameter{'pRemovalRedundantFiles'},
	" -wholeGenomeSequencing ".$scriptParameter{'wholeGenomeSequencing'},
	" -maximumCores ",$scriptParameter{'maximumCores'};
    if ($scriptParameter{'configFile'} ne 0) {
	print MASTERL " -configFile ".$scriptParameter{'configFile'};
    }
    if ($scriptParameter{'environmentUppmax'} == 1) {
	print MASTERL " -environmentUppmax ".$scriptParameter{'environmentUppmax'};
    }
    print MASTERL " -pFastQC ".$scriptParameter{'pFastQC'};
    if ($scriptParameter{'aligner'}) {
	print MASTERL " -aligner ".$scriptParameter{'aligner'};
    }
    print MASTERL
	" -pMosaikBuild ".$scriptParameter{'pMosaikBuild'};
    if ($scriptParameter{'pMosaikBuild'} > 0 ) {
	print MASTERL " -mosaikBuildMedianFragLength ".$scriptParameter{'mosaikBuildMedianFragLength'};
    }
    print MASTERL
	" -pMosaikAlign ".$scriptParameter{'pMosaikAlign'};
    if ($scriptParameter{'pMosaikAlign'} > 0 ) {
	print MASTERL 
	    " -mosaikAlignReference ".$scriptParameter{'mosaikAlignReference'},
	    " -mosaikAlignNeuralNetworkPeFile ".$scriptParameter{'mosaikAlignNeuralNetworkPeFile'},
	    " -mosaikAlignNeuralNetworkSeFile ".$scriptParameter{'mosaikAlignNeuralNetworkSeFile'},
	    " -mosaikJumpDbStub ".$scriptParameter{'mosaikJumpDbStub'};
    }
    print MASTERL " -pBwaAln ".$scriptParameter{'pBwaAln'};
    if ($scriptParameter{'pBwaAln'} > 0 ) {
	print MASTERL " -bwaAlnQualityTrimming ".$scriptParameter{'bwaAlnQualityTrimming'};
    }
    print MASTERL 
	" -pBwaSampe ".$scriptParameter{'pBwaSampe'},
	" -pSamToolsSort ".$scriptParameter{'pSamToolsSort'};
    if ($scriptParameter{'picardToolsPath'}) {
	print MASTERL
	    " -picardToolsPath ".$scriptParameter{'picardToolsPath'};
    }
    print MASTERL
	" -pPicardToolsMergeSamFiles ".$scriptParameter{'pPicardToolsMergeSamFiles'};
    if (scalar(@picardToolsMergeSamFilesPrevious)) {
	print MASTERL
	    " -picardToolsMergeSamFilesPrevious ".$scriptParameter{'picardToolsMergeSamFilesPrevious'};
    }
    print MASTERL
	" -pPicardToolsMarkduplicates ".$scriptParameter{'pPicardToolsMarkduplicates'};
    print MASTERL
	" -pCalculateCoverage ".$scriptParameter{'pCalculateCoverage'};
    if ($scriptParameter{'pCalculateCoverage'} > 0) {
	print MASTERL
	    " -pGenomeCoverageBED ".$scriptParameter{'pGenomeCoverageBED'},
	    " -pCoverageBED ".$scriptParameter{'pCoverageBED'},
	    " -pQaCompute ".$scriptParameter{'pQaCompute'},
	    " -pPicardToolsCollectMultipleMetrics ".$scriptParameter{'pPicardToolsCollectMultipleMetrics'},
	    " -pPicardToolsCalculateHSMetrics ".$scriptParameter{'pPicardToolsCalculateHSMetrics'};
	if ( ($scriptParameter{'pGenomeCoverageBED'} > 0) || ($scriptParameter{'pQaCompute'} > 0) ) {
	    print MASTERL
		" -xCoverage ".$scriptParameter{'xCoverage'};
	}    
    }
    if ($identicalCaptureBedCounter eq scalar(@sampleIDs)) { #Same capture kit for all sampleIDs
	print MASTERL 
	    " -exomeTargetBed ".$scriptParameter{$sampleIDs[0]}{'exomeTargetBed'};
    }
    elsif ($exomeTargetBed) {
	print MASTERL 
	    " -exomeTargetBed ".$scriptParameter{$sampleIDs[0]}{'exomeTargetBed'};
    }
    if ($identicalCaptureBedIntervalCounter eq scalar(@sampleIDs)) { #Same capture kit for all sampleIDs
	print MASTERL 
	    " -exomeTargetBedInfileList ".$scriptParameter{$sampleIDs[0]}{'exomeTargetBedInfileList'},
	    " -exomeTargetPaddedBedInfileList ".$scriptParameter{$sampleIDs[0]}{'exomeTargetPaddedBedInfileList'};
    }
    elsif ($exomeTargetBedInfileList) {
	print MASTERL
	    " -exomeTargetBedInfileList ".$scriptParameter{$sampleIDs[0]}{'exomeTargetBedInfileList'},
	    " -exomeTargetPaddedBedInfileList ".$scriptParameter{$sampleIDs[0]}{'exomeTargetPaddedBedInfileList'};
    }
    print MASTERL
	" -pRCovPlots ".$scriptParameter{'pRCovPlots'},
	" -pSamToolsViewSplitChr ".$scriptParameter{'pSamToolsViewSplitChr'};
    if ($scriptParameter{'genomeAnalysisToolKitPath'}) {
	print MASTERL
	    " -genomeAnalysisToolKitPath ".$scriptParameter{'genomeAnalysisToolKitPath'};
    }	
    print MASTERL
	" -pGATKRealigner ".$scriptParameter{'pGATKRealigner'};
    if ($scriptParameter{'pGATKRealigner'} > 0) {
	print MASTERL
	    " -GATKReAlignerINDELKnownSet1 ".$scriptParameter{'GATKReAlignerINDELKnownSet1'},
	    " -GATKReAlignerINDELKnownSet2 ".$scriptParameter{'GATKReAlignerINDELKnownSet2'},
	    " -GATKTempDirectory ".$scriptParameter{'GATKTempDirectory'};
    } 
    print MASTERL
	" -pGATKBaseRecalibration ".$scriptParameter{'pGATKBaseRecalibration'};
    if ($scriptParameter{'pGATKBaseRecalibration'} > 0) {
	print MASTERL
	    " -GATKBaseReCalibrationSNPKnownSet ".$scriptParameter{'GATKBaseReCalibrationSNPKnownSet'};
    }    
    if ( ($scriptParameter{'pGATKRealigner'} > 0) || ($scriptParameter{'pGATKBaseRecalibration'} > 0) ) {
	print MASTERL
	" -GATKTempDirectory ".$scriptParameter{'GATKTempDirectory'};
    }
    print MASTERL 
	" -pGATKHaploTypeCaller ".$scriptParameter{'pGATKHaploTypeCaller'};
    if ($scriptParameter{'pGATKHaploTypeCaller'} > 0) {
	print MASTERL
	    " -GATKHaploTypeCallerSNPKnownSet ".$scriptParameter{'GATKHaploTypeCallerSNPKnownSet'};
    }
    print MASTERL 
	" -pGATKVariantRecalibration ".$scriptParameter{'pGATKVariantRecalibration'};
    if ($scriptParameter{'pGATKVariantRecalibration'} > 0) {
	print MASTERL
	    " -GATKExomeReferenceSNPs ".$scriptParameter{'GATKExomeReferenceSNPs'},
	    " -GATKVariantReCalibrationTrainingSetHapMap ".$scriptParameter{'GATKVariantReCalibrationTrainingSetHapMap'},
	    " -GATKVariantReCalibrationTrainingSetDbSNP ".$scriptParameter{'GATKVariantReCalibrationTrainingSetDbSNP'},
	    " -GATKVariantReCalibrationTrainingSet1000GOmni ".$scriptParameter{'GATKVariantReCalibrationTrainingSet1000GOmni'},
	    " -GATKVariantReCalibrationTrainingSetMills ".$scriptParameter{'GATKVariantReCalibrationTrainingSetMills'},
	    " -GATKVariantReCalibrationTSFilterLevel ".$scriptParameter{'GATKVariantReCalibrationTSFilterLevel'};
    }
    print MASTERL
	" -writeConfigFile ".$scriptParameter{'writeConfigFile'}, "\n";
    #Note FileHandle MASTERL not closed
    return;
}