#
# Autogenerated by Thrift
#
# DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
#
require 5.6.0;
use strict;
use warnings;
use Thrift;

use Hypertable::ThriftGen2::Types;
use Hypertable::ThriftGen::ClientService;

# HELPER FUNCTIONS AND STRUCTURES

package Hypertable::ThriftGen2::HqlService_hql_exec_args;
use Class::Accessor;
use base('Class::Accessor');
Hypertable::ThriftGen2::HqlService_hql_exec_args->mk_accessors( qw( command noflush unbuffered ) );
sub new {
my $classname = shift;
my $self      = {};
my $vals      = shift || {};
$self->{command} = undef;
$self->{noflush} = 0;
$self->{unbuffered} = 0;
  if (UNIVERSAL::isa($vals,'HASH')) {
    if (defined $vals->{command}) {
      $self->{command} = $vals->{command};
    }
    if (defined $vals->{noflush}) {
      $self->{noflush} = $vals->{noflush};
    }
    if (defined $vals->{unbuffered}) {
      $self->{unbuffered} = $vals->{unbuffered};
    }
  }
return bless($self,$classname);
}

sub getName {
  return 'HqlService_hql_exec_args';
}

sub read {
  my $self  = shift;
  my $input = shift;
  my $xfer  = 0;
  my $fname;
  my $ftype = 0;
  my $fid   = 0;
  $xfer += $input->readStructBegin(\$fname);
  while (1) 
  {
    $xfer += $input->readFieldBegin(\$fname, \$ftype, \$fid);
    if ($ftype == TType::STOP) {
      last;
    }
    SWITCH: for($fid)
    {
      /^1$/ && do{      if ($ftype == TType::STRING) {
        $xfer += $input->readString(\$self->{command});
      } else {
        $xfer += $input->skip($ftype);
      }
      last; };
      /^2$/ && do{      if ($ftype == TType::BOOL) {
        $xfer += $input->readBool(\$self->{noflush});
      } else {
        $xfer += $input->skip($ftype);
      }
      last; };
      /^3$/ && do{      if ($ftype == TType::BOOL) {
        $xfer += $input->readBool(\$self->{unbuffered});
      } else {
        $xfer += $input->skip($ftype);
      }
      last; };
        $xfer += $input->skip($ftype);
    }
    $xfer += $input->readFieldEnd();
  }
  $xfer += $input->readStructEnd();
  return $xfer;
}

sub write {
  my $self   = shift;
  my $output = shift;
  my $xfer   = 0;
  $xfer += $output->writeStructBegin('HqlService_hql_exec_args');
  if (defined $self->{command}) {
    $xfer += $output->writeFieldBegin('command', TType::STRING, 1);
    $xfer += $output->writeString($self->{command});
    $xfer += $output->writeFieldEnd();
  }
  if (defined $self->{noflush}) {
    $xfer += $output->writeFieldBegin('noflush', TType::BOOL, 2);
    $xfer += $output->writeBool($self->{noflush});
    $xfer += $output->writeFieldEnd();
  }
  if (defined $self->{unbuffered}) {
    $xfer += $output->writeFieldBegin('unbuffered', TType::BOOL, 3);
    $xfer += $output->writeBool($self->{unbuffered});
    $xfer += $output->writeFieldEnd();
  }
  $xfer += $output->writeFieldStop();
  $xfer += $output->writeStructEnd();
  return $xfer;
}

package Hypertable::ThriftGen2::HqlService_hql_exec_result;
use Class::Accessor;
use base('Class::Accessor');
Hypertable::ThriftGen2::HqlService_hql_exec_result->mk_accessors( qw( success ) );
sub new {
my $classname = shift;
my $self      = {};
my $vals      = shift || {};
$self->{success} = undef;
$self->{e} = undef;
  if (UNIVERSAL::isa($vals,'HASH')) {
    if (defined $vals->{success}) {
      $self->{success} = $vals->{success};
    }
    if (defined $vals->{e}) {
      $self->{e} = $vals->{e};
    }
  }
return bless($self,$classname);
}

sub getName {
  return 'HqlService_hql_exec_result';
}

sub read {
  my $self  = shift;
  my $input = shift;
  my $xfer  = 0;
  my $fname;
  my $ftype = 0;
  my $fid   = 0;
  $xfer += $input->readStructBegin(\$fname);
  while (1) 
  {
    $xfer += $input->readFieldBegin(\$fname, \$ftype, \$fid);
    if ($ftype == TType::STOP) {
      last;
    }
    SWITCH: for($fid)
    {
      /^0$/ && do{      if ($ftype == TType::STRUCT) {
        $self->{success} = new Hypertable::ThriftGen2::HqlResult();
        $xfer += $self->{success}->read($input);
      } else {
        $xfer += $input->skip($ftype);
      }
      last; };
      /^1$/ && do{      if ($ftype == TType::STRUCT) {
        $self->{e} = new Hypertable::ThriftGen::ClientException();
        $xfer += $self->{e}->read($input);
      } else {
        $xfer += $input->skip($ftype);
      }
      last; };
        $xfer += $input->skip($ftype);
    }
    $xfer += $input->readFieldEnd();
  }
  $xfer += $input->readStructEnd();
  return $xfer;
}

sub write {
  my $self   = shift;
  my $output = shift;
  my $xfer   = 0;
  $xfer += $output->writeStructBegin('HqlService_hql_exec_result');
  if (defined $self->{success}) {
    $xfer += $output->writeFieldBegin('success', TType::STRUCT, 0);
    $xfer += $self->{success}->write($output);
    $xfer += $output->writeFieldEnd();
  }
  if (defined $self->{e}) {
    $xfer += $output->writeFieldBegin('e', TType::STRUCT, 1);
    $xfer += $self->{e}->write($output);
    $xfer += $output->writeFieldEnd();
  }
  $xfer += $output->writeFieldStop();
  $xfer += $output->writeStructEnd();
  return $xfer;
}

package Hypertable::ThriftGen2::HqlService_hql_query_args;
use Class::Accessor;
use base('Class::Accessor');
Hypertable::ThriftGen2::HqlService_hql_query_args->mk_accessors( qw( command ) );
sub new {
my $classname = shift;
my $self      = {};
my $vals      = shift || {};
$self->{command} = undef;
  if (UNIVERSAL::isa($vals,'HASH')) {
    if (defined $vals->{command}) {
      $self->{command} = $vals->{command};
    }
  }
return bless($self,$classname);
}

sub getName {
  return 'HqlService_hql_query_args';
}

sub read {
  my $self  = shift;
  my $input = shift;
  my $xfer  = 0;
  my $fname;
  my $ftype = 0;
  my $fid   = 0;
  $xfer += $input->readStructBegin(\$fname);
  while (1) 
  {
    $xfer += $input->readFieldBegin(\$fname, \$ftype, \$fid);
    if ($ftype == TType::STOP) {
      last;
    }
    SWITCH: for($fid)
    {
      /^1$/ && do{      if ($ftype == TType::STRING) {
        $xfer += $input->readString(\$self->{command});
      } else {
        $xfer += $input->skip($ftype);
      }
      last; };
        $xfer += $input->skip($ftype);
    }
    $xfer += $input->readFieldEnd();
  }
  $xfer += $input->readStructEnd();
  return $xfer;
}

sub write {
  my $self   = shift;
  my $output = shift;
  my $xfer   = 0;
  $xfer += $output->writeStructBegin('HqlService_hql_query_args');
  if (defined $self->{command}) {
    $xfer += $output->writeFieldBegin('command', TType::STRING, 1);
    $xfer += $output->writeString($self->{command});
    $xfer += $output->writeFieldEnd();
  }
  $xfer += $output->writeFieldStop();
  $xfer += $output->writeStructEnd();
  return $xfer;
}

package Hypertable::ThriftGen2::HqlService_hql_query_result;
use Class::Accessor;
use base('Class::Accessor');
Hypertable::ThriftGen2::HqlService_hql_query_result->mk_accessors( qw( success ) );
sub new {
my $classname = shift;
my $self      = {};
my $vals      = shift || {};
$self->{success} = undef;
$self->{e} = undef;
  if (UNIVERSAL::isa($vals,'HASH')) {
    if (defined $vals->{success}) {
      $self->{success} = $vals->{success};
    }
    if (defined $vals->{e}) {
      $self->{e} = $vals->{e};
    }
  }
return bless($self,$classname);
}

sub getName {
  return 'HqlService_hql_query_result';
}

sub read {
  my $self  = shift;
  my $input = shift;
  my $xfer  = 0;
  my $fname;
  my $ftype = 0;
  my $fid   = 0;
  $xfer += $input->readStructBegin(\$fname);
  while (1) 
  {
    $xfer += $input->readFieldBegin(\$fname, \$ftype, \$fid);
    if ($ftype == TType::STOP) {
      last;
    }
    SWITCH: for($fid)
    {
      /^0$/ && do{      if ($ftype == TType::STRUCT) {
        $self->{success} = new Hypertable::ThriftGen2::HqlResult();
        $xfer += $self->{success}->read($input);
      } else {
        $xfer += $input->skip($ftype);
      }
      last; };
      /^1$/ && do{      if ($ftype == TType::STRUCT) {
        $self->{e} = new Hypertable::ThriftGen::ClientException();
        $xfer += $self->{e}->read($input);
      } else {
        $xfer += $input->skip($ftype);
      }
      last; };
        $xfer += $input->skip($ftype);
    }
    $xfer += $input->readFieldEnd();
  }
  $xfer += $input->readStructEnd();
  return $xfer;
}

sub write {
  my $self   = shift;
  my $output = shift;
  my $xfer   = 0;
  $xfer += $output->writeStructBegin('HqlService_hql_query_result');
  if (defined $self->{success}) {
    $xfer += $output->writeFieldBegin('success', TType::STRUCT, 0);
    $xfer += $self->{success}->write($output);
    $xfer += $output->writeFieldEnd();
  }
  if (defined $self->{e}) {
    $xfer += $output->writeFieldBegin('e', TType::STRUCT, 1);
    $xfer += $self->{e}->write($output);
    $xfer += $output->writeFieldEnd();
  }
  $xfer += $output->writeFieldStop();
  $xfer += $output->writeStructEnd();
  return $xfer;
}

package Hypertable::ThriftGen2::HqlServiceIf;
use base('Hypertable::ThriftGen::ClientServiceIf');
sub hql_exec{
  my $self = shift;
  my $command = shift;
  my $noflush = shift;
  my $unbuffered = shift;

  die 'implement interface';
}
sub hql_query{
  my $self = shift;
  my $command = shift;

  die 'implement interface';
}
package Hypertable::ThriftGen2::HqlServiceRest;
use base('Hypertable::ThriftGen::ClientServiceRest');
sub hql_exec{
  my $self = shift;
  my $request = shift;

  my $command = ($request->{'command'}) ? $request->{'command'} : undef;
  my $noflush = ($request->{'noflush'}) ? $request->{'noflush'} : undef;
  my $unbuffered = ($request->{'unbuffered'}) ? $request->{'unbuffered'} : undef;
  return $self->{impl}->hql_exec($command, $noflush, $unbuffered);
}

sub hql_query{
  my $self = shift;
  my $request = shift;

  my $command = ($request->{'command'}) ? $request->{'command'} : undef;
  return $self->{impl}->hql_query($command);
}

package Hypertable::ThriftGen2::HqlServiceClient;
use base('Hypertable::ThriftGen::ClientServiceClient');
use base('Hypertable::ThriftGen2::HqlServiceIf');
sub new {
  my $classname = shift;
  my $input     = shift;
  my $output    = shift;
  my $self      = {};
    $self = $classname->SUPER::new($input, $output);
  return bless($self,$classname);
}

sub hql_exec{
  my $self = shift;
  my $command = shift;
  my $noflush = shift;
  my $unbuffered = shift;

    $self->send_hql_exec($command, $noflush, $unbuffered);
  return $self->recv_hql_exec();
}

sub send_hql_exec{
  my $self = shift;
  my $command = shift;
  my $noflush = shift;
  my $unbuffered = shift;

  $self->{output}->writeMessageBegin('hql_exec', TMessageType::CALL, $self->{seqid});
  my $args = new Hypertable::ThriftGen2::HqlService_hql_exec_args();
  $args->{command} = $command;
  $args->{noflush} = $noflush;
  $args->{unbuffered} = $unbuffered;
  $args->write($self->{output});
  $self->{output}->writeMessageEnd();
  $self->{output}->getTransport()->flush();
}

sub recv_hql_exec{
  my $self = shift;

  my $rseqid = 0;
  my $fname;
  my $mtype = 0;

  $self->{input}->readMessageBegin(\$fname, \$mtype, \$rseqid);
  if ($mtype == TMessageType::EXCEPTION) {
    my $x = new TApplicationException();
    $x->read($self->{input});
    $self->{input}->readMessageEnd();
    die $x;
  }
  my $result = new Hypertable::ThriftGen2::HqlService_hql_exec_result();
  $result->read($self->{input});
  $self->{input}->readMessageEnd();

  if (defined $result->{success} ) {
    return $result->{success};
  }
  if (defined $result->{e}) {
    die $result->{e};
  }
  die "hql_exec failed: unknown result";
}
sub hql_query{
  my $self = shift;
  my $command = shift;

    $self->send_hql_query($command);
  return $self->recv_hql_query();
}

sub send_hql_query{
  my $self = shift;
  my $command = shift;

  $self->{output}->writeMessageBegin('hql_query', TMessageType::CALL, $self->{seqid});
  my $args = new Hypertable::ThriftGen2::HqlService_hql_query_args();
  $args->{command} = $command;
  $args->write($self->{output});
  $self->{output}->writeMessageEnd();
  $self->{output}->getTransport()->flush();
}

sub recv_hql_query{
  my $self = shift;

  my $rseqid = 0;
  my $fname;
  my $mtype = 0;

  $self->{input}->readMessageBegin(\$fname, \$mtype, \$rseqid);
  if ($mtype == TMessageType::EXCEPTION) {
    my $x = new TApplicationException();
    $x->read($self->{input});
    $self->{input}->readMessageEnd();
    die $x;
  }
  my $result = new Hypertable::ThriftGen2::HqlService_hql_query_result();
  $result->read($self->{input});
  $self->{input}->readMessageEnd();

  if (defined $result->{success} ) {
    return $result->{success};
  }
  if (defined $result->{e}) {
    die $result->{e};
  }
  die "hql_query failed: unknown result";
}
package Hypertable::ThriftGen2::HqlServiceProcessor;
use base('Hypertable::ThriftGen::ClientServiceProcessor');
sub process {
    my $self   = shift;
    my $input  = shift;
    my $output = shift;
    my $rseqid = 0;
    my $fname  = undef;
    my $mtype  = 0;

    $input->readMessageBegin(\$fname, \$mtype, \$rseqid);
    my $methodname = 'process_'.$fname;
    if (!$self->can($methodname)) {
      $input->skip(TType::STRUCT);
      $input->readMessageEnd();
      my $x = new TApplicationException('Function '.$fname.' not implemented.', TApplicationException::UNKNOWN_METHOD);
      $output->writeMessageBegin($fname, TMessageType::EXCEPTION, $rseqid);
      $x->write($output);
      $output->writeMessageEnd();
      $output->getTransport()->flush();
      return;
    }
    $self->$methodname($rseqid, $input, $output);
    return 1;
  }

sub process_hql_exec{
    my $self = shift;
    my ($seqid, $input, $output) = @_;
    my $args = new Hypertable::ThriftGen2::HqlService_hql_exec_args();
    $args->read($input);
    $input->readMessageEnd();
    my $result = new Hypertable::ThriftGen2::HqlService_hql_exec_result();
    eval {
      $result->{success} = $self->{handler}->hql_exec($args->command, $args->noflush, $args->unbuffered);
    }; if( UNIVERSAL::isa($@,'ClientException') ){ 
      $result->{e} = $@;
    }
    $output->writeMessageBegin('hql_exec', TMessageType::REPLY, $seqid);
    $result->write($output);
    $output->getTransport()->flush();
}
sub process_hql_query{
  my $self = shift;
  my ($seqid, $input, $output) = @_;
  my $args = new Hypertable::ThriftGen2::HqlService_hql_query_args();
  $args->read($input);
  $input->readMessageEnd();
  my $result = new Hypertable::ThriftGen2::HqlService_hql_query_result();
  eval {
    $result->{success} = $self->{handler}->hql_query($args->command);
  }; if( UNIVERSAL::isa($@,'ClientException') ){ 
    $result->{e} = $@;
  }
  $output->writeMessageBegin('hql_query', TMessageType::REPLY, $seqid);
  $result->write($output);
  $output->getTransport()->flush();
}
1;
