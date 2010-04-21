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
			'COMMENT' => 5,
			'p_exceptionmap' => 31,
			"class" => 7,
			'RAW_CODE' => 32,
			"const" => 9,
			"int" => 34,
			'p_module' => 14,
			'p_loadplugin' => 39,
			'p_package' => 38,
			"short" => 15,
			'p_file' => 41,
			"unsigned" => 42,
			'p_name' => 17,
			'p_include' => 18,
			"long" => 19,
			"char" => 22
		},
		GOTOS => {
			'perc_loadplugin' => 24,
			'class_name' => 1,
			'top_list' => 2,
			'perc_package' => 27,
			'function' => 26,
			'nconsttype' => 25,
			'looks_like_function' => 4,
			'exceptionmap' => 29,
			'special_block_start' => 30,
			'perc_name' => 6,
			'class_decl' => 33,
			'typemap' => 8,
			'decorate_class' => 10,
			'special_block' => 11,
			'perc_module' => 35,
			'type_name' => 12,
			'perc_file' => 37,
			'basic_type' => 36,
			'template' => 13,
			'looks_like_renamed_function' => 40,
			'top' => 16,
			'function_decl' => 43,
			'perc_include' => 44,
			'directive' => 45,
			'type' => 20,
			'class' => 21,
			'raw' => 46
		}
	},
	{#State 1
		ACTIONS => {
			'OPANG' => 47
		},
		DEFAULT => -97
	},
	{#State 2
		ACTIONS => {
			'ID' => 23,
			'' => 48,
			'p_typemap' => 3,
			'OPSPECIAL' => 28,
			'COMMENT' => 5,
			'p_exceptionmap' => 31,
			"class" => 7,
			'RAW_CODE' => 32,
			"const" => 9,
			"int" => 34,
			'p_module' => 14,
			'p_package' => 38,
			'p_loadplugin' => 39,
			"short" => 15,
			'p_file' => 41,
			"unsigned" => 42,
			'p_name' => 17,
			'p_include' => 18,
			"long" => 19,
			"char" => 22
		},
		GOTOS => {
			'perc_loadplugin' => 24,
			'class_name' => 1,
			'function' => 26,
			'perc_package' => 27,
			'nconsttype' => 25,
			'looks_like_function' => 4,
			'exceptionmap' => 29,
			'special_block_start' => 30,
			'perc_name' => 6,
			'class_decl' => 33,
			'typemap' => 8,
			'decorate_class' => 10,
			'special_block' => 11,
			'perc_module' => 35,
			'type_name' => 12,
			'perc_file' => 37,
			'basic_type' => 36,
			'template' => 13,
			'looks_like_renamed_function' => 40,
			'top' => 49,
			'function_decl' => 43,
			'perc_include' => 44,
			'directive' => 45,
			'type' => 20,
			'class' => 21,
			'raw' => 46
		}
	},
	{#State 3
		ACTIONS => {
			'OPCURLY' => 50
		}
	},
	{#State 4
		DEFAULT => -62
	},
	{#State 5
		DEFAULT => -23
	},
	{#State 6
		ACTIONS => {
			'ID' => 23,
			"class" => 7,
			"short" => 15,
			"const" => 9,
			"unsigned" => 42,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 25,
			'template' => 13,
			'looks_like_function' => 51,
			'class_decl' => 52,
			'type' => 20
		}
	},
	{#State 7
		ACTIONS => {
			'ID' => 53
		}
	},
	{#State 8
		DEFAULT => -12
	},
	{#State 9
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 42,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 54,
			'template' => 13
		}
	},
	{#State 10
		ACTIONS => {
			'SEMICOLON' => 55
		}
	},
	{#State 11
		DEFAULT => -24
	},
	{#State 12
		DEFAULT => -95
	},
	{#State 13
		DEFAULT => -96
	},
	{#State 14
		ACTIONS => {
			'OPCURLY' => 56
		}
	},
	{#State 15
		ACTIONS => {
			"int" => 57
		},
		DEFAULT => -104
	},
	{#State 16
		DEFAULT => -1
	},
	{#State 17
		ACTIONS => {
			'OPCURLY' => 58
		}
	},
	{#State 18
		ACTIONS => {
			'OPCURLY' => 59
		}
	},
	{#State 19
		ACTIONS => {
			"int" => 60
		},
		DEFAULT => -103
	},
	{#State 20
		ACTIONS => {
			'ID' => 61
		}
	},
	{#State 21
		DEFAULT => -4
	},
	{#State 22
		DEFAULT => -101
	},
	{#State 23
		ACTIONS => {
			'DCOLON' => 63
		},
		DEFAULT => -110,
		GOTOS => {
			'class_suffix' => 62
		}
	},
	{#State 24
		ACTIONS => {
			'SEMICOLON' => 64
		}
	},
	{#State 25
		ACTIONS => {
			'STAR' => 66,
			'AMP' => 65
		},
		DEFAULT => -92
	},
	{#State 26
		DEFAULT => -6
	},
	{#State 27
		ACTIONS => {
			'SEMICOLON' => 67
		}
	},
	{#State 28
		DEFAULT => -139
	},
	{#State 29
		DEFAULT => -13
	},
	{#State 30
		ACTIONS => {
			'CLSPECIAL' => 68,
			'line' => 69
		},
		GOTOS => {
			'special_block_end' => 70,
			'lines' => 71
		}
	},
	{#State 31
		ACTIONS => {
			'OPCURLY' => 72
		}
	},
	{#State 32
		DEFAULT => -22
	},
	{#State 33
		ACTIONS => {
			'SEMICOLON' => 73
		}
	},
	{#State 34
		DEFAULT => -102
	},
	{#State 35
		ACTIONS => {
			'SEMICOLON' => 74
		}
	},
	{#State 36
		DEFAULT => -98
	},
	{#State 37
		ACTIONS => {
			'SEMICOLON' => 75
		}
	},
	{#State 38
		ACTIONS => {
			'OPCURLY' => 76
		}
	},
	{#State 39
		ACTIONS => {
			'OPCURLY' => 77
		}
	},
	{#State 40
		DEFAULT => -70,
		GOTOS => {
			'function_metadata' => 78
		}
	},
	{#State 41
		ACTIONS => {
			'OPCURLY' => 79
		}
	},
	{#State 42
		ACTIONS => {
			"short" => 15,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		DEFAULT => -99,
		GOTOS => {
			'basic_type' => 80
		}
	},
	{#State 43
		ACTIONS => {
			'SEMICOLON' => 81
		}
	},
	{#State 44
		ACTIONS => {
			'SEMICOLON' => 82
		}
	},
	{#State 45
		DEFAULT => -5
	},
	{#State 46
		DEFAULT => -3
	},
	{#State 47
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 42,
			"const" => 9,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_list' => 84,
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 25,
			'template' => 13,
			'type' => 83
		}
	},
	{#State 48
		DEFAULT => 0
	},
	{#State 49
		DEFAULT => -2
	},
	{#State 50
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 42,
			"const" => 9,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 25,
			'template' => 13,
			'type' => 85
		}
	},
	{#State 51
		DEFAULT => -63
	},
	{#State 52
		DEFAULT => -29
	},
	{#State 53
		ACTIONS => {
			'COLON' => 87
		},
		DEFAULT => -33,
		GOTOS => {
			'base_classes' => 86
		}
	},
	{#State 54
		ACTIONS => {
			'STAR' => 66,
			'AMP' => 65
		},
		DEFAULT => -91
	},
	{#State 55
		DEFAULT => -26
	},
	{#State 56
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 88
		}
	},
	{#State 57
		DEFAULT => -106
	},
	{#State 58
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 89
		}
	},
	{#State 59
		ACTIONS => {
			'ID' => 91,
			'DASH' => 92
		},
		GOTOS => {
			'file_name' => 90
		}
	},
	{#State 60
		DEFAULT => -105
	},
	{#State 61
		ACTIONS => {
			'OPPAR' => 93
		}
	},
	{#State 62
		ACTIONS => {
			'DCOLON' => 94
		},
		DEFAULT => -111
	},
	{#State 63
		ACTIONS => {
			'ID' => 95
		}
	},
	{#State 64
		DEFAULT => -10
	},
	{#State 65
		DEFAULT => -94
	},
	{#State 66
		DEFAULT => -93
	},
	{#State 67
		DEFAULT => -8
	},
	{#State 68
		DEFAULT => -140
	},
	{#State 69
		DEFAULT => -141
	},
	{#State 70
		DEFAULT => -138
	},
	{#State 71
		ACTIONS => {
			'CLSPECIAL' => 68,
			'line' => 96
		},
		GOTOS => {
			'special_block_end' => 97
		}
	},
	{#State 72
		ACTIONS => {
			'ID' => 98
		}
	},
	{#State 73
		DEFAULT => -25
	},
	{#State 74
		DEFAULT => -7
	},
	{#State 75
		DEFAULT => -9
	},
	{#State 76
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 99
		}
	},
	{#State 77
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 100
		}
	},
	{#State 78
		ACTIONS => {
			'p_code' => 106,
			'p_cleanup' => 102,
			'p_catch' => 109,
			'p_postcall' => 104
		},
		DEFAULT => -64,
		GOTOS => {
			'perc_postcall' => 105,
			'perc_code' => 101,
			'perc_cleanup' => 107,
			'perc_catch' => 103,
			'_function_metadata' => 108
		}
	},
	{#State 79
		ACTIONS => {
			'ID' => 91,
			'DASH' => 92
		},
		GOTOS => {
			'file_name' => 110
		}
	},
	{#State 80
		DEFAULT => -100
	},
	{#State 81
		DEFAULT => -27
	},
	{#State 82
		DEFAULT => -11
	},
	{#State 83
		DEFAULT => -108
	},
	{#State 84
		ACTIONS => {
			'CLANG' => 111,
			'COMMA' => 112
		}
	},
	{#State 85
		ACTIONS => {
			'CLCURLY' => 113
		}
	},
	{#State 86
		ACTIONS => {
			'COMMA' => 115
		},
		DEFAULT => -40,
		GOTOS => {
			'class_metadata' => 114
		}
	},
	{#State 87
		ACTIONS => {
			"protected" => 119,
			"private" => 118,
			"public" => 116
		},
		GOTOS => {
			'base_class' => 117
		}
	},
	{#State 88
		ACTIONS => {
			'CLCURLY' => 120
		}
	},
	{#State 89
		ACTIONS => {
			'CLCURLY' => 121
		}
	},
	{#State 90
		ACTIONS => {
			'CLCURLY' => 122
		}
	},
	{#State 91
		ACTIONS => {
			'DOT' => 124,
			'SLASH' => 123
		}
	},
	{#State 92
		DEFAULT => -116
	},
	{#State 93
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"const" => 9,
			"unsigned" => 42,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		DEFAULT => -121,
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 25,
			'template' => 13,
			'arg_list' => 126,
			'argument' => 127,
			'type' => 125
		}
	},
	{#State 94
		ACTIONS => {
			'ID' => 128
		}
	},
	{#State 95
		DEFAULT => -114
	},
	{#State 96
		DEFAULT => -142
	},
	{#State 97
		DEFAULT => -137
	},
	{#State 98
		ACTIONS => {
			'CLCURLY' => 129
		}
	},
	{#State 99
		ACTIONS => {
			'CLCURLY' => 130
		}
	},
	{#State 100
		ACTIONS => {
			'CLCURLY' => 131
		}
	},
	{#State 101
		DEFAULT => -77
	},
	{#State 102
		ACTIONS => {
			'OPSPECIAL' => 28
		},
		GOTOS => {
			'special_block' => 132,
			'special_block_start' => 30
		}
	},
	{#State 103
		DEFAULT => -80
	},
	{#State 104
		ACTIONS => {
			'OPSPECIAL' => 28
		},
		GOTOS => {
			'special_block' => 133,
			'special_block_start' => 30
		}
	},
	{#State 105
		DEFAULT => -79
	},
	{#State 106
		ACTIONS => {
			'OPSPECIAL' => 28
		},
		GOTOS => {
			'special_block' => 134,
			'special_block_start' => 30
		}
	},
	{#State 107
		DEFAULT => -78
	},
	{#State 108
		DEFAULT => -69
	},
	{#State 109
		ACTIONS => {
			'OPCURLY' => 135
		}
	},
	{#State 110
		ACTIONS => {
			'CLCURLY' => 136
		}
	},
	{#State 111
		DEFAULT => -107
	},
	{#State 112
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 42,
			"const" => 9,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 25,
			'template' => 13,
			'type' => 137
		}
	},
	{#State 113
		ACTIONS => {
			'OPCURLY' => 138
		}
	},
	{#State 114
		ACTIONS => {
			'OPCURLY' => 139,
			'p_catch' => 109
		},
		GOTOS => {
			'perc_catch' => 140
		}
	},
	{#State 115
		ACTIONS => {
			"protected" => 119,
			"private" => 118,
			"public" => 116
		},
		GOTOS => {
			'base_class' => 141
		}
	},
	{#State 116
		ACTIONS => {
			'ID' => 23,
			'p_name' => 17
		},
		GOTOS => {
			'perc_name' => 143,
			'class_name' => 142,
			'class_name_rename' => 144
		}
	},
	{#State 117
		DEFAULT => -31
	},
	{#State 118
		ACTIONS => {
			'ID' => 23,
			'p_name' => 17
		},
		GOTOS => {
			'perc_name' => 143,
			'class_name' => 142,
			'class_name_rename' => 145
		}
	},
	{#State 119
		ACTIONS => {
			'ID' => 23,
			'p_name' => 17
		},
		GOTOS => {
			'perc_name' => 143,
			'class_name' => 142,
			'class_name_rename' => 146
		}
	},
	{#State 120
		DEFAULT => -83
	},
	{#State 121
		DEFAULT => -81
	},
	{#State 122
		DEFAULT => -86
	},
	{#State 123
		ACTIONS => {
			'ID' => 91,
			'DASH' => 92
		},
		GOTOS => {
			'file_name' => 147
		}
	},
	{#State 124
		ACTIONS => {
			'ID' => 148
		}
	},
	{#State 125
		ACTIONS => {
			'ID' => 150,
			'p_length' => 149
		}
	},
	{#State 126
		ACTIONS => {
			'CLPAR' => 151,
			'COMMA' => 152
		}
	},
	{#State 127
		DEFAULT => -119
	},
	{#State 128
		DEFAULT => -115
	},
	{#State 129
		ACTIONS => {
			'OPCURLY' => 153
		}
	},
	{#State 130
		DEFAULT => -82
	},
	{#State 131
		DEFAULT => -85
	},
	{#State 132
		DEFAULT => -88
	},
	{#State 133
		DEFAULT => -89
	},
	{#State 134
		DEFAULT => -87
	},
	{#State 135
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 154,
			'class_name_list' => 155
		}
	},
	{#State 136
		DEFAULT => -84
	},
	{#State 137
		DEFAULT => -109
	},
	{#State 138
		ACTIONS => {
			'ID' => 156
		}
	},
	{#State 139
		DEFAULT => -41,
		GOTOS => {
			'class_body_list' => 157
		}
	},
	{#State 140
		DEFAULT => -39
	},
	{#State 141
		DEFAULT => -32
	},
	{#State 142
		DEFAULT => -37
	},
	{#State 143
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 158
		}
	},
	{#State 144
		DEFAULT => -34
	},
	{#State 145
		DEFAULT => -36
	},
	{#State 146
		DEFAULT => -35
	},
	{#State 147
		DEFAULT => -118
	},
	{#State 148
		DEFAULT => -117
	},
	{#State 149
		ACTIONS => {
			'OPCURLY' => 159
		}
	},
	{#State 150
		ACTIONS => {
			'EQUAL' => 160
		},
		DEFAULT => -124
	},
	{#State 151
		ACTIONS => {
			"const" => 161
		},
		DEFAULT => -56,
		GOTOS => {
			'const' => 162
		}
	},
	{#State 152
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 42,
			"const" => 9,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'argument' => 163,
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 25,
			'template' => 13,
			'type' => 125
		}
	},
	{#State 153
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 42,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 165,
			'class_name' => 164,
			'basic_type' => 36
		}
	},
	{#State 154
		DEFAULT => -112
	},
	{#State 155
		ACTIONS => {
			'COMMA' => 166,
			'CLCURLY' => 167
		}
	},
	{#State 156
		ACTIONS => {
			'CLCURLY' => 168
		}
	},
	{#State 157
		ACTIONS => {
			'ID' => 183,
			'p_typemap' => 3,
			'OPSPECIAL' => 28,
			"virtual" => 184,
			'COMMENT' => 5,
			"class_static" => 170,
			"package_static" => 185,
			"public" => 171,
			'p_exceptionmap' => 31,
			'RAW_CODE' => 32,
			"const" => 9,
			"static" => 189,
			"int" => 34,
			"private" => 176,
			'CLCURLY' => 191,
			"short" => 15,
			"unsigned" => 42,
			'p_name' => 17,
			'TILDE' => 179,
			"protected" => 180,
			"long" => 19,
			"char" => 22
		},
		GOTOS => {
			'class_name' => 1,
			'nconsttype' => 25,
			'looks_like_function' => 4,
			'static' => 169,
			'exceptionmap' => 186,
			'special_block_start' => 30,
			'perc_name' => 172,
			'typemap' => 173,
			'class_body_element' => 187,
			'method' => 188,
			'vmethod' => 174,
			'nmethod' => 175,
			'special_block' => 11,
			'access_specifier' => 177,
			'type_name' => 12,
			'ctor' => 178,
			'basic_type' => 36,
			'template' => 13,
			'virtual' => 190,
			'looks_like_renamed_function' => 192,
			'_vmethod' => 193,
			'type' => 20,
			'dtor' => 181,
			'raw' => 194,
			'method_decl' => 182
		}
	},
	{#State 158
		DEFAULT => -38
	},
	{#State 159
		ACTIONS => {
			'ID' => 195
		}
	},
	{#State 160
		ACTIONS => {
			'ID' => 23,
			'INTEGER' => 197,
			'QUOTED_STRING' => 199,
			'DASH' => 201,
			'FLOAT' => 200
		},
		GOTOS => {
			'class_name' => 196,
			'value' => 198
		}
	},
	{#State 161
		DEFAULT => -55
	},
	{#State 162
		DEFAULT => -61
	},
	{#State 163
		DEFAULT => -120
	},
	{#State 164
		DEFAULT => -97
	},
	{#State 165
		ACTIONS => {
			'CLCURLY' => 202
		}
	},
	{#State 166
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 203
		}
	},
	{#State 167
		DEFAULT => -90
	},
	{#State 168
		ACTIONS => {
			'OPSPECIAL' => 28
		},
		DEFAULT => -136,
		GOTOS => {
			'special_blocks' => 205,
			'special_block' => 204,
			'special_block_start' => 30
		}
	},
	{#State 169
		ACTIONS => {
			'ID' => 23,
			"class_static" => 170,
			"package_static" => 185,
			"short" => 15,
			"unsigned" => 42,
			"const" => 9,
			'p_name' => 17,
			"long" => 19,
			"static" => 189,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 25,
			'template' => 13,
			'looks_like_function' => 4,
			'static' => 169,
			'perc_name' => 206,
			'looks_like_renamed_function' => 192,
			'nmethod' => 207,
			'type' => 20
		}
	},
	{#State 170
		DEFAULT => -59
	},
	{#State 171
		ACTIONS => {
			'COLON' => 208
		}
	},
	{#State 172
		ACTIONS => {
			'ID' => 183,
			"virtual" => 184,
			"short" => 15,
			"unsigned" => 42,
			"const" => 9,
			'p_name' => 17,
			'TILDE' => 179,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'ctor' => 211,
			'basic_type' => 36,
			'nconsttype' => 25,
			'template' => 13,
			'looks_like_function' => 51,
			'virtual' => 190,
			'perc_name' => 209,
			'_vmethod' => 193,
			'dtor' => 212,
			'vmethod' => 210,
			'type' => 20
		}
	},
	{#State 173
		DEFAULT => -45
	},
	{#State 174
		DEFAULT => -52
	},
	{#State 175
		DEFAULT => -51
	},
	{#State 176
		ACTIONS => {
			'COLON' => 213
		}
	},
	{#State 177
		DEFAULT => -47
	},
	{#State 178
		DEFAULT => -53
	},
	{#State 179
		ACTIONS => {
			'ID' => 214
		}
	},
	{#State 180
		ACTIONS => {
			'COLON' => 215
		}
	},
	{#State 181
		DEFAULT => -54
	},
	{#State 182
		ACTIONS => {
			'SEMICOLON' => 216
		}
	},
	{#State 183
		ACTIONS => {
			'DCOLON' => 63,
			'OPPAR' => 217
		},
		DEFAULT => -110,
		GOTOS => {
			'class_suffix' => 62
		}
	},
	{#State 184
		DEFAULT => -57
	},
	{#State 185
		DEFAULT => -58
	},
	{#State 186
		DEFAULT => -46
	},
	{#State 187
		DEFAULT => -42
	},
	{#State 188
		DEFAULT => -43
	},
	{#State 189
		DEFAULT => -60
	},
	{#State 190
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 42,
			"const" => 9,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 25,
			'template' => 13,
			'looks_like_function' => 218,
			'type' => 20
		}
	},
	{#State 191
		DEFAULT => -30
	},
	{#State 192
		DEFAULT => -70,
		GOTOS => {
			'function_metadata' => 219
		}
	},
	{#State 193
		DEFAULT => -73
	},
	{#State 194
		DEFAULT => -44
	},
	{#State 195
		ACTIONS => {
			'CLCURLY' => 220
		}
	},
	{#State 196
		ACTIONS => {
			'OPPAR' => 221
		},
		DEFAULT => -129
	},
	{#State 197
		DEFAULT => -125
	},
	{#State 198
		DEFAULT => -123
	},
	{#State 199
		DEFAULT => -128
	},
	{#State 200
		DEFAULT => -127
	},
	{#State 201
		ACTIONS => {
			'INTEGER' => 222
		}
	},
	{#State 202
		ACTIONS => {
			'OPCURLY' => 223
		}
	},
	{#State 203
		DEFAULT => -113
	},
	{#State 204
		DEFAULT => -134
	},
	{#State 205
		ACTIONS => {
			'OPSPECIAL' => 28,
			'SEMICOLON' => 225
		},
		GOTOS => {
			'special_block' => 224,
			'special_block_start' => 30
		}
	},
	{#State 206
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 42,
			"const" => 9,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 25,
			'template' => 13,
			'looks_like_function' => 51,
			'type' => 20
		}
	},
	{#State 207
		DEFAULT => -72
	},
	{#State 208
		DEFAULT => -48
	},
	{#State 209
		ACTIONS => {
			'ID' => 226,
			'TILDE' => 179,
			'p_name' => 17,
			"virtual" => 184
		},
		GOTOS => {
			'perc_name' => 209,
			'ctor' => 211,
			'_vmethod' => 193,
			'dtor' => 212,
			'vmethod' => 210,
			'virtual' => 190
		}
	},
	{#State 210
		DEFAULT => -74
	},
	{#State 211
		DEFAULT => -66
	},
	{#State 212
		DEFAULT => -68
	},
	{#State 213
		DEFAULT => -50
	},
	{#State 214
		ACTIONS => {
			'OPPAR' => 227
		}
	},
	{#State 215
		DEFAULT => -49
	},
	{#State 216
		DEFAULT => -28
	},
	{#State 217
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"const" => 9,
			"unsigned" => 42,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		DEFAULT => -121,
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 25,
			'template' => 13,
			'arg_list' => 228,
			'argument' => 127,
			'type' => 125
		}
	},
	{#State 218
		ACTIONS => {
			'EQUAL' => 229
		},
		DEFAULT => -70,
		GOTOS => {
			'function_metadata' => 230
		}
	},
	{#State 219
		ACTIONS => {
			'p_code' => 106,
			'p_cleanup' => 102,
			'p_catch' => 109,
			'p_postcall' => 104
		},
		DEFAULT => -71,
		GOTOS => {
			'perc_postcall' => 105,
			'perc_code' => 101,
			'perc_cleanup' => 107,
			'perc_catch' => 103,
			'_function_metadata' => 108
		}
	},
	{#State 220
		DEFAULT => -122
	},
	{#State 221
		ACTIONS => {
			'ID' => 23,
			'INTEGER' => 197,
			'QUOTED_STRING' => 199,
			'DASH' => 201,
			'FLOAT' => 200
		},
		DEFAULT => -133,
		GOTOS => {
			'class_name' => 196,
			'value_list' => 231,
			'value' => 232
		}
	},
	{#State 222
		DEFAULT => -126
	},
	{#State 223
		ACTIONS => {
			'ID' => 233
		}
	},
	{#State 224
		DEFAULT => -135
	},
	{#State 225
		DEFAULT => -14
	},
	{#State 226
		ACTIONS => {
			'OPPAR' => 217
		}
	},
	{#State 227
		ACTIONS => {
			'CLPAR' => 234
		}
	},
	{#State 228
		ACTIONS => {
			'CLPAR' => 235,
			'COMMA' => 152
		}
	},
	{#State 229
		ACTIONS => {
			'INTEGER' => 236
		}
	},
	{#State 230
		ACTIONS => {
			'p_code' => 106,
			'p_cleanup' => 102,
			'p_catch' => 109,
			'p_postcall' => 104
		},
		DEFAULT => -75,
		GOTOS => {
			'perc_postcall' => 105,
			'perc_code' => 101,
			'perc_cleanup' => 107,
			'perc_catch' => 103,
			'_function_metadata' => 108
		}
	},
	{#State 231
		ACTIONS => {
			'CLPAR' => 237,
			'COMMA' => 238
		}
	},
	{#State 232
		DEFAULT => -131
	},
	{#State 233
		ACTIONS => {
			'CLCURLY' => 239
		}
	},
	{#State 234
		DEFAULT => -70,
		GOTOS => {
			'function_metadata' => 240
		}
	},
	{#State 235
		DEFAULT => -70,
		GOTOS => {
			'function_metadata' => 241
		}
	},
	{#State 236
		DEFAULT => -70,
		GOTOS => {
			'function_metadata' => 242
		}
	},
	{#State 237
		DEFAULT => -130
	},
	{#State 238
		ACTIONS => {
			'ID' => 23,
			'INTEGER' => 197,
			'QUOTED_STRING' => 199,
			'DASH' => 201,
			'FLOAT' => 200
		},
		GOTOS => {
			'class_name' => 196,
			'value' => 243
		}
	},
	{#State 239
		ACTIONS => {
			'OPCURLY' => 245,
			'OPSPECIAL' => 28
		},
		DEFAULT => -20,
		GOTOS => {
			'simple_block' => 247,
			'mixed_blocks' => 244,
			'special_block' => 246,
			'special_block_start' => 30
		}
	},
	{#State 240
		ACTIONS => {
			'p_code' => 106,
			'p_cleanup' => 102,
			'p_catch' => 109,
			'p_postcall' => 104
		},
		DEFAULT => -67,
		GOTOS => {
			'perc_postcall' => 105,
			'perc_code' => 101,
			'perc_cleanup' => 107,
			'perc_catch' => 103,
			'_function_metadata' => 108
		}
	},
	{#State 241
		ACTIONS => {
			'p_code' => 106,
			'p_cleanup' => 102,
			'p_catch' => 109,
			'p_postcall' => 104
		},
		DEFAULT => -65,
		GOTOS => {
			'perc_postcall' => 105,
			'perc_code' => 101,
			'perc_cleanup' => 107,
			'perc_catch' => 103,
			'_function_metadata' => 108
		}
	},
	{#State 242
		ACTIONS => {
			'p_code' => 106,
			'p_cleanup' => 102,
			'p_catch' => 109,
			'p_postcall' => 104
		},
		DEFAULT => -76,
		GOTOS => {
			'perc_postcall' => 105,
			'perc_code' => 101,
			'perc_cleanup' => 107,
			'perc_catch' => 103,
			'_function_metadata' => 108
		}
	},
	{#State 243
		DEFAULT => -132
	},
	{#State 244
		ACTIONS => {
			'OPCURLY' => 245,
			'OPSPECIAL' => 28,
			'SEMICOLON' => 249
		},
		GOTOS => {
			'simple_block' => 250,
			'special_block' => 248,
			'special_block_start' => 30
		}
	},
	{#State 245
		ACTIONS => {
			'ID' => 251
		}
	},
	{#State 246
		DEFAULT => -16
	},
	{#State 247
		DEFAULT => -17
	},
	{#State 248
		DEFAULT => -18
	},
	{#State 249
		DEFAULT => -15
	},
	{#State 250
		DEFAULT => -19
	},
	{#State 251
		ACTIONS => {
			'CLCURLY' => 252
		}
	},
	{#State 252
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
		 'class', 2, undef
	],
	[#Rule 26
		 'class', 2, undef
	],
	[#Rule 27
		 'function', 2, undef
	],
	[#Rule 28
		 'method', 2, undef
	],
	[#Rule 29
		 'decorate_class', 2,
sub
#line 86 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 30
		 'class_decl', 7,
sub
#line 89 "XSP.yp"
{ create_class( $_[0], $_[2], $_[3], $_[4], $_[6] ) }
	],
	[#Rule 31
		 'base_classes', 2,
sub
#line 92 "XSP.yp"
{ [ $_[2] ] }
	],
	[#Rule 32
		 'base_classes', 3,
sub
#line 93 "XSP.yp"
{ push @{$_[1]}, $_[3] if $_[3]; $_[1] }
	],
	[#Rule 33
		 'base_classes', 0, undef
	],
	[#Rule 34
		 'base_class', 2,
sub
#line 97 "XSP.yp"
{ $_[2] }
	],
	[#Rule 35
		 'base_class', 2,
sub
#line 98 "XSP.yp"
{ $_[2] }
	],
	[#Rule 36
		 'base_class', 2,
sub
#line 99 "XSP.yp"
{ $_[2] }
	],
	[#Rule 37
		 'class_name_rename', 1,
sub
#line 103 "XSP.yp"
{ create_class( $_[0], $_[1], [], [] ) }
	],
	[#Rule 38
		 'class_name_rename', 2,
sub
#line 104 "XSP.yp"
{ my $klass = create_class( $_[0], $_[2], [], [] );
                             $klass->set_perl_name( $_[1] );
                             $klass
                             }
	],
	[#Rule 39
		 'class_metadata', 2,
sub
#line 110 "XSP.yp"
{ [ @{$_[1]}, @{$_[2]} ] }
	],
	[#Rule 40
		 'class_metadata', 0,
sub
#line 111 "XSP.yp"
{ [] }
	],
	[#Rule 41
		 'class_body_list', 0,
sub
#line 115 "XSP.yp"
{ [] }
	],
	[#Rule 42
		 'class_body_list', 2,
sub
#line 117 "XSP.yp"
{ push @{$_[1]}, $_[2] if $_[2]; $_[1] }
	],
	[#Rule 43
		 'class_body_element', 1, undef
	],
	[#Rule 44
		 'class_body_element', 1, undef
	],
	[#Rule 45
		 'class_body_element', 1, undef
	],
	[#Rule 46
		 'class_body_element', 1, undef
	],
	[#Rule 47
		 'class_body_element', 1, undef
	],
	[#Rule 48
		 'access_specifier', 2,
sub
#line 123 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 49
		 'access_specifier', 2,
sub
#line 124 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 50
		 'access_specifier', 2,
sub
#line 125 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 51
		 'method_decl', 1, undef
	],
	[#Rule 52
		 'method_decl', 1, undef
	],
	[#Rule 53
		 'method_decl', 1, undef
	],
	[#Rule 54
		 'method_decl', 1, undef
	],
	[#Rule 55
		 'const', 1,
sub
#line 130 "XSP.yp"
{ 1 }
	],
	[#Rule 56
		 'const', 0,
sub
#line 131 "XSP.yp"
{ 0 }
	],
	[#Rule 57
		 'virtual', 1, undef
	],
	[#Rule 58
		 'static', 1, undef
	],
	[#Rule 59
		 'static', 1, undef
	],
	[#Rule 60
		 'static', 1,
sub
#line 137 "XSP.yp"
{ 'package_static' }
	],
	[#Rule 61
		 'looks_like_function', 6,
sub
#line 142 "XSP.yp"
{
              return { ret_type  => $_[1],
                       name      => $_[2],
                       arguments => $_[4],
                       const     => $_[6],
                       };
          }
	],
	[#Rule 62
		 'looks_like_renamed_function', 1, undef
	],
	[#Rule 63
		 'looks_like_renamed_function', 2,
sub
#line 153 "XSP.yp"
{ $_[2]->{perl_name} = $_[1]; $_[2] }
	],
	[#Rule 64
		 'function_decl', 2,
sub
#line 156 "XSP.yp"
{ add_data_function( $_[0],
                                         name      => $_[1]->{name},
                                         perl_name => $_[1]->{perl_name},
                                         ret_type  => $_[1]->{ret_type},
                                         arguments => $_[1]->{arguments},
                                         @{$_[2]} ) }
	],
	[#Rule 65
		 'ctor', 5,
sub
#line 164 "XSP.yp"
{ add_data_ctor( $_[0], name      => $_[1],
                                            arguments => $_[3],
                                            @{ $_[5] } ) }
	],
	[#Rule 66
		 'ctor', 2,
sub
#line 167 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 67
		 'dtor', 5,
sub
#line 170 "XSP.yp"
{ add_data_dtor( $_[0], name  => $_[2],
                                            @{ $_[5] },
                                      ) }
	],
	[#Rule 68
		 'dtor', 2,
sub
#line 173 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 69
		 'function_metadata', 2,
sub
#line 175 "XSP.yp"
{ [ @{$_[1]}, @{$_[2]} ] }
	],
	[#Rule 70
		 'function_metadata', 0,
sub
#line 176 "XSP.yp"
{ [] }
	],
	[#Rule 71
		 'nmethod', 2,
sub
#line 181 "XSP.yp"
{ my $m = add_data_method
                        ( $_[0],
                          name      => $_[1]->{name},
                          perl_name => $_[1]->{perl_name},
                          ret_type  => $_[1]->{ret_type},
                          arguments => $_[1]->{arguments},
                          const     => $_[1]->{const},
                          @{$_[2]},
                          );
            $m
          }
	],
	[#Rule 72
		 'nmethod', 2,
sub
#line 193 "XSP.yp"
{ $_[2]->set_static( $_[1] ); $_[2] }
	],
	[#Rule 73
		 'vmethod', 1, undef
	],
	[#Rule 74
		 'vmethod', 2,
sub
#line 198 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 75
		 '_vmethod', 3,
sub
#line 203 "XSP.yp"
{ my $m = add_data_method
                        ( $_[0],
                          name      => $_[2]->{name},
                          perl_name => $_[2]->{perl_name},
                          ret_type  => $_[2]->{ret_type},
                          arguments => $_[2]->{arguments},
                          const     => $_[2]->{const},
                          @{$_[3]},
                          );
            $m->set_virtual( 1 );
            $m
          }
	],
	[#Rule 76
		 '_vmethod', 5,
sub
#line 216 "XSP.yp"
{ my $m = add_data_method
                        ( $_[0],
                          name      => $_[2]->{name},
                          perl_name => $_[2]->{perl_name},
                          ret_type  => $_[2]->{ret_type},
                          arguments => $_[2]->{arguments},
                          const     => $_[2]->{const},
                          @{$_[5]},
                          );
            die "Invalid pure virtual method" unless $_[4] eq '0';
            $m->set_virtual( 2 );
            $m
          }
	],
	[#Rule 77
		 '_function_metadata', 1, undef
	],
	[#Rule 78
		 '_function_metadata', 1, undef
	],
	[#Rule 79
		 '_function_metadata', 1, undef
	],
	[#Rule 80
		 '_function_metadata', 1, undef
	],
	[#Rule 81
		 'perc_name', 4,
sub
#line 237 "XSP.yp"
{ $_[3] }
	],
	[#Rule 82
		 'perc_package', 4,
sub
#line 238 "XSP.yp"
{ $_[3] }
	],
	[#Rule 83
		 'perc_module', 4,
sub
#line 239 "XSP.yp"
{ $_[3] }
	],
	[#Rule 84
		 'perc_file', 4,
sub
#line 240 "XSP.yp"
{ $_[3] }
	],
	[#Rule 85
		 'perc_loadplugin', 4,
sub
#line 241 "XSP.yp"
{ $_[3] }
	],
	[#Rule 86
		 'perc_include', 4,
sub
#line 242 "XSP.yp"
{ $_[3] }
	],
	[#Rule 87
		 'perc_code', 2,
sub
#line 243 "XSP.yp"
{ [ code => $_[2] ] }
	],
	[#Rule 88
		 'perc_cleanup', 2,
sub
#line 244 "XSP.yp"
{ [ cleanup => $_[2] ] }
	],
	[#Rule 89
		 'perc_postcall', 2,
sub
#line 245 "XSP.yp"
{ [ postcall => $_[2] ] }
	],
	[#Rule 90
		 'perc_catch', 4,
sub
#line 246 "XSP.yp"
{ [ map {(catch => $_)} @{$_[3]} ] }
	],
	[#Rule 91
		 'type', 2,
sub
#line 249 "XSP.yp"
{ make_const( $_[2] ) }
	],
	[#Rule 92
		 'type', 1, undef
	],
	[#Rule 93
		 'nconsttype', 2,
sub
#line 254 "XSP.yp"
{ make_ptr( $_[1] ) }
	],
	[#Rule 94
		 'nconsttype', 2,
sub
#line 255 "XSP.yp"
{ make_ref( $_[1] ) }
	],
	[#Rule 95
		 'nconsttype', 1,
sub
#line 256 "XSP.yp"
{ make_type( $_[1] ) }
	],
	[#Rule 96
		 'nconsttype', 1, undef
	],
	[#Rule 97
		 'type_name', 1, undef
	],
	[#Rule 98
		 'type_name', 1, undef
	],
	[#Rule 99
		 'type_name', 1,
sub
#line 263 "XSP.yp"
{ 'unsigned int' }
	],
	[#Rule 100
		 'type_name', 2,
sub
#line 264 "XSP.yp"
{ 'unsigned' . ' ' . $_[2] }
	],
	[#Rule 101
		 'basic_type', 1, undef
	],
	[#Rule 102
		 'basic_type', 1, undef
	],
	[#Rule 103
		 'basic_type', 1, undef
	],
	[#Rule 104
		 'basic_type', 1, undef
	],
	[#Rule 105
		 'basic_type', 2, undef
	],
	[#Rule 106
		 'basic_type', 2, undef
	],
	[#Rule 107
		 'template', 4,
sub
#line 270 "XSP.yp"
{ make_template( $_[1], $_[3] ) }
	],
	[#Rule 108
		 'type_list', 1,
sub
#line 274 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 109
		 'type_list', 3,
sub
#line 275 "XSP.yp"
{ push @{$_[1]}, $_[3]; $_[1] }
	],
	[#Rule 110
		 'class_name', 1, undef
	],
	[#Rule 111
		 'class_name', 2,
sub
#line 279 "XSP.yp"
{ $_[1] . '::' . $_[2] }
	],
	[#Rule 112
		 'class_name_list', 1,
sub
#line 282 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 113
		 'class_name_list', 3,
sub
#line 283 "XSP.yp"
{ push @{$_[1]}, $_[3]; $_[1] }
	],
	[#Rule 114
		 'class_suffix', 2,
sub
#line 286 "XSP.yp"
{ $_[2] }
	],
	[#Rule 115
		 'class_suffix', 3,
sub
#line 287 "XSP.yp"
{ $_[1] . '::' . $_[3] }
	],
	[#Rule 116
		 'file_name', 1,
sub
#line 289 "XSP.yp"
{ '-' }
	],
	[#Rule 117
		 'file_name', 3,
sub
#line 290 "XSP.yp"
{ $_[1] . '.' . $_[3] }
	],
	[#Rule 118
		 'file_name', 3,
sub
#line 291 "XSP.yp"
{ $_[1] . '/' . $_[3] }
	],
	[#Rule 119
		 'arg_list', 1,
sub
#line 293 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 120
		 'arg_list', 3,
sub
#line 294 "XSP.yp"
{ push @{$_[1]}, $_[3]; $_[1] }
	],
	[#Rule 121
		 'arg_list', 0, undef
	],
	[#Rule 122
		 'argument', 5,
sub
#line 298 "XSP.yp"
{ make_argument( @_[0, 1], "length($_[4])" ) }
	],
	[#Rule 123
		 'argument', 4,
sub
#line 300 "XSP.yp"
{ make_argument( @_[0, 1, 2, 4] ) }
	],
	[#Rule 124
		 'argument', 2,
sub
#line 301 "XSP.yp"
{ make_argument( @_ ) }
	],
	[#Rule 125
		 'value', 1, undef
	],
	[#Rule 126
		 'value', 2,
sub
#line 304 "XSP.yp"
{ '-' . $_[2] }
	],
	[#Rule 127
		 'value', 1, undef
	],
	[#Rule 128
		 'value', 1, undef
	],
	[#Rule 129
		 'value', 1, undef
	],
	[#Rule 130
		 'value', 4,
sub
#line 308 "XSP.yp"
{ "$_[1]($_[3])" }
	],
	[#Rule 131
		 'value_list', 1, undef
	],
	[#Rule 132
		 'value_list', 3,
sub
#line 313 "XSP.yp"
{ "$_[1], $_[2]" }
	],
	[#Rule 133
		 'value_list', 0,
sub
#line 314 "XSP.yp"
{ "" }
	],
	[#Rule 134
		 'special_blocks', 1,
sub
#line 318 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 135
		 'special_blocks', 2,
sub
#line 320 "XSP.yp"
{ [ @{$_[1]}, $_[2] ] }
	],
	[#Rule 136
		 'special_blocks', 0, undef
	],
	[#Rule 137
		 'special_block', 3,
sub
#line 324 "XSP.yp"
{ $_[2] }
	],
	[#Rule 138
		 'special_block', 2,
sub
#line 326 "XSP.yp"
{ [] }
	],
	[#Rule 139
		 'special_block_start', 1,
sub
#line 329 "XSP.yp"
{ push_lex_mode( $_[0], 'special' ) }
	],
	[#Rule 140
		 'special_block_end', 1,
sub
#line 331 "XSP.yp"
{ pop_lex_mode( $_[0], 'special' ) }
	],
	[#Rule 141
		 'lines', 1,
sub
#line 333 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 142
		 'lines', 2,
sub
#line 334 "XSP.yp"
{ push @{$_[1]}, $_[2]; $_[1] }
	]
],
                                  @_);
    bless($self,$class);
}

#line 336 "XSP.yp"


use ExtUtils::XSpp::Lexer;

1;
