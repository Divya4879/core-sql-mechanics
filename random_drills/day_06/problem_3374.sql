/* =====================================================================================
   LEETCODE 3374: First Letter Capitalization II (Hard String Manipulation)
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      String Tokenization, The Tally Table (Numbers CTE) Architecture, 
      & Multi-Phase Sequence Reconstruction (`GROUP_CONCAT`)
      
   2. 🚨 PITFALLS, WEAKNESSES, & TRAPS:
      - The Recursive Character Loop: Attempting to use `WITH RECURSIVE` to process a string 
        one character at a time requires tracking boolean states (e.g., `in_word`, `after_hyphen`) 
        row-by-row. This is incredibly slow and almost always fails on edge cases like consecutive 
        spaces or special characters.
      - The Spacing Wipeout: If you use simple `REPLACE` or standard extraction tricks, you 
        will delete consecutive spaces (e.g., "Hello   World"). LeetCode specifically requires 
        exact formatting preservation.

   3. CORE INSIGHT & CODE MECHANICS (The Tally Table Tokenizer):
      Since MySQL lacks a native `STRING_SPLIT()` function, we build a 5-Phase Tokenization Pipeline:
      
      - Phase 1 (The Engine): Create a "Tally Table" (`Numbers`) containing integers 1 to 1000. 
        This acts as our loop counter.
      - Phase 2 (Explode by Space): We join the string to the Numbers table, extracting the Nth 
        word using `SUBSTRING_INDEX`. Crucially, consecutive spaces extract as empty strings `""`, 
        which mathematically preserves the exact spacing footprint.
      - Phase 3 (Explode by Hyphen): If a extracted word perfectly matches the strict hyphen 
        rule (`^[a-zA-Z]+(-[a-zA-Z]+)+$`), we run it through the exact same Tally Table logic 
        again, breaking it into sub-parts (e.g., "FRONT-end" -> "FRONT", "end").
      - Phase 4 (Transform & Rebuild Hyphens): We capitalize the sub-parts and glue them back 
        together with `-` using `GROUP_CONCAT( ... SEPARATOR '-')`.
      - Phase 5 (The Final Assembly): We evaluate every word. If it doesn't start with a letter, 
        skip it. If it has hyphens, pull from Phase 4. Otherwise, just capitalize the first letter. 
        Finally, `GROUP_CONCAT` the entire sequence back together with spaces.

   4. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      - Diagnostic Question: "I need to split a string by spaces/commas in MySQL and alter the words."
        NEVER iterate character-by-character. 
        ALWAYS build a Numbers CTE, use `SUBSTRING_INDEX` to extract the `N`th element, perform 
        your math, and `GROUP_CONCAT` it back together.
   ===================================================================================== */

-- =====================================================================================
-- THE OPTIMAL INDUSTRY-STANDARD APPROACH (Tally Table Tokenization)
-- =====================================================================================
WITH Numbers AS (
    -- Phase 1: Generate a Tally Table of 1 to 1000 instantly using Cross Joins
    SELECT a.N + b.N * 10 + c.N * 100 + 1 AS n
    FROM 
    (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
    CROSS JOIN (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
    CROSS JOIN (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c
),

WordList AS (
    -- Phase 2: Split the sentence into distinct rows by space
    SELECT 
        content_id,
        content_text AS original_text,
        n AS word_pos,
        SUBSTRING_INDEX(SUBSTRING_INDEX(content_text, ' ', n), ' ', -1) AS word
    FROM user_content
    -- Only loop up to the exact number of spaces + 1
    JOIN Numbers ON n <= LENGTH(content_text) - LENGTH(REPLACE(content_text, ' ', '')) + 1
),

HyphenSplit AS (
    -- Phase 3: Take ONLY the words that match the strict Hyphen Rule, and split them further
    SELECT 
        content_id,
        word_pos,
        n AS hyphen_pos,
        SUBSTRING_INDEX(SUBSTRING_INDEX(word, '-', n), '-', -1) AS part
    FROM WordList
    JOIN Numbers ON n <= LENGTH(word) - LENGTH(REPLACE(word, '-', '')) + 1
    -- Regex enforces "consists of two or more non-empty parts of English letters connected by hyphens"
    WHERE word REGEXP '^[a-zA-Z]+(-[a-zA-Z]+)+$'
),

HyphenRebuilt AS (
    -- Phase 4: Capitalize the sub-parts and glue the hyphenated word back together
    SELECT 
        content_id,
        word_pos,
        GROUP_CONCAT(
            CONCAT(UPPER(LEFT(part, 1)), LOWER(SUBSTRING(part, 2)))
            ORDER BY hyphen_pos SEPARATOR '-'
        ) AS transformed_word
    FROM HyphenSplit
    GROUP BY content_id, word_pos
),

FinalWords AS (
    -- Phase 5: Routing logic for all words
    SELECT 
        W.content_id,
        W.original_text,
        W.word_pos,
        CASE 
            -- Preserve exact spaces
            WHEN W.word = '' THEN ''
            -- Rule 1: Starts with non-letter, skip entirely
            WHEN W.word NOT REGEXP '^[a-zA-Z]' THEN W.word
            -- Rule 2: Strict hyphenated words pull from the Rebuilt CTE
            WHEN W.word REGEXP '^[a-zA-Z]+(-[a-zA-Z]+)+$' THEN H.transformed_word
            -- Rule 3: Standard capitalization
            ELSE CONCAT(UPPER(LEFT(W.word, 1)), LOWER(SUBSTRING(W.word, 2)))
        END AS new_word
    FROM WordList W
    LEFT JOIN HyphenRebuilt H 
        ON W.content_id = H.content_id AND W.word_pos = H.word_pos
)

-- Phase 6: Reconstruct the final output sentence
SELECT 
    content_id,
    original_text,
    GROUP_CONCAT(new_word ORDER BY word_pos SEPARATOR ' ') AS converted_text
FROM FinalWords
GROUP BY content_id, original_text;

/* =====================================================================================
   THE POSTGRESQL ARCHITECTURE (INDUSTRY STANDARD)
   =====================================================================================
   
   1. WHY POSTGRES OUTPERFORMS MYSQL HERE:
      MySQL treats strings as rigid blocks of text, forcing us to build complex mathematical 
      "Tally Tables" to slice them apart. PostgreSQL treats Strings and Arrays as first-class 
      citizens. Postgres natively understands how to explode strings into arrays, process 
      them, and collapse them back together.

   2. ⚡ THE POSTGRESQL NATIVE FUNCTION CRASH COURSE:
      If you are building a Python/Postgres backend, you must memorize these functions:
      
      - `string_to_array(text, delimiter)`: Instantly converts 'Hello World' to `[Hello, World]`.
        Crucially, it handles consecutive spaces perfectly without wiping them out.
        
      - `UNNEST(array) WITH ORDINALITY`: The Holy Grail of string parsing. `UNNEST` takes 
        an array and explodes it into vertical rows. `WITH ORDINALITY` automatically attaches 
        a generated index number (1, 2, 3...) to each row so you don't lose the word order!
        
      - `INITCAP(string)`: Postgres has native title-casing. It automatically capitalizes the 
        first letter of a word and lowers the rest. Even better, it natively recognizes 
        hyphens as word boundaries! `INITCAP('FRONT-end')` automatically outputs `Front-End`.
        
      - `Regex Operators (~ and !~)`: Instead of writing `REGEXP` or `NOT REGEXP`, Postgres 
        uses `~` for match and `!~` for negative match. 
        
      - `array_to_string(array_agg(column), delimiter)`: The Postgres equivalent of `GROUP_CONCAT`. 
        You use `array_agg` to pack the rows back into a list, and `array_to_string` to glue 
        that list together with spaces.

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE PYTHON BACKEND CAREER:
      - Diagnostic Question: "I need to manipulate individual words inside a sentence in Postgres."
        Pipeline: `string_to_array` -> `UNNEST WITH ORDINALITY` -> `CASE WHEN` -> `array_to_string(array_agg)`.
   ===================================================================================== */

WITH WordList AS (
    -- Phase 1: Explode the string into rows and instantly generate index numbers
    SELECT 
        content_id,
        content_text AS original_text,
        word,
        word_pos
    -- In Postgres, joining an unnested array automatically aligns the rows to the parent table
    FROM user_content,
    UNNEST(string_to_array(content_text, ' ')) WITH ORDINALITY AS t(word, word_pos)
),

FinalWords AS (
    -- Phase 2: Apply the business routing logic
    SELECT 
        content_id,
        original_text,
        word_pos,
        CASE 
            -- Rule 1: Preserve consecutive spaces (empty strings)
            WHEN word = '' THEN ''
            -- Rule 2: If it does NOT start with an English letter, keep unchanged (!~ is NOT REGEXP)
            WHEN word !~ '^[a-zA-Z]' THEN word
            -- Rule 3: INITCAP natively handles both standard words AND hyphenated words perfectly
            ELSE INITCAP(word)
        END AS new_word
    FROM WordList
)

-- Phase 3: Rebuild the sentence from the transformed rows
SELECT 
    content_id,
    original_text,
    array_to_string(array_agg(new_word ORDER BY word_pos), ' ') AS converted_text
FROM FinalWords
GROUP BY content_id, original_text;