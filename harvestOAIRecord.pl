#!/usr/bin/perl -w
use strict;

use FileHandle;
use Getopt::Long;
use Net::OAI::Harvester;
use Time::HiRes qw(sleep);
use Time::localtime;
use File::Copy;

my %opts = (); 

main();

#-----------------------------------------------------------------------------
sub main
{
   #$Net::OAI::Harvester::DEBUG = 1;
   initSettings();
   my $retrieved = 0;
   
   my $identifiers = shift @ARGV;

   my $harvester = Net::OAI::Harvester->new( 
        'baseURL' => $opts{baseurl}
   );
   
   my $idFH = new FileHandle;
	
   $idFH->open($identifiers);
   
   
   while(not($idFH->eof)) {
      my $idIn = $idFH->getline;
      chomp $idIn;
      $idIn =~ s/\+/MIU01\-/gx;
      
      $retrieved++;
      
      my $record = $harvester->getRecord(
            identifier              => $idIn,
            metadataPrefix          => $opts{meta}      
      );       
      
      my $tm = localtime;
      my $timestamp = sprintf("%04d-%02d-%02d", $tm->year+1900, ($tm->mon)+1, $tm->mday);

      my $moved = 'records\\' . $idIn . '.xml';

      move($record->file, $moved);
      
      print "Harvested $retrieved $idIn\n";
      
      if ($retrieved % 100 == 0) {
         print "Waiting....\n";
         sleep(15);
      }
      
   }
      print "Fetched $retrieved records\n"; 
}

#-----------------------------------------------------------------------------
sub initSettings {
    
    GetOptions ("config=s" => \$opts{config},
		"baseurl=s"=> \$opts{baseurl},
		"set=s"=> \$opts{set}
                );

    		
    # Set Defaults if no argument given		     
    $opts{config} = 'harvestOAI.config'
        if !($opts{config});								

    # read settings from config
    my $configFH = new FileHandle;
	
    $configFH->open($opts{config});
    while(not($configFH->eof)) {
        my $lineIn = $configFH->getline;
        chomp $lineIn;
        # skip comments
        unless ( $lineIn =~ /^#/ ) {
            $lineIn =~ s/\s//g;
            $lineIn =~ /(.+)\=(.+)/;
            my ($key, $value) = ($1, $2);
	 
            $opts{$key} = $value;		    
        }
    }
        
    die "Need base URL to harvest.\n"
        if !($opts{baseurl});
        
    #die "Need OAI Set to harvest.\n"
    #    if !($opts{set});

    $configFH->close();

}

#-----------------------------------------------------------------------------
