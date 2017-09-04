#!/usr/bin/ruby

# Church encoding
# Such encoding N[p][x]can be explained as "perform p(x) iteratively for N times and return its result"
ZERO  = ->p{->x{x}}
ONE   = ->p{->x{p[x]}}
TWO   = ->p{->x{p[p[x]]}}
THREE = ->p{->x{p[p[p[x]]]}}
FOUR  = ->p{->x{p[p[p[p[x]]]]}}
FIVE  = ->p{->x{p[p[p[p[p[x]]]]]}}
SIX   = ->p{->x{p[p[p[p[p[p[x]]]]]]}}
SEVEN = ->p{->x{p[p[p[p[p[p[p[x]]]]]]]}}
EIGHT = ->p{->x{p[p[p[p[p[p[p[p[x]]]]]]]]}}
NINE  = ->p{->x{p[p[p[p[p[p[p[p[p[x]]]]]]]]]}}
TEN   = ->p{->x{p[p[p[p[p[p[p[p[p[p[x]]]]]]]]]]}}

# perform ->n{n+1}[0] N times and return n.
def proc_to_integer(proc)
	proc[->n{n+1}][0]
end

# test
puts proc_to_integer(ZERO)
puts proc_to_integer(ONE)
puts proc_to_integer(TWO)
puts proc_to_integer(THREE)
puts proc_to_integer(FOUR)
puts proc_to_integer(FIVE)
puts proc_to_integer(SIX)
puts proc_to_integer(SEVEN)
puts proc_to_integer(EIGHT)
puts proc_to_integer(NINE)
puts proc_to_integer(TEN)

# Church Boolean
# each receives two arguments as options, and return different option.
# they distinguish with each other by returning different option.
TRUE  = ->x{->y{x}}
FALSE = ->x{->y{y}}

# we set two options to Ruby value true and false to make sure:
# proc TRUE returns Ruby value true, and vice versa
def proc_to_boolean(proc)
	proc[true][false]
end

# test
puts proc_to_integer(TRUE)
puts proc_to_integer(FALSE)

# IF

# original expression is as follows
IF_ORIGIN = 
->selector{
	->branch1{ ->branch2{
			selector[branch1][branch2]
	}}
}
# however, we can use the rule
#   ->x{ p[x] }  ==  p
# to simplify IF_ORIGIN as
IF = ->selector{ selector }
# we find that proc IF does nothing but "selector".
# in fact, IF does the same work as two "selector"s - TRUE and FALSE
# as we have known above that the two "selector"s is actually IF itself - they branch from two probable results - as if-statement does
# we design proc IF there for the sake of finding a lambda-way to express if-statement - a kind of syntactic sugar.
# IF just provide a convenient way to use "selector" TRUE and FALSE.

# WHY NOT:
# IF = 
# ->branch1{
#	->branch2{
#		->selector{
#			selector[branch1][branch2]
#		}
#	}
# }

# test
print "true ? branch1 : branch2 = "
puts IF[TRUE ]["branch1"]["branch2"]
print "false ? branch1 : branch2 = "
puts IF[FALSE]["branch1"]["branch2"]

# is_zero

# Each proc of number NUM is a proc which receives two arguments, which the first argument is a proc p with parameter x,
#    and the second argument is the parameter x of the first argument p, i.e. ->p{->x{p..[x]}}.
# As is known, proc ZERO (->p{->x{x}}) returns the second argument x directly, so we could construct the IS_ZERO proc,
#    which receives one parameter NUM, and assigning TRUE to the second argument x of argument NUM,
#    thus we will get TRUE when NUM = ZERO.
#    While NUM != ZERO, we need FALSE in return. To achieve this, we could assign the first argument p to a "Constant"
#    which always returns FALSE regardless of the parameter. We mark this proc as
FALSE_CONST = ->x{FALSE}
#    (Note that FALSE_CONST is not FALSE. FALSE_CONST returns proc FALSE, FALSE returns the second argument of its two args.)
#    Because only ZERO does not call proc p (FALSE_CONST) and it always returns the second arg TRUE, so IS_ZERO[ZERO] == TRUE.
#    Others call proc p (FALSE_CONST) iteratively and no matter what x is, FALSE_CONST always returns FALSE.
# Now we can construct IS_ZERO as follow
IS_ZERO = ->num{num[FALSE_CONST][TRUE]}
# Always remember that IS_ZERO returns proc TRUE or FALSE, so we can regard IS_ZERO as an implement of a predicate.

print "zero? 10 = "
puts proc_to_boolean(IS_ZERO[TEN])
print "zero? 0 = "
puts proc_to_boolean(IS_ZERO[ZERO])

# pair

# A pair is a data structure which contains two elements in a certain order: left element and right element.
#    To construct a pair, consider a proc "selector", which holds two different arguments, and we will use it to store two elements of the pair.
#    We can make the pair return a "selector" containing two bound arguments, to simulate a pair containing two elements.
PAIR = ->element1{->element2{->selector{selector[element1][element2]}}}
# When we want to get one element of a pair, we need to select one argument of the pair in some way.
#    As the proc PAIR returns a proc "selector" with two bound argument, we could bind a particular proc to "selector" which could SELECT one of two bound args.
#    Luckily we have constructed two different procs - TRUE and FALSE. They are in fact selectors to choose one from two bound arguments to return.
#    Now we could assign(bind) TRUE to parameter "selector" of PAIR to get one bound argument as an stored element, and assign FALSE in order to get another element.

# I have to make a declaration that I have not studied lambda calculaus in any formal curriculum,
#   so I should clarify some terms I have used:
# ASSIGN/BIND/APPLY means "to replace a free variable(自由变量) such as "x" in "f(x)" with a certain instance(实例) such as "1" in "f(1)",
#   and the "1" there is a ASSIGNED/BOUND/APPLIED variable(绑定变量)(if we regard substance "1" as a variable).

# 

LEFT  = ->pair{pair[TRUE]}
RIGHT = ->pair{pair[FALSE]}
print "left <1,2> = "
puts proc_to_integer(LEFT[PAIR[ONE][TWO]])
print "right <3,4> = "
puts proc_to_integer(RIGHT[PAIR[THREE][FOUR]])

# arithmetic calculation

# increment
# p(n+1) = p[p(n)]
INCREMENT =
->number{
	->p{
		->x{
			p[number[p][x]]
		}
	}
}
print "inc 10 = "
puts proc_to_integer(INCREMENT[TEN])

# decrement

# implement a function to transform pair<a-2,a-1> to pair<a-1,a>
SLIDE =
->pair{
	PAIR[RIGHT[pair]][INCREMENT[RIGHT[pair]]]
}

# SLIDE[PAIR] receives PAIR as input arg and return a slided PAIR
# NUM[P][x] receives a function P and P's argument x to iterate P for NUM times.
# So, "Slide pair<0,0> for NUM times" could be written as
#    NUM[SLIDE][PAIR[ZERO][ZERO]]
# and take the left element of the result PAIR.

DECREMENT =
->number{
	LEFT[number[SLIDE][PAIR[ZERO][ZERO]]]
}
print "dec 10 = "
puts proc_to_integer(DECREMENT[TEN])

# Add/Sub/Multiply/Power
ADD = ->m{->n{n[INCREMENT][m]}}
SUB = ->m{->n{n[DECREMENT][m]}}
MUL = ->m{->n{n[ADD[m]][ZERO]}} # n*m
POW = ->m{->n{n[MUL[m]][ONE]}}  # n^m

print "10 + 9 = "
puts proc_to_integer(ADD[TEN][NINE])
print "10 - 9 = "
puts proc_to_integer(SUB[TEN][NINE])
print "10 * 9 = "
puts proc_to_integer(MUL[TEN][NINE])
print "10 ^ 2 = "
puts proc_to_integer(POW[TEN][TWO])

HUNDRED = MUL[TEN][TEN]

# relation operator

IS_LE = ->m{->n{IS_ZERO[SUB[m][n]]}}

print "10 <= 9 ? "
puts proc_to_boolean(IS_LE[TEN][NINE])
print "9 <= 10 ? "
puts proc_to_boolean(IS_LE[NINE][TEN])
print "9 <= 9 ? "
puts proc_to_boolean(IS_LE[NINE][NINE])

# mod
=begin
def mod(m, n)
	if n <= m
		mod(m - n, n)
	else
		m
	end
end
=end

MOD_OLD = 
->m{
	->n{
		IF[IS_LE[n][m]] [
			->x{ MOD_OLD[SUB[m][n]][n] [x] }
		] [
			m
		]
	}
}

# Y-combinator
Y =
->f{
	->x{
		f[x[x]]
	} [
		->x{
		f[x[x]]
	}]
}
# Z-combinator
Z =
->f{
	->x{
		f[->y{x[x][y]}]
	} [
	->x{
		f[->y{x[x][y]}]
	}]
}

MOD =
Z[
->f{
	->m{
		->n{
			IF[IS_LE[n][m]] [
				->x{ f[SUB[m][n]][n] [x] }
			] [
				m
			]
		}
	}
}
]


print "(2*5) % (2^2) = "
puts proc_to_integer(MOD[MUL[TWO][FIVE]][POW[TWO][TWO]])

# list
EMPTY = PAIR[TRUE][TRUE]
UNSHIFT =
->element{
	->list{
		PAIR[FALSE][ PAIR[element][list] ]
	}
}
IS_EMPTY = LEFT
FIRST = ->list{ LEFT[RIGHT[list]] }
REST  = ->list{RIGHT[RIGHT[list]] }
AT =
->list{
	->index{
		FIRST[ index[REST][list] ]
	}
}

def proc_to_array(list)
	array = []
	index = ZERO
	until proc_to_boolean(IS_EMPTY[list])
		array.push(FIRST[list])
		list = REST[list]
	end
	array
end

list_test = UNSHIFT[ONE][ UNSHIFT[TWO][ UNSHIFT[THREE][EMPTY] ] ]
print "list_test[0] = "
puts proc_to_integer(AT[list_test][ZERO])
print "list_test[1] = "
puts proc_to_integer(AT[list_test][ONE])
print "list_test[2] = "
puts proc_to_integer(AT[list_test][TWO])
print "list_test = "
proc_to_array(list_test).map{ |p| print proc_to_integer(p) }
puts ""

# range
RANGE =
Z[
->_range{
	->m{ ->n{
		IF[IS_LE[m][n]][
			->x{ UNSHIFT[m][ _range[INCREMENT[m]][n] ] [x] }
		] [
			EMPTY
		]
	}}
}
]

range_test = RANGE[ONE][TEN]
print "range_test = "
proc_to_array(range_test).map{ |p| print proc_to_integer(p) }
puts ""

# map
# the FOLD resembles the method #map
# FOLD(list, x, f) = f( FOLD( REST(list) , x , f ) , FIRST(list) )
FOLD =
Z[
->_fold{
	->list{ ->x{ ->func{
		IF[IS_EMPTY[list]] [
			x
		] [
			->eta{
				func[ _fold[REST[list]][x][func] ][ FIRST[list] ] [eta]
			}
		]
	}}}
}
]
MAP = 
->range{ ->func{
	FOLD[range][EMPTY][
		->list{ ->element{ UNSHIFT[func[element]][list] } }
	]
}}

mapped_range = MAP[range_test][ADD[TWO]]
print "range_test.map{|i| i+1} = "
proc_to_array(mapped_range).map{ |p| print proc_to_integer(p) }
puts ""

# string
_B = TEN
_F = INCREMENT[_B]
_I = INCREMENT[_F]
_U = INCREMENT[_I]
_Z = INCREMENT[_U]

_FIZZ = UNSHIFT[_F][ UNSHIFT[_I][ UNSHIFT[_Z][ UNSHIFT[_Z][EMPTY] ] ] ]
_BUZZ = UNSHIFT[_B][ UNSHIFT[_U][ UNSHIFT[_Z][ UNSHIFT[_Z][EMPTY] ] ] ]
_FIZZBUZZ = UNSHIFT[_F][ UNSHIFT[_I][ UNSHIFT[_Z][ UNSHIFT[_Z][_BUZZ] ] ] ]

def proc_to_char(proc)
	'0123456789BFiuz'.slice(proc_to_integer(proc))
end

def proc_to_string(proc)
	proc_to_array(proc).map{ |c| proc_to_char(c)}.join
end
print "Print 'FizzBuzz' = "
puts proc_to_string(_FIZZBUZZ)

# to_s
DIV =
Z[
->_div{
	->m{ ->n{
		IF[IS_LE[n][m]][
			->eta{
				INCREMENT[ _div[SUB[m][n]][n] ] [eta]
			}
		] [
			ZERO
		]
	}}
}
]
PUSH =
->list{
	->element{
		FOLD[list][UNSHIFT[element][EMPTY]][UNSHIFT]
	}
}
TO_DIGITS =
Z[
->_to_digits{
	->num{
		PUSH[
			IF[IS_LE[num][DECREMENT[TEN]]] [
				EMPTY
			] [
				->eta{
					_to_digits[DIV[num][TEN]] [eta]
				}
			]
		][MOD[num][TEN]]
	}
}
]
print "10 / 3 = "
puts proc_to_integer(DIV[HUNDRED][THREE])
print "Print 'FizzBuzz' = "
puts proc_to_string(TO_DIGITS[HUNDRED])
