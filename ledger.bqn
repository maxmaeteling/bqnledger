⟨Journal, ParseJournal⟩ ⇐ •Import "parse.bqn"
⟨ProcessInput⟩ ⇐ •Import "process_input.bqn"
⟨ReportBal⟩ ⇐•Import "report_bal.bqn"

input ← •FChars "test.ledger"

KeepEntries  ← {1↓¨𝕩/˜(⊑¨𝕩)∊⋈"e"}
KeepEntries ⊑Journal input

# j‿k ← ParseJournal input

# ⟨com, bal, errs⟩ ← j ProcessInput k

# fields_ta ← ⟨"index", "date", "date_cleared", "status", "ta_code", "desc"⟩
# fields_posting ← ⟨"index", "account", "ac", "ac_price"⟩

# ReportBal bal