⟨ProcessInput⟩⇐

err ← "Error"
of ← 1‿0‿¯1

# Amounts to columns by commodity
AddCommodityCols ← {
			  # commodity per TA
			  t  ← ⊑¨2↓¨2⊏˘𝕩
			  # unique commodities
			  com ← ⍷t
			  # amount array by commodities
			  am ← (×´˘⊑˘2↑¨2↓˘𝕩)×t≡⌜com
			  com‿am
}

RemCommodityCols ← {(<¨(≠𝕨)/1↑˘𝕩)∾¨⥊<¨(⟨≠𝕩, ≠𝕨⟩⥊1)∾¨(<¨⟨≠𝕩, ≠𝕨⟩⥊𝕨)∾¨(1↓˘𝕩)}
	
# Overflow rows for balancing
AddErrorRows ← {
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

# Find balancing errors
BalancingErrors ← {
				⟨k, b⟩:
				# an error row may contain a currency exchange	
				e0 ← ({err≡𝕩}¨1⊏˘k)∧¬({0=+´𝕩}∧{2=+´|¨𝕩})˘×¨2↓˘b
				# an overflow row may contain one currency
				o0 ← {({of≡𝕩}¨2⊏˘k)∧¬{err≡𝕩}¨1⊏˘k}×¬({2>+´|¨𝕩})˘×¨2↓˘b
				m ← b/˜0<¨e0+o0
}

# match 𝕩 to 𝕨 based on id in first col
MatchFirst ← {⟨𝕨,𝕩⊏˜𝕨⊏○(⊑˘)𝕩⟩}

RemErrorRows ← {𝕩/˜{err≢𝕩}¨1⊏˘𝕩}

BalanceTAs ← {⍉∾⍉¨⟨2↑˘𝕩, 𝕨+¯1×-⟜»{𝕨>○|𝕩?𝕨;𝕩}`(0=+´˘𝕨)×+`𝕨⟩}

ProcessInput ← {
			 com‿am ← AddCommodityCols 𝕩
			 k0 ← AddErrorRows am‿𝕨‿𝕩
			 com‿am ↩ AddCommodityCols k0
			 bal ← am BalanceTAs k0
			 errs ← 𝕨 MatchFirst˜ BalancingErrors ⟨k0, bal⟩				 
			 bal ↩ RemErrorRows bal
			 ⟨com, bal, errs⟩
}