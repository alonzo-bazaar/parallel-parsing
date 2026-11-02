# depth vector calculation
# (could have been shorter but I don't wanna compute o twice)
DV ← { o ← 𝕩∊"([{" ⋄ c ← 𝕩∊")]}" ⋄ o-˜+`o-c }

# valid brackets
# procedure from
# https://dl.acm.org/doi/epdf/10.1145/3760250.3762222
# stable sort brackets by their depth, matching brackets should
# then all be moved one next to the other  
# eg:
# 𝕩   : "[](([]))"
# DV 𝕩:  00012210
# (stable) sorting by depth gives
# ⍋∘DV⊸⊏ tv: []()()[]
# the paper then kinda (rough bqn translation)
# ∧´ 1‿2∊˜ -˜˝˘ @-˜ ∘‿2⥊⍋∘DV⊸⊏ "insert string here"
# since in ascii '(' + 1 = ')', '[' + 2 = ']', and '{' + 2 = '}'
VB ← {
   1=2|≠𝕩 ? 0 ;
   # we use depth vector twice, store not to recompute
   d ← DV 𝕩
   # banal first check, depth vector is never negative
   c1 ← ∧´ 0 ≤ d
   # plus paper's additional check
   c2 ← ∧´ 1‿2∊˜ -˜˝˘ ∘‿2⥊ (⍋d)⊏ 𝕩-@
   # we'll take them both being valid as an ok 
   c1 ∧ c2
}

# unit tests
!  VB ""
!  VB "()"
!  VB "([])"
!  VB "([{}])"
!¬ VB "([{])}"
!  VB "[][](([])(){}{{[]()[()]}})"
!¬ VB "([)]"
!¬ VB "()[]{}{"
!¬ VB "()[]{}{{"
!¬ VB "()[]{}}}"
