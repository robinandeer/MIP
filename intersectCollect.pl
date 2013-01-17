#!/usr/bin/perl - w

use strict;
use warnings;
use File::Basename;

#Intersects and collects information based on 1-4 keys present (mandatory) in each file to be investigated. The set of elements to be interrogated are decided by the first db file elements unless the merge option is used. The db files are supplied using the -db flag, which should point to a db_master file (tab-sep) with the format (DbPath\tSeparator\tColumn_Keys\tChr_Column\tMatching\tColumns_to_Extract\tFile_Size\t). NOTE that matching should be either range or exact. Currently the range option only supports 3-4 keys i.e. only 3 keys are used to define the range look up (preferbly chr,start,stop). Range db file should be sorted -k1,1 -k2,2n if it contains chr information. If the merge option is used then all overlapping and unique elements are added to the final list. Beware that this option is memory demanding.    
   
#Copyright 2012 Henrik Stranneheim

=head1 SYNOPSIS

intersectCollect.3.2.pl -db db_master.txt -o outfile.txt

=head2 COMMANDS AND OPTIONS

-db/--dbfile A tab-sep file containing 1 db per line with format (DbPath\tSeparator\tColumn_Keys\tChr_Column\tMatching\tColumns_to_Extract\tFile_Size\t). NOTE: db file and col nr are 0-based. 

-o/--outfile The output file (defaults to annovar_master.txt)

-ocol/--outcolumns The order of the col in the outfile. NOTE: db file and col nr are 0-based. (if col 2,3 in 1st db file & col 0,1 in 0th db file is desired then ocol should be 1_2,1_3,0_0,0_1. You are free to include, exclude or rearrange the order as you like. The information can also be recorded in the db master file as outcolumns=fileNr_colNr,,fileN_colN. Precedence 1. command line 2. Recorded in db master file 3. Order of appearance in db master file. 

-oheaders/--outheaders The headers for each column in output file. The information can also be recorded in the db master file as outheaders=header,,headerN.

-m/--merge Merge all entries found within db files. Unique entries (not found in first db file) will be included. Do not support range matching. (Defaults to "0") 

-prechr/--prefix_chromosomes "chrX" or just "X" (defaults to "X")

=head3 I/O

Input format db master file (tab-sep)

Output format (tab separate list)

=cut

use Pod::Usage;
use Pod::Text;
use Getopt::Long;

use vars qw($USAGE);

BEGIN {
    $USAGE =
	qq{intersectCollect.3.1.pl -db db_master.txt -o outfile.txt
               -db/--dbfile A tab-sep file containing 1 db per line with format (DbPath\tSeparator\tColumn_Keys\tChr_Column\tMatching\tColumns_to_Extract\tFile_Size\t). NOTE: db file and col nr are 0-based.
                  1. DbPath = Complete path to db file. First file determines the nr of elements that are subsequently used to collects information. [string]
                  2. Separator = Anything that can be inserted into perls split function. [string]
                  3. Column_Keys = The column number(s) for the key values that are to be matched (1-4 keys supported). [Number]
                  4. Chr_Column = The column number(s) for the chr information. Set to "Na" if not applicable and the program will not try to use chr information. [Number, Na]
                  5. Columns_to_Extract = The column number(s) for the information to extract from the db file(s). [Number]
                  6. Matching = The type of matching to apply to the keys. Range db file should be sorted -k1,1 -k2,2n if it contains chr information. Currently range has only been tested using chromosomal coordinates. ["range", "exact"].
                  7. File_Size = The size of the db file. If it is large another sub routine is used to collect the information to ensure speed and proper memory handling. ["small", "large"]
               -o/--outfile The output file (defaults to intersectCollect.txt)
               -ocol/--outcolumns The order of the col in the outfile. NOTE: db file and col nr are 0-based. (if col 2,3 in 1st db file & col 0,1 in 0th db file is desired then ocol should be 1_2,1_3,0_0,0_1. You are free to include, exclude or rearrange the order as you like. The information can also be recorded in the db master file as outcolumns=fileNr_colNr,,fileN_colN. 
                  Precedence: 1. command line 2. Recorded in db master file 3. Order of appearance in db master file.
               -oheaders/--outheaders The headers for each column in output file. The information can also be recorded in the db master file as outheaders=header,,headerN. 
                  Precedence: 1. command line 2. Recorded in db master file
               -m/--merge Merge all entries found within db files. Unique entries (not found in first db file) will be included. Do not support range matching. (Defaults to "0")
               -prechr/--prefix_chromosomes "chrX" or just "X" (defaults to "X")
	   };
    
}

my ($db,$of,$ocol,$oheaders,$merge,$prechr,$help) = (0,"intersectCollect.txt",0,0,0,0);

my (@chr, @ocol, @oheaders);

###
#User Options
###

GetOptions('db|dbfile:s'  => \$db,
	   'o|outfile:s'  => \$of,
	   'ocol|outcolumns:s'  => \@ocol, #comma separated
	   'oheaders|outheaders:s'  => \@oheaders, #comma separated
	   'm|merge:n'  => \$merge,
	   'prechr|prefix_chromosomes:n'  => \$prechr,
	   'h|help' => \$help,
	   );

die $USAGE if( $help );

if ($db eq 0) {
    print STDERR "\n", "Need to specify db file by using flag -db. 1 db file per line. Format: DbPath\tSeparator\tColumn_Keys\tChr_Column\tMatching\tColumns_to_Extract\tFile_Size\t \n";
    die $USAGE;
}
if (@ocol) {
    @ocol = split(/,/,join(',',@ocol)); #Enables comma separated list
    print STDOUT "Order of output columns as supplied by user: ";
    for (my $out_col=0;$out_col<scalar(@ocol);$out_col++) {
	print STDOUT $ocol[$out_col], "\t";
    } 
    print STDOUT "\n";
    $ocol =1; #To not rewrite order supplied by user with the order in the Db master file
}
if (@oheaders) { 
    @oheaders = split(/,/,join(',',@oheaders)); #Enables comma separated list
    print STDOUT "Order of output columns headers as supplied by user: ";
    for (my $out_header=0;$out_header<scalar(@oheaders);$out_header++) {
	print STDOUT $oheaders[$out_header], "\t";
    }
    print STDOUT "\n";
    $oheaders =1; #To not rewrite order of headers supplied by user with the order of headers in the Db master file
}
if ($prechr == 0) {
    @chr = ("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y","MT"); #Chr for enhanced speed in collecting information and reducing memory consumption
}
else {
    @chr = ("chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11","chr12","chr13","chr14","chr15","chr16","chr17","chr18","chr19","chr20","chr21","chr22","chrX","chrY","chrMT");
}

my $dbFileCounter=0; #Global count of the nr of files in $db
my (@allVariants, @allVariants_unique, @allVariants_sorted); #temporary arrays for sorting
my (%db, %RangeVariants, %RangeBins, %db_file_pos); #Db file structure, range/bin intervalls, binary positions in db files
my (%allVariants, %allVariants_chr, %allVariants_chr_unique, %allVariants_chr_sorted); #hash for collected information and temporary hashes for sorting
my %unsorted; #For later sorting using ST 

###
#MAIN
###

if ($db) {
    ReadDbMaster($db,$ocol,$oheaders); #Collect information on db files from master file supplied with -db
}

#Read all range Db file first to enable check against first db file keys as it is read.
for (my $dbFileNr=0;$dbFileNr<$dbFileCounter;$dbFileNr++) {

    if ($db{$dbFileNr}{'Matching'} eq "range") {
	if ($merge == 0) { #Only include elements found in first db file. Not supported by merge option 
	    ReadDbRange($db{$dbFileNr}{'File'},$dbFileNr);
	}
    }
}

for (my $dbFileNr=0;$dbFileNr<$dbFileCounter;$dbFileNr++) {

    if ($dbFileNr ==0) {#Add first keys and columns to extract and determines valid keys for subsequent Db files
	if ($merge == 0) { #Only include elements found in first db file 
	    ReadInfile($db{$dbFileNr}{'File'}, $dbFileNr);
	    %RangeVariants = (); #All done with range queries.
	}
    }
    elsif ($db{$dbFileNr}{'Size'} eq "large") {#Reads large Db file(s). Large (long) Db file(s) will slow down the performance due to the fact that the file using the ReadDbFiles sub routine would be scanned linearly for every key (i.e. if chr coordinates are used). To circumvent this the large db file(s) are completely read and all entries matching the infile are saved using the keys supplied by the user. This is done for all large db file(s), and the extracted information is then keept in memory. This ensures that only entries matching the keys in the infile are keept, keeping the memory use low compared to reading the large db and keeping the whole large db file(s) in memory. As each chr in is processed in ReadDbFiles the first key is erased reducing the search space (somewhat) and memory consumption (more).
	if ($merge == 0) { #Only include elements found in first db file 
	    ReadDbLarge($db{$dbFileNr}{'File'},$dbFileNr);
	}
    }
}

#if chrNr are used
if ($db{0}{'Chr_column'} ne "Na") { #For chromosome queries
 
    if ($merge == 0) { #Only include elements found in first db file
	for (my $chr=0;$chr<scalar(@chr);$chr++) {
	    
	    if ($chr[$chr+1]) {
		ReadDbFiles($chr[$chr],$chr[$chr+1]); #Scans each file for chr entries only processing those i.e. will scan the db file once for each chr in @chr.   
	    }
	    else {
		ReadDbFiles($chr[$chr]); #Last chr
	    }
	    SortAllVariantsST($chr[$chr]); #Sort all variants per chr
	    WriteChrVariants($of, $chr[$chr]); #Write all variants to file per chr
	    #Reset for next chr
	    $allVariants{$chr[$chr]} = (); %allVariants_chr = (); %allVariants_chr_unique = (); %allVariants_chr_sorted = ();
	    @allVariants = (); @allVariants_unique = (); @allVariants_sorted = ();
	    
	}
    }
    else  { #Only for db files that are to be merged
	for (my $chr=0;$chr<scalar(@chr);$chr++) {
	    
	    if ($chr[$chr+1]) {
		ReadInfileMerge($db{0}{'File'}, 0,$chr[$chr],$chr[$chr+1]);
		ReadDbFilesMerge($chr[$chr], $chr[$chr+1]); #Scans each file for chr entries only processing those i.e. will scan the db file once for each chr in @chr.   
	    }
	    else {
		ReadInfileMerge($db{0}{'File'}, 0,$chr[$chr]);
		ReadDbFilesMerge($chr[$chr]); #Scans each file for chr entries only processing those i.e. will scan the db file once for each chr in @chr.
	    }
	    SortAllVariantsMergeST($chr[$chr]); #Sort all variants per chr
	    WriteAllVariantsMerge($of, $chr[$chr]); #Write all variants to file per chr
#Reset for next chr
	    %allVariants = (); %allVariants_chr = (); %allVariants_chr_unique = (); %allVariants_chr_sorted = ();
	    @allVariants = (); @allVariants_unique = (); @allVariants_sorted = ();
	}
    }
}

else { #Other type of keys
    ReadDbFilesNoChr();
    WriteAll($of);
}


###
#Sub Routines
###

sub ReadDbMaster {
#Reads DbMaster file
#DbPath\tSeparator\Column_Keys\tColumns_to_Extract\t. First 4 columns are mandatory.
#$_[0] = filename
#$_[1] = "0" || "1", depending on the user supplied an output order (1) or not (0)
#$_[2] = "0" || "1", depending on the user supplied an output header (1) or nor (0)

    my $local_ocol = $_[1];
    my $local_headers = $_[2];
    my (@dbColumnKeys, @dbColumnKeysNr, @dbColumnsToExtract);
    open(DBM, "<$_[0]") or die "Can't open $_[0]:$!, \n";    
    
    while (<DBM>) {
	
	chomp $_;
	
	if (m/^\s+$/) {		# Avoid blank lines
	    next;
	}
	if (m/^#/) {		# Avoid #
	    next;
	}
	if ($_ =~/^outcolumns\=/i) { #Locate order of out columns if recorded in db master (precedence: 1. Command line, 2. Recorded in db master file 3. Order of appearance in db master file)
	    if ($local_ocol == 0) { #Create output order determined by entry in db master file
		$ocol = 1; #Ensure that precedence is kept
		@ocol = split(",", $'); #'  
	    }
	    next;
	}
	if ($_ =~/^outheaders\=/i) { #Locate order of out columns header if recorded in db master (precedence: 1. Command line, 2. Recorded in db master file)
	    if ($local_headers == 0) { #Create output header order and entries determined by entry in db master file
		$oheaders = 1; #Ensure that precedence is kept. Note: Global
		@oheaders = split(",", $'); #'
	    }
	    next;
	}		
	if ( $_ =~/^(\S+)/ ) {	
	    my @temp = split("\t",$_);	    #Loads variant calls
	    #Set mandatory values
	    $db{$dbFileCounter}{'File'}=$temp[0]; #Add dbFile Name
	    $db{$dbFileCounter}{'Separator'}=$temp[1]; #Add dbFile Seperator
	    @dbColumnKeys = split(/,/,join(',',$temp[2])); #Enable comma separeted entry for column keys
	    push (@dbColumnKeysNr, scalar(@dbColumnKeys)); #Check that correct Nr of keys are supplied for all files (dictated by first file)
	    $db{$dbFileCounter}{'Column_Keys'}= [@dbColumnKeys]; #Add dbFile column keys
	    $db{$dbFileCounter}{'Chr_column'}=$temp[3]; #Add dbFile Chr column (For skipping lines in files, should be replaced by general indexing of db files in the future
	    $db{$dbFileCounter}{'Matching'}=$temp[4]; # (exact or range). Range only valid for chr coordinates or similiar. 
	    if ($db{$dbFileCounter}{'Matching'} eq "range") { 
		if ($dbFileCounter == 0) { #Cannot handle range queries for the determining elements
		    print STDERR "\n", "First Db file should be used with exact mathing \n";
		    die $USAGE;
		}
		if ( (scalar(@dbColumnKeys)  <=2 ) ) { #Must have at least three keys presently to perform range queries
		    print STDERR "\n", "To few keys to use for range comparison, currently only three keys are supported for the range file, but for are allowed within same run for exact Db files \n";
		    die $USAGE;
		}
	    }
	    if ( scalar(@dbColumnKeysNr) > 1 ) { #Check that same number of keys are consistently added. 
		if ( ($dbColumnKeysNr[0] ne $dbColumnKeysNr[1]) && ($db{$dbFileCounter}{'Matching'} ne "range") ) {
		    print STDERR "Not the same number of keys as in previous db files in db file: $db{$dbFileCounter}{'File'}\n";
		    die $USAGE
		}
		pop(@dbColumnKeysNr);
	    }
	    @dbColumnsToExtract = split(/,/,join(',',$temp[5])); #Enable comma separeted entry for columns to extract
	    if ($ocol eq 0) { #Create output order determined by appearance in db master file
		for (my $out_col=0;$out_col<scalar(@dbColumnsToExtract);$out_col++) {
		    push (@ocol, $dbFileCounter."_".$dbColumnsToExtract[$out_col]);
		}
	    }
	    $db{$dbFileCounter}{'Column_To_Extract'}= [@dbColumnsToExtract]; #Add dbFile columns to extract
	    $db{$dbFileCounter}{'Size'}=$temp[6]; #Determine the way to parse the db file
###
#Validation	    
###
	    print "$db{$dbFileCounter}{'File'}\t $db{$dbFileCounter}{'Separator'}\t";
	    for (my $col_keys=0;$col_keys<scalar( @ {$db{$dbFileCounter}{'Column_Keys'} });$col_keys++) {
		print $db{$dbFileCounter}{'Column_Keys'}[$col_keys], ",";
	    }
	    print "\t";
	    print "$db{$dbFileCounter}{'Chr_column'}\t";
	    for (my $col_to_extract=0;$col_to_extract<scalar( @ {$db{$dbFileCounter}{'Column_To_Extract'} });$col_to_extract++) {
		print $db{$dbFileCounter}{'Column_To_Extract'}[$col_to_extract], ",";
	    }
	    print "\t";
	    print $db{$dbFileCounter}{'Matching'}, "\t", $db{$dbFileCounter}{'Size'}, "\n";
	    $dbFileCounter++;
	}
    }
    if ($local_headers == 0) { #No order of output columns headers supplied by user 
	if ($oheaders == 1) {
	    print STDOUT "Order of output columns headers determined by db master file: ";
	    for (my $out_col_head=0;$out_col_head<scalar(@oheaders);$out_col_head++) {
		print STDOUT $oheaders[$out_col_head], "\t";
	    } 
	}
	else {
	    print STDOUT "Proceeding without attaching header information. Headers can be supplied using flag -oheaders or by recording header information (and order) in the db master file by adding 'outheaders=header1,,headerN' before any db files";
	}
	print STDOUT "\n";
    }
    if ($local_ocol eq 0) { #No order of output columns supplied by user
	if ($ocol == 1) {
	    print STDOUT "Order of output columns determined by db master file: ";
	    for (my $out_col=0;$out_col<scalar(@ocol);$out_col++) {
		print STDOUT $ocol[$out_col], "\t";
	    } 
	    print STDOUT "\n";
	}
 	else {
	    print STDOUT "No users supplied order of output columns. Will order the columns according to appearance in db master file\n";
	}
    }
    close(DBM);
    print STDOUT "Finished Reading Db file: $_[0]","\n";
    print STDOUT "Found $dbFileCounter Db files","\n";
    return;
}

sub ReadDbFiles {
#Reads all db files collected from Db master file, except first db file and db files with features "large", "range". These db files are handled by different subroutines.
#$_[0] = chr number
#$_[1] = next chr number
    
    for (my $dbFileNr=1;$dbFileNr<$dbFileCounter;$dbFileNr++) { #All db files (in order of appearance in $db) except first db which has already been handled	
	
	if ( ($db{$dbFileNr}{'Size'} eq "large") || ($db{$dbFileNr}{'Matching'} eq "range") ) { #Already handled
	    next;
	}
	else { #Read files per chr (i.e. multiple times)
	    
	    open(DBF, "<$db{$dbFileNr}{'File'}") or die "Can't open $db{$dbFileNr}{'File'}:$!, \n";    
	    if ( defined($db_file_pos{$dbFileNr}) ) { #if file has been searched previously
		seek(DBF, $db_file_pos{$dbFileNr},0) or die "Couldn't seek to $db_file_pos{$dbFileNr} in $db{$dbFileNr}{'File'}: $!\n"; #Seek to binary position in file where we left off
	    }
	    while (<DBF>) {
		
		chomp $_;
		#if ($.==1) {
		  #  print STDERR "Started at line $.\n";
		   # my $pos = tell(DBF);
		   # if ( defined ($db_file_pos{$dbFileNr}) ) {print STDERR "Started at pos ", $db_file_pos{$dbFileNr}, "\n";}
		   # else {print STDERR "Started at pos ",  $pos, "\n";}
		#}
		if (m/^\s+$/) {		# Avoid blank lines
		    next;
		}
		if (m/^#/) {		# Avoid #
		    next;
		}		
		if ( $_ =~/^(\S+)/) {
		    
		    my @temp = split($db{$dbFileNr}{'Separator'},$_); #Splits columns on separator and loads line
		    
		    if ($_[1] && $temp[$db{$dbFileNr}{'Chr_column'}] eq $_[1]) { #If next chr is found return (Since all numerically infiles are sorted this is ok)
			
			#print STDOUT "Finished Reading chr$_[0] in Infile $db{$dbFileNr}{'File'}","\n";
			#$db_file_pos{$dbFileNr} = tell(DBF); # Save  binary position in file to enable seek when revisiting e.g. next chr
			#print "Ended at pos $db_file_pos{$dbFileNr} in $db{$dbFileNr}{'File'}\n";
			close(DBF);
			last;
		    }
		    if ( $temp[$db{$dbFileNr}{'Chr_column'}] eq $_[0]) { #If chr number and chr in line match - go ahead and process
			
                        #Depending on the number of column keys supplied by user in db master file . 
			if (scalar( @{$db{$dbFileNr}{'Column_Keys'}}) == 1) {
			    
			    if ( $allVariants{ $temp[ $db{$dbFileNr}{'Column_Keys'}[0] ] }) { #If first key match to already processed first db file 
				for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$dbFileNr}{'Column_To_Extract'}});$columns_to_extract++) {
				    
				    my $columnId = $dbFileNr."_".$db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract];
				    $allVariants{ $temp[ $db{$dbFileNr}{'Column_Keys'}[0] ] }{$columnId}=$temp[ $db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract] ];
				}
			    }
			}
			if (scalar( @{$db{$dbFileNr}{'Column_Keys'}}) == 2) {
			    if ( $allVariants{ $temp[ $db{$dbFileNr}{'Column_Keys'}[0] ] }{ $temp[ $db{$dbFileNr}{'Column_Keys'}[1] ] }) {
				for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$dbFileNr}{'Column_To_Extract'}});$columns_to_extract++) {
				    
				    my $columnId = $dbFileNr."_".$db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract];
				    $allVariants{ $temp[ $db{$dbFileNr}{'Column_Keys'}[0] ] }{ $temp[ $db{$dbFileNr}{'Column_Keys'}[1] ] }{$columnId}= $temp[ $db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract] ];
				}
			    }
			}
			if (scalar( @{$db{$dbFileNr}{'Column_Keys'}}) == 3) {
			    if ( $allVariants{ $temp[ $db{$dbFileNr}{'Column_Keys'}[0] ] }{ $temp[ $db{$dbFileNr}{'Column_Keys'}[1] ] }{ $temp[ $db{$dbFileNr}{'Column_Keys'}[2] ]}) {
				for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$dbFileNr}{'Column_To_Extract'}});$columns_to_extract++) {
				    
				    my $columnId = $dbFileNr."_".$db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract];
				    $allVariants{ $temp[ $db{$dbFileNr}{'Column_Keys'}[0] ]}{ $temp[ $db{$dbFileNr}{'Column_Keys'}[1] ]}{ $temp[ $db{$dbFileNr}{'Column_Keys'}[2] ]}{$columnId}= $temp[ $db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract] ];
				}
			    }
			}
			if (scalar( @{$db{$dbFileNr}{'Column_Keys'}}) == 4) {
			    if ( $allVariants{ $temp[ $db{$dbFileNr}{'Column_Keys'}[0] ] }{ $temp[ $db{$dbFileNr}{'Column_Keys'}[1] ] }{ $temp[ $db{$dbFileNr}{'Column_Keys'}[2] ]}{ $temp[ $db{$dbFileNr}{'Column_Keys'}[3] ]}) {
				for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$dbFileNr}{'Column_To_Extract'}});$columns_to_extract++) {
				    
				    my $columnId = $dbFileNr."_".$db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract];
				    $allVariants{ $temp[ $db{$dbFileNr}{'Column_Keys'}[0] ] }{ $temp[ $db{$dbFileNr}{'Column_Keys'}[1] ] }{ $temp[ $db{$dbFileNr}{'Column_Keys'}[2] ] }{ $temp[ $db{$dbFileNr}{'Column_Keys'}[3] ]}{$columnId}= $temp[ $db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract] ];
				}
			    }
			}
		    }
		} 	
	    }
	}
	close(DBF);
	print STDOUT "Finished Reading chr$_[0] in Infile: $db{$dbFileNr}{'File'}","\n";
    }
    return;
}

sub ReadDbFilesNoChr {
#Reads all db files collected from Db master file, except first db file and db files with features "large", "range". These db files are handled by different subroutines.
    
    for (my $dbFileNr=1;$dbFileNr<$dbFileCounter;$dbFileNr++) { #All db files (in order of appearance in $db) except first db which has already been handled	
	
	if ( ($db{$dbFileNr}{'Size'} eq "large") || ($db{$dbFileNr}{'Matching'} eq "range") ) { #Already handled
	    next;
	}
	else { #Read files per chr (i.e. multiple times)
	    open(DBF, "<$db{$dbFileNr}{'File'}") or die "Can't open $db{$dbFileNr}{'File'}:$!, \n";    
	    
	    while (<DBF>) {
		
		chomp $_;
		
		if (m/^\s+$/) {		# Avoid blank lines
		    next;
		}
		if (m/^#/) {		# Avoid #
		    next;
		}		
		if ( $_ =~/^(\S+)/) {
		    
		    my @temp = split($db{$dbFileNr}{'Separator'},$_); #Splits columns on separator and loads line
		    
#Depending on the number of column keys supplied by user. NOTE: Must always be the same nr of columns containing the same keys 
		    if (scalar( @{$db{$dbFileNr}{'Column_Keys'}}) == 1) {
			if ( $allVariants{ $temp[ $db{$dbFileNr}{'Column_Keys'}[0] ] } ) { #If first key match
			    for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$dbFileNr}{'Column_To_Extract'}});$columns_to_extract++) {
				
				my $columnId = $dbFileNr."_".$db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract];
				$allVariants{ $temp[ $db{$dbFileNr}{'Column_Keys'}[0] ] }{$columnId}=$temp[ $db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract] ];
##Code to collapse some entries and make serial additions of others. CMMS_External specific and not part of original programe. To enable commen previous line and remove comments from subsequent lines.
				#if ($temp[ $db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract] ]) {
				 #   if ($columns_to_extract>=3) {
				#	$allVariants{ $temp[ $db{$dbFileNr}{'Column_Keys'}[0] ] }{$columnId}.="$temp[ $db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract] ];";
				 #   }
				  #  else {
				#	$allVariants{ $temp[ $db{$dbFileNr}{'Column_Keys'}[0] ] }{$columnId}=$temp[ $db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract] ];
				 #   }
				#}
			    }
			}
			#else {
			 #   print $_, "\n";
			#}
		    }
		    if (scalar( @{$db{$dbFileNr}{'Column_Keys'}}) == 2) {
			if ( $allVariants{ $temp[ $db{$dbFileNr}{'Column_Keys'}[0] ] }{ $temp[ $db{$dbFileNr}{'Column_Keys'}[1] ] }) {
			    for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$dbFileNr}{'Column_To_Extract'}});$columns_to_extract++) {
				
				my $columnId = $dbFileNr."_".$db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract];
				$allVariants{ $temp[ $db{$dbFileNr}{'Column_Keys'}[0] ] }{ $temp[ $db{$dbFileNr}{'Column_Keys'}[1] ] }{$columnId}= $temp[ $db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract] ];
			    }
			}
		    }
		    if (scalar( @{$db{$dbFileNr}{'Column_Keys'}}) == 3) {
			if ( $allVariants{ $temp[ $db{$dbFileNr}{'Column_Keys'}[0] ] }{ $temp[ $db{$dbFileNr}{'Column_Keys'}[1] ] }{ $temp[ $db{$dbFileNr}{'Column_Keys'}[2] ]}) {
			    for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$dbFileNr}{'Column_To_Extract'}});$columns_to_extract++) {
				
				my $columnId = $dbFileNr."_".$db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract];
				$allVariants{ $temp[ $db{$dbFileNr}{'Column_Keys'}[0] ]}{ $temp[ $db{$dbFileNr}{'Column_Keys'}[1] ]}{ $temp[ $db{$dbFileNr}{'Column_Keys'}[2] ]}{$columnId}= $temp[ $db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract] ];
				
			    }
			}
		    }
		    if (scalar( @{$db{$dbFileNr}{'Column_Keys'}}) == 4) {
			if ( $allVariants{ $temp[ $db{$dbFileNr}{'Column_Keys'}[0] ] }{ $temp[ $db{$dbFileNr}{'Column_Keys'}[1] ] }{ $temp[ $db{$dbFileNr}{'Column_Keys'}[2] ]}{ $temp[ $db{$dbFileNr}{'Column_Keys'}[3] ]}) {
			    for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$dbFileNr}{'Column_To_Extract'}});$columns_to_extract++) {
				
				my $columnId = $dbFileNr."_".$db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract];
				$allVariants{ $temp[ $db{$dbFileNr}{'Column_Keys'}[0] ] }{ $temp[ $db{$dbFileNr}{'Column_Keys'}[1] ] }{ $temp[ $db{$dbFileNr}{'Column_Keys'}[2] ] }{ $temp[ $db{$dbFileNr}{'Column_Keys'}[3] ]}{$columnId}= $temp[ $db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract] ];
			    }
			}
		    }
		}
	    } 	
	}
	close(DBF);
	print STDOUT "Finished Reading Db Infile: $db{$dbFileNr}{'File'}","\n";
    }
    return;
}

sub ReadDbLarge {
#Reads large Db file(s). Large (long) Db file(s) will slow down the performance due to the fact that the file is scanned linearly for every key (i.e. if chr coordinates are used). To circumvent this the large db file(s) are completely read and all entries matching the infile are saved using the keys supplied by the user. This is done for all large db file(s), and the extracted information is then keept in memory. This ensures that only entries matching the keys in the infile are keept, keeping the memory use low compared to reading the large db and keeping the whole large db file(s) in memory. As each chr in is processed in ReadDbFiles the first key is erased reducing the search space and memory consumption.
#$_[0] = filename
#$_[1] = db file number
    
    open(RDBL, "<$_[0]") or die "Can't open $_[0]:$!, \n";    
    
    
    while (<RDBL>) {
	
	chomp $_;
	
	if (m/^\s+$/) {		# Avoid blank lines
	    next;
	}
	if (m/^#/) {		# Avoid #
	    next;
	}		
	if ( $_ =~/^(\S+)/ ) {	
	    my @temp = split($db{$_[1]}{'Separator'},$_); #Loads line

	    if (scalar( @{$db{$_[1]}{'Column_Keys'}}) == 1) {
		if ( $allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] } ) { #Check full entry
		    for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$_[1]}{'Column_To_Extract'}});$columns_to_extract++) { #Extract info
			
			my $columnId = $_[1]."_".$db{$_[1]}{'Column_To_Extract'}[$columns_to_extract];			
			$allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{$columnId}= $temp[ $db{$_[1]}{'Column_To_Extract'}[$columns_to_extract] ];
		    }		    
		}
	    }
	    if (scalar( @{$db{$_[1]}{'Column_Keys'}}) == 2) {	    
		if ( $allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] } ) { #Needed to not run out of memory in hash look-up
		    
		    if ( $allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[1] ] } ){ #Check full entry
			for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$_[1]}{'Column_To_Extract'}});$columns_to_extract++) { #Extract info
			    
			    my $columnId = $_[1]."_".$db{$_[1]}{'Column_To_Extract'}[$columns_to_extract];			
			    $allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[1] ] }{$columnId}= $temp[ $db{$_[1]}{'Column_To_Extract'}[$columns_to_extract] ];
			}		    
		    }
		}
	    }
	    if (scalar( @{$db{$_[1]}{'Column_Keys'}}) == 3) {
		if ( $allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] } ) { #Needed to not run out of memory in hash look-up
		    
		    if ( $allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[1] ] } ){ #Needed to not run out of memory in hash look-up
			
			if ( $allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[1] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[2] ] }) { #Check full entry
			    for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$_[1]}{'Column_To_Extract'}});$columns_to_extract++) { #Extract info
				
				my $columnId = $_[1]."_".$db{$_[1]}{'Column_To_Extract'}[$columns_to_extract];			
				$allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[1] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[2] ] }{$columnId}= $temp[ $db{$_[1]}{'Column_To_Extract'}[$columns_to_extract] ];
			    }		    
			}
		    }		
		    
		}
	    }
	    if (scalar( @{$db{$_[1]}{'Column_Keys'}}) == 4) {
		if ( $allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] } ) { #Needed to not run out of memory in hash look-up
		    
		    if ( $allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[1] ] } ){ #Needed to not run out of memory in hash look-up
			
			if ( $allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[1] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[2] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[3] ]} ) { #Check full entry
			    for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$_[1]}{'Column_To_Extract'}});$columns_to_extract++) { #Extract info
				
				my $columnId = $_[1]."_".$db{$_[1]}{'Column_To_Extract'}[$columns_to_extract];			
				$allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[1] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[2] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[3] ]}{$columnId}= $temp[ $db{$_[1]}{'Column_To_Extract'}[$columns_to_extract] ];
			    }		    
			}
		    }
		}
	    }
	}
    } 	
    close(RDBL);
    print STDOUT "Finished Reading Large Db file: $_[0]","\n";
    return;
}

sub ReadInfile {
#Reads the first db file, which is the file that all subsequent elements will matched to i.e. only information for elements present in the first file will be added)
#$_[0] = Db file name
#$_[1] = Db file nr
    
    open(RIF, "<$_[0]") or die "Can't open $_[0]:$!, \n";    
    
    while (<RIF>) {
	
	chomp $_;
	
	if (m/^\s+$/) {		# Avoid blank lines
	    next;
	}
	if (m/^#/) {		# Avoid #
	    next;
	}		
	if ( $_ =~/^(\S+)/ ) {
	    my @temp = split($db{$_[1]}{'Separator'},$_); #Loads line
	    if (scalar( @{$db{0}{'Column_Keys'}}) == 1) {
		
		for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$_[1]}{'Column_To_Extract'}});$columns_to_extract++) {
		    
		    my $columnId = $_[1]."_".$db{$_[1]}{'Column_To_Extract'}[$columns_to_extract];
		    $allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{$columnId}= $temp[ $db{$_[1]}{'Column_To_Extract'}[$columns_to_extract] ];
		}
	    }
	    if (scalar( @{$db{0}{'Column_Keys'}}) == 2) {

		for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$_[1]}{'Column_To_Extract'}});$columns_to_extract++) {
		    
		    my $columnId = $_[1]."_".$db{$_[1]}{'Column_To_Extract'}[$columns_to_extract];
		    $allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[1] ] }{$columnId}= $temp[ $db{$_[1]}{'Column_To_Extract'}[$columns_to_extract] ];
		}
		push (@{$unsorted{$temp[ $db{$_[1]}{'Column_Keys'}[0] ]}}, $temp[ $db{$_[1]}{'Column_Keys'}[1] ]);
	    }
	    if (scalar( @{$db{0}{'Column_Keys'}}) == 3) {
		for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$_[1]}{'Column_To_Extract'}});$columns_to_extract++) {
		    
		    my $columnId = $_[1]."_".$db{$_[1]}{'Column_To_Extract'}[$columns_to_extract];
		    $allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[1] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[2] ] }{$columnId}= $temp[ $db{$_[1]}{'Column_To_Extract'}[$columns_to_extract] ];	    
		}
		push (@{$unsorted{$temp[ $db{$_[1]}{'Column_Keys'}[0] ]}}, $temp[ $db{$_[1]}{'Column_Keys'}[1] ]);
		for my $rangeDbFiles (keys %RangeVariants) { #All Range Db Files
		    
		    for my $firstkey (keys % { $RangeVariants{$rangeDbFiles} })  { #For all first key e.g. chrNr
			
			if ($firstkey eq $temp[ $db{$_[1]}{'Column_Keys'}[0] ]) { #Find correct key e.g. chrNr (enhance speed)
			   
			    for my $binNr (keys %{ $RangeBins{$rangeDbFiles}{$firstkey} }) { #For all bins within range Db file and first key (enhance speed)
					
				if ($temp[ $db{$_[1]}{'Column_Keys'}[1] ] >= $RangeBins{$rangeDbFiles}{$firstkey}{$binNr}{'lowerboundary'} && $temp[ $db{$_[1]}{'Column_Keys'}[1] ] <= $RangeBins{$rangeDbFiles}{$firstkey}{$binNr}{'upperboundary'} ) { #Found in Range Bin Db file, correct firstkey, within bin and second key overlapps bin range.
				    
				    for my $startpos (keys % { $RangeVariants{$rangeDbFiles}{$firstkey}{$binNr} })  { #For all Db file range start positions within bin
				 	
					if ( $startpos <= $temp[ $db{$_[1]}{'Column_Keys'}[1] ]) { #second key is downstream of start position
					    
					    for my $stoppos (keys % { $RangeVariants{$rangeDbFiles}{$firstkey}{$binNr}{$startpos} })  { #For all range stop positions 
						
						if ( $stoppos >= $temp[ $db{$_[1]}{'Column_Keys'}[1] ] ) { #second key is upstream of stop position i.e overlapping
						    
						    for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$rangeDbFiles}{'Column_To_Extract'}});$columns_to_extract++) {
							my $columnId = $rangeDbFiles."_".$db{$rangeDbFiles}{'Column_To_Extract'}[$columns_to_extract]; #RangeDb file is not random key but ordered Db file from initial for loop.		
							$allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[1] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[2] ] }{$columnId}.="$RangeVariants{$rangeDbFiles}{$firstkey}{$binNr}{$startpos}{$stoppos}{$columnId};";
							#print $allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[1] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[2] ] }{$columnId}, "\n";
						    }
						}
					    }
					}
					#Catches events where second key is upstream of range start, but third key is within range i.e. we do not require complete feature overlap
					elsif ( $startpos <= $temp[ $db{$_[1]}{'Column_Keys'}[2] ]) { #third key is downstream of start position
					    
					    for my $stoppos (keys % { $RangeVariants{$rangeDbFiles}{$firstkey}{$binNr}{$startpos} })  { #For all range stop positions 
						
						if ( $stoppos >= $temp[ $db{$_[1]}{'Column_Keys'}[2] ] ) { #third key is upstream of stop position i.e overlapping
						    
						    for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$rangeDbFiles}{'Column_To_Extract'}});$columns_to_extract++) {
							my $columnId = $rangeDbFiles."_".$db{$rangeDbFiles}{'Column_To_Extract'}[$columns_to_extract]; #RangeDb file is not random key but ordered Db file from initial for loop.		
							$allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[1] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[2] ] }{$columnId}.="$RangeVariants{$rangeDbFiles}{$firstkey}{$binNr}{$startpos}{$stoppos}{$columnId};";
							#print $allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[1] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[2] ] }{$columnId},"\n";
						    }
						}
					    }
					}
				    }
				    last; #No overlapping bins - move to next line
				}
			    }
			}
		    }
		}
	    } 
	    if (scalar( @{$db{0}{'Column_Keys'}}) == 4) {
		
		for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$_[1]}{'Column_To_Extract'}});$columns_to_extract++) {
		    
		    my $columnId = $_[1]."_".$db{$_[1]}{'Column_To_Extract'}[$columns_to_extract];
		    $allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[1] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[2] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[3] ]}{$columnId}= $temp[ $db{$_[1]}{'Column_To_Extract'}[$columns_to_extract] ];
		    
		}
		push (@{$unsorted{$temp[ $db{$_[1]}{'Column_Keys'}[0] ]}}, $temp[ $db{$_[1]}{'Column_Keys'}[1] ]);
		for my $rangeDbFiles (keys %RangeVariants) { #All Range Db Files
		    
		    for my $firstkey (keys % { $RangeVariants{$rangeDbFiles} })  { #For all first key e.g. chrNr
			
			if ($firstkey eq $temp[ $db{$_[1]}{'Column_Keys'}[0] ]) { #Find correct key e.g. chrNr (enhance speed)
			    
			    for my $binNr (keys %{ $RangeBins{$rangeDbFiles}{$firstkey} }) { #For all bins within range Db file and first key (enhance speed)
				
				if ($temp[ $db{$_[1]}{'Column_Keys'}[1] ] >= $RangeBins{$rangeDbFiles}{$firstkey}{$binNr}{'lowerboundary'} && $temp[ $db{$_[1]}{'Column_Keys'}[1] ] <= $RangeBins{$rangeDbFiles}{$firstkey}{$binNr}{'upperboundary'} ) { #Found in Range Bin Db file, correct firstkey, within bin and second key overlapps bin range.
				    
				    for my $startpos (keys % { $RangeVariants{$rangeDbFiles}{$firstkey}{$binNr} })  { #For all Db file range start positions within bin

					if ( $startpos <= $temp[ $db{$_[1]}{'Column_Keys'}[1] ]) { #second key is downstream of start position
					    
					    for my $stoppos (keys % { $RangeVariants{$rangeDbFiles}{$firstkey}{$binNr}{$startpos} })  { #For all range stop positions 
						
						if ( $stoppos >= $temp[ $db{$_[1]}{'Column_Keys'}[1] ] ) { #second key is upstream of stop position i.e overlapping
						    
						    for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$rangeDbFiles}{'Column_To_Extract'}});$columns_to_extract++) {
							my $columnId = $rangeDbFiles."_".$db{$rangeDbFiles}{'Column_To_Extract'}[$columns_to_extract]; #RangeDb file is not random key but ordered Db file from initial for loop.		
							$allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[1] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[2] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[3] ]}{$columnId}.="$RangeVariants{$rangeDbFiles}{$firstkey}{$binNr}{$startpos}{$stoppos}{$columnId};";
						    }
						}
					    }
					}
					#Catches events where second key is upstream of range start, but third key is within range i.e. we do not require complete feature overlap
					elsif ( $startpos <= $temp[ $db{$_[1]}{'Column_Keys'}[2] ]) { #third key is downstream of start position
					    
					    for my $stoppos (keys % { $RangeVariants{$rangeDbFiles}{$firstkey}{$binNr}{$startpos} })  { #For all range stop positions 
						
						if ( $stoppos >= $temp[ $db{$_[1]}{'Column_Keys'}[2] ] ) { #third key is upstream of stop position i.e overlapping
						    
						    for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$rangeDbFiles}{'Column_To_Extract'}});$columns_to_extract++) {
							my $columnId = $rangeDbFiles."_".$db{$rangeDbFiles}{'Column_To_Extract'}[$columns_to_extract]; #RangeDb file is not random key but ordered Db file from initial for loop.		
							$allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[1] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[2] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[3] ]}{$columnId}.="$RangeVariants{$rangeDbFiles}{$firstkey}{$binNr}{$startpos}{$stoppos}{$columnId};";
						    }
						}
					    }
					}
				    }
				    last; #No overlapping bins since border spanning events are added to all Bin that the event is spanned - move to next line
				}
			    }
			}
		    }
		}
	    } 	
	}
    }
    close(RIF);
    print STDOUT "Finished Reading key Db file: $_[0]","\n";
    return;
}



sub ReadDbRange {
#Reads db file for allowing overlapping feature look-up
#$_[0] = Db file name
#$_[1] = Db file nr
    
#Loop through file to assign bins based on third key highest value
    my %EstimateBinsize;

    open(DBR, "<$_[0]") or die "Can't open $_[0]:$!, \n";    

    while (<DBR>) {
	
	chomp $_;
	
	if (m/^\s+$/) {		# Avoid blank lines
	    next;
	}
	if (m/^#/) {		# Avoid #
	    next;
	}		
	if ( $_ =~/^(\S+)/ ) {	
	    my @temp = split($db{$_[1]}{'Separator'},$_);	    #Loads line
	 
	    if ( (scalar( @{$db{0}{'Column_Keys'}}) == 3) || (scalar( @{$db{0}{'Column_Keys'}} ) == 4) ) {

		if ( $EstimateBinsize{$_[1]}{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ]}{'highest'} && $temp[ $db{$_[1]}{'Column_Keys'}[2] ] > $EstimateBinsize{$_[1]}{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ]}{'highest'} ) { #Within Firstkey and highest value of thirdkey e.g. chrNr and stoppos
		$EstimateBinsize{$_[1]}{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ]}{'highest'} = $temp[ $db{$_[1]}{'Column_Keys'}[2] ];
		}
		else { #Initiate binsize
		    $EstimateBinsize{$_[1]}{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ]}{'highest'} = $temp[ $db{$_[1]}{'Column_Keys'}[2] ];
		}
	    }
	}
    }
    
for my $firstkey (keys %{$EstimateBinsize{$_[1]} }) { #Set size of bins and add to %RangeBins. Used later to add values in Rnage Db file to correct bin and when infile is read to reduce the number of hash look-ups that needs to be performed for range Db files. Assumes random distribution of ranges across bins.
    my $lowerboundary=0;
    my $upperboundary;
    my $binsize = $EstimateBinsize{$_[1]}{$firstkey}{'highest'}/100;
    $upperboundary = $binsize; 
    #print $firstkey, "\t", $EstimateBinsize{$_[1]}{$firstkey}{'highest'}, "\t", $binsize, "\n";

    for (my $binNr=0;$binNr<100;$binNr++) {
	
	$RangeBins{$_[1]}{$firstkey}{$binNr}{'lowerboundary'}=$lowerboundary;
	$RangeBins{$_[1]}{$firstkey}{$binNr}{'upperboundary'}= $upperboundary;
	$lowerboundary = $lowerboundary + $binsize; #Starting from 0
	$upperboundary= $upperboundary + $binsize; #Starting from binsize
	#print "LowerB: $RangeBins{$_[1]}{$firstkey}{$binNr}{'lowerboundary'}\n";
	#print "UpperB: $RangeBins{$_[1]}{$firstkey}{$binNr}{'upperboundary'}\n"; 
    }

}
    %EstimateBinsize=();
    close(DBR);

#Collect values within Range Db file, now that the bin values have been set. A range can end up in several bins if the range spans bin borders. Then as a exackt match is done a bin the range within that bin can actually expand outside of the bin. This is to catch elements that independent of bin/range size.

    open(DBR, "<$_[0]") or die "Can't open $_[0]:$!, \n";    
    while (<DBR>) {
	
	chomp $_;
	
	if (m/^\s+$/) {		# Avoid blank lines
	    next;
	}
	if (m/^#/) {		# Avoid #
	    next;
	}		
	if ( $_ =~/^(\S+)/ ) {	
	    my @temp = split($db{$_[1]}{'Separator'},$_); #Loads line

	    if ( (scalar( @{$db{0}{'Column_Keys'}}) == 3) || (scalar( @{$db{0}{'Column_Keys'}} ) == 4) ) {

		for my $firstkey (keys %{$RangeBins{$_[1]} }) { #All firstkeys
		    
		    if ( $temp[ $db{$_[1]}{'Column_Keys'}[0] ] eq $firstkey ) { #Correct firstkey - check bins
		
			for (my $binNr=0;$binNr<100;$binNr++) { #For all bins
			  
			    if ( $temp[ $db{$_[1]}{'Column_Keys'}[1] ] >= $RangeBins{$_[1]}{$firstkey}{$binNr}{'lowerboundary'} && $temp[ $db{$_[1]}{'Column_Keys'}[2] ] <= $RangeBins{$_[1]}{$firstkey}{$binNr}{'upperboundary'}) { #Whole range within bin - go ahead and add
				for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$_[1]}{'Column_To_Extract'}});$columns_to_extract++) {
				    
				    my $columnId = $_[1]."_".$db{$_[1]}{'Column_To_Extract'}[$columns_to_extract];
				    $RangeVariants{$_[1]}{$temp[ $db{$_[1]}{'Column_Keys'}[0] ]}{$binNr}{$temp[ $db{$_[1]}{'Column_Keys'}[1] ]}{$temp[ $db{$_[1]}{'Column_Keys'}[2] ]}{$columnId}= $temp[ $db{$_[1]}{'Column_To_Extract'}[$columns_to_extract] ]; #RangeVariants{dbNr}{key1}{BinNr}{range_start}{range_stop}{columnId}
				    #print "Within 1 bin:\t", $RangeVariants{$_[1]}{$temp[ $db{$_[1]}{'Column_Keys'}[0] ]}{$binNr}{$temp[ $db{$_[1]}{'Column_Keys'}[1] ]}{$temp[ $db{$_[1]}{'Column_Keys'}[2] ]}{$columnId}, "\n";
				}
				last;
			    }
			    elsif ( ($temp[ $db{$_[1]}{'Column_Keys'}[1] ] >= $RangeBins{$_[1]}{$firstkey}{$binNr}{'lowerboundary'}) && ($temp[ $db{$_[1]}{'Column_Keys'}[2] ] >= $RangeBins{$_[1]}{$firstkey}{$binNr}{'upperboundary'}) && ($temp[ $db{$_[1]}{'Column_Keys'}[1] ] <= $RangeBins{$_[1]}{$firstkey}{$binNr}{'upperboundary'}) ) { #Range spans bins
				for (my $spanBinNr=$binNr;$spanBinNr<100;$spanBinNr++) {
				    if ( $temp[ $db{$_[1]}{'Column_Keys'}[2] ] >= $RangeBins{$_[1]}{$firstkey}{$spanBinNr}{'upperboundary'} ) { #Not found upper limit yet
					for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$_[1]}{'Column_To_Extract'}});$columns_to_extract++) {
					    
					    my $columnId = $_[1]."_".$db{$_[1]}{'Column_To_Extract'}[$columns_to_extract];
					    $RangeVariants{$_[1]}{$temp[ $db{$_[1]}{'Column_Keys'}[0] ]}{$spanBinNr}{$temp[ $db{$_[1]}{'Column_Keys'}[1] ]}{$temp[ $db{$_[1]}{'Column_Keys'}[2] ]}{$columnId}= $temp[ $db{$_[1]}{'Column_To_Extract'}[$columns_to_extract] ]; #RangeVariants{dbNr}{key1}{BinNr}{range_start}{range_stop}{columnId}
					    #print "Spanning bins:\t", $RangeVariants{$_[1]}{$temp[ $db{$_[1]}{'Column_Keys'}[0] ]}{$binNr}{$temp[ $db{$_[1]}{'Column_Keys'}[1] ]}{$temp[ $db{$_[1]}{'Column_Keys'}[2] ]}{$columnId}, "\n";
					}
				    }
				    elsif ( $temp[ $db{$_[1]}{'Column_Keys'}[2] ] >= $RangeBins{$_[1]}{$firstkey}{$spanBinNr}{'lowerboundary'} ) { #Found upper limit and check to see if upper limit is before start of bin - if so then add to bin and break
					for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$_[1]}{'Column_To_Extract'}});$columns_to_extract++) {
					    
					    my $columnId = $_[1]."_".$db{$_[1]}{'Column_To_Extract'}[$columns_to_extract];
					    $RangeVariants{$_[1]}{$temp[ $db{$_[1]}{'Column_Keys'}[0] ]}{$spanBinNr}{$temp[ $db{$_[1]}{'Column_Keys'}[1] ]}{$temp[ $db{$_[1]}{'Column_Keys'}[2] ]}{$columnId}= $temp[ $db{$_[1]}{'Column_To_Extract'}[$columns_to_extract] ]; #RangeVariants{dbNr}{key1}{BinNr}{range_start}{range_stop}{columnId}
					    #print "End bin:\t", $RangeVariants{$_[1]}{$temp[ $db{$_[1]}{'Column_Keys'}[0] ]}{$binNr}{$temp[ $db{$_[1]}{'Column_Keys'}[1] ]}{$temp[ $db{$_[1]}{'Column_Keys'}[2] ]}{$columnId}, "\n";
					}
					last;
				    }
				    else {
					$binNr=$spanBinNr;
					last;
				    }
				}
			    }
			}
		    }
		}
	    }
	}
    }
    close(DBR);
    print STDOUT "Finished Reading Range key Db file: $_[0]","\n";
    return;
}

sub SortAllVariantsST {
#Creates an array of all position which are unique and in sorted ascending order
#$_[0] = chr number
#$_[1] = db file number   
    
    my $firstKey = $_[0];
    my %seen = (); 

#Unique entries only
    @{$allVariants_chr_unique{$firstKey} } = grep { ! $seen{$_} ++ } @{$unsorted{$_[0]} };
#Sort using the Schwartzian Transform 
    @{$allVariants_chr_sorted{$firstKey} } =  map { $_->[0] }
    sort { $a->[0] <=> $b->[0] }
    map { [$_] }
    @{$allVariants_chr_unique{$firstKey} };

    $unsorted{$_[0]}=(); #Reset for this chr
   
}

sub SortAllVariants {
#Creates an array of all position which are unique and in sorted ascending order
#$_[0] = chr number
#$_[1] = db file number   
    
    my $firstKey = $_[0];
    my %seen = (); 

    if (scalar( @{$db{0}{'Column_Keys'}}) > 1) {
	
	for my $secondKey (keys %{ $allVariants{$firstKey} } )  { #For all secondkeys
	    
	    push ( @{$allVariants_chr{$firstKey} },$secondKey );
	}
	@{$allVariants_chr_unique{$firstKey} } = grep { ! $seen{$_} ++ } @{$allVariants_chr{$firstKey} }; #Unique entries only 
	@{$allVariants_chr_sorted{$firstKey} } = sort { $a <=> $b } @{ $allVariants_chr_unique{$firstKey} }; #Sorts keys to be able to print sorted table later 
	print STDOUT "Sorted all non overlapping entries\n";
    }
}

sub WriteChrVariants {
#Prints tab separated file of all collected db file info in ascending order dictaded by %$allVariants_chr
#$_[0] = filename
#$_[1] = chr number
    
    my $filename = $_[0];
    my $chr = $_[1];
    
    if ( ($_[1] eq 1) || ($_[1] eq "chr1") ) {
	open (WAV, ">$filename") or die "Can't write to $filename: $!\n";
	if ($oheaders == 1) { #Print header if supplied
	    print WAV "#";
	    for (my $out_header=0;$out_header<scalar(@oheaders);$out_header++) {
		print WAV "$oheaders[$out_header]\t";
	    }
	    print WAV "\n";
	}
    }
    else {
	open (WAV, ">>$filename") or die "Can't write to $filename: $!\n";
    }

    if (scalar( @{$db{'0'}{'Column_Keys'}}) == 1) { #Any db file should be fine since all have to have the same nr of keys
	
	for (my $out_col=0;$out_col<scalar(@ocol);$out_col++ ) {
	    
	    if ( defined($allVariants{$chr}{$ocol[$out_col]}) ) {
		print WAV $allVariants{$chr}{$ocol[$out_col]}, "\t";
	    }
	    else {
		print WAV "-", "\t";
	    }
	}
	print WAV "\n";
    }
    if (scalar( @{$db{'0'}{'Column_Keys'}}) == 2) { #Any db file should be fine since all have to have the same nr of keys

	for (my $i=0;$i<scalar( @{$allVariants_chr_sorted{$chr} } );$i++)  { #For all pos per chr	
	    
	    my $secondKey = $allVariants_chr_sorted{$chr}[$i]; #pos keys to hash from sorted arrray
	    
	    for (my $out_col=0;$out_col<scalar(@ocol);$out_col++ ) {
		
		if ( defined($allVariants{$chr}{$secondKey}{$ocol[$out_col]}) ) {
		    print WAV $allVariants{$chr}{$secondKey}{$ocol[$out_col]}, "\t";
		}
		else {
		    print WAV "-", "\t";
		}
	    }
	    print WAV "\n";
	}
    }
    if (scalar( @{$db{'0'}{'Column_Keys'}}) == 3) { #Any db file should be fine since all have to have the same nr of keys
	
	for (my $i=0;$i<scalar( @{$allVariants_chr_sorted{$chr} } );$i++)  { #For all pos per chr	
	    
	    my $secondKey = $allVariants_chr_sorted{$chr}[$i]; #pos keys to hash from sorted arrray
	    
	    for my $thirdKey (keys % {$allVariants{$chr}{$secondKey} }) {
		
		for (my $out_col=0;$out_col<scalar(@ocol);$out_col++ ) {
		    
		    if ( defined($allVariants{$chr}{$secondKey}{$thirdKey}{$ocol[$out_col]}) ) {
			print WAV $allVariants{$chr}{$secondKey}{$thirdKey}{$ocol[$out_col]}, "\t";
		    }
		    else {
			print WAV "-", "\t";
		    }
		}
		print WAV "\n";   
	    }
	}
    }
    if (scalar( @{$db{'0'}{'Column_Keys'}}) == 4) { #Any db file should be fine since all have to have the same nr of keys
	
	for (my $i=0;$i<scalar( @{$allVariants_chr_sorted{$chr} } );$i++)  { #For all pos per chr	
	    
	    my $secondKey = $allVariants_chr_sorted{$chr}[$i]; #pos keys to hash from sorted arrray

	    for my $thirdKey (keys % {$allVariants{$chr}{$secondKey} }) {
		
		for my $fourthKey (keys % {$allVariants{$chr}{$secondKey}{$thirdKey} }) {
		    
		    for (my $out_col=0;$out_col<scalar(@ocol);$out_col++ ) {
			
			if ( defined($allVariants{$chr}{$secondKey}{$thirdKey}{$fourthKey}{$ocol[$out_col]}) ) { #Seperate zero from undef
			    print WAV $allVariants{$chr}{$secondKey}{$thirdKey}{$fourthKey}{$ocol[$out_col]}, "\t";
			}
			else {
			    print WAV "-", "\t";
			}
		    }
		    print WAV "\n";
		}
	    }
	}
    }
    close (WAV);
    if ($prechr == 0) {
	print STDOUT "Finished Writing Master file for: chr$_[1]","\n";
    }
    else {
	print STDOUT "Finished Writing Master file for: $_[1]","\n";
    }
    return;
}

sub WriteAll {
#Prints tab separated file of all collected db file info 
#$_[0] = filename
    
    my $filename = $_[0];

    open (WAV, ">$filename") or die "Can't write to $filename: $!\n";
    if ($oheaders == 1 ) { #Print header if supplied
	print WAV "#";
	for (my $out_header=0;$out_header<scalar(@oheaders);$out_header++) {
	    print WAV "$oheaders[$out_header]\t";
	}
	print WAV "\n";
    }
    if (scalar( @{$db{'0'}{'Column_Keys'}}) == 1) { #Any db file should be fine since all have to have the same nr of keys
	
	for my $firstkey (keys %allVariants) { #All firstkeys
	    
	    for (my $out_col=0;$out_col<scalar(@ocol);$out_col++ ) {
		
		if ( defined($allVariants{$firstkey}{$ocol[$out_col]}) ) {
		    print WAV $allVariants{$firstkey}{$ocol[$out_col]}, "\t";
		}
		else {
		    print WAV "-", "\t";
		}
	    }
	    print WAV "\n";
	}
    }
    if (scalar( @{$db{'0'}{'Column_Keys'}}) == 2) { #Any db file should be fine since all have to have the same nr of keys
	
	for my $firstkey (keys %allVariants) { #All firstkeys
	    
	    for my $secondKey (keys % {$allVariants{$firstkey} }) {
		
		for (my $out_col=0;$out_col<scalar(@ocol);$out_col++ ) {
		    
		    if ( defined($allVariants{$firstkey}{$secondKey}{$ocol[$out_col]}) ) {
			print WAV $allVariants{$firstkey}{$secondKey}{$ocol[$out_col]}, "\t";
		    }
		    else {
			print WAV "-", "\t";
		    }
		}
		print WAV "\n";
	    }
	}
    }
    if (scalar( @{$db{'0'}{'Column_Keys'}}) == 3) { #Any db file should be fine since all have to have the same nr of keys

	for my $firstkey (keys %allVariants) { #All firstkeys
	    
	    for my $secondKey (keys % {$allVariants{$firstkey} }) {
		
		for my $thirdKey (keys % {$allVariants{$firstkey}{$secondKey} }) {
		    
		    for (my $out_col=0;$out_col<scalar(@ocol);$out_col++ ) {
			
			if ( defined($allVariants{$firstkey}{$secondKey}{$thirdKey}{$ocol[$out_col]}) ) {
			    print WAV $allVariants{$firstkey}{$secondKey}{$thirdKey}{$ocol[$out_col]}, "\t";
			}
			else {
			    print WAV "-", "\t";
			}
		    }
		    print WAV "\n";   
		}
	    }
	}
    }
    if (scalar( @{$db{'0'}{'Column_Keys'}}) == 4) { #Any db file should be fine since all have to have the same nr of keys
	
	for my $firstkey (keys %allVariants) { #All firstkeys
	    
	    for my $secondKey (keys % {$allVariants{$firstkey} }) {
		
		for my $thirdKey (keys % {$allVariants{$firstkey}{$secondKey} }) {
		    
		    for my $fourthKey (keys % {$allVariants{$firstkey}{$secondKey}{$thirdKey} }) {
			
			for (my $out_col=0;$out_col<scalar(@ocol);$out_col++ ) {
			    
			    if ( defined($allVariants{$firstkey}{$secondKey}{$thirdKey}{$fourthKey}{$ocol[$out_col]}) ) {
				print WAV $allVariants{$firstkey}{$secondKey}{$thirdKey}{$fourthKey}{$ocol[$out_col]}, "\t";
			    }
			    else {
				print WAV "-", "\t";
			    }
			}
			print WAV "\n";
		    }
		}
	    }
	}
    }
    close (WAV);
    print STDOUT "Finished Writing Master file for: $_[0]","\n";
    return;
} 

####
#Merged Sub Routines
####


sub ReadInfileMerge {
#Reads the first db file per chr.
#$_[0] = Db file name
#$_[1] = Db file nr
#$_[2] = Chr number
#$_[3] = Next chr number
    
    open(RIFM, "<$_[0]") or die "Can't open $_[0]:$!, \n";    
    if ( defined($db_file_pos{$_[1]}) ) { #if file has been searched previously
	seek(RIFM, $db_file_pos{$_[1]},0) or die "Couldn't seek to $db_file_pos{$_[1]} in $_[0]: $!\n"; #Seek to binary position in file where we left off
    }    

    while (<RIFM>) {
	
	chomp $_;
	if ($.==1) {
	    print STDERR "Started at line $.\n";
	    my $pos = tell(RIFM);
	    if ( defined ($db_file_pos{$_[1]}) ) {print STDERR "Started at pos ", $db_file_pos{$_[1]}, "\n";}
	    else {print STDERR "Started at pos ",  $pos, "\n";}
	}
	if (m/^\s+$/) {		# Avoid blank lines
	    next;
	}
	if (m/^#/) {		# Avoid #
	    next;
	}		
	if ( $_ =~/^(\S+)/ ) {
	    my @temp = split($db{$_[1]}{'Separator'},$_); #Loads line

	    if ($_[3] && $temp[$db{$_[1]}{'Chr_column'}] eq $_[3]) { #If next chr is found return (Since all numerically infiles are sorted this is ok)
		print STDOUT "Finished Reading chr$_[2] in Infile $_[0]","\n";
		$db_file_pos{$_[1]} = tell(RIFM); # Save  binary position in file to enable seek when revisiting e.g. next chr
		print "Ended at pos $db_file_pos{$_[1]} in $db{$_[1]}{'File'}\n";
		close(RIFM);
		return;
	    }
	    if ($temp[$db{$_[1]}{'Chr_column'}] eq $_[2]) { #Only correct chr
		if (scalar( @{$db{0}{'Column_Keys'}}) == 1) {
		    
		    for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$_[1]}{'Column_To_Extract'}});$columns_to_extract++) {
			
			my $columnId = $_[1]."_".$db{$_[1]}{'Column_To_Extract'}[$columns_to_extract];
			$allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{$columnId}= $temp[ $db{$_[1]}{'Column_To_Extract'}[$columns_to_extract] ];
		    }
		    push (@{$unsorted{$temp[ $db{$_[1]}{'Column_Keys'}[0] ]}}, $temp[ $db{$_[1]}{'Column_Keys'}[1] ]);
		}
		if (scalar( @{$db{0}{'Column_Keys'}}) == 2) {
		    
		    for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$_[1]}{'Column_To_Extract'}});$columns_to_extract++) {
			
			my $columnId = $_[1]."_".$db{$_[1]}{'Column_To_Extract'}[$columns_to_extract];
			$allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[1] ] }{$columnId}= $temp[ $db{$_[1]}{'Column_To_Extract'}[$columns_to_extract] ];
		    }
		    push (@{$unsorted{$temp[ $db{$_[1]}{'Column_Keys'}[0] ]}}, $temp[ $db{$_[1]}{'Column_Keys'}[1] ]);
		}
		if (scalar( @{$db{0}{'Column_Keys'}}) == 3) {
		    for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$_[1]}{'Column_To_Extract'}});$columns_to_extract++) {
			
			my $columnId = $_[1]."_".$db{$_[1]}{'Column_To_Extract'}[$columns_to_extract];
			$allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[1] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[2] ] }{$columnId}= $temp[ $db{$_[1]}{'Column_To_Extract'}[$columns_to_extract] ];	    
		    }
		    push (@{$unsorted{$temp[ $db{$_[1]}{'Column_Keys'}[0] ]}}, $temp[ $db{$_[1]}{'Column_Keys'}[1] ]);
		} 
		if (scalar( @{$db{0}{'Column_Keys'}}) == 4) {
		    
		    for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$_[1]}{'Column_To_Extract'}});$columns_to_extract++) {
			
			my $columnId = $_[1]."_".$db{$_[1]}{'Column_To_Extract'}[$columns_to_extract];
			$allVariants{ $temp[ $db{$_[1]}{'Column_Keys'}[0] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[1] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[2] ] }{ $temp[ $db{$_[1]}{'Column_Keys'}[3] ]}{$columnId}= $temp[ $db{$_[1]}{'Column_To_Extract'}[$columns_to_extract] ];
		    }
		    push (@{$unsorted{$temp[ $db{$_[1]}{'Column_Keys'}[0] ]}}, $temp[ $db{$_[1]}{'Column_Keys'}[1] ]); 	
		}
	    }
	}
    }
    close(RIFM);
    print STDOUT "Finished Reading key Db file: $_[0] in Merged Mode","\n";
    return;
}

sub ReadDbFilesMerge {
#Reads all db files collected from Db master file, except first db file and db files with features "large", "range". These db files are handled by different subroutines. Requires numerically sorted infiles.
#$_[0] = chr number
#$_[1] = next chr number
    
    for (my $dbFileNr=1;$dbFileNr<$dbFileCounter;$dbFileNr++) { #All db files (in order of appearance in $db) except first db which has already been handled	
	
	#Read files per chr (i.e. multiple times)
	open(DBFM, "<$db{$dbFileNr}{'File'}") or die "Can't open $db{$dbFileNr}{'File'}:$!, \n";    
	if ( defined($db_file_pos{$dbFileNr}) ) { #if file has been searched previously
	    seek(DBFM, $db_file_pos{$dbFileNr},0) or die "Couldn't seek to $db_file_pos{$dbFileNr}: $!\n"; #Seek to binary position in file where we left off
	}

	while (<DBFM>) {
	    
	    chomp $_;
	    
	    if ($.==1) {
		print STDERR "Started at line $.\n";
		my $pos = tell(DBFM);
		if ( defined ($db_file_pos{$dbFileNr}) ) {print STDERR "Started at pos ", $db_file_pos{$dbFileNr}, "\n";}
		else {print STDERR "Started at pos ",  $pos, "\n";}
	    }
	    if (m/^\s+$/) {		# Avoid blank lines
		next;
	    }
	    if (m/^#/) {		# Avoid #
		next;
	    }		
	    if ( $_ =~/^(\S+)/) {
		
		my @temp = split($db{$dbFileNr}{'Separator'},$_); #Splits columns on separator and loads line
		
		if ($_[1] && $temp[$db{$dbFileNr}{'Chr_column'}] eq $_[1]) { #If next chr is found return (Since all numerically infiles are sorted this is ok)
		    #print STDOUT "Finished Reading chr$_[0] in Infile $db{$dbFileNr}{'File'}","\n";
		    $db_file_pos{$dbFileNr} = tell(DBFM); # Save  binary position in file to enable seek when revisiting e.g. next chr
		    print "Ended at pos $db_file_pos{$dbFileNr} in $db{$dbFileNr}{'File'}\n";		    
		    close(DBFM);
		    last;
		}
		if ( $temp[$db{$dbFileNr}{'Chr_column'}] eq $_[0]) { #If chr number and chr in line match - go ahead and process
		    
		    #Depending on the number of column keys supplied by user in db master file . 
		    if (scalar( @{$db{$dbFileNr}{'Column_Keys'}}) == 1) {
		       
			for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$dbFileNr}{'Column_To_Extract'}});$columns_to_extract++) {
			    
			    my $columnId = $dbFileNr."_".$db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract];
			    $allVariants{ $temp[ $db{$dbFileNr}{'Column_Keys'}[0] ] }{$columnId}=$temp[ $db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract] ];
			}
		    }
		    if (scalar( @{$db{$dbFileNr}{'Column_Keys'}}) == 2) {

			for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$dbFileNr}{'Column_To_Extract'}});$columns_to_extract++) {
			    
			    my $columnId = $dbFileNr."_".$db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract];
			    $allVariants{ $temp[ $db{$dbFileNr}{'Column_Keys'}[0] ] }{ $temp[ $db{$dbFileNr}{'Column_Keys'}[1] ] }{$columnId}= $temp[ $db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract] ];
			}
		    }
		    if (scalar( @{$db{$dbFileNr}{'Column_Keys'}}) == 3) {
			
			for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$dbFileNr}{'Column_To_Extract'}});$columns_to_extract++) {
			    
			    my $columnId = $dbFileNr."_".$db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract];
			    $allVariants{ $temp[ $db{$dbFileNr}{'Column_Keys'}[0] ]}{ $temp[ $db{$dbFileNr}{'Column_Keys'}[1] ]}{ $temp[ $db{$dbFileNr}{'Column_Keys'}[2] ]}{$columnId}= $temp[ $db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract] ];
			}
		    }
		    if (scalar( @{$db{$dbFileNr}{'Column_Keys'}}) == 4) {
			
			for (my $columns_to_extract=0;$columns_to_extract<scalar( @{$db{$dbFileNr}{'Column_To_Extract'}});$columns_to_extract++) {
			    
			    my $columnId = $dbFileNr."_".$db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract];
			    $allVariants{ $temp[ $db{$dbFileNr}{'Column_Keys'}[0] ] }{ $temp[ $db{$dbFileNr}{'Column_Keys'}[1] ] }{ $temp[ $db{$dbFileNr}{'Column_Keys'}[2] ] }{ $temp[ $db{$dbFileNr}{'Column_Keys'}[3] ]}{$columnId}= $temp[ $db{$dbFileNr}{'Column_To_Extract'}[$columns_to_extract] ];
			    
			}
			push (@{$unsorted{$temp[ $db{$dbFileNr}{'Column_Keys'}[0] ]}}, $temp[ $db{$dbFileNr}{'Column_Keys'}[1] ]);
		    }
		}
	    } 	
	}
	close(DBFM);
	print STDOUT "Finished Reading chr$_[0] in Infile: $db{$dbFileNr}{'File'}","\n";
    }
    return;
}

sub SortAllVariantsMergeST {
#Creates an array of all position which are unique and in sorted ascending order
#$_[0] = chr number
#$_[1] = db file number   
    
    my $firstKey = $_[0];
    my %seen = (); 

#Unique entries only
    @{$allVariants_chr_unique{$firstKey} } = grep { ! $seen{$_} ++ } @{$unsorted{$_[0]} };
#Sort using the Schwartzian Transform 
    @{$allVariants_chr_sorted{$firstKey} } =  map { $_->[0] }
    sort { $a->[0] <=> $b->[0] }
    map { [$_] }
    @{$allVariants_chr_unique{$firstKey} };

    @{$unsorted{$_[0] } }=();  #Reset for this chr
}

sub SortAllVariantsMerge {
#Creates an array of all position
#$_[0] = chr number
#$_[1] = db file number   
    
    my $firstKey = $_[0];
    my %seen = (); 

    if (scalar( @{$db{0}{'Column_Keys'}}) > 1) {
	
	for my $secondKey (keys %{ $allVariants{$firstKey} } )  { #For all secondkeys
	    
	    push ( @{$allVariants_chr{$firstKey} },$secondKey );
	}
	@{$allVariants_chr_unique{$firstKey} } = grep { ! $seen{$_} ++ } @{$allVariants_chr{$firstKey} }; #Unique entries only 
	@{$allVariants_chr_sorted{$firstKey} } = sort { $a <=> $b } @{ $allVariants_chr_unique{$firstKey} }; #Sorts keys to be able to print sorted table later 
	print STDOUT "Sorted all non overlapping entries\n";
    }
}

sub WriteAllVariantsMerge {
#Prints tab separated file of all collected db file info in ascending order.
#$_[0] = filename
#$_[1] = chr number
    
    my $filename = $_[0];
    my $chr = $_[1];

    if ( ($_[1] eq 1) || ($_[1] eq "chr1") ) {
	open (WAVM, ">$filename") or die "Can't write to $filename: $!\n";
	if ($oheaders == 1 ) { #Print header if supplied
	    print WAVM "#";
	    for (my $out_header=0;$out_header<scalar(@oheaders);$out_header++) {
		print WAVM "$oheaders[$out_header]\t";
	    }
	    print WAVM "\n";
	}
    }
    else {
	open (WAVM, ">>$filename") or die "Can't write to $filename: $!\n";
    }

    if (scalar( @{$db{'0'}{'Column_Keys'}}) == 1) { #Any db file should be fine since all have to have the same nr of keys
	
	for (my $out_col=0;$out_col<scalar(@ocol);$out_col++ ) {
	    
	    if ( defined($allVariants{$chr}{$ocol[$out_col]}) ) {
		print WAVM $allVariants{$chr}{$ocol[$out_col]}, "\t";
	    }
	    else {
		print WAVM "-", "\t";
	    }
	}
	print WAVM "\n";
    }
    if (scalar( @{$db{'0'}{'Column_Keys'}}) == 2) { #Any db file should be fine since all have to have the same nr of keys

	for (my $i=0;$i<scalar( @{$allVariants_chr_sorted{$chr} } );$i++)  { #For all pos per chr	
	    
	    my $secondKey = $allVariants_chr_sorted{$chr}[$i]; #pos keys to hash from sorted arrray
	    
	    for (my $out_col=0;$out_col<scalar(@ocol);$out_col++ ) {
		
		if ( defined($allVariants{$chr}{$secondKey}{$ocol[$out_col]}) ) {
		    print WAVM $allVariants{$chr}{$secondKey}{$ocol[$out_col]}, "\t";
		}
		else {
		    print WAVM "-", "\t";
		}
	    }
	    print WAVM "\n";
	}
    }
    if (scalar( @{$db{'0'}{'Column_Keys'}}) == 3) { #Any db file should be fine since all have to have the same nr of keys
	
	for (my $i=0;$i<scalar( @{$allVariants_chr_sorted{$chr} } );$i++)  { #For all pos per chr	
	    
	    my $secondKey = $allVariants_chr_sorted{$chr}[$i]; #pos keys to hash from sorted arrray
	    
	    for my $thirdKey (keys % {$allVariants{$chr}{$secondKey} }) {
		
		for (my $out_col=0;$out_col<scalar(@ocol);$out_col++ ) {
		    
		    if ( defined($allVariants{$chr}{$secondKey}{$thirdKey}{$ocol[$out_col]}) ) {
			print WAVM $allVariants{$chr}{$secondKey}{$thirdKey}{$ocol[$out_col]}, "\t";
		    }
		    else {
			print WAVM "-", "\t";
		    }
		}
		print WAVM "\n";   
	    }
	}
    }
    if (scalar( @{$db{'0'}{'Column_Keys'}}) == 4) { #Any db file should be fine since all have to have the same nr of keys
	
	for (my $i=0;$i<scalar( @{$allVariants_chr_sorted{$chr} } );$i++)  { #For all pos per chr	
	    
	    my $secondKey = $allVariants_chr_sorted{$chr}[$i]; #pos keys to hash from sorted arrray

	    for my $thirdKey (keys % {$allVariants{$chr}{$secondKey} }) {
		
		for my $fourthKey (keys % {$allVariants{$chr}{$secondKey}{$thirdKey} }) {
		    
		    print WAVM "$chr\t","$secondKey\t","$thirdKey\t","$fourthKey\t";

		    for (my $out_col=0;$out_col<scalar(@ocol);$out_col++ ) {
			
			if ( defined($allVariants{$chr}{$secondKey}{$thirdKey}{$fourthKey}{$ocol[$out_col]}) ) {
			    print WAVM $allVariants{$chr}{$secondKey}{$thirdKey}{$fourthKey}{$ocol[$out_col]}, "\t";
			}
			else {
			    print WAVM "-", "\t";
			}
		    }
		    print WAVM "\n";
		}
	    }
	}
    }
    close (WAVM);
    print STDOUT "Finished Writing Master file for: chr$_[1]","\n";
    return;
}


