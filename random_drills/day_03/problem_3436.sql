/* =====================================================================================
   LEETCODE 3436: Find Valid Emails
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      String Validation via Regular Expressions (`REGEXP`)
      
   2. CORE INSIGHT & CODE MECHANICS:
      Standard SQL `LIKE` operators (`%`, `_`) are too weak to validate complex string structures 
      like email addresses. You must use the `REGEXP` operator to define a strict structural pattern.

      Breaking down the User's Regex Pattern: '^[A-Za-z0-9_]+@[A-Za-z]+\\.com$'
      
      - THE ANCHORS: 
        `^` : Asserts the position at the absolute START of the string.
        `$` : Asserts the position at the absolute END of the string.
        (Without `^` and `$`, the regex would match an invalid email like "bad!alice@example.com!bad" 
        because the valid pattern exists *somewhere* in the middle).

      - THE PREFIX (Before the @):
        `[A-Za-z0-9_]` : A "Character Class". It tells the engine "allow any uppercase letter, 
        any lowercase letter, any digit, or an underscore".
        `+` : A "Quantifier". It means "one or more of the preceding element". So, one or more 
        alphanumeric/underscore characters.

      - THE @ SYMBOL:
        `@` : A literal character match.

      - THE DOMAIN (After @, before .com):
        `[A-Za-z]` : Allow ONLY uppercase or lowercase letters (no numbers, no underscores).
        `+` : One or more of those letters.

      - THE EXTENSION:
        `\\.` : The dot `.` is a special wildcard character in regex that means "match ANY character". 
        To tell the engine you want an actual, literal dot, you must "escape" it. In MySQL string 
        literals, you use two backslashes `\\` to pass a single backslash `\` to the regex engine.
        `com` : Literal character match for "com".

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later, ask yourself these diagnostic questions:
      - Question A: "Does the string have to match this pattern EXACTLY from start to finish?" 
        If yes, you must wrap your pattern in `^` and `$`.
      - Question B: "How do I match a specific group of allowed characters?" 
        Put them in square brackets `[...]`.
      - Question C: "How do I say 'at least one of these'?" 
        Put a `+` directly after the character or bracket.
      - Question D: "How do I search for a literal dot or special character?" 
        Escape it with `\\` in MySQL.

   4. COMMON PITFALLS TO AVOID:
      - Forgetting anchors (`^` and `$`): This is the #1 regex mistake. Without them, it acts like a `LIKE '%pattern%'` search.
      - Using `*` instead of `+`: The `*` quantifier means "ZERO or more", meaning a blank prefix would pass. `+` strictly enforces "ONE or more".
      - Forgetting to escape the dot (`.com` instead of `\\.com`): An unescaped dot would match "exampleXcom" or "example9com" instead of just "example.com".
   ===================================================================================== */

-- =====================================================================================
-- YOUR EXACT SOLUTION CODE
-- =====================================================================================
SELECT 
    user_id, 
    email
FROM Users
-- Ensure the email strictly matches the required prefix, @, letter-only domain, and .com format
WHERE email REGEXP '^[A-Za-z0-9_]+@[A-Za-z]+\\.com$'
ORDER BY user_id ASC;