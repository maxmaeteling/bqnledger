ns_parser ← •Import "parse.bqn"
⟨Journal, ParseJournal⟩⇐ns_parser

input ← •FChars "test.ledger"

j‿k ← ParseJournal input

AmountCols ← {
		   # commodity per TA
		   t ← ⊑¨2↓¨2⊏˘𝕩
		   # unique commodities
		   com ← ⍷t
		   # amount array by commodities
		   am ← (×´˘⊑˘2↑¨2↓˘𝕩)×t≡⌜com
		   com‿am
}

com‿am ← AmountCols k

# empty TAs are used for balancing
e ← 0=+´˘am

# add empty posting fallback
em ← (1↑˘j)(¬∘∊/⊣)(e/1↑˘k)

# add fallback rows at end and put them to right index
tmp ← k∾(⍉∾⍉¨⟨em,(≠em)/≍"System:Error"‿⟨1, 0, -1⟩‿⟨⟩⟩)
k0 ← tmp⊏˜⍋({𝕩≡⟨1, 0, -1⟩}¨(2⊏˘tmp))+2×1↑˘tmp

com‿am ↩ AmountCols k0

# balanced TAs
bal ← ⍉∾⍉¨⟨2↑˘k0, am+¯1×-⟜»⌈`(0=+´˘am)×+`am⟩

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
		AccountBF      ← {p ← AccountParents ⊑1↑𝕩 ⋄ <⍉∾⍉¨⟨⍉≍p, (≠p)/≍1↓⥊𝕩⟩}
		s              ← {{⟨⟩≢𝕩}¨⊏˘𝕩}⊸/CalcBalPlain 𝕩
		b              ← ⊏˜⟜{⍋1↑˘𝕩}∾´AccountBF˘ s
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
