use utf8;
package ActiveCMDB::Schema::Database::Result::Security;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Database::Result::Security

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<security>

=cut

__PACKAGE__->table("security");

=head1 ACCESSORS

=head2 security_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 security_name

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 security_user

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 security_pwd

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 security_key

  data_type: 'varchar'
  is_nullable: 1
  size: 1024

=cut

__PACKAGE__->add_columns(
  "security_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "security_name",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "security_user",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "security_pwd",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "security_key",
  { data_type => "varchar", is_nullable => 1, size => 1024 },
);

=head1 PRIMARY KEY

=over 4

=item * L</security_id>

=back

=cut

__PACKAGE__->set_primary_key("security_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<sec_name>

=over 4

=item * L</security_name>

=back

=cut

__PACKAGE__->add_unique_constraint("sec_name", ["security_name"]);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-08-17 15:21:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:q6zpkWTi5Y9bUyw2OEmpOA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
