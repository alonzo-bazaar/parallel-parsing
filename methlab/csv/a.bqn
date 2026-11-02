# based off of
# https://tony-zorman.com/posts/bqn-csv.html
# with some adjustments (author being a cunt)

# RM: running mask
# we are given a mask array m of ones and zeros
# and we wanna know, for each index i where 1=i⊑m, how "deep" it is in a run of
# consecutive 1s i is
# 
# for clarity I'll call an i where 1=i⊑m a 'positive index'
# cause that sounda a bit more human than "an index i for which 1=i⊑m"
# 
# example input/output
# in:  0 0 1 1 1 0 0 0 0 0 1 1 0 1
# out: 0 0 0 1 2 0 0 0 0 0 0 1 0 0
RM ← {𝕊m :
   s ← +`m   # plus Scan
   f ← m∧¬»m # mark First positive index in each run of consecutive 1s

   # s×f will tell us, for the first index of every run of consecutive 1s
   # how large s was at that run-starting positive index i
   # 
   # ⌈`s×f will propagate that value to all other positive indices in the run
   # we won't have any previous run overwrite a later run 'cause we started
   # with a monotonic sequence anyway (+` of a bit mask)
   #
   # so if we subtract them like s-⌈`s×f
   # this will give us, at each positive index i, +`m, *ignoring* how large s
   # already was when the run containing i started
   #
   # ie: a plus scan ignoring everything before that run
   #     a plus scan "localized" to that run, if you will
   #
   # (also we should multiply s-⌈`s×f by m at the end 'cause its value for non
   #  positive indices is kinda garbage data, lol)
   m × s-⌈`s×f
}

# turns csv text into csv data structure
CSV ← {𝕊t:
    # quote indices
    q←'"'=t
    # comma and newline indices
    # Note:
    #   ¬≠`q is an *approximation* for which indices in 𝕩 are unquoted
    #   it doesn't handle quoted quotes correctly, and is not a general purpose
    #   way to tell quoted indices in a csv text string.
    #   That said... we only need it to tell quoted newlines and commas
    #   newlines, so for *this* usecase, it's good enough, fuck it
    [c,n] ← (¬≠`q)⊸×˘ [',', @+10]=⌜t

    # the bqn idiom for splitting a string is like
    # separator ((⊢-˜+`×¬)∘=⊔⊢) string
    # (taken from https://mlochbaum.github.io/bqncrate/)
    # 
    # here, the mask returned by string=separator serves two purposes
    # - it tells +` when to advance the group index
    # - it sets the group index to ¯1, since we don't want to leave
    #   the separator chars in the bits of string we split off
    # (the ⊔ primitive does splitting *and* ignoring, quite handy)
    # 
    # here we're gonna need two different masks for those two different
    # purposes:
    # - one mask to say when one element ends and the next one starts
    # - one mask to say which elements of the input text we want to skip in
    #   the output/split pieces
    # 
    # the separator mask is banal enough, we split on commas and newlines  
    s ← c∨n

    # the second mask is a bit trickier, we do of course want s to be part of
    # this second mask, separators are part of what you leave out when
    # splitting, but we'll use this mask to also skip
    # - escaped quotes
    # - the carriage returns (in CSV files lines are usually split by crlf)
    #   (note: we only need to skip the carriage returns that come immediately
    #    after a newline)
    #
    # to tell which quotes are escaped we'll use the running mask function from
    # above, and skip all quotes with an odd running mask value
    # 
    # we'll call mask this k for sKipped
    k ← s ∨ (q ∧ 0=2|RM q) ∨ (»n ∧ (@+13)=t)

    (0∾s/+`n) ⊔ (1-˜(¬k)×1++`s) ⊔ t 
}
