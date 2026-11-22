a ← ∾(⊣+↕∘¬˜)´¨ "AZ"‿"az" # alpha
n ← '0'+↕10               # numeric
an ← a∾n                  # alphaumeric

# a pseudo edn tokenizer
# for shits and giggles
T ← {
    # token starting indices:
    # . delimiters (brackets)
    # . alphanumeric indices which are preceded by a
    #   non-alphanumeric index
    ts ← (»⊸<∘(∊⟜an) ∨ ∊⟜"()[]{}") 𝕩

    # skipped inidices
    # . we consider spaces and commas as separators 
    #   (commas treated like in clojure where they're basically
    #    equivalent to spaces)
    sk ← 𝕩∊" ,"

    # ol' reliable
    (1-˜(¬sk)×+`ts)⊔𝕩
}
