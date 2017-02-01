#!/usr/bin/perl -w
use strict;

use FileHandle;
use Getopt::Long;
use Net::OAI::Harvester;
use Time::HiRes qw(sleep);
use Time::localtime;
use File::Path;
use File::Copy;
use XML::LibXML;

my %opts = (); 

main();

#-----------------------------------------------------------------------------
sub main
{
   #$Net::OAI::Harvester::DEBUG = 1;
   initSettings();
    
   my $harvester = Net::OAI::Harvester->new( 
        'baseURL' => $opts{baseurl}
   );
            
    
   my $records = $harvester->listRecords( 
                            metadataPrefix => $opts{meta},
                            from           => $opts{from},
                            until          => $opts{until},
                            set            => $opts{set});    

   my ($finished, $count) = (0,0);
            my $check = 0;
   
   while ( my $record = $records->next() ) {
      $count++;
   }
   while ( ! $finished ) {
		
               my $retrieved = 0; 
               
	       my $timestamp = $opts{timestamp};
		my $range = $opts{from} . '-' . $opts{until};

		my $setname = $opts{set};
		$setname =~ s/:/-/;
	
		my $path = 'harvested/' . $setname . '_' . $range . '/';
	 	my $filename = $timestamp . '_' . $count . '.xml';
		my $fullpath = $path . $filename;

		if (! -d $path)
		{
			my $dirs = eval { mkpath($path) };
			die "Failed to create $path: $@\n" unless $dirs;
		}

		move($records->file, $fullpath)
    		or die "move failed: $!";

		print "Records written to $fullpath\n";

		my $rToken = $records->resumptionToken();
                
                if ($check == 0){
                  #$rToken->settoken('20170125154806:marc21:19000101000000:20170125235959:450000:hathitrust:pd');
                  $check = 1;
               }
	   if ( $rToken ) { 
   	       print "Fetched $count records\n";
      	# wait 15 seconds
               print "Waiting....\n";
               #sleep(25);
               print "restarting with token\n";
               $records = $harvester->listRecords( 
                resumptionToken => $rToken->token());
               
               while ( my $record = $records->next() ) {
                        $retrieved++;
                        $count++;
               }
               if ($retrieved == 0){
                  print "Zero records retrieved. Waiting....\n";
                  sleep(25);
                  print "Restarting with token\n";
                  $records = $harvester->listRecords( 
                     resumptionToken => $rToken->token());
                  while ( my $record = $records->next() ) {
                        $retrieved++;
                        $count++;
                  }
                  if ($retrieved == 0){
                     print "Unable to retrieve.  Last resumption token is\n";
                     print $rToken->resumptionTokenText();
                     die;
                  }
               }
	    } else { 
     		$finished = 1;
	   }

   }
	print "Fetched $count records\n"; 
}

#-----------------------------------------------------------------------------
sub initSettings {
    
    GetOptions ("config=s" => \$opts{config},
		"baseurl=s"=> \$opts{baseurl},
		"set=s"=> \$opts{set},
                "from=s"=> \$opts{from},
                "until=s"=> \$opts{until},
                "timestamp=s"=> \$opts{timestamp}
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
	 
            $opts{$key} = $value
               unless(!$value);
        }
    }

   my $tm = localtime;
   my $timestamp = sprintf("%04d-%02d-%02d", $tm->year+1900, ($tm->mon)+1, $tm->mday);
   $opts{timestamp} = $timestamp;
   
   $opts{from} = "1900-01-01"
      if !($opts{from});
   
   $opts{until} = $timestamp
      if !($opts{until});
   
    die "Need base URL to harvest.\n"
        if !($opts{baseurl});
        
    #die "Need OAI Set to harvest.\n"
    #    if !($opts{set});

    $configFH->close();

}

#-----------------------------------------------------------------------------
