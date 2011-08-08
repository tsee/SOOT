package Devel::REPL::Plugin::CompletionDriver::SOOT;
use Devel::REPL::Plugin;
use Scalar::Util qw(blessed);
use namespace::clean -except => [ 'meta' ];
use Term::ANSIColor qw(:constants :pushpop);

sub BEFORE_PLUGIN {
    my $self = shift;
    $self->load_plugin('Completion');
}

# returns array ref: [$ok, $show_prototype, $methname, $invocant]

sub _match_method_call {
  my ($self, $last) = @_;
  my $show_prototype = 0;
  # If we're after a paren (and the rest below matches, too),
  # then we want to print method signatures.
  if ($last->isa('PPI::Token::Structure') and $last->content eq '(') {
    $show_prototype = 1;
    $last = $last->parent->sprevious_sibling;
    last if not $last;
  }
  # match method name
  return [0, $show_prototype]
    if not $last or not $last->isa('PPI::Token::Word');
  
  # match arrow operator
  my $prev = $last->sprevious_sibling;
  return [0, $show_prototype]
    if not $prev or not $prev->isa('PPI::Token::Operator') or $prev->content ne '->';

  # match invocant
  my $invocant = $prev->sprevious_sibling;
  return [0, $show_prototype]
    if not $invocant
    or not ($invocant->isa('PPI::Token::Symbol') || $invocant->isa('PPI::Token::Word'));

  return [1, $show_prototype, $last, $invocant];
}

sub _try_complete_lexical {
  my ($self, $invocant, $methname, $document, $show_prototype) = @_;
  
  my $soot_obj;
  my $invocant_str = $invocant->content;
  my $lexenv = $self->lexical_environment();
  my $cxt = $lexenv->get_context('_');
  my $var = $cxt->{$invocant_str};

  return
    if not blessed($var)
    or not ($var->isa('TObject') or SOOT::API->is_soot_class(ref($var)));

  my $class = $var->Class;
  if ($show_prototype) {
    my @meth = $class->soot_method_complete_proto_str($methname->content, 1);
    print "\n" if @meth;
    for (@meth) {
      print LOCALCOLOR YELLOW $_;
      print "\n";
    }
    local $| = 1;
    print LOCALCOLOR UNDERLINE $self->prompt;
    print $document->content;
    return [];
  }
  else {
    my @meth = $class->soot_method_complete_name($methname->content);
    return [map "$_(", @meth];
  }
}

around complete => sub {
  my $orig = shift;
  my ($self, $text, $document) = @_;

  # The last token the user has entered (will dive as deep as possible into the PPI structure)
  my $last = $self->last_ppi_element($document);

  my $rv = $self->_match_method_call($last);
  my ($ok, $show_prototype, $methname, $invocant) = @{$rv||[]};
  return if not $ok;

  my $completions = $self->_try_complete_lexical($invocant, $methname, $document, $show_prototype);
  return $orig->(@_), @$completions if $completions;

  return $orig->(@_);
};

1;

__END__

=head1 NAME

Devel::REPL::Plugin::CompletionDriver::SOOT - Complete SOOT method names

=head1 AUTHOR

Steffen Mueller, C<< <smueller@cpan.org> >>

=cut

