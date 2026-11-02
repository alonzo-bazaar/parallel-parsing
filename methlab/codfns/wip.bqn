parse ← •Import "impl.bqn"

⊏
# longer example
lo←"(mapcar (lambda (x y) (* (car x) (car y))) '((1) (2)))"
# shorter example
sh←"((a)) ((((boi)))) (c d)"
# stronzo example 1
st1←"((((((((((a))))))))))"
# stronzo example 2
st2←"a b c d e f g h i j k"
# incorrect example (will add errors later)
in←"((a)) ((((boi))) (c d)"

# now we gotta turn the depth vector into a parent vector
t‿d‿v ← Parse in
# one way to compute the parent vector
# for every index, get the latest index to its left that's one depth less
# if no such index exists we say its parent is 0
P1 ← {𝕊d: {(0≠≠)◶0‿(⊢´) /(𝕩↑d)=(1-˜𝕩⊑d)}¨ ↕≠d}

# this implementation, although rather nice and direct (for some)
# is kinda inefficient, so we can use group
⊔d
# this gives an array x such that i⊑x is an array of all nodes in x with
# depth i

# in the phd aaron uses ⊔ to separate the layers of the tree and
# ⍋ between the layers in question to get the parent indices of layer n+1
# into layer n

# something like
1-˜ ⍋´¨ <˘ 2↕ ⊔d
# the 1-˜ at the end is because ⍋ returns values one greater
# than those you'd get from ⍸

# this gives us the parent indices
# the parents themselves can be obtained by
⊑ <˘2↕ ⊔d
(1⊸-˜∘(⍋´) ⊏ ⊑)¨ <˘2↕ d⊔ ↕≠d
# P2 ← {𝕊d: {(⋈0¨⊑𝕩)∾(1⊸-˜∘(⍋´) ⊏ ⊑)¨ <˘2↕𝕩}⌾(d⊸⊔) ↕≠d}

# (<(1-˜⍋´)⊏⊑)2↕⊔d is basically a 2-wise reduction of
# 1-˜⍋
# given a tree layer and its parent
# (⊔d separates the depth vector into layers)
# this gets all the parents (in the first layer) of the nodes (in the second layer)
# this is because a node i's parent may also be found as the last
# node which comes before i and has depth =1-˜i⊑d
# 
# root nodes all have parent zero so we add zeros at the beginning
D2P ← {𝕊d: {(⋈0¨⊑𝕩)∾(<(1-˜⍋´)⊏⊑)˘2↕𝕩}⌾(d⊸⊔)↕≠d}

# ok this doesn't work, aaron did more
{
    p ← ↕≠d
    {
        p (𝕩⊏˜ 1-˜ 𝕩⍋𝕨)⌾(𝕨⊸⊏)↩
    }´¨ <˘ 2↕⊔d
    p
}

# ok I must have gotten something terribly wrong, this isn't working
# shit
