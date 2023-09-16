⟨ReportBal⟩⇐

# calculate account balance
CalcBalPlain ← {
    # sort/ group accounts
	s ← 𝕩⊏˜⍋1⊏˘𝕩
	# last in group?
	l ← ≢¨⟜«1⊏˘s
	# merge dependent cumulative sums and accounts
	∾≍⟨⍉≍l/1⊏˘s,-⟜»l/+`2↓˘s⟩
}

AccountParents ← {{𝕨∾":"∾𝕩}`𝕩⊔˜1-˜(𝕩≠':')×1++`𝕩=':'}

# Add balances to parents and then reapply cumulation
CalcBal ← {
    AccountBF ← {p ← AccountParents ⊑1↑𝕩 ⋄ <∾≍⟨⍉≍p, (≠p)/≍1↓⥊𝕩⟩}
	s         ← {{⟨⟩≢𝕩}¨⊏˘𝕩}⊸/CalcBalPlain 𝕩
	b         ← ⊏˜⟜{⍋1↑˘𝕩}∾´AccountBF˘s
	CalcBalPlain ∾≍⟨+`≢¨⟜»1↑˘b, b⟩
}

# Add total row to bal report
BalTotals ← {t ← +´˘⍉1↓˘𝕩 ⋄ 𝕩∾t∾˜<"Total"}

ReportBal ← {com‿bal‿prices: BalTotals CalcBal bal}