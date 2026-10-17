/* =====================================================================================
   LEETCODE 3465: Find Products with Valid Serial Numbers
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Substring Regex Extraction, Explicit Word Boundaries, Exact Quantifiers (`{n}`), 
      & Case-Sensitive Function Flags (`REGEXP_LIKE(..., 'c')`)
      
   2. CORE INSIGHT & CODE MECHANICS:
      When searching for a strict pattern *inside* a larger block of text (like a description), 
      you cannot simply anchor the regex to the start (`^`) and end (`$`) of the string. However, 
      without anchors, a loose regex like `SN[0-9]{4}-[0-9]{4}` will falsely match an invalid 
      serial number like "SN1234-56789" (because the first 4 digits match, ignoring the 9).

      To solve this, you must define "Boundaries" around your pattern. 

      Breaking down the User's Regex: '(^|[^a-zA-Z0-9])SN[0-9]{4}-[0-9]{4}([^a-zA-Z0-9]|$)'
      
      - THE LEFT BOUNDARY `(^|[^a-zA-Z0-9])`:
        The pipe `|` means OR. This tells the engine: "Before the 'SN', there must be EITHER the 
        absolute start of the string (`^`), OR a character that is NOT (`^` inside brackets) 
        an alphanumeric letter/number." This ensures the 'SN' isn't attached to a word like "MySN".

      - THE CORE PATTERN `SN[0-9]{4}-[0-9]{4}`:
        `SN`: Matches literal "SN".
        `[0-9]{4}`: The curly braces `{4}` are an Exact Quantifier. It means "match exactly 4 digits, 
        no more, no less."
        `-`: Literal hyphen.

      - THE RIGHT BOUNDARY `([^a-zA-Z0-9]|$)`:
        "After the last 4 digits, there must be EITHER a non-alphanumeric character (like a space 
        or period) OR the absolute end of the string (`$`)." This prevents matching "SN1234-56789".

      - THE CASE FLAG `'c'`:
        By default, MySQL regex is case-insensitive. Using `REGEXP_LIKE(column, pattern, 'c')` 
        forces case-sensitivity, ensuring it only matches "SN", not "sn" or "Sn".

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later in your career, ask yourself these diagnostic questions:
      - Question A: "Am I looking for an exact count of characters?" 
        Use the curly brace quantifier `{n}`.
      - Question B: "Am I searching for a pattern embedded inside a larger sentence?" 
        Do not use global `^` and `$` anchors on the outside. Instead, build your own word 
        boundaries using `(^|[^a-zA-Z0-9])` to ensure the target isn't glued to surrounding text.
      - Question C: "Does case matter?" 
        Standard `REGEXP` is case-insensitive. Switch to the `REGEXP_LIKE()` function and pass 
        the `'c'` parameter to enforce strict casing.

   4. COMMON PITFALLS TO AVOID:
      - Using `LIKE '%SN____-____%'`: `LIKE` cannot distinguish between numbers and letters; it 
        would falsely match "SNABCD-EFGH".
      - Forgetting boundary constraints, which allows the regex engine to find 4 digits hiding 
        inside a 5-digit number.
   ===================================================================================== */

-- =====================================================================================
-- YOUR EXACT SOLUTION CODE
-- =====================================================================================
SELECT
    product_id,
    product_name,
    description
FROM
    products
WHERE
    -- [[:space:]] or punctuation boundaries are safer, or standard whitespace/line anchors:
    -- 'c' flag enforces strict case-sensitivity for 'SN'
    REGEXP_LIKE(description, '(^|[^a-zA-Z0-9])SN[0-9]{4}-[0-9]{4}([^a-zA-Z0-9]|$)', 'c')
ORDER BY
    product_id ASC;

/* =====================================================================================
   OPTIMAL & REFINED APPROACH (Native Word Boundaries)
   =====================================================================================
   
   Improvements made in this optimal version:
   1. Dropped Manual Exclusions: The manual boundary logic `(^|[^a-zA-Z0-9])` is mathematically 
      correct but verbose. Modern SQL Regex provides a single native token for this: `\\b`.
   2. The `\\b` Token (Word Boundary): It acts as an invisible zero-width anchor that asserts: 
      "The character before this and the character after this must form a clean break (a space, 
      a comma, or the start/end of the string)."
   3. SQL Escaping: Regex natively uses `\b`, but inside a MySQL string literal, you must escape 
      the backslash itself, writing it as `\\b`.
   ===================================================================================== */

/*
SELECT
    product_id,
    product_name,
    description
FROM products
WHERE 
    -- \\b ensures a clean word boundary before 'SN' and after the final 4 digits
    REGEXP_LIKE(description, '\\bSN[0-9]{4}-[0-9]{4}\\b', 'c')
ORDER BY 
    product_id ASC;
*/