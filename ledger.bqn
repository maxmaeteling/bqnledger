ns_parser ← •Import "parse.bqn"
⟨Journal, ParseJournal⟩⇐ns_parser

input ← •FChars "test.ledger"

j‿k ← ParseJournal input

err ← "Error"
of ← 1‿0‿¯1

# Amounts to columns by commodity
CommodityCols ← {
			  # commodity per TA
			  t  ← ⊑¨2↓¨2⊏˘𝕩
			  # unique commodities
			  com ← ⍷t
			  # amount array by commodities
			  am ← (×´˘⊑˘2↑¨2↓˘𝕩)×t≡⌜com
			  com‿am
}

com‿am ← CommodityCols k

# Overflow rows for balancing
ErrorRows ← {
	  am‿j‿k :
	  # empty TAs are used for balancing
	  e ← 0=+´˘am
	  # add empty posting fallback
	  em ← (1↑˘j)(¬∘∊/⊣)(e/1↑˘k)
	  # append fallback rows 
	  t ← k∾(⍉∾⍉¨⟨em,(≠em)/≍⟨err, of, ⟨⟩⟩⟩)
	  # put fallback rows to right index
	  t⊏˜⍋({𝕩≡of}¨(2⊏˘t))+2×1↑˘t
}

k0 ← ErrorRows am‿j‿k
com‿am ↩ CommodityCols k0

# balanced TAs
bal ← ⍉∾⍉¨⟨2↑˘k0, am+¯1×-⟜»{𝕨>○|𝕩?𝕨;𝕩}`(0=+´˘am)×+`am⟩

# Find balancing errors
BalancingErrors ← {
				⟨k, b⟩:
				# an error row may contain a currency exchange	
				e0 ← ({err≡𝕩}¨1⊏˘k)∧¬({0=+´𝕩}∧{2=+´|¨𝕩})˘×¨2↓˘b
				# an overflow row may contain one currency
				o0 ← {({of≡𝕩}¨2⊏˘k)∧¬{err≡𝕩}¨1⊏˘k}×¬({2>+´|¨𝕩})˘×¨2↓˘b
				m ← b/˜0<¨e0+o0
}
err ← BalancingErrors ⟨k0, bal⟩

# match 𝕩 to 𝕨 based on id in first col
MatchFirst ← {
		  ⟨𝕨,𝕩⊏˜𝕨⊏○(⊑˘)𝕩⟩
}
err MatchFirst j

RemErrorRows ← {𝕩/˜{err≢𝕩}¨1⊏˘𝕩}
bal ↩ RemErrorRows bal

# calculate account balance
CalcBalPlain ← {
		# sort/ group accounts
		s ← 𝕩⊏˜⍋1⊏˘𝕩
		# last in group?
		l ← ≢¨⟜«1⊏˘s
		# merge dependent cumulative sums and accounts
		⍉∾⍉¨⟨⍉≍l/1⊏˘s,-⟜»l/+`2↓˘s⟩
}

AccountParents ← {{𝕨∾":"∾𝕩}`𝕩⊔˜1-˜(𝕩≠':')×1++`𝕩=':'}

# Add balances to parents and then reapply cumulation
CalcBal ← {
		AccountBF ← {p ← AccountParents ⊑1↑𝕩 ⋄ <⍉∾⍉¨⟨⍉≍p, (≠p)/≍1↓⥊𝕩⟩}
		s         ← {{⟨⟩≢𝕩}¨⊏˘𝕩}⊸/CalcBalPlain 𝕩
		b         ← ⊏˜⟜{⍋1↑˘𝕩}∾´AccountBF˘s
		CalcBalPlain ⍉∾⍉¨⟨+`≢¨⟜»1↑˘b, b⟩
}

CalcBal bal

# # calculate parent indexes from sorted depths
# DepthParents ← { ⌈´˘(𝕩=⌜1+˜↕⌈´𝕩)×⌈`(↕≠𝕩)×𝕩=⌜↕⌈´𝕩 }

# # create account tree
# AccountTree ← {
# 			t ← (∧⍷∾{{𝕨∾":"∾𝕩}`𝕩⊔˜1-˜(𝕩≠':')×1++`𝕩=':'}¨𝕩)
# 			dep ← (+´¨t=¨':')
# 			par ← DepthParents dep
# 			⟨t, dep, par⟩
# }

# AccountTree ⊏˘bal_sums

# multiple commodities unbalanced
1<+´˘0≠bal
