#!/usr/bin/env bqn

# file where I toy with various ideas for how to implement utf8
# validation in a fast asf boi manner

# I'm gonna avoid using the •bit namespace
# it's a teeny tiny pain in the ass to use 
# expecially if the entire program I'm writing is just, like
# wrangling unsigned chars

# BS: bitstring
# take bitstring ... and turn it to number 0b...
# I can't think of a cleaner impl for this, :/
BS ← {+´ (2⋆⌽∘↕∘≠)⊸× '0'-˜ 𝕩}

# UOC: utf8 octet class, returns
# 0 -> 0xxxxxxx (ascii)
# 1 -> 10xxxxxx (continuation)
# 2 -> 110xxxxx (first octet in a 2 octet code point)
# 3 -> 1110xxxx (first octet in a 3 octet code point)
# 4 -> 11110xxx (first octet in a 4 octet code point)
# 5 -> invalid octet

UOC ← {
    a ← 𝕩 ≥ BS "10000000" # not 0xx...
    b ← 𝕩 ≥ BS "11000000" # not 0xx... or 10x...
    c ← 𝕩 ≥ BS "11100000" # not 0xx... or 10x... or 110x...
    d ← 𝕩 ≥ BS "11110000" # you get the point
    e ← 𝕩 ≥ BS "11111000"

    a + b + c + d + e
}

# validate utf8
# this function currently only targets validity of how octet
# prefixes appear in the utf8 stream, according to
# https://www.rfc-editor.org/info/rfc3629/#section-3
# 
# the stream must be a sequence of encoded code points and a
# code point may only be encoded through a subsequence
# shaped like one of these:
# - 0xxxxxxx
# - 110xxxxx 10xxxxxx
# - 1110xxxx 10xxxxxx 10xxxxxx
# - 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
#
# the above is a fancy way to say we still don't check for
# surrogate pairs
VU ← {
    # character class vector
    c ← UOC 𝕩

    # we're gonna define a bunch of checks:
    # each of this checks will only run if all the ones before it
    # failed miserably.

    # check that we have no invaild characters
    C1 ← 5<⌈´
    # check that 110xxxxx, 1110xxxx, and 11110xxx characters
    # (from now on, character header octet)
    # are always followed by a 10xxxxxx character
    # (from now on, a continuation octet)
    C2 ← (0=∨´)∘(1⊸≠ ∧ (»2⊸≤))

    # check that continuation octets characters are never
    # directly preceded by an ascii character
    C3 ← (0=∨´)∘ (0⊸= ∧ («1⊸=))

    # check that character header octets are always followed by
    # the correct amount of continuation octets
    C4 ← {
        off←+`0‿1‿¯1‿¯2‿¯3⊏𝕩
        # no header octet should be followed by an excess amount
        # of continuation octets
        # 𝕩     ←  2 1 1 1 (wrong) for instance, would become
        # off   ← ¯1 1 1 1
        # +`off ← ¯1 0 1 2
        # values over 0 mark an excess in continuation octets
        a ← 0=⌈´ off

        # all rising edges in `off` should occur when off = 0
        # 𝕩     ←  4  1  1 2 (wrong) for instance, would become
        # off   ← ¯3  1  1 2
        # +`off ← ¯3 ¯2 ¯1 1
        # the rising edge occuring between ¯1 and 1 means there
        # was a defect in continuations after the 4
        # a rising edge occuring at a 0 means we gucci
        # 
        # NOTE 1:
        #   a rising edge occuring at a positive number also means
        #   we had an excess in continuation octets following a
        #   given header octet, meaning the check at above could
        #   be redundant
        b ← 0=∧´ (off≠0) ∧ off<«off

        # NOTE 2:
        #   I should check if any previous runaway garbage state could
        #   violate the preconditions I have put for how these scans
        #   locate invalid utf8 yes, a positive number in off detects
        #   invalidity due to the reasons above but could some
        #   undetected garbage upstream from an invalid utf8 location
        #   turn an error detected by a into a false negative;
        #   for instance, by making the running sum at that invalid
        #   spot excessively negative.
    }
    # TBD: other checks for octet class sequence
    # TODO: surrogate pair checks

    # I need a short circuiting ∧ here
    # this was the dumbest way to do it I could come up with
    # there's probably a cleaner way to do this, perhaps involving a 
    # vector of functions and a •_while_
    {𝕊: ¬ C1 𝕩 ? 0 ; ¬ C2 𝕩 ? 0 ¬ C3 𝕩? 0 ; ¬ C4 𝕩 ? 0 ; 1 } c
}

# test data
# TODO: need test invalid utf8 as well
≠ b ← @-˜•Fbytes "short.txt"
