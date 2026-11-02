# comments are mostly notes to self, unlikely to be clear much

a←∾(↕26)⊸+¨ 'a'‿'A'  # alphabet (upper and lower)
w←@+10‿11‿12‿13‿32   # whitespace chars (see https://www.asciitable.com/)
s←"()"               # syntax chars

# symbol mask of string (map (is neither whitespace nor syntax))
SM←¬∊⟜(w∾s)

# we might a have progressive symbol marker vector (to use with ⊔)
# and make it like
# +`∘¬⊸×∘SM vector
# but we wanna use this with ⊔, so we also gotta mark everything
# that's not in a symbol token as ¯1
SIM ← (⊢ -˜ ¬×+`)∘(¬SM) # symbol indicized mask
SS ← ((0≠≠¨)⊸/)(SIM⊸⊔)  # symbols (gotta also remove empty entries)

# getting the depth vector in a separate function was not worth it
# much clearer to shove everything in here instead

# Parse returns
# depth vector of expression
# type  vector of each node (symbol or syntax element)
# value vector of each node (what's the string that represents it)
Parse ← {
    # "descent fronts" of symbolness
    df ← >´˘2↕ SM ∾⟜' ' 𝕩
    # (only have one `1` per symbol, exactly at the end)
    # this will be used as the symbol's representative
    # character position in the string when turning the
    # character vector 𝕩 into token vectors

    # open paren mask
    opm ← '('=𝕩
    # token mask
    tm ← df∨opm
    # which characters in the string will represent the
    # tokens they're part of (only one such char per token)

    # depth of the string
    sd ← opm-˜ +`('('⊸=-=⟜')') 𝕩
    # we subtract opm from the +` to make sure '(' nodes
    # are recognizeable as parents of the shit right after them
    # bqn's ` is an inclusive scan so in +`('('⊸=-=⟜')') 𝕩 
    # they'd have the same depth instead

    # type vector for tokens (1 for '(', 2 for symbols)
    tv ← 0⊸≠⊸/ opm+2×df
    # depth vector for the tokens
    dv ← tm/sd
    # value vector
    # given the current schema it's "(" for everything
    # except the symbol nodes in which case it is the symbol name instead
    vv ← (SS 𝕩)⌾((tv=2)⊸/) ⟨"("⟩⥊˜≠tv

    tv‿dv‿vv
}

# depth vector to parent vector
# ⊔d splits the tree into layers, where each layer is a list of all
# nodes with a given depth, 0⊑⊔d all have depth 0, i⊑⊔d all depth 1...
# (<(1-˜⍋´)⊏⊑)˘2↕𝕩 does a 2-wise reduction on layers
# for a given node i, its parent is the last node before i with
# depth = 1-˜i⊏d
# so (<(1-˜⍋´)⊏⊑) will act on couples of parent layer - child layer
# and get the ids for the child layer node's parents 
# (<(1-˜⍋´)⊏⊑)˘2↕ gets parent nodes for all child layers
# nodes with depth 0 are nobodoy's child layer, so we add a dummy
# (⋈0¨⊑𝕩) in front of (<(1-˜⍋´)⊏⊑)˘2↕𝕩
# and that's everyone's parents
D2P ← {𝕊d: {(⋈0¨⊑𝕩)∾(<(1-˜⍋´)⊏⊑)˘2↕𝕩}⌾(d⊸⊔)↕≠d}
