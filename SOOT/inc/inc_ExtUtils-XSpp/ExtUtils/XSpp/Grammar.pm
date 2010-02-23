####################################################################
#
#    This file was generated using Parse::Yapp version 1.05.
#
#        Don't edit this file, use source file instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
####################################################################
package ExtUtils::XSpp::Grammar;
use vars qw ( @ISA );
use strict;

@ISA= qw ( ExtUtils::XSpp::Grammar::YappDriver );
#Included Parse/Yapp/Driver.pm file----------------------------------------
{
#
# Module ExtUtils::XSpp::Grammar::YappDriver
#
# This module is part of the Parse::Yapp package available on your
# nearest CPAN
#
# Any use of this module in a standalone parser make the included
# text under the same copyright as the Parse::Yapp module itself.
#
# This notice should remain unchanged.
#
# (c) Copyright 1998-2001 Francois Desarmenien, all rights reserved.
# (see the pod text in Parse::Yapp module for use and distribution rights)
#

package ExtUtils::XSpp::Grammar::YappDriver;

require 5.004;

use strict;

use vars qw ( $VERSION $COMPATIBLE $FILENAME );

$VERSION = '1.05';
$COMPATIBLE = '0.07';
$FILENAME=__FILE__;

use Carp;

#Known parameters, all starting with YY (leading YY will be discarded)
my(%params)=(YYLEX => 'CODE', 'YYERROR' => 'CODE', YYVERSION => '',
			 YYRULES => 'ARRAY', YYSTATES => 'ARRAY', YYDEBUG => '');
#Mandatory parameters
my(@params)=('LEX','RULES','STATES');

sub new {
    my($class)=shift;
	my($errst,$nberr,$token,$value,$check,$dotpos);
    my($self)={ ERROR => \&_Error,
				ERRST => \$errst,
                NBERR => \$nberr,
				TOKEN => \$token,
				VALUE => \$value,
				DOTPOS => \$dotpos,
				STACK => [],
				DEBUG => 0,
				CHECK => \$check };

	_CheckParams( [], \%params, \@_, $self );

		exists($$self{VERSION})
	and	$$self{VERSION} < $COMPATIBLE
	and	croak "Yapp driver version $VERSION ".
			  "incompatible with version $$self{VERSION}:\n".
			  "Please recompile parser module.";

        ref($class)
    and $class=ref($class);

    bless($self,$class);
}

sub YYParse {
    my($self)=shift;
    my($retval);

	_CheckParams( \@params, \%params, \@_, $self );

	if($$self{DEBUG}) {
		_DBLoad();
		$retval = eval '$self->_DBParse()';#Do not create stab entry on compile
        $@ and die $@;
	}
	else {
		$retval = $self->_Parse();
	}
    $retval
}

sub YYData {
	my($self)=shift;

		exists($$self{USER})
	or	$$self{USER}={};

	$$self{USER};
	
}

sub YYErrok {
	my($self)=shift;

	${$$self{ERRST}}=0;
    undef;
}

sub YYNberr {
	my($self)=shift;

	${$$self{NBERR}};
}

sub YYRecovering {
	my($self)=shift;

	${$$self{ERRST}} != 0;
}

sub YYAbort {
	my($self)=shift;

	${$$self{CHECK}}='ABORT';
    undef;
}

sub YYAccept {
	my($self)=shift;

	${$$self{CHECK}}='ACCEPT';
    undef;
}

sub YYError {
	my($self)=shift;

	${$$self{CHECK}}='ERROR';
    undef;
}

sub YYSemval {
	my($self)=shift;
	my($index)= $_[0] - ${$$self{DOTPOS}} - 1;

		$index < 0
	and	-$index <= @{$$self{STACK}}
	and	return $$self{STACK}[$index][1];

	undef;	#Invalid index
}

sub YYCurtok {
	my($self)=shift;

        @_
    and ${$$self{TOKEN}}=$_[0];
    ${$$self{TOKEN}};
}

sub YYCurval {
	my($self)=shift;

        @_
    and ${$$self{VALUE}}=$_[0];
    ${$$self{VALUE}};
}

sub YYExpect {
    my($self)=shift;

    keys %{$self->{STATES}[$self->{STACK}[-1][0]]{ACTIONS}}
}

sub YYLexer {
    my($self)=shift;

	$$self{LEX};
}


#################
# Private stuff #
#################


sub _CheckParams {
	my($mandatory,$checklist,$inarray,$outhash)=@_;
	my($prm,$value);
	my($prmlst)={};

	while(($prm,$value)=splice(@$inarray,0,2)) {
        $prm=uc($prm);
			exists($$checklist{$prm})
		or	croak("Unknow parameter '$prm'");
			ref($value) eq $$checklist{$prm}
		or	croak("Invalid value for parameter '$prm'");
        $prm=unpack('@2A*',$prm);
		$$outhash{$prm}=$value;
	}
	for (@$mandatory) {
			exists($$outhash{$_})
		or	croak("Missing mandatory parameter '".lc($_)."'");
	}
}

sub _Error {
	print "Parse error.\n";
}

sub _DBLoad {
	{
		no strict 'refs';

			exists(${__PACKAGE__.'::'}{_DBParse})#Already loaded ?
		and	return;
	}
	my($fname)=__FILE__;
	my(@drv);
	open(DRV,"<$fname") or die "Report this as a BUG: Cannot open $fname";
	while(<DRV>) {
                	/^\s*sub\s+_Parse\s*{\s*$/ .. /^\s*}\s*#\s*_Parse\s*$/
        	and     do {
                	s/^#DBG>//;
                	push(@drv,$_);
        	}
	}
	close(DRV);

	$drv[0]=~s/_P/_DBP/;
	eval join('',@drv);
}

#Note that for loading debugging version of the driver,
#this file will be parsed from 'sub _Parse' up to '}#_Parse' inclusive.
#So, DO NOT remove comment at end of sub !!!
sub _Parse {
    my($self)=shift;

	my($rules,$states,$lex,$error)
     = @$self{ 'RULES', 'STATES', 'LEX', 'ERROR' };
	my($errstatus,$nberror,$token,$value,$stack,$check,$dotpos)
     = @$self{ 'ERRST', 'NBERR', 'TOKEN', 'VALUE', 'STACK', 'CHECK', 'DOTPOS' };

#DBG>	my($debug)=$$self{DEBUG};
#DBG>	my($dbgerror)=0;

#DBG>	my($ShowCurToken) = sub {
#DBG>		my($tok)='>';
#DBG>		for (split('',$$token)) {
#DBG>			$tok.=		(ord($_) < 32 or ord($_) > 126)
#DBG>					?	sprintf('<%02X>',ord($_))
#DBG>					:	$_;
#DBG>		}
#DBG>		$tok.='<';
#DBG>	};

	$$errstatus=0;
	$$nberror=0;
	($$token,$$value)=(undef,undef);
	@$stack=( [ 0, undef ] );
	$$check='';

    while(1) {
        my($actions,$act,$stateno);

        $stateno=$$stack[-1][0];
        $actions=$$states[$stateno];

#DBG>	print STDERR ('-' x 40),"\n";
#DBG>		$debug & 0x2
#DBG>	and	print STDERR "In state $stateno:\n";
#DBG>		$debug & 0x08
#DBG>	and	print STDERR "Stack:[".
#DBG>					 join(',',map { $$_[0] } @$stack).
#DBG>					 "]\n";


        if  (exists($$actions{ACTIONS})) {

				defined($$token)
            or	do {
				($$token,$$value)=&$lex($self);
#DBG>				$debug & 0x01
#DBG>			and	print STDERR "Need token. Got ".&$ShowCurToken."\n";
			};

            $act=   exists($$actions{ACTIONS}{$$token})
                    ?   $$actions{ACTIONS}{$$token}
                    :   exists($$actions{DEFAULT})
                        ?   $$actions{DEFAULT}
                        :   undef;
        }
        else {
            $act=$$actions{DEFAULT};
#DBG>			$debug & 0x01
#DBG>		and	print STDERR "Don't need token.\n";
        }

            defined($act)
        and do {

                $act > 0
            and do {        #shift

#DBG>				$debug & 0x04
#DBG>			and	print STDERR "Shift and go to state $act.\n";

					$$errstatus
				and	do {
					--$$errstatus;

#DBG>					$debug & 0x10
#DBG>				and	$dbgerror
#DBG>				and	$$errstatus == 0
#DBG>				and	do {
#DBG>					print STDERR "**End of Error recovery.\n";
#DBG>					$dbgerror=0;
#DBG>				};
				};


                push(@$stack,[ $act, $$value ]);

					$$token ne ''	#Don't eat the eof
				and	$$token=$$value=undef;
                next;
            };

            #reduce
            my($lhs,$len,$code,@sempar,$semval);
            ($lhs,$len,$code)=@{$$rules[-$act]};

#DBG>			$debug & 0x04
#DBG>		and	$act
#DBG>		and	print STDERR "Reduce using rule ".-$act." ($lhs,$len): ";

                $act
            or  $self->YYAccept();

            $$dotpos=$len;

                unpack('A1',$lhs) eq '@'    #In line rule
            and do {
                    $lhs =~ /^\@[0-9]+\-([0-9]+)$/
                or  die "In line rule name '$lhs' ill formed: ".
                        "report it as a BUG.\n";
                $$dotpos = $1;
            };

            @sempar =       $$dotpos
                        ?   map { $$_[1] } @$stack[ -$$dotpos .. -1 ]
                        :   ();

            $semval = $code ? &$code( $self, @sempar )
                            : @sempar ? $sempar[0] : undef;

            splice(@$stack,-$len,$len);

                $$check eq 'ACCEPT'
            and do {

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Accept.\n";

				return($semval);
			};

                $$check eq 'ABORT'
            and	do {

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Abort.\n";

				return(undef);

			};

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Back to state $$stack[-1][0], then ";

                $$check eq 'ERROR'
            or  do {
#DBG>				$debug & 0x04
#DBG>			and	print STDERR 
#DBG>				    "go to state $$states[$$stack[-1][0]]{GOTOS}{$lhs}.\n";

#DBG>				$debug & 0x10
#DBG>			and	$dbgerror
#DBG>			and	$$errstatus == 0
#DBG>			and	do {
#DBG>				print STDERR "**End of Error recovery.\n";
#DBG>				$dbgerror=0;
#DBG>			};

			    push(@$stack,
                     [ $$states[$$stack[-1][0]]{GOTOS}{$lhs}, $semval ]);
                $$check='';
                next;
            };

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Forced Error recovery.\n";

            $$check='';

        };

        #Error
            $$errstatus
        or   do {

            $$errstatus = 1;
            &$error($self);
                $$errstatus # if 0, then YYErrok has been called
            or  next;       # so continue parsing

#DBG>			$debug & 0x10
#DBG>		and	do {
#DBG>			print STDERR "**Entering Error recovery.\n";
#DBG>			++$dbgerror;
#DBG>		};

            ++$$nberror;

        };

			$$errstatus == 3	#The next token is not valid: discard it
		and	do {
				$$token eq ''	# End of input: no hope
			and	do {
#DBG>				$debug & 0x10
#DBG>			and	print STDERR "**At eof: aborting.\n";
				return(undef);
			};

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Dicard invalid token ".&$ShowCurToken.".\n";

			$$token=$$value=undef;
		};

        $$errstatus=3;

		while(	  @$stack
			  and (		not exists($$states[$$stack[-1][0]]{ACTIONS})
			        or  not exists($$states[$$stack[-1][0]]{ACTIONS}{error})
					or	$$states[$$stack[-1][0]]{ACTIONS}{error} <= 0)) {

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Pop state $$stack[-1][0].\n";

			pop(@$stack);
		}

			@$stack
		or	do {

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**No state left on stack: aborting.\n";

			return(undef);
		};

		#shift the error token

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Shift \$error token and go to state ".
#DBG>						 $$states[$$stack[-1][0]]{ACTIONS}{error}.
#DBG>						 ".\n";

		push(@$stack, [ $$states[$$stack[-1][0]]{ACTIONS}{error}, undef ]);

    }

    #never reached
	croak("Error in driver logic. Please, report it as a BUG");

}#_Parse
#DO NOT remove comment

1;

}
#End of include--------------------------------------------------




sub new {
        my($class)=shift;
        ref($class)
    and $class=ref($class);

    my($self)=$class->SUPER::new( yyversion => '1.05',
                                  yystates =>
[
	{#State 0
		ACTIONS => {
			'ID' => 23,
			'p_typemap' => 3,
			'OPSPECIAL' => 28,
			'COMMENT' => 4,
			'p_exceptionmap' => 31,
			"class" => 6,
			'RAW_CODE' => 32,
			"const" => 8,
			"int" => 34,
			'p_module' => 13,
			'p_loadplugin' => 39,
			'p_package' => 38,
			"short" => 15,
			'p_file' => 40,
			"unsigned" => 41,
			'p_name' => 17,
			'p_include' => 18,
			"long" => 19,
			"char" => 22
		},
		GOTOS => {
			'perc_loadplugin' => 24,
			'class_name' => 1,
			'top_list' => 2,
			'nconsttype' => 27,
			'perc_package' => 26,
			'function' => 25,
			'exceptionmap' => 29,
			'special_block_start' => 30,
			'perc_name' => 5,
			'class_decl' => 33,
			'typemap' => 7,
			'decorate_class' => 9,
			'special_block' => 10,
			'perc_module' => 35,
			'type_name' => 11,
			'perc_file' => 37,
			'basic_type' => 36,
			'template' => 12,
			'decorate_function' => 14,
			'top' => 16,
			'function_decl' => 42,
			'perc_include' => 43,
			'directive' => 44,
			'type' => 20,
			'class' => 21,
			'raw' => 45
		}
	},
	{#State 1
		ACTIONS => {
			'OPANG' => 46
		},
		DEFAULT => -90
	},
	{#State 2
		ACTIONS => {
			'ID' => 23,
			'' => 47,
			'p_typemap' => 3,
			'OPSPECIAL' => 28,
			'COMMENT' => 4,
			'p_exceptionmap' => 31,
			"class" => 6,
			'RAW_CODE' => 32,
			"const" => 8,
			"int" => 34,
			'p_module' => 13,
			'p_package' => 38,
			'p_loadplugin' => 39,
			"short" => 15,
			'p_file' => 40,
			"unsigned" => 41,
			'p_name' => 17,
			'p_include' => 18,
			"long" => 19,
			"char" => 22
		},
		GOTOS => {
			'perc_loadplugin' => 24,
			'class_name' => 1,
			'function' => 25,
			'perc_package' => 26,
			'nconsttype' => 27,
			'exceptionmap' => 29,
			'special_block_start' => 30,
			'perc_name' => 5,
			'class_decl' => 33,
			'typemap' => 7,
			'decorate_class' => 9,
			'special_block' => 10,
			'perc_module' => 35,
			'type_name' => 11,
			'perc_file' => 37,
			'basic_type' => 36,
			'template' => 12,
			'decorate_function' => 14,
			'top' => 48,
			'function_decl' => 42,
			'perc_include' => 43,
			'directive' => 44,
			'type' => 20,
			'class' => 21,
			'raw' => 45
		}
	},
	{#State 3
		ACTIONS => {
			'OPCURLY' => 49
		}
	},
	{#State 4
		DEFAULT => -23
	},
	{#State 5
		ACTIONS => {
			'ID' => 23,
			"class" => 6,
			"short" => 15,
			"const" => 8,
			'p_name' => 17,
			"unsigned" => 41,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 11,
			'class_name' => 1,
			'basic_type' => 36,
			'function' => 51,
			'nconsttype' => 27,
			'template' => 12,
			'decorate_function' => 14,
			'perc_name' => 5,
			'class_decl' => 33,
			'function_decl' => 42,
			'decorate_class' => 9,
			'type' => 20,
			'class' => 50
		}
	},
	{#State 6
		ACTIONS => {
			'ID' => 52
		}
	},
	{#State 7
		DEFAULT => -12
	},
	{#State 8
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 41,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 11,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 53,
			'template' => 12
		}
	},
	{#State 9
		DEFAULT => -26
	},
	{#State 10
		DEFAULT => -24
	},
	{#State 11
		DEFAULT => -88
	},
	{#State 12
		DEFAULT => -89
	},
	{#State 13
		ACTIONS => {
			'OPCURLY' => 54
		}
	},
	{#State 14
		DEFAULT => -28
	},
	{#State 15
		ACTIONS => {
			"int" => 55
		},
		DEFAULT => -97
	},
	{#State 16
		DEFAULT => -1
	},
	{#State 17
		ACTIONS => {
			'OPCURLY' => 56
		}
	},
	{#State 18
		ACTIONS => {
			'OPCURLY' => 57
		}
	},
	{#State 19
		ACTIONS => {
			"int" => 58
		},
		DEFAULT => -96
	},
	{#State 20
		ACTIONS => {
			'ID' => 59
		}
	},
	{#State 21
		DEFAULT => -4
	},
	{#State 22
		DEFAULT => -94
	},
	{#State 23
		ACTIONS => {
			'DCOLON' => 61
		},
		DEFAULT => -103,
		GOTOS => {
			'class_suffix' => 60
		}
	},
	{#State 24
		ACTIONS => {
			'SEMICOLON' => 62
		}
	},
	{#State 25
		DEFAULT => -6
	},
	{#State 26
		ACTIONS => {
			'SEMICOLON' => 63
		}
	},
	{#State 27
		ACTIONS => {
			'STAR' => 65,
			'AMP' => 64
		},
		DEFAULT => -85
	},
	{#State 28
		DEFAULT => -132
	},
	{#State 29
		DEFAULT => -13
	},
	{#State 30
		ACTIONS => {
			'CLSPECIAL' => 66,
			'line' => 67
		},
		GOTOS => {
			'special_block_end' => 68,
			'lines' => 69
		}
	},
	{#State 31
		ACTIONS => {
			'OPCURLY' => 70
		}
	},
	{#State 32
		DEFAULT => -22
	},
	{#State 33
		DEFAULT => -25
	},
	{#State 34
		DEFAULT => -95
	},
	{#State 35
		ACTIONS => {
			'SEMICOLON' => 71
		}
	},
	{#State 36
		DEFAULT => -91
	},
	{#State 37
		ACTIONS => {
			'SEMICOLON' => 72
		}
	},
	{#State 38
		ACTIONS => {
			'OPCURLY' => 73
		}
	},
	{#State 39
		ACTIONS => {
			'OPCURLY' => 74
		}
	},
	{#State 40
		ACTIONS => {
			'OPCURLY' => 75
		}
	},
	{#State 41
		ACTIONS => {
			"short" => 15,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		DEFAULT => -92,
		GOTOS => {
			'basic_type' => 76
		}
	},
	{#State 42
		DEFAULT => -27
	},
	{#State 43
		ACTIONS => {
			'SEMICOLON' => 77
		}
	},
	{#State 44
		DEFAULT => -5
	},
	{#State 45
		DEFAULT => -3
	},
	{#State 46
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 41,
			"const" => 8,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_list' => 79,
			'type_name' => 11,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 27,
			'template' => 12,
			'type' => 78
		}
	},
	{#State 47
		DEFAULT => 0
	},
	{#State 48
		DEFAULT => -2
	},
	{#State 49
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 41,
			"const" => 8,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 11,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 27,
			'template' => 12,
			'type' => 80
		}
	},
	{#State 50
		DEFAULT => -31
	},
	{#State 51
		DEFAULT => -32
	},
	{#State 52
		ACTIONS => {
			'COLON' => 82
		},
		DEFAULT => -39,
		GOTOS => {
			'base_classes' => 81
		}
	},
	{#State 53
		ACTIONS => {
			'STAR' => 65,
			'AMP' => 64
		},
		DEFAULT => -84
	},
	{#State 54
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 83
		}
	},
	{#State 55
		DEFAULT => -99
	},
	{#State 56
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 84
		}
	},
	{#State 57
		ACTIONS => {
			'ID' => 86,
			'DASH' => 87
		},
		GOTOS => {
			'file_name' => 85
		}
	},
	{#State 58
		DEFAULT => -98
	},
	{#State 59
		ACTIONS => {
			'OPPAR' => 88
		}
	},
	{#State 60
		ACTIONS => {
			'DCOLON' => 89
		},
		DEFAULT => -104
	},
	{#State 61
		ACTIONS => {
			'ID' => 90
		}
	},
	{#State 62
		DEFAULT => -10
	},
	{#State 63
		DEFAULT => -8
	},
	{#State 64
		DEFAULT => -87
	},
	{#State 65
		DEFAULT => -86
	},
	{#State 66
		DEFAULT => -133
	},
	{#State 67
		DEFAULT => -134
	},
	{#State 68
		DEFAULT => -131
	},
	{#State 69
		ACTIONS => {
			'CLSPECIAL' => 66,
			'line' => 91
		},
		GOTOS => {
			'special_block_end' => 92
		}
	},
	{#State 70
		ACTIONS => {
			'ID' => 93
		}
	},
	{#State 71
		DEFAULT => -7
	},
	{#State 72
		DEFAULT => -9
	},
	{#State 73
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 94
		}
	},
	{#State 74
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 95
		}
	},
	{#State 75
		ACTIONS => {
			'ID' => 86,
			'DASH' => 87
		},
		GOTOS => {
			'file_name' => 96
		}
	},
	{#State 76
		DEFAULT => -93
	},
	{#State 77
		DEFAULT => -11
	},
	{#State 78
		DEFAULT => -101
	},
	{#State 79
		ACTIONS => {
			'CLANG' => 97,
			'COMMA' => 98
		}
	},
	{#State 80
		ACTIONS => {
			'CLCURLY' => 99
		}
	},
	{#State 81
		ACTIONS => {
			'COMMA' => 101
		},
		DEFAULT => -46,
		GOTOS => {
			'class_metadata' => 100
		}
	},
	{#State 82
		ACTIONS => {
			"protected" => 105,
			"private" => 104,
			"public" => 102
		},
		GOTOS => {
			'base_class' => 103
		}
	},
	{#State 83
		ACTIONS => {
			'CLCURLY' => 106
		}
	},
	{#State 84
		ACTIONS => {
			'CLCURLY' => 107
		}
	},
	{#State 85
		ACTIONS => {
			'CLCURLY' => 108
		}
	},
	{#State 86
		ACTIONS => {
			'DOT' => 110,
			'SLASH' => 109
		}
	},
	{#State 87
		DEFAULT => -109
	},
	{#State 88
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"const" => 8,
			"unsigned" => 41,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		DEFAULT => -114,
		GOTOS => {
			'type_name' => 11,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 27,
			'template' => 12,
			'arg_list' => 112,
			'argument' => 113,
			'type' => 111
		}
	},
	{#State 89
		ACTIONS => {
			'ID' => 114
		}
	},
	{#State 90
		DEFAULT => -107
	},
	{#State 91
		DEFAULT => -135
	},
	{#State 92
		DEFAULT => -130
	},
	{#State 93
		ACTIONS => {
			'CLCURLY' => 115
		}
	},
	{#State 94
		ACTIONS => {
			'CLCURLY' => 116
		}
	},
	{#State 95
		ACTIONS => {
			'CLCURLY' => 117
		}
	},
	{#State 96
		ACTIONS => {
			'CLCURLY' => 118
		}
	},
	{#State 97
		DEFAULT => -100
	},
	{#State 98
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 41,
			"const" => 8,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 11,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 27,
			'template' => 12,
			'type' => 119
		}
	},
	{#State 99
		ACTIONS => {
			'OPCURLY' => 120
		}
	},
	{#State 100
		ACTIONS => {
			'OPCURLY' => 121,
			'p_catch' => 123
		},
		GOTOS => {
			'perc_catch' => 122
		}
	},
	{#State 101
		ACTIONS => {
			"protected" => 105,
			"private" => 104,
			"public" => 102
		},
		GOTOS => {
			'base_class' => 124
		}
	},
	{#State 102
		ACTIONS => {
			'ID' => 23,
			'p_name' => 17
		},
		GOTOS => {
			'perc_name' => 126,
			'class_name' => 125,
			'class_name_rename' => 127
		}
	},
	{#State 103
		DEFAULT => -37
	},
	{#State 104
		ACTIONS => {
			'ID' => 23,
			'p_name' => 17
		},
		GOTOS => {
			'perc_name' => 126,
			'class_name' => 125,
			'class_name_rename' => 128
		}
	},
	{#State 105
		ACTIONS => {
			'ID' => 23,
			'p_name' => 17
		},
		GOTOS => {
			'perc_name' => 126,
			'class_name' => 125,
			'class_name_rename' => 129
		}
	},
	{#State 106
		DEFAULT => -76
	},
	{#State 107
		DEFAULT => -74
	},
	{#State 108
		DEFAULT => -79
	},
	{#State 109
		ACTIONS => {
			'ID' => 86,
			'DASH' => 87
		},
		GOTOS => {
			'file_name' => 130
		}
	},
	{#State 110
		ACTIONS => {
			'ID' => 131
		}
	},
	{#State 111
		ACTIONS => {
			'ID' => 133,
			'p_length' => 132
		}
	},
	{#State 112
		ACTIONS => {
			'CLPAR' => 134,
			'COMMA' => 135
		}
	},
	{#State 113
		DEFAULT => -112
	},
	{#State 114
		DEFAULT => -108
	},
	{#State 115
		ACTIONS => {
			'OPCURLY' => 136
		}
	},
	{#State 116
		DEFAULT => -75
	},
	{#State 117
		DEFAULT => -78
	},
	{#State 118
		DEFAULT => -77
	},
	{#State 119
		DEFAULT => -102
	},
	{#State 120
		ACTIONS => {
			'ID' => 137
		}
	},
	{#State 121
		DEFAULT => -47,
		GOTOS => {
			'class_body_list' => 138
		}
	},
	{#State 122
		DEFAULT => -45
	},
	{#State 123
		ACTIONS => {
			'OPCURLY' => 139
		}
	},
	{#State 124
		DEFAULT => -38
	},
	{#State 125
		DEFAULT => -43
	},
	{#State 126
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 140
		}
	},
	{#State 127
		DEFAULT => -40
	},
	{#State 128
		DEFAULT => -42
	},
	{#State 129
		DEFAULT => -41
	},
	{#State 130
		DEFAULT => -111
	},
	{#State 131
		DEFAULT => -110
	},
	{#State 132
		ACTIONS => {
			'OPCURLY' => 141
		}
	},
	{#State 133
		ACTIONS => {
			'EQUAL' => 142
		},
		DEFAULT => -117
	},
	{#State 134
		ACTIONS => {
			"const" => 143
		},
		DEFAULT => -61,
		GOTOS => {
			'const' => 144
		}
	},
	{#State 135
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 41,
			"const" => 8,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'argument' => 145,
			'type_name' => 11,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 27,
			'template' => 12,
			'type' => 111
		}
	},
	{#State 136
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 41,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 147,
			'class_name' => 146,
			'basic_type' => 36
		}
	},
	{#State 137
		ACTIONS => {
			'CLCURLY' => 148
		}
	},
	{#State 138
		ACTIONS => {
			'ID' => 161,
			'p_typemap' => 3,
			'OPSPECIAL' => 28,
			"virtual" => 163,
			'COMMENT' => 4,
			"class_static" => 149,
			"package_static" => 164,
			"public" => 151,
			'p_exceptionmap' => 31,
			'RAW_CODE' => 32,
			"const" => 8,
			"int" => 34,
			"private" => 154,
			'CLCURLY' => 169,
			"short" => 15,
			"unsigned" => 41,
			'p_name' => 17,
			'TILDE' => 157,
			"protected" => 158,
			"long" => 19,
			"char" => 22
		},
		GOTOS => {
			'decorate_method' => 162,
			'class_name' => 1,
			'nconsttype' => 27,
			'static' => 150,
			'exceptionmap' => 165,
			'special_block_start' => 30,
			'perc_name' => 152,
			'typemap' => 153,
			'class_body_element' => 166,
			'method' => 167,
			'special_block' => 10,
			'access_specifier' => 155,
			'type_name' => 11,
			'ctor' => 156,
			'basic_type' => 36,
			'template' => 12,
			'virtual' => 168,
			'function_decl' => 170,
			'type' => 20,
			'dtor' => 159,
			'raw' => 171,
			'method_decl' => 160
		}
	},
	{#State 139
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 172,
			'class_name_list' => 173
		}
	},
	{#State 140
		DEFAULT => -44
	},
	{#State 141
		ACTIONS => {
			'ID' => 174
		}
	},
	{#State 142
		ACTIONS => {
			'ID' => 23,
			'INTEGER' => 176,
			'QUOTED_STRING' => 178,
			'DASH' => 180,
			'FLOAT' => 179
		},
		GOTOS => {
			'class_name' => 175,
			'value' => 177
		}
	},
	{#State 143
		DEFAULT => -60
	},
	{#State 144
		DEFAULT => -69,
		GOTOS => {
			'function_metadata' => 181
		}
	},
	{#State 145
		DEFAULT => -113
	},
	{#State 146
		DEFAULT => -90
	},
	{#State 147
		ACTIONS => {
			'CLCURLY' => 182
		}
	},
	{#State 148
		ACTIONS => {
			'OPSPECIAL' => 28
		},
		DEFAULT => -129,
		GOTOS => {
			'special_blocks' => 184,
			'special_block' => 183,
			'special_block_start' => 30
		}
	},
	{#State 149
		DEFAULT => -64
	},
	{#State 150
		ACTIONS => {
			'ID' => 161,
			"virtual" => 163,
			"class_static" => 149,
			"package_static" => 164,
			"short" => 15,
			"unsigned" => 41,
			"const" => 8,
			'p_name' => 17,
			'TILDE' => 157,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'decorate_method' => 162,
			'type_name' => 11,
			'class_name' => 1,
			'ctor' => 156,
			'basic_type' => 36,
			'nconsttype' => 27,
			'template' => 12,
			'static' => 150,
			'virtual' => 168,
			'perc_name' => 152,
			'function_decl' => 170,
			'method' => 185,
			'type' => 20,
			'dtor' => 159,
			'method_decl' => 160
		}
	},
	{#State 151
		ACTIONS => {
			'COLON' => 186
		}
	},
	{#State 152
		ACTIONS => {
			'ID' => 161,
			"virtual" => 163,
			"class_static" => 149,
			"package_static" => 164,
			"short" => 15,
			"unsigned" => 41,
			"const" => 8,
			'p_name' => 17,
			'TILDE' => 157,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'decorate_method' => 162,
			'type_name' => 11,
			'class_name' => 1,
			'ctor' => 156,
			'basic_type' => 36,
			'nconsttype' => 27,
			'template' => 12,
			'static' => 150,
			'virtual' => 168,
			'perc_name' => 152,
			'function_decl' => 170,
			'method' => 187,
			'type' => 20,
			'dtor' => 159,
			'method_decl' => 160
		}
	},
	{#State 153
		DEFAULT => -51
	},
	{#State 154
		ACTIONS => {
			'COLON' => 188
		}
	},
	{#State 155
		DEFAULT => -53
	},
	{#State 156
		DEFAULT => -58
	},
	{#State 157
		ACTIONS => {
			'ID' => 189
		}
	},
	{#State 158
		ACTIONS => {
			'COLON' => 190
		}
	},
	{#State 159
		DEFAULT => -59
	},
	{#State 160
		DEFAULT => -29
	},
	{#State 161
		ACTIONS => {
			'DCOLON' => 61,
			'OPPAR' => 191
		},
		DEFAULT => -103,
		GOTOS => {
			'class_suffix' => 60
		}
	},
	{#State 162
		DEFAULT => -30
	},
	{#State 163
		DEFAULT => -62
	},
	{#State 164
		DEFAULT => -63
	},
	{#State 165
		DEFAULT => -52
	},
	{#State 166
		DEFAULT => -48
	},
	{#State 167
		DEFAULT => -49
	},
	{#State 168
		ACTIONS => {
			'ID' => 161,
			"virtual" => 163,
			"class_static" => 149,
			"package_static" => 164,
			"short" => 15,
			"unsigned" => 41,
			"const" => 8,
			'p_name' => 17,
			'TILDE' => 157,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'decorate_method' => 162,
			'type_name' => 11,
			'class_name' => 1,
			'ctor' => 156,
			'basic_type' => 36,
			'nconsttype' => 27,
			'template' => 12,
			'static' => 150,
			'virtual' => 168,
			'perc_name' => 152,
			'function_decl' => 170,
			'method' => 192,
			'type' => 20,
			'dtor' => 159,
			'method_decl' => 160
		}
	},
	{#State 169
		ACTIONS => {
			'SEMICOLON' => 193
		}
	},
	{#State 170
		DEFAULT => -57
	},
	{#State 171
		DEFAULT => -50
	},
	{#State 172
		DEFAULT => -105
	},
	{#State 173
		ACTIONS => {
			'COMMA' => 194,
			'CLCURLY' => 195
		}
	},
	{#State 174
		ACTIONS => {
			'CLCURLY' => 196
		}
	},
	{#State 175
		ACTIONS => {
			'OPPAR' => 197
		},
		DEFAULT => -122
	},
	{#State 176
		DEFAULT => -118
	},
	{#State 177
		DEFAULT => -116
	},
	{#State 178
		DEFAULT => -121
	},
	{#State 179
		DEFAULT => -120
	},
	{#State 180
		ACTIONS => {
			'INTEGER' => 198
		}
	},
	{#State 181
		ACTIONS => {
			'p_code' => 204,
			'p_cleanup' => 200,
			'p_catch' => 123,
			'SEMICOLON' => 205,
			'p_postcall' => 202
		},
		GOTOS => {
			'perc_postcall' => 203,
			'perc_code' => 199,
			'perc_cleanup' => 206,
			'perc_catch' => 201,
			'_function_metadata' => 207
		}
	},
	{#State 182
		ACTIONS => {
			'OPCURLY' => 208
		}
	},
	{#State 183
		DEFAULT => -127
	},
	{#State 184
		ACTIONS => {
			'OPSPECIAL' => 28,
			'SEMICOLON' => 210
		},
		GOTOS => {
			'special_block' => 209,
			'special_block_start' => 30
		}
	},
	{#State 185
		DEFAULT => -34
	},
	{#State 186
		DEFAULT => -54
	},
	{#State 187
		DEFAULT => -33
	},
	{#State 188
		DEFAULT => -56
	},
	{#State 189
		ACTIONS => {
			'OPPAR' => 211
		}
	},
	{#State 190
		DEFAULT => -55
	},
	{#State 191
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"const" => 8,
			"unsigned" => 41,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		DEFAULT => -114,
		GOTOS => {
			'type_name' => 11,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 27,
			'template' => 12,
			'arg_list' => 212,
			'argument' => 113,
			'type' => 111
		}
	},
	{#State 192
		DEFAULT => -35
	},
	{#State 193
		DEFAULT => -36
	},
	{#State 194
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 213
		}
	},
	{#State 195
		DEFAULT => -83
	},
	{#State 196
		DEFAULT => -115
	},
	{#State 197
		ACTIONS => {
			'ID' => 23,
			'INTEGER' => 176,
			'QUOTED_STRING' => 178,
			'DASH' => 180,
			'FLOAT' => 179
		},
		DEFAULT => -126,
		GOTOS => {
			'class_name' => 175,
			'value_list' => 214,
			'value' => 215
		}
	},
	{#State 198
		DEFAULT => -119
	},
	{#State 199
		DEFAULT => -70
	},
	{#State 200
		ACTIONS => {
			'OPSPECIAL' => 28
		},
		GOTOS => {
			'special_block' => 216,
			'special_block_start' => 30
		}
	},
	{#State 201
		DEFAULT => -73
	},
	{#State 202
		ACTIONS => {
			'OPSPECIAL' => 28
		},
		GOTOS => {
			'special_block' => 217,
			'special_block_start' => 30
		}
	},
	{#State 203
		DEFAULT => -72
	},
	{#State 204
		ACTIONS => {
			'OPSPECIAL' => 28
		},
		GOTOS => {
			'special_block' => 218,
			'special_block_start' => 30
		}
	},
	{#State 205
		DEFAULT => -65
	},
	{#State 206
		DEFAULT => -71
	},
	{#State 207
		DEFAULT => -68
	},
	{#State 208
		ACTIONS => {
			'ID' => 219
		}
	},
	{#State 209
		DEFAULT => -128
	},
	{#State 210
		DEFAULT => -14
	},
	{#State 211
		ACTIONS => {
			'CLPAR' => 220
		}
	},
	{#State 212
		ACTIONS => {
			'CLPAR' => 221,
			'COMMA' => 135
		}
	},
	{#State 213
		DEFAULT => -106
	},
	{#State 214
		ACTIONS => {
			'CLPAR' => 222,
			'COMMA' => 223
		}
	},
	{#State 215
		DEFAULT => -124
	},
	{#State 216
		DEFAULT => -81
	},
	{#State 217
		DEFAULT => -82
	},
	{#State 218
		DEFAULT => -80
	},
	{#State 219
		ACTIONS => {
			'CLCURLY' => 224
		}
	},
	{#State 220
		DEFAULT => -69,
		GOTOS => {
			'function_metadata' => 225
		}
	},
	{#State 221
		DEFAULT => -69,
		GOTOS => {
			'function_metadata' => 226
		}
	},
	{#State 222
		DEFAULT => -123
	},
	{#State 223
		ACTIONS => {
			'ID' => 23,
			'INTEGER' => 176,
			'QUOTED_STRING' => 178,
			'DASH' => 180,
			'FLOAT' => 179
		},
		GOTOS => {
			'class_name' => 175,
			'value' => 227
		}
	},
	{#State 224
		ACTIONS => {
			'OPCURLY' => 229,
			'OPSPECIAL' => 28
		},
		DEFAULT => -20,
		GOTOS => {
			'simple_block' => 231,
			'mixed_blocks' => 228,
			'special_block' => 230,
			'special_block_start' => 30
		}
	},
	{#State 225
		ACTIONS => {
			'p_code' => 204,
			'p_cleanup' => 200,
			'p_catch' => 123,
			'SEMICOLON' => 232,
			'p_postcall' => 202
		},
		GOTOS => {
			'perc_postcall' => 203,
			'perc_code' => 199,
			'perc_cleanup' => 206,
			'perc_catch' => 201,
			'_function_metadata' => 207
		}
	},
	{#State 226
		ACTIONS => {
			'p_code' => 204,
			'p_cleanup' => 200,
			'p_catch' => 123,
			'SEMICOLON' => 233,
			'p_postcall' => 202
		},
		GOTOS => {
			'perc_postcall' => 203,
			'perc_code' => 199,
			'perc_cleanup' => 206,
			'perc_catch' => 201,
			'_function_metadata' => 207
		}
	},
	{#State 227
		DEFAULT => -125
	},
	{#State 228
		ACTIONS => {
			'OPCURLY' => 229,
			'OPSPECIAL' => 28,
			'SEMICOLON' => 235
		},
		GOTOS => {
			'simple_block' => 236,
			'special_block' => 234,
			'special_block_start' => 30
		}
	},
	{#State 229
		ACTIONS => {
			'ID' => 237
		}
	},
	{#State 230
		DEFAULT => -16
	},
	{#State 231
		DEFAULT => -17
	},
	{#State 232
		DEFAULT => -67
	},
	{#State 233
		DEFAULT => -66
	},
	{#State 234
		DEFAULT => -18
	},
	{#State 235
		DEFAULT => -15
	},
	{#State 236
		DEFAULT => -19
	},
	{#State 237
		ACTIONS => {
			'CLCURLY' => 238
		}
	},
	{#State 238
		DEFAULT => -21
	}
],
                                  yyrules  =>
[
	[#Rule 0
		 '$start', 2, undef
	],
	[#Rule 1
		 'top_list', 1,
sub
#line 21 "XSP.yp"
{ $_[1] ? [ $_[1] ] : [] }
	],
	[#Rule 2
		 'top_list', 2,
sub
#line 22 "XSP.yp"
{ push @{$_[1]}, $_[2] if $_[2]; $_[1] }
	],
	[#Rule 3
		 'top', 1, undef
	],
	[#Rule 4
		 'top', 1, undef
	],
	[#Rule 5
		 'top', 1, undef
	],
	[#Rule 6
		 'top', 1,
sub
#line 26 "XSP.yp"
{ $_[1]->resolve_typemaps; $_[1]->resolve_exceptions; $_[1] }
	],
	[#Rule 7
		 'directive', 2,
sub
#line 29 "XSP.yp"
{ ExtUtils::XSpp::Node::Module->new( module => $_[1] ) }
	],
	[#Rule 8
		 'directive', 2,
sub
#line 31 "XSP.yp"
{ ExtUtils::XSpp::Node::Package->new( perl_name => $_[1] ) }
	],
	[#Rule 9
		 'directive', 2,
sub
#line 33 "XSP.yp"
{ ExtUtils::XSpp::Node::File->new( file => $_[1] ) }
	],
	[#Rule 10
		 'directive', 2,
sub
#line 35 "XSP.yp"
{ $_[0]->YYData->{PARSER}->load_plugin( $_[1] ); undef }
	],
	[#Rule 11
		 'directive', 2,
sub
#line 37 "XSP.yp"
{ $_[0]->YYData->{PARSER}->include_file( $_[1] ); undef }
	],
	[#Rule 12
		 'directive', 1,
sub
#line 38 "XSP.yp"
{ }
	],
	[#Rule 13
		 'directive', 1,
sub
#line 39 "XSP.yp"
{ }
	],
	[#Rule 14
		 'typemap', 9,
sub
#line 43 "XSP.yp"
{ my $package = "ExtUtils::XSpp::Typemap::" . $_[6];
                      my $type = $_[3]; my $c = 0;
                      my %args = map { "arg" . ++$c => $_ }
                                 map { join( '', @$_ ) }
                                     @{$_[8] || []};
                      my $tm = $package->new( type => $type, %args );
                      ExtUtils::XSpp::Typemap::add_typemap_for_type( $type, $tm );
                      undef }
	],
	[#Rule 15
		 'exceptionmap', 12,
sub
#line 55 "XSP.yp"
{ my $package = "ExtUtils::XSpp::Exception::" . $_[9];
                      my $type = make_type($_[6]); my $c = 0;
                      my %args = map { "arg" . ++$c => $_ }
                                 map { join( "\n", @$_ ) }
                                     @{$_[11] || []};
                      my $e = $package->new( name => $_[3], type => $type, %args );
                      ExtUtils::XSpp::Exception->add_exception( $e );
                      undef }
	],
	[#Rule 16
		 'mixed_blocks', 1,
sub
#line 65 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 17
		 'mixed_blocks', 1,
sub
#line 67 "XSP.yp"
{ [ [$_[1]] ] }
	],
	[#Rule 18
		 'mixed_blocks', 2,
sub
#line 69 "XSP.yp"
{ [ @{$_[1]}, $_[2] ] }
	],
	[#Rule 19
		 'mixed_blocks', 2,
sub
#line 71 "XSP.yp"
{ [ @{$_[1]}, $_[2] ] }
	],
	[#Rule 20
		 'mixed_blocks', 0, undef
	],
	[#Rule 21
		 'simple_block', 3,
sub
#line 75 "XSP.yp"
{ $_[2] }
	],
	[#Rule 22
		 'raw', 1,
sub
#line 77 "XSP.yp"
{ add_data_raw( $_[0], [ $_[1] ] ) }
	],
	[#Rule 23
		 'raw', 1,
sub
#line 78 "XSP.yp"
{ add_data_comment( $_[0], $_[1] ) }
	],
	[#Rule 24
		 'raw', 1,
sub
#line 79 "XSP.yp"
{ add_data_raw( $_[0], [ @{$_[1]} ] ) }
	],
	[#Rule 25
		 'class', 1, undef
	],
	[#Rule 26
		 'class', 1, undef
	],
	[#Rule 27
		 'function', 1, undef
	],
	[#Rule 28
		 'function', 1, undef
	],
	[#Rule 29
		 'method', 1, undef
	],
	[#Rule 30
		 'method', 1, undef
	],
	[#Rule 31
		 'decorate_class', 2,
sub
#line 85 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 32
		 'decorate_function', 2,
sub
#line 86 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 33
		 'decorate_method', 2,
sub
#line 87 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 34
		 'decorate_method', 2,
sub
#line 88 "XSP.yp"
{ $_[2]->set_static( $_[1] ); $_[2] }
	],
	[#Rule 35
		 'decorate_method', 2,
sub
#line 89 "XSP.yp"
{ $_[2]->set_virtual( 1 ); $_[2] }
	],
	[#Rule 36
		 'class_decl', 8,
sub
#line 92 "XSP.yp"
{ create_class( $_[0], $_[2], $_[3], $_[4], $_[6] ) }
	],
	[#Rule 37
		 'base_classes', 2,
sub
#line 95 "XSP.yp"
{ [ $_[2] ] }
	],
	[#Rule 38
		 'base_classes', 3,
sub
#line 96 "XSP.yp"
{ push @{$_[1]}, $_[3] if $_[3]; $_[1] }
	],
	[#Rule 39
		 'base_classes', 0, undef
	],
	[#Rule 40
		 'base_class', 2,
sub
#line 100 "XSP.yp"
{ $_[2] }
	],
	[#Rule 41
		 'base_class', 2,
sub
#line 101 "XSP.yp"
{ $_[2] }
	],
	[#Rule 42
		 'base_class', 2,
sub
#line 102 "XSP.yp"
{ $_[2] }
	],
	[#Rule 43
		 'class_name_rename', 1,
sub
#line 106 "XSP.yp"
{ create_class( $_[0], $_[1], [], [] ) }
	],
	[#Rule 44
		 'class_name_rename', 2,
sub
#line 107 "XSP.yp"
{ my $klass = create_class( $_[0], $_[2], [], [] );
                             $klass->set_perl_name( $_[1] );
                             $klass
                             }
	],
	[#Rule 45
		 'class_metadata', 2,
sub
#line 113 "XSP.yp"
{ [ @{$_[1]}, @{$_[2]} ] }
	],
	[#Rule 46
		 'class_metadata', 0,
sub
#line 114 "XSP.yp"
{ [] }
	],
	[#Rule 47
		 'class_body_list', 0,
sub
#line 118 "XSP.yp"
{ [] }
	],
	[#Rule 48
		 'class_body_list', 2,
sub
#line 120 "XSP.yp"
{ push @{$_[1]}, $_[2] if $_[2]; $_[1] }
	],
	[#Rule 49
		 'class_body_element', 1, undef
	],
	[#Rule 50
		 'class_body_element', 1, undef
	],
	[#Rule 51
		 'class_body_element', 1, undef
	],
	[#Rule 52
		 'class_body_element', 1, undef
	],
	[#Rule 53
		 'class_body_element', 1, undef
	],
	[#Rule 54
		 'access_specifier', 2,
sub
#line 126 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 55
		 'access_specifier', 2,
sub
#line 127 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 56
		 'access_specifier', 2,
sub
#line 128 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 57
		 'method_decl', 1,
sub
#line 132 "XSP.yp"
{ my $f = $_[1];
                           my $m = add_data_method
                             ( $_[0],
                               name      => $f->cpp_name,
                               ret_type  => $f->ret_type,
                               arguments => $f->arguments,
                               code      => $f->code,
                               cleanup   => $f->cleanup,
                               postcall  => $f->postcall,
                               catch     => $f->catch,
                               );
                           $m
                         }
	],
	[#Rule 58
		 'method_decl', 1, undef
	],
	[#Rule 59
		 'method_decl', 1, undef
	],
	[#Rule 60
		 'const', 1, undef
	],
	[#Rule 61
		 'const', 0, undef
	],
	[#Rule 62
		 'virtual', 1, undef
	],
	[#Rule 63
		 'static', 1, undef
	],
	[#Rule 64
		 'static', 1, undef
	],
	[#Rule 65
		 'function_decl', 8,
sub
#line 158 "XSP.yp"
{ add_data_function( $_[0],
                                         name      => $_[2],
                                         ret_type  => $_[1],
                                         arguments => $_[4],
                                         @{ $_[7] } ) }
	],
	[#Rule 66
		 'ctor', 6,
sub
#line 165 "XSP.yp"
{ add_data_ctor( $_[0], name      => $_[1],
                                            arguments => $_[3],
                                            @{ $_[5] } ) }
	],
	[#Rule 67
		 'dtor', 6,
sub
#line 170 "XSP.yp"
{ add_data_dtor( $_[0], name  => $_[2],
                                            @{ $_[5] },
                                      ) }
	],
	[#Rule 68
		 'function_metadata', 2,
sub
#line 174 "XSP.yp"
{ [ @{$_[1]}, @{$_[2]} ] }
	],
	[#Rule 69
		 'function_metadata', 0,
sub
#line 175 "XSP.yp"
{ [] }
	],
	[#Rule 70
		 '_function_metadata', 1, undef
	],
	[#Rule 71
		 '_function_metadata', 1, undef
	],
	[#Rule 72
		 '_function_metadata', 1, undef
	],
	[#Rule 73
		 '_function_metadata', 1, undef
	],
	[#Rule 74
		 'perc_name', 4,
sub
#line 185 "XSP.yp"
{ $_[3] }
	],
	[#Rule 75
		 'perc_package', 4,
sub
#line 186 "XSP.yp"
{ $_[3] }
	],
	[#Rule 76
		 'perc_module', 4,
sub
#line 187 "XSP.yp"
{ $_[3] }
	],
	[#Rule 77
		 'perc_file', 4,
sub
#line 188 "XSP.yp"
{ $_[3] }
	],
	[#Rule 78
		 'perc_loadplugin', 4,
sub
#line 189 "XSP.yp"
{ $_[3] }
	],
	[#Rule 79
		 'perc_include', 4,
sub
#line 190 "XSP.yp"
{ $_[3] }
	],
	[#Rule 80
		 'perc_code', 2,
sub
#line 191 "XSP.yp"
{ [ code => $_[2] ] }
	],
	[#Rule 81
		 'perc_cleanup', 2,
sub
#line 192 "XSP.yp"
{ [ cleanup => $_[2] ] }
	],
	[#Rule 82
		 'perc_postcall', 2,
sub
#line 193 "XSP.yp"
{ [ postcall => $_[2] ] }
	],
	[#Rule 83
		 'perc_catch', 4,
sub
#line 194 "XSP.yp"
{ [ map {(catch => $_)} @{$_[3]} ] }
	],
	[#Rule 84
		 'type', 2,
sub
#line 197 "XSP.yp"
{ make_const( $_[2] ) }
	],
	[#Rule 85
		 'type', 1, undef
	],
	[#Rule 86
		 'nconsttype', 2,
sub
#line 202 "XSP.yp"
{ make_ptr( $_[1] ) }
	],
	[#Rule 87
		 'nconsttype', 2,
sub
#line 203 "XSP.yp"
{ make_ref( $_[1] ) }
	],
	[#Rule 88
		 'nconsttype', 1,
sub
#line 204 "XSP.yp"
{ make_type( $_[1] ) }
	],
	[#Rule 89
		 'nconsttype', 1, undef
	],
	[#Rule 90
		 'type_name', 1, undef
	],
	[#Rule 91
		 'type_name', 1, undef
	],
	[#Rule 92
		 'type_name', 1,
sub
#line 211 "XSP.yp"
{ 'unsigned int' }
	],
	[#Rule 93
		 'type_name', 2,
sub
#line 212 "XSP.yp"
{ 'unsigned' . ' ' . $_[2] }
	],
	[#Rule 94
		 'basic_type', 1, undef
	],
	[#Rule 95
		 'basic_type', 1, undef
	],
	[#Rule 96
		 'basic_type', 1, undef
	],
	[#Rule 97
		 'basic_type', 1, undef
	],
	[#Rule 98
		 'basic_type', 2, undef
	],
	[#Rule 99
		 'basic_type', 2, undef
	],
	[#Rule 100
		 'template', 4,
sub
#line 218 "XSP.yp"
{ make_template( $_[1], $_[3] ) }
	],
	[#Rule 101
		 'type_list', 1,
sub
#line 222 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 102
		 'type_list', 3,
sub
#line 223 "XSP.yp"
{ push @{$_[1]}, $_[3]; $_[1] }
	],
	[#Rule 103
		 'class_name', 1, undef
	],
	[#Rule 104
		 'class_name', 2,
sub
#line 227 "XSP.yp"
{ $_[1] . '::' . $_[2] }
	],
	[#Rule 105
		 'class_name_list', 1,
sub
#line 230 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 106
		 'class_name_list', 3,
sub
#line 231 "XSP.yp"
{ push @{$_[1]}, $_[3]; $_[1] }
	],
	[#Rule 107
		 'class_suffix', 2,
sub
#line 234 "XSP.yp"
{ $_[2] }
	],
	[#Rule 108
		 'class_suffix', 3,
sub
#line 235 "XSP.yp"
{ $_[1] . '::' . $_[3] }
	],
	[#Rule 109
		 'file_name', 1,
sub
#line 237 "XSP.yp"
{ '-' }
	],
	[#Rule 110
		 'file_name', 3,
sub
#line 238 "XSP.yp"
{ $_[1] . '.' . $_[3] }
	],
	[#Rule 111
		 'file_name', 3,
sub
#line 239 "XSP.yp"
{ $_[1] . '/' . $_[3] }
	],
	[#Rule 112
		 'arg_list', 1,
sub
#line 241 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 113
		 'arg_list', 3,
sub
#line 242 "XSP.yp"
{ push @{$_[1]}, $_[3]; $_[1] }
	],
	[#Rule 114
		 'arg_list', 0, undef
	],
	[#Rule 115
		 'argument', 5,
sub
#line 246 "XSP.yp"
{ make_argument( @_[0, 1], "length($_[4])" ) }
	],
	[#Rule 116
		 'argument', 4,
sub
#line 248 "XSP.yp"
{ make_argument( @_[0, 1, 2, 4] ) }
	],
	[#Rule 117
		 'argument', 2,
sub
#line 249 "XSP.yp"
{ make_argument( @_ ) }
	],
	[#Rule 118
		 'value', 1, undef
	],
	[#Rule 119
		 'value', 2,
sub
#line 252 "XSP.yp"
{ '-' . $_[2] }
	],
	[#Rule 120
		 'value', 1, undef
	],
	[#Rule 121
		 'value', 1, undef
	],
	[#Rule 122
		 'value', 1, undef
	],
	[#Rule 123
		 'value', 4,
sub
#line 256 "XSP.yp"
{ "$_[1]($_[3])" }
	],
	[#Rule 124
		 'value_list', 1, undef
	],
	[#Rule 125
		 'value_list', 3,
sub
#line 261 "XSP.yp"
{ "$_[1], $_[2]" }
	],
	[#Rule 126
		 'value_list', 0,
sub
#line 262 "XSP.yp"
{ "" }
	],
	[#Rule 127
		 'special_blocks', 1,
sub
#line 266 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 128
		 'special_blocks', 2,
sub
#line 268 "XSP.yp"
{ [ @{$_[1]}, $_[2] ] }
	],
	[#Rule 129
		 'special_blocks', 0, undef
	],
	[#Rule 130
		 'special_block', 3,
sub
#line 272 "XSP.yp"
{ $_[2] }
	],
	[#Rule 131
		 'special_block', 2,
sub
#line 274 "XSP.yp"
{ [] }
	],
	[#Rule 132
		 'special_block_start', 1,
sub
#line 277 "XSP.yp"
{ push_lex_mode( $_[0], 'special' ) }
	],
	[#Rule 133
		 'special_block_end', 1,
sub
#line 279 "XSP.yp"
{ pop_lex_mode( $_[0], 'special' ) }
	],
	[#Rule 134
		 'lines', 1,
sub
#line 281 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 135
		 'lines', 2,
sub
#line 282 "XSP.yp"
{ push @{$_[1]}, $_[2]; $_[1] }
	]
],
                                  @_);
    bless($self,$class);
}

#line 284 "XSP.yp"


use ExtUtils::XSpp::Lexer;

1;
