#!/usr/bin/perl
package JMX::Jmx4Perl::Config;
use Data::Dumper;

my $HAS_CONFIG_GENERAL;

BEGIN {
    eval { 
        require "Config/General.pm";
    };
    $HAS_CONFIG_GENERAL = $@ ? 0 : 1;
}

=head1 NAME 

JMX::Jmx4Perl::Config - Configuration file support for Jmx4Perl

=head1 SYNOPSIS

=over

=item Configuration file format

  # ================================================================
  # Sample configuration for jmx4perl

  <Server>
    # Name how this config could accessed
    Name = localhost

    # Options for JMX::Jmx4Perl->new, case is irrelevant
    Url  = http://localhost:8080/j4p
    User = roland
    Password = test
    Product = JBoss
    
    # HTTP proxy for accessing the agent
    <Proxy>
      Url = http://proxy:8001
      User = proxyuser
      Password = ppaasswwdd
    </Proxy>
    # Target for running j4p in proxy mode
    <Target>
      Url       service:jmx:iiop://....
      User      weblogic
      Password  weblogic
    </Target>       
  </Server>

=item Usage

  my $config = new JMX::Jmx4Perl::Config($config_file);

=back


=head1 DESCRIPTION


=head1 METHODS

=over

=item $cfg = JMX::Jmx4Perl::Config->new($file)

Create a new configuration object with the given file name. If no file name 
is given the configuration F<~/.j4p> is tried. If the file does not 
exist, C<server_config_exists> will alway return C<false> and
C<get_server_config> will always return C<undef>

=cut 

sub new { 
    my $class = shift;
    my $file = shift;
    $file = $ENV{HOME} . "/.j4p" unless $file;
    my $self = {};
    if (-e $file) {
        if ($HAS_CONFIG_GENERAL) {
            $self->{config} =           
                 &_prepare_server_hash({
                     new Config::General(-ConfigFile => $file,-LowerCaseNames => 1)->getall});
        } else {
            warn "Configuration file $file found, but Config::General is not installed.\n" . 
              "Please install Config::General, for the moment we are ignoring the content of $file\n\n";
        }
    } else {
        $self->{config} = {};
    }
    bless $self,(ref($class) || $class);
    return $self;   
}

=item $exists = $config->server_config_exists($name)

Check whether a configuration entry for the server with name $name
exist.

=cut

sub server_config_exists {
    my $self = shift;
    my $name = shift || die "No server name given to reference to get config for";
    my $cfg = $self->get_server_config($name);
    return defined($cfg) ? 1 : 0;
}

=item $server_config = $config->get_server_config($name)

Get the configuration for the given server or C<undef> 
if no such configuration exist.

=cut

sub get_server_config {
    my $self = shift;
    my $name = shift || die "No server name given to reference to get config for";
    return $self->{config}->{$name};
}

sub _prepare_server_hash {
    my $config = shift;
    my $servers = &_get_configured_servers($config);
    my $ret = {};
    for my $server (@$servers) {
        $ret->{$server->{name}} = $server;
    };
    return $ret;
}

sub _get_configured_servers {
    my $config = shift;
    my $servers = $config->{server};
    return [] unless $servers;
    if (ref($servers) eq "HASH") {
        return [ $servers ];
    } else {
        return $servers;
    }
}

=back 

=head1 LICENSE

This file is part of jmx4perl.

Jmx4perl is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

jmx4perl is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with jmx4perl.  If not, see <http://www.gnu.org/licenses/>.

A commercial license is available as well. Please contact roland@cpan.org for
further details.

=head1 PROFESSIONAL SERVICES

Just in case you need professional support for this module (or Nagios or JMX in
general), you might want to have a look at
http://www.consol.com/opensource/nagios/. Contact roland.huss@consol.de for
further information (or use the contact form at http://www.consol.com/contact/)

=head1 AUTHOR

roland@cpan.org

=cut

1;
