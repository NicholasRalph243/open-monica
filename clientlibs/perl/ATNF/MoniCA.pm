package MonPoint;

sub new {
  my $proto = shift;
  my $class = ref($proto) || $proto;

  my $monline = shift;
  my $self = [$monline =~ /^(\S+)\s+(\S+)\s+(\S.*)$/];

  bless ($self, $class);
}

sub point {
  my $self = shift;
  if (@_) { $self->[0] = shift }
  return $self->[0];
}

sub bat {
  my $self = shift;
  if (@_) { $self->[1] = shift }
  return $self->[1];
}

sub val {
  my $self = shift;
  if (@_) { $self->[2] = shift }
  return $self->[2];
}

package MonBetweenPoint;

sub new {
  my $proto = shift;
  my $class = ref($proto) || $proto;

  my $monline = shift;
  my $self = [$monline =~ /^(\S+)\s+(\S.*)$/];

  bless ($self, $class);
}

sub bat {
  my $self = shift;
  if (@_) { $self->[0] = shift }
  return $self->[0];
}

sub val {
  my $self = shift;
  if (@_) { $self->[1] = shift }
  return $self->[1];
}

package MonFullPoint;

sub new {
    my $proto=shift;
    my $class=ref($proto)||$proto;
    
    my $monline=shift;
    my $self=[$monline=~/^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)$/];
    
    bless ($self,$class);
}

sub point {
    my $self=shift;
    if (@_) { $self->[0] = shift }
    return $self->[0];
}

sub bat {
    my $self=shift;
    if (@_) { $self->[1] = shift }
    return $self->[1];
}

sub val {
    my $self=shift;
    if (@_) { $self->[2] = shift }
    return $self->[2];
}

sub units {
    my $self=shift;
    if (@_) { $self->[3] = shift }
    return $self->[3];
}

sub errorstate {
    my $self=shift;
    if (@_) { $self->[4] = shift }
    return $self->[4];
}

package MonDetail;

sub new {
    my $proto=shift;
    my $class=ref($proto) || $proto;

    my $monline=shift;
    my $self=[$monline=~/^(\S+)\s+(\S+)\s+\"(.*?)\"\s+\"(.*)\"$/];

    bless ($self,$class);
}

sub point {
    my $self=shift;
    if (@_) { $self->[0] = shift }
    return $self->[0];
}

sub updatetime {
    my $self=shift;
    if (@_) { $self->[1] = shift }
    return $self->[1];
}

sub units {
    my $self=shift;
    if (@_) { $self->[2] = shift }
    return $self->[2];
}

sub description {
    my $self=shift;
    if (@_) { $self->[3] = shift }
    return $self->[3];
}

package ATNF::MoniCA;
use strict;

=head1 NAME

ATNF::MoniCA - Perl interface to OpenMoniCA


=head1 SYNOPSIS

    use ATNF::MoniCA

    my $server = 'monhost-nar.atnf.csiro.au';
    my $mon = monconnect($server);
    die "Could not connect to monitor host $server\n" if (!defined $mon);

    my @points = qw(site.environment.weather.Temperature);

    my $point = monpoll($mon, @points);

    print "ATCA temperature is ", $point->val, "\n";

=head1 DESCRIPTION

ATNF::MoniCA is a perl interface to the OpenMoniCA ascii interface. It parallels the
function calls available for the ascii interface. Users are directed to the ascii interface
documentation for details.

  http://code.google.com/p/open-monica/wiki/ClientASCII

Note that the returned data is slightly "perlised" before returning. This part of the
interface is currently in flux and will change without notice.

=head1 AUTHOR

Chris Phillips  Chris.Phillips@csiro.au

=head1 Data Types

Most functions parse the ascii return values from the server and return an perl 
object. These are fairly simple and simple just used to encode the multiple 
return values for each monitor point (value, bat, name etc). 

=over 2

=item B<MonPoint>

A single monitor point. 

  ->point    Name of the monitor point
  ->bat      BAT time corresponding to the point sample
  ->val      Actual value of the monitor point

=item B<MonBetweenPoint>
 
A single monitor point value returned by monbetween or monsince.

  ->bat      BAT time corresponding to the point sample
  ->val      Actual value of the monitor point

=item B<MonFullPoint>

A single monitor point, as returned by monpoll2.

  ->point       Name of the monitor point
  ->bat         BAT time corresponding to the point sample
  ->val         Actual value of the monitor point
  ->units       The units associated with the monitor point value
  ->errorstate  Flag to indicate error state, true = error

=item B<MonDetail>

Detail about a single monitor point.

  ->point       Name of the monitor point
  ->updatetime  The time between server updates, in seconds
  ->units       The units associated with the monitor point value
  ->description A human-readable description of the monitor point

=back

=head1 FUNCTIONS

=over 1

=cut

use IO::Socket;

use Math::BigFloat;
use Math::BigInt;
use Astro::Time;
use Time::Local;
use POSIX qw (ceil);

use Carp;
require Exporter;

use vars qw(@ISA @EXPORT);

@ISA    = qw( Exporter );
@EXPORT = qw( bat2time monconnect monpoll monsince parse_tickphase current_bat 
	      monbetween monpreceeding monfollowing montill 
	      bat2mjd mjd2bat bat2time atca_tied monnames
              mondetails monpoll2 bat2cal bat2unixtime perltime2mjd );

=item B<monconnect>

  my $mon = monconnect($server);

 Opens a connection to the MoniCA server 
    $server  Name of server, e.g. 'myserver.domain.com'
    $mon     Socket to MoniCA server, used for subsequent calls

=cut

sub monconnect($) {
  my $server = shift;

  my $mon = IO::Socket::INET->new(PeerAddr => $server,
				  PeerPort => 8051,
				 )
    || return undef;

  return $mon;
}

=item B<monpoll>

  my $pointval = monpoll($mon, $pointname);
  my @pointvals = monpoll($mon, @pointnames);

 Calls the "poll" function, returnint the most recent values for one
 or more monitor points. Note calling in scalar mode only the first
 monitor point is returned.

    $mon           Monitor server
    $pointname     Single monitor point
    @pointnames  List of monitor points
    $pointval      MonPoint object, representing the first returned monitor
                   point
    @pointvals   List of MonPoint objects

=cut

sub monpoll ($@) {
  my $mon = shift;
  my @monpoints = @_;
  my $npoll = scalar(@monpoints);

  if ($npoll==0) {
    warn "No monitor points requested!\n";
    return undef;
  }

  print $mon "poll\n";
  print $mon "$npoll\n";
  foreach (@monpoints) {
    print $mon "$_\n";
  }

  my @vals = ();

  for (my $i=0; $i<$npoll; $i++) {
    my $line = <$mon>;
    push @vals, new MonPoint($line);
  }

  if (wantarray) {
    return @vals;
  } else {
    return $vals[0];
  }
}

=item B<monpoll2>

  my $pointval = monpoll2($mon, $pointname);
  my @pointvals = monpoll2($mon, @pointnames);

Calls the "poll2" function, returning the most recent values for one
or monitor points, along with their associated units and an indication
of whether the point is in an error state. Note: calling in scalar mode
returns only the first monitor point.

    $mon         Monitor server
    $pointname   Single monitor point
    @pointnames  List of monitor points
    $pointval    MonFullPoint object, representing the first returned
                 monitor point
    @pointvals   List of MonPointFull objects

=cut

sub monpoll2 ($@) {
    my $mon=shift;
    my @monpoints=@_;
    my $npoll=scalar(@monpoints);

    if ($npoll==0){
	warn "No monitor points requested!\n";
	return undef;
    }

    print $mon "poll2\n";
    print $mon "$npoll\n";
    foreach (@monpoints) {
	print $mon "$_\n";
    }

    my @vals=();

    for (my $i=0;$i<$npoll;$i++){
	my $line=<$mon>;
	push @vals,new MonFullPoint($line);
    }

    if (wantarray){
	return @vals;
    } else {
	return $vals[0];
    }
}

=item B<monsince>

  my @pointvals = monsince($mon, $mjd, $pointname, $maxnper);

Calls the "since" function, returning all records, for a single
monitor point, between the nominated time and now.

    $mon        Monitor server
    $mjd        MJD of start of query range (double)
    $pointname  Monitor point
    $maxnper    (optional) the maximum number of points to return
                per server query
    @pointvals  List of MonBetweenPoint objects

=cut

sub monsince ($$$;$) {
    my $mon=shift;
    my $mjd=shift;
    my $point=shift;
    my $maxnper=shift;
    $maxnper=-1 if (!defined $maxnper);
    
    my $bat = mjd2bat($mjd)->as_hex;
    
    my $nreceived;
    my @vals=();
    my $maxbat=bat2mjd($bat);
    do {
	print $mon "since\n";
	print $mon mjd2bat($maxbat)->as_hex." $point\n";
	
	$nreceived=<$mon>;
	my $acceptfraction=ceil($nreceived/$maxnper);
	my $j=0;
	for (my $i=0;$i<$nreceived;$i++){
	    my $line=<$mon>;
	    $j++;
	    if (($acceptfraction<0)||($j>=$acceptfraction)||
		($i==0)||($i==($nreceived-1))){
		$j=0;
		push @vals,new MonBetweenPoint($line);
		if (bat2mjd($vals[$#vals]->bat)>$maxbat){
		    $maxbat=bat2mjd($vals[$#vals]->bat);
		}
	    }
	}
	# increment the max bat by 1 millisecond
	$maxbat+=(1e-3/60/60/24);
    } while ($nreceived>1);

    return @vals;
}

=item B<monbetween>

  my @pointvals = monbetween($mon, $mjd1, $mjd2, $pointname, $maxnper);

 Calls the "between" function, returning all records, for a single
 monitor point, between two nominated times.

    $mon           Monitor server
    $mjd1          MJD of start of query range (double)
    $mjd2          MJD of end of query range (double)
    $pointname     Monitor point
    $maxnper       (optional) the maximum number of points to return
                   per server query
    @pointvals     List of MonBetweenPoint objects

=cut

sub monbetween ($$$$;$) {
    my $mon=shift;
    my $mjd1=shift;
    my $mjd2=shift;
    my $point=shift;
    my $maxnper=shift;
    $maxnper=-1 if (!defined $maxnper);

    my $bat1=mjd2bat($mjd1)->as_hex;
    my $bat2=mjd2bat($mjd2)->as_hex;

    my $nreceived;
    my @vals=();
    my $maxbat=bat2mjd($bat1);
    do {
	print $mon "between\n";
	print $mon mjd2bat($maxbat)->as_hex." $bat2 $point\n";

	my $nreceived=<$mon>;
	chomp($nreceived);
	return undef if (! defined $nreceived);
	return undef if (! ($nreceived =~ /^\d+$/));
	my $acceptfraction=ceil($nreceived/$maxnper);
	my $j=0;
	for (my $i=0;$i<$nreceived;$i++){
	    my $line=<$mon>;
	    $j++;
	    if (($acceptfraction<0)||($j>=$acceptfraction)||
		($i==0)||($i==($nreceived-1))){
		$j=0;
		push @vals,new MonBetweenPoint($line);
		if (bat2mjd($vals[$#vals]->bat)>$maxbat){
		    $maxbat=bat2mjd($vals[$#vals]->bat);
		}
	    }
	}
	# increment the max bat by 1 millisecond
	$maxbat+=(1e-3/60/60/24);
	# check whether we've gone past the last bat
	if ($maxbat>=bat2mjd($bat2)){
	    last;
	}
    } while ($nreceived>1);

    return @vals;
}

=item B<mondetails>

  my $pointdetail = mondetails($mon, $pointname);
  my @pointdetails = mondetails($mon, @pointnames);

Calls the "details" function, returning details about all the
nominated monitor points.

    $mon          Monitor server
    $pointname    Single monitor point
    @pointnames   List of monitor points
    $pointdetail  MonDetail object, representing the first
                  returned monitor point
    @pointvals    List of MonDetails objects

=cut

sub mondetails ($@) {
    my $mon=shift;
    my @monpoints=@_;
    my $npoll=scalar(@monpoints);

    if ($npoll==0){
	warn "No monitor points requested!\n";
	return undef;
    }

    print $mon "details\n";
    print $mon "$npoll\n";
    foreach (@monpoints) {
	print $mon "$_\n";
    }

    my @vals=();
    
    for (my $i=0;$i<$npoll;$i++){
	my $line=<$mon>;
	push @vals,new MonDetail($line);
    }

    if (wantarray){
	return @vals;
    } else {
	return $vals[0];
    }
    
}

=item B<monnames>

  my @pointnames = monnames($mon);

Calls the "names" function, returning the names of all the points
available on the server.

    $mon         Monitor server
    @pointnames  List of strings

=cut

sub monnames ($) {
    my ($mon)=@_;

    print $mon "names\n";
    
    my @names;
    
    my $num_names=<$mon>; # the number of names being returned
    for (my $i=0;$i<$num_names;$i++){
	chomp(my $line=<$mon>);
	push @names,$line;
    }

    return @names;
}

sub montill($$$$) {
  # Get a monitor point up till the given time
  my ($mon, $mjd, $point, $step) = @_;
  my $mjd0 = $mjd-$step;
  my @vals;
  while (@vals==0) {
    @vals = monbetween($mon, $mjd0, $mjd, $point);
    $mjd0-= $step;
  }
  return pop @vals; 
}

=item B<monpreceeding>

  my $pointval = monpreceeding($mon, $mjd, $pointname);
  my @pointvals = monpreceeding($mon, $mjd, @pointnames);

 Calls the "monpreceeding" function, returning the last record <= a specifed time
 for one or more monitor points. Note calling in scalar mode only the first
 monitor point is returned.

    $mon           Monitor server
    $mjd           MJD of start of query time (double))
    $pointname     Single monitor point
    @pointnames    List of monitor points
    $pointval      MonPoint object, representing the first returned monitor
                   point
    @pointvals     List of MonPoint objects

=cut

sub monpreceeding ($$@) {
  my $mon = shift;
  my $mjd = shift;
  my @monpoints = @_;
  my $npoll = scalar(@monpoints);

  my $bat = mjd2bat($mjd)->as_hex;

  if ($npoll==0) {
    warn "No monitor points requested!\n";
    return undef;
  }

  print $mon "preceeding\n";
  print $mon "$npoll\n";
  foreach (@monpoints) {
    print $mon "$bat $_\n";
  }

  my @vals = ();

  for (my $i=0; $i<$npoll; $i++) {
    my $line = <$mon>;
    push @vals, new MonPoint($line);
  }

  if (wantarray) {
    return @vals;
  } else {
    return $vals[0];
  }
}

=item B<monfollowing>

  my $pointval = monfollowing($mon, $mjd, $pointname);
  my @pointvals = monfollowing($mon, $mjd, @pointnames);

 Calls the "following" function, returning the first record >= a specifed time
 for one or more monitor points. Note calling in scalar mode only the first
 monitor point is returned.

    $mon           Monitor server
    $mjd           MJD of start of query time (double)
    $pointname     Single monitor point
    @pointnames    List of monitor points
    $pointval      MonPoint object, representing the first returned monitor
                   point
    @pointvals     List of MonPoint objects

=cut

sub monfollowing ($$@) {
  my $mon = shift;
  my $mjd = shift;
  my @monpoints = @_;
  my $npoll = scalar(@monpoints);

  my $bat = mjd2bat($mjd)->as_hex;

  if ($npoll==0) {
    warn "No monitor points requested!\n";
    return undef;
  }

  print $mon "following\n";
  print $mon "$npoll\n";
  foreach (@monpoints) {
    print $mon "$bat $_\n";
  }

  my @vals = ();

  for (my $i=0; $i<$npoll; $i++) {
    my $line = <$mon>;
    push @vals, new MonPoint($line);
  }

  if (wantarray) {
    return @vals;
  } else {
    return $vals[0];
  }
}

=item B<bat2cal>

  my $calstring = bat2cal($bat)

Convert a bat into a string representation yyyy-mm-dd_HH:MM:SS.

    $bat        BAT value
    $calstring  string representation of BAT time

=cut

sub bat2cal($;$) {
    my $bat=Math::BigInt->new(shift);

    my $dUT=shift;
    $dUT=0 if (!defined $dUT);

    my $mjd=(Math::BigFloat->new($bat)/1e6-$dUT)/60/60/24;
    
    my ($day,$month,$year,$ut)=mjd2cal($mjd->bstr());

    $ut*=24.0;
    my $hour=floor($ut);
    $ut-=$hour;
    $ut*=60.0;
    my $minute=floor($ut);
    $ut-=$minute;
    $ut*=60.0;
    my $second=floor($ut);

    my $caltime=sprintf "%04d-%02d-%02d_%02d:%02d:%02d",
    $year,$month,$day,$hour,$minute,$second;

    return $caltime;
}

=item B<bat2unixtime>

  my $unixtime = bat2unixtime($bat);

Convert a bat into number of seconds since 1 Jan 1970, 0 UT.
    $bat         BAT value
    $unixtime    Unix time (UT)

=cut

sub bat2unixtime($;$) {
    my $bat=Math::BigInt->new(shift);

    my $dUT=shift;
    $dUT=0 if (!defined $dUT);

    my $mjd=(Math::BigFloat->new($bat)/1e6-$dUT)/60/60/24;
    
    my ($day,$month,$year,$ut)=mjd2cal($mjd->bstr());

    $ut*=24.0;
    my $hour=floor($ut);
    $ut-=$hour;
    $ut*=60.0;
    my $minute=floor($ut);
    $ut-=$minute;
    $ut*=60.0;
    my $second=floor($ut);
    
    $year-=1900;
    $month-=1;
    my $utime=timegm($second,$minute,$hour,$day,$month,$year,0,0);
    
    return $utime;

}

=item B<perltime2mjd>

  my $mjd = perltime2mjd(@perltime);

Converts a Perl formatted time list (as obtained through eg. gmtime(time)
into MJD.
    @perltime   Perl formatted time list
    $mjd        MJD

=cut

sub perltime2mjd {
    # perl time should be (second,minute,hour,day,month-1,year-1900)
    my @fulltime=@_;
    
    my $ut=hms2time($fulltime[2],$fulltime[1],$fulltime[0]);
    my $mjd=cal2mjd($fulltime[3],$fulltime[4]+1,$fulltime[5]+1900,$ut);

    return $mjd;
}    

sub bat2time($;$$) {
 my $bat = Math::BigInt->new(shift);

 my $dUT = shift;
 $dUT = 0 if (!defined $dUT);
 my $np = shift;

 my $mjd = (Math::BigFloat->new($bat)/1e6-$dUT)/60/60/24;

 return mjd2time($mjd, $np);
}

=item B<bat2mjd>

  my $mjd = bat2mjd($bat);

 Convert a bat into mjd
    $bat           BAT value
    $mjd           MJD (double)
=cut

sub bat2mjd($;$) {
 my $bat = Math::BigInt->new(shift);
 my $dUT = shift;
 $dUT = 0 if (!defined $dUT);
 return (Math::BigFloat->new($bat)/1e6-$dUT)/60/60/24;
}

=item B<mjd2bat>

  my $bat = mjd2bat($mjd);

 Convert a mjd into bat

    $mjd           MJD (double)
    $bat           BAT value
=cut

sub mjd2bat($) {
  my $mjd = shift;
  if (ref $mjd eq 'Math::BigFloat') {
    my $bat = 60*60*24*1e6*$mjd;
    return $bat->as_number();
  } else {
    return Math::BigInt->new(60*60*24*1e6*$mjd);
  }
}

sub parse_tickphase ($) {
  my $line = shift;
  chomp $line;

  my ($point, $bat, $tickphase);
  
  if ($line =~ /^(\S+)\s+(\S+)\s+(.*)$/) {
    ($point, $bat, $tickphase) = ($1, $2, $3);
  } elsif ($line =~ /^(\S+)\s+(.*)$/) {
    ($bat, $tickphase) = ($1, $2, $3);
  } else {
    warn "Did not understand $line\n";
    return undef;
  }

  my $time = bat2mjd($bat);
  return ($time, $tickphase);
}

sub current_bat ($$) {
  my ($mon, $clock) = @_;

  my $val = monpoll($mon, "$clock.misc.clock.Time");

  my ($point, $time1, $time2) = $val =~ /^(\S+)\s+(\S+)\s+(\S+)$/;

  return($time1, $time2);
}

# Return a list of tied antenna between two MJDs (including the initial state)
sub atca_tied($$$;$) {
  my ($mon, $mjd1, $mjd2, $dUT) = @_;
  $dUT = 0 if (!defined $dUT);
  $dUT /= 24*60*60;

  my %state = ();
  my %currentstate = ();
  
  my @ants = qw(ca01 ca02 ca03 ca04 ca05 ca06);
  my $monpoint = 'misc.catie.Active1';

  foreach my $ant (@ants) {
    my @antstate = ();
    my $thispoint = "$ant.$monpoint";

    my @vals;

    # Get the state at the start of the given range
    my $mjd0 = $mjd1-10;
    while (@vals==0) {
      @vals = monbetween($mon, $mjd0-$dUT, $mjd1-$dUT, $thispoint);
      $mjd0-= 10;
    }
    return undef if (!defined $vals[0]);

    my $initialstate = pop @vals;
    $currentstate{$ant} = $initialstate->val;

    # Get the values during the period
    @vals = monbetween($mon, $mjd1-$dUT, $mjd2-$dUT, $thispoint);
    foreach (@vals) {
      push @antstate, [bat2mjd($_->bat), $_->val];
    }
    $state{$ant} = [@antstate];
  }

  # Tied state at start of time range
  my @tiedant = ();
  foreach (@ants) {
    if ($currentstate{$_} eq 'true') {
      push @tiedant, $_;
    } 
  }
  my @state = [$mjd1, 0, [@tiedant]];
 
  # Build up list of times when state changes
  while (1) {
    my $first = undef;
    my $firsttime = undef;
    # Go through each antenna and find out which has the earliest change
    foreach my $ant (@ants) {
      if (@{$state{$ant}}>0) { # Any left?
	if (defined $first) {
	  if ($state{$ant}->[0][0]<$firsttime) {
	    $first = $ant;
	    $firsttime = $state{$ant}->[0][0];
	  }
	} else {
	  $first = $ant;
	  $firsttime = $state{$ant}->[0][0];
	}
      }
    }
    last if (!defined $first); # Nothing found

    my $val = shift @{$state{$first}};
    
    if ($val->[1] ne $currentstate{$first}) { # It actually has changed
      $currentstate{$first} = $val->[1];

      # Go through the rest of the antenna and see if any have a value at the 
      # same time

      foreach my $ant (@ants) {
	if (@{$state{$ant}}>0 && $state{$ant}->[0][0]==$val->[0]) {
	  $currentstate{$ant} = $state{$ant}->[0][1];
	  shift @{$state{$ant}};
	}
      }

      @tiedant = ();
      foreach (@ants) {
	if ($currentstate{$_} eq 'true') {
	  push @tiedant, $_;
	}
      }
      push @state, [$val->[0], 0, [@tiedant]];
    }
  }
  for (my $i=0; $i<@state-1; $i++) {
    $state[$i]->[1] = $state[$i+1]->[0];
  }
  $state[$#state]->[1] = $mjd2;

  return @state;
}


return 1;
