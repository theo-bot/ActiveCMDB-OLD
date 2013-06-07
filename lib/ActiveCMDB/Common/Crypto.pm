#########################################################################
# Initialize package
package ActiveCMDB::Common::Crypto;

#########################################################################
# Initialize  modules
use Exporter;
use Crypt::OpenSSL::RSA;
use constant ENCPAYLOAD_FORMAT => 'Na*';

@ISA = ('Exporter');

@EXPORT = qw(
			cmdb_encrypt
			cmdb_decrypt
			cmdb_genkey
			);

my $public_key = undef;
my $private_key = undef;

=head2 cmdb_encrypt

Encrypts a message using a public key.

=cut

sub cmdb_encrypt($$) {
	my($keyname, $message) = @_;
	
	if ( !defined($public_key) ) {
		my $keyfile = sprintf("%s/conf/%s.public.key",$ENV{CMDB_HOME}, $keyname);
		if ( -e $keyfile ) {
			open PUBLIC, $keyfile;
			$public_key = join("", <PUBLIC>);
			close(PUBLIC);
		} else {
			return -1;
		}
	}
	
	my $rsa = Crypt::OpenSSL::RSA->new_public_key($public_key);
	$rsa->use_pkcs1_padding();
	my $blockct = int(length($message) / 245 ) + 1;
	my $encpayload = "";
	
	for (my $loop =0; $loop<$blockct; $loop++)
	{
		$encpayload .= $rsa->encrypt(substr($message, $loop * 245, 245));
	}
	return cmdb_bin2hex(pack(ENCPAYLOAD_FORMAT,$blockct,$encpayload));
}

=head2 cmdb_decrypt


=cut

sub cmdb_decrypt($$) {
	my($keyname, $message) = @_;
	
	if ( !defined($private_key) ) {
		my $keyfile = sprintf("%s/conf/%s.private.key",$ENV{CMDB_HOME}, $keyname);
		if ( -e $keyfile ) {
			open PUBLIC, $keyfile;
			$private_key = join("", <PUBLIC>);
			close(PUBLIC);
		} else {
			return -1;
		}
	}
	
	my $rsa = Crypt::OpenSSL::RSA->new_private_key($private_key);
	$rsa->use_pkcs1_padding();
	
	my($blockct, $encpayload) = unpack(ENCPAYLOAD_FORMAT, cmdb_hex2bin($message));
	my $decmessage = "";
	
	for (my $loop=0; $loop<$blockct; $loop++)
	{
		$decmessage .= $rsa->decrypt(substr($encpayload, $loop * 256, 256) );
	}
	
	return $decmessage;
}

=head2 cmdb_genkey

Generates a rsa key pair

=cut

sub cmdb_genkey($) {
	my($keyname) = @_;
	
	my $rsa = Crypt::OpenSSL::RSA->generate_key(2048);
	my $private_key = $ENV{CMDB_HOME} . '/conf/' . $keyname.'.private.key';
	my $public_key  = $ENV{CMDB_HOME} . '/conf/' . $keyname.'.public.key';
	print "Generating keypair for $keyname\n";
	
	if ( !(-e $private_key) )
	{
		open(PRIVATE, "> $private_key");
		print PRIVATE $rsa->get_private_key_string();
		close(PRIVATE);
		
		open(PUBLIC, "> $public_key");
		print PUBLIC $rsa->get_public_key_x509_string();
		close(PUBLIC);
	}
}

=head2 cmdb_bin2hex

=cut

sub cmdb_bin2hex($) {
	my($data) = shift;
	my $hex = "";
	
	foreach (split(//, $data))
	{
		$hex .= sprintf("%02x", ord($_))
	}
	
	return $hex;	
}

sub cmdb_hex2bin($)
{
	my($hex) = shift;
	my $data = "";
	my $lc   = 0;
	
	my $len = length($hex);
	
	while ( $lc < $len )
	{
		my $hexcode = '0x'.substr($hex, $lc, 2);
		my $dec = hex($hexcode);
		
		$data .= chr($dec);
		$lc += 2;
	}
	
	return $data;
}

1;