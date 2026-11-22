s←"(0,(1,2),3,4,(50),6,7,(),8)"

ois ← s='(' # open indices
cis ← s=')' # closed indices
# number indices
# but we want only one index per number
# so number indices that are not followed by a number index
# ie, we have that a number is located "only" at its first digit
nis ← »⊸< s∊'0'+↕10
# now the tokenizer
# tokens types one index per token
ott ← 1 # open   (paren) token type
ctt ← 2 # closed (paren) token type
ntt ← 3 # number         token type
tts ← 0⊸≠⊸/ (ott×ois) + (ctt×cis) + (ntt×nis) # token types
otis ← tts=ott # open   *token* indices
ntis ← tts=ntt # number *token* indices
ctis ← tts=ctt # closed *token* indices
# also get the numbers out
ns ← •Parsefloat¨ s ⊔˜ 1-˜(s∊'0'+↕10)×(+`nis)
# token depths
td ← +` otis - ctis
# depth ordering
do ← ⍋td
# tokens types, ordered by depth
# NOTE:
# when ordering by depth we have
# - first all the depth 0 tokens
# - then all the depth 1 tokens, in the order in which they appear
#   in the original token vector  
# - then all the depth 3 tokens, in the order in which they...
# 
# so... yeah congratulations we have acheived a very weird way
# to do a dfs of the tree expressed in our string
# (without even deserializing it first, like what the fuck man)
tt_obd ← do⊏tts
# sublist index, ordered by depth
si_obd ← +`tt_obd=ott
# sublist index, original order
# we obtain the obd one first 'cause it's far easier to compute
# to obtain it in the original (data string) order, we invert the
# depth ordering by calling ⍋ on it (see ordinals pattern)
si ← (⍋do)⊏si_obd
# value token indices
#
# we want the numbers sorted by depth as well so we can
# put them together with this datum then go fucking nuts
# 
# we're gonna construct a value list bottom up
# numbers first, then the deepest lists, then less deep lists, and so on
# value indices will tell for all "value tokens"
# (ntt tokens stand numbers, ctt tokens stand for sublists)
#
# the value indices vector will tell us, for each value token
# what value of this list do they correspond to
# (we need this 'cause the value list and the token (type) list are
#  separate)
# 
# so, to compute it:
# we have 0⊸≠⊸/ (1×tts=ntt) + (2×tts=ctt)
# this will be 1 for numbers, 2 for closing brackets, and 0 nowhere
# and then do an ordinals on it
# which here is like
# {(↕+´1=𝕩)⌾((1=𝕩)⊸/)𝕩}
# and
# {(number_of_ones+↕+´1=𝕩)⌾((2=𝕩)⊸/)𝕩}
# if that makes any sense
# 
# we're gonna have an increasing thing which goes through all the ones
# first then through all the twos
# so you have a unique increasing index for numbers and ')'
# and it's lower for all numbers than it is for any ')'
vi ← ⍋⍋ 0⊸≠⊸/ (1×ntis) + (2×ctis)
# this means we do have, for all numbers, what index they correspond to
# but the closing parens in this ⍋⍋ are ordered by depth *increasing*,
# whereas in the value list we're building we said we'd list them by 
# depth *decreasing* (plus a bunch of bullshit at ties)
# we gotta fix that
# 
# to fix that we use si
# if we do ctis/si we get, for every close paren, its sublist index,
# but for how we structured si
# (ie: using a depth that increases at close parens)
# ctis/si at close parens will see a close paren as belonging to the
# list containing it, not to the list it's delimiting
# > "containing it" as in "containing the list it's delimiting", 
# > recall that we're using closing parens as where to place the list
# > they delimit
#
# to get the list it's delimiting we'll access the element right before
# it so ctis/»l (we could have used («ctis)/l but it's bqn, we golfing)
# 
# this will be an index ranging from 1 to +´ctis inclusive 
# recall how we defined si as
# (a rearrangement of) +` (a rearrangement of) ctis
# and it's 0 only for closing brackets contained in the toplevel
# but we only take indices *inside* parenthesis
#
# NOTE:
# if we have a valid parenthesized expression it can't start with )
# meaning we're gonna have 0=⊑ctis, so «ctis should not be lossy as
# ctis will ≡ »«ctis for all valid values of ctis
# for invalid values... idfk
# 
# next we do (≠ns) + ≠⊸-ctis/»si
# that is, take c/»l, we subtract the length from it, so instead of
# going from 1...+`ctis, it goes from 1-˜+`ctis...0
# this inverts the order because we're doing deeper lists first
# then we add ≠ns because we need indices into the value list
# which has 0...ns-1 for numbers, so it will have ns, ns...1-˜+`ctis
# for sublists
# so we fix vi by having
fvi ← vi ⊏ (↕≠ns) ∾ (≠ns) + ≠⊸-ctis/»si # fixed vi
vm ← ntis∨ctis # value mask
vals ← ns
{vals ∾↩<𝕩⊏vals⋄@}¨ ⌽((+´ctis)∾˜1-˜vm/si)⊔fvi
¯1⊑vals
